function mainFigure_windowscrollwheelFcn(~,evnt,handles)
% Main GUI Mouse Control
% Called when user uses scroll wheel for time selection

global CUR_IM START_IM END_IM LAST_IM;

factor = .2; % proportion of increase/decrease;
xlim1 = handles.RightAxes.XLim(1);
xlim2 = handles.RightAxes.XLim(2);

%evnt.VerticalScrollCount
if evnt.VerticalScrollCount >0
    %disp('down')
    Xlim1 = min(CUR_IM,xlim1+factor*(CUR_IM-xlim1));
    Xlim2 = max(CUR_IM,xlim2-factor*(xlim2-CUR_IM));
    
else
    %disp('up')
    Xlim1 = max(1,xlim1-factor*(CUR_IM-xlim1));
    Xlim2 = min(LAST_IM,xlim2+factor*(xlim2-CUR_IM));
end

handles.RightAxes.XLim = [Xlim1;Xlim2];

START_IM = ceil(Xlim1);
END_IM = floor(Xlim2);

set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));

end

  