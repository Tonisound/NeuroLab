function f2 = figure_Timed_Frames(myhandles,val,str_regions,str_tag)

global DIR_FIG DIR_SAVE FILES CUR_FILE IM LAST_IM;
load('Preferences.mat','GTraces');

if nargin<3
    str_regions = [];
    str_tag = [];
    %     str_group = [];
    %     str_traces = [];
end

%Time_Reference
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file')
    data_tr = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
else
    errordlg(sprintf('Missing File %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat')));
    return;
end

%Time_Tags
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'file')
    data_tt = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'));
%     list_tags = arrayfun(@(i) strjoin(data_tt.TimeTags_cell(i,2:4),' - '), 2:size(data_tt.TimeTags_cell,1), 'unif', 0)';
    list_tags = arrayfun(@(i) strjoin(data_tt.TimeTags_cell(i,2),' - '), 2:size(data_tt.TimeTags_cell,1), 'unif', 0)';
else
    errordlg(sprintf('Missing File %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat')));
    return;
end

if val==1
    % user mode
    [ind_tag,v] = listdlg('Name','Tag Selection','PromptString','Select Time Tags',...
        'SelectionMode','multiple','ListString',list_tags,'InitialValue','','ListSize',[300 500]);
    if v==0 || isempty(ind_tag)
        return;
    end
else
    % batch mode
    ind_tag = [];
    for i=1:length(str_tag)
        cur_tag = char(str_tag(i));
        ind_tag = [ind_tag;find(strcmp(list_tags,cur_tag)==1)];
    end
end

selected_tags = list_tags(ind_tag);
selected_strings = data_tt.TimeTags_strings(ind_tag,:);
temp1 = datenum(selected_strings(:,1));
temp2 = datenum(selected_strings(:,2));
selected_times = [(temp1-floor(temp1)),(temp2-floor(temp2))]*24*3600;
sampling_fus = median(diff(data_tr.time_ref.Y));
        

f2 = figure('Units','normalized',...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'MenuBar','figure',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Timed Frames Analysis');
f2.OuterPosition = [0 0 1 1/3];
% f2.OuterPosition = [0 0 1 1];

colormap(f2,'hot');

f2.UserData.success = false;

% Creating uitabgroup
fontSize = 8;
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',f2,...
    'Tag','TabGroup');

% Loading traces
if isempty(str_regions)
    all_lines  = findobj(myhandles.RightAxes,'Tag','Trace_Mean');
    str_actual_regions = {'Trace-Mean'};
else
    all_regions  = findobj(myhandles.RightAxes,'Tag','Trace_Region');
    all_lines = [];
    str_actual_regions = [];
    for i =1:length(all_regions)
        if sum(strcmp(all_regions(i).UserData.Name,str_regions))>0
            ind_region = find(strcmp(all_regions(i).UserData.Name,str_regions)==1);
            all_lines = [all_lines ;all_regions(ind_region)];
            str_actual_regions = [str_actual_regions;{all_regions(i).UserData.Name}];
        end
    end
end

% Masking NaN values
rows_nn = ~isnan(mean(mean(IM,3,'omitnan'),1,'omitnan'));
lines_nn = ~isnan(mean(mean(IM,3,'omitnan'),2,'omitnan'));
IM_NN = IM(lines_nn==1,rows_nn==1,:);


% Getting CLim
Yraw = IM_NN(~isnan(IM_NN));
n_iqr_max = 4;
n_iqr_min = 1;
clim1=median(Yraw(:))-n_iqr_min*iqr(Yraw(:));
clim2=median(Yraw(:))+n_iqr_max*iqr(Yraw(:));

all_time_vec = [];

for i=1:length(selected_tags)
    cur_tag = char(selected_tags(i));
    cur_tag_start = selected_times(i,1);
    cur_tag_end = selected_times(i,2);
    n_hours = ceil((cur_tag_end-cur_tag_start)/3600);
    
    for k=1:n_hours
        
        tab = uitab('Parent',tabgp,'Title',sprintf('%s-H%d',cur_tag,k));
        t_start = cur_tag_start + (k-1)*3600;
        t_end = min(t_start+3600-1,cur_tag_end);
        t_step = 10; %seconds
        n_im_step = round(t_step/sampling_fus);

        time_vec = t_start:t_step:t_end;
        all_time_vec = [all_time_vec,time_vec];
        n_col = 10;
        n_rows = ceil(length(time_vec)/n_col);

        for index = 1:length(time_vec)

            % Getting current index
            % index_row = ceil(index/n_col);
            % index_col = mod(index-1,n_col)+1;
            [gap_im,index_im] = min(abs(data_tr.time_ref.Y-time_vec(index)));
            % Sanity Check
            if gap_im>sampling_fus
                continue;
            end

            ax = subplot(n_rows,n_col,index,'Parent',tab);
