% plot the given image and the detection on it along with scores


data = trainData;

% set here how many topX should be displayed
topX = 5;

% this is the worst according to the given model
sample_image_index = 402;
sample_image_index = 100;
figure
set(gcf, 'Color', 'w')

Im = im2single(imread(strcat(image_path, filesep, data.trainImages{sample_image_index})));
imshow(Im);
alpha 1
hold on

% compute scores and plot them on top
hog = vl_hog(Im, hogCellSize);
scores = vl_nnconv(hog, w, []);
imagesc([.5 *size(w, 1) * hogCellSize, size(Im, 2)- .5 *size(w, 1) * hogCellSize] -.5,...
    [.5 *size(w, 1) * hogCellSize, size(Im, 1)- .5 *size(w, 1) * hogCellSize]-.5, scores);
imshow(Im);
alpha 0.35

% plot on top the detection
detected_bb = detect(Im, w, hogCellSize);
hold on
plotBBox(detected_bb, 'r')
vl_plotbox(double(data.trainBoxes(:, sample_image_index))-0.5, 'g')

% [~, bestIndex] = sort(scores(:), 'descend');
% bestIndex = bestIndex(1:topX); % top X entries!
% [hy, hx] = ind2sub(size(scores), bestIndex);
% x = (hx - 1) * hogCellSize + 1;
% y = (hy - 1) * hogCellSize + 1;
% scatter(x, y, 'rx');
% 
% % plot box for second largest entry
% bb = [x(2), y(2), x(2) + hogCellSize * size(w, 1), y(2) + hogCellSize * size(w, 2)]';
% plotBBox(bb, 'k');
% 
% colorbar
axis on