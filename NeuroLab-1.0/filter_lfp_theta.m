function success = filter_lfp_theta(foldername,handles)
% Manual pass-band filtering - Filter LFP for theta
% Searches Trace_Cerep for LFP traces, compute and load LFP-theta

success = false;

load('Preferences.mat','GFilt');
theta_inf = GFilt.theta_inf;
theta_sup = GFilt.theta_sup;

% Time Reference loading
if exist(fullfile(foldername,'Time_Reference.mat'),'file')
    data_t = load(fullfile(foldername,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
else
    errordlg(sprintf('Missing File %s',fullfile(foldername,'Time_Reference.mat')));
    return;
end

% Saving struct
traces = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
        'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});

dir_t = dir(fullfile(foldername,'Traces_Cerep','LFP_*.mat'));
if isempty(dir_t)
    errordlg(sprintf('No LFP traces found in %s',foldername));
else
    channel_list = {dir_t(:).name}';
    
    for i =1:length(channel_list)
        str_channel = char(channel_list(i));
        data  = load(fullfile(foldername,'Traces_Cerep',str_channel));
        Y = data.Y;
        X = (data.x_start:data.f:data.x_end)';
        
        % Pass-band filtering
        f1 = theta_inf;
        f2 = theta_sup;
        fs = 1/data.f;
        fprintf('Filtering LFP for theta %s...',str_channel);
        [B,A]  = butter(1,[f1 f2]/(fs/2),'bandpass');
        Y_temp = filtfilt(B,A,Y);
        %Y_temp = bandpass(Y,[f1,f2],fs);
        
        % Subsampling
        ftemp = 10*f2;
        X_theta = (X(1):1/ftemp:X(end))';
        Y_theta = interp1(X,Y_temp,X_theta);
        fprintf(' done;\n');
        
        % Saving
        temp = regexp(strrep(str_channel,'.mat',''),'_','split');
        %traces(i).ID = sprintf('%d',eval(char(temp(2))));
        traces(i).ID = char(temp(2));
        
        traces(i).shortname = 'LFP-theta';
        traces(i).parent = 'Cereplex-Traces';
        traces(i).fullname = strcat(traces(i).shortname,'/',traces(i).ID);
        traces(i).X = X_theta;
        traces(i).Y = Y_theta;
        traces(i).X_ind = data_t.time_ref.X;
        traces(i).X_im = data_t.time_ref.Y;
        traces(i).Y_im = interp1(traces(i).X,traces(i).Y,traces(i).X_im);
        traces(i).nb_samples = length(Y_theta);
        %fprintf('Succesful Importation %s [Parent %s].\n',traces(i).fullname,traces(i).parent);
    end
end

% Save dans SpikoscopeTraces.mat
MetaData = [];
if ~isempty(traces)
    save(fullfile(foldername,'Cereplex_Traces.mat'),'traces','MetaData','-v7.3');
end
fprintf('===> Saved at %s.mat\n',fullfile(foldername,'Cereplex_Traces.mat'));

success = true;

end