function pattern = largest_suffix(C)
Pattern = char(C(1,1));
pattern = Pattern(end);
while length(pattern)<length(Pattern) && length(cell2mat(regexp(C,pattern)))>=length(C)
    pattern = Pattern(end-length(pattern):end);
end
pattern = pattern(2:end);
end