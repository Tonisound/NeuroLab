function centerPanel_motionFcn(hObj,~,handles)
% Called when user moves Pixel in CenterAxes

global DIR_SAVE FILES CUR_FILE IM;

% Gaussian window
load('Preferences.mat','GDisp','GTraces');
try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','length_burst','n_burst','rec_mode');
catch
    warning('Missing File %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
    length_burst = size(IM,3);
    n_burst =1;
    rec_mode = 'CONTINUOUS';
end
t_gauss = GTraces.GaussianSmoothing;
delta =  time_ref.Y(2)-time_ref.Y(1);
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);
        

pt2 = round(get(handles.CenterAxes,'CurrentPoint'));
Xlim2 = get(handles.CenterAxes,'XLim');
Ylim2 = get(handles.CenterAxes,'YLim');

if(pt2(1,1)>Xlim2(1) && pt2(1,1)<Xlim2(2) && pt2(1,2)>Ylim2(1) && pt2(1,2)<Ylim2(2))
    if strcmp(get(hObj,'Pointer'),'arrow')
        set(hObj,'Pointer','crosshair');
    end
    if ~isempty(findobj(handles.CenterAxes,'Tag','Movable_Pixel'))
        pix = findobj(handles.CenterAxes,'Tag','Movable_Pixel');
        pix.XData = pt2(1,1);
        pix.YData = pt2(1,2);
        
        hp = findobj(handles.RightAxes,'Tag','Movable_Trace_Pixel');
        hp.YData(1:end-1) = IM(pt2(1,2),pt2(1,1),:);
        
        % Gaussian smoothing
        if t_gauss>0
            y = hp.YData(1:end-1);
            if strcmp(rec_mode,'BURST')
                % gaussian nan convolution + nan padding (only for burst_recording)
                % length_burst_smooth = 30;
                % n_burst_smooth = length(y)/length_burst_smooth;
                % y_reshape = [reshape(y,[length_burst_smooth,n_burst_smooth]);NaN(length(w),n_burst_smooth)];
                try
                    length_burst_smooth = 59;
                    n_burst_smooth = length(y)/length_burst_smooth;
                    y_reshape = [reshape(y,[length_burst_smooth,n_burst_smooth]);NaN(length(w),n_burst_smooth)];
                catch
                    length_burst_smooth = 1181;
                    n_burst_smooth = length(y)/length_burst_smooth;
                    y_reshape = [reshape(y,[length_burst_smooth,n_burst_smooth]);NaN(length(w),n_burst_smooth)];
                end
                y_conv = nanconv(y_reshape(:),w,'same');
                y_reshaped = reshape(y_conv,[length_burst_smooth+length(w),n_burst_smooth]);
                y_final = reshape(y_reshaped(1:length_burst_smooth,:),[length_burst_smooth*n_burst_smooth,1]);
                hp.YData(1:end-1) = y_final';
            else
                hp.YData(1:end-1) = nanconv(y,w,'same');
            end
        end
    end
    if ~isempty(findobj(handles.CenterAxes,'Tag','Movable_Box'))
        reg = findobj(handles.CenterAxes,'Tag','Movable_Box');
        reg.XData(3) = pt2(1,1);
        reg.XData(4) = pt2(1,1);
        reg.YData(2) = pt2(1,2);
        reg.YData(3) = pt2(1,2);
        
        t = findobj(handles.RightAxes,'Tag','Movable_Trace_Box');
        i = min(reg.YData(1),reg.YData(2));
        j = min(reg.XData(3),reg.XData(2));
        I = max(reg.YData(1),reg.YData(2));
        J = max(reg.XData(3),reg.XData(2));
        t.YData(1:end-1) = mean(mean(IM(i:I,j:J,:),2,'omitnan'),1,'omitnan');
        
        % Gaussian smoothing
        if t_gauss>0
            y = t.YData(1:end-1);
            if strcmp(rec_mode,'BURST')
                % gaussian nan convolution + nan padding (only for burst_recording)
                % length_burst_smooth = 30;
                % n_burst_smooth = length(y)/length_burst_smooth;
                % y_reshape = [reshape(y,[length_burst_smooth,n_burst_smooth]);NaN(length(w),n_burst_smooth)];
                try
                    length_burst_smooth = 59;
                    n_burst_smooth = length(y)/length_burst_smooth;
                    y_reshape = [reshape(y,[length_burst_smooth,n_burst_smooth]);NaN(length(w),n_burst_smooth)];
                catch
                    length_burst_smooth = 1181;
                    n_burst_smooth = length(y)/length_burst_smooth;
                    y_reshape = [reshape(y,[length_burst_smooth,n_burst_smooth]);NaN(length(w),n_burst_smooth)];
                end
                
                y_conv = nanconv(y_reshape(:),w,'same');
                y_reshaped = reshape(y_conv,[length_burst_smooth+length(w),n_burst_smooth]);
                y_final = reshape(y_reshaped(1:length_burst_smooth,:),[length_burst_smooth*n_burst_smooth,1]);
                t.YData(1:end-1) = y_final';
            else
                t.YData(1:end-1) = nanconv(y,w,'same');
            end
        end
    end
else
    set(hObj,'Pointer','arrow');
end

end