%             ax.Position = get_position(n_rows,n_col,index);
            ax2 = copyobj(ax,tab);

            % Displaying single image
            flag_single=1;
            if flag_single
                imagesc(IM_NN(:,:,index_im),'Parent',ax);
                % im.AlphaData = .5;
                % Displaying mean values
            else
                im_start=max(1,round(index_im-n_im_step/2));
                im_end= min(LAST_IM,round(index_im+n_im_step/2));
                IM_mean = mean(IM_NN(:,:,im_start:im_end),3,'omitnan');
                imagesc(IM_mean,'Parent',ax);
            end

            % Getting XLim
            ax.XLim = [40 120];

            % Getting CLim
            ax.CLim = [clim1,clim2];
            ax.CLim = [0,150];%[-10,50];

            ax.Title.String = data_tr.time_str(index_im);
            set(ax,'XTick','','YTick','','XTickLabel','','YTickLabel','');
            ax.FontSize = fontSize;

            % ax2.Position(4)=.02;
            % ax2.Position(2)=ax.Position(2)-ax2.Position(4);
            set(ax2,'XTick','','YTick','','XTickLabel','','YTickLabel','');
            flag_lines=0;
            if flag_lines
                for j=1:length(all_lines)
                    l_new = copyobj(all_lines(j),ax2);
                    l_new.LineWidth=2;
                    l_new.Visible='on';
                    if length(all_lines)==1
                        l_new.Color='r';
                    end
                end
            end
            ax2.XLim = [index_im-n_im_step/2,index_im+n_im_step/2];
            ax2.XLim = [index_im-n_im_step/2,index_im+n_im_step/2];
            ax2.YLim = ax.CLim;
            ax2.Visible='off';
        end

        % Colorbar
        leg = legend(ax2,str_actual_regions);
        leg.Position=[0 .0 .1 .05];

        % Colorbar
        cbar = colorbar(ax,'east');
        cbar.Position=[.925 .1125 .01 .1];

        % Saving Images
        tabgp.SelectedTab = tab;
        save_dir = fullfile(DIR_FIG,'TimedFrames',FILES(CUR_FILE).nlab);
        if ~isfolder(save_dir)
            mkdir(save_dir);
        end
        pic_name = strcat(sprintf('%s_%s',FILES(CUR_FILE).nlab,tab.Title));
        saveas(f2,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
        fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
    end
end

% Concatenated Display
flag_concatenate = false;
if flag_concatenate
    tab = uitab('Parent',tabgp,'Title','Concatenated');
    n_col = 10;
    n_rows = ceil(length(all_time_vec)/n_col);
    for index = 1:length(all_time_vec)

        % Getting current index
        % index_row = ceil(index/n_col);
        % index_col = mod(index-1,n_col)+1;
        [gap_im,index_im] = min(abs(data_tr.time_ref.Y-all_time_vec(index)));
        % Sanity Check
        if gap_im>sampling_fus
            continue;
        end

        ax = subplot(n_rows,n_col,index,'Parent',tab);
        % ax.Position = get_position(n_rows,n_col,index);
        ax2 = copyobj(ax,tab);

        % Displaying single image
        flag_single=1;
        if flag_single
            imagesc(IM_NN(:,:,index_im),'Parent',ax);
            % im.AlphaData = .5;
            % Displaying mean values
        else
            im_start=max(1,round(index_im-n_im_step/2));
            im_end= min(LAST_IM,round(index_im+n_im_step/2));
            IM_mean = mean(IM_NN(:,:,im_start:im_end),3,'omitnan');
            imagesc(IM_mean,'Parent',ax);
        end

        % Getting XLim
        ax.XLim = [40 120];

        % Getting CLim
        ax.CLim = [clim1,clim2];
        ax.CLim = [0,150];%[-10,50];

        ax.Title.String = data_tr.time_str(index_im);
        set(ax,'XTick','','YTick','','XTickLabel','','YTickLabel','');
        ax.FontSize = fontSize;

        % ax2.Position(4)=.02;
        % ax2.Position(2)=ax.Position(2)-ax2.Position(4);
        set(ax2,'XTick','','YTick','','XTickLabel','','YTickLabel','');
        ax2.XLim = [index_im-n_im_step/2,index_im+n_im_step/2];
        ax2.XLim = [index_im-n_im_step/2,index_im+n_im_step/2];
        ax2.YLim = ax.CLim;
        ax2.Visible='off';
    end

    % Colorbar
    leg = legend(ax2,str_actual_regions);
    leg.Position=[0 .0 .1 .05];
    % Colorbar
    cbar = colorbar(ax,'east');
    cbar.Position=[.925 .1125 .01 .1];
    % Saving Images
    tabgp.SelectedTab = tab;
    save_dir = fullfile(DIR_FIG,'TimedFrames',FILES(CUR_FILE).nlab);
    if ~isfolder(save_dir)
        mkdir(save_dir);
    end
    pic_name = strcat(sprintf('%s_%s',FILES(CUR_FILE).nlab,tab.Title));
    saveas(f2,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
    fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
end

f2.UserData.success = true;

% % Closing figure in batch mode
% if val==0
%     close(f2);
% end

end