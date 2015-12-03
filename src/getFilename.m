function [fname] = getFilename(filename)
%GETFILENAME returns filename without ext

[~, fname ,~] = fileparts(filename);

end

