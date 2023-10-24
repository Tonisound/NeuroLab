function success = detect_ripples_both(savedir,val,channel_ripple,timegroup)
% Detect Hippocampal Ripples Script based on Kteam/PrgMatlab
% Two methods sqrt & abs
% Generates events files Ripples-Abs|Sqrt|Merged-All.csv'

% Addpath
addpath(genpath('/home/hobbes/Dropbox/Kteam/PrgMatlab/'));

success  = false;

if exist(fullfile(savedir,'Nconfig.mat'),'file')
    data_nconfig = load(fullfile(savedir,'Nconfig.mat'));
else
    data_nconfig = [];
end

if val == 1
    % user mode
    if nargin < 4
        timegroup = 'NREM';
    end    
    if nargin < 3
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
    if nargin < 4
        timegroup = 'NREM';
    end
    if nargin < 3
        channel_ripple = '005';
    end
end


% Loading traces and intepolate
if exist(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_ripple)),'file')
    data_lfp = load(fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_ripple)));
    fprintf('LFP file loaded [%s].\n',fullfile(savedir,'Sources_LFP',sprintf('LFP_%s.mat',channel_ripple)));
else
    warning('Channel not found [%s-%s]',savedir,channel_ripple);
    return;
end
X=(data_lfp.x_start:data_lfp.f:data_lfp.x_end)';
Xq= (data_lfp.x_start:1/1250:data_lfp.x_end)';
Y=data_lfp.Y;
Yq = interp1(X,Y,Xq,'spline');
X = Xq;
Y = Yq;

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
LFP = tsd(X*1e4,zeros(size(Y)));
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
channel_non_ripple = [];

% % Saving in csv format
folder_events = fullfile(savedir,'Events');
if ~isfolder(folder_events)
    mkdir(folder_events);
end

% Metadata and Header
EventHeader = {'Start(s)';'Peak(s)';'End(s)';'MeanDur(us)';'MeanFreq(Hz)';'MeanPeaktoPeak(uV)'};
MetaData =    {sprintf('channel_ripple,%s',channel_ripple);...
    sprintf('channel_non_ripple,%s',channel_non_ripple);...
    sprintf('timegroup,%s',timegroup)};

% Writing Abs Ripples
output_file = fullfile(folder_events,'Ripples-Abs-All.csv');
write_csv_events(output_file,ripples_abs,EventHeader,MetaData);
% Writing Sqrt Ripples
output_file = fullfile(folder_events,'Ripples-Sqrt-All.csv');
write_csv_events(output_file,ripples_sqrt,EventHeader,MetaData);
% Writing Merged Ripples
output_file = fullfile(folder_events,'Ripples-Merged-All.csv');
write_csv_events(output_file,ripples,EventHeader,MetaData);


% Saving in separate folder
% Comment if unnecessary
global DIR_SAVE DIR_STATS;
folder_separate = fullfile(DIR_STATS,'Separate-Ripple-Detection');
if ~isfolder(folder_separate)
    mkdir(folder_separate);
end
cur_file = strrep(savedir,DIR_SAVE,'');
cur_file = strrep(cur_file,filesep,'');
output_file = fullfile(folder_separate,sprintf('[%][%]Ripples-Merged-All.csv',cur_file,channel_ripple));
write_csv_events(output_file,ripples,EventHeader,MetaData);
output_file = fullfile(folder_separate,sprintf('[%][%]Ripples-Abs-All.csv',cur_file,channel_ripple));
write_csv_events(output_file,ripples_abs,EventHeader,MetaData);
output_file = fullfile(folder_separate,sprintf('[%][%]Ripples-Sqrt-All.csv',cur_file,channel_ripple));
write_csv_events(output_file,ripples_sqrt,EventHeader,MetaData);


% Delete folders : 
rmdir('ChannelsToAnalyse','s');
rmdir('LFPData','s');
rmdir('Ripples','s');
delete('behavResources.mat');
delete('StateEpochSB.mat');
delete('Rippleraw.png');
delete('swr.evt.swr');
delete('SWR.mat');

success  = true;

end
