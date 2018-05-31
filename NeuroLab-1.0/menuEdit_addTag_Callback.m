function menuEdit_addTag_Callback(~,~,handles)
% adding time tag manually 
    
    global DIR_SAVE FILES CUR_FILE START_IM END_IM;
    
    % Loading Time Reference
    if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file')
        load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','time_str');
    else
        errordlg('File Time_Reference.mat not found.');
        return;
    end
    
    % Loading Time Tags
    if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'file')
        tdata = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    else
        errordlg('File Time_Tags.mat not found.');
        return;
    end
    
    % input tag
    name='Specify Tag';
    prompt = {'Time start';'Time end';'Tag'};
    defaultans = {char(time_str(START_IM)),char(time_str(END_IM)),'BASELINE'};
    answer = inputdlg(prompt,name,[1 100],defaultans);
    if ~isempty(answer)
        t_start = char(answer(1));
        t_end = char(answer(2));
        tag = char(answer(3));
    else
        return;
    end
    
    % adding tag
    n = length(tdata.TimeTags);
    %TimeTags_strings
    TimeTags_strings = [tdata.TimeTags_strings;[{t_start},{t_end}]];
    tts1 = datenum(t_start);
    tts2 = datenum(t_end);
    TimeTags_seconds = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;
    TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');
    % TimeTags_images
    [~, ind_min_time] = min(abs(time_ref.Y-TimeTags_seconds(1)));
    [~, ind_max_time] = min(abs(time_ref.Y-TimeTags_seconds(2)));
    TimeTags_images = [tdata.TimeTags_images;[ind_min_time,ind_max_time]];
    
    % TimeTags_cell & TimeTags
    TimeTags_cell = [tdata.TimeTags_cell;{'',tag,t_start,char(TimeTags_dur),t_start,''}];
    TimeTags = tdata.TimeTags;
    TimeTags(n+1,1).Episode = '';
    TimeTags(n+1,1).Tag = tag;
    TimeTags(n+1,1).Onset = t_start;
    TimeTags(n+1,1).Duration = char(TimeTags_dur);
    TimeTags(n+1,1).Reference = t_start;
    TimeTags(n+1,1).Tokens = '';
    
    % Saving
    save(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    fprintf('===> Saved at %s.mat\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'));

end