% Article REM 3d - Revised Figure 3
% Synthesis GLM Analysis

function script_FigureRevision3D(rec_list,reg_group)
% rec_list = CORONAL|SAGITTAL|ALL
% reg_group = GROUPS|RIGHT-GROUPS|LEFT-GROUPS

close all;

if nargin <1
    rec_list = 'ALL';
end
if nargin <2
    reg_group = 'GROUPS';
end
if nargin <3
    restrict_period = 'REM';
end

% Generate Lists
L = get_lists(rec_list,reg_group);
fName = sprintf('RevisedFig3_%s-%s_%s',rec_list,reg_group,restrict_period);
folder_save = fullfile(pwd,'RevisedFigure3');
if ~exist(folder_save,'dir')
    mkdir(folder_save);
end

% % Exclude some regions
% list_exclude = {'CCallosum';'Cerebellum';'BrainStem';'Ventricles'};
% ind_exclude = contains(L.list_regions,list_exclude);
% L.list_regions(ind_exclude)=[];
% L.label_regions(ind_exclude)=[];

% list of time groups
% list_group = {'QW';'AW';'NREM';'REM-TONIC';'REM-PHASIC'};
list_group = {'REM-TONIC';'REM-PHASIC'};

% Storing
L.list_group = list_group;
L.fName = fName;
L.folder_save = folder_save;
L.rec_list = rec_list;
L.reg_group = reg_group;
L.restrict_period = restrict_period;

% Loading/Browsing data
if exist(fullfile(folder_save,strcat(fName,'.mat')),'file')
    fprintf('Loading [%s]... ',fName);
    load(fullfile(folder_save,strcat(fName,'.mat')),'R','S','P');
    fprintf(' done.\n');
    fprintf('Data Loaded [%s-%s] (%d files)\n',L.rec_list,L.reg_group,length(L.list_files));
else
    [R,S,P] = browse_data(L);
end

% Plotting/Saving Data
only_txt = false;
tt_data = plot1(L,P,R,S,'Mean',only_txt);
tt_data = plot1(L,P,R,S,'Median',only_txt);

end

function [R,S,P] = browse_data(L)

global DIR_STATS;

folder_save = L.folder_save;
fName = L.fName;
list_regions = L.list_regions;
list_files = L.list_files;
list_group = L.list_group;
restrict_period = L.restrict_period;
% list_files=strrep(list_files,'R_nlab','R');

% Buidling struct S
S = struct('region','','group','','recording','',...
    'regions_b',[]);...,'regions_dev',[]
S(length(list_group),length(list_regions)).recording = [];

% Buidling struct R
R = struct('group','','recording','',...
    'pixels_b',[]);...,'pixels_dev',[]
R(length(list_files),length(list_group)).recording = [];

counter = 0;
for index = 1:length(list_files)
    
    cur_file = char(list_files(index));
    
    % Loading fUS_Statistics
    container = fullfile(DIR_STATS,'GLM_Analysis',cur_file,restrict_period);

    d = dir(fullfile(container,'GLM_Analysis.mat'));
    if isempty(d)
        fprintf(' >>> Absent file GLM_Analysis [File: %s]\n',cur_file);
        continue;
    else
        fprintf('Loading file GLM_Analysis [File: %s] ...',cur_file);
        data_glm = load(fullfile(container,'GLM_Analysis.mat'));
        fprintf(' done.\n');
        all_regressors = data_glm.all_regressors;
        actual_regions = data_glm.actual_regions;
    end
    
    for i = 1:length(list_group)
        
        cur_group = char(list_group(i));
        index_regressor = find(strcmp(cur_group,all_regressors)==1);
        
        if isempty(index_regressor)
            warning(sprintf('Regressor not found [Group: %s, File: %s]',cur_group,cur_file))
            continue;
        elseif length(index_regressor)>1
            warning(sprintf('Multiple Regressors found [Group: %s, File: %s]',cur_group,cur_file))
            continue;
        end
        counter = counter +1;
        
        % Collecting fUS data
        R(index,i).group = {cur_group};
        R(index,i).recording = {cur_file};
        R(index,i).pixels_b = data_glm.pixels_b(:,:,index_regressor);
%         R(index,i).pixels_dev = data_glm.pixels_dev;
        
        for j=1:length(list_regions)
            cur_region = char(list_regions(j));
            index_region = find(strcmp(actual_regions,cur_region)==1);
            if length(index_region)>1
                index_region = index_region(end);
            elseif isempty(index_region)
                continue;
            end

            % Getting data
            S(i,j).group = [S(i,j).group;{cur_group}];
            S(i,j).region = [S(i,j).region;{cur_region}];
            S(i,j).recording = [S(i,j).recording;{cur_file}];
            S(i,j).regions_b = [S(i,j).regions_b;data_glm.regions_b(index_region,index_regressor)];
            
        end
    end
end
fprintf('Data Browsed [%d files loaded].\n',counter);

