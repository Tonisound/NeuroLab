% Article RUN
% Figure 2

function script_Figure5(cur_list,timegroup,gather_regions)

if nargin <3
    gather_regions = false;
end

[D,R,S,list_regions] = compute_script_Figure5(cur_list,timegroup);
plot1_Figure5(S,list_regions,cur_list,timegroup,gather_regions);

end

function [D,R,S,list_regions] = compute_script_Figure5(cur_list,timegroup)

close all;
folder = 'I:\NEUROLAB\NLab_Statistics\fUS_PeriEventHistogram';
all_files = dir(fullfile(folder,'*_E'));
index =0;

list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';...
    '20150225_154031_E';'20150226_173600_E';'20150619_132607_E';'20150620_175137_E';...
    '20150714_191128_E';'20150715_181141_E';'20150716_130039_E';'20150717_133756_E';...
    '20150724_170457_E';'20150726_152241_E';'20150728_134238_E';'20151126_170516_E';...
    '20151201_144024_E';'20151202_141449_E';'20151203_113703_E';'20160622_191334_E';...
    '20160623_123336_E';'20160624_120239_E';'20160628_171324_E';'20160629_134749_E';...
    '20160629_191304_E'};
%list_coronal = {'20150223_170742_E';'20150224_175307_E';'20150225_154031_E'};
list_diagonal = {'20150227_134434_E';'20150304_150247_E';'20150305_190451_E';'20150306_162342_E';...
    '20150718_135026_E';'20150722_121257_E';'20150723_123927_E';'20150724_131647_E';...
    '20150725_130514_E';'20150725_160417_E';'20150727_114851_E';'20151127_120039_E';...
    '20151128_133929_E';'20151204_135022_E';'20160622_122940_E';'20160623_163228_E';...
    '20160623_193007_E';'20160624_171440_E';'20160625_113928_E';'20160625_163710_E';...
    '20160630_114317_E';'20160701_130444_E'};

% list of references to search (in order)
%list_ref = {'SPEED';'ACCEL'};
%list_ref = {'heta'};
% timegroup = 'RIGHT_RUNS';
% cur_list = 'DIAGONAL';

% Buidling struct D
D = struct('file','','Doppler_ref','','str_ref','','timegroup','','plane','','rat_name','','rat_id','',...
    'labels_fus','','labels_lfp','','labels_cfc','','EventSelection','');
for i = 1:length(all_files)
    cur_file = char(all_files(i).name);
    
   % timegroup
    dd = dir(fullfile(folder,cur_file,timegroup,'RecordingInfo.mat'));
    if ~isempty(dd)
        data_dd = load(fullfile(folder,cur_file,timegroup,'RecordingInfo.mat'));
        %all_regions = {ddd(:).name}';
    else
        continue;
    end
    
    % updating struct D
    index = index+1;
    D(index).file = cur_file;
    D(index).Doppler_ref = data_dd.Doppler_ref;
    D(index).str_ref = data_dd.str_ref;
    D(index).timegroup = timegroup;
    D(index).rat_name = data_dd.rat_name;
    D(index).rat_id = data_dd.rat_id;
    
    D(index).labels_fus = data_dd.labels_fus;
    D(index).labels_lfp = data_dd.labels_lfp;
    D(index).labels_cfc = data_dd.labels_cfc;
    D(index).EventSelection = data_dd.EventSelection;
    
    if sum(contains(list_coronal,cur_file))>0
        D(index).plane = 'CORONAL';
    elseif sum(contains(list_diagonal,cur_file))>0
        D(index).plane = 'DIAGONAL';
    else
        D(index).plane = 'UNDEFINED';
    end
end

% list_regions
if strcmp(cur_list,'CORONAL')
    list_regions = {'AC-L.mat';'AC-R.mat';'S1BF-L.mat';'S1BF-R.mat';'LPtA-L.mat';'LPtA-R.mat';'RS-L.mat';'RS-R.mat';...
        'DG-L.mat';'DG-R.mat';'CA1-L.mat';'CA1-R.mat';'CA2-L.mat';'CA2-R.mat';'CA3-L.mat';'CA3-R.mat';...
        'dThal-L.mat';'dThal-R.mat';'Po-L.mat';'Po-R.mat';'VPM-L.mat';'VPM-R.mat';...
        'HypothalRg-L.mat';'HypothalRg-R.mat'};
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
elseif  strcmp(cur_list,'DIAGONAL')
    list_regions = {'AntCortex-L.mat';'AMidCortex-L.mat';'PMidCortex-R.mat';'PostCortex-R.mat';...
        'DG-R.mat';'CA3-R.mat';'CA1-R.mat';'dHpc-R.mat';'vHpc-R.mat';...
        'dThal-R.mat';'vThal-R.mat';'Thalamus-L.mat';'Thalamus-R.mat';'CPu-L.mat';'CPu-R.mat';...
        'HypothalRg-L.mat';'HypothalRg-R.mat'};
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
else
    list_regions =    {'Neocortex-L.mat';'Neocortex-R.mat';...
        'dHpc-L.mat';'dHpc-R.mat';...
        'Thalamus-L.mat';'Thalamus-R.mat';...
        'HypothalRg-L.mat';'HypothalRg-R.mat'};
