function menuTag_prevTag_Callback(~,~,handles)

global DIR_SAVE FILES CUR_FILE CUR_IM START_IM END_IM;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags_cell');
    %fprintf('Successful Time Tags Importation (File %s).\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'));
catch
    errordlg(sprintf('Missing File Time_Tags.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus)));
    return;
end

if ~isempty(handles.TagButton.UserData)
    
    ind_new = max(min(handles.TagButton.UserData.Selected)-1,1);  
    min_time = char(TimeTags_cell(ind_new+1,3));
    max_time_on = char(TimeTags_cell(ind_new+1,3));
    max_time_dur = char(TimeTags_cell(ind_new+1,4));
    max_time = datestr(datenum(max_time_on)+datenum(max_time_dur),'HH:MM:SS.FFF');
    [~, ind_min_time] = min(abs(datenum(handles.TimeDisplay.UserData)-datenum(min_time)));
    [~, ind_max_time] = min(abs(datenum(handles.TimeDisplay.UserData)-datenum(max_time)));
    
    TimeTags_strings = {min_time,max_time};
    TimeTags_images = [ind_min_time,ind_max_time];
    handles.TagButton.UserData.TimeTags_strings = TimeTags_strings;
    handles.TagButton.UserData.TimeTags_images = TimeTags_images;
    handles.TagButton.UserData.Selected = ind_new;
    
    % Adding Tag Name
    handles.RightAxes.Title.String = sprintf('Tag %s (%s - %s)',char(TimeTags_cell(ind_new+1,2)),char(TimeTags_strings(1)),char(TimeTags_strings(2)));
    
    % Setting limits on RightAxes
    START_IM = ind_min_time;
    END_IM = ind_max_time;
    if CUR_IM > END_IM || CUR_IM < START_IM
        CUR_IM = START_IM;
        set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
    end
    set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));    
    actualize_plot(handles);
    
end

end