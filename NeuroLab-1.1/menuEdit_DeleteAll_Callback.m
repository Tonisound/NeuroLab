function menuEdit_DeleteAll_Callback(~,~,handles)
% 104 -- Manual Reset

global CUR_IM START_IM END_IM LAST_IM DIR_SAVE FILES CUR_FILE IM;

% Time Reference Loading
if isempty(FILES)
    length_burst = 2;
    n_burst = 1;
else
    try
        load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
    catch
        warning('Missing File Time_Reference.mat');
        length_burst = size(IM,3);
        n_burst =1;
    end
end

% Resetting Current Start and & Last images
CUR_IM = 1;
START_IM = 1;
END_IM = LAST_IM;
set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));

% Stopping Movie
set(handles.PlayToggle,'Value',0);
%set(handles.LabelBox,'Value',0);
set(findobj(handles.RightAxes,'Tag','Trace_Mean'),'Visible','on');

% Resetting axes
delete(findobj(handles.CenterAxes,'Type','line','-or','Type','patch'));
delete(findobj(handles.RightAxes,'Type','line','-not','Tag','Cursor'));
delete(findobj(handles.RightAxes,'Type','text'));

% Recreating Trace_Mean
xdata = [reshape(1:LAST_IM,[length_burst,n_burst]);NaN(1,n_burst)];
ydata = [reshape(mean(mean(IM,2,'omitnan'),1,'omitnan'),[length_burst,n_burst]);NaN(1,n_burst)];
hl = line('XData',xdata(:),...
    'YData',ydata(:),...
    'Tag','Trace_Mean',...
    'Color','black',...
    'HitTest','off',...
    'Parent', handles.RightAxes);
s.Name = 'Whole';
hl.UserData = s;

% Updating Plot Figure
actualize_plot(handles);

end