end
    
% Buidling struct S
% All_trials
S = struct('Ydata',[],'Xdata',[],'ind_end',[],'ind_start',[],'label_events','','region','',...
    't_start',[],'t_end',[],'file','','str_ref','','rat_name','','rat_id','');
S(length(list_regions)).Ydata = [];

% Average per recording
R = struct('ref_time',[],'m',[],'s',[],'ind_start',[],'ind_end',[],'labels','','str_popup','');
R(length(list_regions)).Ydata = [];

lmax = 5000;
    
for index = 1:length(D)
    
    cur_file = D(index).file;
    str_ref = D(index).str_ref;
    timegroup = D(index).timegroup;
    fullpath = fullfile(folder,cur_file,timegroup);
    rat_name = D(index).rat_name;
    rat_id = D(index).rat_id;
    
    % Loading rmax, tmax
    data_fus = load(fullfile(fullpath,'fUS_Data.mat'));
    for i=1:length(list_regions)
        
        region_name = strrep(char(list_regions(i)),'.mat','');
        ind_keep = find(strcmp(data_fus.fUS_Selection(:,1),region_name)==1);
        
        if ~isempty(ind_keep)        
            Ydata_temp = cat(2,data_fus.Ydata(:,:,ind_keep),NaN(size(data_fus.Ydata,1),lmax-size(data_fus.Ydata,2)));
            S(i).Ydata = [S(i).Ydata;Ydata_temp];
            Xdata_temp = cat(2,data_fus.ref_time,NaN(1,lmax-length(data_fus.ref_time)));
            Xdata_temp = repmat(Xdata_temp,[size(Ydata_temp,1),1]);
            S(i).Xdata = [S(i).Xdata;Xdata_temp];
            S(i).label_events = [S(i).label_events;data_fus.label_events];
            S(i).t_start = [S(i).t_start;data_fus.Time_indices(:,2)-data_fus.Time_indices(1,1)];
            S(i).t_end = [S(i).t_end;data_fus.Time_indices(:,3)-data_fus.Time_indices(1,1)];
            
            S(i).region = region_name;
            S(i).ind_start = [S(i).ind_start;data_fus.ind_start];
            S(i).ind_end = [S(i).ind_end;data_fus.ind_end];
            
%             S(i).rat_name = [S(i).rat_name;repmat({D(index).rat_name},[size(Ydata_temp,1),1])];
%             S(i).rat_id = [S(i).rat_id;repmat({D(index).rat_id},[size(Ydata_temp,1),1])];
%             S(i).file = [S(i).file;repmat({cur_file},[size(Ydata_temp,1),1])];
%             S(i).str_ref =[S(i).str_ref;repmat({D(index).str_ref},[size(Ydata_temp,1),1])];      
            S(i).rat_name = [S(i).rat_name;{D(index).rat_name};repmat({''},[size(Ydata_temp,1),1])];
            S(i).rat_id = [S(i).rat_id;{D(index).rat_id};repmat({''},[size(Ydata_temp,1),1])];
            S(i).file = [S(i).file;{cur_file};repmat({''},[size(Ydata_temp,1),1])];
            S(i).str_ref =[S(i).str_ref;{D(index).str_ref};repmat({''},[size(Ydata_temp,1),1])];

        end
    end
    
    data_ar = load(fullfile(fullpath,'AverageResponse.mat'));
    for i=1:length(list_regions)
        
        region_name = strrep(char(list_regions(i)),'.mat','');
        ind_keep = find(strcmp(data_ar.labels,region_name)==1);
        if ~isempty(ind_keep)
            R(i).ind_start = [R(i).ind_start;mean(data_ar.ind_start)];
            R(i).ind_end = [R(i).ind_end;mean(data_ar.ind_end)];
            R(i).region = region_name;
            R(i).str_popup = [R(i).str_popup;{data_ar.str_popup}];
            
            R(i).ref_time = [R(i).ref_time;[data_ar.ref_time,NaN(1,lmax-length(data_ar.ref_time))]];
            R(i).m = [R(i).m;[data_ar.m(:,:,i),NaN(1,lmax-length(data_ar.ref_time))]];
            R(i).s = [R(i).s;[data_ar.s(:,:,i),NaN(1,lmax-length(data_ar.ref_time))]];
        end
    end
