% Article REM 3d - Figure 4
% Synthesis LFP-CBV Correlation

function script_Figure4(rec_list,reg_group)
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
fName = sprintf('Fig4_%s-%s',rec_list,reg_group);
folder_save = fullfile(pwd,'Figure4');
if ~exist(folder_save,'dir')
    mkdir(folder_save);
end

% list of time groups
list_ref = {'SD025','LFP_011';
    'SD025','LFP_015';
    'SD025','LFP_016';
    'SD025','LFP_019';
    'SD025','LFP_020';
    'SD025','LFP_023';
    'SD025','LFP_024';
    'SD025','LFP_025';
    'SD032','LFP_005';
    'SD032','LFP_006';
    'SD032','LFP_009';
    'SD032','LFP_012';
    'SD032','LFP_015';
    'SD032','LFP_016';
    'SD032','LFP_019';
    'SD032','LFP_025';
    'SD041','LFP_006';
    'SD041','LFP_007';
    'SD041','LFP_010';
    'SD041','LFP_011';
    'SD041','LFP_014';
    'SD041','LFP_015';
    'SD041','LFP_019';
    'SD041','LFP_025'};

% list of frequency bands
list_bands = {'delta';'theta';'beta';...
    'gamma low';'gamma-mid';'gamma-mid-up';...
    'gamma-high';'gamma-high-up';'ripple'};
label_lfp = {'delta';'theta';'beta';...
    'glow';'gmid';'gmid-up';...
    'ghigh';'ghigh-up';'ripple'};

% Storing
L.list_ref = list_ref;
L.list_bands = list_bands;
L.label_lfp = label_lfp;
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

% Sorting reference
ind_sorted_ref = [3 1 5 8 6 2 4 7 10 9 14 13 12 11 15 16 19 20 17 21 18 22 23 24]';
L.list_ref = list_ref(ind_sorted_ref,:);
S = S(:,:,ind_sorted_ref);

R_peak_data = plot2(L,P,S,'Mean');
R_peak_data = plot2(L,P,S,'Median');

end

function [S,P] = browse_data(L)

folder_save = L.folder_save;
fName = L.fName;
list_regions = L.list_regions;
list_ref = L.list_ref;
list_bands = L.list_bands;
list_files = L.list_files;

% container = 'F:\SHARED_DATASET\NEUROLAB\NLab_Statistics\Cross_Correlation';
container = 'F:\SHARED_DATASET\NEUROLAB\NLab_Statistics\Cross_Correlation[rem-120s]';
% container = 'F:\SHARED_DATASET\NEUROLAB\NLab_Statistics\Cross_Correlation[whole-lfp]';
% tag_container = 'Whole-LFP';
tag_container = '*';
list_files=strrep(list_files,'R_nlab','R');

% Buidling struct S
S = struct('animal','','channel','','region','','band','',...
    'recording','','matfile','','tag','','Tag_Selection','',...
    'R_peak',[],'T_peak',[]);
S(length(list_regions),length(list_bands),length(list_ref)).R_peak = [];

counter = 0;
for index = 1:length(list_files)
    cur_file = char(list_files(index));
    for k = 1:size(list_ref,1)
        cur_animal = char(list_ref(k,1));
        cur_channel = char(list_ref(k,2));
        % Loading Cross_Correlation
        d = dir(fullfile(container,cur_file,tag_container,sprintf('*%s*_Cross_Correlation_%s.mat',cur_animal,cur_channel)));
