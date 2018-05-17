function buttonScale_Callback(hObj,~,ax)

global START_IM END_IM;

lines = findobj(ax,'Tag','Trace_Cerep');
others = findobj(ax,'Tag','Trace_Region','-or','Tag','Trace_Pixel','-or','Tag','Trace_Box','-or','Tag','Trace_Mean');
visible = findobj(ax,'Visible','on');
others = visible(ismember(visible,others));

m = 0;
M = 0;
if isempty(others)
    for k=1:length(lines)
        m = min(m,min(lines(k).YData(START_IM:END_IM)));
        M = max(M,max(lines(k).YData(START_IM:END_IM)));
    end
else
    for k=1:length(others)
        m = min(m,min(others(k).YData(START_IM:END_IM)));
        M = max(M,max(others(k).YData(START_IM:END_IM)));
    end
end

switch hObj.Value
    case 0,
        for i=1:length(lines)
            scale = lines(i).UserData.scale;
            %offset = lines(i).UserData.offset;
            lines(i).YData = (lines(i).YData)/scale;
            lines(i).UserData.scale = 1;
            %lines(i).UserData.offset = 1;
        end
    case 1,
        for i=1:length(lines)
            %min_l = min(lines(i).YData(START_IM:END_IM));
            max_l = max(lines(i).YData(START_IM:END_IM));
            scale = M/max_l;
            %offset = scale*(max_l+min_l)/2 - (m+M)/2;
            lines(i).YData = lines(i).YData*scale;
            lines(i).UserData.scale = scale;
            %lines(i).UserData.offset = offset;
        end
end

end