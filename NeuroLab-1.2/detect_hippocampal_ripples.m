function success = detect_hippocampal_ripples(savedir,dir_dat,val,channel_ripple,timegroup)
% Dec 2023 - Function Detect Hippocampal Ripples 
% based on Kteam/PrgMatlab but re-written to work in NeuroLab

% Two methods sqrt & abs
% Generates events files Ripples-Abs|Sqrt|Merged-All.csv'

% Required packages: 

success  = false;

if exist(fullfile(savedir,'Nconfig.mat'),'file')
    data_nconfig = load(fullfile(savedir,'Nconfig.mat'));
else
    data_nconfig = [];
end

if val == 1
    % user mode
    if nargin < 5
        timegroup = 'NREM';
    end    
    if nargin < 4
        d_lfp = dir(fullfile(savedir,'Sources_LFP','LFP_*.mat'));
        % If NConfig file exists, keep electrode order
        if ~isempty(data_nconfig)
            lfp_ordered = data_nconfig.channel_list(contains(data_nconfig.channel_list,'LFP'));
            lfp_str = regexprep(lfp_ordered,'/','_');
        else
            lfp_str = regexprep({d_lfp(:).name}','.mat','');
        end
        [ind_lfp,v] = listdlg('Name','Channel Selection','PromptString','Select LFP channnel for ripple detection',...
            'SelectionMode','single','ListString',lfp_str,'InitialValue',1,'ListSize',[300 500]);
        if v==0
            return;
        end
        channel_ripple = char(strrep(lfp_str(ind_lfp),'LFP_',''));
    end
    
else
    % batch mode
    if nargin < 5
        timegroup = 'NREM';
    end
    if nargin < 4
        channel_ripple = '023';
    end
end

% Loading traces and interpolate
if exist(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_ripple)),'file')
    data_lfp = load(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_ripple)));
    fprintf('LFP file loaded [%s].\n',fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_ripple)));
else
    warning('Channel not found [%s-%s]',savedir,channel_ripple);
    return;
end

% Loading noise and interpolate
channel_noise = '000';
if exist(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_noise)),'file')
    data_noise = load(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_noise)));
    fprintf('Noise channel loaded [%s].\n',fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_noise)));
else
    warning('Channel not found [%s-%s]',savedir,channel_noise);
    return;
end

% Interpolate
Xq= (data_lfp.x_start:1/1250:data_lfp.x_end)';
Y = interp1((data_lfp.x_start:data_lfp.f:data_lfp.x_end)',data_lfp.Y,Xq,'spline');
Ynoise = interp1((data_noise.x_start:data_noise.f:data_noise.x_end)',data_noise.Y,Xq,'spline');

% Making tsd objects
% LFPrip = tsd(X*1e4,Y);
HPCrip = tsd(Xq*1e4,Y);
% LFPnonRip = tsd(X*1e4,zeros(size(Y)));
HPCnonRip = tsd(Xq*1e4,Ynoise);


% Loading time groups
if exist(fullfile(savedir,'Time_Groups.mat'),'file')
    data_tg = load(fullfile(savedir,'Time_Groups.mat'));
    fprintf('Time Groups loaded [%s].\n',fullfile(savedir,'Time_Groups.mat'));
else
    warning('Time Groups not found [%s-%s]',savedir,channel_ripple);
    return;
end
ind_nrem = find(strcmp(data_tg.TimeGroups_name,timegroup)==1);
tts1 = data_tg.TimeGroups_S(ind_nrem).TimeTags_strings(:,1);
tts2 = data_tg.TimeGroups_S(ind_nrem).TimeTags_strings(:,2);
temp1=datenum(tts1);
temp2=datenum(tts2);
t1=24*3600*(temp1-floor(temp1));
t2=24*3600*(temp2-floor(temp2));

% trash_soon
% Epoch definition
SWSEpoch = intervalSet(t1*1e4,t2*1e4);
TotalNoiseEpoch = intervalSet([],[]);
% Wake = intervalSet([],[]);

% params
Info.hemisphere = '';
Info.scoring = '';
Info.threshold = [4 6;2 5];
Info.durations = [15 20 200];
Info.frequency_band = [120 250];
Info.EventFileName = ['swr' Info.hemisphere];
stim = 0;
clean = 1;


[ripples_abs, meanVal, stdVal] = FindRipples_abs(HPCrip, HPCnonRip, SWSEpoch, TotalNoiseEpoch,...
    'frequency_band',Info.frequency_band, ...
    'threshold',Info.threshold(1,:),...
    'durations',Info.durations,...
    'stim',stim);

[ripples_sqrt,stdev] = FindRipples_sqrt(HPCrip, HPCnonRip, SWSEpoch, Info.threshold(2,:));


% % Saving in csv format
folder_events = fullfile(savedir,'Events');
if ~isfolder(folder_events)
    mkdir(folder_events);
end

% Metadata and Header
EventHeader = {'Start(s)';'Peak(s)';'End(s)';'MeanDur(us)';'MeanFreq(Hz)';'MeanPeaktoPeak(uV)'};
MetaData =    {sprintf('channel_ripple,%s',channel_ripple);...
    sprintf('channel_non_ripple,%s',channel_noise);...
    sprintf('timegroup,%s',timegroup)};

% Writing Abs Ripples
output_file = fullfile(folder_events,'Ripples-Abs-All.csv');
write_csv_events(output_file,ripples_abs,EventHeader,MetaData);
% Writing Sqrt Ripples
output_file = fullfile(folder_events,'Ripples-Sqrt-All.csv');
write_csv_events(output_file,ripples_sqrt,EventHeader,MetaData);
% % Writing Merged Ripples
% output_file = fullfile(folder_events,'Ripples-Merged-All.csv');
% write_csv_events(output_file,ripples,EventHeader,MetaData);


% Saving in separate folder
% Comment if unnecessary
global DIR_SAVE DIR_STATS;
% folder_separate = fullfile(DIR_STATS,'Separate-Ripple-Detection');
folder_separate = fullfile(folder_events,channel_ripple);
if ~isfolder(folder_separate)
    mkdir(folder_separate);
end
cur_file = strrep(savedir,DIR_SAVE,'');
cur_file = strrep(cur_file,filesep,'');
% output_file = fullfile(folder_separate,sprintf('[%s][%s]Ripples-Merged-All.csv',cur_file,channel_ripple));
% write_csv_events(output_file,ripples,EventHeader,MetaData);
output_file = fullfile(folder_separate,sprintf('[%s][%s]Ripples-Abs-All.csv',cur_file,channel_ripple));
write_csv_events(output_file,ripples_abs,EventHeader,MetaData);
output_file = fullfile(folder_separate,sprintf('[%s][%s]Ripples-Sqrt-All.csv',cur_file,channel_ripple));
write_csv_events(output_file,ripples_sqrt,EventHeader,MetaData);


% % Move or Delete evt file
% if isfolder(dir_dat)
%     evt_filename = sprintf('[%s][%s]swr-merged.evt.swr',cur_file,channel_ripple);
%     movefile('swr.evt.swr',fullfile(dir_dat,evt_filename));
% else
%     delete('swr.evt.swr');
%     warning('Event file deleted: Dat Directory empty [%s]',dir_dat);
% end

success  = true;

end
