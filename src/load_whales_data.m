% author_name = Nicolas Drizard
% Whales dataset processing
%
%   Script to read the data from the whales and save them in a .mat file
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

% Images

filename = '../whales/images.txt';
% format is (file, name)
images = importdata(filename);
N = size(images,1);

%Image class

filename = '../whales/image_class_labels.txt';
% format is (img_id, class_id)
img_class = importdata(filename,delimiterIn,headerlinesIn);

% Bounding box
% Case images are already as bounded box with format 256*256

% format is (img_id, x, y, w, h)
N_imgs = size(img_class, 1);
o = zeros(N_imgs, 1);
tot = 257*ones(N_imgs, 1);
bounding_boxes = [img_class(:, 1), o, o, tot, tot];

% Parts location

filename = '../whales/part_locs.txt';
% format is (img_id, part_id, x, y, visible)
part_locs = importdata(filename,delimiterIn,headerlinesIn);

% Train/test

%filename = 'CUB_200_2011/CUB_200_2011/train_test_split.txt';
% format is (img_id, is training)

% Import the current training
part_locs = importdata('../whales/training.txt',delimiterIn,headerlinesIn);
% Manual building for the moment, dividing the two classes in half
% training = zeros(size(img_class, 1), 2);
% training(:, 1) = img_class(:, 1);
% for i=1:4
%     class_i = find(img_class(:, 2) == i);
%     train_i = datasample(class_i,int16(size(class_i, 1)/2), 'replace', false);
%     training(train_i, 2)=1;
% end
% % Saving array
% dlmwrite('whales/training.txt', img_part, delimiterIn);


% Formating images id
images_clean = cellfun(@(s) strsplit(s, delimiterIn), images, 'UniformOutput', false);
images_id = cell(size(images_clean,1),2);
for i=1:size(images_clean,1)
    s = images_clean{i,1};
    images_id{i,1} = s{1,1};
    images_id{i,2} = s{1,2};
end

save('imgs_whales.mat', 'images_id', 'img_class', 'bounding_boxes', 'part_locs', 'training');