function centerPanel_motionFcn(hObj,~,handles)
% Called when user moves Pixel in CenterAxes

global IM;

pt2 = round(get(handles.CenterAxes,'CurrentPoint'));
Xlim2 = get(handles.CenterAxes,'XLim');
Ylim2 = get(handles.CenterAxes,'YLim');

if(pt2(1,1)>Xlim2(1) && pt2(1,1)<Xlim2(2) && pt2(1,2)>Ylim2(1) && pt2(1,2)<Ylim2(2))
    if strcmp(get(hObj,'Pointer'),'arrow')
        set(hObj,'Pointer','crosshair');
    end
    if ~isempty(findobj(handles.CenterAxes,'Tag','Movable_Pixel'))
        pix = findobj(handles.CenterAxes,'Tag','Movable_Pixel');
        pix.XData = pt2(1,1);
        pix.YData = pt2(1,2);
        pix.MarkerEdgeColor = char2rgb('w');
        pix.LineWidth = 2;
        set(findobj(handles.CenterAxes,'Tag','Pixel'),'MarkerEdgeColor',char2rgb('k'),'LineWidth',1);
        hp = findobj(handles.RightAxes,'Tag','Movable_Trace_Pixel');
        %hp.YData(~isnan(hp.YData)) = IM(pt2(1,2),pt2(1,1),:);
        hp.YData(1:end-1) = IM(pt2(1,2),pt2(1,1),:);
    end
    if ~isempty(findobj(handles.CenterAxes,'Tag','Movable_Box'))
        reg = findobj(handles.CenterAxes,'Tag','Movable_Box');
        reg.EdgeColor = char2rgb('w');
        reg.LineWidth = 2;
        set(findobj(handles.CenterAxes,'Tag','Box'),'EdgeColor',char2rgb('k'),'LineWidth',1);
        reg.XData(3) = pt2(1,1);
        reg.XData(4) = pt2(1,1);
        reg.YData(2) = pt2(1,2);
        reg.YData(3) = pt2(1,2);
        t = findobj(handles.RightAxes,'Tag','Movable_Trace_Box');
        i = min(reg.YData(1),reg.YData(2));
        j = min(reg.XData(3),reg.XData(2));
        I = max(reg.YData(1),reg.YData(2));
        J = max(reg.XData(3),reg.XData(2));
        t.YData(1:end-1) = mean(mean(IM(i:I,j:J,:),2,'omitnan'),1,'omitnan');
        %t.YData(~isnan(t.YData)) = mean(mean(IM(i:I,j:J,:),2,'omitnan'),1,'omitnan');
    end
else
    set(hObj,'Pointer','arrow');
end

end
