function centerPanel_controlCallback(hObj,~,handles)
% 203 -- Display Images

%global DIR_SAVE LAST_IM IM FILES CUR_FILE;
global DIR_SAVE FILES CUR_FILE;

% Pointer Watch
tic;
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

val = get(hObj,'Value');
%str = get(hObj,'String');
success = load_global_image(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),val);
if success
    hObj.UserData = val;
    actualize_traces(handles);
    actualize_plot(handles);
else
    hObj.Value = hObj.UserData;
end

toc;
set(handles.MainFigure, 'pointer', 'arrow');

end