%         if isempty(d)
%             %fprintf(' >>> Absent file Cross-Correlation [File: %s, Ref: (%s,%s)]\n',cur_file,cur_animal,cur_channel);
%             continue;
%         elseif length(d)>1
%             warning('Multiple files Cross-Correlation [File: %s, Ref: (%s,%s)]',cur_file,cur_animal,cur_channel);
%             d = d(1);
%         end
        for index_d=1:length(d)
            counter = counter +1;
            data_crosscorr = load(fullfile(d(index_d).folder,d(index_d).name));
            cur_matfile = d(index_d).name;
            cur_tag = data_crosscorr.tag;
            cur_selection = data_crosscorr.Tag_Selection;
            %fprintf('Cross-Correlation loaded [File: %s, Ref: (%s,%s)]\n',cur_matfile,cur_animal,cur_channel);
            fprintf('Cross-Correlation loaded [File: %s, Tag: %s]\n',cur_matfile,cur_tag);
            
            % Collecting data
            for i=1:length(list_regions)
                cur_region = char(list_regions(i));
                index_region = find(strcmp(data_crosscorr.label_fus,cur_region)==1);
                if length(index_region)>1
                    index_region = index_region(end);
                end
                if isempty(index_region)
                    continue;
                end
                for j=1:length(list_bands)
                    cur_band = char(list_bands(j));
                    index_band = find(strcmp(data_crosscorr.label_lfp,cur_band)==1);
                    if length(index_band)>1
                        index_band = index_band(end);
                    end
                    if isempty(index_band)
                        continue;
                    end
                    
                    % S(i,j,k).animal = [S(i,j,k).animal;{cur_animal}];
                    S(i,j,k).animal = cur_animal;
                    % S(i,j,k).channel = [S(i,j,k).channel;{cur_channel}];
                    S(i,j,k).channel = cur_channel;
                    % S(i,j,k).region = [S(i,j,k).region;{cur_region}];
                    S(i,j,k).region = cur_region;
                    % S(i,j,k).band = [S(i,j,k).animal;{cur_band}];
                    S(i,j,k).band = cur_band;
                    S(i,j,k).recording = [S(i,j,k).recording;{cur_file}];
                    S(i,j,k).matfile = [S(i,j,k).matfile;{cur_matfile}];
                    S(i,j,k).tag = [S(i,j,k).tag;{cur_tag}];
                    S(i,j,k).Tag_Selection = [S(i,j,k).Tag_Selection;cur_selection];
                    
                    S(i,j,k).T_peak = [S(i,j,k).T_peak; data_crosscorr.T_peak(index_region,index_band)];
                    S(i,j,k).R_peak = [S(i,j,k).R_peak; data_crosscorr.R_peak(index_region,index_band)];
                end
            end 
        end 
    end
end
fprintf('Data Browsed [%d files loaded].\n',counter);

% Setting Parameters
f = figure('Visible','off');
colormap(f,'jet');
P.Colormap = f.Colormap;
%P.f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
P.f_colors =    [0.2422    0.1504    0.6603;
    0.2504    0.1650    0.7076;
    0.2578    0.1818    0.7511;
    0.2647    0.1978    0.7952;
    0.2706    0.2147    0.8364;
    0.2751    0.2342    0.8710;
    0.2783    0.2559    0.8991;
    0.2803    0.2782    0.9221;
    0.2813    0.3006    0.9414;
    0.2810    0.3228    0.9579;
    0.2795    0.3447    0.9717;
    0.2760    0.3667    0.9829;
    0.2699    0.3892    0.9906;
    0.1248    0.6459    0.8883;
    0.0952    0.6798    0.8598;
    0.0689    0.6948    0.8394;
    0.0297    0.7082    0.8163;
    0.0036    0.7203    0.7917;
    0.2470    0.7918    0.5567;
    0.2906    0.7973    0.5188;
    0.3406    0.8008    0.4789;
    0.6720    0.7793    0.2227;
    0.7242    0.7698    0.1910;
    0.7738    0.7598    0.1646;
    0.8203    0.7498    0.1535;
    0.8634    0.7406    0.1596;
    0.9035    0.7330    0.1774;
    0.9393    0.7288    0.2100;
    0.9728    0.7298    0.2394;
    0.9597    0.9135    0.1423;
    0.9628    0.9373    0.1265;
    0.9691    0.9606    0.1064;
    0.9769    0.9839    0.0805];
close(f);

P.margin_w = .01;
P.margin_h = .01;
P.n_columns = length(list_ref);
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
fprintf('Synthesis Data Saved [%s]\n',fullfile(folder_save,strcat(fName,'.mat')));

end

function R_peak_data = plot2(L,P,S,str)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
label_regions = L.label_regions;
label_lfp = L.label_lfp;
list_ref = L.list_ref;
%list_files = L.list_files;
list_bands = L.list_bands;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);

