% author_name = Nicolas Drizard
% Birds dataset processing
%
%   Script to illustrate the POOF approach

% Need vlfeat installed on the local machine
% run /Users/nicolasdrizard/vlfeat-0.9.20/toolbox/vl_setup.m


% Need vlfeat installed on the local machine
run /Users/nicolasdrizard/vlfeat-0.9.20/toolbox/vl_setup.m

%% Parameters Initialisation (from main.m)

% Birds case
% folderpath = '../CUB_200_2011/CUB_200_2011/images/';
% Whales case
folderpath = '../heads/';

% Tiles number
tiles = [8; 16];
N_tiles = size(tiles, 1);

% Verbose for the following plots:
%   image standardized
%   hog features
%   first svm weights
%   connected component
%   last svm weights on mask

plots = 0;

% Case birds
% load('imgs_data.mat');

% Case whales
load('imgs_whales.mat');

% Inputs
i = 1;
j = 2;
f = 1;
a = 2;
% Number of different parts in part_locs
num_parts = size(part_locs, 1) / size(img_class, 1);

[mask, svm] = poof_fit(i, j, f, a, tiles, folderpath, images_id,...
    img_class, bounding_boxes, part_locs, training, num_parts, plots);

%%
% Plotting the tiling
% im_cell = cell(2,2);
% figure
% for t=1:N_tiles
%     im_6 = img_croped{6,1};
%     im_l = img_croped{size(img_croped, 1) - 1,1};
%     tile = tiles(t);
%     dim_x = 64 / tile;
%     dim_y = 128 / tile;
%     for p=1:(dim_x - 1)
%         im_6(p*tile, :, :) = 0;
%         im_l(p*tile, :, :) = 0;
%     end
%     for p=1:(dim_y - 1)
%         im_6(:, p*tile, :) = 0;
%         im_l(:, p*tile, :) = 0;
%     end
%     im_cell{t, 1} = im_6;
%     im_cell{t, 2} = im_l;
%     subplot(N_tiles, 2, 1 + 2*(t-1))
%     imshow(uint8(im_cell{t, 1}));
%     subplot(N_tiles, 2, 2 + 2*(t-1))
%     imshow(uint8(im_cell{t, 2}));
% end