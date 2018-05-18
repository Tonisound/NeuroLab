function menuEdit_TimeGroupSelection_Callback(hObj,~,handles,ind_group)
% Time Group Selection Callback

global DIR_SAVE FILES CUR_FILE CUR_IM START_IM END_IM;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
catch
    errordlg(sprintf('Please edit Time_Groups.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab)));
    return;
end

if nargin<4
    [ind_group,v] = listdlg('Name','Time Group Selection','PromptString','Select Time Groups',...
        'SelectionMode','single','ListString',TimeGroups_name,...
        'InitialValue',1,'ListSize',[300 500]);
else
    v=1;
end

if v==0 || ind_group>size(TimeGroups_name,1)
    return;
elseif isempty(ind_group)
    handles.TagButton.UserData='';
else
    %hObj.UserData.Name = char(TimeGroups_name(ind_group));
    ind_tag = TimeGroups_S(ind_group).Selected;
    handles.TagButton.UserData.Selected = ind_tag';
    handles.TagButton.UserData.Name = TimeGroups_S(ind_group).Name;
    handles.TagButton.UserData.TimeTags_strings = TimeGroups_S(ind_group).TimeTags_strings;
    handles.TagButton.UserData.TimeTags_images = TimeGroups_S(ind_group).TimeTags_images;
    handles.TagButton.UserData.GroupName = char(TimeGroups_name(ind_group));
    
    % Setting limits on RightAxes
    TimeTags_images = TimeGroups_S(ind_group).TimeTags_images;
    START_IM = min(TimeTags_images(:,1));
    END_IM = max(TimeTags_images(:,2));
    if CUR_IM > END_IM || CUR_IM < START_IM
        CUR_IM = START_IM;
        set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
    end
    set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
    actualize_plot(handles);
    fprintf('Time Group loaded [%s].\n',char(TimeGroups_name(ind_group)));
end

end