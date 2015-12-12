% author_name = Nicolas Drizard
% Whales dataset processing
%
%   Script to select location parts pixel for the Poof algorithm

% Ref repository
filefolder = 'heads/';
delimiterIn = ' ';
headerlinesIn = 0;

% Loading the data
load('imgs_whales.mat');

% Pixel selection
N_tot = size(images_id, 1);

% Loading the already filled file
filename = 'whales/part_locs.txt';
% img_part = importdata(filename,delimiterIn,headerlinesIn);


% Format should be (img_id, part_id, x, y, visible)
%img_part = zeros(6*N, 5);

% Reaching 4 classes
for i=77:107
    filename = strcat(filefolder, images_id{i, 2});
    im = imread(filename);
    imshow(im);
    [X, Y] = getpts;
    % In case missing pixel
    % part number
    for p=1:6
        % Case not visible
        if (X(p, 1) < 5) & (Y(p, 1) < 5)
            val = [i, p, 0, 0, 0];
        else
            val = [i, p, X(p, 1), Y(p, 1), 1];
        end
        % Case visible
        img_part((i-1)*6 + p, :) = val;
    end
end

% Saving array
dlmwrite('whales/part_locs.txt', img_part, delimiterIn);
