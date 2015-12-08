% author_name = Nicolas Drizard
%
%   Helper functions for the POOF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ROUTINES for step 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the concatenation on the mask at each tile of the
% low-level features on the masked img to build the POOF score. 
% Returns 0 if all the masks are empty

function poof_features = get_poof_features(hog_tile, svm_mask, tiles)
    N_tiles = size(tiles, 1);
    % To concatenate the selected feature at each scale
    % Size unknown because depends on all the masks
    poof_features = [];
    for t=1:N_tiles
        tile = tiles(t,1);
        % WARNING: X does not contain class information, only hog feature
        X = hog_tile{t,1};
        % Indices of the cells in the connected component of the current tile
        cc_tile = svm_mask{t,1};
        if size(cc_tile) > 0
            % Compute the index of the cc
            dim_x = 64 / tile;
            dim_y = 128 / tile;
            [I, J] = ind2sub([dim_x dim_y], cc_tile);
            % Indices of the 31 dimension hog features of each cell in cc
            indices = sub2ind([dim_x dim_y 31], repmat(I, [31 1]),...
                repmat(J, [31 1]), repmat((1:31)', [size(I,1) 1]));
            % Extract from X the features of the pixel in the connected component
            poof_features = [poof_features, X(:,indices)];
        end
    end
end