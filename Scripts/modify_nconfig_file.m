% Script - Dec 23
% Modifying Nconfig files to re-order channels

global DIR_SAVE FILES;

% Use with caution
for i =1:length(FILES)
    % copying previous file
    copyfile(fullfile(DIR_SAVE,FILES(i).nlab,'Nconfig.mat'),fullfile(DIR_SAVE,FILES(i).nlab,'~Nconfig.mat'));
    fprintf('===> Channel Configuration copied at %s.\n',fullfile(DIR_SAVE,FILES(i).nlab,'~Nconfig.mat'));
end

for i = 1:length(FILES)
    % loading previous file
    data_config = load(fullfile(DIR_SAVE,FILES(i).nlab,'~Nconfig.mat'));
    
    ind_old = 1:8;
    if contains(FILES(i).nlab,'SD025')
        ind_new = [8,5,7,1,3,4,2,6];
    elseif contains(FILES(i).nlab,'SD032')
        ind_new = [1,2,3,4,5,6,7,8];
    elseif contains(FILES(i).nlab,'SD092')
        ind_new = [1,4,6,7,5,2,8,3];
    elseif contains(FILES(i).nlab,'SD093')
        ind_new = [8,7,6,2,4,1,3,5];
    elseif contains(FILES(i).nlab,'SD111')
        ind_new = [3,1,4,8,2,5,6,7];
    elseif contains(FILES(i).nlab,'SD113')
        ind_new = [1,2,8,3,5,6,7,4];
    elseif contains(FILES(i).nlab,'SD121')
        ind_new = [1,2,3,7,4,8,6,5];
    elseif contains(FILES(i).nlab,'SD122')
        ind_new = [1,3,2,6,8,7,4,5];
    elseif contains(FILES(i).nlab,'SD123')
        ind_new = [4,2,1,3,5,6,7,8];
    elseif contains(FILES(i).nlab,'SD131')
        ind_new = [3,5,8,6,7,4,1,2];
    elseif contains(FILES(i).nlab,'SD132')
        ind_new = [8,1,4,2,3,5,6,7];
    else
        continue;
    end
    channel_type = data_config.channel_type;
    channel_type(ind_old) = data_config.channel_type(ind_new);
    
    channel_list = data_config.channel_list;
    channel_list(ind_old) = data_config.channel_list(ind_new);
    
    channel_id = data_config.channel_id;
    channel_id(ind_old) = data_config.channel_id(ind_new);
    
    ind_channel = data_config.ind_channel;
    ind_channel(ind_old) = data_config.ind_channel(ind_new);
    
    ind_channel_diff = data_config.ind_channel_diff;
    ind_channel_diff(ind_old) = data_config.ind_channel_diff(ind_new);
    
    % Save Nconfig.mat
    save(fullfile(DIR_SAVE,FILES(i).nlab,'Nconfig.mat'),...
        'ind_channel','ind_channel_diff','channel_id','channel_list','channel_type');
    fprintf('===> Channel Configuration saved at %s.\n',fullfile(DIR_SAVE,FILES(i).nlab,'Nconfig.mat'));
    
end
