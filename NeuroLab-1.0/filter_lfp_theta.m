function filter_lfp_theta(foldername,handles)
% Manual pass-band filtering - Filter LFP for theta
% Searches Trace_Cerep for LFP traces, compute and load LFP-theta

load('Preferences.mat','GFilt');
theta_inf = GFilt.theta_inf;
theta_sup = GFilt.theta_sup;

traces = dir(fullfile(foldername,'Traces_Cerep','LFP_*.mat'));
if isempty(traces)
    errordlg(sprintf('No LFP traces found in %s',foldername));
else
    traces_name = {traces(:).name}';
    for i =1:length(traces_name)
        data  = load(fullfile(foldername,'Traces_Cerep',char(traces_name(i))));
        Y = data.Y;
        X = (data.x_start:data.f:data.x_end)';
        
        % Pass-band filtering
        f1 = theta_inf;
        f2 = theta_sup;
        fs = data.f;
        fprintf('Filtering LFP for theta %s...',char(traces_name(i)));
        [B,A]  = butter(1,[f1 f2]/(fs/2),'bandpass');
        Y_temp = filtfilt(B,A,Y);
        %Y_temp = bandpass(Y,[f1,f2],fs);
        fprintf(' done;\n');
    end
end

end