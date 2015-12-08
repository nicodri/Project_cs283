% author_name = Nicolas Drizard
% Birds dataset processing
%
%   Script to implement the POOF approach

% Need vlfeat installed on the local machine
% run /Users/nicolasdrizard/vlfeat-0.9.20/toolbox/vl_setup.m

% Function to compute the model (mask, svm) to extract the Poof score for a
% specific configuration
% The images are loaded in the folder at folderpath.
% TODO: only implemented for the hog low-level feature, need to add a color
% histogram

function [svm_mask, poof_svm] = poof_fit(i, j, f, a, tiles, folderpath,...
    images_id, img_class, bounding_boxes, part_locs, training, num_parts, plots)
    N_tiles = size(tiles, 1);
    
    % %% Step 0: Loading the data
    
    % Logical array of the images from class i and j
    img_selected = (img_class(:,2) == i | img_class(:,2) == j);
    % Restricting to training set
    img_selected = img_selected & training(:,2);
    
    ind_selected = find(img_selected);
    % Format is: (global id, class)
    classes_train = [ind_selected, img_class(img_selected, 2)];

    % To convert global index into local index
    gid2lid = zeros(size(img_selected));
    gid2lid(img_selected(:,1) == 1, 1) = 1:size(ind_selected);

    [img, img_part] = retrieve_imgs(images_id, part_locs, bounding_boxes,...
        ind_selected, folderpath, num_parts);
    
    % %% Step 1: Similarity transform

    % Retrieving the local parts f and
    % local_indices: indices for rows where both f and a visible
    % img_croped: contain only images where both f and a are visible
    [parts_f, parts_a, local_indices] = retrieve_parts(img_part, f, a, gid2lid);
    img_croped = standardize_imgs(img, parts_f, parts_a, local_indices);
    % Binary class for the one-vs-one classifier
    outputs = (classes_train(local_indices, 2) == i);
    
    % %% Step 2: Tiling images

    % HOG features

    % We use the hog feature from vl feat to have 31 dimensions feature for
    % each cell and an easier access to the features corresponding to each cell

    % Data structure:
    %   hog_tile -->  cell of (number of tiles, f_tile)
    %   f_tile --> cell of (number of images, features)
    %   features --> [n_observations, 1 + n_features]
    % n_features = numel([dim_x, dim_y, 31]), +1 to store the class label
    %
    %   plots: Last argument use for sanity plot if True
    hog_tile  = retrieve_hog_features(tiles, img_croped, plots);

    % TO DO: Plot hog features

    % %% Step 3: Train SVM with features being the concatenation of the base features

    % Storing the svm for each tiling
    svm_tile = cell(N_tiles, 1);
    for t=1:N_tiles
        X = hog_tile{t,1};
        svm = fitcsvm(X, outputs, 'KernelFunction', 'linear');
        svm_tile{t,1} = svm;
    end

    % %% Step 4: Assigning a score to each grid cell and thresholding

    % Key points: 
    %   What is the dimension of the HOG features per grid?
    %   Mapping the hog feature with its corresponding cell

    % svm_thresh cell array with the mask of the cells above the threshold
    svm_thresh = cell(N_tiles, 1);
    for t=1:N_tiles
        tile = tiles(t,1);
        % Dimension of the grid cell for the current tile
        dim_x = 64 / tile;
        dim_y = 128 / tile;
        svm = svm_tile{t,1};
        beta = svm.Beta;
        % Keep the max weight for each cell
        mask = max(reshape(beta, [dim_x, dim_y, 31]), [], 3);
        % Median thresholding
        med = median(reshape(mask, [numel(mask) 1]));
        mask(mask < med) = 0;
        svm_thresh{t,1} = mask;
    end

    % %% Step 5: Finding the maximum connected components around f in the mask

    % 1d index of the seeds for each tile
    seed = horzcat(64./(2*tiles) + (128./(4*tiles) - 1).*64./tiles,...
        64./(2*tiles) + (128./(4*tiles)).*64./tiles);
    seed = horzcat(seed, seed +1);
    % Store for each tile the list of the indices of the cell in the connected
    % component selected
    svm_mask = cell(N_tiles, 1);
    for t=1:size(tiles,1)
        mask = svm_thresh{t,1};
        cc = bwconncomp(mask);
        pix = cc.PixelIdxList;
        % Initialisation
        found = 0;
        cc_tile = [];
        % To be sure that the cc is not empy
        num_cc = size(pix,2);
        if num_cc
            % Going over the connected components
            for k=1:num_cc
                pix_current = pix{1,k};
                for m=1:4
                    if ismember(seed(t,m), pix_current)
                        cc_tile = pix_current;
                        found = 1;
                        break
                    end
                end
                if found
                    break
                end
            end
        end
        svm_mask{t,1} = cc_tile;   
    end

    % TO DO: Plot connected components
    
    % %% Step 6: Building the SVM which computes the Poof score

    % Features to learn the SVM
    poof_features = get_poof_features(hog_tile, svm_mask, tiles);
    
    % Run a svm on the features
    if size(poof_features) > 0
        poof_svm = fitcsvm(poof_features, outputs, 'KernelFunction', 'linear');
    else
        poof_svm = 0;
    end
end