% margin_w = P.margin_w;
% margin_h = P.margin_h;
% n_columns = P.n_columns;
% n_rows = P.n_rows;
val1 = P.val1;
val2 = P.val2;
tick_width = P.tick_width;
thresh_average = P.thresh_average;
all_markers = P.all_markers;
all_linestyles = P.all_linestyles;
patch_alpha = P.patch_alpha;


%ax_dummy = axes('Parent',panel,'Position',[.1 .1 .8 .8],'Visible','off');
clrmenu(f);
switch str
    case 'Mean'
        f.Name = strcat(fName,'-B-Mean');
    case 'Median'
        f.Name = strcat(fName,'-B-Median');
end
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
f.Colormap = P.Colormap;
f_colors = P.f_colors;


% Getting data
R_peak_data = NaN(length(list_regions),length(list_bands),length(list_ref));
T_peak_data = NaN(length(list_regions),length(list_bands),length(list_ref));
n_recordings = NaN(length(list_regions),length(list_ref));
for k =1:length(list_ref)
    for i = 1:length(list_regions)
        for j = 1:length(list_bands)
            temp = S(i,j,k).R_peak;
            temp2 = S(i,j,k).T_peak;
            
            switch str
                case 'Mean'
                    R_peak_data(i,j,k)=mean(temp);
                    T_peak_data(i,j,k)=mean(temp2);
                case 'Median'
                    R_peak_data(i,j,k)=median(temp);
                    T_peak_data(i,j,k)=median(temp2);
            end
            n_recordings(i,k) = length(temp);
        end
    end
end

% % Sorting rt_data
% [A,ind_max_a] = max(R_peak_data(:,:,1),[],2,'omitnan');
% [~,ind_sorted_a] = sort(A,'ascend');
% [B,ind_max_b] = max(T_peak_data(:,:,2),[],2,'omitnan');
% [~,ind_sorted_b] = sort(B,'ascend');
ind_sorted_a = 1:length(list_regions);
ind_sorted_b = 1:length(list_bands);

% building axes
margin_w = .05;
margin_h = .05;
n_columns = 8;
n_rows = ceil(size(list_ref,1)/n_columns);
ax_1 = gobjects(n_rows,n_columns);
all_axes =[];
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index > size(list_ref,1)
            continue;
        end
        xx = mod(index-1,n_columns)/n_columns;
        yy = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax_1(ii,jj) = axes('Parent',panel);
        ax_1(ii,jj).Position= [xx+margin_w/2 yy+margin_h/2 (1/n_columns)-margin_w/2 (1/n_rows)-margin_h];
        %ax_1(ii,jj).Title.String = sprintf('Ax%d-%d',ii,jj);
        ax_1(ii,jj).Tag = sprintf('Ax%d-%d',ii,jj);
        ax_1(ii,jj).YLim = [0 .1];
        all_axes =[all_axes ;ax_1(ii,jj)];
    end
end

% plotting
for index=1:length(all_axes)
    ax = all_axes(index);
    im = imagesc(R_peak_data(:,:,index),'Parent',ax);
    ax.YLim = [.5 length(list_regions)+.5];
    ax.XLim = [.5 length(list_bands)+.5];
    ax.YTick = 1:length(list_regions);
    if mod(index,8)==1
        ax.YTickLabel = label_regions(ind_sorted_a);
    else
        ax.YTickLabel = strcat('(',num2str(n_recordings(ind_sorted_a,index)),')');
    end
    
    ax.XTick = 1:length(list_bands);
    ax.XTickLabel = label_lfp(ind_sorted_b);
    ax.XTickLabelRotation = 45;
    % colorbar(ax3,'southoutside');
    ax.CLim = [-1 1];
    % ax.CLim = [min(min(rt_data(:,:,1),[],'omitnan'),[],'omitnan') max(max(rt_data(:,:,1),[],'omitnan'),[],'omitnan')];
    ax.Title.String = sprintf('%s-%s',char(list_ref(index,1)),strrep(char(list_ref(index,2)),'_',''));
    ax.FontSize = 6;
    ax.TickLength = [0 0];
end


f.Units = 'pixels';
f.Position = [195          59        1245         919];

fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
saveas(f,fullname);

end
