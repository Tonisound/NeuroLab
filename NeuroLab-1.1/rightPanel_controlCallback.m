function rightPanel_controlCallback(hObj,~,handles)
% 203 -- Display Dynmaics

load('Preferences.mat','GTraces','GDisp');
val = get(hObj,'Value');
str = get(hObj,'String');

pix = findobj(handles.CenterAxes,'Tag','Pixel');
box = findobj(handles.CenterAxes,'Tag','Box');
%reg = findobj(handles.CenterAxes,'Tag','Region');
hp = findobj(handles.RightAxes,'Tag','Trace_Pixel','-or','Tag','Trace_Pixel_label');
hb = findobj(handles.RightAxes,'Tag','Trace_Box','-or','Tag','Trace_Box_label');
hr = findobj(handles.RightAxes,'Tag','Trace_Region','-or','Tag','Trace_Region_label');
hs = findobj(handles.RightAxes,'Tag','Trace_RegionGroup','-or','Tag','Trace_RegionGroup_label');
ht = findobj(handles.RightAxes,'Tag','Trace_Cerep','-or','Tag','Trace_Cerep_label');
hlab = findobj(handles.RightAxes,'Type','text','-not','Tag','Trace_Mean_label');

set([pix;box;hp;hb;hr;hs;ht],'Visible','off');
        
switch strtrim(str(val,:))
    case {'Pixel Dynamics','Pixel'}
        set([pix;hp],'Visible','on');
        
    case {'Box Dynamics','Box'}
        set([box;hb],'Visible','on');
        
    case {'Region Dynamics','Region'}
        %set([reg;hr],'Visible','on');
        set(hr,'Visible','on');
        
    case {'Region Group Dynamics','RegionGroup'}
        set(hs,'Visible','on');
        
    case {'Trace Dynamics'}
        set(ht,'Visible','on');
end

if ~handles.LabelBox.Value
    set(hlab,'Visible','off');
end

actualize_plot(handles);
buttonAutoScale_Callback(handles.AutoScaleButton,[],handles);

end