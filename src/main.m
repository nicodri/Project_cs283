% author_name = Nicolas Drizard
% Birds dataset processing
%
%   Main Script to use the POOF approach

% Need vlfeat installed on the local machine
run /Users/nicolasdrizard/vlfeat-0.9.20/toolbox/vl_setup.m

%% Parameters

% Folder path with the CUB 200-2011 data
% Birds case
% folderpath = 'CUB_200_2011/CUB_200_2011/images/';
% Whales case
folderpath = 'heads/';

% Tiles number
tiles = [8; 16];

% Verbose for plots
plots = 1;

% Loading the data
% Expected format inside:
% 'images_id': [global_img_id, img_filename]
%       with file path to each image: strcat(folderpath, img_filename)
% 'img_class': [global_img_id, class]
% 'bounding_boxes': [global_img_id, x, y, w, h]
% 'part_locs': [global_img_id, part_id, x, y, visible (boolean)]
% 'training': [global_img_id, training (boolean)]

% Case birds
% load('imgs_data.mat');

% Case whales
load('imgs_whales.mat');

%% Fit the Poof on train data

% First test on 3 classes and 3 pixel location
% Classes
classes = [1 2];
n_classes = size(classes, 2);
i_j = nchoosek(classes, 2);
n_combin_classes = size(i_j, 1); 
% Parts
parts = [1 2 3];
n_parts = size(parts, 2);
f_a = vertcat(nchoosek(parts, 2), nchoosek(fliplr(parts), 2));
n_combin_parts = size(f_a, 1);
% Poof
n_poof = n_combin_classes*n_combin_parts;
% Number of different parts in part_locs
num_parts = size(part_locs, 1) / size(img_class, 1);

% To store the Poof models by classes
% Poof_classes: {i, j, Poof_parts_ij}
% Poof_parts_ij: {f, a, mask, svm}

Poof_classes = cell(n_combin_classes, 3);
for k=1:n_combin_classes
    i = i_j(k, 1);
    j = i_j(k, 2);
    Poof_parts = cell(n_combin_parts, 4);
    for m=1:n_combin_parts
        f = f_a(m, 1);
        a = f_a(m, 2);
        [mask, svm] = poof_fit(i, j, f, a, tiles, folderpath, images_id,...
            img_class, bounding_boxes, part_locs, training, num_parts, plots);
        Poof_parts(m, :) = {f, a, mask, svm};
    end
    Poof_classes(k, :) = {i, j, Poof_parts};
end

%% Compute the Poof of new entries

% Retrieving the images indices
% dataset format: (global_id, training, class, visible, poof_features)

% Mask to select the images of the target classes
N_imgs = size(img_class, 1);
img_selected = zeros(N_imgs, 1);
for k=1:n_classes
    c = classes(k);
    img_selected = img_selected | img_class(:,2) == c;
end

ind_selected = find(img_selected);
dataset = zeros(sum(img_selected), 4 + n_poof);
dataset(:, 1:3) = [ind_selected, training(img_selected, 2), img_class(img_selected, 2)];

% To convert global index into local index
gid2lid = zeros(size(img_selected));
gid2lid(img_selected(:,1) == 1, 1) = 1:size(ind_selected);

% Retrieving the images and parts information
[img, img_part] = retrieve_imgs(images_id, part_locs, bounding_boxes,...
    ind_selected, folderpath, num_parts);


