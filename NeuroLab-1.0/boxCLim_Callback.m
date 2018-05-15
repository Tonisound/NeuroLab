function boxCLim_Callback(src,~,handles)
% 403 -- Callback Clim CheckBox

global IM START_IM END_IM;

if get(src,'Value') == 1
    handles.CenterAxes.CLimMode = 'auto';
    fprintf('CLim Mode set to auto. CLim = [%.1f %.1f].\n',handles.CenterAxes.CLim(1),handles.CenterAxes.CLim(2));
else
    handles.CenterAxes.CLimMode = 'manual';
    
    all_movie = IM(:,:,START_IM:END_IM);
    m = min(all_movie(:),[],'omitnan');
    M = max(all_movie(:),[],'omitnan');
    handles.CenterAxes.CLim = [m,M];
    
    fprintf('CLim Mode set to manual. CLim = [%.1f %.1f].\n',handles.CenterAxes.CLim(1),handles.CenterAxes.CLim(2));
end

end