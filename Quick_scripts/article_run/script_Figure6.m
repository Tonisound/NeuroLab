% Article RUN
% Figure 6
% to run after batch Peri-Event Time Histogram 
% Display (and save figure)vascular plasticity for all brain regions
% Sorts all trials relative to the time of first trial 

function script_Figure6(cur_list,timegroup)

flag_group = true; % grouping regions (bilateral/unilateral)
flag_norm = false; % normalizing data per recording
flag_save = false; % saving figure

[D,R,S,list_regions] = compute_script_Figure6(cur_list,timegroup,flag_group);
plot1_Figure6(S,R,list_regions,cur_list,timegroup,flag_group,flag_norm,flag_save);

end

function [D,R,S,list_regions] = compute_script_Figure6(cur_list,timegroup,flag_group)

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
% % high-quality
% list_coronal = {'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';...
%     '20150225_154031_E';'20150226_173600_E';'20150619_132607_E';'20150620_175137_E';...
%     '20150714_191128_E';'20150715_181141_E';'20150716_130039_E';'20150717_133756_E';...
%     '20150724_170457_E';'20150726_152241_E';'20151126_170516_E';...
%     '20151202_141449_E';'20160622_191334_E';...
%     '20160623_123336_E';'20160624_120239_E';'20200709_092810_E';'20200710_123006_E'};%;

list_diagonal = {'20150227_134434_E';'20150304_150247_E';'20150305_190451_E';'20150306_162342_E';...
    '20150718_135026_E';'20150722_121257_E';'20150723_123927_E';'20150724_131647_E';...
    '20150725_130514_E';'20150725_160417_E';'20150727_114851_E';'20151127_120039_E';...
    '20151128_133929_E';'20151204_135022_E';'20160622_122940_E';'20160623_163228_E';...
    '20160623_193007_E';'20160624_171440_E';'20160625_113928_E';'20160625_163710_E';...
    '20160630_114317_E';'20160701_130444_E'};

list_frontal = {'20200616_135248_E';'20200618_132755_E';...
    '20200619_130453_E';'20200624_163458_E';...
    '20200701_092506_E';'20200701_113622_E';...
    '20200701_134008_E';'20200702_111111_E';...
    '20200702_152447_E';'20200709_151857_E';...'20200709_092810_E';;'20200710_123006_E'
    '20200710_093807_E'};


list_sagittal = {'20200630_155022_E';'20200703_132316_E';...
    '20200703_153247_E';'20200703_183145_E';...
    '20200704_125924_E';'20200704_145737_E'};

