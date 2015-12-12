% author_name = Nicolas Drizard
%
%   Helper functions for the POOF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ROUTINES for step 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We need to transform each image to have the two part based features f and
% a at the same position. We fit a similarity transformation to each
% training images.
%
% Reference position: f and a aligned in the middle
%           128 pix
%    -----------------------
% 6 |                       |
% 4 |                       |
% p |     f  64 pix   a     |
% i |                       |
% x |                       |
%    -----------------------
%
% arg plots: boolean for sanity check plots

function img_croped = standardize_imgs(img, parts_f, parts_a, local_indices, plots)    
    fixedPoints = [32, 32; 96, 32];
    N = size(local_indices,1);
    img_croped = cell(N,1);
    for i=1:N
        % lid is the local index (because the cell arrays contain also the
        % img where parts are not visible)
        lid = local_indices(i,1);
        im = img{lid,1};
        % movingPoints format: [f_x f_y; a_x a_y]
        movingPoints = [parts_f(lid,2:3); parts_a(lid,2:3)];

        % Apply axial vertical symmetrie if needed (to avoid rotation)
        if movingPoints(1,1) > movingPoints(2,1)
            % Change the position of the parts
            movingPoints(:, 1) = size(im,2) - movingPoints(:, 1);
            ref_im = zeros(size(im), 'like', im);
            for k=1:size(im,2)
                ref_im(:,k, :) = im(:, size(im,2) - k + 1, :);
            end
            im = ref_im;
        end

        % Fitting the similarity
        tform = fitgeotrans(movingPoints,fixedPoints,'NonreflectiveSimilarity');

        % New image
        img_croped{i,1} = imwarp(im,tform,'OutputView',imref2d([64, 128]));
    end
     % Sanity check
    if plots
        % Sanity plot
        num_plot_line = 6;
        fixedPoints = [32, 32; 96, 32];

        figure
        % In case not enough picture
        n_fig = min((num_plot_line^2), size(img_croped, 1));
        for k=1:n_fig
            subplot(num_plot_line, num_plot_line, k)
            test_im = img_croped{k,1};
            imshow(test_im); hold on;
            plot(fixedPoints(:,1),fixedPoints(:,2),'r.','MarkerSize',20);
            hold on;
        end
    end
end