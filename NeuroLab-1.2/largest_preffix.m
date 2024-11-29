function lpf = largest_preffix(cell_array)

% finding longest common prefix
count = 0;
lpf = [];
while true
    count = count+1;
    temp = [];
    for i = 1:length(cell_array)
        str = char(cell_array{i});
        if count > length(str)
            return;
        end
        temp = [temp;{str(1:count)}];
    end
    if length(unique(temp))==1
        lpf = char(unique(temp));
    end
end

end