% author_name = Nicolas Drizard
% Birds dataset processing
%
%   Helper functions to read the data from CUB 200-2011

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ROUTINE to extract class imgs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Building a working set for two given classes
%
%   objective:
%       images of 2 different classes restricted to their bounding boxes
%       with part locations in common

function [img_i, img_i_part,img_i_id, stepi, ] = get_imgs_classes(i, j, filename, folderpath)
    % Loading the images
    [img_i, img_i_part, img_i_id, stepi] = retrieve_class_imgs(classi, ...
        img_class, images_id, part_locs, bounding_boxes, rep);
    [img_j, img_j_part, img_j_id, stepj] = retrieve_class_imgs(classj, ...
        img_class, images_id, part_locs, bounding_boxes, rep);

    % Checking result
    row = 40;
    im = img_j{row,1};
    id = img_j_id(row,1);
    index = (img_j_part(:,1) == id & img_j_part(:,5) == 1);
    parts = img_j_part(index,:);

    imshow(im); hold on;
    plot(parts(:,3),parts(:,4),'r.','MarkerSize',20)

end
