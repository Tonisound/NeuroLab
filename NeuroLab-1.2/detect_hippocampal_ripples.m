function success = detect_hippocampal_ripples(savedir,dir_dat,val,str_group)
% Detect Hippocampal Ripples Script based on Kteam/PrgMatlab
% Two methods sqrt & abs
% Generates events files Ripples-Abs|Sqrt|Merged-All.csv'
% Uses ripple and noise channel in NConfig.mat (required)
% Enables time group selection

% Should now work stand-alone (no addpath needed)
% all necessary functions copied in Neurolab/wrappers
% tsd toolbox
% Function FindRipples_abs and FindRipples_sqrt

success  = false;

if nargin<4
    str_group = [];
end

global DIR_SAVE ;
cur_file = strrep(savedir,DIR_SAVE,'');
cur_file = strrep(cur_file,filesep,'');

% Loading Time Groups
if exist(fullfile(savedir,'Time_Groups.mat'),'file')
    data_tg = load(fullfile(savedir,'Time_Groups.mat'));
    fprintf('Time Groups loaded [%s].\n',fullfile(savedir,'Time_Groups.mat'));
    list_groups = data_tg.TimeGroups_name;
else
    warning('Missing File Time Groups [%s]',savedir);
    return;
end

% Channel Selection
if exist(fullfile(savedir,'Nconfig.mat'),'file')
    d_ncf = load(fullfile(savedir,'Nconfig.mat'));
    
    % Channel ripple
    if ~isfield(d_ncf,'channel_ripple') || isempty(d_ncf.channel_ripple)
        warning('Channel ripple not defined in NConfig.mat [%s].',savedir);
        return;
    else
        channel_ripple = d_ncf.channel_ripple;
    end
    
    % Channel noise
    if ~isfield(d_ncf,'channel_noise') || isempty(d_ncf.channel_noise)
        warning('Channel Noise not defined in NConfig.mat [%s].',savedir);
        return;
    else
        channel_noise = d_ncf.channel_noise;
    end

%     % User Input Channel selection
%     d_lfp = dir(fullfile(savedir,'Sources_LFP','LFP_*.mat'));
%     % If NConfig file exists, keep electrode order
%     if ~isempty(d_ncf)
%         lfp_ordered = d_ncf.channel_list(contains(d_ncf.channel_list,'LFP'));
%         lfp_str = regexprep(lfp_ordered,'/','_');
%     else
%         lfp_str = regexprep({d_lfp(:).name}','.mat','');
%     end
%     % Initial selection
%     if nargin < 4
%         ind_initial = 1;
%     else
%         ind_initial = find(strcmp(lfp_str,['LFP_',channel_ripple])==1);
%         if isempty(ind_initial)
%             ind_initial = 1;
%         end
%     end
%     [ind_lfp,v] = listdlg('Name','Channel Selection','PromptString','Select LFP channnel for ripple detection',...
%         'SelectionMode','single','ListString',lfp_str,'InitialValue',ind_initial,'ListSize',[300 500]);
%     if v==0
%         return;
%     end
%     channel_ripple = char(strrep(lfp_str(ind_lfp),'LFP_',''));
    
else
    warning('Missing File NConfig.mat [%s].',savedir);
    return;
end

if val == 1
    
    % user mode
    ind_initial = [find(strcmp(list_groups,'QW'));find(strcmp(list_groups,'NREM'))];
    [ind_time_groups,ok] = listdlg('PromptString','Select Time Groups for Detection','SelectionMode','multiple',...
        'ListString',list_groups,'InitialValue',ind_initial,'ListSize',[400 500]);
    if ok==0 || isempty(ind_time_groups)
        return;
    end
    
else
    % batch mode
    ind_time_groups = [];
    for i=1:length(str_group)
        ind_keep = find(strcmp(list_groups,char(str_group(i))));
        ind_time_groups = [ind_time_groups;ind_keep];
    end
end
all_time_groups = list_groups(ind_time_groups);


% Sanity Check
if isempty(all_time_groups)
    warning('Time Group Selection is empty [%s].',savedir);
    return;
end


% Loading traces and interpolate
if exist(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_ripple)),'file')
    data_lfp = load(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_ripple)));
    fprintf('LFP file loaded [%s].\n',fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_ripple)));
else
    warning('Channel not found [%s-%s]',savedir,channel_ripple);
    return;
end
X = (data_lfp.x_start:1/1250:data_lfp.x_end)';
Y = interp1((data_lfp.x_start:data_lfp.f:data_lfp.x_end)',data_lfp.Y,X,'spline');


% Loading noise and interpolate
if exist(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_noise)),'file')
    data_noise = load(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_noise)));
    Ynoise = interp1((data_noise.x_start:data_noise.f:data_noise.x_end)',data_noise.Y,X,'spline');
    fprintf('Noise channel loaded [%s].\n',fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_noise)));
else
    warning('Channel not found [%s-%s]',savedir,channel_noise);
%     Ynoise = zeros(size(Y));
    return;
end


