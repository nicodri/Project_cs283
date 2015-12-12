function [Imout] = normalizeImage(Imin)
%NORMALIZEIMAGE for a given image, maps values to range [0, 1]

IM = Imin;

% gamma correction
% get luminance using ITU-R BT.709 primaries
Y = 0.2126 * IM(:, :, 1) + 0.7152 * IM(:, :, 2) + 0.0722 * IM(:, :, 3);

invgamma = log(0.5) / log(mean(Y(:)));

IM = IM .^ invgamma;

% contrast normalization
for i=1:3
    imin = min(min(IM(:, :, i)));
    imax = max(max(IM(:, :, i)));
    IM(:, :, i) = IM(:, :, i) -  imin * ones([size(IM, 1), size(IM, 2)]);
    IM(:, :, i) = IM(:, :, i) / imax;
end
Imout = IM;

end

