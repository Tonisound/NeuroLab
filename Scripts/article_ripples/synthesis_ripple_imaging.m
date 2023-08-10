%% Script reorganizing Ripple_Imaging image folder
% generate a synthesis video of fUS ripple activations

global DIR_SYNT DIR_FIG DIR_STATS;
load('Preferences.mat','GTraces');


folder_source_figs = fullfile(DIR_FIG,'Ripple_Imaging');
if ~isdir(folder_source_figs)
    errordlg(sprintf('Not a directory [%s]',folder_source_figs));
    return;
end
folder_source_stats = fullfile(DIR_STATS,'Ripple_Imaging');
if ~isdir(folder_source_stats)
    errordlg(sprintf('Not a directory [%s]',folder_source_stats));
    return;
end

folder_dest = fullfile(DIR_SYNT,'Ripple_Imaging');
if ~isdir(folder_dest)
    mkdir(folder_dest);
end

% Listing files
d = dir(folder_source_figs);
% Removing hidden files
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
all_files = {d(:).name}';

% Listing animals 
all_animals = cell(size(all_files));
for i=1:length(all_files)
    temp = regexp(char(all_files(i)),'_','split');
    all_animals(i)=temp(2);
end
unique_animals = unique(all_animals);


% Browsing stats - Buidling struct
S = struct('Y3q_rip_full',[],'name',[],'atlas_name',[],'atlas_coordinate',[],'data_atlas',[]);
% Listing planes 
all_planes = cell(size(all_files));
all_coordinates = NaN(size(all_files));
label_Y3q_rip_full = {'Mean';'Median';'Longest';'Fastest';'Largest'};

for i=1:length(all_files)
    dd = dir(fullfile(folder_source_stats,char(all_files(i)),'*Ripple-Imaging*'));
    for j=1:length(dd)
        %         copyfile(fullfile(dd(j).folder,dd(j).name),fullfile(dd_dest,dd(j).name))
        %         fprintf('File copied [%s] ---> [%s].\n',dd(j).name,dd_dest);
        fprintf('Loading file [%s] ...',dd(j).name);
            data = load(fullfile(dd(j).folder,dd(j).name),'Y3q_rip_reshaped','Y3q_rip_median_reshaped','Y3q_rip_duration_reshaped','Y3q_rip_frequency_reshaped','Y3q_rip_amplitude_reshaped',...
                'Yraw_rip_','t_bins_fus','t_bins_lfp','atlas_coordinate','atlas_name','data_atlas','n_ripples','channel_id','mean_dur','mean_freq','mean_p2p');
%         try
%         catch
%             warning('Unable to load file [%s]',fullfile(dd(j).folder,dd(j).name));
%             continue;
%         end
        fprintf(' done.\n');


        S(i).Y3q_rip_full = cat(4,data.Y3q_rip_reshaped,data.Y3q_rip_median_reshaped,data.Y3q_rip_duration_reshaped,data.Y3q_rip_frequency_reshaped,data.Y3q_rip_amplitude_reshaped);
%         S(i).Y3q_rip_reshaped = data.Y3q_rip_reshaped;
%         S(i).Y3q_rip_median_reshaped = data.Y3q_rip_median_reshaped;
%         S(i).Y3q_rip_duration_reshaped = data.Y3q_rip_duration_reshaped;
%         S(i).Y3q_rip_frequency_reshaped = data.Y3q_rip_frequency_reshaped;
%         S(i).Y3q_rip_amplitude_reshaped = data.Y3q_rip_amplitude_reshaped;
        S(i).Yraw_rip_ = data.Yraw_rip_;
        S(i).t_bins_fus = data.t_bins_fus;
        S(i).t_bins_lfp = data.t_bins_lfp;
        S(i).name = strrep(strrep(d(i).name,'_nlab',''),'_','-');
        S(i).animal = char(all_animals(i));
        S(i).atlas_coordinate = data.atlas_coordinate;
        S(i).atlas_name = data.atlas_name;
        S(i).data_atlas = data.data_atlas;
        S(i).plane = strtrim(strrep(strrep(data.data_atlas.AtlasName,'Rat',''),'Paxinos',''));
        S(i).n_ripples = data.n_ripples;
        S(i).channel_id = data.channel_id;
        S(i).mean_dur = data.mean_dur;
        S(i).mean_freq = data.mean_freq;
        S(i).mean_p2p = data.mean_p2p;

        t_bins_fus = data.t_bins_fus;
        all_coordinates(i) = data.atlas_coordinate;
        all_planes(i) = {strtrim(strrep(strrep(data.data_atlas.AtlasName,'Rat',''),'Paxinos',''))};
    end
