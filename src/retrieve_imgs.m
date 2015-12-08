% author_name = Nicolas Drizard
%
%   Helper functions for the POOF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ROUTINES for step 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Script to retrieve img from the folder filefolder

% We retrieve the images with global id from ind_selected, restrict them
% to their bounded boxe, translate the parts location to their new location
% in the bounded box and store them with the local id corresponding to its
% local index in the ind_selected.

% images_id: global array with all the images_id at their global index
% part_locs: global array with the local parts information
% bounding_boxes: global array with the bounding boxes location

function [img, img_part] = retrieve_imgs(images_id, part_locs,...
    bounding_boxes, ind_selected, filefolder, num_parts)
    % To store in a cell each image and parts
    N = size(ind_selected, 1);
    img = cell(N,1);
    img_part = zeros(15*N, 5);

    for i=1:N
        idx = ind_selected(i,1);
        filename = strcat(filefolder, images_id{idx, 2});
        im = imread(filename);
        % Restricting to the bouding box
        dim = bounding_boxes(idx,2:end);
        % WARNING: Reversing the axes and matlab indices
        % dim(i,1) is y + 1 and dim(i, 2) is x + 1 (need the -1 because of
        % too large width and height)
        img{i,1} = im(dim(1,2) + 1:dim(1,2)+dim(1,4) - 1, dim(1,1) + 1:dim(1,1)+dim(1,3) - 1,:);
        % Storing the parts locations 
        for k=1:num_parts
            parts = part_locs(num_parts*(idx-1)+k,:);
            if parts(1,5) == 1
                parts(1,3) = parts(1,3) - dim(1,1);
                parts(1,4) = parts(1,4) - dim(1,2);
            end
            img_part(num_parts*(i-1)+k,:) = parts;
        end
    end
end