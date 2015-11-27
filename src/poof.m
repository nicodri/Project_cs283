% author_name = Nicolas Drizard
% Birds dataset processing
%
%   Script to implement the POOF approach

%% Loading the data created by birds.m
load img_2_classes

%% Parameters

% Selected parts
f = 1;
a = 5;

%% Step 1: Similarity transform

% Restricting to the images containing these parts
% Class i
id_i_f = img_i_part((img_i_part(:,2) == f & img_i_part(:,5) == 1), 1);
parts_i_f = img_i_part(img_i_part(:,2) == f, [1, 3, 4]);
id_i_a = img_i_part((img_i_part(:,2) == a & img_i_part(:,5) == 1), 1);
parts_i_a = img_i_part(img_i_part(:,2) == a, [1, 3, 4]);

id_i = intersect(id_i_f, id_i_a);
local_index_i = id_i - stepi;

% Class j
id_j_f = img_j_part((img_j_part(:,2) == f & img_j_part(:,5) == 1), 1);
parts_j_f = img_j_part(img_j_part(:,2) == f, [1, 3, 4]);
id_j_a = img_j_part((img_j_part(:,2) == a & img_j_part(:,5) == 1), 1);
parts_j_a = img_j_part(img_j_part(:,2) == a, [1, 3, 4]);

id_j = intersect(id_j_f, id_j_a);
local_index_j = id_j - stepj;

% Sanitary plot: Displaying the two selected part
% id = local_index_i(1,1);
% im_test_i = img_i{id,1};
% imshow(im_test_i); hold on;
% plot(parts_i_f(id,2),parts_i_f(id,3),'r.','MarkerSize',20); hold on;
% plot(parts_i_a(id,2),parts_i_a(id,3),'y.','MarkerSize',20); hold on;

% We need to transform each image to have the two part based features f and
% a at the same position. We fit a similarity transformation to each
% training images.
%
% Reference position: f and aligned in the middle
%           128 pix
%    -----------------------
% 6 |                       |
% 4 |                       |
% p |     f  64 pix   a     |
% i |                       |
% x |                       |
%    -----------------------

fixedPoints = [32, 32; 96, 32];

% Transforming the image of the class i
img_croped_i = cell(size(local_index_i,1),1);
for idx=1:size(local_index_i,1)
    id = local_index_i(idx,1);
    im = img_i{id,1};
    movingPoints = [parts_i_f(id,2:3); parts_i_a(id,2:3)];

    % Apply axial symmetrie if needed
    if movingPoints(1,1) > movingPoints(2,1)
        % Change the position of the parts
        movingPoints(:, 1) = size(im,2) - movingPoints(:, 1);
        ref_im = zeros(size(im), 'like', im);
        for k=1:size(im,2)
            ref_im(:,k, :) = im(:, size(im,2) - k + 1, :);
        end
        im = ref_im;
    end

    % Fitting the similarity
    tform = fitgeotrans(movingPoints,fixedPoints,'NonreflectiveSimilarity');

    % New image
    img_croped_i{idx,1} = imwarp(im,tform,'OutputView',imref2d([64, 128]));
end

% Transforming the image of the class j
img_croped_j = cell(size(local_index_j,1),1);
for idx=1:size(local_index_j,1)
    id = local_index_j(idx,1);
    im = img_j{id,1};
    movingPoints = [parts_j_f(id,2:3); parts_j_a(id,2:3)];

    % Apply axial symmetrie if needed
    if movingPoints(1,1) > movingPoints(2,1)
        % Change the position of the parts
        movingPoints(:, 1) = size(im,2) - movingPoints(:, 1);
        ref_im = zeros(size(im), 'like', im);
        for k=1:size(im,2)
            ref_im(:,k, :) = im(:, size(im,2) - k + 1, :);
        end
        im = ref_im;
    end

    % Fitting the similarity
    tform = fitgeotrans(movingPoints,fixedPoints,'NonreflectiveSimilarity');

    % New image
    img_croped_j{idx,1} = imwarp(im,tform,'OutputView',imref2d([64, 128]));
end

% Sanitary plot
test_im = img_croped_j{40,1};
imshow(test_im); hold on;
plot(fixedPoints(:,1),fixedPoints(:,2),'r.','MarkerSize',20);

%% Step 2: Tiling images

% We use 2 scales of grid to compute the base features: 8x8 and 16x16

% HOG features

% Data structure:
%   hog_tile -->  cell of (number of tiles, f_tile)
%   f_tile --> cell of (number of images, features)
%   features --> 1*N vector with:


tiles = [8 8; 16 16];
hog_tile = cell(size(tiles,1), 1);
for t=1:size(hog_tile, 1)
    tile = tiles(t,:);
    % Compute the HOG feature size
    u = floor(([64 128]./tile - [2 2])./([2 2] - [1 1]) + 1);
    N = prod([u, [2 2], 9]);
    % Class i
    X_tile_i = zeros(size(img_croped_i,1), N + 1);
    for idx=1:size(img_croped_i,1)
        im = img_croped_i{idx, 1};
        [f, hogVisualization] = extractHOGFeatures(im,'CellSize',tile);
        % First column is the class indicator
        X_tile_i(idx,:) = horzcat(1, f);
    end

    % Class j
    X_tile_j = zeros(size(img_croped_j,1), N + 1);
    for idx=1:size(img_croped_j,1)
        im = img_croped_i{idx, 1};
        [f, hogVisualization] = extractHOGFeatures(im,'CellSize',tile);
        % First column is the class indicator
        X_tile_j(idx,:) = horzcat(0, f);
    end
    hog_tile{t,1} = vertcat(X_tile_i, X_tile_j);
end

% Sanity check (pllot last one computed)
figure;
imshow(im); hold on;
plot(hogVisualization);

%% Step 3: Train SVM with features the concatenation of the base features

% Building the training set with a column for the class for each tiling
tiles = [8 8; 16 16];
svm_tile = cell(size(tiles,1), 1);
for t=1:size(hog_tile, 1)
    X = hog_tile{t,1};
    svm = fitcsvm(X(:,2:end), X(:,1));
    svm_tile{t,1} = svm;
end

%% Step 4: Assigning a score to each grid cell and thresholding


% To DO: 
%   What is the dimension of the HOG features per grid?
%   Mapping the hog feature with its corresponding cell
