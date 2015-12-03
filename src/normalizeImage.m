function [Imout] = normalizeImage(Imin)
%NORMALIZEIMAGE for a given image, maps values to range [0, 1]

IM = Imin;
IM = IM - min(IM(:));
IM = IM / max(IM(:));
Imout = IM;

end

