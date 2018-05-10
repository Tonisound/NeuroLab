function rightPanel_clickFcn(hObj,~,handles)
% Main GUI Mouse Control
% Called when user clicks into RightAxes for time selection
    
load('Preferences.mat','GDisp','GTraces');
pt_rp = get(hObj,'CurrentPoint');
Xlim = get(hObj,'XLim');
Ylim = get(hObj,'YLim');

if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
    set(hObj,'UserData',[pt_rp(1,1),pt_rp(1,2)]);
    set(handles.MainFigure,'WindowButtonMotionFcn', {@rightPanel_motionFcn,handles});
    set(handles.MainFigure,'WindowButtonUpFcn', {@rightPanel_unclickFcn,handles});
    line([pt_rp(1,1) pt_rp(1,1)],hObj.YLim,'Tag','T1','Color', 'black','LineWidth',.5,'Parent', hObj);
    line([pt_rp(1,1) pt_rp(1,1)],hObj.YLim,'Tag','T2','Color', 'black','LineWidth',.5,'Parent', hObj);
    x = [pt_rp(1,1) pt_rp(1,1) pt_rp(1,1) pt_rp(1,1)];
    y = [hObj.YLim(1) hObj.YLim(2) hObj.YLim(2) hObj.YLim(1)];
    patch(x,y,[0.5 0.5 0.5],'EdgeColor','none','Tag','T3','FaceAlpha',.5,'LineWidth',.5,'Parent', hObj);
end

end
