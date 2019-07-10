% Article RUN
% Figure 8
% to run after batch Peri-Event Time Histogram 
% Display (and save figure) polar plots for all brain regions
% Sorts all trials relative to the time of first trial 

function script_Figure8(cur_list,timegroup)

[S,list_regions,list_lfp] = compute_script_Figure8(cur_list,timegroup);
plot1_Figure8(S,list_regions,list_lfp,cur_list,timegroup);

end

function [S,list_regions,list_lfp] = compute_script_Figure8(cur_list,timegroup)

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
%list_coronal = {'20150224_175307_E';'20150225_154031_E';'20150226_173600_E';'20150716_130039_E';'20160622_191334_E'};
list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';'20150225_154031_E'};
list_diagonal = {'20150227_134434_E';'20150304_150247_E';'20150305_190451_E';'20150306_162342_E';...
    '20150718_135026_E';'20150722_121257_E';'20150723_123927_E';'20150724_131647_E';...
    '20150725_130514_E';'20150725_160417_E';'20150727_114851_E';'20151127_120039_E'};%;...
%     '20151128_133929_E';'20151204_135022_E';'20160622_122940_E';'20160623_163228_E';...
%     '20160623_193007_E';'20160624_171440_E';'20160625_113928_E';'20160625_163710_E';...
%     '20160630_114317_E';'20160701_130444_E'};

% list of references to search (in order)
% list_ref = {'SPEED';'ACCEL'};
% list_ref = {'heta'};
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
    
list_lfp = [{'ACCEL-POWER[61-extra]'};...
    {'ACCEL-POWER[62-extra]'};...
    {'ACCEL-POWER[63-extra]'};...
    {'SPEED'};...
    {'Power-delta/'};...
    {'Power-theta/'};...
    {'Power-gammalow/'};...
    {'Power-gammamid/'};...
    {'Power-gammamidup/'};...
    {'Power-gammahigh/'};...
    {'Power-gammahighup/'};...
    {'Power-ripple/'}];

% Buidling struct S
% All_trials
S = struct('R',[],'R_data1',[],'R_data2',[],'R_data1_scaled',[],'R_data2_scaled',[],...
    'R_data_file',[],'R_data_str_ref',[],'R_data_rat_name',[],'R_data_rat_id',[],...
    'index_ref',[],'corr_type',[],'file',[],'str_ref',[],'rat_name',[],'rat_id',[]);
S(length(list_lfp),length(list_regions)).R = [];


% % Average per recording
% R = struct('ref_time',[],'m',[],'s',[],'ind_start',[],'ind_end',[],'labels','','str_popup','');
% R(length(list_regions)).Ydata = [];

for index = 1:length(D)
    
    cur_file = D(index).file;
    str_ref = D(index).str_ref;
    timegroup = D(index).timegroup;
    fullpath = fullfile(folder,cur_file,timegroup);
    rat_name = D(index).rat_name;
    rat_id = D(index).rat_id;
    
    % Loading rmax, tmax
    data_fus = load(fullfile(fullpath,'PeaktoPeak.mat'));
    %label_fus = data_fus.label_fus;
    %label_lfp = data_fus.label_lfp;
    
    for i=1:length(list_lfp)
        lfp_name = strrep(char(list_lfp(i)),'.mat','');
        %ind_keep = find(strcmp(data_fus.label_lfp,lfp_name)==1);
        ind_lfp = find(contains(data_fus.label_lfp,lfp_name)==1);
        
        % Selecting ind_lfp
        if isempty(ind_lfp)
            continue;
        elseif length(ind_lfp)>1
            ind_lfp = ind_lfp(1);data
            warning('Multiple pattern matches [Pattern: %s /File: %s /Selected: %s]',lfp_name,cur_file,data_fus.label_lfp(ind_lfp));
        end
            
        for j=1:length(list_regions)
            region_name = strrep(char(list_regions(j)),'.mat','');
            ind_reg = find(strcmp(data_fus.label_fus,region_name)==1);
            
            % Selecting ind_reg
            if isempty(ind_reg)
                continue;
            elseif length(ind_reg)>1
                ind_reg = ind_reg(1);
                warning('Multiple pattern matches [Pattern: %s /File: %s /Selected: %s]',region_name,cur_file,data_fus.label_fus(ind_reg));
            end
            
            % Filling Data            
            S(i,j).R = [S(i,j).R;data_fus.C_XY(ind_reg,ind_lfp)];
            S(i,j).index_ref = [S(i,j).index_ref;data_fus.index_ref];
            S(i,j).corr_type = [S(i,j).corr_type;data_fus.corr_type];
            S(i,j).file = [S(i,j).file;{cur_file}];
            S(i,j).str_ref = [S(i,j).str_ref;{str_ref}];
            S(i,j).rat_name = [S(i,j).rat_name;{rat_name}];
            S(i,j).rat_id = [S(i,j).rat_id;{rat_id}];
            % all_events
            S(i,j).R_data1 = [S(i,j).R_data1;data_fus.S_pp(ind_reg,ind_lfp).R_data1];
            S(i,j).R_data2 = [S(i,j).R_data2;data_fus.S_pp(ind_reg,ind_lfp).R_data2];
            S(i,j).R_data1_scaled = [S(i,j).R_data1_scaled;data_fus.S_pp(ind_reg,ind_lfp).R_data1_scaled];
            S(i,j).R_data2_scaled = [S(i,j).R_data2_scaled;data_fus.S_pp(ind_reg,ind_lfp).R_data2_scaled];
            N = length(data_fus.S_pp(ind_reg,ind_lfp).R_data1);
            S(i,j).R_data_file = [S(i,j).R_data_file; cellstr(repmat(cur_file,[N,1]))];
            S(i,j).R_data_str_ref = [S(i,j).R_data_str_ref; cellstr(repmat(str_ref,[N,1]))];
            S(i,j).R_data_rat_name = [S(i,j).R_data_rat_name; cellstr(repmat(rat_name,[N,1]))];
            S(i,j).R_data_rat_id = [S(i,j).R_data_rat_id; cellstr(repmat(rat_id,[N,1]))];
        end
    end
    
