function success = actualize_traces(handles)
% Actualize Right Panel Traces when user modifies IM

global DIR_SAVE FILES CUR_FILE IM ;
load('Preferences.mat','GTraces');
success = false;

indexes  = isinf(1./IM);
if size(IM,1)*size(IM,2)*(size(IM,3)-1) == sum(indexes(:))
    choice = questdlg('NeuroLab is going to modify traces without loading Doppler',...
            'User Confirmation','Proceed','Load Doppler','Cancel','Cancel');
        % Proceed, cancel, update
        if ~isempty(choice)
            switch choice
                case 'Cancel'
                    warning('Actualize traces canceled.\n');
                    return;
                case 'Proceed'
                    warning('Proceeding.\n');
                case 'Load Doppler'
                    load('Preferences.mat','GImport');
                    GImport.Doppler_loading = 'full';
                    GImport.Doppler_loading_index = 1;
                    save('Preferences.mat','GImport','-append');
            end
        else
            warning('Actualize traces canceled.\n');
            return;           
        end
end

%loading Time Reference
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file')
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),...
        'time_ref','length_burst','n_burst','rec_mode');
else
    errordlg('Missing File [%s]',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
    return;
end

% Gaussian window
t_gauss = GTraces.GaussianSmoothing;
delta =  time_ref.Y(2)-time_ref.Y(1);
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);

% Update XData, YData for Mean
tm = findobj(handles.RightAxes,'Tag','Trace_Mean');
%tm.YData(~isnan(tm.YData)) = mean(mean(IM,2,'omitnan'),1,'omitnan');

% Smoothing mean
if t_gauss>0
    if strcmp(rec_mode,'BURST')
        y = mean(mean(IM,2,'omitnan'),1,'omitnan');
        try
            length_burst = 59;
            n_burst = length(y)/length_burst;
            y_reshape = [reshape(squeeze(y),[length_burst,n_burst]);NaN(length(w),n_burst)];
        catch
            length_burst = 1181;
            n_burst = length(y)/length_burst;
            y_reshape = [reshape(squeeze(y),[length_burst,n_burst]);NaN(length(w),n_burst)];
        end
        y_conv = nanconv(y_reshape(:),w,'same');
        y_reshaped = reshape(y_conv,[length_burst+length(w),n_burst]);
        y_final = reshape(y_reshaped(1:length_burst,:),[length_burst*n_burst,1]);
        tm.YData(1:end-1) = y_final;
    else
        y_smooth =  squeeze(mean(mean(IM,2,'omitnan'),1,'omitnan'));
        y_conv = nanconv(y_smooth,w,'same');
        tm.YData(1:end-1) = y_conv';
        success = true;
    end
else
    tm.YData(1:end-1) = mean(mean(IM,2,'omitnan'),1,'omitnan');
end

% Update YData for Mean, Lines and Boxes
graphics = findobj(handles.CenterAxes,'Type','Patch','-or','Type','Line');

for idx =1:length(graphics)
    fprintf('Actualizing trace %d (%s)... ',idx,graphics(idx).UserData.UserData.Name);
    switch graphics(idx).Tag
        case 'Pixel'
            pt_cp(1,1) = graphics(idx).XData;
            pt_cp(1,2) = graphics(idx).YData;
            %graphics(idx).UserData.YData(~isnan(graphics(idx).UserData.YData)) = IM(pt_cp(1,2),pt_cp(1,1),:);
            %graphics(idx).UserData.YData(1:end-1) = IM(pt_cp(1,2),pt_cp(1,1),:);
            y = IM(pt_cp(1,2),pt_cp(1,1),:);
            y = squeeze(y);
        
        case 'Box'
            reg_y = graphics(idx).XData;
            reg_x = graphics(idx).YData;
            i = min(reg_x(1),reg_x(2));
            j = min(reg_y(3),reg_y(2));
            I = max(reg_x(1),reg_x(2));
            J = max(reg_y(3),reg_y(2));
            %graphics(idx).UserData.YData(~isnan(graphics(idx).UserData.YData)) = mean(mean(IM(i:I,j:J,:),2,'omitnan'),1,'omitnan');
            %graphics(idx).UserData.YData(1:end-1) = mean(mean(IM(i:I,j:J,:),2,'omitnan'),1,'omitnan');
            y = mean(mean(IM(i:I,j:J,:),2,'omitnan'),1,'omitnan');
            y = squeeze(y);
            
        case 'Region'
            im_mask = graphics(idx).UserData.UserData.Mask;
            im_mask(im_mask==0)=NaN;
            im_mask = IM.*repmat(im_mask,1,1,size(IM,3));
            %graphics(idx).UserData.YData(~isnan(graphics(idx).UserData.YData)) = mean(mean(im_mask,2,'omitnan'),1,'omitnan');
            %graphics(idx).UserData.YData(1:end-1) = mean(mean(im_mask,2,'omitnan'),1,'omitnan');
            y = mean(mean(im_mask,2,'omitnan'),1,'omitnan');
            y = squeeze(y);
    end
    
    % Gaussian smoothing
    if t_gauss>0
        fprintf(' Smoothing constant (%.1f s)... ',t_gauss);
        %graphics(idx).UserData.YData(1:end-1) = squeeze(imgaussfilt(y,round(t_gauss/delta),'FilterDomain','spatial'));
        
        if strcmp(rec_mode,'BURST')
            % gaussian nan convolution + nan padding (only for burst_recording)
            try
                length_burst = 59;
                n_burst = length(y)/length_burst;
                y_reshape = [reshape(squeeze(y),[length_burst,n_burst]);NaN(length(w),n_burst)];
            catch
                length_burst = 1181;
                n_burst = length(y)/length_burst;
                y_reshape = [reshape(squeeze(y),[length_burst,n_burst]);NaN(length(w),n_burst)];
            end
            y_conv = nanconv(y_reshape(:),w,'same');
            y_reshaped = reshape(y_conv,[length_burst+length(w),n_burst]);
            y_final = reshape(y_reshaped(1:length_burst,:),[length_burst*n_burst,1]);
            graphics(idx).UserData.YData(1:end-1) = y_final;
        else
            graphics(idx).UserData.YData(1:end-1) = nanconv(y,w,'same');
        end

    else
        graphics(idx).UserData.YData(1:end-1)= y;
    end
    fprintf('done.\n');
    
end

end