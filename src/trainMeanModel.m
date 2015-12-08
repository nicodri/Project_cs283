function [w] = trainMeanModel(data, image_path, hogCellSize)
%TRAINMEANMODEL returns a simple baseline model (mean of hogs)

% step 1: compute hog features via VLfeat
trainHog = {};
for i = 1:size(data.trainBoxPatches, 4)
  trainHog{i} = vl_hog(data.trainBoxPatches(:, :, :, i), hogCellSize);
end
trainHog = cat(4, trainHog{:});

% step 2: estimate model, here by meaning all hog windows!
w = mean(trainHog, 4);

end

