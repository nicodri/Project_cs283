% author_name = Nicolas Drizard
% Birds dataset processing
%
%   Script to read the data from CUB 200-2011

delimiterIn = ' '; 
headerlinesIn = 0;

%% Image class

filename = 'CUB_200_2011/CUB_200_2011/image_class_labels.txt';

% format is (img_id, class_id)
img_class = importdata(filename,delimiterIn,headerlinesIn);

%% Bounding box

filename = 'CUB_200_2011/CUB_200_2011/bounding_boxes.txt';

% format is (img_id, x, y, w, h)
bounding_boxes = importdata(filename,delimiterIn,headerlinesIn);

%% Parts location

filename = 'CUB_200_2011/CUB_200_2011/parts/part_locs.txt';

% format is (img_id, part_id, x, y, visible)
part_locs = importdata(filename,delimiterIn,headerlinesIn);

%% Train/test

filename = 'CUB_200_2011/CUB_200_2011/train_test_split.txt';

% format is (img_id, is training)
training = importdata(filename,delimiterIn,headerlinesIn);

%% Images

filename = 'CUB_200_2011/CUB_200_2011/images.txt';

% format is (img_id, is training)
images = importdata(filename);
N = size(images,1);

% Formating images
images_clean = cellfun(@(s) strsplit(s, delimiterIn), images, 'UniformOutput', false);
images_id = cell(size(images_clean,1),2);
for i=1:size(images_clean,1)
    s = images_clean{i,1};
    images_id{i,1} = s{1,1};
    images_id{i,2} = s{1,2};
end

%% Building a working set
%
%   objective:
%       images of 2 different classes restricted to their bounding boxes
%       with part locations in common

% Loading the images
rep = 'CUB_200_2011/CUB_200_2011/images/';

% Class i
% stores at the row local_id the bounding box of the images
% img1_id(local_id)
classi = 1;
worki = img_class(img_class(:,2) == classi, :);
stepi =worki(1,1)-1;
Ni = size(worki, 1);

img_i = cell(Ni,1);
img_i_part = zeros(15*Ni, 5);
img_i_id = zeros(Ni,1);


for i=1:Ni
    id = worki(i,1);
    img_i_id(i,1) = id;
    filename = strcat(rep, images_id{id, 2});
    im = imread(filename);
    % Restricting to the bouding box
    dim = bounding_boxes(id,2:end);
    % Reversing the axes
    img_i{i,1} = im(dim(1,2):dim(1,2)+dim(1,4)-1, dim(1,1):dim(1,1)+dim(1,3)-1,:);
    for k=1:15
        parts = part_locs(15*(id-1)+k,:);
        if parts(1,5) == 1
            parts(1,3) = parts(1,3) - dim(1,1);
            parts(1,4) = parts(1,4) - dim(1,2);
        end
        img_i_part(15*(i-1)+k,:) = parts;
    end
end

% Class j
% stores at the row local_id the bounding box of the images
% img1_id(local_id)
classj = 2;
workj = img_class(img_class(:,2) == classj, :);
stepj =workj(1,1)-1;
Nj = size(workj, 1);

img_j = cell(Nj,1);
img_j_part = zeros(15*Nj, 5);
img_j_id = zeros(Nj,1);


for i=1:Nj
    id = workj(i,1);
    img_j_id(i,1) = id;
    filename = strcat(rep, images_id{id, 2});
    im = imread(filename);
    % Restricting to the bouding box
    dim = bounding_boxes(id,2:end);
    % Reversing the axes
    img_j{i,1} = im(dim(1,2):dim(1,2)+dim(1,4)-1, dim(1,1):dim(1,1)+dim(1,3)-1,:);
    for k=1:15
        parts = part_locs(15*(id-1)+k,:);
        if parts(1,5) == 1
            parts(1,3) = parts(1,3) - dim(1,1);
            parts(1,4) = parts(1,4) - dim(1,2);
        end
        img_j_part(15*(i-1)+k,:) = parts;
    end
end

%% Checking result
row = 40;
im = img_j{row,1};
id = img_j_id(row,1);
index = (img_j_part(:,1) == id & img_j_part(:,5) == 1);
parts = img_j_part(index,:);

imshow(im); hold on;
plot(parts(:,3),parts(:,4),'r.','MarkerSize',20)



%% Saving working cell arrays
save ('img_2_classes.mat', 'img_i', 'img_j', 'img_i_part', 'img_j_part');

