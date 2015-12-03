function [filenames] = getFilenames(path)
%GETFILENAMES returns a cell array of all filenames in the specified
%directory

files = dir(path);

pos = 1;
filenames = {};
for i=1:length(files)
    if length(files(i).name) > 2
        filenames{pos} = files(i).name;
        pos = pos + 1;
    end
end

end

