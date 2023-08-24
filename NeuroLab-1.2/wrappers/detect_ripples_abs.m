function success = detect_ripples_abs(recording_name,val,channel_ripple,channel_non_ripple,timegroup)

% addpath(genpath('/home/hobbes/Dropbox/Kteam/PrgMatlab/'));
global DIR_SAVE DIR_FIG;
success = false;

if exist(fullfile(DIR_SAVE,recording_name,'Nconfig.mat'),'file')
    data_nconfig = load(fullfile(DIR_SAVE,recording_name,'Nconfig.mat'));
else
    data_nconfig = [];
end

if val == 1
    % user mode
    if nargin < 5
        timegroup = 'NREM';
    end
    if nargin < 4
        channel_non_ripple = '025';
    end
    
    if nargin < 3
        d_lfp = dir(fullfile(DIR_SAVE,recording_name,'Sources_LFP','LFP_*.mat'));
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
        channel_non_ripple = '025';
    end
    if nargin < 3
        channel_ripple = '005';
    end
end

% Loading Channel Ripple
d_ripple = dir(fullfile(DIR_SAVE,recording_name,'Sources_LFP',strcat('LFP_',channel_ripple,'.mat')));
if isempty(d_ripple)
    warning('Channel not found [%s-%s]',recording_name,channel_ripple);
    return;
else
    data_rip = load(fullfile(d_ripple.folder,d_ripple.name));
    X_rip = (data_rip.x_start:data_rip.f:data_rip.x_end)';
    Y_rip = data_rip.Y;
end

% Loading Channel Non-Ripple
d_non_ripple = dir(fullfile(DIR_SAVE,recording_name,'Sources_LFP',strcat('LFP_',channel_non_ripple,'.mat')));
if isempty(d_non_ripple)
    warning('Channel not found [%s-%s]',recording_name,channel_non_ripple);
    return;
else
    data_non_rip = load(fullfile(d_non_ripple.folder,d_non_ripple.name));
    X_non_rip = (data_non_rip.x_start:data_non_rip.f:data_non_rip.x_end)';
    Y_non_rip = data_non_rip.Y;
end

% Loading epochs
data_tg = load(fullfile(DIR_SAVE,recording_name,'Time_Groups.mat'));
data_tt = load(fullfile(DIR_SAVE,recording_name,'Time_Tags.mat'));
ind_group = strcmp(data_tg.TimeGroups_name,timegroup);
if isempty(ind_group)
    warning('Time Group not found [%s-%s]',recording_name,timegroup);
    return;
end
S = data_tg.TimeGroups_S(ind_group);
temp = datenum(S.TimeTags_strings(:,1));
t_start = (temp-floor(temp))*24*3600;
temp = datenum(S.TimeTags_strings(:,2));
t_end = (temp-floor(temp))*24*3600;
epochs = [t_start,t_end];


% transforming into tsd
HPCrip = tsd(X_rip*1e4,Y_rip);
HPCnonRip = tsd(X_non_rip*1e4,Y_non_rip);
% HPCrip = tsd(X_rip,Y_rip);
% HPCnonRip = tsd(X_non_rip,Y_non_rip);
NREM_epochs = intervalSet(t_start*1e4,t_end*1e4);
ind_whole_fus = find(strcmp({data_tt.TimeTags(:).Tag}','Whole-fUS')==1);

% Restricting to NREM epochs
if ~isempty(ind_whole_fus)
    temp = datenum(data_tt.TimeTags_strings(ind_whole_fus,1));
    t_fus_start = (temp-floor(temp))*24*3600;
    temp = datenum(data_tt.TimeTags_strings(ind_whole_fus,2));
    t_fus_end = (temp-floor(temp))*24*3600;
    
    t_start=max(t_start,t_fus_start);
    t_end=min(t_end,t_fus_end);
    
    ind_restrict = ((t_start-t_fus_start).*(t_end-t_fus_end))<0;
    t_start = t_start(ind_restrict==1);
    t_end = t_end(ind_restrict==1);
    NREM_epochs = intervalSet(t_start*1e4,t_end*1e4);
end

% Detecting ripples
[ripples_abs, meanVal, stdVal] = FindRipples_abs(HPCrip, HPCnonRip,NREM_epochs,NREM_epochs,'threshold',[3 6],'frequency_band',[120,250]);
n_events = size(ripples_abs,1);
% [ripples_abs, meanVal, stdVal] = FindRipples_sqrt(HPCrip, HPCnonRip, epochs,epochs);

% Displaying ripples
durations = 100;
cleaning = 0;
PlotFigure = 1;
newfig = 1;
[M,T,f] = PlotRipRaw_AB(HPCrip, ripples_abs(:,2), durations, cleaning, PlotFigure, newfig);

% Saving variables
% save(fullfile(DIR_SAVE,recording_name,'RippleEvents.mat'),...
%     'ripples_abs','HPCrip','meanVal','stdVal','durations','M','T',...
%     'recording_name','channel_ripple','channel_non_ripple','timegroup','-v7.3');
save(fullfile(DIR_SAVE,recording_name,'RippleEvents.mat'),'ripples_abs','n_events',...
    'recording_name','channel_ripple','channel_non_ripple','timegroup','-v7.3');
fprintf('Ripple Detection [Channel:%s, %d events] saved in [%s].\n',channel_ripple,n_events,fullfile(DIR_SAVE,recording_name,'RippleEvents.mat'));

% Saving figure
load('Preferences.mat','GTraces');
save_dir0 = fullfile(DIR_FIG,'Ripple_Detection');
if ~isfolder(save_dir0)
    mkdir(save_dir0);
end
% save_dir = fullfile(DIR_FIG,'Ripple_Detection',recording_name);
% if ~isfolder(save_dir)
%     mkdir(save_dir);
% end

if isgraphics(f)
    saveas(f,fullfile(save_dir0,sprintf('%s-RippleDetection-%s%s',recording_name,channel_ripple,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
%     saveas(f,fullfile(save_dir,sprintf('%s-RippleDetection-%s%s',recording_name,channel_ripple,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
    fprintf('Image saved in [%s].\n',save_dir);
    close(f);
end

success = true;

end

