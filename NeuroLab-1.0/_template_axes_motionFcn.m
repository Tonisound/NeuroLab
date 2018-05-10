function template_axes_motionFcn(~,~,ax,all_axes)

pt = get(ax,'CurrentPoint');
pt1 = get(ax,'UserData');

%all_axes = findobj(hObj,'Type','Axes');
for i=1:length(all_axes)
    c = findobj(all_axes(i),'Tag','T2');
    d = findobj(all_axes(i),'Tag','T3');
    if ~isempty(pt1)
        set(c,'XData',[pt(1,1) pt(1,1)]);
        set(d,'X',[pt1(1,1),pt1(1,1),pt(1,1),pt(1,1)]);
    end    
end

end