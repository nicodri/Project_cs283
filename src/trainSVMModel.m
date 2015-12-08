function [w] = trainSVMModel(csvfile, image_path, hogCellSize, C, epsilon)
%TRAINSVMMODEL trains an SVM model and returns kernel for classification

% step 1: load training data
[trainImages, trainBoxes, trainBoxImages, trainBoxPatches] = ...
    loadTrainData(csvfile, image_path);

% step 2: compute hog features via VLfeat
trainHog = {};
for i = 1:size(trainBoxPatches, 4)
  trainHog{i} = vl_hog(trainBoxPatches(:, :, :, i), hogCellSize);
end
trainHog = cat(4, trainHog{:});

% step 3: get positive / negative samples
% positive samples are given by data
pos = trainHog;

% to get negative samples, sample them uniformly from the images!
% (take the same amount like positive samples!)
neg = [];

multiplier = 8;
% generate one neg sample per image
for i=1:length(trainImages)
    Im = im2single(imread(strcat(image_path, filesep, trainImages{i})));
    for j=1:multiplier
        neg(:, :, :, (i - 1) * multiplier + j) = vl_hog(sampleNegative(Im, trainBoxes(:, i)), hogCellSize);
    end
end

% step 4: Train a SVM
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

% step 5:
% reshape into 2D kernel
w = single(reshape(w, size(trainHog, 2), size(trainHog, 1), [])) ;
end

