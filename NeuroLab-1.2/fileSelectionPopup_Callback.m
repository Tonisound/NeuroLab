function fileSelectionPopup_Callback(hObj,~,handles)
% 101 - File Selection Popup

global FILES CUR_FILE IM CUR_IM LAST_IM START_IM END_IM DIR_SAVE;
load('Preferences.mat','GDisp','GTraces');
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

temp = regexp(new,filesep,'split');
new_fus = strcat(char(temp(end)),'_nlab');
temp = regexp(old,filesep,'split');
old_fus = strcat(char(temp(end)),'_nlab');
CUR_FILE = hObj.Value;

if ~strcmp(old,new)
    % Saving Previous File if FILES not empty
    if ~(strcmp(old,'') || strcmp(old,'<0>'))
        % saving graphics
        save_graphicdata(fullfile(DIR_SAVE,old_fus),handles);
        
        % deleting cereplex traces
        if ~isempty(FILES) && exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Cereplex_Traces.mat'),'file')
            fprintf('Deleting Cereplex_Traces.mat ...');
            delete(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Cereplex_Traces.mat'));
            fprintf(' done.\n');
        end
    end
    
    % Saving Previous File if FILES not empty
    if ~(strcmp(new,'')||strcmp(new,'<0>'))
        
        data_config = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.mat'),...
            'File','CUR_IM','LAST_IM','START_IM','END_IM','UiValues');
        UiValues = data_config.UiValues;
        START_IM = data_config.START_IM;
        CUR_IM = data_config.CUR_IM;
        END_IM = data_config.END_IM;
        LAST_IM = data_config.LAST_IM;
        FILES(CUR_FILE) = data_config.File;      
        % load_global_image(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),data_config.UiValues.CenterPanelPopup);
        load_global_image(FILES(CUR_FILE),handles.CenterPanelPopup.String(data_config.UiValues.CenterPanelPopup,:));
        
        if exist(fullfile(DIR_SAVE,new_fus,'Trace_light.mat'),'file')
            load_graphicdata(fullfile(DIR_SAVE,new_fus),handles);
        else
            % Delete existing graphic data
            warning('Missing Graphic Objects. File %s.',fullfile(DIR_SAVE,new_fus));
            delete(findobj(handles.CenterAxes,'Type','Line','-not','Tag','Cursor','-or','Type','Patch'));
            delete(findobj(handles.RightAxes,'Type','Line','-not','Tag','Cursor','-or','Type','Text'));
            
            % Recreate Mean
            try
                data_tr = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),...
                    'time_ref','length_burst','n_burst','rec_mode');
                rec_mode = data_tr.rec_mode;
                time_ref = data_tr.time_ref;
                length_burst = length(time_ref.Y);
                n_burst = 1;
            catch
                warning('Missing File Time_Reference.mat');
                length_burst = size(IM,3);
                n_burst = 1;
                rec_mode = 'CONTINUOUS';
            end
            xdata = [reshape(1:LAST_IM,[length_burst,n_burst]);NaN(1,n_burst)];
            ydata = [reshape(mean(mean(IM,2,'omitnan'),1,'omitnan'),[length_burst,n_burst]);NaN(1,n_burst)];
            hl = line('XData',xdata(:),'YData',ydata(:),...
                'Tag','Trace_Mean','Color','black','LineWidth',1,...
                'HitTest','off','Parent',handles.RightAxes);
            s.Name = 'Whole';
            s.Selected = 0;
            hl.UserData = s;
            
            % Gaussian window
            t_gauss = GTraces.GaussianSmoothing;
            delta =  time_ref.Y(2)-time_ref.Y(1);
            w = gausswin(round(2*t_gauss/delta));
            w = w/sum(w);
            % Gaussian smoothing
            if t_gauss>0
                y = hl.YData(1:end-1);
                if strcmp(rec_mode,'BURST')
                    % gaussian nan convolution + nan padding (only for burst_recording)
                    %length_burst_smooth = 1181;
                    length_burst_smooth = data_tr.length_burst;
                    n_burst_smooth = length(y)/length_burst_smooth;
                    y_reshape = [reshape(y,[length_burst_smooth,n_burst_smooth]);NaN(length(w),n_burst_smooth)];
                    y_conv = nanconv(y_reshape(:),w,'same');
                    y_reshaped = reshape(y_conv,[length_burst_smooth+length(w),n_burst_smooth]);
                    y_final = reshape(y_reshaped(1:length_burst_smooth,:),[length_burst_smooth*n_burst_smooth,1]);
                    hl.YData(1:end-1) = y_final';
                else
                    hl.YData(1:end-1) = nanconv(y,w,'same');
                end
            end        
        end
        
    % Loading Video file
    load_video(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    else
        IM = zeros(88,169,2);
        LAST_IM = 2;
        START_IM = 1;
        END_IM = 2;
        CUR_IM = 1;
        menuEdit_DeleteAll_Callback([],[],handles);
        if ~isempty(handles.VideoAxes.UserData)
            delete(handles.VideoAxes.UserData.Image);
            delete(handles.VideoAxes.UserData.Text);
            % delete(handles.VideoAxes.UserData.VideoReader);
            handles.VideoAxes.UserData = [];
        end
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

% Actualize BoxAtlas
boxAtlas_Callback(handles.AtlasBox,[],handles.CenterAxes);
% Actualize BoxTimePatch
boxTimePatch_Callback(handles.TimePatchBox,[],handles.RightAxes);

set(handles.MainFigure, 'pointer', 'arrow');

end
