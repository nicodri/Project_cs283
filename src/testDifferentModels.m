%% Settings:
% add vlfeat path
addpath('./vlfeat/toolbox');
addpath('lib'); % for plotting
setup;

data_path = strcat('..', filesep, 'data', filesep);
images_path = strcat('..', filesep, 'cache', filesep, 'imgs_subset');
cache_path = strcat('..', filesep, 'cache');

% load data
csvfile = strcat(data_path, 'nosepatches.csv');
image_path = strcat(cache_path, filesep, 'lq');
data = loadTrainData(csvfile, image_path);

%% split into test & train data!
[testData, trainData] = splitTestTrain(data, 100);


%% script to test different models

modelDistances = {};
testLabels = {};


hogCellSize = 8;


% write output as CSV to file
fid = fopen('../statistics.txt', 'wb');


%% base model using mean (template matching)
w = trainMeanModel(trainData,...
    strcat(cache_path, filesep, 'lq'), hogCellSize);
M = evalModel(testData, image_path, w, hogCellSize);
modelDistances{end+1} = M(:, 2);
testLabels{end+1} = 'base model';
writeMdlRow(fid, 'base model', M);

%% SVM model
w = trainSVMModel(trainData,...
   strcat(cache_path, filesep, 'lq'), hogCellSize, 10, 0.001);
M = evalModel(testData, image_path, w, hogCellSize);
modelDistances{end+1} = M(:, 2);
testLabels{end+1} = 'SVM model';
writeMdlRow(fid, 'SVM model', M);

%% SVM model negative hard mining
wall = trainSVMModelHardNegative(trainData,...
   strcat(cache_path, filesep, 'lq'), hogCellSize, 10, 0.001, 10);
w = wall{end};
M = evalModel(testData, image_path, w, hogCellSize);
modelDistances{end+1} = M(:, 2);
testLabels{end+1} = 'SVM hard mined model';
writeMdlRow(fid, 'SVM hard mined model 10', M);

%% plot histograms of distances
figure
set(gcf, 'Color', 'w');
nhist(modelDistances(1:3));
ylabel('relative frequency');

%%
fclose(fid)

%%
%% SVM model
fid = fopen('../statistics_num_samples.txt', 'wb');
for num_samples=1:20
    disp(['processing ', num2str(num_samples)]);
    w = trainSVMModel(trainData,...
       strcat(cache_path, filesep, 'lq'), hogCellSize, 10, 0.001, num_samples);
    M = evalModel(testData, image_path, w, hogCellSize);
    writeMdlRow(fid, [num2str(num_samples), 'x SVM mode l'], M);
end