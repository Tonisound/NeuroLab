% Script updated May 10, 24
% Generates panel D Figure 3 Article Pogona
% Statistics autocorrelation per animal and time group
% Stores stats in txt file

global DIR_STATS;
close all;

folder_data = fullfile(DIR_STATS,'Auto-Correlation');
list_regions = {'Whole-reg'};
% list_tags = {'WAKE';'INTER';'SLEEP'};
list_tags = {'WAKE';'SLEEP'};
list_animals = {'P1';'P3';'P5';'P6'};


d = dir(fullfile(folder_data,'*','*_Auto-Correlation_*'));
S = struct('all_r',[],'all_pks_regions',[],'all_locs_regions',[],...
    'region',[],'tag',[],'animal',[]);
S(length(list_animals),length(list_tags),length(list_regions)).all_r=[];
all_counters = zeros(length(list_animals),length(list_tags));

for i =1:length(d)
    data_ac = load(fullfile(d(i).folder,d(i).name));

    for k1=1:length(list_animals)
        cur_animal = list_animals(k1);
        actual_recording = data_ac.recording;
        
        if contains(actual_recording,cur_animal)
            % Animal found
            
            for k2=1:length(list_tags)
                cur_tag = list_tags(k2);
                actual_tag = data_ac.tag;
                
                if contains(actual_tag,cur_tag)
                    % Tag found

                    for k3=1:length(list_regions)
                        cur_region = list_regions(k3);
                         
%                         index_regions = find(strcmp(data_ac.label_regions,cur_region)==1);
%                         if isempty(index_regions)
%                             cur_region = strrep(list_regions(k3),'-','_');
%                             index_regions = find(strcmp(data_ac.label_regions,cur_region)==1);
%                         end
                        index_regions = [find(strcmp(data_ac.label_regions,strrep(cur_region,'-','_'))==1);...
                            find(strcmp(data_ac.label_regions,strrep(cur_region,'_','-'))==1)];

                        if ~isempty(index_regions)
                            % Region found
                            all_r = data_ac.all_r_regions(index_regions,:);
                            lags = data_ac.Params.lags;
                            all_counters(k1,k2) = all_counters(k1,k2)+1;

%                             first_time = data_ac.all_locs_regions(index_regions,1);
%                             first_val = data_ac.all_pks_regions(index_regions,1);
%                             max_time = data_ac.all_locs_regions(index_regions,2);
%                             max_val = data_ac.all_pks_regions(index_regions,2);
%                             second_time = data_ac.all_locs_regions(index_regions,3);
%                             second_val = data_ac.all_pks_regions(index_regions,3);
%                             min_time = data_ac.all_locs_regions(index_regions,4);
%                             min_val = data_ac.all_pks_regions(index_regions,4);
%                             S(k1,k2,k3).all_peak_times=[S(k1,k2,k3).all_peak_times;peak_time];
%                             S(k1,k2,k3).all_peak_times_min=[S(k1,k2,k3).all_peak_times_min;peak_time_min];
%                             S(k1,k2,k3).all_peak_val=[S(k1,k2,k3).all_peak_val;peak_val];
%                             S(k1,k2,k3).all_peak_val_min=[S(k1,k2,k3).all_peak_val_min;peak_val_min];

                            S(k1,k2,k3).all_r=[S(k1,k2,k3).all_r;all_r];
                            S(k1,k2,k3).all_locs_regions=[S(k1,k2,k3).all_locs_regions;data_ac.all_locs_regions(index_regions,:)];
                            S(k1,k2,k3).all_pks_regions=[S(k1,k2,k3).all_pks_regions;data_ac.all_pks_regions(index_regions,:)];

                            S(k1,k2,k3).region=[S(k1,k2,k3).region;cur_region];
                            S(k1,k2,k3).tag=[S(k1,k2,k3).tag;actual_tag];
                            S(k1,k2,k3).animal=[S(k1,k2,k3).animal;actual_recording];
                        end
                    end
                end
            end
        end
    end
end


% Merging data
list_variables_1a = {'FirstTime';'MaxTime';'HalfTime';'MinTime';};
all_data_1a = NaN(length(list_animals),length(list_tags),max(all_counters(:)),length(list_variables_1a));
for k4=1:length(list_variables_1a)
    for k2=1:length(list_tags)
        for k1=1:length(list_animals)
            if ~isempty(S(k1,k2,1).all_locs_regions)
                temp = permute(S(k1,k2,1).all_locs_regions(:,k4),[3,2,1]);
                all_data_1a(k1,k2,1:length(temp),k4) = temp;
            end
        end
    end
