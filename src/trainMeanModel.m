function [w] = trainMeanModel(csvfile, image_path, hogCellSize)
%TRAINMEANMODEL returns a simple baseline model (mean of hogs)

% step 1: load training data
[trainImages, trainBoxes, trainBoxImages, trainBoxPatches] = ...
    loadTrainData(csvfile, image_path);

% step 2: compute hog features via VLfeat
trainHog = {};
for i = 1:size(trainBoxPatches, 4)
  trainHog{i} = vl_hog(trainBoxPatches(:, :, :, i), hogCellSize);
end
trainHog = cat(4, trainHog{:});

% step 3: estimate model, here by meaning all hog windows!
w = mean(trainHog, 4);

end

