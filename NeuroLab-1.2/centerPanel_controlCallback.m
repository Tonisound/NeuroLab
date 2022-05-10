function centerPanel_controlCallback(hObj,~,handles)
% 203 -- Display Images

%global DIR_SAVE LAST_IM IM FILES CUR_FILE;
global DIR_SAVE FILES CUR_FILE;

% Pointer Watch
tic;
set(handles.MainFigure,'pointer','watch');
drawnow;

val = get(hObj,'Value');
str = strtrim(hObj.String(hObj.Value,:));
if val == hObj.UserData
    % fprintf('No update, same selection.\n');
    set(handles.MainFigure, 'pointer','arrow');
    return;
end

% dd = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Doppler.mat'),'Doppler_type');
% if strcmp(str,dd.Doppler_type)
%     warning('No update, same selection');
%     return;
% end

% success = load_global_image(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),val);
success = load_global_image(FILES(CUR_FILE),str);

if success
    hObj.UserData = val;
    actualize_traces(handles);
    actualize_plot(handles);
    buttonAutoScale_Callback(0,0,handles);
else
    hObj.Value = hObj.UserData;
end

% Update Config.mat
folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);
data_config = load(fullfile(folder_name,'Config.mat'),'UiValues');
UiValues = data_config.UiValues;
UiValues.CenterPanelPopup = val;
save(fullfile(folder_name,'Config.mat'),'UiValues','-append');
fprintf('Config.mat file updated [%s].\n',fullfile(folder_name,'Config.mat'));

toc;
set(handles.MainFigure, 'pointer', 'arrow');

end