function [Im_sample] = samplePositive(Im, pos_bounding_box)
%SAMPLENEGATIVE returns an sample of the Image that is not equal to the
%bounding box but the same size

width = size(Im, 1);
height = size(Im, 2);
bb_w = pos_bounding_box(3) - pos_bounding_box(1);
bb_h = pos_bounding_box(4) - pos_bounding_box(2);

assert(width > bb_w || height > bb_h);

hbb_h = int32(floor(double(bb_h) / 2));
hbb_w = int32(floor(double(bb_w) / 2));
[X, Y] = meshgrid(-hbb_w+.5:hbb_w-.5, -hbb_h+.5:hbb_h-.5);

% rotate by random angle
theta = rand * pi;
Xrot = X * cos(theta) - Y * sin(theta);
Yrot = X * sin(theta) + Y * cos(theta);

% transform to location! (first rotation, then translation!)
X = Xrot + pos_bounding_box(1) + hbb_w;
Y = Yrot + pos_bounding_box(2) + hbb_h;

% interpolate new positive sample
Im_sample(:, :, 1) = interp2(double(Im(:, :, 1)), double(X), double(Y));
Im_sample(:, :, 2) = interp2(double(Im(:, :, 2)), double(X), double(Y));
Im_sample(:, :, 3) = interp2(double(Im(:, :, 3)), double(X), double(Y));
Im_sample = im2single(Im_sample);
end

