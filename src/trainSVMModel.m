function [w] = trainSVMModel(data, image_path, hogCellSize, C, epsilon, multiplier)
%TRAINSVMMODEL trains an SVM model and returns kernel for classification

% step 1: compute hog features via VLfeat
trainHog = {};
for i = 1:size(data.trainBoxPatches, 4)
  trainHog{i} = vl_hog(data.trainBoxPatches(:, :, :, i), hogCellSize);
end
trainHog = cat(4, trainHog{:});

% step 2: get positive / negative samples
% positive samples are given by data
pos = trainHog;

% to get negative samples, sample them uniformly from the images!
% (take the same amount like positive samples!)
neg = [];
if nargin < 6
   multiplier = 1;
end

npos = size(pos, 4) + 1;


% generate one neg sample per image
for i=1:length(data.trainImages)
    Im = im2single(imread(strcat(image_path, filesep, data.trainImages{i})));
    for j=1:multiplier
        neg(:, :, :, i * multiplier + j) = vl_hog(sampleNegative(Im, data.trainBoxes(:, i)), hogCellSize);
    
        % get also more positive samples!
        if j > 1
            pos(:, :, :, npos) = vl_hog(samplePositive(Im, data.trainBoxes(:, i)), hogCellSize);
            npos = npos + 1;
        end
    end
end

% step 3: Train a SVM
% Pack the data into a matrix with one datum per column
numPos = size(pos, 4);
numNeg = size(neg, 4);
x = cat(4, pos, neg);
x = reshape(x, [], numPos + numNeg);

% Create a vector of binary labels (+1 for pos, -1 for neg!)
y = [ones(1, size(pos,4)) -ones(1, size(neg,4))];
lambda = 1 / (C * (numPos + numNeg));

% Learn the SVM using an SVM solver
w = vl_svmtrain(x, y, lambda, 'epsilon', epsilon, 'verbose');%, 'MaxNumIterations', 5000);

% step 4:
% reshape into 2D kernel
w = single(reshape(w, size(trainHog, 2), size(trainHog, 1), [])) ;
end