% list of references to search (in order)
% list_ref = {'SPEED';'ACCEL'};
% list_ref = {'Power-Theta'};
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
    if ~flag_group
        list_regions = {'AC-L.mat';'AC-R.mat';'S1BF-L.mat';'S1BF-R.mat';'LPtA-L.mat';'LPtA-R.mat';'RS-L.mat';'RS-R.mat';...
            'DG-L.mat';'DG-R.mat';'CA1-L.mat';'CA1-R.mat';'CA2-L.mat';'CA2-R.mat';'CA3-L.mat';'CA3-R.mat';...
            'dThal-L.mat';'dThal-R.mat';'Po-L.mat';'Po-R.mat';'VPM-L.mat';'VPM-R.mat';...
            'HypothalRg-L.mat';'HypothalRg-R.mat'};
    else
        list_regions = {'AC.mat';'S1BF.mat';'LPtA.mat';'RS.mat';...
            'DG.mat';'CA1.mat';'CA2.mat';'CA3.mat';...
            'dThal.mat';'Po.mat';'VPM.mat';'Thalamus.mat';...
            'HypothalRg.mat';'Whole.mat'};
    end
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
elseif  strcmp(cur_list,'DIAGONAL')
    if ~flag_group
        list_regions = {'AntCortex-L.mat';'AMidCortex-L.mat';'PMidCortex-R.mat';'PostCortex-R.mat';...
            'DG-R.mat';'CA3-R.mat';'CA1-R.mat';'dHpc-R.mat';'vHpc-R.mat';...
            'dThal-R.mat';'vThal-R.mat';'Thalamus-L.mat';'Thalamus-R.mat';'CPu-L.mat';'CPu-R.mat';...
            'HypothalRg-L.mat';'HypothalRg-R.mat'};
    else
        list_regions = {'AntCortex.mat';'AMidCortex.mat';'PMidCortex.mat';'PostCortex.mat';...
            'DG.mat';'CA3.mat';'CA1.mat';'dHpc.mat';'vHpc.mat';...
            'dThal.mat';'vThal.mat';'Thalamus.mat';'CPu.mat';...
            'HypothalRg.mat';'Whole.mat'};
    end
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
elseif  strcmp(cur_list,'FRONTAL')
    if ~flag_group
        list_regions = {'M1-L.mat';'M1-R.mat';'M2-L.mat';'M2-R.mat';...
            'Cg1-L.mat';'Cg1-R.mat';'IL-L.mat';'IL-R.mat';...
            'PrL-L.mat';'PrL-R.mat';'CPu-L.mat';'CPu-R.mat';...
            'fmi-L.mat';'fmi-R.mat'};
    else
        list_regions = {'M1.mat';'M2.mat';'Cg1.mat';'IL.mat';...
            'PrL.mat';'CPu.mat';'fmi.mat'};
    end
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
elseif  strcmp(cur_list,'SAGITTAL')
    list_regions = {'M1.mat';'M2.mat';'Cg1.mat';'MPtA.mat';...
            'VM.mat';'Po.mat';'CA3Py.mat';'GrDG.mat';...
            'Neocortex.mat';'dHpc.mat';'Thalamus.mat'};
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
else
    if ~flag_group
        list_regions =    {'Neocortex-L.mat';'Neocortex-R.mat';...
            'dHpc-L.mat';'dHpc-R.mat';...
            'Thalamus-L.mat';'Thalamus-R.mat';...
            'HypothalRg-L.mat';'HypothalRg-R.mat'};
    else
        list_regions =    {'Neocortex.mat';'dHpc.mat';'Thalamus.mat';'HypothalRg.mat';'Whole.mat'};
    end
end
    
% Buidling struct S
% All_trials
S = struct('Ydata',[],'Ydata_norm',[],'Xdata',[],'ind_end',[],'ind_start',[],'label_events','','region','',...
    't_start',[],'t_end',[],'file','','str_ref','','rat_name','','rat_id','');
S(length(list_regions)).Ydata = [];

