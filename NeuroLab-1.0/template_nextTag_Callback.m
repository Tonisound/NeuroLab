function template_nextTag_Callback(~,~,button,ax,edits)

global DIR_SAVE FILES CUR_FILE;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags_cell');
catch
    errordlg(sprintf('Missing File Time_Tags.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus)));
    return;
end

if ~isempty(button.UserData)
    ind_new = min(button.UserData.Selected+1,size(TimeTags_cell,1));  
    min_time = char(TimeTags_cell(ind_new+1,3));
    t_start = datenum(min_time);
    max_time_dur = char(TimeTags_cell(ind_new+1,4));
    t_end = datenum(min_time)+datenum(max_time_dur);
    max_time = datestr(t_end,'HH:MM:SS.FFF');
    button.UserData.Selected = ind_new;
    for i=1:length(ax)
        ax(i).XLim = [(t_start - floor(t_start))*24*3600,(t_end - floor(t_end))*24*3600];
    end
    
    if nargin>4
        edits(1).String = min_time;
        edits(2).String = max_time;
    end
end

end