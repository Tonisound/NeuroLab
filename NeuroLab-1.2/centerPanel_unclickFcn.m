function centerPanel_unclickFcn(hObj,~,handles)
% Called when user releases Pixel in CenterAxes

global CUR_IM;
load('Preferences.mat','GDisp');

% Converting Movable to Fixed
hp= findobj(handles.CenterAxes,'Tag','Movable_Pixel');
hl= findobj(handles.RightAxes,'Tag','Movable_Trace_Pixel');
hq= findobj(handles.CenterAxes,'Tag','Movable_Box');
hr= findobj(handles.RightAxes,'Tag','Movable_Trace_Box');

set(hp,'Tag','Pixel','ButtonDownFcn',{@click_PixelFcn,handles});
set(hl,'Tag','Trace_Pixel','HitTest','on');
set(hl,'ButtonDownFcn',{@click_lineFcn,handles});
 
set(hq,'Tag','Box','ButtonDownFcn',{@click_PatchFcn,handles});
set(hr,'Tag','Trace_Box','HitTest','on');
set(hr,'ButtonDownFcn',{@click_lineFcn,handles});

set(hObj,'Pointer','arrow');
set(hObj,'WindowButtonMotionFcn','');
set(hObj,'WindowButtonUp','');
handles.Cursor.XData = [CUR_IM, CUR_IM];
handles.Cursor.YData = ylim(handles.RightAxes);

end
