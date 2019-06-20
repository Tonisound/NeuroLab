function template_axes_unclickFcn(hObj,~,ax,all_axes,edits)

pt1 = get(ax,'UserData');
if ~isempty(pt1)
    pt = get(ax,'CurrentPoint');
    pt2 = [pt(1,1),pt(1,2)];
    if pt1(1,1)~=pt2(1,1)
        xlim1 = min(pt1(1,1),pt2(1,1));
        xlim2 = max(pt1(1,1),pt2(1,1));
        for k=1:length(all_axes)
            all_axes(k).XLim =[xlim1,xlim2];
        end
        if nargin>3
            edits(1).String = datestr(xlim1/(24*3600),'HH:MM:SS.FFF');
            edits(2).String = datestr(xlim2/(24*3600),'HH:MM:SS.FFF');
        end
    end
    
    %all_axes = findobj(hObj,'Type','Axes');
    for i=1:length(all_axes)
        set(all_axes(i),'UserData',[]);
        %delete(findobj(all_axes(i),'Tag','T1','-or','Tag','T2','-or','Tag','T3'));
        delete(findobj(all_axes(i),'Tag','T1','-or','Tag','T3'));
        if pt1(1,1)==pt2(1,1)
            t2 = findobj(all_axes(i),'Tag','T2');
            t2.Visible = 'off';
            if ~strcmp(all_axes(i).Parent.Tag,'BotPanel')
                axis(all_axes(i),'auto y');
            end
            t2.YData = [all_axes(i).YLim(1) all_axes(i).YLim(2)];
            t2.Visible = 'on';
        else
            delete(findobj(all_axes(i),'Tag','T2'));
        end
    end
end

set(hObj,'WindowButtonUp','');
set(hObj,'WindowButtonMotionFcn','');
end