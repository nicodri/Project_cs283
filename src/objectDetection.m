% inspired from https://www.robots.ox.ac.uk/~vgg/practicals/category-detection/index.html

% add vlfeat path
addpath('./vlfeat/toolbox');
setup;
data_path = strcat('..', filesep, 'data', filesep);
images_path = strcat('..', filesep, 'cache', filesep, 'imgs_subset');
cache_path = strcat('..', filesep, 'cache');

% trainImages: a list of train image names.
% trainBoxes: a 4×N array of object bounding boxes, in the form [xmin,ymin,xmax,ymax].
% trainBoxImages: for each bounding box, the name of the image containing it.
% trainBoxLabels: for each bounding box, the object label. It is one of the index in targetClass.
% trainBoxPatches: a 64×64×3×N array of image patches, one for each training object. Patches are in RGB format.

% step 1: load training data
trainImages = {};
trainBoxes = [];
trainBoxImages = {};
%trainBoxLabels = 1
trainBoxPatches = [];

[trainImages, trainBoxes, trainBoxImages, trainBoxPatches] = ...
    loadTrainData(strcat(data_path, 'nosepatches.csv'), strcat(cache_path, filesep, 'lq'));

% step 2: compute hog features via VLfeat
hogCellSize = 8;
trainHog = {};
for i = 1:size(trainBoxPatches,4)
  trainHog{i} = vl_hog(trainBoxPatches(:,:,:,i), hogCellSize);
end
trainHog = cat(4, trainHog{:});

% step 3: learn a baseline model (i.e. mean)
w = mean(trainHog, 4);

% % render the baseline model
% figure(1); clf;
% imagesc(vl_hog('render', w));

% step 4: apply baseline model to test image
% load sample image
sample_image = '../cache/lq/w_487_lq.jpg';
%sample_image = '../cache/lq/w_250_lq.jpg';
Im = im2single(imread(sample_image));

hog = vl_hog(Im, hogCellSize) ;
scores = vl_nnconv(hog, w, []) ;

% visualize scores here...
%imagesc(scores)

% extract index of highest score
[best, bestIndex] = max(scores(:)) ;
[hy, hx] = ind2sub(size(scores), bestIndex) ;
x = (hx - 1) * hogCellSize + 1 ;
y = (hy - 1) * hogCellSize + 1 ;
modelWidth = size(trainHog, 2) ;
modelHeight = size(trainHog, 1) ;
detection = [
  x - 0.5 ;
  y - 0.5 ;
  x + hogCellSize * modelWidth - 0.5 ;
  y + hogCellSize * modelHeight - 0.5 ;] ;
hold on

figure(2)
imshow(Im)
hold on
vl_plotbox(detection)

% ==> simple model is not working at all!!!


% learn SVM for model
% positive samples are already given
pos = trainHog;

% to get negative samples, sample them uniformly from the images!
neg = [];
% generate one neg sample per image
for i=1:length(trainImages)
    Im = im2single(imread(strcat(cache_path, filesep, 'lq', filesep, trainImages{i})));
    
    neg(:, :, :, i) = vl_hog(sampleNegative(Im, trainBoxes(:, i)), hogCellSize);
end


% step 5: Train a SVM

% Pack the data into a matrix with one datum per column
numPos = size(pos, 4);
numNeg = size(neg, 4);
x = cat(4, pos, neg);
x = reshape(x, [], numPos + numNeg);
% Create a vector of binary labels (+1 for pos, -1 for neg!)
y = [ones(1, size(pos,4)) -ones(1, size(neg,4))];
C = 10 ;
lambda = 1 / (C * (numPos + numNeg));

% Learn the SVM using an SVM solver
w = vl_svmtrain(x,y,lambda,'epsilon',0.01,'verbose');
% reshape into 2D kernel
w = single(reshape(w, modelHeight, modelWidth, [])) ;

% test on sample image
% a good example
sample_index = 487;
sample_image = '../cache/lq/w_487_lq.jpg';
sample_image = ['../cache/lq/', trainImages{sample_index}];
% a bad example
%sample_image = '../cache/lq/w_40_lq.jpg';
Im = im2single(imread(sample_image));

hog = vl_hog(Im, hogCellSize) ;
scores = vl_nnconv(hog, single(w), []) ;

% extract index of highest score
[best, bestIndex] = max(scores(:)) ;
[hy, hx] = ind2sub(size(scores), bestIndex) ;
x = (hx - 1) * hogCellSize + 1 ;
y = (hy - 1) * hogCellSize + 1 ;
modelWidth = size(trainHog, 2) ;
modelHeight = size(trainHog, 1) ;
detection = [
  x - 0.5 ;
  y - 0.5 ;
  x + hogCellSize * modelWidth - 0.5 ;
  y + hogCellSize * modelHeight - 0.5 ;] ;
hold on

figure(2)
imshow(Im)
hold on
vl_plotbox(detection, 'g')
vl_plotbox(double(trainBoxes(:, sample_index))-0.5, 'b')