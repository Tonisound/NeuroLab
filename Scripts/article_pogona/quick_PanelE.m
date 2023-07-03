global DIR_STATS;

folder_data = fullfile(DIR_STATS,'Auto-Correlation');
list_regions = {'Whole-reg'};
list_tags = {'WAKE';'SLEEP'};
list_animals = {'P1';'P2';'P3'};

d = dir(fullfile(folder_data,'*','*_Auto-Correlation_*'));
S = struct('all_r',[],'all_peak_times',[],'region',[],'tag',[],'animal',[]);
S(length(list_animals),length(list_tags),length(list_regions)).all_r=[];

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
                        index_regions = find(strcmp(data_ac.label_regions,cur_region)==1);

                        if ~isempty(index_regions)
                            % Region found
                            all_r = data_ac.all_r_regions(index_regions,:);
                            lags = data_ac.Params.lags;
                            try
                                peak_time = lags(data_ac.all_locs_regions(index_regions));
                            catch
                                peak_time = NaN;
                            end
                            S(k1,k2,k3).all_r=[S(k1,k2,k3).all_r;all_r];
                            S(k1,k2,k3).all_peak_times=[S(k1,k2,k3).all_peak_times;peak_time];
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

% f=figure;
% counter = 0;
% for k1=1:length(list_animals)
%     for k2=1:length(list_tags)
%         counter =counter+1;
%         ax = subplot(length(list_animals),length(list_tags),counter);
%         for i=1:size(S(k1,k2,1).all_r,1)
%             line('XData',lags,'YData',S(k1,k2,1).all_r(i,:),'Parent',ax);
%         end
%         ax.Title.String = sprintf('%s - %s',char(list_animals(k1)),char(list_tags(k2)));
%     end
% end

g_colors = get(groot,'defaultAxesColorOrder');
f=figure;
counter = 0;
for k2=1:length(list_tags)
    for k1=1:length(list_animals)
        counter =counter+1;
        ax = subplot(length(list_tags),length(list_animals),counter);
        for i=1:size(S(k1,k2,1).all_r,1)
            line('XData',lags,'YData',S(k1,k2,1).all_r(i,:),'Parent',ax,'Color',g_colors(k1,:));
        end
        ax.Title.String = sprintf('%s - %s',char(list_animals(k1)),char(list_tags(k2)));
        ax.YLim = [-.5 1];
        grid(ax,'on');
    end
end
