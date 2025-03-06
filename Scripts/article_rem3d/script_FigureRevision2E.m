% Article REM 3d - Revised Figure 2D
% Vascular Surges Statistics Per Location

function script_FigureRevision2E(rec_list)
% rec_list = CORONAL|SAGITTAL|ALL

close all;

if nargin <1
    rec_list = 'ALL';
end

% Generate Lists
L = get_lists(rec_list,'');
fName = sprintf('RevisedFig2D_%s',rec_list);
folder_save = fullfile(pwd,'RevisedFigure2');
if ~exist(folder_save,'dir')
    mkdir(folder_save);
end
% list_location = {'anterior';'intermediate';'posterior';'medial';'lateral'};
list_location = {'ANTERIOR';'INTERMEDIATE';'POSTERIOR';'MEDIAL';'LATERAL'};
label_location = {'ANT';'INT';'POST';'MED';'LAT'};

% Storing
L.fName = fName;
L.folder_save = folder_save;
L.rec_list = rec_list;
L.list_location = list_location;
L.label_location = label_location;

% Loading/Browsing data
if exist(fullfile(folder_save,strcat(fName,'.mat')),'file')
    fprintf('Loading [%s]... ',fName);
    load(fullfile(folder_save,strcat(fName,'.mat')),'Q','R','S','P');
    fprintf(' done.\n');
    fprintf('Data Loaded [%s] (%d files)\n',L.rec_list,length(L.list_files));
else
    [Q,R,S,P] = browse_data(L);
end

% Plotting/Saving Data
only_txt = false;
plot3(L,P,Q,R,S,'Mean',only_txt);
plot3(L,P,Q,R,S,'Median',only_txt);

end

function [Q,R,S,P] = browse_data(L)

global DIR_SAVE;

fName = L.fName;
folder_save = L.folder_save;
list_files = L.list_files;
list_location = L.list_location;

% Buidling structures
Q = struct('n_surges_per_rec',[],'percent_phasic_per_rec',[],...
    'duration_phasic',[],'duration_rem',[],...
    'location','','atlas','','recording','');
Q(length(list_location)).recording = [];

R = struct('n_surges_per_ep',[],'percent_phasic_per_ep',[],...
    'duration_phasic',[],'duration_rem',[],...
    'location','','atlas','','recording','','episode','');
R(length(list_location)).recording = [];

S = struct('vs_duration',[],'vs_ratio',[],'vs_intensity',[],...
    'location','','atlas','','recording','','episode','','surge','');
S(length(list_location)).recording = [];

counter_rec = 0;
counter_ep = 0;
counter_surge = 0;

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
%     data_surges = load(fullfile(DIR_SAVE,cur_file,'Time_Surges.mat'),...
%         'Doppler_Surge','ind_surge','ind_tonic','REM_images','TimeTags');
    data_surges = load(fullfile(DIR_SAVE,cur_file,'Time_Surges.mat'),'S_surges');
    
    % Loading Atlas
    dd = dir(fullfile(DIR_SAVE,cur_file,'Atlas.mat'));
    if isempty(dd)
        warning('Absent file Atlas.mat [File: %s]',cur_file);
        continue;
    end
    fprintf('Loading Atlas [File: %s] ... ',cur_file);
    data_atlas = load(fullfile(DIR_SAVE,cur_file,'Atlas.mat'));
    
    % Loading Tags
    ddd = dir(fullfile(DIR_SAVE,cur_file,'Time_Tags.mat'));
    if isempty(ddd)
        warning('Absent file Time_Tags.mat [File: %s]',cur_file);
        continue;
    end
    fprintf('Loading Time_Tags [File: %s] ...',cur_file);
    data_tags = load(fullfile(DIR_SAVE,cur_file,'Time_Tags.mat'));
    fprintf(' done.\n');
    
    % Defining location
    switch data_atlas.AtlasName
        case 'Rat Coronal Paxinos'
            if data_atlas.AP_mm > 0
                cur_location = 'anterior';
            elseif data_atlas.AP_mm > -3
                cur_location = 'intermediate';
            else
                cur_location = 'posterior';
            end
            cur_atlas = sprintf('%s[%.2f mm]',data_atlas.AtlasName,data_atlas.AP_mm);
        case 'Rat Sagittal Paxinos'
            if data_atlas.ML_mm > -2 && data_atlas.ML_mm < 2
                cur_location = 'medial';
            else
                cur_location = 'lateral';
            end
            cur_atlas = sprintf('%s[%.2f mm]',data_atlas.AtlasName,data_atlas.ML_mm);
    end
    index_location = find(strcmpi(list_location,cur_location)==1);
    
