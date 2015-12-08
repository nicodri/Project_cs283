% author_name = Nicolas Drizard
%
%   Helper functions for the POOF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ROUTINES for step 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return a cell array with for each tile the hog features from the images
% in img_croped
% boolean plots set to 1 for sanity plot
function hog_tile  = retrieve_hog_features(tiles, img_croped, plots)
    N_tiles = size(tiles,1);
    N_imgs = size(img_croped,1);
    hog_tile = cell(N_tiles, 1);
        
    for t=1:N_tiles
        tile = tiles(t,1);
        % Matlab implementation
    %     u = floor(([64 128]./tile - [2 2])./([2 2] - [1 1]) + 1);
    %     N = prod([u, [2 2], 9]);
        % Vl feat implementation
        % Compute the number of features
        im_test = img_croped{1, 1};
        N_features = 31 * numel(im_test(:,:,1)) / (tile^2);
        X_tile = zeros(N_imgs, N_features);
        for id=1:N_imgs
            im = img_croped{id, 1};
            % Matlab implementation
    %         [f, hogVisualization] = extractHOGFeatures(im,'CellSize',tile, 'BlockOverlap', [0 0]);
            % Vl feat implemenation
            hog = vl_hog(single(im), tile) ;
            X_tile(id,:) = reshape(hog,[1 numel(hog)]);
        end  
        hog_tile{t,1} = X_tile;
    end
    
    % Sanity check
    if plots
        % Sanity plot
        num_plot_line = 6;
        fixedPoints = [32, 32; 96, 32];

        figure
        title('class i')
        % In case not enough picture from current class i
        n_fig_i = min((num_plot_line^2), size(img_croped, 1));
        for k=1:n_fig_i
            subplot(num_plot_line, num_plot_line, k)
            test_im = img_croped{k,1};
            imshow(test_im); hold on;
            plot(fixedPoints(:,1),fixedPoints(:,2),'r.','MarkerSize',20);
            hold on;
        end
    end
end