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
    img_croped = standardize_imgs(img, parts_f, parts_a, local_indices, plots);
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
    
    % Color histogram
%     color_tile = cell(N_tiles,1);
%     for t=1:N_tiles
%         tile = tiles(t);
%         for k=1:size(img_croped, 1)
%             im = img_croped{k,1};
%             im_r = reshape(im, [numel(im) 1]);
%             
%         end
%     end

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
    % Store the mask to plot
    mask_plot = cell(N_tiles, 1);
    for t=1:N_tiles
        tile = tiles(t,1);
        % Dimension of the grid cell for the current tile
        dim_x = 64 / tile;
        dim_y = 128 / tile;
        svm = svm_tile{t,1};
        beta = svm.Beta;
        % Keep the max weight for each cell
        mask = max(reshape(beta, [dim_x, dim_y, 31]), [], 3);
        mask_plot{t, 1} = mask;
        % Median thresholding
        med = median(reshape(mask, [numel(mask) 1]));
        mask(mask < med) = 0;
        svm_thresh{t,1} = mask;
    end
    
    % Sanity check of weights
    if plots
        figure;
        for t=1:N_tiles
            m = mask_plot{t, 1};
            m = (m - min(min(m)))./(max(max(m)) - min(min(m)));
            subplot(N_tiles, 1, t);
            colormap('hot')
            imagesc(m)
            colorbar
            hold on;
        end
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
        % We look for the 4-connected neighborhood
        cc = bwconncomp(mask, 4);
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

    % Sanity check of connected components
    if plots
        figure;
        for t=1:N_tiles
            mask = svm_mask{t, 1};
            tile = tiles(t);
            % Need to find the corresponding mask on the image pixels
            mask2img = [];
            dim_x = 64 / tile;
            dim_y = 128 / tile;
            for j=1:size(mask,1)
                m = mask(j);
                q = floor((m - 1)/dim_x);
                r = mod(m-1, dim_x);
                % upper left element of the current box of mask
                a = tile*r + 64*tile*q;
                % Loop over all the pixels of the boxes
                for w=1:tile
                    for z=1:tile
                        mask2img = [mask2img; a + z + (w-1)*64];
                    end
                end
            end
            im_i = img_croped{6,1};
            show_i = zeros(size(im_i, 1), size(im_i, 2), 3);
            im_j = img_croped{size(img_croped, 1) - 1,1};
            show_j = zeros(size(im_j, 1), size(im_j, 2), 3);
            [I, J] = ind2sub([size(im_i, 1), size(im_i, 2)], sort(mask2img));
            % Changing the cells value
            for s=1:size(I, 1)
                show_i(I(s), J(s), :) = im_i(I(s), J(s), :);
                show_j(I(s), J(s), :) = im_j(I(s), J(s), :);
            end
            % Image i
            subplot(N_tiles, 2, 1 + (t-1)*2);
            imshow(uint8(show_i));
            hold on;
            % Image j
            subplot(N_tiles, 2, 2 + (t-1)*2);
            imshow(uint8(show_j));
            hold on;
        end
    end
 
    % %% Step 6: Building the SVM which computes the Poof score

    % Features to learn the SVM
    poof_features = get_poof_features(hog_tile, svm_mask, tiles);
    
    % Run a svm on the features
    if size(poof_features) > 0
        poof_svm = fitcsvm(poof_features, outputs, 'KernelFunction', 'linear');
        % Sanity check of the feature weights
        if plots
            figure;
            % counter to start the number of features
            start_cursor = 1;
            beta = poof_svm.Beta;
            for t=1:N_tiles
                mask = svm_mask{t, 1};
                tile = tiles(t);
                % Dimension of the grid cell for the current tile
                dim_x = 64 / tile;
                dim_y = 128 / tile;
                % Compute the number of features of the current tile
                end_cursor = size(mask,1)*31;
                beta_curr = beta(start_cursor:end_cursor);
                % Defining the weighted mask (we keep the max weight for each
                % cell)
                weighted_mask = zeros(dim_x, dim_y);
                % Number of pixel in the current mask
                number_pixels = size(beta_curr,1)/31;
                weighted_mask(mask) = max(reshape(beta_curr, [number_pixels, 31]), [], 2);
                % Scaling the weights
                weighted_mask = (weighted_mask - min(min(weighted_mask)))./(max(max(weighted_mask)) - min(min(weighted_mask)));
                subplot(N_tiles, 1, t);
                colormap('hot')
                imagesc(weighted_mask)
                colorbar
                hold on;
            end
        end
    else
        poof_svm = 0;
    end
end
