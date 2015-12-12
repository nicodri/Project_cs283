% (c) 2015 by L.Spiegelberg
% this script scales down data to alower (25%) resolution

images_path = strcat('..', filesep, 'cache', filesep, 'images501_1000');
cache_path = strcat('..', filesep, 'cache');
filenames = getFilenames(images_path);

addpath('lib')

%define test range
im_range = length(filenames);

% all images are the same size (1848x2773 pixels)
im_sizes = [];
for i=1:im_range
    file = filenames{i};
    
    disp(['processing ', file,  ' (', num2str(i), '/', num2str(im_range),') ...'])
    
    Im = imread(strcat(images_path, filesep, file));
    
    % resize to 1/4 of original size
    %Im = imresize(Im, 0.25);
    
    % there are some larger images, use this
    % make sure aspect ratio is always the same
    Im = imresize(Im, [462, 694]); 
    
    % normalize Image's contrast
    %Im = ContrastStretchNorm(im2double(Im));
    Im = normalizeImage(im2double(Im));
    
    % write image to cache
    imwrite(Im, strcat(cache_path, filesep, 'lq501_1000', filesep, getFilename(file), '_lq.jpg')); 
    
    im_sizes = [im_sizes;size(Im)];
    
%     % extract 3rd channel in lab mode
%     Im = im2double(Im);
%     lab = rgb2lab(Im);
%     cmap = gray(256);
%     imwrite(normalizeImage(lab(:, :, 3)), strcat(cache_path, filesep, 'lq', filesep, getFilename(file), '_lq_lab3.jpg')); 
% 
%     ntsc = rgb2ntsc(Im);
%     imwrite(normalizeImage(lab(:, :, 2)),strcat(cache_path, filesep, 'lq', filesep, getFilename(file), '_lq_ntsc2.jpg')); 
%     %imshow(Im)
end

