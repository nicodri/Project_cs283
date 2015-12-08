% author_name = Nicolas Drizard
%
%   Helper functions for the POOF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ROUTINES for step 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Retrieve the parts for pixel point f and a from img_part with the local
% indexes in those array where both are visible as local_indices
function [parts_f, parts_a, local_indices] = retrieve_parts(img_part, f, a, gid2lid)
    visible_f = (img_part(:,2) == f & img_part(:,5) == 1);
    visible_a = (img_part(:,2) == a & img_part(:,5) == 1);
    % Global indices (indices in the global parts array) of the image where
    % the part is visible
    gids_f = img_part(visible_f, 1);
    gids_a = img_part(visible_a, 1);
    gids = intersect(gids_f, gids_a);
    % Store the local indices of image with visible parts
    local_indices = gid2lid(gids,1);
    % Store all the aprts, need to use local_indices for those visible
    parts_f = img_part(img_part(:,2) == f , [1, 3, 4]);
    parts_a = img_part(img_part(:,2) == a, [1, 3, 4]);

end