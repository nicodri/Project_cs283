% build svm first

% % load data from csv
% M = csvread('../cache/hogfeatures.csv');
% 
% % X is the data matrix, y is the response
% X = M(:, 2:end);
% y = M(:, 1);
% svmmdl = fitcsvm(X, y);

% now create a sliding window

% first compute HOG features of the whole image
image_name = '../cache/lq/w_487_lq.jpg';

% add vlfeat path
addpath('./vlfeat/toolbox');

Im = im2single(imread(image_name));
%imshow(Im)

% % change this parameters to influence hog feature vector
% cellSize = 4;
% numOrientations = 7;

hog = vl_hog(Im, cellSize, 'numOrientations', numOrientations);

patch_size = 128;
winsize = int32(patch_size / cellSize);

% go through whole image, predicting its class
num = 1;
labels = zeros([size(hog, 1) - winsize, size(hog, 2) - winsize]);
scores = zeros([size(hog, 1) - winsize, size(hog, 2) - winsize]);
for i=1:size(hog, 1) - winsize
    for j=1:size(hog, 2) - winsize
        disp(['processing window ', num2str(num), '/', num2str((size(hog,1) - winsize) * (size(hog, 2) - winsize))]);
        
        W = hog(i:i+winsize-1, j:j+winsize-1, :);
        W = W(:);
        [label, score] = predict(svmmdl, W');
        labels(i, j) = label;
        scores(i, j) = score;
        num = num + 1;
    end
end
