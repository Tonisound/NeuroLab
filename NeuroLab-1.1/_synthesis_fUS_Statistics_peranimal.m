function [table1,T1] = synthesis_fUS_Statistics_peranimal(list_name_txt)
% Synthesis Statistical Analysis Per Animal with confidence intervals
% Opens txt file/ creates corresponding folder
% manuscript NCOMMS revision aug 2018
% Creates table to show confidence intervals etc.

global DIR_SYNT DIR_STATS;
folder_synt = fullfile(DIR_SYNT,'fUS_Statistics_per_animal');

% If list name not provided opens list dialog
if nargin ==0
    str_list = dir(fullfile(folder_synt,'*.txt'));
    [ind_list,v] = listdlg('Name','List Selection','PromptString','Select recording list',...
        'SelectionMode','single','ListString',{str_list(:).name},'InitialValue','','ListSize',[300 500]);
    if isempty(ind_list)||v==0
        return;
    else
        list_name_txt = char(str_list(ind_list).name);
    end
end
list_name = strrep(list_name_txt,'.txt','');

% Open file
filename = fullfile(folder_synt,list_name_txt);
fileID = fopen(filename);
rec_list = [];
while ~feof(fileID)
    hline = fgetl(fileID);
    rec_list = [rec_list;{hline}];
end
fclose(fileID);

%Extracting file channel and episode from rec_list
file_list = [];
for i =1:length(rec_list)
    pattern = strrep(char(rec_list(i)),'.mat','');
    temp = regexp(pattern,'_fUS_Statistics','split');
    file_list = [file_list;temp(1)];
end

%Clearing folder synthesis
folder_list = fullfile(folder_synt,list_name);
if exist(folder_list,'dir')
    fprintf('Clearing folder %s\n',folder_list);
    rmdir(folder_list,'s');
end
mkdir(folder_list);

%Moving stats 
for i =1:length(rec_list)
    fprintf('Moving file %s\n',filename);
    filename = char(rec_list(i));
    status = copyfile(fullfile(DIR_STATS,'fUS_Statistics',char(file_list(i)),filename),fullfile(folder_list,filename));
    if ~status
        warning('Problem copying file %s',filename);
    end
end

% Parameters
list_regions = {'Neocortex';'dHpc';'dThal';'Thalamus';'Whole'};
%list_regions = {'Neocortex-L';'Neocortex-R';'dHpc-L';'dHpc-R';'dThal-L';'dThal-R';'Thalamus-L';'Thalamus-R';'Whole-reg'};
list_episodes = {'QW';'NREM';'AW';'REM';'REM-TONIC';'REM-PHASIC'};


%Loading

S_ALL(length(list_regions),length(list_episodes)).recording = [];
S_ALL(length(list_regions),length(list_episodes)).region = [];
S_ALL(length(list_regions),length(list_episodes)).x_data = [];
S_ALL(length(list_regions),length(list_episodes)).y_data = [];

S_EPISODE(length(list_regions),length(list_episodes)).recording = [];
S_EPISODE(length(list_regions),length(list_episodes)).region = [];
S_EPISODE(length(list_regions),length(list_episodes)).group_name = [];
S_EPISODE(length(list_regions),length(list_episodes)).episode = [];
S_EPISODE(length(list_regions),length(list_episodes)).n_images = [];
S_EPISODE(length(list_regions),length(list_episodes)).y_mean = [];

S_RECORDING(length(list_regions),length(list_episodes)).recording = [];
S_RECORDING(length(list_regions),length(list_episodes)).region = [];
S_RECORDING(length(list_regions),length(list_episodes)).n_images = [];
S_RECORDING(length(list_regions),length(list_episodes)).y_mean = [];

