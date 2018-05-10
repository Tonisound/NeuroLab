function pos = get_stackposition(lines,ax)
% Returns a vector of position stacking order 

if isempty(lines)
    pos = [];
else
    pos = NaN(size(lines));
    l_stack = findobj(ax,'Type','line','-not','Tag','Cursor');
    l_stack_name = [];
    for i=1:length(l_stack)
        l_stack_name =[l_stack_name;{l_stack(i).UserData.Name}];
    end
    
    indexes = 1:length(l_stack_name);
    for i=1:length(lines)
        ind = strcmp(l_stack_name,lines(i).UserData.Name);
        temp = indexes(ind);
        pos(i) = temp(1);
    end
end

end