end
% Sorting S
[~,ind_sorted] = sort(all_coordinates,'descend');
S = S(ind_sorted);

% Building files
unique_planes = unique(all_planes);
for i=1:length(unique_animals)
    for j=1:length(unique_planes)
        if ~isdir(fullfile(folder_dest,strcat(char(unique_animals(i)),'-',char(unique_planes(j)))))
            mkdir(fullfile(folder_dest,strcat(char(unique_animals(i)),'-',char(unique_planes(j)))));
        end
    end
end


% Moving figures
all_filetypes = {'Dynamics';'Regions';'Ripple-Imaging';'Synthesis';'Trials';...
    'Sequence-Mean';'Sequence-Median';'Sequence-Largest';'Sequence-Fastest';'Sequence-Longest'};
for i=1:length(all_files)
    for j=1:length(all_filetypes)
        filetype = char(all_filetypes(j));
        dd = dir(fullfile(folder_source_figs,char(all_files(i)),strcat('*',filetype,'*')));
        for j=1:length(dd)
            dd_dest = fullfile(folder_dest,strcat(char(all_animals(i)),'-',char(all_planes(i))),filetype);
            if ~isdir(dd_dest)
                mkdir(dd_dest)
            end
            copyfile(fullfile(dd(j).folder,dd(j).name),fullfile(dd_dest,dd(j).name))
            fprintf('File copied [%s] ---> [%s].\n',dd(j).name,dd_dest);
        end
    end
end