% Making tsd objects
HPCrip = tsd(X*1e4,Y);
HPCnonRip = tsd(X*1e4,Ynoise);

% params
Info.hemisphere = '';
Info.scoring = '';
Info.threshold = [4 6;2 5];
Info.durations = [15 20 200];
Info.frequency_band = [120 250];
Info.EventFileName = ['swr' Info.hemisphere];
stim = 0;
clean = 1;


for i = 1:length(all_time_groups)
    
    cur_timegroup = char(all_time_groups(i));
    cur_index = find(strcmp(list_groups,cur_timegroup)==1);
    
    % Getting timegroup_duration
    S = data_tg.TimeGroups_S(cur_index);
    temp = datenum(S.TimeTags_strings(:,1));
    t_start = (temp-floor(temp))*24*3600;
    temp = datenum(S.TimeTags_strings(:,2));
    t_end = (temp-floor(temp))*24*3600;
    timegroup_duration = sum((t_end-t_start));   
    
    % Loading time indexes
    ind_nrem = find(strcmp(data_tg.TimeGroups_name,cur_timegroup)==1);
    tts1 = data_tg.TimeGroups_S(ind_nrem).TimeTags_strings(:,1);
    tts2 = data_tg.TimeGroups_S(ind_nrem).TimeTags_strings(:,2);
    temp1=datenum(tts1);
    temp2=datenum(tts2);
    t1=24*3600*(temp1-floor(temp1));
    t2=24*3600*(temp2-floor(temp2));

    
    % Epoch definition
    SWSEpoch = intervalSet(t1*1e4,t2*1e4);
    TotalNoiseEpoch = intervalSet([],[]);
   
    
    % Ripple detection abs
    fprintf('================ Ripple Event Detection using absolute value ================\n');
%     [ripples_abs, meanVal, stdVal] = FindRipples_abs(HPCrip, HPCnonRip, SWSEpoch, TotalNoiseEpoch,...
%         'frequency_band',Info.frequency_band, ...
%         'threshold',Info.threshold(1,:),...
%         'durations',Info.durations,...
%         'stim',stim);
    Info.Epoch = SWSEpoch-TotalNoiseEpoch;
    Info.Restrict = SWSEpoch;
    [ripples_abs, meanVal, stdVal] = FindRipples_abs(HPCrip, HPCnonRip, ...
        Info.Epoch, Info.Restrict,'frequency_band',Info.frequency_band, ...
        'threshold',Info.threshold(1,:),'durations',Info.durations,'stim',stim);
    % Removing NaN
    ripples_abs = ripples_abs(~isnan(ripples_abs(:,1)),:);
    density_events_abs = size(ripples_abs,1)/timegroup_duration;
    fprintf('================ Found %d events with ripple rate %.3f Hz ================\n',size(ripples_abs,1),density_events_abs);
    
    
    % Ripple detection sqrt
    fprintf('================ Ripple Event Detection using square root ================\n');
    % Get longest epoch of sws start and stop times (for zug)
    [~,idx]=max(End(Info.Restrict)-Start(Info.Restrict));
    if isempty(idx)
        restrict=0;
    else
        tsws(1) = Start(subset(Info.Restrict,idx))/1e4;
        tsws(2) = End(subset(Info.Restrict,idx))/1e4;
    end

    [ripples_sqrt,stdev] = FindRipples_sqrt(HPCrip, HPCnonRip, Info.Epoch, Info.threshold(2,:), ...
        'clean',clean,'restrict',tsws);
    % Removing NaN
    ripples_sqrt = ripples_sqrt(~isnan(ripples_sqrt(:,1)),:);
    
    density_events_sqrt = size(ripples_sqrt,1)/timegroup_duration;
    fprintf('================ Found %d events with ripple rate %.3f Hz ================\n',size(ripples_sqrt,1),density_events_sqrt);
    
    
    % Ripple merge
    fprintf('================ Merging Ripple absolute value and square root  ================\n');
    ripples = MergeRipples(ripples_abs,ripples_sqrt,HPCrip);
    % Removing NaN
    ripples = ripples(~isnan(ripples(:,1)),:);
    
    density_events = size(ripples,1)/timegroup_duration;
    fprintf('================ Found %d events with ripple rate %.3f Hz ================\n',size(ripples,1),density_events);
    
   
    % Saving in csv format
    folder_events = fullfile(savedir,'Events');
    if ~isfolder(folder_events)
        mkdir(folder_events);
    end
    
    % Metadata and Header
    EventHeader = {'Start(s)';'Peak(s)';'End(s)';'MeanDur(us)';'MeanFreq(Hz)';'MeanPeaktoPeak(uV)'};
    MetaData =    {sprintf('file,%s',cur_file);...
        sprintf('channel_ripple,%s',channel_ripple);...
        sprintf('channel_noise,%s',channel_noise);...
        sprintf('timegroup_name,%s',cur_timegroup);
        sprintf('timegroup_duration(s),%.2f',timegroup_duration);
        sprintf('density_events(Hz),%.3f',density_events)};
    MetaDataAbs =    {sprintf('file,%s',cur_file);...
        sprintf('channel_ripple,%s',channel_ripple);...
        sprintf('channel_noise,%s',channel_noise);...
        sprintf('timegroup_name,%s',cur_timegroup);
        sprintf('timegroup_duration(s),%.2f',timegroup_duration);
        sprintf('density_events(Hz),%.3f',density_events_abs)};
    MetaDataSqrt =    {sprintf('file,%s',cur_file);...
        sprintf('channel_ripple,%s',channel_ripple);...
        sprintf('channel_noise,%s',channel_noise);...
        sprintf('timegroup_name,%s',cur_timegroup);
        sprintf('timegroup_duration(s),%.2f',timegroup_duration);
        sprintf('density_events(Hz),%.3f',density_events_sqrt)};
    
