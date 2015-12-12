function distanceHist(w, csvfile, image_path)
%DISTANCEHIST plots a distance histogram of the correct boxes vs. the
%incorrect ones

% step 1: load training data
[trainImages, trainBoxes, trainBoxImages, trainBoxPatches] = ...
    loadTrainData(csvfile, image_path);

% for each image detect the box


end

