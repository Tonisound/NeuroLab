% Article REM 3d - Revised Figure 2
% Vascular Surges Statistics

function script_FigureRevision2(rec_list,reg_group)
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
fName = sprintf('RevisedFig2_%s-%s',rec_list,reg_group);
folder_save = fullfile(pwd,'RevisedFigure2');
if ~exist(folder_save,'dir')
    mkdir(folder_save);
end
% list_group = {'QW';'AW';'NREM';'REM';};
list_group = {'REM-TONIC';'REM-PHASIC';};

% Storing
L.list_group = list_group;
L.fName = fName;
L.folder_save = folder_save;
L.rec_list = rec_list;
L.reg_group = reg_group;

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
tt_data = plot2(L,P,S,'Mean',only_txt);
tt_data = plot2(L,P,S,'Median',only_txt);

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
    'y_data',[],...
    'group','','region','','recording','');
S(length(list_group),length(list_regions)).recording = [];
% save(fullfile(folder_name,'Time_Surges.mat'),'n_aw','thresh_surge','thresh_second',...
%     'AW_images','IM_AW','STD_AW','REM_images','IM_REM','STD_REM',...
%     'ind_surge','ind_tonic','n_phasic','n_tonic','S_surges',...
%     'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images',...
%     'ratio_surge','intensity_surge','whole_mask','n_whole','Doppler_Surge','-v7.3');
    
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
    fprintf('Loading Time Surges [File: %s (%d/%d)] ...',cur_file,index,length(list_files));
    data_surges = load(fullfile(DIR_SAVE,cur_file,'Time_Surges.mat'));
    fprintf(' done.\n');

    % Loading Atlas
    dd = dir(fullfile(DIR_SAVE,cur_file,'Atlas.mat'));
    if isempty(dd)
        warning('Absent file Atlas.mat [File: %s]',cur_file);
        continue;  
    end
    fprintf('Loading Atlas [File: %s] ...',cur_file);
    data_atlas = load(fullfile(DIR_SAVE,cur_file,'Atlas.mat'));
    fprintf(' done.\n');

    % Listing Regions
    ddd = dir(fullfile(DIR_SAVE,cur_file,'Sources_fUS','*.mat'));
    if isempty(ddd)
        warning('No Regions found [File: %s]',cur_region,cur_file);
        continue;
    end
    available_regions = strrep({ddd(:).name}','.mat','');
    
    % Counter
    counter = counter+1;
%     REM_images = data_surges.REM_images;
%     index_REM = find(REM_images==1);
%     TimeTags = data_surges.TimeTags;
%     intensity_surge = data_surges.intensity_surge;
%     whole_mask = data_surges.whole_mask;
    Doppler_Surge = data_surges.Doppler_Surge;
    ind_surge = data_surges.ind_surge;
    ind_tonic = data_surges.ind_tonic;
    
    % Compute 
    Doppler_tonic = Doppler_Surge(:,:,ind_tonic==1);
    Doppler_tonic(Doppler_tonic==-1)=0;
    Doppler_tonic_mean_rec = mean(Doppler_tonic,3,'omitnan');
    Doppler_tonic_median_rec = median(Doppler_tonic,3,'omitnan');
    
    Doppler_phasic = Doppler_Surge(:,:,ind_surge==1);
    Doppler_phasic(Doppler_phasic==-1)=0;
    Doppler_phasic_mean_rec = mean(Doppler_phasic,3,'omitnan');
    Doppler_phasic_median_rec = median(Doppler_phasic,3,'omitnan');

    % Collecting fUS data
    for i=1:length(list_group)
        cur_group = char(list_group(i));
%         index_group = find(strcmp(data_fus.label_episodes,cur_group)==1);
        
        for j=1:length(list_regions) 
            cur_region = char(list_regions(j));
            if sum(strcmp(cur_region,available_regions)>0)
                data_mask = load(fullfile(DIR_SAVE,cur_file,'Sources_fUS',strcat(cur_region,'.mat')),'mask');
                cur_mask = data_mask.mask;
            else
                continue;
            end
            
            cur_mask(cur_mask==0)=NaN;
            
            % Applying mask to Doppler Doppler_tonic Doppler_phasic
            Doppler_tonic_masked = Doppler_tonic.*repmat(cur_mask,[1,1,size(Doppler_tonic,3)]);
            Doppler_phasic_masked = Doppler_phasic.*repmat(cur_mask,[1,1,size(Doppler_phasic,3)]);
            Doppler_tonic_reshaped = reshape(Doppler_tonic_masked,size(Doppler_tonic_masked,1)*size(Doppler_tonic_masked,2),1,size(Doppler_tonic_masked,3));
            y_data_tonic = (mean(squeeze(Doppler_tonic_reshaped),1,'omitnan'))';
            Doppler_phasic_reshaped = reshape(Doppler_phasic_masked,size(Doppler_phasic_masked,1)*size(Doppler_phasic_masked,2),1,size(Doppler_phasic_masked,3));
            y_data_phasic = (mean(squeeze(Doppler_phasic_reshaped),1,'omitnan'))';
            
            temp_tonic = Doppler_phasic_mean_rec.*cur_mask;
            mean_tonic = mean(temp_tonic(:),'omitnan');
            temp_phasic = Doppler_phasic_mean_rec.*cur_mask;
            mean_phasic = mean(temp_phasic(:),'omitnan');
            
            temp_tonic = Doppler_tonic_median_rec.*cur_mask;
            median_tonic = mean(temp_tonic(:),'omitnan');
            temp_phasic = Doppler_phasic_median_rec.*cur_mask;
            median_phasic = mean(temp_phasic(:),'omitnan');
            
            if strcmp(cur_group,'REM-TONIC')
                value1 = mean_tonic;
                value2 = median_tonic;
                y_data = y_data_tonic;
            elseif strcmp(cur_group,'REM-PHASIC')
                value1 = mean_phasic;
                value2 = median_phasic;
                y_data = y_data_phasic;
            end
            
            % Emit warning if NaN found
            if isnan(value1)
                warning('NaN value mean [File: %s, Region: %s].',cur_file,cur_region);
                continue;
            end
            if isnan(value2)
                warning('NaN value median [File: %s, Region: %s].',cur_file,cur_region);
                continue;
            end
%           index_region = find(strcmp(data_fus.label_channels,cur_region)==1);
%             if length(index_region)>1
%                 index_region = index_region(end);
%             end
            
            % Getting data
            S(i,j).group = cur_group;
            S(i,j).region = cur_region;
            S(i,j).recording = [S(i,j).recording;{cur_file}];
            S(i,j).mean_per_rec = [S(i,j).mean_per_rec;value1];
            S(i,j).median_per_rec = [S(i,j).median_per_rec;value2];
            S(i,j).y_data = [S(i,j).y_data;y_data];
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
        n_recordings(i,j)=sum(~isnan(S(i,j).y_mean));
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

function tt_data = plot2(L,P,S,str,only_txt)

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
switch str
    case 'Mean'
        f.Name = strcat(fName,'-B-MeanPerRecording');
    case 'Median'
        f.Name = strcat(fName,'-B-MedianPerRecording');
end
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
%tt_data = rand(10000,length(list_regions),length(list_group));
m = 0;
for i =1:length(list_group)
    for j = 1:length(list_regions)
        switch str
            case 'Mean'
                m = max(m,length(S(i,j).y_mean));  
            case 'Median'
                m = max(m,length(S(i,j).y_median));
        end
    end
end

dots_data = NaN(m,length(list_regions),length(list_group));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        switch str
            case 'Median'
                temp = S(i,j).y_median;
            case 'Mean'
                temp = S(i,j).y_mean;
        end 
        dots_data(1:length(temp),j,i) = temp;
    end
end

tt_data = NaN(length(list_group),length(list_regions));
ebar_data = NaN(length(list_group),length(list_regions));
n_samples = NaN(length(list_group),length(list_regions));
% n_recordings = NaN(length(list_group),length(list_regions));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        switch str
            case 'Mean'
                temp = S(i,j).y_median;
            case 'Median'
                temp = S(i,j).y_mean;
        end
        tt_data(i,j) = mean(temp,'omitnan');
        n_samples(i,j)=sum(~isnan(temp));
%         n_recordings(i,j)=sum(~isnan(S(i,j).y_mean));
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
        fwrite(fid,sprintf('%.4f \t ', tt_data(j,i)));
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
        'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5],'Parent',ax1);
    % errorbars
    e = errorbar(b1(i).YData(i),b1(i).XData(i),-ebar_data(1,i),ebar_data(1,i),...
        'horizontal','Parent',ax1,'LineWidth',1,'Color','k');
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
    b2(i).FaceColor = f_colors(i,:);
    b2(i).EdgeColor = 'none';
    b2(i).LineWidth = .1;
    % Plot dots and ebar data for Mean per recording
    % dots
    temp = dots_data(:,i,2);
    temp(isnan(temp))=[];
    line('XData',temp,'YData',b2(i).XData(i)*ones(size(temp)),...
        'LineStyle','none','Marker','.','MarkerSize',8,...
        'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5],'Parent',ax2);
    % errorbars
    e = errorbar(b2(i).YData(i),b2(i).XData(i),-ebar_data(1,i),ebar_data(1,i),...
        'horizontal','Parent',ax2,'LineWidth',1,'Color','k');
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
