function fileSelectionPopup_Callback(hObj,~,handles)
% 101 - File Selection Popup

global FILES CUR_FILE IM CUR_IM LAST_IM START_IM END_IM DIR_SAVE;
load('Preferences.mat','GDisp');
load('Files.mat','UiValues');

% Pointer Watch
handles.MainFigure.Pointer = 'watch';
drawnow;

% Retrieving old and new files
if isempty(hObj.UserData)
    old = '';
else
    old = hObj.UserData;
end
new = char(strtrim(hObj.String(hObj.Value,:)));

temp = regexp(new,'/','split');
new_fus = strcat(char(temp(end)),'_nlab');
temp = regexp(old,'/','split');
old_fus = strcat(char(temp(end)),'_nlab');
CUR_FILE = hObj.Value;

if ~strcmp(old,new)
    % Saving Previous File if FILES not empty
    if ~(strcmp(old,'') || strcmp(old,'<0>'))
        save_graphicdata(fullfile(DIR_SAVE,old_fus),handles);
    end
    
    % Saving Previous File if FILES not empty
    if ~(strcmp(new,'')||strcmp(new,'<0>'))
        
        data_config = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.mat'),'CUR_IM','LAST_IM','START_IM','END_IM','UiValues');
        START_IM = data_config.START_IM;
        CUR_IM = data_config.CUR_IM;
        END_IM = data_config.END_IM;
        LAST_IM = data_config.LAST_IM;
        load_global_image(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),data_config.UiValues.CenterPanelPopup);
        
        if exist(fullfile(DIR_SAVE,new_fus,'Trace_light.mat'),'file')
            load_graphicdata(fullfile(DIR_SAVE,new_fus),handles);
        else
            % Delete existing graphic data
            warning('Missing Graphic Objects. File %s.\n',fullfile(DIR_SAVE,new_fus));
            delete(findobj(handles.CenterAxes,'Type','Line','-not','Tag','Cursor','-or','Type','Patch'));
            delete(findobj(handles.RightAxes,'Type','Line','-not','Tag','Cursor','-or','Type','Text'));
            
            % Recreate Mean and Mean Label
            try
                load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
            catch
                warning('Missing File Time_Reference.mat');
                length_burst = size(IM,3);
                n_burst =1;
            end
            xdata = [reshape(1:LAST_IM,[length_burst,n_burst]);NaN(1,n_burst)];
            ydata = [reshape(mean(mean(IM,2,'omitnan'),1,'omitnan'),[length_burst,n_burst]);NaN(1,n_burst)];
            hl = line('XData',xdata(:),'YData',ydata(:),...
                'Tag','Trace_Mean','Color','black',...
                'HitTest','off','Parent',handles.RightAxes);
            s.Name = 'Whole';
            hl.UserData = s;
            
        end
        
    else
        IM = zeros(88,169,2);
        LAST_IM = 2;
        START_IM = 1;
        END_IM = 2;
        CUR_IM = 1;
        menuTraces_DeleteAll_Callback([],[],handles);
    end
else
    if ~isempty(FILES) && exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.mat'),'file')
        load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.mat'),'CUR_IM','LAST_IM','START_IM','END_IM','UiValues');
        %fprintf('Configuration loaded : %s\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.mat'));
    end
end

% Saving CUR_FILE Files.mat
save('Files.mat','CUR_FILE','-append');
%fprintf('Files.mat Saved %s.\n',fullfile(pwd,'Files.mat'));

actualize_controls(handles,UiValues)
actualize_plot(handles);
buttonAutoScale_Callback(handles.AutoScaleButton,[],handles);
hObj.UserData = char(new);
set(handles.MainFigure, 'pointer', 'arrow');

end
