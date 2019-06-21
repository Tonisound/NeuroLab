function pattern = largest_prefix(C)
pattern = char(C(1,1));
%while length(pattern)>1 && length(cell2mat(regexp(C,pattern)))<length(C)
%    pattern = pattern(1:end-1);
%end
cur=1;
while length(pattern)>1 && cur<length(C)
    if isempty(strfind(char(C(cur,1)),pattern))
        pattern = pattern(1:end-1);
    else
        cur = cur+1;
    end
end
end