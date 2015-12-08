function plotBBox(bb, varargin)
%PLOTBBOX plot box using diagonal
hold on
% plot([x;x+kw], [y;y + kw], varargin{:});
% plot([x;x+kw], [y + kw;y], varargin{:});
plot(bb([1 3]), bb([2 4]), varargin{:});
plot(bb([1 3]), bb([4 2]), varargin{:});
hold on
vl_plotbox(bb, varargin{:})
end

