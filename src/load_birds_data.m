% author_name = Nicolas Drizard
% Birds dataset processing
%
%   Script to read the data from CUB 200-2011 and save them in a .mat file
%   
%   Input: one file per each output
%       
%   Output: save as 'imgs_data.mat' the following matlab variables:
%       - 'images_id': (immg_id, filename)
%       - 'img_class': (img_id, class_id)
%       - 'bounding_boxes': (img_id, x, y, w, h)
%       - 'part_locs': (img_id, part_id, x, y, visible)
%       - 'training': (img_id, is training)

% Parameters
delimiterIn = ' '; 
headerlinesIn = 0;

%Image class

filename = 'CUB_200_2011/CUB_200_2011/image_class_labels.txt';
% format is (img_id, class_id)
img_class = importdata(filename,delimiterIn,headerlinesIn);

% Bounding box

filename = 'CUB_200_2011/CUB_200_2011/bounding_boxes.txt';
% format is (img_id, x, y, w, h)
bounding_boxes = importdata(filename,delimiterIn,headerlinesIn);

% Parts location

filename = 'CUB_200_2011/CUB_200_2011/parts/part_locs.txt';
% format is (img_id, part_id, x, y, visible)
part_locs = importdata(filename,delimiterIn,headerlinesIn);

% Train/test

filename = 'CUB_200_2011/CUB_200_2011/train_test_split.txt';
% format is (img_id, is training)
training = importdata(filename,delimiterIn,headerlinesIn);

% Images

filename = 'CUB_200_2011/CUB_200_2011/images.txt';
% format is (file, name)
images = importdata(filename);
N = size(images,1);

% Formating images id
images_clean = cellfun(@(s) strsplit(s, delimiterIn), images, 'UniformOutput', false);
images_id = cell(size(images_clean,1),2);
for i=1:size(images_clean,1)
    s = images_clean{i,1};
    images_id{i,1} = s{1,1};
    images_id{i,2} = s{1,2};
end

save ('imgs_data.mat', 'images_id', 'img_class', 'bounding_boxes', 'part_locs', 'training');