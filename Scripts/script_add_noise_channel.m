global DIR_SAVE;

for i=1:length(FILES)
    cur_recording = FILES(i).nlab;
    % LFP Channel Loading
    d_lfp = dir(fullfile(DIR_SAVE,cur_recording,'Sources_LFP','LFP_*.mat'));
    n_channels = length(d_lfp);

    Yraw = [];
    for j=1:n_channels
        cur_channel = char(d_lfp(j).name);
        d_raw = dir(fullfile(d_lfp(j).folder,d_lfp(j).name));
        if isempty(d_raw)
            warning('No channel found [%s]',cur_recording);
            continue;
        else
            data_raw = load(fullfile(d_raw.folder,d_raw.name));
            Xraw = data_raw.x_start:data_raw.f:data_raw.x_end;
            Yraw = [Yraw,rescale(data_raw.Y(:),0,1)];
        end
        fprintf('Data Loaded [%s][%s].\n',cur_recording,cur_channel);
    end

    Y = mean(Yraw,2,'omitnan');
    if length(Xraw)~=length(Y)
        warning('Uneven size for LFP noise channel [%s]',cur_recording);
        continue;
    else
        x_start=data_raw.x_start;
        f=data_raw.f;
        x_end=data_raw.x_end;
        save(fullfile(DIR_SAVE,cur_recording,'Sources_LFP','LFP_999.mat'),'Y','x_start','f','x_end');
        fprintf('Noise channel Saved [%s].\n',fullfile(DIR_SAVE,cur_recording,'Sources_LFP','LFP_999.mat'));
    end
end