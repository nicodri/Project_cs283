function [M] = evalModel(data, image_path, w, hogCellSize)
%EVALMODEL given a model w and a testfile (through a csv file)
%   this function returns detailed statistics
% i.e. first column is whether classifier matched box
% next column is distance between boxes (L2 norm)

M = zeros([size(data.trainImages, 1), 2]);
% go over all files and detect whale in it
for i = 1:size(data.trainImages, 2)
  
   % load image
   Im = im2single(imread(strcat(image_path, filesep, data.trainImages{i})));
   
   % detect box
   bb = double(detect(Im, w, hogCellSize));
   bb_r = double(data.trainBoxes(:, i));
   % check if box is the same
   M(i, 1) = isequal(bb, bb_r);
   M(i, 2) = norm(bb_r([1 2]) - bb([1 2]) , 2);
end

end