end
end

function plot1_Figure5(S,list_regions,cur_list,timegroup,gather_regions)

% Drawing results
f = figure;
%f.Name = sprintf('Synthesis Hemodynamics Response all_trials [%s | %s]',cur_list,timegroup);
f.Name = sprintf('Fig5_SynthesisB_%s-%s',cur_list,timegroup);
colormap(f,'parula');
f_colors = f.Colormap(round(1:64/length(S):64),:);

% Sixth tab
all_axes = [];
margin_w=.02;
margin_h=.02;
n_columns = 4;
n_rows = ceil(length(list_regions)/n_columns);
% Creating axes
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>length(list_regions)
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax = axes('Parent',f);
        ax.Position= [x+margin_w y+margin_h (1/n_columns)-2*margin_w (1/n_rows)-3*margin_h];
        ax.XAxisLocation ='origin';
        ax.Title.String = sprintf('Ax-%02d',index);
        ax.Title.Visible = 'on';
        all_axes = [all_axes;ax];
    end
end

%gather_regions = false;
if gather_regions
    labels_gathered = strrep(list_regions,'-L','');
    labels_gathered = strrep(labels_gathered,'-R','');
    [C, ~, ic] = unique(labels_gathered,'stable');
    % Reposition axes
    delete(all_axes(length(C)+1:end));
    n_rows = ceil(length(C)/n_columns);
    for ii = 1:n_rows
        for jj = 1:n_columns
            index = (ii-1)*n_columns+jj;
            if index>length(C)
                continue;
            end
            x = mod(index-1,n_columns)/n_columns;
            y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
            ax = all_axes(index);
            ax.Position= [x+margin_w y+margin_h (1/n_columns)-2*margin_w (1/n_rows)-3*margin_h];       
        end
    end
    all_axes = all_axes(ic);
else
    labels_gathered = list_regions;
end
labels_gathered=regexprep(labels_gathered,'.mat','');

% Plotting
for index = 1:length(S)
    
    if isempty(S(index).region)
        continue
    end
    
    ax = all_axes(index);
    if contains(S(index).region,'-L')
        marker = 'none';
        linestyle = '-';%'--';
    elseif contains(S(index).region,'-R')
        marker = 'none';
        linestyle = '-';%'-.';
    else
        marker = 'none';
        linestyle = '-';
    end
    
    % Building index_binned
    bins = 0:60:3600;
    value = S(index).t_start;
    value_binned = repmat(value,[1 length(bins)]);
    %index_binned = true(size(value,1),length(bins));
    crit_inf = repmat(bins,[size(value,1),1]);
    crit_sup = repmat([bins(2:end),Inf],[size(value,1),1]);
    index_binned = (value_binned>crit_inf).*(value_binned<=crit_sup);
    % Matrix notation
    T = index_binned./repmat(sum(index_binned),[size(index_binned,1) 1]);
    T(isnan(T))=0;
    
    Xdata = S(index).Xdata;
    Ydata = S(index).Ydata;
    ind_start = S(index).ind_start;
    ind_end = S(index).ind_end;
    m1 = mean(Ydata,2,'omitnan');
    m_binned = m1'*T;
    
    m2 = NaN(size(ind_end));
    lag=100;
    ind_ref = ind_end;
    for j=1:size(Ydata,1)
        m2(j) = mean(Ydata(j,ind_start(j)-lag:ind_ref(j)+lag),'omitnan');
    end
    m2(isnan(m2))=0;
    m_binned = m2'*T;
    str_fig = 'FullRun';
    
    b = bar(m_binned,'FaceColor',f_colors(index,:),...
        'EdgeColor','none','Parent',ax);
    title(ax,labels_gathered(index));
%     errorbar(bar_data,ebar_data,...
%         'Color','k',...
%         'Parent',ax2,...
%         'LineStyle','none',...
%         'MarkerSize',3,...
%         'LineWidth',.5);
    
    % axes limits
    ax.FontSize = 8;
    ax.XTick = 0:10:60;
    ax.XTickLabel = {'0';'10';'20';'30';'40';'50';'60'};
    ax.XLim = [.5 30.5];
    ax.YLim = [-5 20];
end

f.Units = 'pixels';
f.Position = [195          59        1045         919];
saveas(f,fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s%s%s',f.Name,str_fig,'.pdf')));
fprintf('Figure Saved [%s].\n',fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s%s',f.Name,'.pdf')));

end