%% Displaying synthesis movie
for j=1:length(unique_animals)
    cur_animal = char(unique_animals(j));
    S_animal = S(strcmp({S(:).animal}',cur_animal)==1);

    for jj=1:length(unique_planes)
        cur_plane = char(unique_planes(jj));
        S_animal_plane = S_animal(strcmp({S_animal(:).plane}',cur_plane)==1);

        % Sanity Check
        if isempty(S_animal_plane)
            continue;
        end

        % n_col = 6;
        n_col = ceil(1.2*sqrt(length(S_animal_plane)));
        n_rows = ceil(length(S_animal_plane)/n_col);
        % eps1=.01;
        % eps2=.01;

        for l=1:length(label_Y3q_rip_full)
            cur_label = char(label_Y3q_rip_full(l));
            f = figure('Units','normalized','OuterPosition',[0 0 1 1],'Name',strcat('Ripple-Synthesis_',cur_animal,'-',cur_plane,'_',cur_label));
            colormap(f,"parula");
            f_axes = [];
            for i=1:length(S_animal_plane)
                ax = axes('Parent',f);
                ax.Position = get_position(n_rows,n_col,i,[.05,.05,.01;.05,.05,.02]);
                f_axes = [f_axes;ax];
            end
            t = uicontrol(f,'Style','text','BackgroundColor','w','FontSize',16,'FontWeight','bold',...
                'Units','normalized','Position',[.25 .96 .5 .03],'Parent',f);

            work_dir = fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat('Frames-',cur_animal,'-',cur_plane,'_',cur_label));
            if isfolder(work_dir)
                rmdir(work_dir,'s');
            end
            mkdir(work_dir);

            for k=1:length(t_bins_fus)
                for i=1:length(f_axes)
                    ax = f_axes(i);
                    hold(ax,'on');
                    imagesc(S_animal_plane(i).Y3q_rip_full(:,:,k,l),'Parent',ax);
                    ax.Title.String = sprintf('%s [N = %d]',S_animal_plane(i).atlas_name,S_animal_plane(i).n_ripples);
                    ax.YLabel.String = S_animal_plane(i).name;
                    ax.YLabel.FontSize = 8;
                    t.String = sprintf('[%s] Time from Ripple Peak = %.1f s',cur_label,t_bins_fus(k));
                    l_ = line('XData',S_animal_plane(i).data_atlas.line_x,'YData',S_animal_plane(i).data_atlas.line_z,'Tag','AtlasMask',...
                        'LineWidth',.5,'Color','r','Parent',ax);
                    l_.Color(4)=.5;
                    % ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                    ax.CLim = [-5,10];
                    ax.XLim = [.5 size(S_animal_plane(i).Y3q_rip_full,2)+.5];
                    ax.YLim = [.5 size(S_animal_plane(i).Y3q_rip_full,1)+.5];
                    set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                    ax.YDir = 'reverse';
                    if i ==length(f_axes)
                        pos = ax.Position;
                        c = colorbar(ax,"eastoutside");
                        c.Position(1) = pos(1)+pos(3)+.01;
                    end
                end
                pic_name = sprintf(strcat('Ripple-Synthesis_%03d.mat'),k);
                saveas(f,fullfile(work_dir,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
            end

            video_name = strcat('Ripple-Synthesis_',cur_animal,'-',cur_plane,'_',cur_label);
            save_video(work_dir,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane)),video_name);
%             rmdir(work_dir,'s');
            close(f);
        end
    end
end


%% Displaying ripple detection
for j=1:length(unique_animals)
    cur_animal = char(unique_animals(j));
    S_animal = S(strcmp({S(:).animal}',cur_animal)==1);

    for jj=1:length(unique_planes)
        cur_plane = char(unique_planes(jj));
        S_animal_plane = S_animal(strcmp({S_animal(:).plane}',cur_plane)==1);

        % Sanity Check
        if isempty(S_animal_plane)
            continue;
        end

        n_col = ceil(1.2*sqrt(length(S_animal_plane)));
        n_rows = ceil(length(S_animal_plane)/n_col);

        f = figure('Units','normalized','OuterPosition',[0 0 1 1],'Name',strcat('Ripple-Detection_',cur_animal,'-',cur_plane));
        colormap(f,"parula");
        f_axes = [];
        for i=1:length(S_animal_plane)
            ax = axes('Parent',f);
            ax.Position = get_position(n_rows,n_col,i,[.05,.05,.01;.05,.05,.02]);
            f_axes = [f_axes;ax];
        end

        for i=1:length(f_axes)
            ax = f_axes(i);
            hold(ax,'on');
            % Displaying ripple detection
            % Raw Trace
            hold(ax,'on');
            for ii=1:S_animal_plane(i).n_ripples
                l=line('XData',S_animal_plane(i).t_bins_lfp,'YData',S_animal_plane(i).Yraw_rip_(:,ii),'Color','k','LineWidth',.1,'Parent',ax);
                l.Color(4)=.5;
            end
            line('XData',S_animal_plane(i).t_bins_lfp,'YData',mean(S_animal_plane(i).Yraw_rip_,2,'omitnan'),'Color','r','LineWidth',2,'Parent',ax);
            ax.Title.String = sprintf('Channel %s [N=%d]',S_animal_plane(i).channel_id,S_animal_plane(i).n_ripples);
%             ax.Title.String = sprintf('%s [N = %d]',S_animal_plane(i).atlas_name,S_animal_plane(i).n_ripples);
            ax.YLabel.String = S_animal_plane(i).name;
            ax.YLabel.FontSize = 8;
            n_iqr = 3;
            Yraw_rip = S_animal_plane(i).Yraw_rip_(:);
            data_iqr = Yraw_rip(~isnan(Yraw_rip));
            ax.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
            ax.XLim = [-.1 .1];
            set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);

%             % Filtered Trace
%             ax2 = subplot(323,'parent',tab2);
%             hold(ax2,'on');
%             for i=1:n_events
%                 l=line('XData',t_bins_lfp,'YData',Y1_rip_(:,i),'Color',[.5 .5 .5],'LineWidth',.1,'Parent',ax2);
%                 l.Color(4)=.5;
%             end
%             line('XData',t_bins_lfp,'YData',mean(Y1_rip_,2,'omitnan'),'Color','r','Parent',ax2);
%             ax2.Title.String = 'Filtered trace LFP';
%             n_iqr= 20;
%             data_iqr = Y1_rip_(~isnan(Y1_rip_));
%             ax2.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
%             ax2.XLim = [-.1 .5];
% 
%             % Spectrogram
%             ax3 = subplot(325,'parent',tab2);
%             hold(ax3,'on');
%             Cdata_mean = mean(Cdata_rip_,3,'omitnan');
%             imagesc('XData',t_bins_lfp,'YData',data_spectro.freqdom,'CData',Cdata_mean,'HitTest','off','Parent',ax3);
% 
%             n_iqr= 2;
%             data_iqr = Cdata_mean(~isnan(Cdata_mean));
%             ax3.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
%             ax3.YLim = [data_spectro.freqdom(1),data_spectro.freqdom(end)];
%             % ax3.XLim = [t_bins_lfp(1),t_bins_lfp(end)];
%             ax3.XLim = [-.1 .5];
%             ax3.Title.String = 'Mean Spectrogram';
        end

        pic_name = sprintf(strcat('Ripple-Detection-Synthesis','_',cur_animal,'-',cur_plane));
        saveas(f,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        close(f);
    end
end