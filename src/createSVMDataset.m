% creates the dataset comprised of 0 (nonose) 1 (nose)
% with hog feature vectors


% change this parameters to influence hog feature vector
cellSize = 4;
numOrientations = 7;

patch_path = '../cache/patches';
filenames = getFilenames(patch_path);

% data matrix X
X = [];

im_range = length(filenames);
for i=1:im_range
    file = filenames{i};
    disp(['processing ', file,  ' (', num2str(i), '/', num2str(im_range),') ...'])
    patch_name = strcat(patch_path, filesep, file);
    row = getHOGFeatureVector(patch_name, cellSize, numOrientations);
    X = [X;row];
end

% write to cache
csvwrite('../cache/hogfeatures.csv', X);