end

end

function plot1_Figure8(S,list_regions,list_lfp,cur_list,timegroup)

% Drawing results
f = figure;
f.Name = sprintf('Fig8_SynthesisA_%s-%s',cur_list,timegroup);
colormap(f,'parula');
f_colors = f.Colormap(round(1:64/length(S):64),:);
list_regions=regexprep(list_regions,'.mat','');

% Sixth tab
all_axes = [];
margin_w = .02;
margin_h =.02;
n_columns = 4;
n_rows = ceil(length(list_lfp)/n_columns);
all_P = [];
all_E = [];
    
% Creating axes
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>length(list_lfp)
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
    %m1 = mean(Ydata,2,'omitnan');
    %m_binned = m1'*T;
    
    m2 = NaN(size(ind_end));
    s2 = NaN(size(ind_end));
    lag = 100;
    % Reference time
    ind_ref = ind_end;
    for j=1:size(Ydata,1)
        m2(j) = mean(Ydata(j,ind_start(j)-lag:ind_ref(j)+lag),'omitnan');
        s2(j) = std(Ydata(j,ind_start(j)-lag:ind_ref(j)+lag),[],'omitnan');
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
    
    b = bar(M_binned,'FaceColor',f_colors(index,:),...
        'EdgeColor','none','Parent',ax);
    title(ax,list_regions(index));
    hold(ax,'on');
    e = errorbar(M_binned,SEM_binned,'k',...
        'linewidth',.5,'linestyle','none',...
        'Parent',ax,'Tag','ErrorBar');
    e.CapSize = 2;
%     % Removing bar edges
%     for i =1:length(b)
%         b(i).EdgeColor='k';
%         b(i).LineWidth= .1;
%     end
    
    % axes limits
    ax.FontSize = 8;
    ax.XTick = 0:10:60;
    ax.XTickLabel = {'0';'10';'20';'30';'40';'50';'60'};
    ax.XLim = [.5 30+.5];
    ax.YLim = [-2 15];
	 ax.TickLength = [0 0];
    
    % Linear Fit
    x = b.XData(~isnan(b.YData));
    y = b.YData(~isnan(b.YData));
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
    E = mean((l.YData(1:t)-b.YData(1:t)).^2,'omitnan');
    all_E = [all_E;E];
    text(.7*ax.XLim(2),.9*ax.YLim(2),sprintf('err = %.1f',E),...
        'FontSize',9,'Parent',ax,'Color','r');
    text(.7*ax.XLim(2),.8*ax.YLim(2),sprintf('b = %.2f',10*P(end-1)),...
        'FontSize',9,'Parent',ax,'Color','r');
end

f.Units = 'pixels';
f.Position = [195          59        1045         919];
saveas(f,fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s%s%s',f.Name,str_fig,'.pdf')));
fprintf('Figure Saved [%s].\n',fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s%s',f.Name,'.pdf')));

end
