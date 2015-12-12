% this script visualizes for a sample whale what the hog is

% this is the worst according to the given model
sample_image_index = 402;
sample_image_index = 110;
figure
set(gcf, 'Color', 'w')

Im = im2single(imread(strcat(image_path, filesep, data.trainImages{sample_image_index})));


% compute scores and plot them on top
hogCellSize = 8;
hog = vl_hog(Im, hogCellSize);
figure
set(gcf, 'Color', 'w')
imhog = vl_hog('render', hog, 'verbose');
imagesc(imhog);
colormap gray;