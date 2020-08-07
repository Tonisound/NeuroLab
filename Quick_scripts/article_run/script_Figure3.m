% Article RUN
% Figure 3
% to run after batch fUS_Correlation 
% Display (and save figure) mean correlation patterns

function script_Figure3(cur_list,timegroup,flag_grouped,flag_sorted)

close all;
if nargin <4
    flag_sorted = true;
end

if nargin <3
    flag_grouped = true;
end

[D,R,S,list_regions] = compute_script_Figure3(cur_list,timegroup,flag_grouped);
plot1_Figure3(D,S,list_regions,R,flag_sorted)

end

function [D,R,S,list_regions] = compute_script_Figure3(cur_list,timegroup,flag_grouped)

flag_mainlfp = false;
seed = 'I:';
%seed = '/Volumes/Toni_HD2/';
folder = fullfile(seed,'NEUROLAB','NLab_Statistics','fUS_Correlation');
all_files = dir(fullfile(folder,'*_E'));
D = struct('file','','reference','','all_regions','','timegroup','','plane','','main_channel','');
index = 0;

list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';...
    '20150225_154031_E';'20150226_173600_E';'20150619_132607_E';'20150620_175137_E';...
    '20150714_191128_E';'20150715_181141_E';'20150716_130039_E';'20150717_133756_E';...
    '20150724_170457_E';'20150726_152241_E';'20150728_134238_E';'20151126_170516_E';...
    '20151201_144024_E';'20151202_141449_E';'20151203_113703_E';'20160622_191334_E';...
    '20160623_123336_E';'20160624_120239_E';'20160628_171324_E';'20160629_134749_E';...
    '20160629_191304_E'};
% high-definition
% list_coronal = {'20141216_225758B_E';'20141226_154835B_E';'20150223_170742B_E';'20150224_175307B_E';...
%     '20150225_154031B_E';'20150226_173600B_E';'20150619_132607B_E';'20150620_175137B_E';...
%     '20150714_191128B_E';'20150715_181141B_E';'20150716_130039B_E';'20150717_133756B_E';...
%     '20150724_170457B_E';'20150726_152241B_E';'20150728_134238B_E';'20151126_170516B_E';...
%     '20151201_144024B_E';'20151202_141449B_E';'20151203_113703B_E';'20160622_191334B_E';...
%     '20160623_123336B_E';'20160624_120239B_E';'20160628_171324B_E';'20160629_134749B_E';...
%     '20160629_191304B_E'};
% high-quality
% list_coronal = {'20141226_154835B_E';'20150223_170742B_E';'20150224_175307B_E';...
%     '20150225_154031B_E';'20150226_173600B_E';'20150619_132607B_E';'20150620_175137B_E';...
%     '20150714_191128B_E';'20150715_181141B_E';'20150716_130039B_E';'20150717_133756B_E';...
%     '20150724_170457B_E';'20150726_152241B_E';'20151126_170516B_E';...
%     '20151202_141449B_E';'20160622_191334B_E';...
%     '20160623_123336B_E';'20160624_120239B_E'};

list_diagonal = {'20150227_134434_E';'20150304_150247_E';'20150305_190451_E';'20150306_162342_E';...
    '20150718_135026_E';'20150722_121257_E';'20150723_123927_E';'20150724_131647_E';...
    '20150725_130514_E';'20150725_160417_E';'20150727_114851_E';'20151127_120039_E';...
    '20151128_133929_E';'20151204_135022_E';'20160622_122940_E';'20160623_163228_E';...
    '20160623_193007_E';'20160624_171440_E';'20160625_113928_E';'20160625_163710_E';...
    '20160630_114317_E';'20160701_130444_E'};
% high-definition
% list_diagonal = {'20150227_134434B_E';'20150304_150247B_E';'20150305_190451B_E';'20150306_162342B_E';...
%     '20150718_135026B_E';'20150722_121257B_E';'20150723_123927B_E';'20150724_131647B_E';...
%     '20150725_130514B_E';'20150725_160417B_E';'20150727_114851B_E';'20151127_120039B_E';...
%     '20151128_133929B_E';'20151204_135022B_E';'20160622_122940B_E';'20160623_163228B_E';...
%     '20160623_193007B_E';'20160624_171440B_E';'20160625_113928B_E';'20160625_163710B_E';...
%     '20160630_114317B_E';'20160701_130444B_E'};
% high-quality
% list_diagonal = {'20150227_134434B_E';'20150304_150247B_E';'20150305_190451B_E';'20150306_162342B_E';...
%     '20150718_135026B_E';'20150722_121257B_E';'20150723_123927B_E';'20150724_131647B_E';...
%     '20150725_160417B_E';'20150727_114851B_E';'20151127_120039B_E';...
%     '20151204_135022B_E';'20160623_163228B_E';...
%     '20160623_193007B_E';'20160625_113928B_E'};

