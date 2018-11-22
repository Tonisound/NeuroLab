function template_button_TagSelection_Callback(hObj,~,ax,edits,selection_type,ind_tag,v)
% Time Tag Selection Callback
% Single Selection

global DIR_SAVE FILES CUR_FILE;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags_cell','TimeTags_strings','TimeTags_images');
catch
    errordlg(sprintf('Missing File Time_Tags.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab)));
    return;
end

if isempty(hObj.UserData)
    Selected = 1;
else
    if strcmp(selection_type,'multiple')
        Selected = hObj.UserData.Selected;
    elseif strcmp(selection_type,'single')
        Selected = hObj.UserData.Selected(1);
   end
end

if nargin <6
    str_tag = arrayfun(@(i) strjoin(TimeTags_cell(i,2:4),' - '), 2:size(TimeTags_cell,1), 'unif', 0)';
    [ind_tag,v] = listdlg('Name','Tag Selection','PromptString','Select Time Tags',...
        'SelectionMode',selection_type,'ListString',str_tag,...
        'InitialValue',Selected,'ListSize',[300 500]);
end

if v==0
    return;
elseif isempty(ind_tag)
    hObj.UserData='';
else
    hObj.UserData.Selected = ind_tag;
    hObj.UserData.Name = TimeTags_cell(ind_tag+1,2);
    hObj.UserData.TimeTags_strings = TimeTags_strings(ind_tag,:);
    hObj.UserData.TimeTags_images = TimeTags_images(ind_tag,:);
    
    hObj.UserData.Selected = ind_tag;
    min_time = char(TimeTags_cell(ind_tag+1,3));
    t_start = datenum(min_time);
    max_time_dur = char(TimeTags_cell(ind_tag+1,4));
    t_end = datenum(min_time)+datenum(max_time_dur);
    max_time = datestr(t_end,'HH:MM:SS.FFF');
    
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
    hObj.UserData.GroupName = name_Tag;
    
    for i=1:length(ax)
        ax(i).XLim = [(t_start - floor(t_start))*24*3600,(t_end - floor(t_end))*24*3600];
        %ax(i).Title.String = char(TimeTags_cell(ind_tag+1,2));
    end
    if nargin>3
        edits(1).String = min_time;
        edits(2).String = max_time;
    end
end

end