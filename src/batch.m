% this script does all the processing required

data_path = strcat('..', filesep, 'data', filesep);
images_path = strcat('..', filesep, 'cache', filesep, 'imgs_subset');
cache_path = strcat('..', filesep, 'cache');

% load csv file
csvfile_noses = strcat(data_path, 'nosepatches.csv');
csvfile_nonoses = strcat(data_path, 'nosepatches.csv');

% call extract patches function
patches_path = strcat('..', filesep, 'cache', filesep, 'patches');
images_path = strcat('..', filesep, 'cache', filesep, 'lq');
extractPatches(csvfile_noses, patches_path, images_path, true, 0); 
extractPatches(csvfile_nonoses, patches_path, images_path, false, 0);