list_frontal = {'20200616_135248_E_nlabSEP2';'20200618_132755_E';...
    '20200619_130453_E';'20200624_163458_E';...
    '20200701_092506_E';'20200701_113622_E';...
    '20200701_134008_E';'20200702_111111_E';...
    '20200709_151857_E';...'20200709_092810_E';;'20200710_123006_E'
    '20200710_093807_E'};

list_sagittal = {'20200630_155022_E';'20200703_132316_E';...
    '20200703_153247_E';'20200703_183145_E';...
    '20200704_125924_E';'20200704_145737_E'};


% list of references to search (in order)
% list_ref = {'SPEED'};
list_ref = {'SPEED';'ACCEL'};
% list_ref = {'Power-theta'};

for i = 1:length(all_files)
    
    index = index+1;
    cur_file = char(all_files(i).name);
    % reference
    % d = dir(fullfile(folder,cur_file,'*_normalized'));
    d = dir(fullfile(folder,cur_file,timegroup,'Ref-*'));
    
    % Getting main channel
    if exist(fullfile(seed,'NEUROLAB','NLab_DATA',strrep(cur_file,'_E','_E_nlab'),'Config.mat'),'file')
        data_config = load(fullfile(seed,'NEUROLAB','NLab_DATA',strrep(cur_file,'_E','_E_nlab'),'Config.mat'),'File');
        D(index).main_channel = data_config.File.mainlfp ;
    end
    
    flag_ref=false;
    for j=1:length(list_ref) 
        pattern = char(list_ref(j));
        
        if sum(contains({d(:).name}',pattern))>0
            ind_keep = find(contains({d(:).name}',pattern)==1);
            if length(ind_keep)>1
                % Selecting
                % main channel
                if flag_mainlfp
                    ind_keep2 = find(contains({d(ind_keep).name}',D(index).main_channel)==1);
                    if length(ind_keep2)==1
                        reference = char(d(ind_keep(ind_keep2)).name);
                        flag_ref = true;
                        break;
                    end
                end
                
                % highest correlation
                rmax_score=[];
                for k=1:length(ind_keep)
                    if exist(fullfile(folder,cur_file,timegroup,char(d(ind_keep(k)).name),'Correlation_pattern.mat'),'file')
                        data_cp = load(fullfile(folder,cur_file,timegroup,char(d(ind_keep(k)).name),'Correlation_pattern.mat'),'RT_pattern');
                        rmax_score=[rmax_score;mean(max(data_cp.RT_pattern,[],2,'omitnan'),'omitnan')];         
                    end
                end
                % Selection criterion
                if isempty(rmax_score)
                    ind_selected=1;
                else
                    [~, ind_selected] = max(rmax_score);
                end
            else
                ind_selected = 1;
            end
            
            reference = char(d(ind_keep(ind_selected)).name);
            flag_ref = true;
            break;
        end      
    end
    % skip if ref not found
    if ~flag_ref
        continue;
    end
    
    % Storing all_regions
    dd = dir(fullfile(folder,cur_file,timegroup,reference,'Correlation_pattern.mat'));
    if ~isempty(dd)
        ddd = load(fullfile(dd(1).folder,dd(1).name));
        all_regions = ddd.labels;
    else
        continue;
    end
    
    % updating struct D
    D(index).file = cur_file;
    D(index).reference = reference;
    D(index).timegroup = timegroup;
    D(index).all_regions = all_regions;
    if sum(contains(list_coronal,cur_file))>0
        D(index).plane = 'CORONAL';
    elseif sum(contains(list_diagonal,cur_file))>0
        D(index).plane = 'DIAGONAL';
    elseif sum(contains(list_frontal,cur_file))>0
        D(index).plane = 'FRONTAL';
    elseif sum(contains(list_sagittal,cur_file))>0
        D(index).plane = 'SAGITTAL';
    else
        D(index).plane = 'UNDEFINED';
    end
    
end

% list_regions
if strcmp(cur_list,'CORONAL')
    if ~flag_grouped
        list_regions = {'AC-L';'AC-R';'S1BF-L';'S1BF-R';'LPtA-L';'LPtA-R';'RS-L';'RS-R';...
            'DG-L';'DG-R';'CA1-L';'CA1-R';'CA2-L';'CA2-R';'CA3-L';'CA3-R';...
            'dThal-L';'dThal-R';'Po-L';'Po-R';'VPM-L';'VPM-R';...
            'HypothalRg-L';'HypothalRg-R'};
    else
        list_regions = {'AC';'S1BF';'LPtA';'RS';...
            'DG';'CA1';'CA2';'CA3';...
            'dThal';'Po';'VPM';'HypothalRg'};
    end
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
elseif  strcmp(cur_list,'DIAGONAL')
    if ~flag_grouped
        list_regions = {'AntCortex-L';'AMidCortex-L';'PMidCortex-R';'PostCortex-R';...
            'DG-R';'CA3-R';'CA1-R';'dHpc-R';'vHpc-R';...
            'dThal-R';'vThal-R';'Thalamus-L';'Thalamus-R';'CPu-L';'CPu-R';...
            'HypothalRg-L';'HypothalRg-R'};
    else
        list_regions = {'AntCortex';'AMidCortex';'PMidCortex';'PostCortex';...
            'DG';'CA3';'CA1';'dHpc';'vHpc';...
            'dThal';'vThal';'Thalamus';'CPu'};
    end
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
elseif  strcmp(cur_list,'FRONTAL')
    if ~flag_grouped
        list_regions = {'M1-L';'M1-R';'M2-L';'M2-R';...
            'Cg1-L';'Cg1-R';'IL-L';'IL-R';...
            'PrL-L';'PrL-R';'CPu-L';'CPu-R';...
            'fmi-L';'fmi-R'};
    else
        list_regions = {'M1';'M2';'Cg1';'IL';...
            'PrL';'CPu';'fmi'};
    end
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
elseif  strcmp(cur_list,'SAGITTAL')
    list_regions = {'M1';'M2';'Cg1';'MPtA';...
            'VM';'Po';'CA3Py';'GrDG';...
            'Neocortex';'dHpc';'Thalamus'};
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
else
    if ~flag_grouped
        list_regions =    {'Neocortex-L';'Neocortex-R';...
            'dHpc-L';'dHpc-R';...
            'Thalamus-L';'Thalamus-R';...
            'HypothalRg-L';'HypothalRg-R'};
    else
        list_regions =    {'Neocortex';'dHpc';'Thalamus';'HypothalRg';'Whole'};
    end
end
    
% Buidling struct S
rmax_regions = NaN(length(D),length(list_regions)); 
tmax_regions = NaN(length(D),length(list_regions));
rmax_regions_resamp = NaN(length(D),length(list_regions)); 
tmax_regions_resamp = NaN(length(D),length(list_regions));
S = struct('labels','','ref_name','','lags','','step','',...
    'RT_pattern','','Rmax_map','','Tmax_map','','background','',...
    'RT_pattern_resamp','','lags_resampled','');
    
for index = 1:length(D)
    
    cur_file = D(index).file;
    reference = D(index).reference;
    timegroup = D(index).timegroup;
    %fulpath = fullfile(folder,cur_file,reference,timegroup,'Regions');
    
    % Loading UF
    data_uf = load(fullfile(folder,cur_file,timegroup,reference,'UF.mat'),'UF');
    % data_c = load(fullfile(folder,cur_file,timegroup,reference,'Correlation_pattern.mat'),'RT_pattern','Rmax_map','Tmax_map');
    data_c = load(fullfile(folder,cur_file,timegroup,reference,'Correlation_pattern.mat'));
    S(index).labels = data_uf.UF.labels;
    S(index).ref_name = data_uf.UF.ref_name;
    S(index).lags = data_uf.UF.lags;
    S(index).step = data_uf.UF.step;
    
    S(index).RT_pattern = data_c.RT_pattern;
    S(index).Rmax_map = data_c.Rmax_map;
    S(index).Tmax_map = data_c.Tmax_map;
    
    % Loading rmax, tmax
    for i=1:length(list_regions)
        region_name = char(list_regions(i));
        ind_region = find(strcmp(S(index).labels,region_name)==1);
        if ~isempty(ind_region)
            rmax_regions(index,i) = data_c.r_max(ind_region(1));
            tmax_regions(index,i) = data_c.x_max(ind_region(1));
        end
    end

    % Computing rmax, tmax
    RT_pattern = S(index).RT_pattern;
    labels = S(index).labels ;
    %lags_s = S(index).lags*S(index).step; 
    lags_s = data_c.x_;
    resamp_step = 0.01;
    lags_resampled = lags_s(1):resamp_step:lags_s(end);
    RT_pattern_resamp = interp2(lags_s,(1:size(RT_pattern,1))',RT_pattern,lags_resampled,(1:size(RT_pattern,1))');
    [RT_pattern_rmax,RT_pattern_imax] = max(RT_pattern_resamp,[],2);
    RT_pattern_tmax = [];
    for k=1:length(RT_pattern_imax)
        RT_pattern_tmax = [RT_pattern_tmax;lags_resampled(RT_pattern_imax(k))];
    end    
    S(index).RT_pattern_resamp = RT_pattern_resamp;
    S(index).lags_resampled = lags_resampled;
    
    % Loading rmax_resamp, tmax_resamp
    for i=1:length(list_regions)
        region_name = strrep(char(list_regions(i)),'.mat','');
        ind_keep = find(strcmp(labels,region_name)==1);
        if ~isempty(ind_keep)
            rmax_regions_resamp(index,i) = RT_pattern_rmax(ind_keep(1));
            tmax_regions_resamp(index,i) = RT_pattern_tmax(ind_keep(1));
        end
    end
    
    % Loading background image
    folder_im = fullfile(seed,'NEUROLAB','NLab_DATA');
    try
        data_im = load(fullfile(folder_im,strcat(cur_file,'_nlab'),'Config.mat'),'Current_Image');
    catch
        data_im.Current_Image = zeros(size(data_c.Rmax_map));
    end
    im_baseline = data_im.Current_Image; 
    S(index).background = 20*log10(abs(im_baseline)/max(max(abs(im_baseline))));
end

R.rmax_regions = rmax_regions;
R.tmax_regions = tmax_regions;

end

function plot1_Figure3(D,S,list_regions,R,flag_sorted)

rmax_regions = R.rmax_regions;
tmax_regions = R.tmax_regions;

% if sum(strcmp({D(:).plane}','DIAGONAL'))==length(D)
%     tmax_regions= tmax_regions+.2;
% end

% Drawing results
f = figure;
%colormap(f,'parula');
colormap(f,'copper');    
clrmenu(f);
cmap = f.Colormap;

% Ax1
ax1 = subplot(131);
%rmax_regions = rmax_regions.^2;
m = mean(rmax_regions,1,'omitnan');
s_sem = std(rmax_regions,[],1,'omitnan')./sum(~isnan(rmax_regions),1);
b1 = bar(1:length(list_regions),diag(m),'stacked','Parent',ax1);
hold on;
e1 = errorbar(diag(m),diag(s_sem),'Color','k',...
    'Parent',ax1,'LineStyle','none','LineWidth',1);
x_dots = repmat(1:length(list_regions),[length(D) 1]);
plot(x_dots',rmax_regions','Linestyle','none','Linewidth',.1,'Color','k',...
    'Marker','o','MarkerSize',3,'MarkerFaceColor','k','MarkerEdgeColor','none','Parent',ax1);
ax1.XTick = 1:length(list_regions);
ax1.XTickLabel = regexprep(list_regions,'.mat','');
ax1.XTickLabelRotation = 45;
ax1.YLabel.String = 'rmax';
% sort rmax
if flag_sorted
    [~,ind_sorted_r] = sort(m,'descend');
else
    ind_sorted_r = 1:length(m);
end
colorbar(ax1,'northoutside');

% Ax2
ax2 = subplot(132);
m = mean(tmax_regions,1,'omitnan');
s_sem = std(tmax_regions,[],1,'omitnan')./sqrt(sum(~isnan(tmax_regions),1));
% sort timing
if flag_sorted
    [~,ind_sorted_t] = sort(m,'ascend');
else
    ind_sorted_t = 1:length(m);
end
%m = m(ind_sorted_r);
%s_sem = s_sem(ind_sorted_r);
list_regions_sorted_r = list_regions(ind_sorted_r);
list_regions_sorted_t = list_regions(ind_sorted_t);

ind_sorted = ind_sorted_t;
list_regions_sorted = list_regions_sorted_t;
b2 = bar(diag(m(ind_sorted)),'stacked','Parent',ax2);
hold on;
e2 = errorbar(diag(m(ind_sorted)),diag(s_sem(ind_sorted)),'Color','k',...
    'Parent',ax2,'LineStyle','none','LineWidth',1);
% dots = 
x_dots = repmat(1:length(list_regions_sorted),[length(D) 1]);
plot(x_dots',tmax_regions(:,ind_sorted)','Linestyle','none','Linewidth',.1,'Color','k',...
    'Marker','o','MarkerSize',3,'MarkerFaceColor','k','MarkerEdgeColor','none','Parent',ax2);
ax2.XTick = 1:length(list_regions_sorted);
ax2.XTickLabel = regexprep(list_regions_sorted,'.mat','');
ax2.XTickLabelRotation = 45;
ax2.YLabel.String = 'tmax';
ax2.YLim = [0, 3.5];
%[1.2, 1.6];
colorbar(ax2,'northoutside');

% relative timing
test_relative = true;
if test_relative
    ind_relative = find(strcmpi(list_regions,'M1'));
    if isempty(ind_relative)
        ind_relative = find(strcmpi(list_regions,'M1-L'));
    end
    if ~isempty(ind_relative)
        t_relative =  repmat(tmax_regions(:,ind_relative),[1 size(tmax_regions,2)]);
        tmax_regions_relative = tmax_regions-t_relative; 
    end
end
% Ax3
ax3 = subplot(133);
m = mean(tmax_regions_relative,1,'omitnan');
s_sem = std(tmax_regions_relative,[],1,'omitnan')./sqrt(sum(~isnan(tmax_regions_relative),1));
%ax3.YLim = [0, 1];

b3 = bar(diag(m(ind_sorted)),'stacked','Parent',ax3);
hold on;
e3 = errorbar(diag(m(ind_sorted)),diag(s_sem(ind_sorted)),'Color','k',...
    'Parent',ax3,'LineStyle','none','LineWidth',1);
% dots = 
x_dots = repmat(1:length(list_regions_sorted),[length(D) 1]);
plot(x_dots',tmax_regions_relative(:,ind_sorted)','Linestyle','none','Linewidth',.1,'Color','k',...
    'Marker','o','MarkerSize',3,'MarkerFaceColor','k','MarkerEdgeColor','none','Parent',ax3);
ax3.XTick = 1:length(list_regions_sorted);
ax3.XTickLabel = regexprep(list_regions_sorted,'.mat','');
ax3.XTickLabelRotation = 45;
ax3.YLabel.String = 'tmax-relative';
ax3.YLim = [-1, 1.5];
%[1.2, 1.6];
colorbar(ax3,'northoutside');

% colors
%ind_cmap = round(1:length(cmap)/length(b1):length(cmap));
cmap = cmap(1:floor(length(cmap)/length(b1)):end,:);
list_regions_sorted = list_regions_sorted_r;

for i =1:length(list_regions_sorted)
    ind_b2 = find(strcmp(ax2.XTickLabel,list_regions_sorted(i))==1);
    b2(ind_b2).FaceColor = cmap(i,:);
    b2(ind_b2).EdgeColor='none';
    
    b3(ind_b2).FaceColor = cmap(i,:);
    b3(ind_b2).EdgeColor='none';
    
    ind_b1 = find(strcmp(ax1.XTickLabel,list_regions_sorted(i))==1);
    b1(ind_b1).FaceColor=cmap(i,:);
    %b1(ind_b1).FaceColor=cmap_sorted(i,:);
    b1(ind_b1).EdgeColor='none';
end

% Drawing results
f1 = figure;
colormap(f1,'parula');
clrmenu(f1);
cmap = f1.Colormap;

% Ax1
%ax1 = axes('Parent',f1);
ax1 = subplot(211,'Parent',f1);
%rmax_regions = rmax_regions.^2;
m_r = mean(rmax_regions,1,'omitnan');
m_t = mean(tmax_regions,1,'omitnan');
s_sem = std(tmax_regions,[],1,'omitnan')./sqrt(sum(~isnan(tmax_regions),1));

% Box Plot
n_bars = size(rmax_regions,2);
positions = m_t;
ind_colors = 1:63/(n_bars-1):64;
colors = cmap(round(ind_colors),:);
colors_= colors(ind_sorted_t,:);
boxplot(rmax_regions.^2,...
    'MedianStyle','target',...
    'positions',positions,...
    'colors',colors_,...
    'Width',.025,...
    'OutlierSize',1,...
    'Parent',ax1);
%'PlotStyle','compact',...
ax1.YLabel.String = 'rmax^2';
ax1.YGrid = 'on';
ax1.XLim= [0.0,3.0];
ax1.YLim= [0,1];
ax1.YTick = ax1.YLim(1):.2:ax1.YLim(end); 
for i =1:length(list_regions)
    text(positions(i),(m_r(i))^2,char(list_regions(i)));
end
ax1.XTick = ax1.XLim(1):.5:ax1.XLim(2);
xticklabel = [];
for i =1:length(ax1.XTick)
    xticklabel = [xticklabel;{sprintf('%.1f',ax1.XTick(i))}];
end
ax1.XTickLabel = xticklabel;
grid(ax1,'on');
% ax1.XTickLabelRotation = 45;

ax2 = subplot(212,'Parent',f1);
ax2.YLabel.String = 'Activation Sequence';
% lines
m_t_ = m_t(ind_sorted_t);
s_sem_ = s_sem(ind_sorted_t);
for i =1:length(m_t_)
    line('XData',[m_t_(i)-s_sem_(i) m_t_(i)+s_sem_(i)],'YData',[i i],'Color',colors_(i,:),...
        'LineStyle','-','LineWidth',1,'Parent',ax2);
    text(m_t_(i)-.1,i+.4,char(list_regions_sorted_t(i)));
    text(m_t_(i)-s_sem_(i)-.1,i+.4,sprintf('%.2f',m_t_(i)-s_sem_(i)));
    text(m_t_(i)+s_sem_(i)-.1,i+.4,sprintf('%.2f',m_t_(i)+s_sem_(i)));
end
ax2.YLim= [0 length(m_t)+1];
ax2.XLim= ax1.XLim;
ax2.XTick = ax1.XTick;
ax2.XTickLabel = ax1.XTickLabel;
ax2.YTick = [];
ax2.XGrid = 'on';

% Drawing Rmax/Tmax_pattern
f2 = figure;
n_columns = 8;
n_rows = ceil(length(S)/n_columns);
margin_w=.01;
margin_h=.02;
alpha_value = .2;
cmin = 0.2;
cmax = 0.6;
tmin = -1;
tmax = 5;

%Rmax
% axes creation
all_axes = gobjects(length(S),1);
all_axes0 = gobjects(length(S),1);
for i = 1:n_rows
    for j = 1:n_columns
        index = (i-1)*n_columns+j;
        if index>length(S)
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        
        ax0 = axes('Parent',f2);
        ax0.Position = [x+margin_w y+.2*margin_h (1/n_columns)-2*margin_w (1/n_rows)-2*margin_h];
        colormap(ax0,'gray');
        all_axes0(index) = ax0;
        
        ax = axes('Parent',f2);
        ax.Position = [x+margin_w y+.2*margin_h (1/n_columns)-2*margin_w (1/n_rows)-2*margin_h];
        colormap(ax,'jet');
        all_axes(index) = ax;
        
    end
end
%plotting
for k =1:length(S)
    
    %background
    ax0 = all_axes0(k);
    imagesc(S(k).background,'Parent',ax0);
    ax0.Visible = 'off';
    
    %image
    ax = all_axes(k);
    im = imagesc(S(k).Rmax_map,'Parent',ax);
    im.AlphaData = im.CData>alpha_value;
    ref = strrep(D(k).reference,'_','-');
    ref = strrep(ref,'-Doppler-normalized','-');
    ax.Title.String = sprintf('%s\n%s',strrep(D(k).file,'_','-'),ref);
    ax.FontSize = 6;
    
    ax.Visible = 'off';
    ax.Title.Visible ='on';
    ax.CLim = [cmin cmax];
    %colorbar
    if k==length(S)
        c = colorbar(ax);
        c.Position = [ax.Position(1)+ax.Position(3)+margin_w ax.Position(2) margin_w ax.Position(4)];
    end

end

f3 = figure;
%Tmax
% axes creation
all_axes = gobjects(length(S),1);
all_axes0 = gobjects(length(S),1);
for i = 1:n_rows
    for j = 1:n_columns
        index = (i-1)*n_columns+j;
        if index>length(S)
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        
        ax0 = axes('Parent',f3);
        ax0.Position = [x+margin_w y+.2*margin_h (1/n_columns)-2*margin_w (1/n_rows)-2*margin_h];
        colormap(ax0,'gray');
        all_axes0(index) = ax0;
        
        ax = axes('Parent',f3);
        ax.Position = [x+margin_w y+.2*margin_h (1/n_columns)-2*margin_w (1/n_rows)-2*margin_h];
        colormap(ax,'jet');
        all_axes(index) = ax;
        
    end
end
%plotting
for k =1:length(S)
    
    %background
    ax0 = all_axes0(k);
    imagesc(S(k).background,'Parent',ax0);
    ax0.Visible = 'off';
    
    %image
    ax = all_axes(k);
    im = imagesc(S(k).Tmax_map,'Parent',ax);
    im.AlphaData = S(k).Rmax_map>alpha_value;
    ax.Title.String = strrep(D(k).file,'_','-');
    ax.Visible = 'off';
    ax.Title.Visible ='on';
    ax.CLim = [tmin tmax];
    %colorbar
    if k==length(S)
        c = colorbar(ax);
        c.Position = [ax.Position(1)+ax.Position(3)+margin_w ax.Position(2) margin_w ax.Position(4)];
    end

end

% Drawing Rmax_pattern
f4 = figure;
% axes creation
all_axes = gobjects(length(S),1);
for i = 1:n_rows
    for j = 1:n_columns
        index = (i-1)*n_columns+j;
        if index>length(S)
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax = axes('Parent',f4);
        ax.Position = [x+3*margin_w y+.2*margin_h (1/n_columns)-3*margin_w (1/n_rows)-2*margin_h];
        colormap(ax,'jet');
        all_axes(index) = ax;  
    end
end
%plotting
for k =1:length(S)
    ax = all_axes(k);
    colormap(ax,'parula');
    RT_pattern = S(k).RT_pattern_resamp;
    lags = S(k).lags_resampled;
    % RT_pattern = S(k).RT_pattern;
    % lags = S(k).lags*S(k).step; 
    
    imagesc('XData',lags,'YData',1:length(S(k).labels),'CData',RT_pattern,'Parent',ax);
    ax.Title.String = strrep(D(k).file,'_','-');
    %ax.Visible = 'off';
    ax.Title.Visible ='on';
    ax.CLim = [0 .8];
    ax.XLim = [S(k).lags(1)*S(k).step S(k).lags(end)*S(k).step];
    ax.XTick = S(k).lags(1:5:end)*S(k).step;
    %ax.XTick = '';
    ax.XTickLabel = round(S(k).lags(1:5:end)*S(k).step);
    ax.FontSize = 5;
    ax.Title.FontSize = 10;
    
    % ticks
    [~,imax] = max(RT_pattern,[],2,'omitnan');
    ydat = [];
    for kk=1:size(RT_pattern,1)
        ydat = [ydat;lags(imax(kk))];
    end  
%     line('YData',1:length(S(k).labels),'XData',ydat,'Parent',ax,...
%         'LineStyle','none','MarkerSize',3,'Marker','o',...
%         'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
    line('YData',1:length(S(k).labels),'XData',ydat,'Parent',ax,...
        'LineStyle','--','MarkerSize',3,'Marker','none',...
        'Color',[.5 .5 .5],'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
    
    ax.YLim = [.5,length(S(k).labels)+.5];
    ax.YTick = 1:length(S(k).labels);
    ax.YTickLabel = S(k).labels;
    
    if k==length(S)
        c = colorbar(ax);
        c.Position = [ax.Position(1)+ax.Position(3)+margin_w ax.Position(2) margin_w ax.Position(4)];
    end
end
end