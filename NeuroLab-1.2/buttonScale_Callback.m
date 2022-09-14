function buttonScale_Callback(hObj,~,ax)

global START_IM END_IM;

lines = findobj(ax,'Tag','Trace_Cerep');
others = findobj(ax,'Tag','Trace_Region','-or','Tag','Trace_RegionGroup','-or','Tag','Trace_Pixel','-or','Tag','Trace_Box','-or','Tag','Trace_Mean');
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


for i=1:length(lines)
    
    if ~isfield(lines(i).UserData,'YDataOriginal')
        lines(i).UserData.YDataOriginal = lines(i).YData;
    end
    
    switch hObj.Value
        
        %         case 0
        %             % No scaling
        %             scale = lines(i).UserData.scale;
        %             %offset = lines(i).UserData.offset;
        %             lines(i).YData = (lines(i).YData)/scale;
        %             lines(i).UserData.scale = 1;
        %             %lines(i).UserData.offset = 1;
        %
        %         case 1
        %             % Scaling
        %             %min_l = min(lines(i).YData(START_IM:END_IM));
        %             max_l = max(lines(i).YData(START_IM:END_IM));
        %             scale = M/max_l;
        %             %offset = scale*(max_l+min_l)/2 - (m+M)/2;
        %             lines(i).YData = lines(i).YData*scale;
        %             lines(i).UserData.scale = scale;
        %             %lines(i).UserData.offset = offset;

        case 0
            % No scaling
            lines(i).YData = lines(i).UserData.YDataOriginal;
            
        case 1
            % Scaling
            m_global = min(lines(i).YData,[],'omitnan');
            M_global = max(lines(i).YData,[],'omitnan');
            m = min(lines(i).YData(START_IM:END_IM),[],'omitnan');
            M = max(lines(i).YData(START_IM:END_IM),[],'omitnan');
            lines(i).YData = rescale(lines(i).YData,((M-m_global)/(M-m))*ax.YLim(1),((M_global-m)/(M-m))*ax.YLim(2));
            
    end
end

end