for i=1:length(rec_list)
    filename = char(rec_list(i));
    %data = load(fullfile(folder_list,filename),'S','label_ampli','label_episodes','label_channels');
    data = load(fullfile(folder_list,filename));
    fprintf('Loading file %s.\n',fullfile(folder_list,filename));
    this_recording = data.recording;

    % Searching regions
    for j=1:length(list_regions)
        this_region = char(list_regions(j));
        ind_reg = find(contains(data.label_channels,this_region)==1);
        if isempty(ind_reg)
            warning('Region %s not found in recording %s. Proceed',this_region,this_recording);
            continue;
        elseif length(ind_reg)>1
            selected_region = data.label_channels(ind_reg);
            for jj=1:length(selected_region)
                fprintf('Multiple Regions found in recording %s. aggregating: %s.\n',this_recording,char(selected_region(jj)));
            end
            
            % Adding aggregate region at the end of the structure
            %S = data.S(:,ind_reg(1));
            S = data.S(:,ind_reg);
            for kk=1:size(S,1)
                aggregate_region = '';
                aggregate_ydata = [];
            
                for jj=1:length(ind_reg)
                    aggregate_region = strcat(aggregate_region,strcat(S(kk,jj).channel,'|'));
                    aggregate_ydata = [aggregate_ydata,S(kk,jj).y_data];
                end
                S(kk,length(ind_reg)+1).channel = aggregate_region(1:end-1);
                S(kk,length(ind_reg)+1).y_data = mean(aggregate_ydata,2,'omitnan');
                S(kk,length(ind_reg)+1).group = S(kk,length(ind_reg)).group;
                S(kk,length(ind_reg)+1).t_data = S(kk,length(ind_reg)).t_data;
                S(kk,length(ind_reg)+1).x_data = S(kk,length(ind_reg)).x_data;
            end
            S = S(:,length(ind_reg)+1);
        else
            selected_region = data.label_channels(ind_reg);
            fprintf('Region %s found in recording %s.\n',char(selected_region),this_recording);
            S = data.S(:,ind_reg);
        end

        
        % Searching episodes
        for k=1:length(list_episodes)
            this_episode = char(list_episodes(k));
            ind_episode = find(strcmp(data.label_episodes,this_episode)==1);
            if isempty(ind_episode)
                warning('Episode %s not found in recording %s. Proceed',this_episode,this_recording);
                continue;
            elseif length(ind_episode)>1
                selected_episodes = data.label_episodes(ind_episodes);
                for jj=1:length(selected_episode)
                    warning('Multiple Episodes found in recording %s. averaging: %s.\n',this_recording,char(selected_episodes(jj)));
                end
                continue;
            else
                selected_episode = data.label_episodes(ind_episode);
                fprintf('Episode %s found in recording %s.\n',char(selected_episode),this_recording);
                S_episode = S(ind_episode,:);
                
                %Subsampling
                t_subsamp = 20; % Time between two subsequent frames
                sub_samp_factor = round(t_subsamp/(S_episode.t_data(2)- S_episode.t_data(1)));
                x_temp=S_episode.x_data(1:sub_samp_factor:end);
                y_temp=[];
                for ll=1:length(x_temp)
                    ind1=(ll-1)*sub_samp_factor+1;
                    ind2=min(ll*sub_samp_factor,length(S_episode.y_data));
                    y_temp = [y_temp;mean(S_episode.y_data(ind1:ind2))];
                end
                S_episode.x_data = x_temp;
                S_episode.y_data = y_temp;
                
                % filling
                S_ALL(j,k).x_data = [S_ALL(j,k).x_data;S_episode.x_data];
                S_ALL(j,k).y_data = [S_ALL(j,k).y_data;S_episode.y_data];
                S_ALL(j,k).recording = [S_ALL(j,k).recording;repmat({this_recording},size(S_episode.x_data))];
                S_ALL(j,k).region = [S_ALL(j,k).region;repmat({S_episode.channel},size(S_episode.x_data))];
                
                % data per episode
                tag_name = data.Tag_Name(ind_episode);
                all_episodes = [];
                all_y_mean = [];
                all_n_images = [];
                for kk=1:length(tag_name.tags)
                    ind_keep = (S_episode.x_data>=tag_name.images(kk,1)).*(S_episode.x_data<=tag_name.images(kk,2));
                    y_mean = mean(S_episode.y_data(ind_keep==1),'omitnan');
                    n_images = length(S_episode.y_data(ind_keep==1));
                    
                    all_episodes = [all_episodes;tag_name.tags(kk)];
                    all_y_mean = [all_y_mean;y_mean];
                    all_n_images = [all_n_images;n_images];
                end
                S_EPISODE(j,k).recording = [S_EPISODE(j,k).recording;repmat({this_recording},size(all_y_mean))];
                S_EPISODE(j,k).region = [S_EPISODE(j,k).region;repmat({S_episode.channel},size(all_y_mean))];
                S_EPISODE(j,k).group_name = [S_EPISODE(j,k).group_name;repmat(tag_name.group,size(all_y_mean))];
                S_EPISODE(j,k).episode = [S_EPISODE(j,k).episode;all_episodes];
                S_EPISODE(j,k).n_images = [S_EPISODE(j,k).n_images;all_n_images];
                S_EPISODE(j,k).y_mean = [S_EPISODE(j,k).y_mean;all_y_mean];
                
                % data per recording
                S_RECORDING(j,k).y_mean = [S_RECORDING(j,k).y_mean;mean(S_episode.y_data,'omitnan')];
                S_RECORDING(j,k).recording = [S_RECORDING(j,k).recording;{this_recording}];
                S_RECORDING(j,k).region = [S_RECORDING(j,k).region;{S_episode.channel}];
                S_RECORDING(j,k).n_images = [S_RECORDING(j,k).n_images;length(S_episode.y_data)];
            end
        end
    end
