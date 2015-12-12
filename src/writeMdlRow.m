function writeMdlRow(fid, desc, M)
%WRITEMDLROW output model statistics
fprintf(fid, ['"', desc, '"'])

for i=1:length(M)
    fprintf(fid, [',', num2str(M(i, 2))]);
end
fprintf(fid, '\n');
end

