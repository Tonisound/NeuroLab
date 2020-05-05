function template_axes_clickFcn(hObj,~,version,axes,edits)

f = get_parentfigure(hObj);
pt_rp = get(hObj,'CurrentPoint');
Xlim = get(hObj,'XLim');
Ylim = get(hObj,'YLim');

if nargin<3
    version = 0;
end

switch version
    case 0
        % Single-line
        all_axes = hObj;
    case 1
        % Muti-line (All axes in Figure affected)
        all_axes = findobj(f,'Type','Axes');
    case 2
        % Multi-line (Only axes specified in arguments are affected)
        all_axes = axes;
end

if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
    set(hObj,'UserData',[pt_rp(1,1),pt_rp(1,2)]);
    set(f,'WindowButtonMotionFcn', {@template_axes_motionFcn,hObj,all_axes});
    if nargin>4
        set(f,'WindowButtonUpFcn', {@template_axes_unclickFcn,hObj,all_axes,edits});
    else
        set(f,'WindowButtonUpFcn', {@template_axes_unclickFcn,hObj,all_axes});
    end
    
    for i=1:length(all_axes)
        line([pt_rp(1,1) pt_rp(1,1)],all_axes(i).YLim,'Tag','T1','Color', 'black','LineWidth',.5,'LineStyle','-','Parent', all_axes(i));
        t2 = findobj(all_axes(i),'Tag','T2');
        if isempty(t2)
            line([pt_rp(1,1) pt_rp(1,1)],all_axes(i).YLim,'Tag','T2','Color', 'black','LineWidth',.5,'LineStyle','-','Parent', all_axes(i));
        else
            t2.XData = [pt_rp(1,1) pt_rp(1,1)];
            %t2.Visible = 'on';
        end
        x = [pt_rp(1,1) pt_rp(1,1) pt_rp(1,1) pt_rp(1,1)];
        y = [all_axes(i).YLim(1) all_axes(i).YLim(2) all_axes(i).YLim(2) all_axes(i).YLim(1)];
        patch(x,y,[0.5 0.5 0.5],'EdgeColor','none','Tag','T3','FaceAlpha',.5,'LineWidth',.5,'Parent', all_axes(i));
    end
    
end

if length(edits)>2
    edits(3).String = datestr(pt_rp(1,1)/(24*3600),'HH:MM:SS.FFF');
end

end