end
list_variables_1b = {'FirstTimeDiff';'MaxTimeDiff'};
all_data_1b = NaN(length(list_animals),length(list_tags),max(all_counters(:)),2);
all_data_1b(:,:,:,1) = all_data_1a(:,:,:,1)-all_data_1a(:,:,:,3);
all_data_1b(:,:,:,2) = all_data_1a(:,:,:,2)-all_data_1a(:,:,:,4);
% Concatenate
list_variables_1 = [list_variables_1a;list_variables_1b];
all_data_1 = cat(4,all_data_1a,all_data_1b);

% Merging data
list_variables_2a = {'FirstPeak';'MaxPeak';'HalfPeak';'MinPeak';};
all_data_2a = NaN(length(list_animals),length(list_tags),max(all_counters(:)),length(list_variables_2a));
for k4=1:length(list_variables_2a)
    for k2=1:length(list_tags)
        for k1=1:length(list_animals)
            if ~isempty(S(k1,k2,1).all_pks_regions)
                temp = permute(S(k1,k2,1).all_pks_regions(:,k4),[3,2,1]);
                all_data_2a(k1,k2,1:length(temp),k4) = temp;
            end
        end
    end
end
list_variables_2b = {'FirstPeakDiff';'MaxPeakDiff'};
all_data_2b = NaN(length(list_animals),length(list_tags),max(all_counters(:)),2);
all_data_2b(:,:,:,1) = all_data_2a(:,:,:,1)-all_data_2a(:,:,:,3);
all_data_2b(:,:,:,2) = all_data_2a(:,:,:,2)-all_data_2a(:,:,:,4);
% Concatenate
list_variables_2 = [list_variables_2a;list_variables_2b];
all_data_2 = cat(4,all_data_2a,all_data_2b);



% Synthesis Correlogramm
g_colors = get(groot,'defaultAxesColorOrder');
f1 = figure;
counter = 0;
for k2=1:length(list_tags)
    for k1=1:length(list_animals)
        counter =counter+1;
        ax = subplot(length(list_tags),length(list_animals),counter);
