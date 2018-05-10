function menuTag_TimeTagSelection_Callback(~,~,handles,ind_tag,v)
% Time Tag Selection Callback
% If nargin == 3 : opens list dialog to manually select Time Tags

global DIR_SAVE FILES CUR_FILE CUR_IM START_IM END_IM;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags_cell','TimeTags_strings','TimeTags_images');
catch
    errordlg(sprintf('Please re-import Time_Tags.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab)));
    return;
end

if isempty(handles.TagButton.UserData)
    Selected = 1;
else
    Selected = handles.TagButton.UserData.Selected;
end

if nargin<4
    str_tag = arrayfun(@(i) strjoin(TimeTags_cell(i,2:4),' - '), 2:size(TimeTags_cell,1), 'unif', 0)';
    if max(Selected)>length(str_tag)
        Selected = 1;
        handles.TagButton.UserData=[];
    end
    [ind_tag,v] = listdlg('Name','Tag Selection','PromptString','Select Time Tags',...
        'SelectionMode','mutiple','ListString',str_tag,'InitialValue',Selected,'ListSize',[300 500]);
end

if v==0
    return;
elseif isempty(ind_tag)
    handles.TagButton.UserData='';
else
    handles.TagButton.UserData.Selected = ind_tag;
    handles.TagButton.UserData.Name = TimeTags_cell(ind_tag+1,2);
    handles.TagButton.UserData.TimeTags_strings = TimeTags_strings(ind_tag,:);
    handles.TagButton.UserData.TimeTags_images = TimeTags_images(ind_tag,:);
    
    % Setting limits on RightAxes
    TimeTags_images = TimeTags_images(ind_tag,:);
    START_IM = min(TimeTags_images(:,1));
    END_IM = max(TimeTags_images(:,2));
    if CUR_IM > END_IM || CUR_IM < START_IM
        CUR_IM = START_IM;
        set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
    end
    set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
    actualize_plot(handles);
    
    % Adding Tag Name
    if length(ind_tag)==1
        handles.RightAxes.Title.String = sprintf('Tag %s (%s - %s)',char(TimeTags_cell(ind_tag+1,2)),char(TimeTags_strings(ind_tag,1)),char(TimeTags_strings(ind_tag,2)));
    else
        handles.RightAxes.Title.String = '';
    end
    
    % Adding TimeGroup Name
    name_Tag = '';
    if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'file')
        load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_S');
        % Test if ind_tags matches TimeGroups_S(i).Selected
        for i =1:length(TimeGroups_name)
            if length(TimeGroups_S(i).Selected)== length(ind_tag) && sum(TimeGroups_S(i).Selected-ind_tag(:))==0
                name_Tag = char(TimeGroups_name(i));
            end
        end
    end
    handles.TagButton.UserData.GroupName = name_Tag;
end

end

% name_Tag = check_TimeGroups(ind_tag);
% function name_Tag = check_TimeGroups(ind_tags)
% 
% if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'file')
%     load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_S');
%     % Test if ind_tags matches TimeGroups_S(i).Selected
%     for i =1:length(TimeGroups_name)
%         if length(TimeGroups_S(i).Selected)== length(ind_tags) && sum(TimeGroups_S(i).Selected-ind_tags)==0
%             name_Tag = char(TimeGroups_name(i));
%         end
%     end
% else
%     warning(sprintf('Missing file Time_Groups.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab)));
%     name_Tag = '';
%     return ;
% end
% 
% end