% Average per recording
R = struct('ref_time',[],'m',[],'s',[],'ind_start',[],'ind_end',[],'labels','','str_popup','',...
    'p_strength',[],'p_offset',[],'rat_name','','rat_id','');
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
            
            % rescale
            m_ = mean(data_fus.Ydata(:),'omitnan');
            s_ = std(data_fus.Ydata(:),[],'omitnan');
            data_fus.Ydata = 10*(data_fus.Ydata-m_)/s_;
            
            Ydata_temp = cat(2,data_fus.Ydata(:,:,ind_keep),NaN(size(data_fus.Ydata,1),lmax-size(data_fus.Ydata,2)));
            S(i).Ydata = [S(i).Ydata;Ydata_temp];
            Xdata_temp = cat(2,data_fus.ref_time,NaN(1,lmax-length(data_fus.ref_time)));
            Xdata_temp = repmat(Xdata_temp,[size(Ydata_temp,1),1]);
            S(i).Xdata = [S(i).Xdata;Xdata_temp];
            S(i).label_events = [S(i).label_events;data_fus.label_events];
            % timing
            t_start = data_fus.Time_indices(:,2)-data_fus.Time_indices(1,1);
            t_end = data_fus.Time_indices(:,3)-data_fus.Time_indices(1,1);
            S(i).t_start = [S(i).t_start;t_start];
            S(i).t_end = [S(i).t_end;t_end];
            % indexes_start
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
            
            % Normalized data
            lag = 100;
            ind_ref = data_fus.ind_end;
            trial_norm = 1; % normalization trials
            all_norm_fact = [];
            for k =1:length(trial_norm)
                all_norm_fact = [all_norm_fact;mean(Ydata_temp(trial_norm(k),ind_ref(trial_norm(k))-lag:ind_ref(trial_norm(k))+lag),'omitnan')];
            end
            norm_factor = max(mean(abs(all_norm_fact)),1);
            Ydata_norm = Ydata_temp/norm_factor;
            S(i).Ydata_norm = [S(i).Ydata_norm;Ydata_norm];
            
            % polyfit
            x = data_fus.Time_indices(:,2)-data_fus.Time_indices(1,2);
            y = NaN(size(Ydata_temp,1),1);
            for j=1:size(Ydata_temp,1)
                y(j) = mean(Ydata_temp(j,ind_ref(j)-lag:ind_ref(j)+lag),'omitnan');
                %y(j) = median(Ydata_temp(j,ind_ref(j)-lag:ind_ref(j)+lag),'omitnan');
            end
            x = x(~isnan(y));
            y = y(~isnan(y));
            P = polyfit(x,y,1);
            R(i).p_strength = [R(i).p_strength;P(1)];
            R(i).p_offset = [R(i).p_offset;P(2)];
            R(i).rat_name = [R(i).rat_name;{rat_name}];
            R(i).rat_id = [R(i).rat_id;{rat_id}];
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

function plot1_Figure6(S,R,list_regions,cur_list,timegroup,flag_group,flag_norm,flag_save)

% Drawing results
f = figure;
%f.Name = sprintf('Synthesis Hemodynamics Response all_trials [%s | %s]',cur_list,timegroup);
f.Name = sprintf('Fig5_SynthesisB_%s-%s',cur_list,timegroup);
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
colormap(f,'parula');
f_colors = f.Colormap(round(1:64/length(S):64),:);

% Sixth tab
all_axes = [];
margin_w=.02;
margin_h=.02;
n_columns = 4;
n_rows = ceil(length(list_regions)/n_columns);
all_P = [];
all_E = [];
    
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

%flag_group = false;
if flag_group
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
        continue;
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
    if flag_norm
        % working with normalized data
        Ydata = S(index).Ydata_norm;
    else
        % working with raw data
        Ydata = S(index).Ydata;
    end
    ind_start = S(index).ind_start;
    ind_end = S(index).ind_end;
    %m1 = mean(Ydata,2,'omitnan');
    %m_binned = m1'*T;
    
    m2 = NaN(size(ind_end));
    s2 = NaN(size(ind_end));
    lag = 100;
    % Reference time
    ind_ref = ind_end;
    for j=1:size(Ydata,1)
        m2(j) = mean(Ydata(j,ind_ref(j)-lag:ind_ref(j)+lag),'omitnan');
        s2(j) = std(Ydata(j,ind_ref(j)-lag:ind_ref(j)+lag),[],'omitnan');
        %m2(j) = mean(Ydata(j,ind_start(j)-lag:ind_ref(j)+lag),'omitnan');
        %s2(j) = std(Ydata(j,ind_start(j)-lag:ind_ref(j)+lag),[],'omitnan');
    end
    %sem2 = s2/sqrt(1);
    m2(isnan(m2))=0;
    m_binned = m2'*T;
    str_fig = 'FullRun';
    
    % Alternative
    index_binned_NaN = index_binned;
    index_binned_NaN(index_binned_NaN==0)=NaN;
    M2 = index_binned_NaN.*(repmat(m2,[1,size(T,2)]));
    M_binned = mean(M2,'omitnan');
    S_binned = std(M2,[],'omitnan');
    div = sum(~isnan(M2));
    div(div==0)=1;
    SEM_binned = S_binned./div;
    