%     Doppler_Surge = data_surges.Doppler_Surge;
%     ind_surge = data_surges.ind_surge;
%     ind_tonic = data_surges.ind_tonic;
%     ind_rem = data_surges.REM_images;
%     index_phasic = find(data_surges.ind_surge==1);
%     index_tonic = find(data_surges.ind_tonic==1);
%     index_rem = find(data_surges.REM_images==1);
%     % Setting zero-values
%     Doppler_Surge(Doppler_Surge==-1)=0;
    S_surges = data_surges.S_surges;
    
    if isempty(S_surges(1).name) 
        warning('Missing Vascular Surges [File: %s]',cur_file)
        continue;
    end
    
    % Finding all REM episodes
    TimeTags = data_tags.TimeTags;
    if isempty(TimeTags)
        warning('Empty TimeTags [File: %s]',cur_file);
        continue;
    else
        ind_timetags_rem = find(startsWith({TimeTags(:).Tag}','REM-')==1);
        % ind_timetags_tonic = find(startsWith({TimeTags(:).Tag}','REMTONIC-')==1);
        % ind_timetags_phasic = find(startsWith({TimeTags(:).Tag}','REMPHASIC-')==1);
    end
    % Keeping only long REM episodes
    thresh_rem_s = 60;
    if isempty(ind_timetags_rem)
        warning('No TimeTags labeled REM [File: %s]',cur_file);
        continue;
    else
        temp = datenum({TimeTags(ind_timetags_rem).Duration}');
        duration_all_rem = (temp-floor(temp))*24*3600;
        ind_timetags_rem = ind_timetags_rem(duration_all_rem>thresh_rem_s);
        duration_all_rem = duration_all_rem(duration_all_rem>thresh_rem_s);
    end
    if isempty(ind_timetags_rem)
        warning('No TimeTags labeled REM longer than %.1f seconds [File: %s]',cur_file,thresh_rem_s);
        continue;
    end
    
    counter_rec = counter_rec+1;
    all_these_surges = [];
    
    for i = 1:length(ind_timetags_rem)
        
        % Browsing rem episodes
        cur_ep = TimeTags(ind_timetags_rem(i)).Tag;
        counter_ep = counter_ep+1;
        temp = datenum({TimeTags(ind_timetags_rem(i)).Duration}');
        duration_this_rem = (temp-floor(temp))*24*3600;
        these_surges = find(strcmp({S_surges(:).episode}',cur_ep)==1);
        all_these_surges = [all_these_surges;these_surges];
        
        for j = 1:length(these_surges)
            
            % Browsing surges
            cur_vs = S_surges(these_surges(j)).name;
            counter_surge = counter_surge+1;
            duration_this_surge = S_surges(these_surges(j)).duration;
            vs_ratio = S_surges(these_surges(j)).mean_ratio;
            vs_intensity = S_surges(these_surges(j)).mean_intensity;
            
            % Storing per surges
            S(index_location).location = [S(index_location).location;{cur_location}];
            S(index_location).recording = [S(index_location).recording;{cur_file}];
            S(index_location).episode = [S(index_location).episode;{cur_ep}];
            S(index_location).atlas = [S(index_location).atlas;{cur_atlas}];
            S(index_location).surge = [S(index_location).surge;{cur_vs}];
            S(index_location).vs_duration = [S(index_location).vs_duration;duration_this_surge];
            S(index_location).vs_ratio = [S(index_location).vs_ratio;vs_ratio];
            S(index_location).vs_intensity = [S(index_location).vs_intensity;vs_intensity];
            
        end
        
        n_surges_per_ep = length(these_surges);
        if n_surges_per_ep>0
            duration_these_phasic = sum([S_surges(these_surges).duration]);
        else
            duration_these_phasic =0;
        end
        percent_phasic_per_ep = duration_these_phasic/duration_this_rem;

        % Storing per episode
        R(index_location).location = [R(index_location).location;{cur_location}];
        R(index_location).recording = [R(index_location).recording;{cur_file}];
        R(index_location).episode = [R(index_location).episode;{cur_ep}];
        R(index_location).atlas = [R(index_location).atlas;{cur_atlas}];
        R(index_location).n_surges_per_ep = [R(index_location).n_surges_per_ep;n_surges_per_ep];
        R(index_location).percent_phasic_per_ep = [R(index_location).percent_phasic_per_ep;percent_phasic_per_ep];
        R(index_location).duration_phasic = [R(index_location).duration_phasic;duration_these_phasic];
        R(index_location).duration_rem = [R(index_location).duration_rem;duration_this_rem];    
    end
    
    n_surges_per_rec = length(S_surges(all_these_surges));
    if n_surges_per_rec>0
        duration_phasic = sum([S_surges(all_these_surges).duration]);
    else
        duration_phasic =0;
    end
    duration_rem = sum(duration_all_rem);
    percent_phasic_per_rec = duration_phasic/duration_rem;
    
    % Storing per recording
    Q(index_location).location = [Q(index_location).location;{cur_location}];
    Q(index_location).recording = [Q(index_location).recording;{cur_file}];
    Q(index_location).atlas = [Q(index_location).atlas;{cur_atlas}];
    Q(index_location).n_surges_per_rec = [Q(index_location).n_surges_per_rec;n_surges_per_rec];
    Q(index_location).percent_phasic_per_rec = [Q(index_location).percent_phasic_per_rec;percent_phasic_per_rec];
    Q(index_location).duration_phasic = [Q(index_location).duration_phasic;duration_phasic];
    Q(index_location).duration_rem = [Q(index_location).duration_rem;duration_rem];
    
end
fprintf('Data Browsed [%d recordings, %d episodes, %d surges].\n',counter_rec,counter_ep,counter_surge);

% for i =1:5
%      fprintf('%d /%d empty episodes.\n',sum(R(i).n_surges_per_ep==0),length(R(i).n_surges_per_ep));
% end

% Setting Parameters
f = figure('Visible','off');
colormap(f,'jet');
P.Colormap = f.Colormap;
P.f_colors = f.Colormap;
% %uncomment if list_regions is not ALL
% P.f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
% % comment if list_regions is not ALL
% ind_colors = [1,2,3,4,5,6,7,8,9,10,11,12,13,25,27,28,29,30,38,39,40,46,47,48,49,50,51,52,53,61,62,63,64];
% P.f_colors = f.Colormap(ind_colors,:);
close(f);

P.margin_w = .01;
P.margin_h = .02;
P.n_columns = length(list_location);
P.n_rows = 1;
P.val1 = -1;
P.val2 = 1;
P.tick_width =.5;
P.thresh_average = .5;
P.all_markers = {'none';'none';'none'};
P.all_linestyles = {'--';':';'-'};
P.patch_alpha = .1;

% Saving Data
save(fullfile(folder_save,strcat(fName,'.mat')),'L','Q','R','S','P','-v7.3');
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
switch str1
    case 'Mean'
        switch str2
            case 'Recording'
                f.Name = strcat(fName,'-C-MeanPerRecording');
            case 'Episode'
                f.Name = strcat(fName,'-C-MeanPerEpisode');
        end
    case 'Median'
        switch str2
            case 'Recording'
                f.Name = strcat(fName,'-C-MedianPerRecording');
            case 'Episode'
                f.Name = strcat(fName,'-C-MedianPerEpisode');
        end
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

function [b_data,ebar_data] = plot3(L,P,Q,R,S,str,only_txt)

switch str
    case 'Mean'
        fName = strcat(L.fName,'-Mean');

    case 'Median'
        fName = strcat(L.fName,'-Median');
end

folder_save = L.folder_save;
% list_regions = L.list_regions;
% label_regions = L.label_regions;
% list_group = L.list_group;
list_location = L.list_location;
label_location = L.label_location;
label_location_ep = L.label_location;
label_location_surge = L.label_location;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
ax1 = axes('Parent',panel,'Position',[.05 .55 .4 .4]);
ax2 = axes('Parent',panel,'Position',[.55 .55 .4 .4]);
ax3 = axes('Parent',panel,'Position',[.05 .05 .4 .4]);
ax4 = axes('Parent',panel,'Position',[.55 .05 .4 .4]);

f.Renderer = 'Painters';
f.PaperPositionMode='manual';
f.Name = fName;
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
dd_color = [.5 .5 .5];
amp_noise = .2;
bd_color = 'k';
stats_color = 'r';

% Getting data
n_recordings = 0;
n_episodes = 0;
n_surges = 0;

m_q = 0;
m_r = 0;
m_s = 0;
for i =1:length(list_location)
    m_q = max(m_q,length(Q(i).recording));
    m_r = max(m_r,length(R(i).recording));
    m_s = max(m_s,length(S(i).recording));
    n_recordings = length(Q(i).recording);
    n_episodes = length(R(i).recording);
    n_surges = length(S(i).recording);
    label_location_ep(i) = {strcat(char(label_location_ep(i)),sprintf('[%d]',n_episodes))};
    label_location_surge(i) = {strcat(char(label_location_surge(i)),sprintf('[%d]',n_surges))};
end

% Dots data
dots_data_r = NaN(m_r,length(list_location),2);
dots_data_s = NaN(m_s,length(list_location),2);
for i =1:length(list_location)
    temp = R(i).n_surges_per_ep;
    dots_data_r(1:length(temp),i,1) = temp;
    temp = R(i).percent_phasic_per_ep;
    dots_data_r(1:length(temp),i,2) = temp;
    temp = S(i).vs_duration;
    dots_data_s(1:length(temp),i,1) = temp;
    temp = S(i).vs_ratio;
    dots_data_s(1:length(temp),i,2) = temp;
end

% Bar data
b_data = NaN(4,length(list_location));
ebar_data = NaN(4,length(list_location));
% n_samples = NaN(length(list_group),length(list_regions));
% n_recordings = NaN(length(list_group),length(list_regions));
for i =1:length(list_location)
    switch str
        case 'Mean'
            b_data(1,i) = mean(dots_data_r(:,i,1),'omitnan');
            b_data(2,i) = mean(dots_data_r(:,i,2),'omitnan');
            b_data(3,i) = mean(dots_data_s(:,i,1),'omitnan');
            b_data(4,i) = mean(dots_data_s(:,i,2),'omitnan');
        case 'Median'
            b_data(1,i) = median(dots_data_r(:,i,1),'omitnan');
            b_data(2,i) = median(dots_data_r(:,i,2),'omitnan');
            b_data(3,i) = median(dots_data_s(:,i,1),'omitnan');
            b_data(4,i) = median(dots_data_s(:,i,2),'omitnan');
    end
    n_samples_1=sum(~isnan(dots_data_r(:,i,1)));
    ebar_data(1,i) = std(dots_data_r(:,i,1),[],'omitnan')./sqrt(n_samples_1);
    n_samples_2=sum(~isnan(dots_data_r(:,i,2)));
    ebar_data(2,i) = std(dots_data_r(:,i,2),[],'omitnan')./sqrt(n_samples_2);
    n_samples_3=sum(~isnan(dots_data_s(:,i,1)));
    ebar_data(3,i) = std(dots_data_s(:,i,1),[],'omitnan')./sqrt(n_samples_3);
    n_samples_4=sum(~isnan(dots_data_s(:,i,2)));
    ebar_data(4,i) = std(dots_data_s(:,i,2),[],'omitnan')./sqrt(n_samples_4);
end

% Statistics
P = NaN(length(list_location),length(list_location),4);
for i=1:length(list_location)
    for j=1:length(list_location)
        X = dots_data_r(:,i,1);
        Y = dots_data_r(:,j,1);
        P(i,j,1) = ranksum(X,Y);
    end
end
for i=1:length(list_location)
    for j=1:length(list_location)
        X = dots_data_r(:,i,2);
        Y = dots_data_r(:,j,2);
        P(i,j,2) = ranksum(X,Y);
    end
end
for i=1:length(list_location)
    for j=1:length(list_location)
        X = dots_data_s(:,i,1);
        Y = dots_data_s(:,j,1);
        P(i,j,3) = ranksum(X,Y);
    end
end
for i=1:length(list_location)
    for j=1:length(list_location)
        X = dots_data_s(:,i,2);
        Y = dots_data_s(:,j,2);
        P(i,j,4) = ranksum(X,Y);
    end
end
P_label = cell(size(P));
P_label(P>=.05)={'n.s.'};
P_label(P<.05)={'*'};
P_label(P<.01)={'**'};
P_label(P<.001)={'***'};


% Save in txt file
fid = fopen(fullfile(folder_save,strcat(f.Name,'.txt')),'w');
fwrite(fid,sprintf('%d recordings \t %d episodes \t %d surges',n_recordings,n_episodes,n_surges));
fwrite(fid,newline);
fwrite(fid,newline);

fwrite(fid,sprintf('Location \t'));
for j =1:length(list_location)
    fwrite(fid,sprintf('%s \t ', char(list_location(j))));
end
fwrite(fid,newline);
fwrite(fid,sprintf('%s \t ','#surges/REM'));
for j =1:length(list_location)
    fwrite(fid,sprintf('%.4f+/-%.4f \t ', b_data(1,j),ebar_data(1,j)));
end
fwrite(fid,newline);
fwrite(fid,sprintf('%s \t ','%PHASIC/REM'));
for j =1:length(list_location)
    fwrite(fid,sprintf('%.4f+/-%.4f \t ',b_data(2,j),ebar_data(2,j)));
end
fwrite(fid,newline);
fwrite(fid,sprintf('%s \t ','VS Duration(s)'));
for j =1:length(list_location)
    fwrite(fid,sprintf('%.4f+/-%.4f \t ', b_data(3,j),ebar_data(3,j)));
end
fwrite(fid,newline);
fwrite(fid,sprintf('%s \t ','VS Ratio(%)'));
for j =1:length(list_location)
    fwrite(fid,sprintf('%.4f+/-%.4f \t ', b_data(4,j),ebar_data(4,j)));
end
fwrite(fid,newline);
fwrite(fid,newline);
fwrite(fid,sprintf('Stats[#surges/REM] \t'));
for j =1:length(list_location)
    fwrite(fid,sprintf('%s \t ', char(list_location(j))));
end
for k =1:length(list_location)
    fwrite(fid,newline);
    fwrite(fid,sprintf('%s \t ',char(label_location(k))));
    for j =1:length(list_location)
        fwrite(fid,sprintf('%.6f \t ', P(j,k,1)));
    end
end

fwrite(fid,newline);
fwrite(fid,newline);
fwrite(fid,sprintf('Stats[%%PHASIC/REM] \t'));
for j =1:length(list_location)
    fwrite(fid,sprintf('%s \t ', char(list_location(j))));
end
for k =1:length(list_location)
    fwrite(fid,newline);
    fwrite(fid,sprintf('%s \t ',char(label_location(k))));
    for j =1:length(list_location)
        fwrite(fid,sprintf('%.6f \t ', P(j,k,2)));
    end
end

fwrite(fid,newline);
fwrite(fid,newline);
fwrite(fid,sprintf('Stats[VS Duration(s)] \t'));
for j =1:length(list_location)
    fwrite(fid,sprintf('%s \t ', char(list_location(j))));    
end
for k =1:length(list_location)
    fwrite(fid,newline);
    fwrite(fid,sprintf('%s \t ',char(label_location(k))));
    for j =1:length(list_location)
        fwrite(fid,sprintf('%.6f \t ', P(j,k,3)));
    end
end

fwrite(fid,newline);
fwrite(fid,newline);
fwrite(fid,sprintf('Stats[VS Ratio(%%)] \t'));
for j =1:length(list_location)
    fwrite(fid,sprintf('%s \t ', char(list_location(j))));
end
for k =1:length(list_location)
    fwrite(fid,newline);
    fwrite(fid,sprintf('%s \t ',char(label_location(k))));
    for j =1:length(list_location)
        fwrite(fid,sprintf('%.6f \t ', P(j,k,4)));
    end
end

fclose(fid);
fprintf('Data Saved in txt file [%s].\n',fullfile(folder_save,strcat(f.Name,'.txt')));


% Early Break
if only_txt == true
    warning('Early Break: Text File saved only.');
    close(f);
    return;
end

% Box Plot
n_groups = length(list_location);
n_bars = 5;

% % Sorting
% [~,ind_sorted_rem] = sort(tt_data(index_rem,:),'ascend');
% ebar_data_sorted = ebar_data(:,ind_sorted_rem);
% [~,ind_sorted_aw] = sort(tt_data2,'ascend');

% Ax1
hold(ax1,'on');
b1 = bar(diag(b_data(1,:)),'stacked','Parent',ax1);
for i=1:length(b1)
    % bar color
    b1(i).FaceColor = f_colors(50*i,:);
    b1(i).EdgeColor = 'none';
    b1(i).LineWidth = .1;
    % Plot dots and ebar data
    temp = dots_data_r(:,i,1);
    temp(isnan(temp))=[];
    noise = amp_noise*(-.5+rand(size(temp)));
    line('XData',b1(i).XData(i)*ones(size(temp))+noise,'YData',temp,...'XData',b1(i).XData(i)*ones(size(temp)),'YData',temp,...
        'LineStyle','none','Marker','.','MarkerSize',8,...
        'MarkerFaceColor',dd_color,'MarkerEdgeColor',dd_color,'Parent',ax1);
    % errorbars
    e = errorbar(b1(i).XData(i),b1(i).YData(i),-ebar_data(1,i),ebar_data(1,i),...
        'vertical','Parent',ax1,'LineWidth',1,'Color',bd_color);
end
% Axis limits
ax1.XTick = 1:n_bars;
ax1.XTickLabel = label_location_ep;
ax1.Title.String = '# surges/REM episode';
ax1.TickLength = [0 0];
ax1.YLim = [0 8];
grid(ax1,'on');
ax1.XGrid='off';
% Plot stats
for i =[1,2,4]
    line('XData',[b1(i).XData(i)+.1 b1(i+1).XData(i+1)-.1],'YData',[ax1.YLim(2)*0.9 ax1.YLim(2)*0.9],...
        'LineStyle','-','Marker','none','Color',stats_color,'Parent',ax1);
    text(b1(i).XData(i)+.4,ax1.YLim(2)*0.925,char(P_label(i,i+1,1)),'Color','r','Parent',ax1);
    if i==1
        line('XData',[b1(i).XData(i)+.1 b1(i+2).XData(i+2)-.1],'YData',[ax1.YLim(2)*0.95 ax1.YLim(2)*0.95],...
            'LineStyle','-','Marker','none','Color',stats_color,'Parent',ax1);
        text(b1(i+1).XData(i+1),ax1.YLim(2)*0.975,char(P_label(i,i+2,1)),'Color','r','Parent',ax1);
    end
end

% Ax2
hold(ax2,'on');
b2 = bar(diag(b_data(2,:)),'stacked','Parent',ax2);
for i=1:length(b2)
    %bar color
    b2(i).FaceColor = f_colors(50*i,:);
    b2(i).EdgeColor = 'none';
    b2(i).LineWidth = .1;
    % Plot dots and ebar data
    temp = dots_data_r(:,i,2);
    temp(isnan(temp))=[];
    noise = amp_noise*(-.5+rand(size(temp)));
    line('XData',b2(i).XData(i)*ones(size(temp))+noise,'YData',temp,...
        'LineStyle','none','Marker','.','MarkerSize',8,...
        'MarkerFaceColor',dd_color,'MarkerEdgeColor',dd_color,'Parent',ax2);
    % errorbars
    e = errorbar(b2(i).XData(i),b2(i).YData(i),-ebar_data(2,i),ebar_data(2,i),...
        'vertical','Parent',ax2,'LineWidth',1,'Color',bd_color);
end
% Axis limits
ax2.XTick = 1:n_bars;
ax2.XTickLabel = label_location_ep;
% ax2.XTickLabelRotation = 45;
ax2.Title.String = '% PHASIC/REM episode';
ax2.TickLength = [0 0];
ax2.YLim = [0 .5];
grid(ax2,'on');
ax2.XGrid='off';
% Plot stats
for i =[1,2,4]
    line('XData',[b2(i).XData(i)+.1 b2(i+1).XData(i+1)-.1],'YData',[ax2.YLim(2)*0.9 ax2.YLim(2)*0.9],...
        'LineStyle','-','Marker','none','Color',stats_color,'Parent',ax2);
    text(b2(i).XData(i)+.4,ax2.YLim(2)*0.925,char(P_label(i,i+1,2)),'Color','r','Parent',ax2);
    if i==1
        line('XData',[b2(i).XData(i)+.1 b2(i+2).XData(i+2)-.1],'YData',[ax2.YLim(2)*0.95 ax2.YLim(2)*0.95],...
            'LineStyle','-','Marker','none','Color',stats_color,'Parent',ax2);
        text(b2(i+1).XData(i+1),ax2.YLim(2)*0.975,char(P_label(i,i+2,2)),'Color','r','Parent',ax2);
    end
end

% Ax3
hold(ax3,'on');
b3 = bar(diag(b_data(3,:)),'stacked','Parent',ax3);
for i=1:length(b3)
    %bar color
    b3(i).FaceColor = f_colors(50*i,:);
    b3(i).EdgeColor = 'none';
    b3(i).LineWidth = .1;
    % Plot dots and ebar data
    temp = dots_data_s(:,i,1);
    temp(isnan(temp))=[];
    noise = amp_noise*(-.5+rand(size(temp)));
    line('XData',b3(i).XData(i)*ones(size(temp))+noise,'YData',temp,...
        'LineStyle','none','Marker','.','MarkerSize',8,...
        'MarkerFaceColor',dd_color,'MarkerEdgeColor',dd_color,'Parent',ax3);
    % errorbars
    e = errorbar(b3(i).XData(i),b3(i).YData(i),-ebar_data(3,i),ebar_data(3,i),...
        'vertical','Parent',ax3,'LineWidth',1,'Color',bd_color);
end
% Axis limits
ax3.XTick = 1:n_bars;
ax3.XTickLabel = label_location_surge;
ax3.Title.String = 'VS Duration (s)';
ax3.TickLength = [0 0];
ax3.YLim = [0 12];
grid(ax3,'on');
ax3.XGrid='off';
% Plot stats
for i =[1,2,4]
    line('XData',[b3(i).XData(i)+.1 b3(i+1).XData(i+1)-.1],'YData',[ax3.YLim(2)*0.9 ax3.YLim(2)*0.9],...
        'LineStyle','-','Marker','none','Color',stats_color,'Parent',ax3);
    text(b3(i).XData(i)+.4,ax3.YLim(2)*0.925,char(P_label(i,i+1,3)),'Color','r','Parent',ax3);
    if i==1
        line('XData',[b3(i).XData(i)+.1 b3(i+2).XData(i+2)-.1],'YData',[ax3.YLim(2)*0.95 ax3.YLim(2)*0.95],...
            'LineStyle','-','Marker','none','Color',stats_color,'Parent',ax3);
        text(b3(i+1).XData(i+1),ax3.YLim(2)*0.975,char(P_label(i,i+2,3)),'Color','r','Parent',ax3);
    end
end

% Ax4
hold(ax4,'on');
b4 = bar(diag(b_data(4,:)),'stacked','Parent',ax4);
for i=1:length(b4)
    %bar color
    b4(i).FaceColor = f_colors(50*i,:);
    b4(i).EdgeColor = 'none';
    b4(i).LineWidth = .1;
    % Plot dots and ebar data
    temp = dots_data_s(:,i,2);
    temp(isnan(temp))=[];
    noise = amp_noise*(-.5+rand(size(temp)));
    line('XData',b4(i).XData(i)*ones(size(temp))+noise,'YData',temp,...
        'LineStyle','none','Marker','.','MarkerSize',8,...
        'MarkerFaceColor',dd_color,'MarkerEdgeColor',dd_color,'Parent',ax4);
    % errorbars
    e = errorbar(b4(i).XData(i),b4(i).YData(i),-ebar_data(4,i),ebar_data(4,i),...
        'vertical','Parent',ax4,'LineWidth',1,'Color',bd_color);
end
% Axis limits
ax4.XTick = 1:n_bars;
ax4.XTickLabel = label_location_surge;
% ax4.XTickLabelRotation = 45;
ax4.Title.String = 'VS Ratio (%)';
ax4.TickLength = [0 0];
ax4.YLim = [.5 .7];
grid(ax4,'on');
ax4.XGrid='off';
% Plot stats
for i =[1,2,4]
    line('XData',[b4(i).XData(i)+.1 b4(i+1).XData(i+1)-.1],'YData',[ax4.YLim(2)*0.95 ax4.YLim(2)*0.95],...
        'LineStyle','-','Marker','none','Color',stats_color,'Parent',ax4);
    text(b4(i).XData(i)+.4,ax4.YLim(2)*0.96,char(P_label(i,i+1,4)),'Color','r','Parent',ax4);
    if i==1
        line('XData',[b4(i).XData(i)+.1 b4(i+2).XData(i+2)-.1],'YData',[ax4.YLim(2)*0.975 ax4.YLim(2)*0.975],...
            'LineStyle','-','Marker','none','Color',stats_color,'Parent',ax4);
        text(b4(i+1).XData(i+1),ax4.YLim(2)*0.98,char(P_label(i,i+2,4)),'Color','r','Parent',ax4);
    end
end

f.Units = 'pixels';
f.Position = [195          59        1045         719];

fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
saveas(f,fullname);

end