% Building the features for the entries and storing them in dataset
% dataset: (global_id, training, class, # visible, PooF features)
% visible: (global_id, binary column for each part)
visible = zeros(sum(img_selected), 1 + n_parts);
visible(:, 1) = dataset(:, 1);

for k=1:n_combin_classes
    [i, j, Poof_parts] = Poof_classes{k, :};
    for m=1:n_combin_parts
        % Column indices in the dataset array to score the current poof
        poof_i = (k - 1)*n_combin_parts + m;
        [f, a, mask, svm] = Poof_parts{m, :};
        
        % %%%% Croping the images if f AND a visible
        
        % Local indices = local indices where f AND a visible
        [parts_f, parts_a, local_indices] = retrieve_parts(img_part, f, a, gid2lid);
        img_croped = standardize_imgs(img, parts_f, parts_a, local_indices);
        % Increasing the counter of visible features in the visible column
        % of dataset
        dataset(local_indices, 4) = dataset(local_indices, 4) + 1;
        % May be called several times on the same image
        visible(local_indices, 1 + find(parts==f)) = 1;
        visible(local_indices, 1 + find(parts==a)) = 1;
        
        % %%%% Extracting the hog features for the masked image (where
        % %%%% parts are visible) for each tile
        
        hog_tile  = retrieve_hog_features(tiles, img_croped, plots);
        
        % %%% Computing the poof score only for the visible parts
        
        poof_features = get_poof_features(hog_tile, mask, tiles);
        % Need to check that an svm is present (ie that at least one
        % element is present in mask).
        % An error will occured if svm=0
        try
            dataset(local_indices, 4 + poof_i) = svm.Bias + poof_features*svm.Beta;
        end
    end
end

%% Building the final classifier on the Poof features (SVM)

% Building n_classes one-vs-all SVM on the poof features from dataset
% Results stored in 
% classification : [global_id, training, class, # visible, predicted class, SVM)
% SVM column stores classifier response in the order of classes array

classification = zeros(sum(img_selected), 5 + n_classes);
classification(:, 1:4) = dataset(:, 1:4);
% TO DO: handling missing value case
% Selection of images with all parts visible only
img_to_classify = (classification(:, 4) == n_poof);
img_to_classify_train = (img_to_classify & classification(:, 2) == 1);
img_to_classify_test = (img_to_classify & classification(:, 2) == 0);

% One-vs-All classifiers for entry with all parts visible
for k=1:n_classes
    c = classes(k);
    % Classification for class c on training data
    outputs = (classification(img_to_classify_train, 3) == c);
    svm = fitcsvm(dataset(img_to_classify_train, 5:end),...
        outputs, 'KernelFunction', 'linear');
    % Filling the array starting at cell 6 (5 is kept for the prediction
    classification(img_to_classify,5+k) = svm.Bias + ...
        dataset(img_to_classify, 5:end)*svm.Beta;
end

%% Classifier where one part not visible

% To store the total classified entries
img_classified = img_to_classify;
img_classified_train = img_to_classify_train;
img_classified_test = img_to_classify_test;

% One-vs-All classifiers for entry with one part not visible
ps = 1:n_parts;
for p=1:n_parts
    % Entry where curr_part only not visible
    others = setdiff(ps,p);
    img_to_classify_curr = visible(:,1+p) == 0 & sum(visible(:, 1 + others) == 1, 2) == n_parts - 1;
    img_to_classify_curr_train = img_to_classify_curr & classification(:, 2) == 1;
    img_to_classify_curr_test = img_to_classify_curr & classification(:, 2) == 0;
    % Update the total values
    img_classified = img_classified | img_to_classify_curr;
    img_classified_train = img_classified_train | img_to_classify_curr_train;
    img_classified_test = img_classified_test | img_to_classify_curr_test;
    % Still including the training set with all parts to have more data
    img_to_classify_curr_train_tot = img_to_classify_train | img_to_classify_curr_train;
    for k=1:n_classes
        c = classes(k);
        outputs = (classification(img_to_classify_curr_train_tot, 3) == c);
        svm = fitcsvm(dataset(img_to_classify_curr_train_tot, 5:end),...
            outputs, 'KernelFunction', 'linear');
        % Filling the array starting at cell 6 (5 is kept for the prediction
        classification(img_to_classify_curr,5+k) = svm.Bias + ...
            dataset(img_to_classify_curr, 5:end)*svm.Beta;
    end
end

%% Printing result

% Computing the predicted class, as highest classifier's score
[sortedValues, sortedIndexes] = sort(classification(img_classified, 6:end), 2, 'descend');
classification(img_classified, 5) = classes(sortedIndexes(:, 1));

% Display results about the classification
n_classified = sum(img_classified);
n_train = sum(img_classified_train);
n_test = sum(img_classified_test);
accuracy_train = sum(classification(img_classified_train, 3) == classification(img_classified_train, 5)) / n_train;
accuracy_test= sum(classification(img_classified_test, 3) == classification(img_classified_test, 5)) / n_test;

fprintf(['Classes are : ',mat2str(classes),' . Parts are: ',mat2str(parts), ' \n']);
fprintf('Num total of images: %d . Num total of images classified: %d \n', size(dataset, 1), n_classified);
fprintf('Training one-vs-all SVM for %d classes with %d parts on %d train images for %d test images \n', n_classes, n_parts, n_train, n_test);
fprintf('Accuracy on train is: %d \n', accuracy_train);
fprintf('Accuracy on test is: %d \n', accuracy_test);


%% Baseline computation


