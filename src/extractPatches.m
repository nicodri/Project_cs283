% script to extract patches out of annotated images
function extractPatches(csvfile, patches_path, images_path, isnose, base_number)

coords = [];
filenames = {};
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
        
        coords = [coords; [M{1}, M{2}, M{3}, M{4}]];
        file = M{7};
        filenames{n} = file{1};
        n = n+1;
    end
end
fclose(fid);

% go through files and save the patches into the cache folder...
im_range = length(filenames);
for i=1:im_range
    file = filenames{i};
    disp(['processing ', file,  ' (', num2str(i), '/', num2str(im_range),') ...'])
    
    Im = imread(strcat(images_path, filesep, file));
    
    % retrieve range as x:x+w, y:y+w
    % alter 0 based coords by +1 for matlab coords
    xrange = coords(i, 1)+1:coords(i, 1) + coords(i, 3)+1;
    yrange = coords(i, 2)+1:coords(i, 2) + coords(i, 4)+1;
    
    % output patch
    Impatch = Im(yrange,xrange,:);
    assert(i + base_number < 1000);
    
    if isnose
        imwrite(Impatch, strcat(patches_path, filesep, 'nose_',sprintf('%04d', i + base_number), '.png'));
    else
        imwrite(Impatch, strcat(patches_path, filesep, 'nonose_',sprintf('%04d', i + base_number), '.png'));
    end
end
end