%     % Bar diagram
%     b = bar(M_binned,'FaceColor',f_colors(index,:),...
%         'EdgeColor','none','Parent',ax);
%     title(ax,labels_gathered(index));
%     hold(ax,'on');
%     e = errorbar(M_binned,SEM_binned,'k',...
%         'linewidth',.5,'linestyle','none',...
%         'Parent',ax,'Tag','ErrorBar');
%     e.CapSize = 2;
% %     % Removing bar edges
% %     for i =1:length(b)
% %         b(i).EdgeColor='k';
% %         b(i).LineWidth= .1;
% %     end

    % Whisker plot
    % boxplot(M2,'Parent',ax,'Colors',f_colors(index,:),'PlotStyle','compact');
    b = boxplot(M2,'Parent',ax,'Colors',f_colors(index,:),'BoxStyle','filled',...
        'Symbol','k+','MedianStyle','target','OutlierSize',.1);
    title(ax,labels_gathered(index));
    %hold(ax,'on');
    
    % axes limits
    ax.FontSize = 8;
    ax.XTick = 0:10:60;
    ax.XTickLabel = {'0';'10';'20';'30';'40';'75';'60'};
    ax.XLim = [.5 30+.5];
    if flag_norm
        ax.YLim = [-1 3];
    else
        ax.YLim = [-20 30];
    end
     ax.TickLength = [0 0];
     grid(ax,'on');
     
     % Summary Statistics
     all_P_values = NaN(size(M2,2),1);
     for k=2:size(M2,2)
         X = M2(:,1);
         X = X(~isnan(X));
         Y = M2(:,k);
         Y = Y(~isnan(Y));
         if ~isempty(X) && ~isempty(Y)
             all_P_values(k) = ranksum(X,Y);
         end
     end
    % Plot Stats
    X_stats = (1:length(all_P_values));
    Y_stats = (ax.YLim(2)-(.05*(ax.YLim(2)-ax.YLim(1))))*(all_P_values<.05);
    Y_stats(Y_stats==0)=NaN;
    Y_stats2 = (ax.YLim(2)-(.03*(ax.YLim(2)-ax.YLim(1))))*(all_P_values<.01);
    Y_stats2(Y_stats2==0)=NaN;
    Y_stats3 = (ax.YLim(2)-(.01*(ax.YLim(2)-ax.YLim(1))))*(all_P_values<.001);
    Y_stats3(Y_stats3==0)=NaN;
    line('XData',X_stats,'YData',Y_stats,'Parent',ax,...
        'Marker','*','MarkerSize',5,'MarkerFaceColor','k','LineStyle','none');
    line('XData',X_stats,'YData',Y_stats2,'Parent',ax,...
        'Marker','*','MarkerSize',5,'MarkerFaceColor','k','LineStyle','none');
    line('XData',X_stats,'YData',Y_stats3,'Parent',ax,...
        'Marker','*','MarkerSize',5,'MarkerFaceColor','k','LineStyle','none');
    
    % Linear Fit
    x = 1:length(M_binned);
    y = M_binned;
    y = y(x<ax.XLim(2));
    x = x(x<ax.XLim(2));
    n = 1;
    P = polyfit(x,y,n);
    all_P = [all_P;P];
    switch n
        case 1
            l = line('XData',x,'YData',P(end)+P(end-1)*x,'Color','r',...%f_colors(index,:),...
                'Linewidth',.75,'Linestyle','-','Parent',ax);
        case 2
            l = line('XData',x,'YData',P(end)+P(end-1)*x+P(end-2)*x.^2,'Color','r',...%f_colors(index,:),...
                'Linewidth',.75,'Linestyle','-','Parent',ax);
    end
    
    % quadratic Error
    t = min(length(x),ax.XLim(2));
    E = mean((l.YData(1:t)-M_binned(1:t)).^2,'omitnan');
    all_E = [all_E;E];
    text(.7*ax.XLim(2),.9*ax.YLim(2),sprintf('err = %.1f',E),...
        'FontSize',9,'Parent',ax,'Color','r');
    text(.7*ax.XLim(2),.8*ax.YLim(2),sprintf('b = %.2f',10*P(end-1)),...
        'FontSize',9,'Parent',ax,'Color','r');
