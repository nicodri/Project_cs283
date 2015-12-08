function [bb] = detect(Im, w, hogCellSize)
%DETECT given an Image and a kernel (w) this function returns the best
% bounding box

% convert to single for vlfeat
Im = im2single(Im);

% compute history of gradients
hog = vl_hog(Im, hogCellSize);
scores = vl_nnconv(hog, single(w), []);

% extract index of highest score
[~, bestIndex] = max(scores(:));
[hy, hx] = ind2sub(size(scores), bestIndex);
x = (hx - 1) * hogCellSize + 1;
y = (hy - 1) * hogCellSize + 1;
modelWidth = size(w, 2);
modelHeight = size(w, 1);

% return bb with 0.5 offset for matlab
bb = [x;y;x + hogCellSize * modelWidth;y + hogCellSize * modelHeight] - 0.5;

% make sure, box lies withhin image boundaries!
if bb(1) < 0.5 || bb(2) < 0.5 || bb(3) > size(Im, 2) - 0.5 || bb(4) > size(Im, 1) - 0.5
    % correct bounding box, to make up for arbitrary images
    x = x - (bb(3) - size(Im, 2) + 0.5) * (bb(3) > size(Im, 2) - 0.5);
    y = y - (bb(4) - size(Im, 1) + 0.5) * (bb(4) > size(Im, 1) - 0.5);
    bb = [x;y;x + hogCellSize * modelWidth;y + hogCellSize * modelHeight] - 0.5;
end

end

