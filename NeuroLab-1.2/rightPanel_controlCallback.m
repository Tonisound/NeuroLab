function rightPanel_controlCallback(hObj,~,handles)
% 203 -- Display Dynmaics

load('Preferences.mat','GTraces','GDisp');
val = get(hObj,'Value');
str = get(hObj,'String');

% pix = findobj(handles.CenterAxes,'Tag','Pixel');
% box = findobj(handles.CenterAxes,'Tag','Box');
% reg = findobj(handles.CenterAxes,'Tag','Region');
hp = findobj(handles.RightAxes,'Tag','Trace_Pixel');
hb = findobj(handles.RightAxes,'Tag','Trace_Box');
hr = findobj(handles.RightAxes,'Tag','Trace_Region');
hs = findobj(handles.RightAxes,'Tag','Trace_RegionGroup');
ht = findobj(handles.RightAxes,'Tag','Trace_Cerep');

% Turning all objects invisible
set([hp;hb;hr;hs;ht],'Visible','off');
        
switch strtrim(str(val,:))
    case {'Pixel Dynamics','Pixel'}
        % set([pix;hp],'Visible','on');
        set(hp,'Visible','on');
        
    case {'Box Dynamics','Box'}
        % set([box;hb],'Visible','on');
        set(hb,'Visible','on');
        
    case {'Region Dynamics','Region'}
        %set([reg;hr],'Visible','on');
        set(hr,'Visible','on');
        
    case {'Region Group Dynamics','RegionGroup'}
        set(hs,'Visible','on');
        
    case {'Trace Dynamics'}
        set(ht,'Visible','on');
end

% Update Patches and Masks
boxPatch_Callback(handles.PatchBox,[],handles);
boxMask_Callback(handles.MaskBox,[],handles)

actualize_plot(handles);
buttonAutoScale_Callback(handles.AutoScaleButton,[],handles);

end