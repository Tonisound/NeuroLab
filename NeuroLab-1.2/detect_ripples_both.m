function success = detect_ripples_both(savedir,dir_dat,val,str_group)
% Detect Hippocampal Ripples Script based on Kteam/PrgMatlab
% Two methods sqrt & abs
% Generates events files Ripples-Abs|Sqrt|Merged-All.csv'
% Uses ripple and noise channel in NConfig.mat (required)
% Enables time group selection

% Should now work stand-alone (no addpath needed)
% all necessary functions copied in Neurolab/wrappers

% Addpath
% addpath(genpath('/home/hobbes/Dropbox/Kteam/PrgMatlab/'));

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
    
    
    % Create folders :
    if isfolder('ChannelsToAnalyse')
        rmdir('ChannelsToAnalyse','s');
    end
    mkdir('ChannelsToAnalyse');
    
    if isfolder('LFPData')
        rmdir('LFPData','s');
    end
    mkdir('LFPData');
    
    if isfolder('Ripples')
        rmdir('Ripples','s');
    end
    
    if isfile('behavResources.mat')
        delete('behavResources.mat');
    end
    if isfile('StateEpochSB.mat')
        delete('StateEpochSB.mat');
    end
    if isfile('SWR.mat')
        delete('SWR.mat');
    end
    
    % LFP Data
    % LFPrip = tsd(X*1e4,Y);
    LFP = tsd(X*1e4,Y);
    save('LFPData/LFP0.mat','LFP') % rip chan
    % LFPnonRip = tsd(X*1e4,zeros(size(Y)));
    % LFP = tsd(X*1e4,zeros(size(Y)));
    LFP = tsd(X*1e4,Ynoise);
    save('LFPData/LFP1.mat','LFP') % non rip chan
    
    % Epoch definition
    SWSEpoch = intervalSet(t1*1e4,t2*1e4);
    TotalNoiseEpoch = intervalSet([],[]);
    Wake = intervalSet([],[]);
    % Epoch = intervalSet(0,max(Range(LFP)));
    Epoch = SWSEpoch;
    
    save('StateEpochSB.mat','TotalNoiseEpoch','SWSEpoch','Epoch','Wake')
    
    % Channels to analyse
    channel=0;
    save('ChannelsToAnalyse/dHPC_rip.mat','channel')
    channel=1;
    save('ChannelsToAnalyse/nonRip.mat','channel')
    
    
    % behavResources
    TTLInfo = intervalSet([],[]);
    save('behavResources.mat','TTLInfo')
    
    % CreateRipplesSleep
    [ripples,ripples_abs,ripples_sqrt] = CreateRipplesSleep_AB();
    density_events = size(ripples,1)/timegroup_duration;
    density_events_abs = size(ripples_abs,1)/timegroup_duration;
    density_events_sqrt = size(ripples_sqrt,1)/timegroup_duration;
    
    % % Saving in csv format
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
    
    % % Writing Abs Ripples
    % output_file = fullfile(folder_events,'Ripples-Abs-All.csv');
    % write_csv_events(output_file,ripples_abs,EventHeader,MetaData);
    % % Writing Sqrt Ripples
    % output_file = fullfile(folder_events,'Ripples-Sqrt-All.csv');
    % write_csv_events(output_file,ripples_sqrt,EventHeader,MetaData);
    
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
    
    
    % Delete folders
    rmdir('ChannelsToAnalyse','s');
    rmdir('LFPData','s');
    rmdir('Ripples','s');
    delete('behavResources.mat');
    delete('StateEpochSB.mat');
    delete('Rippleraw.png');
    delete('SWR.mat');
    
    
    % Move or Delete evt file
    if ~isempty(dir_dat)
        evt_filename = sprintf('[%s][%s-%s]swr-merged.evt.swr',cur_timegroup,channel_ripple,channel_noise);
        movefile('swr.evt.swr',fullfile(dir_dat,evt_filename));
        fprintf('Event File saved [%s].\n',fullfile(dir_dat,evt_filename));
    else
        delete('swr.evt.swr');
        warning('Dat Directory empty. Event file deleted.');
    end
end

success  = true;

end
