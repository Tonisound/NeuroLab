global DIR_SAVE FILES;
T = [];

for i = 1:length(FILES)
    % loading SeqUF 
    data_s = load(fullfile(DIR_SAVE,FILES(i).nlab,'Config.mat'),'SeqUF');
    s1 = data_s.SeqUF.Data;
    table1 = struct2table(s1);
    table1 = table1(:,1:4);
    
    % loading Time_Reference.mat
    data_t = load(fullfile(DIR_SAVE,FILES(i).nlab,'Time_Reference.mat'),...
        'n_images','discrepant','trigger_raw');
    s2 = struct('n_images',[],'n_trigs',[],'discrepant',[],'trigger_raw',[],'error_trigg',[]);
    s2.n_images = data_t.n_images;
    s2.n_trigs = length(data_t.trigger_raw);
    s2.discrepant = data_t.discrepant;
    s2.trigger_raw = {data_t.trigger_raw};
    s2.error_trigg = sum(diff(diff(data_t.trigger_raw)).^2);
    table2 = struct2table(s2);
    
    % Concatenate structs
    names = [fieldnames(s1);fieldnames(s2)];
    s3 = cell2struct([struct2cell(s1);struct2cell(s2)],names,1);
    
    % Storing 
    %T = [T;table1];
    T = [T;[table1,table2]];
    S(i)= s3;
end

% Adding rows
T.Row = {FILES(:).nlab}';
table_synthesis = T;
save('Trigger_info.mat','table_synthesis','S','-v7.3');