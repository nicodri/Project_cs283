function [Im_sample] = sampleNegative(Im, pos_bounding_box)
%SAMPLENEGATIVE returns an sample of the Image that is not equal to the
%bounding box but the same size

width = size(Im, 1);
height = size(Im, 2);
bb_w = pos_bounding_box(3) - pos_bounding_box(1);
bb_h = pos_bounding_box(4) - pos_bounding_box(2);

assert(width > bb_w || height > bb_h);

done = false;
cnt = 0;
maxcnt = 100; % restrict count!
while ~done && cnt < maxcnt
    
    xmin = randi(width - bb_w);
    ymin = randi(height - bb_h);
    
    % not equal to bounding box? => take as negative sample!
    % condition will be met almost certainly...
    if xmin ~= pos_bounding_box(1) && ymin ~= pos_bounding_box(3)
        Im_sample = Im(xmin:xmin + bb_w, ymin:ymin + bb_h, :);
        break
    end
    cnt = cnt + 1;
end

% maxcnt reached? return some sample, hope it is ok...
if cnt == maxcnt
    xmin = randi(width - bb_w);
    ymin = randi(height - bb_h);
    Im_sample = Im(xmin:xmin + bb_w, ymin:ymin + bb_h, :);
end

end

