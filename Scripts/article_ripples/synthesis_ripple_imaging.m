% Script reorganizing Ripple_Imaging image folder
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
for i=1:length(unique_animals)
    if ~isdir(fullfile(folder_dest,char(unique_animals(i))))
        mkdir(fullfile(folder_dest,char(unique_animals(i))));
    end
end

% Moving figures
all_filetypes = {'Dynamics';'Regions';'Ripple-Imaging';'Sequence';'Synthesis';'Trials'};
for i=1:length(all_files)
    for j=1:length(all_filetypes)
        filetype = char(all_filetypes(j));
        dd = dir(fullfile(folder_source_figs,char(all_files(i)),strcat('*',filetype,'*')));
        for j=1:length(dd)
            dd_dest = fullfile(folder_dest,char(all_animals(i)),filetype);
            if ~isdir(dd_dest)
                mkdir(dd_dest)
            end
            copyfile(fullfile(dd(j).folder,dd(j).name),fullfile(dd_dest,dd(j).name))
            fprintf('File copied [%s] ---> [%s].\n',dd(j).name,dd_dest);
        end
    end
end

% Browsing stats - Buidling struct
S = struct('data',[],'name',[],'atlas_name',[],'atlas_coordinate',[],'data_atlas',[]);
all_coordinates = [];

for i=1:length(all_files)
    dd = dir(fullfile(folder_source_stats,char(all_files(i)),'*Ripple-Imaging*'));
    for j=1:length(dd)
        %         copyfile(fullfile(dd(j).folder,dd(j).name),fullfile(dd_dest,dd(j).name))
        %         fprintf('File copied [%s] ---> [%s].\n',dd(j).name,dd_dest);
        fprintf('Loading file [%s] ...',dd(j).name);
        data = load(fullfile(dd(j).folder,dd(j).name),'Y3q_rip_reshaped','t_bins_fus','atlas_coordinate','atlas_name','data_atlas');%,'n_ripples'
        fprintf(' done.\n');
        S(i).data = data.Y3q_rip_reshaped;
        S(i).name = strrep(d(i).name,'_nlab_Ripple-Imaging.mat','');
        S(i).animal = char(all_animals(i));
        S(i).atlas_coordinate = data.atlas_coordinate;
        S(i).atlas_name = data.atlas_name;
        S(i).data_atlas = data.data_atlas;
%         S(i).n_ripples = data.n_ripples;
        S(i).n_ripples = 1000;
        t_bins_fus = data.t_bins_fus;
        all_coordinates = [all_coordinates;data.atlas_coordinate];
    end
end
% Sorting S
[~,ind_sorted] = sort(all_coordinates,'descend');
S = S(ind_sorted);


% Displaying synthesis movie
for j=1:length(unique_animals)
    cur_animal = char(unique_animals(j));
    S_animal = S(strcmp({S(:).animal}',cur_animal)==1);
    n_col = 6;
    n_rows = ceil(length(S_animal)/n_col);
%     eps1=.01;
%     eps2=.01;
    
    f = figure('Units','normalized','OuterPosition',[0 0 1 1]);
    colormap(f,"parula");
    f_axes = [];
    for i=1:length(S_animal)
        ax = axes('Parent',f);
        ax.Position = get_position(n_rows,n_col,i,[.05,.05,.01;.05,.05,.02]);
        f_axes = [f_axes;ax];
    end

    work_dir = fullfile(folder_dest,cur_animal,strcat('Frames-',cur_animal));
    if isfolder(work_dir)
        rmdir(work_dir,'s');
    end
    mkdir(work_dir);

    for k=1:length(t_bins_fus)
        for i=1:length(f_axes)

            ax = f_axes(i);
            hold(ax,'on');
            imagesc(S_animal(i).data(:,:,k),'Parent',ax);
            ax.Title.String = strcat(S_animal(i).atlas_name,sprintf(' n=%d ',S_animal(i).n_ripples),sprintf(' t=%.1f s',t_bins_fus(k)));

            l = line('XData',S_animal(i).data_atlas.line_x,'YData',S_animal(i).data_atlas.line_z,'Tag','AtlasMask',...
                'LineWidth',.5,'Color','r','Parent',ax);
            l.Color(4)=.5;

            % ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
            ax.CLim = [-5,10];
            ax.XLim = [.5 size(S_animal(i).data,2)+.5];
            ax.YLim = [.5 size(S_animal(i).data,1)+.5];

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

    close(f);
    video_name = strcat('Ripple-Synthesis_',cur_animal);
    save_video(work_dir,folder_dest,video_name);
%     rmdir(work_dir,'s');
end