%     % Writing Abs Ripples
%     output_file = fullfile(folder_events,sprintf('[%s]Ripples-Abs-All.csv',cur_timegroup));
%     write_csv_events(output_file,ripples_abs,EventHeader,MetaDataAbs);
%     % Writing Sqrt Ripples
%     output_file = fullfile(folder_events,sprintf('[%s]Ripples-Sqrt-All.csv',cur_timegroup));
%     write_csv_events(output_file,ripples_sqrt,EventHeader,MetaDataSqrt);
    % Writing Merged Ripples
    output_file = fullfile(folder_events,sprintf('[%s]Ripples-Merged-All.csv',cur_timegroup));
    write_csv_events(output_file,ripples,EventHeader,MetaData);
    
    
    % Saving in separate folder
    folder_separate = fullfile(folder_events,channel_ripple);
    if ~isfolder(folder_separate)
        mkdir(folder_separate);
    end
    output_file = fullfile(folder_separate,sprintf('[%s][%s-%s]Ripples-Merged-All.csv',cur_timegroup,channel_ripple,channel_noise));
    write_csv_events(output_file,ripples,EventHeader,MetaData); 
    output_file = fullfile(folder_separate,sprintf('[%s][%s-%s]Ripples-Abs-All.csv',cur_timegroup,channel_ripple,channel_noise));
    write_csv_events(output_file,ripples_abs,EventHeader,MetaDataAbs);
    output_file = fullfile(folder_separate,sprintf('[%s][%s-%s]Ripples-Sqrt-All.csv',cur_timegroup,channel_ripple,channel_noise));
    write_csv_events(output_file,ripples_sqrt,EventHeader,MetaDataSqrt);
    
    
    % Save evt file
    if ~isempty(dir_dat)
        evt_filename = sprintf('[%s-%s][%s]swr-merged.evt.swr',channel_ripple,channel_noise,cur_timegroup);
        file_ID = fopen(fullfile(dir_dat,evt_filename),'w');
        for ii = 1:size(ripples,1)
            fprintf(file_ID,'%f\t%s\n',ripples(ii,1)*1000,'Ripple start 0'); % Convert to milliseconds
            fprintf(file_ID,'%f\t%s\n',ripples(ii,2)*1000,'Ripple peak 0'); % Convert to milliseconds
            fprintf(file_ID,'%f\t%s\n',ripples(ii,3)*1000,'Ripple stop 0'); % Convert to milliseconds
        end
        fclose(file_ID);
        fprintf('Event File saved [%s].\n',fullfile(dir_dat,evt_filename));
    end
    
end

success  = true;

end


function ripples = MergeRipples(ripples_abs,ripples_sqrt,HPCrip)

% Merge ripples
if ~isempty(ripples_sqrt)
    id{1}=[];id{2}=[];id{3}=[];
    ripabs = intervalSet(ripples_abs(:,1)*1E4, ripples_abs(:,3)*1E4);
    ripabs_tsd = Restrict(HPCrip,ripabs);
    for ii=1:size(ripples_sqrt,1)
        ripsqrt_ts = intervalSet(ripples_sqrt(ii,1)*1E4,ripples_sqrt(ii,3)*1E4);
        in = inInterval(ripsqrt_ts,ripabs_tsd);
        if sum(Data(in))
            id{1}(end+1)=ii;
        else
            id{2}(end+1)=ii;
        end
        clear in;
    end
    % get abs-detected only
    ripsqrt = intervalSet(ripples_sqrt(:,1)*1E4, ripples_sqrt(:,3)*1E4);
    ripsqrt_tsd = Restrict(HPCrip,ripsqrt);
    for ii=1:size(ripples_abs,1)
        ripabs_ts = intervalSet(ripples_abs(ii,1)*1E4,ripples_abs(ii,3)*1E4);
        in = inInterval(ripabs_ts,ripsqrt_tsd);
        if ~sum(Data(in))
            id{3}(end+1)=ii;
        end
    end
    
    ripples_tmp = [ripples_sqrt([id{1}'; id{2}'],:); ripples_abs(id{3}',:)];
    % sorting events by start time
    [~,idx] = sort(ripples_tmp(:,1)); % sort just the first column
    ripples = ripples_tmp(idx,:);   % sort the whole matrix using the sort indices
    
else
    ripples=ripples_abs;
end

end
