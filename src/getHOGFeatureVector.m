% return hog feature vector for a patch
function row = getHOGFeatureVector(patch_name, cellSize, numOrientations)
patch_name = '../cache/patches/nose_0274.png';

% add vlfeat path
addpath('./vlfeat/toolbox');

tmp = getFilename(patch_name);
isnose = strcmp(tmp(1:4), 'nose');

Im = im2single(imread(patch_name));

%imshow(Im)

hog = vl_hog(Im, cellSize, 'numOrientations', numOrientations);

% this code plots the hog classifier
%imhog = vl_hog('render', hog, 'verbose', 'numOrientations', numOrientations);
%clf ; imagesc(imhog) ; colormap gray;

row = hog(:);
row = [1, row'];
end