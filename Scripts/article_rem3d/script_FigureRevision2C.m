% Article REM 3d - Revised Figure 2
% Vascular Surges Statistics Per Region

function script_FigureRevision2C(rec_list,reg_group)
% rec_list = CORONAL|SAGITTAL|ALL
% reg_group = GROUPS|RIGHT-GROUPS|LEFT-GROUPS|VESSEL-GROUPS

close all;

if nargin <1
    rec_list = 'ALL';
end
if nargin <2
    reg_group = 'GROUPS';
end

% Generate Lists
L = get_lists(rec_list,reg_group);
fName = sprintf('RevisedFig2C_%s-%s',rec_list,reg_group);
folder_save = fullfile(pwd,'RevisedFigure2');
if ~exist(folder_save,'dir')
    mkdir(folder_save);
end
list_group = {'REM-TONIC';'REM-PHASIC';};

% Storing
L.list_group = list_group;
L.fName = fName;
L.folder_save = folder_save;
L.rec_list = rec_list;
L.reg_group = reg_group;
% list_location = {'anterior';'intermediate';'posterior';'medial';'lateral'};
list_location = {'ANTERIOR';'INTERMEDIATE';'POSTERIOR';'MEDIAL';'LATERAL'};
L.list_location = list_location;

% Loading/Browsing data
if exist(fullfile(folder_save,strcat(fName,'.mat')),'file')
    fprintf('Loading [%s]... ',fName);
    load(fullfile(folder_save,strcat(fName,'.mat')),'S','P');
    fprintf(' done.\n');
    fprintf('Data Loaded [%s-%s] (%d files)\n',L.rec_list,L.reg_group,length(L.list_files));
else
    [S,P] = browse_data(L);
end

% Plotting/Saving Data
only_txt = false;
% tt_data = plot1(L,P,S);
tt_data = plot2(L,P,S,'Mean','Recording',only_txt);
tt_data = plot2(L,P,S,'Mean','Episode',only_txt);

end

function [S,P] = browse_data(L)

global DIR_SAVE;

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
list_group = L.list_group;
list_files = L.list_files;

% Buidling struct S
S = struct('mean_per_rec',[],'median_per_rec',[],...
    'mean_per_ep',[],'median_per_ep',[],...
    'y_data',[],'y_data_ep',[],...
    'group','','region','','recording','');
S(length(list_group),length(list_regions)).recording = [];

counter = 0;

% Browsing files
for index = 1:length(list_files)
    
    cur_file = char(list_files(index));
    
    % Loading Time_Surges
    d = dir(fullfile(DIR_SAVE,cur_file,'Time_Surges.mat'));
    if isempty(d)
        warning('Absent file Time_Surges.mat [File: %s]',cur_file);
        continue;
    end
    fprintf('Loading Time Surges [File: %s (%d/%d)] ... ',cur_file,index,length(list_files));
    data_surges = load(fullfile(DIR_SAVE,cur_file,'Time_Surges.mat'),...
        'Doppler_Surge','ind_surge','ind_tonic','REM_images','TimeTags');
    
