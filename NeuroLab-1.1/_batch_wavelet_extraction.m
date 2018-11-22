function batch_wavelet_extraction 
% Detects and isolate Wavelet Spectrogramm for all elements files
% between start and end of each episode

global DIR_SYNT DIR_STATS DIR_SAVE  FILES;
dir_name = fullfile(DIR_SYNT,'Wavelet_Extraction','REM');
files = FILES;

% Create Synthesis Directory
if isdir(dir_name)
    rmdir(dir_name,'s');
end
mkdir(dir_name);

for i=1:length(files)
    
    % Loading Episodes
    % Works with any time array
    
%     t_episode = load(fullfile(DIR_SAVE,files(i).gfus,'Time_Surges.mat'));
%     episode_strings = t_episode.T_whole_strings;
%     episode_name = cell(size(episode_strings,1),1);
%     for ii=1:size(episode_strings,1)
%         episode_name(ii) = {sprintf('Surge-%.2d',ii)};
%     end
    
    t_episode = load(fullfile(DIR_SAVE,files(i).gfus,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_S');
    ind = find(~cellfun('isempty',strfind(t_episode.TimeGroups_name,'REM'))==1);
    episode_strings = t_episode.TimeGroups_S(ind).TimeTags_strings;
    episode_name = t_episode.TimeGroups_S(ind).Name;
    
    temp = datenum(episode_strings(:,1));
    t_start = (temp-floor(temp))*24*3600+.1;
    temp = datenum(episode_strings(:,2));
    t_end = (temp-floor(temp))*24*3600-.1;
    
    % Loading corresponding Wavelet data
    folder_wav = fullfile(DIR_STATS,'Wavelet_Analysis',files(i).eeg);
    d = dir(fullfile(folder_wav,'LFP*.mat'));
    
    % Counting channels and episodes
    all_traces = [];
    %all_tags = [];
    for k = 1:length(d)
        filename= fullfile(folder_wav,d(k).name);
        data = load(filename,'trace_name','Tag_Selection');
        all_traces = [all_traces; data.trace_name];
        %all_tags = [all_tags; {data.Tag_Selection}];
        
    end
    all_traces = unique(all_traces);
    %all_tags = unique(all_tags);
    
    % Initialization
    S  = struct('trace_name',[],'Cdata_sub',[],'Xdata_sub',[],'Cdata_phase_ascend',[],'Cdata_phase_descend',[],'X_trace',[],'Y_trace',[],'X_phase',[],'Y_phase',[]);
    S(size(episode_strings,1),length(all_traces)).trace_name = [];  
    
    % Looping on files
    for k = 1:length(d)
        
        filename= fullfile(folder_wav,d(k).name);
        fprintf('Extracting Wavelet data (File : %s)...',d(k).name);
        data_t = load(filename,'x_end','x_start','f_sub');
        x_end = data_t.x_end;
        x_start = data_t.x_start;         
        
        % Looping on episode timing
        % If one episode matches - load
        ind_keep = zeros(size(episode_strings,1),1);
        for j =1:size(episode_strings,1)
            % Testing if t_start and t_end \in [x_start;x_end]
            if (t_start(j)-x_start)*(t_start(j)-x_end) <=0 && (t_end(j)-x_start)*(t_end(j)-x_end)<=0
                ind_keep(j)=1;
            end
        end
        
        if sum(ind_keep)>0
            data_C = load(filename,'Cdata_sub','Xdata_sub','X_phase','X_trace','Y_phase','Y_trace','trace_name','Tag_Selection','freqdom','bins','delta_d');
            trace_name = data_C.trace_name;
            Tag_Selection = data_C.Tag_Selection;
            
            index_trace = find(strcmp(all_traces,trace_name)==1);
            for jj =1:size(episode_strings,1)
                if ind_keep(jj)==1
                    % name
                    S(jj,index_trace).trace_name = trace_name;
                    S(jj,index_trace).freqdom = data_C.freqdom;
                    S(jj,index_trace).bins = data_C.bins;
                    S(jj,index_trace).delta_d = data_C.delta_d;
                    %S(jj,index_trace).Tag_Selection = Tag_Selection;
                    
                    %cdata_sub
                    [~,ind_1] = min((data_C.Xdata_sub-t_start(jj)).^2);
                    [~,ind_2] = min((data_C.Xdata_sub-t_end(jj)).^2);
                    Cdata_sub = data_C.Cdata_sub(:,ind_1:ind_2);
                    Xdata_sub = data_C.Xdata_sub(ind_1:ind_2);
                    S(jj,index_trace).Cdata_sub = Cdata_sub;
                    S(jj,index_trace).Xdata_sub = Xdata_sub;
                    %x_trace
                    [~,ind_1] = min((data_C.X_trace-t_start(jj)).^2);
                    [~,ind_2] = min((data_C.X_trace-t_end(jj)).^2);
                    X_trace = data_C.X_trace(ind_1:ind_2);
                    Y_trace = data_C.Y_trace(ind_1:ind_2);
                    S(jj,index_trace).X_trace = X_trace;
                    S(jj,index_trace).Y_trace = Y_trace;   
                    %x_phase
                    [~,ind_1] = min((data_C.X_phase-t_start(jj)).^2);
                    [~,ind_2] = min((data_C.X_phase-t_end(jj)).^2);
                    X_phase = data_C.X_phase(ind_1:ind_2);
                    Y_phase = data_C.Y_phase(ind_1:ind_2);
                    S(jj,index_trace).X_phase = X_phase;
                    S(jj,index_trace).Y_phase = Y_phase;
                    
                    % Computing phase spectrogram
                    [Cdata_phase_ascend,Cdata_phase_descend] = compute_phase_spectrogramm(Cdata_sub,Xdata_sub,X_phase,Y_phase,data_C.bins);
                    S(jj,index_trace).Cdata_phase_ascend = Cdata_phase_ascend;
                    S(jj,index_trace).Cdata_phase_descend = Cdata_phase_descend;
                    
                end
            end
        end
        fprintf(' done.\n');
    end
    
    % Loading corresponding traces
    folder_dis = fullfile(DIR_STATS,'Global_Episode_Display',files(i).eeg);
    d = dir(fullfile(folder_dis,'*WHOLE.mat'));
    T  = struct('ref_time',[],'Ydata',[]);
    T(size(episode_strings,1)).Ydata = [];
    labels = [];
    if ~isempty(d)
        filename= fullfile(folder_dis,d(1).name);
        fprintf('Extracting Trace data (File : %s)...',d(1).name);
        data_r = load(filename,'ref_time','Ydata','x_start','x_end','labels');
        labels = data_r.labels;
        
        for j =1:size(episode_strings,1)
            if (t_start(j)-data_r.x_start)*(t_start(j)-data_r.x_end) <=0 && (t_end(j)-data_r.x_start)*(t_end(j)-data_r.x_end)<=0
                [~,ind_1] = min((data_r.ref_time-t_start(j)).^2);
                [~,ind_2] = min((data_r.ref_time-t_end(j)).^2);
                T(j).Ydata = data_r.Ydata(:,ind_1:ind_2);
                T(j).ref_time = data_r.ref_time(ind_1:ind_2);
            end
        end
        fprintf(' done.\n');
    end
    
    % Saving
    for j =1:size(episode_strings,1)
        x_start = t_start(j);
        x_end = t_end(j);
        tag = char(Tag_Selection(1));
        name = char(episode_name(j));
        s  = S(j,:);
        ref_time = T(j).ref_time;
        Ydata = T(j).Ydata;
        parent = files(i).gfus;
        fprintf('Saving data (%s)...',sprintf('%s_%s.mat',files(i).eeg,name));
        save(fullfile(dir_name,sprintf('%s_%s.mat',files(i).eeg,name)),'x_start','x_end','tag','name','s','ref_time','labels','Ydata','parent');
        fprintf(' done.\n');
    end
    
    %save(fullfile(dir_name,sprintf('%s_Wavelet_Surges',files(i).eeg)),'S');
    %fprintf('==> Saving structure %s.\n',fullfile(dir_name,sprintf('%s_Wavelet_Surges',files(i).eeg)));
   
end

end

