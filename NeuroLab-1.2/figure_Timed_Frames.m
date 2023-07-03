function f2 = figure_Timed_Frames(myhandles,val,str_regions)

global DIR_FIG DIR_SAVE FILES CUR_FILE IM LAST_IM;
load('Preferences.mat','GTraces');

if nargin<3
    str_regions = [];
    %     str_tag = [];
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
f2.OuterPosition = [0 0 1 1];
colormap(f2,'gray');

f2.UserData.success = false;

% Creating uitabgroup
fontSize = 8;
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',f2,...
    'Tag','TabGroup');

% getting recording length
n_hours = ceil((data_tr.time_ref.Y(end)-data_tr.time_ref.Y(1))/3600);
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


for k=1:n_hours
    tab = uitab('Parent',tabgp,'Title',sprintf('Hour-%d',k));

    t_start = (k-1)*60*60+data_tr.time_ref.Y(1);
    t_end = t_start+60*60-1;
    t_step = 60; %seconds
    n_im_step = round(t_step/(data_tr.time_ref.Y(2)-data_tr.time_ref.Y(1)));

    time_vec = t_start:t_step:t_end;
    n_col = 10;
    n_rows = ceil(length(time_vec)/n_col);
    n_max = n_col*n_rows;

    for index = 1:length(time_vec)

        % Getting current index
        % index_row = ceil(index/n_col);
        % index_col = mod(index-1,n_col)+1;
        [m,index_im] = min(abs(data_tr.time_ref.Y-time_vec(index)));
        % Sanity Check
        if m>data_tr.time_ref.Y(2)-data_tr.time_ref.Y(1)
            continue;
        end

        ax = subplot(n_rows,n_col,index,'Parent',tab);
        ax2 = copyobj(ax,tab);

        % Displaying single image
        flag_single=1;
        im_start=max(1,round(index_im-n_im_step/2));
        im_end= min(LAST_IM,round(index_im+n_im_step/2));
        if flag_single
            imagesc(IM_NN(:,:,index_im),'Parent',ax);
            % im.AlphaData = .5;
            % Displaying mean values
        else
            IM_mean = mean(IM_NN(:,:,im_start:im_end),3,'omitnan');
            imagesc(IM_mean,'Parent',ax);
        end

        % Getting XLim
        ax.XLim = [40 120];

        % Getting CLim
        ax.CLim = [clim1,clim2];
        ax.CLim = [-20,100];

        ax.Title.String = data_tr.time_str(index_im);
        set(ax,'XTick','','YTick','','XTickLabel','','YTickLabel','');
        ax.FontSize = fontSize;

        % ax2.Position(4)=.02;
        % ax2.Position(2)=ax.Position(2)-ax2.Position(4);
        set(ax2,'XTick','','YTick','','XTickLabel','','YTickLabel','');
        flag_lines=0;
        if flag_lines
            for i=1:length(all_lines)
                l_new = copyobj(all_lines(i),ax2);
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

f2.UserData.success = true;

% % Closing figure in batch mode
% if val==0
%     close(f2);
% end

end