% Setting Parameters
f = figure('Visible','off');
colormap(f,'jet');
P.Colormap = f.Colormap;
P.f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
P.f_colors = f.Colormap(round(1:length(f.Colormap)/length(list_regions):length(f.Colormap)),:);
% P.f_colors =    [0.2422    0.1504    0.6603;
%     0.2504    0.1650    0.7076;
%     0.2578    0.1818    0.7511;
%     0.2647    0.1978    0.7952;
%     0.2706    0.2147    0.8364;
%     0.2751    0.2342    0.8710;
%     0.2783    0.2559    0.8991;
%     0.2803    0.2782    0.9221;
%     0.2813    0.3006    0.9414;
%     0.2810    0.3228    0.9579;
%     0.2795    0.3447    0.9717;
%     0.2760    0.3667    0.9829;
%     0.2699    0.3892    0.9906;
%     0.1248    0.6459    0.8883;
%     0.0952    0.6798    0.8598;
%     0.0689    0.6948    0.8394;
%     0.0297    0.7082    0.8163;
%     0.0036    0.7203    0.7917;
%     0.2470    0.7918    0.5567;
%     0.2906    0.7973    0.5188;
%     0.3406    0.8008    0.4789;
%     0.6720    0.7793    0.2227;
%     0.7242    0.7698    0.1910;
%     0.7738    0.7598    0.1646;
%     0.8203    0.7498    0.1535;
%     0.8634    0.7406    0.1596;
%     0.9035    0.7330    0.1774;
%     0.9393    0.7288    0.2100;
%     0.9728    0.7298    0.2394;
%     0.9597    0.9135    0.1423;
%     0.9628    0.9373    0.1265;
%     0.9691    0.9606    0.1064;
%     0.9769    0.9839    0.0805];
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
save(fullfile(folder_save,strcat(fName,'.mat')),'L','R','S','P','-v7.3');
fprintf('Synthesis Data Saved [%s]\n',fullfile(folder_save,strcat(fName,'.mat')));

end

function tt_data = plot1(L,P,R,S,str,only_txt)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
label_regions = L.label_regions;
list_group = L.list_group;
%list_files = L.list_files;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
% ax1 = axes('Parent',panel,'Position',[.125 .1 .15 .8]);
% ax2 = axes('Parent',panel,'Position',[.45 .1 .15 .8]);
% ax3 = axes('Parent',panel,'Position',[.775 .1 .15 .8]);
% all_axes = [ax1;ax2;ax3];

clrmenu(f);
switch str
    case 'Mean'
        f.Name = strcat(fName,'-Mean');
    case 'Median'
        f.Name = strcat(fName,'-Median');
end
f.Renderer = 'Painters';
f.PaperPositionMode = 'manual';

f.Colormap = P.Colormap;
f_colors = P.f_colors;
dd_color = [.5 .5 .5];
dd_color = 'none';
bd_color = 'k';
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

all_axes = [];
margin_w = .025;
margin_h = .05;
for i = 1:length(list_group)
    ax = axes('Parent',panel,'Position',[(i-1)/length(list_group)+1.5*margin_w margin_h 1/length(list_group)-2*margin_w 1-2*margin_h]);
    all_axes = [all_axes;ax];
end

% Getting data
m = 0;
for i =1:length(list_group)
    for j = 1:length(list_regions)
        m = max(m,length(S(i,j).regions_b));
    end
end
dots_data = NaN(m,length(list_regions),length(list_group));
n_recordings = NaN(length(list_group),length(list_regions));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        temp = S(i,j).regions_b;
        dots_data(1:length(temp),j,i) = temp;
        n_recordings(i,j) = length(temp);
    end
end

tt_data = NaN(length(list_group),length(list_regions));
ebar_data = NaN(length(list_group),length(list_regions));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        temp = S(i,j).regions_b;
        switch str
            case 'Mean'
                tt_data(i,j) = mean(temp,'omitnan');
            case 'Median'
                tt_data(i,j) = median(temp,'omitnan');
        end
        ebar_data(i,j) = std(temp,[],'omitnan')/sqrt(n_recordings(i,j));
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
        fwrite(fid,sprintf('%.4f +/- %.4f\t ',tt_data(j,i),ebar_data(j,i)));
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
for k = 1:length(all_axes)
    ax = all_axes(k);
    hold(ax,'on');
    b1 = barh(diag(tt_data(k,:)),'stacked','Parent',ax);
    for i=1:length(b1)
        %bar color
        b1(i).FaceColor = f_colors(i,:);
        b1(i).EdgeColor = 'none';
        b1(i).LineWidth = .1;
        % Plot dots and ebar data for Mean per recording
        % dots
        temp = dots_data(:,i,k);
        temp(isnan(temp))=[];
        line('XData',temp,'YData',b1(i).XData(i)*ones(size(temp)),...
            'LineStyle','none','Marker','.','MarkerSize',8,...
            'MarkerFaceColor',dd_color,'MarkerEdgeColor',dd_color,'Parent',ax);
        % errorbars
        errorbar(b1(i).YData(i),b1(i).XData(i),-ebar_data(k,i),ebar_data(k,i),...
            'horizontal','Parent',ax,'LineWidth',1,'Color',bd_color);
    end
    % Axis limits
    ax.YTick = 1:n_bars;
    % ax1.YTickLabel = list_regions(ind_sorted_rem);
    ax.YTickLabel = label_regions;
    ax.Title.String = char(list_group(k));
    ax.TickLength = [0 0];
    ax.XLim = [-5 60];
    grid(ax,'on');
    ax.YGrid='off';
end


f.Units = 'pixels';
f.Position = [195          59        1045         719];

fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
saveas(f,fullname);

end
