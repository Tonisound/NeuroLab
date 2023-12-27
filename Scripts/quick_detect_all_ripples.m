% Detect Ripples on All channels
% Comment if unnecessary

global DIR_SAVE FILES;

for i=1:length(FILES)
    savedir = fullfile(DIR_SAVE,FILES(i).nlab);
    dir_dat = FILES(i).dir_dat;
    if exist(fullfile(savedir,'Nconfig.mat'),'file')
        data_nconfig = load(fullfile(savedir,'Nconfig.mat'));
        all_channels = data_nconfig.channel_id(strcmp(data_nconfig.channel_type,'LFP'));
        for k=1:length(all_channels)
            channel_ripple = char(all_channels(k));
            timegroup = 'NREM';
            success = detect_ripples_both(savedir,dir_dat,0,channel_ripple,timegroup);
        end
    else
        success = false;
    end
end