end

% T1 = struct('region',[],'episode',[],'n_recordings',[],'n_dots',[],...
%     'mean',[],'median',[],'std',[],'sem',[],...
%     'IC_95',[],'IC_99',[],'p_value',[]);
T1 = struct('animal',[],'region',[],'episode',[],'n_recordings',[],'n_dots',[],...
    'mean',[],'sem',[],'IC_95',[],'diff',[],'IC_95_d',[],'p_value',[]);
for j=1:length(list_regions)
    for k=1:length(list_episodes)
        this_region = char(list_regions(j));
        this_episode = char(list_episodes(k));
        T1(j,k).animal = list_name;
        T1(j,k).region = this_region;
        T1(j,k).episode = this_episode;
        T1(j,k).n_recordings = length(unique(S_ALL(j,k).recording));
        T1(j,k).n_dots = length(S_ALL(j,k).y_data);
       
        T1(j,k).mean = mean(S_ALL(j,k).y_data,'omitnan');
        %T1(j,k).median = median(S_ALL(j,k).y_data,'omitnan');
        %T1(j,k).std = std(S_ALL(j,k).y_data,[],'omitnan');
        T1(j,k).sem = std(S_ALL(j,k).y_data,[],'omitnan')/sqrt(T1(j,k).n_dots);
        T1(j,k).IC_95 = [T1(j,k).mean-1.96*T1(j,k).sem, T1(j,k).mean+1.96*T1(j,k).sem];
        %T1(j,k).IC_99 = [T1(j,k).mean-2.57*T1(j,k).sem, T1(j,k).mean+2.57*T1(j,k).sem];
        if k>1
            T1(j,k).diff = T1(j,k).mean-T1(j,1).mean;
            sem_diff = sqrt(T1(j,k).sem^2+T1(j,1).sem^2);
            T1(j,k).IC_95_d = [T1(j,k).diff-1.96*sem_diff, T1(j,k).diff+1.96*sem_diff];
            T1(j,k).p_value = ranksum(S_ALL(j,1).y_data,S_ALL(j,k).y_data);
        else
            T1(j,k).diff = 0;
            T1(j,k).IC_95_d = [0,0];
            T1(j,k).p_value = 0;
        end
    end
end


% T2 = struct('region',[],'episode',[],'n_recordings',[],'n_episodes',[],'n_images_per_ep',[],...
%     'mean',[],'median',[],'std',[],'sem',[],...
%     'IC_95',[],'IC_99',[],'p_value',[]);
T2 = struct('animal',[],'region',[],'episode',[],'n_rec',[],'n_ep',[],...
    'mean',[],'sem',[],'IC_95',[],'diff',[],'IC_95_d',[],'p_value',[]);
for j=1:length(list_regions)
    for k=1:length(list_episodes)
        this_region = char(list_regions(j));
        this_episode = char(list_episodes(k));
        T2(j,k).animal = list_name;
        T2(j,k).region = this_region;
        T2(j,k).episode = this_episode;
        T2(j,k).n_rec = length(unique(S_EPISODE(j,k).recording));
        T2(j,k).n_ep = length(S_EPISODE(j,k).y_mean);
        %T2(j,k).n_images_per_ep = mean(S_EPISODE(j,k).n_images);
        
        T2(j,k).mean = mean(S_EPISODE(j,k).y_mean,'omitnan');
        % avoiding mean artifacts
        %T2(j,k).mean = sum(S_EPISODE(j,k).y_mean.*(S_EPISODE(j,k).n_images/sum(S_EPISODE(j,k).n_images)),'omitnan');
        
        %T2(j,k).median = median(S_EPISODE(j,k).y_mean,'omitnan');
        %T2(j,k).std = std(S_EPISODE(j,k).y_mean,[],'omitnan');
        T2(j,k).sem = std(S_EPISODE(j,k).y_mean,[],'omitnan')/sqrt(T2(j,k).n_ep);        
        T2(j,k).IC_95 = [T2(j,k).mean-1.96*T2(j,k).sem, T2(j,k).mean+1.96*T2(j,k).sem];
        %T2(j,k).IC_99 = [T2(j,k).mean-2.57*T2(j,k).sem, T2(j,k).mean+2.57*T2(j,k).sem];
        if k>1
            T2(j,k).diff = T2(j,k).mean-T2(j,1).mean;
            sem_diff = sqrt(T2(j,k).sem^2+T2(j,1).sem^2);
            T2(j,k).IC_95_d = [T2(j,k).diff-1.96*sem_diff, T2(j,k).diff+1.96*sem_diff];
            T2(j,k).p_value = ranksum(S_EPISODE(j,1).y_mean,S_EPISODE(j,k).y_mean);
        else
            T2(j,k).diff = 0;
            T2(j,k).IC_95_d = [0,0];
            T2(j,k).p_value = 0;
        end
    end
