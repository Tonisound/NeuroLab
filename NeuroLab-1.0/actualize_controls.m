function actualize_controls(handles,uivalues)
% Actualize UiControls

global CUR_IM END_IM FILES CUR_FILE DIR_SAVE IM;

set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
set(handles.PlayToggle,'Value',0);

set(handles.CenterPanelPopup,'Value',uivalues.CenterPanelPopup);
handles.CenterPanelPopup.UserData = uivalues.CenterPanelPopup;
set(handles.FigureListPopup,'Value',uivalues.FigureListPopup);
set(handles.ProcessListPopup,'Value',uivalues.ProcessListPopup);
set(handles.RightPanelPopup,'Value',uivalues.RightPanelPopup);

set(handles.LabelBox,'Value',uivalues.LabelBox);
set(handles.PatchBox,'Value',uivalues.PatchBox);
set(handles.MaskBox,'Value',uivalues.MaskBox);
handles.TagButton.UserData = uivalues.TagSelection;
%Video Menu
handles.ViewMenu_Video.Checked = uivalues.video_status;
handles.VideoFigure.Visible = uivalues.video_status;
%uivalues.video_status

if ~isempty(FILES)
     try
        load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref');
        set(handles.TimeDisplay,'UserData',datestr((time_ref.Y)/(24*3600),'HH:MM:SS.FFF'));
        set(handles.TimeDisplay,'String',datestr(time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF'));
    catch
        fprintf('(Warning) Missing Reference Time File (%s)\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
        set(handles.TimeDisplay,'UserData',repmat('00:00:00.000',size(IM,3),1));
        set(handles.TimeDisplay,'String','00:00:00.000');
    end
end

end