%         for i=1:size(S(k1,k2,1).all_r,1)
%             line('XData',lags,'YData',S(k1,k2,1).all_r(i,:),'LineWidth',.25,'Parent',ax,'Color',[.5 .5 .5]);
%             line('XData',S(k1,k2,1).all_locs_regions(i,1),'YData',S(k1,k2,1).all_pks_regions(i,1),...
%                 'Marker',"^",'MarkerSize',5,'Parent',ax,'MarkerFaceColor','r','MarkerEdgeColor','r');
%             line('XData',S(k1,k2,1).all_locs_regions(i,3),'YData',S(k1,k2,1).all_pks_regions(i,3),...
%                 'Marker',"v",'MarkerSize',5,'Parent',ax,'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
%         end
        line('XData',lags,'YData',mean(S(k1,k2,1).all_r,1,'omitnan'),'LineWidth',1,'Parent',ax,'Color','r');
%         line('XData',lags,'YData',mean(S(k1,k2,1).all_r,1,'omitnan')+sem(S(k1,k2,1).all_r,1,'omitnan'),'LineWidth',.5,'Parent',ax,'Color',[.5 .5 .5]);
%         line('XData',lags,'YData',mean(S(k1,k2,1).all_r,1,'omitnan')-sem(S(k1,k2,1).all_r,1,'omitnan'),'LineWidth',.5,'Parent',ax,'Color',[.5 .5 .5]);
        patch_xdata = [lags,fliplr(lags)];
%         patch_ydata = [mean(S(k1,k2,1).all_r,1,'omitnan')-sem(S(k1,k2,1).all_r,1,'omitnan'),fliplr(mean(S(k1,k2,1).all_r,1,'omitnan')+sem(S(k1,k2,1).all_r,1,'omitnan'))];
        patch_ydata = [mean(S(k1,k2,1).all_r,1,'omitnan')-(std(S(k1,k2,1).all_r,1,'omitnan')/sqrt(length(S(k1,k2,1).region))),fliplr(mean(S(k1,k2,1).all_r,1,'omitnan')+(std(S(k1,k2,1).all_r,1,'omitnan')/sqrt(length(S(k1,k2,1).region))))];
        patch('XData',patch_xdata,'YData',patch_ydata,'EdgeColor','none','Parent',ax,'FaceColor',g_colors(k1,:),'FaceAlpha',.25);

        ax.Title.String = sprintf('%s - %s',char(list_animals(k1)),char(list_tags(k2)));
        ax.YLim = [-.5 1];
%         ax.XLim = [-200 200];
        grid(ax,'on');
    end
end


% % Synthesis Bar Data
% f=figure;
% for k4 = 1:4
%     ax=subplot(2,3,k4);
%     bdata = mean(all_data_1(:,:,:,k4),3,'omitnan');
%     ebdata = std(all_data_1(:,:,:,k4),[],3,'omitnan');
%     bar(bdata,'Parent',ax);
%     hold(ax,"on");
%     ax.Title.String = char(list_variables_1(k4));
%     grid(ax,"on");
%     l = legend(list_tags); 
%     ax.XTickLabel = list_animals;
% end
% 
% ax=subplot(2,3,5);
% bdata = mean(all_data_1(:,:,:,1)-all_data_1(:,:,:,3),3,'omitnan');
% bar(bdata,'Parent',ax);
% ax.Title.String = 'First Time Diff';
% grid(ax,"on");
% l = legend(list_tags);
% ax.XTickLabel = list_animals;
% ax=subplot(2,3,6);
% bdata = mean(all_data_1(:,:,:,2)-all_data_1(:,:,:,4),3,'omitnan');
% bar(bdata,'Parent',ax);
% ax.Title.String = 'Max Time Diff';
% grid(ax,"on");
% l = legend(list_tags);
% ax.XTickLabel = list_animals;
% 
% 
% f=figure;
% for k4 = 1:length(list_variables_2)
%     ax=subplot(2,3,k4);
%     bdata = mean(all_data_2(:,:,:,k4),3,'omitnan');
%     bar(bdata,'Parent',ax);
%     ax.Title.String = char(list_variables_2(k4));
%     grid(ax,"on");
%     l = legend(list_tags);  
%     ax.XTickLabel = list_animals;
% end
% ax=subplot(2,3,5);
% bdata = mean(all_data_2(:,:,:,1)-all_data_2(:,:,:,3),3,'omitnan');
% bar(bdata,'Parent',ax);
% ax.Title.String = 'First Peak Diff';
% grid(ax,"on");
% l = legend(list_tags);
% ax.XTickLabel = list_animals;
% ax=subplot(2,3,6);
% bdata = mean(all_data_2(:,:,:,2)-all_data_2(:,:,:,4),3,'omitnan');
% bar(bdata,'Parent',ax);
% ax.Title.String = 'Max Peak Diff';
% grid(ax,"on");
% l = legend(list_tags);
% ax.XTickLabel = list_animals;


% Scatter Plots
x_bar = [1 2 3 4]';
x_offset = [-.2 .2 .2];
s_markers = {'o';'+';'.'};
x_position = repmat(x_bar,[1 3])+ repmat(x_offset,[4 1]);
scatter_x = repmat(x_position,[1 1 size(all_data_1,3)]);
scatter_x = scatter_x+rand(size(scatter_x))/10;

% % All points
% f=figure;
% for k4 = 1:length(list_variables_1)
%     ax=subplot(2,2,k4);
%     scatter_y = all_data_1(:,:,:,k4);
%     scatter(scatter_x(:),scatter_y(:));
%     ax.Title.String = char(list_variables_1(k4));
%     grid(ax,"on");
%     l = legend(list_tags);
%     ax.XTick = 1:length(list_animals);
%     ax.XTickLabel = list_animals;
% end

% Statistics Separate files
folder = pwd;
filename_out = fullfile(folder,sprintf('Statistics_PanelD.txt'));
fid = fopen(filename_out,'w'); 


f2 = figure;
for k4 = 1:length(list_variables_1)
    ax=subplot(2,3,k4);
    hold(ax,'on');
    for k2=1:length(list_tags)
        scatter_xx = scatter_x(:,k2,:);
        scatter_yy = all_data_1(:,k2,:,k4);
        scatter(scatter_xx(:),scatter_yy(:),'Color',g_colors(k2,:),'Marker',s_markers(k2));
    end
    
    bdata = mean(all_data_1(:,:,:,k4),3,'omitnan');
    n_samples = sum(~isnan(all_data_1(:,:,:,k4)),3);
    std_data = std(all_data_1(:,:,:,k4),[],3,'omitnan');
    sem_data = std_data./sqrt(n_samples);
    
    for k2=1:length(list_tags)
        line('Xdata',x_position(:,k2)+.05,'YData',bdata(:,k2),'Parent',ax,'LineStyle','none','LineWidth',2,...
            'Marker','_','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
        line('Xdata',x_position(:,k2)+.05,'YData',bdata(:,k2)+sem_data(:,k2),'Parent',ax,'LineStyle','none','LineWidth',2,...
            'Marker','.','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
        line('Xdata',x_position(:,k2)+.05,'YData',bdata(:,k2)-sem_data(:,k2),'Parent',ax,'LineStyle','none','LineWidth',2,...
            'Marker','.','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
    end

    ax.Title.String = char(list_variables_1(k4));
    grid(ax,"on");
    l = legend(list_tags);
    ax.XTick = 1:length(list_animals);
    ax.XTickLabel = list_animals;

    % Writing to file
    fwrite(fid,sprintf('%s \t ', char(list_variables_1(k4))));
    for j = 1:length(list_tags)
        fwrite(fid,sprintf('%s \t ', char(list_tags(j))));
    end
    fwrite(fid,newline);
    for k = 1:size(bdata,1)
        fwrite(fid,sprintf('%s-%s \t ', 'Nsamples',char(list_animals(k))));
        for j = 1:length(list_tags)
            fwrite(fid,sprintf('%d \t ', n_samples(k,j)));
        end
        fwrite(fid,newline);
        fwrite(fid,sprintf('%s-%s \t ', 'Mean',char(list_animals(k))));
        for j = 1:length(list_tags)
            fwrite(fid,sprintf('%.2f \t ', bdata(k,j)));
        end
        fwrite(fid,newline);
        fwrite(fid,sprintf('%s-%s \t ', 'Std',char(list_animals(k))));
        for j = 1:length(list_tags)
            fwrite(fid,sprintf('%.2f \t ', std_data(k,j)));
        end
        fwrite(fid,newline);
        fwrite(fid,sprintf('%s-%s \t ', 'Sem',char(list_animals(k))));
        for j = 1:length(list_tags)
            fwrite(fid,sprintf('%.2f \t ', sem_data(k,j)));
        end
        fwrite(fid,newline);
    end
    fwrite(fid,newline);
end


f3 = figure;
for k4 = 1:length(list_variables_2)
    ax=subplot(2,3,k4);
    hold(ax,'on');
    for k2=1:length(list_tags)
        scatter_xx = scatter_x(:,k2,:);
        scatter_yy = all_data_2(:,k2,:,k4);
        scatter(scatter_xx(:),scatter_yy(:),'Color',g_colors(k2,:),'Marker',s_markers(k2));
    end
    bdata = mean(all_data_2(:,:,:,k4),3,'omitnan');
    n_samples = sum(~isnan(all_data_2(:,:,:,k4)),3);
    std_data = std(all_data_2(:,:,:,k4),[],3,'omitnan');
    sem_data = std_data./sqrt(n_samples);
    for k2=1:length(list_tags)
        line('Xdata',x_position(:,k2)+.05,'YData',bdata(:,k2),'Parent',ax,'LineStyle','none','LineWidth',2,...
            'Marker','_','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
        line('Xdata',x_position(:,k2)+.05,'YData',bdata(:,k2)+sem_data(:,k2),'Parent',ax,'LineStyle','none','LineWidth',2,...
            'Marker','.','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
        line('Xdata',x_position(:,k2)+.05,'YData',bdata(:,k2)-sem_data(:,k2),'Parent',ax,'LineStyle','none','LineWidth',2,...
            'Marker','.','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
    end

    ax.Title.String = char(list_variables_2(k4));
    grid(ax,"on");
    l = legend(list_tags);
    ax.XTick = 1:length(list_animals);
    ax.XTickLabel = list_animals;
end

fclose(fid);
fprintf('Data saved in file %s\n',filename_out);