end


% T3 = struct('region',[],'episode',[],'n_recordings',[],'n_images_per_rec',[],...
%     'mean',[],'median',[],'std',[],'sem',[],'IC_95',[],'IC_99',[],...
%     'diff_mean',[],'diff_std',[],'IC_diff',[],'p_value',[]);
% for j=1:length(list_regions)
%     for k=1:length(list_episodes)
%         this_region = char(list_regions(j));
%         this_episode = char(list_episodes(k));
%         T3(j,k).region = this_region;
%         T3(j,k).episode = this_episode;
%         T3(j,k).n_recordings = length(unique(S_RECORDING(j,k).recording));
%         T3(j,k).n_images_per_rec = mean(S_RECORDING(j,k).n_images);
%         
%         T3(j,k).mean = mean(S_RECORDING(j,k).y_mean,'omitnan');
%         if k>1
%             try
%                 data_diff = S_RECORDING(j,k).y_mean-S_RECORDING(j,1).y_mean;
%                 T3(j,k).diff_mean = mean(data_diff,'omitnan');
%                 T3(j,k).diff_std = std(data_diff,[],'omitnan');
%             catch
%                 data_diff = S_RECORDING(j,k).y_mean-S_RECORDING(j,1).y_meanS
%             end
%         end
%         T3(j,k).median = median(S_RECORDING(j,k).y_mean,'omitnan');
%         T3(j,k).std = std(S_RECORDING(j,k).y_mean,[],'omitnan');
%         T3(j,k).sem = std(S_RECORDING(j,k).y_mean,[],'omitnan')/sqrt(T3(j,k).n_recordings);
%     end
% end

table1 = struct2table(reshape(T1',[size(T1,1)*size(T1,2),1]));
table2 = struct2table(reshape(T2',[size(T2,1)*size(T2,2),1]));
% table3 = struct2table(reshape(T3',[size(T3,1)*size(T3,2),1]));

end

function main_script_stats()
% generate txt files with synthesis tables

[table1,T1] = synthesis_fUS_Statistics_peranimal('Rat1.txt');
[table2,T2] = synthesis_fUS_Statistics_peranimal('Rat2.txt');
[table3,T3] = synthesis_fUS_Statistics_peranimal('Rat3.txt');
[table4,T4] = synthesis_fUS_Statistics_peranimal('Rat4.txt');
[table5,T5] = synthesis_fUS_Statistics_peranimal('Rat5.txt');

T_cortex = [T1(1,:);T2(1,:);T3(1,:);T4(1,:);T5(1,:)];
T_hpc = [T1(2,:);T2(2,:);T3(2,:);T4(2,:);T5(2,:)];
T_dthal = [T1(3,:);T2(3,:);T3(3,:);T4(3,:);T5(3,:)];
T_thal = [T1(4,:);T2(4,:);T3(4,:);T4(4,:);T5(4,:)];
T_whole = [T1(5,:);T2(5,:);T3(5,:);T4(5,:);T5(5,:)];

table_cortex = struct2table(reshape(T_cortex,[size(T_cortex,1)*size(T_cortex,2),1]));
table_hpc = struct2table(reshape(T_hpc,[size(T_hpc,1)*size(T_hpc,2),1]));
table_dthal = struct2table(reshape(T_dthal,[size(T_dthal,1)*size(T_dthal,2),1]));
table_thal = struct2table(reshape(T_thal,[size(T_thal,1)*size(T_thal,2),1]));
table_whole = struct2table(reshape(T_whole,[size(T_whole,1)*size(T_whole,2),1]));

writetable(table_cortex);
writetable(table_hpc);
writetable(table_dthal);
writetable(table_thal);
writetable(table_whole);

end