function [wall] = trainSVMModelHardNegative(data, image_path, hogCellSize, C, epsilon, num_rounds)
%TRAINSVMMODEL trains an SVM model and returns kernel for classification
% this method uses hard negative mining, i.e. we sample as long negative
% samples till the svm converges

wall = {};

% step 1: compute hog features via VLfeat
trainHog = {};
for i = 1:size(data.trainBoxPatches, 4)
    trainHog{i} = vl_hog(data.trainBoxPatches(:, :, :, i), hogCellSize);
end
trainHog = cat(4, trainHog{:});

% step 2: get positive / negative samples
% positive samples are given by data
pos = trainHog;

% step 3: Train a SVM

% for negative hard mining, we start with only positive samples and then
% add negative samples (until there is nothing wrong classified or a
% stopping criteria is met)

% to get negative samples, sample them uniformly from the images!
% (take the same amount like positive samples!)
neg = [];

for round=1:num_rounds
    disp(['training round ', num2str(round), '/', num2str(num_rounds)]);
    numPos = size(pos, 4);
    numNeg = size(neg, 4);
    
    % fix for empty array
    if isempty(neg)
        numNeg = 0;
    end
    
    % Pack the data into a matrix with one datum per column
    x = cat(4, pos, neg);
    x = reshape(x, [], numPos + numNeg);
    
    % Create a vector of binary labels (+1 for pos, -1 for neg!)
    y = [ones(1, numPos) -ones(1, numNeg)];
    lambda = 1 / (C * (numPos + numNeg));
    
    % Learn the SVM using an SVM solver
    w = vl_svmtrain(x, y, lambda, 'epsilon', epsilon, 'verbose');
    
    % reshape into 2D kernel
    w = single(reshape(w, size(trainHog, 2), size(trainHog, 1), [])) ;
    
    wall{end+1} = w;
    error_patches = [];
    num_errors = 1;
    % now evaluate the model over the testset
    for i=1:length(data.trainImages)
        Im = im2single(imread(strcat(image_path, filesep, data.trainImages{i})));
        box = detect(Im, w, hogCellSize);
        
        % box met?
        if sum(abs(box - double(data.trainBoxes(:, i)) + 0.5)) > 0.005
            box = int32(box+0.5);
            % if not append new negative sample!
            error_patches(:, :, :, num_errors) =...
                vl_hog(Im(box(2):box(4), box(1):box(3), :), hogCellSize);
            num_errors = num_errors + 1;
        end
    end
    
    % append boxes to negative sample & remove duplicates
    neg = cat(4, neg, error_patches);
    z = reshape(neg, [], size(neg, 4)) ;
    [~, keep] = unique(z', 'stable', 'rows') ;
    neg = neg(:, :, :, keep) ;
end

end

