function [trainImages, trainBoxes, trainBoxImages, trainBoxPatches] = loadTrainData(csvfile, images_path)
%LOADTRAINDATA 
% trainImages: a list of train image names.
% trainBoxes: a 4×N array of object bounding boxes, in the form [xmin,ymin,xmax,ymax].
% trainBoxImages: for each bounding box, the name of the image containing it.
% trainBoxPatches: a 64×64×3×N array of image patches, one for each training object. Patches are in RGB format.

trainImages = {};
trainBoxes = [];
trainBoxPatches = [];

% custom scanner for file
fid = fopen(csvfile);
n = 1;
tline = fgetl(fid);
while ischar(tline)
    tline = fgetl(fid);
    if length(tline) > 2
        % extract via textscan data
        % format is : x,y,w,h,imw,imh,filename,absolutepath
        M = textscan(tline, '%d,%d,%d,%d,%d,%d,%[^,],%s');
        
        % convert [x, y, w, h] to [xmin. ymin, xmax, ymax]
        % and add +1 to convert between 0adressed and 1adressed
        % coords
        coords = int32([M{1}, M{2}, M{1} + M{3}, M{2} + M{4}] + 1);
        file = M{7};
        file = file{1};
        
        % store in arrays info
        trainImages{n} = file;
        trainBoxes = [trainBoxes; coords];
        trainBoxImages{n} = file;
        
        % load image and store patch of it
        Im = im2single(imread(strcat(images_path, filesep, file)));
        trainBoxPatches(:, :, :, n) = Im(coords(2):coords(4), coords(1):coords(3), :);
        
        n = n+1;
    end
end
fclose(fid);

% adjustments
trainBoxes = trainBoxes';
trainBoxPatches = single(trainBoxPatches);

end

