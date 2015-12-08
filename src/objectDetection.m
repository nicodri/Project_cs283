% inspired from https://www.robots.ox.ac.uk/~vgg/practicals/category-detection/index.html

% add vlfeat path
addpath('./vlfeat/toolbox');
setup;

%% Settings:
data_path = strcat('..', filesep, 'data', filesep);
images_path = strcat('..', filesep, 'cache', filesep, 'imgs_subset');
cache_path = strcat('..', filesep, 'cache');

hogCellSize = 8;

% load data
csvfile = strcat(data_path, 'nosepatches.csv');
image_path = strcat(cache_path, filesep, 'lq');
trainData = loadTrainData(csvfile, image_path);


% train a base model (mean)
w = trainMeanModel(trainData,...
    strcat(cache_path, filesep, 'lq'), hogCellSize);
% ==> simple model is not working at all!!!

w = trainSVMModel(trainData,...
   strcat(cache_path, filesep, 'lq'), hogCellSize, 10, 0.01);
% % ==> SVM is ok but not perfect...
% 
% % w = trainSVMModelHardNegative(strcat(data_path, 'nosepatches.csv'),...
% %     strcat(cache_path, filesep, 'lq'), hogCellSize, 10, 0.01, 5);
% 
% % load training data for display
% csvfile = strcat(data_path, 'nosepatches.csv');
% image_path = strcat(cache_path, filesep, 'lq');
% [trainImages, trainBoxes, trainBoxImages, trainBoxPatches] = ...
%     loadTrainData(csvfile, image_path);
% 
% % test on sample image
% % a good example 
% sample_index = 487;
% sample_index = 30;
% sample_image = '../cache/lq/w_487_lq.jpg';
% sample_image = ['../cache/lq/', trainImages{sample_index}];
% % a bad example
% %sample_image = '../cache/lq/w_40_lq.jpg';
% Im = imread(sample_image);
% % extract index of highest score
% detected_bb = detect(Im, w, hogCellSize);
% 
% figure(2)
% 
% imshow(Im)
% hold on
% vl_plotbox(detected_bb, 'r')
% vl_plotbox(double(trainBoxes(:, sample_index))-0.5, 'g')
% 
% 
% 
% 
% 
% 
% 
% 
% % % % render the baseline model
% % % figure(1); clf;
% % % imagesc(vl_hog('render', w));
% % 
% % % step 4: apply baseline model to test image
% % % load sample image
% % sample_image = '../cache/lq/w_487_lq.jpg';
% % %sample_image = '../cache/lq/w_250_lq.jpg';
% % Im = im2single(imread(sample_image));
% % %% visualize scores here...
% % %hog = vl_hog(Im, hogCellSize) ;
% % %scores = vl_nnconv(hog, w, []) ;
% % %imagesc(scores)
% % 
% % figure(2)
% % imshow(Im)
% % hold on
% % vl_plotbox(detection)