%     % Loading Atlas
%     dd = dir(fullfile(DIR_SAVE,cur_file,'Atlas.mat'));
%     if isempty(dd)
%         warning('Absent file Atlas.mat [File: %s]',cur_file);
%         continue;
%     end
%     fprintf('Loading Atlas [File: %s] ...',cur_file);
%     data_atlas = load(fullfile(DIR_SAVE,cur_file,'Atlas.mat'));
    fprintf(' done.\n');
    
    % Listing Regions
    ddd = dir(fullfile(DIR_SAVE,cur_file,'Sources_fUS','*.mat'));
    if isempty(ddd)
        warning('No Regions found [File: %s]',cur_file);
        continue;
    end
    available_regions = strrep({ddd(:).name}','.mat','');
    
    % Counter
    counter = counter+1;
    Doppler_Surge = data_surges.Doppler_Surge;
    ind_surge = data_surges.ind_surge;
    ind_tonic = data_surges.ind_tonic;
    ind_rem = data_surges.REM_images;
    index_phasic = find(data_surges.ind_surge==1);
    index_tonic = find(data_surges.ind_tonic==1);
    index_rem = find(data_surges.REM_images==1);
    
    % Finding all REM episodes
    TimeTags = data_surges.TimeTags;
    if isempty(TimeTags(1).Tag)
        warning('Empty TimeTags [File: %s]',cur_file);
    else
        TimeTags_REM = TimeTags(startsWith({TimeTags(:).Tag}','REM-')==1);
        TimeTags_TONIC = TimeTags(startsWith({TimeTags(:).Tag}','REMTONIC-')==1);
        TimeTags_PHASIC = TimeTags(startsWith({TimeTags(:).Tag}','REMPHASIC-')==1);
    end
    temp = find(diff(index_rem)>1);
    index_start = [index_rem(1);index_rem(temp+1)];
    index_end = [index_rem(temp);index_rem(end)];
    
    % Setting zero-values
    Doppler_Surge(Doppler_Surge==-1)=0;
    
    % Browsing groups
    for i=1:length(list_group)
        
        cur_group = char(list_group(i));
        if strcmp(cur_group,'REM-TONIC')
            index_frames = index_tonic;
            ind_frames = ind_tonic;
        elseif strcmp(cur_group,'REM-PHASIC')
            index_frames = index_phasic;
            ind_frames = ind_surge;
        elseif strcmp(cur_group,'REM')
            index_frames = index_rem;
            ind_frames = ind_rem;
        end
        
        % Browsing regions
        for j=1:length(list_regions)
                
            cur_region = char(list_regions(j));
%             fprintf('Collecting Data [Region: %s].\n',cur_region);
            
            if sum(strcmp(cur_region,available_regions)>0)
                data_mask = load(fullfile(DIR_SAVE,cur_file,'Sources_fUS',strcat(cur_region,'.mat')),'mask');
                cur_mask = data_mask.mask;
            else
                continue;
            end
            
            % Setting zero values to NaN
            cur_mask(cur_mask==0)=NaN;
            
            % Applying mask to Doppler_Surge
            Doppler_masked = Doppler_Surge.*repmat(cur_mask,[1,1,size(Doppler_Surge,3)]);
            Doppler_reshaped = reshape(Doppler_masked,size(Doppler_masked,1)*size(Doppler_masked,2),1,size(Doppler_masked,3));
            y_data = (mean(squeeze(Doppler_reshaped),1,'omitnan'))';
            
            % Full y_data
            y_data_rec = y_data(index_frames);
            mean_rec = mean(y_data_rec(:),'omitnan');
            median_rec = median(y_data_rec(:),'omitnan');
            % Emit warning if NaN found
            if isnan(mean_rec)
                warning('NaN value mean [File: %s, Region: %s].',cur_file,cur_region);
                continue;
            end
            if isnan(median_rec)
                warning('NaN value median [File: %s, Region: %s].',cur_file,cur_region);
                continue;
            end
            
            % Browsing episodes
            all_y_data_ep = [];
            all_mean_ep = [];
            all_median_ep = [];
            for k=1:length(index_start)
                
                ind_episode = zeros(size(ind_rem));
                ind_episode(index_start(k):index_end(k))=1;
                index_restrict = find(ind_frames.*ind_episode==1);
%                 if isempty(index_restrict)
%                     warning('Empty restriction [File: %s, Group: %s, Region: %s, Episode: %d].',cur_file,cur_group,cur_region,k);
%                 end
                % Restrict y_data to episode
                if ~isempty(index_restrict)
                    y_data_ep = y_data(index_restrict);
                    mean_ep = mean(y_data_ep(:),'omitnan');
                    median_ep = median(y_data_ep(:),'omitnan');
                    
                    all_y_data_ep = [all_y_data_ep ; y_data_ep];
                    all_mean_ep = [all_mean_ep ; mean_ep];
                    all_median_ep = [all_median_ep ; median_ep];
                
                end
            end
            
            % Getting data
            S(i,j).group = cur_group;
            S(i,j).region = cur_region;
            S(i,j).recording = [S(i,j).recording;{cur_file}];
            S(i,j).y_data = [S(i,j).y_data;y_data_rec];
            S(i,j).mean_per_rec = [S(i,j).mean_per_rec;mean_rec];
            S(i,j).median_per_rec = [S(i,j).median_per_rec;median_rec];
            S(i,j).y_data_ep = [S(i,j).y_data_ep;all_y_data_ep];
            S(i,j).mean_per_ep = [S(i,j).mean_per_ep;all_mean_ep];
            S(i,j).median_per_ep = [S(i,j).median_per_ep;all_median_ep];

        end
    end
end
fprintf('Data Browsed [%d files loaded].\n',counter);

% Setting Parameters
f = figure('Visible','off');
colormap(f,'parula');
P.Colormap = f.Colormap;
%uncomment if list_regions is not ALL
P.f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
% % comment if list_regions is not ALL
% ind_colors = [1,2,3,4,5,6,7,8,9,10,11,12,13,25,27,28,29,30,38,39,40,46,47,48,49,50,51,52,53,61,62,63,64];
% P.f_colors = f.Colormap(ind_colors,:);
% P.f_colors = f.Colormap;
close(f);

P.margin_w = .01;
P.margin_h = .02;
P.n_columns = length(list_group);
P.n_rows = 1;
P.val1 = -1;
P.val2 = 1;
P.tick_width =.5;
P.thresh_average = .5;
P.all_markers = {'none';'none';'none'};
P.all_linestyles = {'--';':';'-'};
P.patch_alpha = .1;

% Saving Data
save(fullfile(folder_save,strcat(fName,'.mat')),'L','S','P','-v7.3');
fprintf('Data Saved [%s]\n',fullfile(folder_save,strcat(fName,'.pdf')));

end

function tt_data = plot1(L,P,S)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
list_group = L.list_group;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
ax = axes('Parent',panel,'Position',[.1 .1 .8 .8]);
ax_dummy = axes('Parent',panel,'Position',[.1 .1 .8 .8],'Visible','off');
clrmenu(f);
f.Name = strcat(fName,'-A');
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
% f.PaperPositionMode='auto';

f.Colormap = P.Colormap;
f_colors = P.f_colors;
margin_w = P.margin_w;
margin_h = P.margin_h;
n_columns = P.n_columns;
n_rows = P.n_rows;
val1 = P.val1;
val2 = P.val2;
tick_width = P.tick_width;
thresh_average = P.thresh_average;
all_markers = P.all_markers;
all_linestyles = P.all_linestyles;
patch_alpha = P.patch_alpha;


% Getting data
m = 0;
for i =1:length(list_group)
    for j = 1:length(list_regions)
        m = max(m,length(S(i,j).y_data));
    end
end
n_samples = NaN(length(list_group),length(list_regions));
n_recordings = NaN(length(list_group),length(list_regions));
tt_data = NaN(m,length(list_regions),length(list_group));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        temp = S(i,j).y_data;
        n_samples(i,j)=sum(~isnan(temp))/1000;
        n_recordings(i,j)=sum(~isnan(S(i,j).mean_per_rec));
        tt_data(1:length(temp),j,i) = temp;
    end
end

dummy_data = rand(length(list_group),length(list_regions));
xtick_labs = list_group;
% str_recordings = regexp(sprintf('%d-',n_recordings(1,:)),'-','split');
% str_samples1 = regexp(sprintf('%d-',n_samples(1,:)),'-','split');
% str_samples2 = regexp(sprintf('%d-',n_samples(2,:)),'-','split');
% str_samples3 = regexp(sprintf('%d-',n_samples(3,:)),'-','split');
% str_samples4 = regexp(sprintf('%d-',n_samples(4,:)),'-','split');
% % leg_labs = list_regions;
% leg_labs = strcat(list_regions,' [',str_recordings(1:end-1)',']');
% % leg_labs = strcat(list_regions,' [',str_recordings(1:end-1)','-',...
% %     str_samples1(1:end-1)','-',str_samples2(1:end-1)','-',...
% %     str_samples3(1:end-1)','-',str_samples4(1:end-1)',']');

% two-lines legend
leg_labs = cell(length(list_regions),1);
for i =1:length(list_regions)
    leg_labs(i)={sprintf('%s (N=%d)\n[%.1f/%.1f/%.1f/%.1f]',...
        char(list_regions(i)),n_recordings(1,i),...
        n_samples(1,i),...char(list_group(1)),
        n_samples(2,i),...char(list_group(2)),
        n_samples(3,i),...char(list_group(3)),
        n_samples(4,i))};...char(list_group(4)),
end

% Box Plot
n_groups = size(tt_data,3);
n_bars = size(tt_data,2);
hold(ax,'on');
% gpwidth = min(.8,n_groups/(n_groups+1.5));
gpwidth = .85;
for i=1:n_groups
    positions = i-gpwidth/2:gpwidth/(n_bars-1):i+gpwidth/2;
    %     ind_colors = 1:63/(n_bars-1):64;
    %     colors = cmap(round(ind_colors),:);
    boxplot(tt_data(:,:,i),...
        'MedianStyle','target',...
        'positions',positions,...
        'colors',f_colors,...colors,...
        'OutlierSize',.1,...
        'symbol','',...
        'PlotStyle','compact',...
        'Widths',gpwidth/(n_bars+1),...
        'Parent',ax);
end
hold(ax,'off');
ax.Position = [.05 .05 .8 .9];

% Dummy axes for legend
b = bar(dummy_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
    b(i).FaceColor = f_colors(i,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,leg_labs,'Visible','on');
%leg = legend(ax,leg_labs,'Visible','on');
ax_dummy.Position = [2 1 1 1];

% Axis limits
%ax.YLim = [min(tt_data(:)) max(tt_data(:))];
ax.YLim = [-60 140];
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = 'Synthesis Episode Statistics';
ax.TickLength = [0 0];
grid(ax,'on');
ax.Visible ='on';
%ax.Position =[0 0 .05 .05];

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .9*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';
leg.Visible ='on';

f.Units = 'pixels';
f.Position = [195          59        1045         919];

fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
saveas(f,fullname);

end

function tt_data = plot2(L,P,S,str1,str2,only_txt)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
label_regions = L.label_regions;
list_group = L.list_group;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
ax1 = axes('Parent',panel,'Position',[.15 .05 .2 .9]);
ax2 = axes('Parent',panel,'Position',[.45 .05 .2 .9]);
ax_dummy = axes('Parent',panel,'Position',[.1 .1 .8 .8],'Visible','off');
clrmenu(f);
switch str1
   case 'Mean'
        switch str2
            case 'Recording'
                f.Name = strcat(fName,'-MeanPerRecording');
            case 'Episode'
                f.Name = strcat(fName,'-MeanPerEpisode');
        end       
    case 'Median'
        switch str2
            case 'Recording'
                f.Name = strcat(fName,'-MedianPerRecording');
            case 'Episode'
                f.Name = strcat(fName,'-MedianPerEpisode');
        end
end
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
% f.PaperPositionMode='auto';

f.Colormap = P.Colormap;
f_colors = P.f_colors;
f_colors = P.Colormap;
margin_w = P.margin_w;
margin_h = P.margin_h;
n_columns = P.n_columns;
n_rows = P.n_rows;
val1 = P.val1;
val2 = P.val2;
tick_width = P.tick_width;
thresh_average = P.thresh_average;
all_markers = P.all_markers;
all_linestyles = P.all_linestyles;
patch_alpha = P.patch_alpha;
dd_color = [.5 .5 .5];
dd_color = 'none';
bd_color = 'k';
stats_color = 'r';


% Getting data
%tt_data = rand(10000,length(list_regions),length(list_group));
m = 0;
for i =1:length(list_group)
    for j = 1:length(list_regions)
        
        switch str1
            case 'Mean'
                switch str2
                    case 'Recording'
                        m = max(m,length(S(i,j).mean_per_rec));
                    case 'Episode'
                        m = max(m,length(S(i,j).mean_per_ep));
                end
                
            case 'Median'
                switch str2
                    case 'Recording'
                        m = max(m,length(S(i,j).median_per_rec));
                    case 'Episode'
                        m = max(m,length(S(i,j).median_per_rec));
                end
        end
    end
end

dots_data = NaN(m,length(list_regions),length(list_group));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        switch str1
            case 'Mean'
                switch str2
                    case 'Recording'
                        temp = S(i,j).mean_per_rec;
                    case 'Episode'
                        temp = S(i,j).mean_per_ep;
                end
                
            case 'Median'
                switch str2
                    case 'Recording'
                        temp = S(i,j).median_per_rec;
                    case 'Episode'
                        temp = S(i,j).median_per_ep;
                end
        end
        dots_data(1:length(temp),j,i) = temp;
    end
end

tt_data = NaN(length(list_group),length(list_regions));
ebar_data = NaN(length(list_group),length(list_regions));
n_samples = NaN(length(list_group),length(list_regions));
n_recordings = NaN(length(list_group),length(list_regions));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        switch str1
            case 'Mean'
                switch str2
                    case 'Recording'
                        temp = S(i,j).mean_per_rec;
                    case 'Episode'
                        temp = S(i,j).mean_per_ep;
                end
                
            case 'Median'
                switch str2
                    case 'Recording'
                        temp = S(i,j).median_per_rec;
                    case 'Episode'
                        temp = S(i,j).median_per_ep;
                end
        end
        tt_data(i,j) = mean(temp,'omitnan');
        n_samples(i,j)=sum(~isnan(temp));
        n_recordings(i,j)=sum(~isnan(S(i,j).mean_per_rec));
        ebar_data(i,j) = std(temp,[],'omitnan')./sqrt(n_samples(i,j));
    end
end

% Save in txt file
fid = fopen(fullfile(folder_save,strcat(f.Name,'.txt')),'w');
fwrite(fid,sprintf('Region \t'));
for j =1:length(list_group)
    fwrite(fid,sprintf('%s \t ', char(list_group(j))));
end
fwrite(fid,newline);
for i =1:length(list_regions)
    fwrite(fid,sprintf('%s \t ', char(list_regions(i))));
    for j =1:length(list_group)
        fwrite(fid,sprintf('%.4f+/-%.4f \t ',tt_data(j,i),ebar_data(j,i)));
    end
    if i~=length(list_regions)
        fwrite(fid,newline);
    end
end
fclose(fid);
fprintf('Data Saved in txt file [%s].\n',fullfile(folder_save,strcat(f.Name,'.txt')));

% Early Break
if only_txt == true
    warning('Early Break: Text File saved only.');
    return;
end

% Box Plot
n_groups = length(list_group);
n_bars = length(list_regions);

% % Sorting
% [~,ind_sorted_rem] = sort(tt_data(index_rem,:),'ascend');
% ebar_data_sorted = ebar_data(:,ind_sorted_rem);
% [~,ind_sorted_aw] = sort(tt_data2,'ascend');

% Ax1
hold(ax1,'on');
b1 = barh(diag(tt_data(1,:)),'stacked','Parent',ax1);
for i=1:length(b1)
    %bar color
    b1(i).FaceColor = f_colors(i,:);
    b1(i).EdgeColor = 'none';
    b1(i).LineWidth = .1;
    % Plot dots and ebar data for Mean per recording
    % dots
    temp = dots_data(:,i,1);
    temp(isnan(temp))=[];
    line('XData',temp,'YData',b1(i).XData(i)*ones(size(temp)),...
        'LineStyle','none','Marker','.','MarkerSize',8,...
        'MarkerFaceColor',dd_color,'MarkerEdgeColor',dd_color,'Parent',ax1);
    % errorbars
    e = errorbar(b1(i).YData(i),b1(i).XData(i),-ebar_data(1,i),ebar_data(1,i),...
        'horizontal','Parent',ax1,'LineWidth',1,'Color',bd_color);
    %         e.Color='k';
    
end

% Axis limits
ax1.YTick = 1:n_bars;
% ax1.YTickLabel = list_regions(ind_sorted_rem);
ax1.YTickLabel = label_regions;
ax1.Title.String = char(list_group(1));
ax1.TickLength = [0 0];
ax1.XLim = [0 1];
grid(ax1,'on');
ax1.YGrid='off';


% Ax2
hold(ax2,'on');
b2 = barh(diag(tt_data(2,:)),'stacked','Parent',ax2);
for i=1:length(b2)
    %bar color
    b2(i).FaceColor = f_colors(end-i+1,:);
    b2(i).EdgeColor = 'none';
    b2(i).LineWidth = .1;
    % Plot dots and ebar data for Mean per recording
    % dots
    temp = dots_data(:,i,2);
    temp(isnan(temp))=[];
    line('XData',temp,'YData',b2(i).XData(i)*ones(size(temp)),...
        'LineStyle','none','Marker','.','MarkerSize',8,...
        'MarkerFaceColor',dd_color,'MarkerEdgeColor',dd_color,'Parent',ax2);
    % errorbars
    e = errorbar(b2(i).YData(i),b2(i).XData(i),-ebar_data(2,i),ebar_data(2,i),...
        'horizontal','Parent',ax2,'LineWidth',1,'Color',bd_color);
    %         e.Color='k';
    
end

% Axis limits
ax2.YTick = 1:n_bars;
% ax2.YTickLabel = list_regions(ind_sorted_rem);
ax2.YTickLabel = label_regions;
ax2.Title.String = char(list_group(2));
ax2.TickLength = [0 0];
ax2.XLim = [0 1];
grid(ax2,'on');
ax2.YGrid='off';


dummy_data = rand(length(list_group),length(list_regions));
xtick_labs = list_group;
str_recordings = regexp(sprintf('%d-',n_recordings(1,:)),'-','split');
% leg_labs = list_regions;
leg_labs = strcat(list_regions,' [',str_recordings(1:end-1)',']');


% Dummy axes for legend
b = bar(dummy_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
    b(i).FaceColor = f_colors(i,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,leg_labs,'Visible','on');
ax_dummy.Position = [2 1 1 1];


% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
%leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.7 .05 .25 .9];
panel.Units = 'normalized';
leg.Units = 'normalized';

f.Units = 'pixels';
f.Position = [195          59        1045         719];

fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
saveas(f,fullname);

end
