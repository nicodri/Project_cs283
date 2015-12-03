% return for given file the number of lines in it
function n = lineCount(filename)

fid = fopen(filename);
n = 0;
tline = fgetl(fid);
while ischar(tline)
  tline = fgetl(fid);
  n = n+1;
end
fclose(fid);
end