end

if flag_save
    f.Units = 'pixels';
    f.Position = [195          59        1045         919];
%    saveas(f,fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s%s%s',f.Name,str_fig,'.pdf')));
%    fprintf('Figure Saved [%s].\n',fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s%s',f.Name,'.pdf')));
    saveas(f,sprintf('%s%s%s',f.Name,str_fig,'.pdf'));
    fprintf('Figure Saved [%s].\n',sprintf('%s%s',f.Name,'.pdf'));
end

% % 2nd figure
% figure();
% ax1 = subplot(311);
% bdat = all_P(:,1);
% b = bar(1:length(bdat),diag(bdat),'stacked','Parent',ax1);
% for k=1:length(bdat)
%     %b(k).FaceColor = char(GDisp.colors(k));
%     b(k).FaceColor = f_colors(k,:);
% end
% ax1.XTick = 1:length(bdat);
% ax1.XTickLabel = labels_gathered;
% ax1.XTickLabelRotation = 45;
% ax1.TickLength=[0 0];
% ax1.XLim = [.5 length(bdat)+.5];
% ax1.YLim = [min(bdat)-.1 max(bdat)+.1];
% 
% ax2 = subplot(312);
% bdat = all_P(:,2);
% b = bar(1:length(bdat),diag(bdat),'stacked','Parent',ax2);
% for k=1:length(bdat)
%     %b(k).FaceColor = char(GDisp.colors(k));
%     b(k).FaceColor = f_colors(k,:);
% end
% ax2.XTick = 1:length(bdat);
% ax2.XTickLabel = labels_gathered;
% ax2.XTickLabelRotation = 45;
% ax2.TickLength=[0 0];
% ax2.XLim = [.5 length(bdat)+.5];
% ax2.YLim = [min(bdat)-.1 max(bdat)+.1];
% 
% ax3 = subplot(313);
% bdat = all_E(:,1);
% b = bar(1:length(bdat),diag(bdat),'stacked','Parent',ax3);
% for k=1:length(bdat)
%     %b(k).FaceColor = char(GDisp.colors(k));
%     b(k).FaceColor = f_colors(k,:);
% end
% ax3.XTick = 1:length(bdat);
% ax3.XTickLabel = labels_gathered;
% ax3.XTickLabelRotation = 45;
% ax3.TickLength=[0 0];
% ax3.XLim = [.5 length(bdat)+.5];
% ax3.YLim = [min(bdat)-.1 max(bdat)+.1];

% 3rd figure
f = figure();
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
ax1 = axes('parent',f);
m_size = all_E/max(all_E);
line('XData',[0 0],'YData',[-10 10],'Parent',ax1,...
    'linewidth',.5,'Color','k');
line('YData',[0 0],'XData',[-10 10],'Parent',ax1,...
    'linewidth',.5,'Color','k');
for k=1:size(all_P,1)
    l = line('XData',all_P(k,1),'YData',all_P(k,2),'Parent',ax1,...
        'MarkerFaceColor',[.5 .5 .5],'Marker','o','MarkerSize',10*(1+m_size(k)),...
        'MarkerEdgeColor','none');
    l = line('XData',all_P(k,1),'YData',all_P(k,2),'Parent',ax1,...
        'MarkerFaceColor',f_colors(k,:),'Marker','o','MarkerSize',10,...
        'MarkerEdgeColor','none');
    text(all_P(k,1)+.01,all_P(k,2),sprintf('%s',char(labels_gathered(k))),...
        'FontSize',9,'Parent',ax1,'Color','k');
end
ax1.Title.String = cur_list;
ax1.XLabel.String = 'Potentiation Strength';
ax1.YLabel.String = 'Potentiation Offset';
ax1.XLim = [min(all_P(:,1))-.01 max(all_P(:,1))+.01];
ax1.YLim = [min(all_P(:,2))-.5 max(all_P(:,2))+.5];

% 4th figure
% Drawing results
f = figure;
f.Name = sprintf('Fig5_Synthesisc_%s-%s',cur_list,timegroup);
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
colormap(f,'parula');
f_colors = f.Colormap(round(1:64/length(S):64),:);
g_colors = repmat(get(groot,'DefaultAxesColorOrder'),[10,1]);

panel1 = uipanel('FontSize',10,...
    'Units','normalized',...
    'Title','Potentiation Strength',...
    'Tag','Panel1',...
    'Position',[0 .5 1 .5],...
    'Parent',f);
panel2 = uipanel('FontSize',10,...
    'Units','normalized',...
    'Title','Potentiation Offset',...
    'Tag','Panel1',...
    'Position',[0 0 1 .5],...
    'Parent',f);

% Sixth tab
all_axes1 = [];
all_axes2 = [];
margin_w=.02;
margin_h=.02;
n_columns = 4;
n_rows = ceil(length(list_regions)/n_columns);
all_P = [];
all_E = [];
    
% Creating axes
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>length(list_regions)
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        % Panel1
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax = axes('Parent',panel1);
        ax.Position= [x+margin_w y+margin_h (1/n_columns)-2*margin_w (1/n_rows)-3*margin_h];
        ax.XAxisLocation ='origin';
        %ax.Title.String = sprintf('Ax-%02d',index);
        ax.Title.Visible = 'on';
        all_axes1 = [all_axes1;ax];
        % Panel2
        ax = axes('Parent',panel2);
        ax.Position= [x+margin_w y+margin_h (1/n_columns)-2*margin_w (1/n_rows)-3*margin_h];
        ax.XAxisLocation ='origin';
        %ax.Title.String = sprintf('Ax-%02d',index);
        ax.Title.Visible = 'on';
        all_axes2 = [all_axes2;ax];
    end
end

% Filling axes
for i = 1:length(all_axes1)
    ax1 = all_axes1(i);
    ax2 = all_axes2(i);
    
    % finding rats
    all_rats = unique(R(i).rat_name);
    all_lines1 = [];
    all_lines2 = [];
    counter = 0;
    for j=1:length(all_rats)
        cur_rat = all_rats(j);
        ind_keep = find(strcmp(R(i).rat_name,cur_rat)==1);
        if length(ind_keep)>=3
            counter = counter+1;
            % Panel1
            y = R(i).p_strength(ind_keep);
            x = (1:length(y))';       
            l = line('XData',x,'YData',y,'Parent',ax1,...
                'Color',g_colors(counter,:),'Tag',char(cur_rat),...
                'LineStyle','-','LineWidth',.5,...
                'Marker','o','MarkerSize',3,...
                'MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor','none');
            hold on;
            all_lines1 = [all_lines1;l];
            % Panel2
            y = R(i).p_offset(ind_keep);
            x = (1:length(y))';       
            l = line('XData',x,'YData',y,'Parent',ax2,...
                'Color',g_colors(counter,:),'Tag',char(cur_rat),...
                'LineStyle','-','LineWidth',.5,...
                'Marker','o','MarkerSize',3,...
                'MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor','none');
            hold on;
            all_lines2 = [all_lines2;l];
        else
            continue;
        end
        
    end
    % Ax limits
    ax1.Title.String = R(i).region;
    ax2.Title.String = R(i).region;
    
end

% legend
index_leg = 2;
leg1 = legend(all_axes1(index_leg),{all_lines1(:).Tag}');
leg2 = legend(all_axes2(index_leg),{all_lines2(:).Tag}');
leg1.Position(1)= leg1.Position(3)+leg1.Position(1)+3*margin_w;
leg2.Position(1)= leg2.Position(3)+leg2.Position(1)+3*margin_w;

end
