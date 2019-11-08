% Article RUN
% Figure 5
% to run after batch Peri-Event Time Histogram 
% Display (and save figure) all trials for all brain regions

function script_Figure5(cur_list,timegroup,gather_regions)

if nargin <3
    gather_regions = false;
end

flag_grouped = false;
flag_save = true;

[D,Q,R,S,list_regions,list_lfp] = compute_script_Figure5(cur_list,timegroup,flag_grouped);
plot1_Figure5(S,list_regions,cur_list,timegroup,gather_regions,flag_save);
plot2_Figure5(Q,list_lfp,cur_list,timegroup,flag_save);

end

function [D,Q,R,S,list_regions,list_lfp] = compute_script_Figure5(cur_list,timegroup,flag_grouped)

close all;
global DIR_STATS;

folder = fullfile(DIR_STATS,'fUS_PeriEventHistogram');
all_files = dir(fullfile(folder,'*_E'));
index =0;

list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';...
    '20150225_154031_E';'20150226_173600_E';'20150619_132607_E';'20150620_175137_E';...
    '20150714_191128_E';'20150715_181141_E';'20150716_130039_E';'20150717_133756_E';...
    '20150724_170457_E';'20150726_152241_E';'20150728_134238_E';
    '20151126_170516_E';'20151202_141449_E';...%'20151203_113703_E';%'20151201_144024_E';
    '20160622_191334_E';'20160623_123336_E';...%'20160624_120239_E';...
    '20160628_171324_E';'20160629_134749_E';'20160629_191304_E'};

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

% list_lfp
list_lfp = {'SPEED';'ACCEL-POWER[61-extra]';'ACCEL-POWER[62-extra]';'ACCEL-POWER[63-extra]';...
    'Power-theta/';'Power-gammalow/';'Power-gammamid/';'Power-gammahigh/'};

% list_regions
if strcmp(cur_list,'CORONAL')
    if ~flag_grouped
        list_regions = {'AC-L.mat';'AC-R.mat';'S1BF-L.mat';'S1BF-R.mat';'LPtA-L.mat';'LPtA-R.mat';'RS-L.mat';'RS-R.mat';...
            'DG-L.mat';'DG-R.mat';'CA1-L.mat';'CA1-R.mat';'CA2-L.mat';'CA2-R.mat';'CA3-L.mat';'CA3-R.mat';...
            'dThal-L.mat';'dThal-R.mat';'Po-L.mat';'Po-R.mat';'VPM-L.mat';'VPM-R.mat';...
            'HypothalRg-L.mat';'HypothalRg-R.mat'};
        % adding large regions
        list_regions = {'Neocortex-L.mat';'Neocortex-R.mat';'dHpc-L.mat';'dHpc-R.mat';'Thalamus-L.mat';'Thalamus-R.mat';'HypothalRg-L.mat';'HypothalRg-R.mat'};
    else
        list_regions = {'AC.mat';'S1BF.mat';'LPtA.mat';'RS.mat';...
            'DG.mat';'CA1.mat';'CA2.mat';'CA3.mat';...
            'dThal.mat';'Po.mat';'VPM.mat';'Thalamus.mat';...
            'HypothalRg.mat';'Whole.mat'};
        % adding large regions
        list_regions =    {'Neocortex.mat';'dHpc.mat';'Thalamus.mat';'HypothalRg.mat';'Whole.mat'};
    end
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
elseif  strcmp(cur_list,'DIAGONAL')
    if ~flag_grouped
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
else
    if ~flag_grouped
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
S = struct('Ydata',[],'Xdata',[],'ind_end',[],'ind_start',[],'label_events','','region','',...
    't_start',[],'t_end',[],'file','','str_ref','','rat_name','','rat_id','');
S(length(list_regions)).Ydata = [];

% Buidling struct Q
% All_trials
Q = struct('Ydata',[],'Xdata',[],'ind_end',[],'ind_start',[],'label_events','','channel','',...
    't_start',[],'t_end',[],'file','','str_ref','','rat_name','','rat_id','');
Q(length(list_lfp)).Ydata = [];

% Average per recording
list_average = [list_regions;list_lfp];
R = struct('ref_time',[],'m',[],'s',[],'ind_start',[],'ind_end',[],'channel','','str_popup','');
R(length(list_average)).ref_time = [];

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
    data_lfp = load(fullfile(fullpath,'LFP_Data.mat'));
    
    % Collecting fUS data
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
            S(i).rat_name = [S(i).rat_name;{D(index).rat_name};repmat({''},[size(Ydata_temp,1)-1,1])];
            S(i).rat_id = [S(i).rat_id;{D(index).rat_id};repmat({''},[size(Ydata_temp,1)-1,1])];
            S(i).file = [S(i).file;{cur_file};repmat({''},[size(Ydata_temp,1)-1,1])];
            S(i).str_ref =[S(i).str_ref;{D(index).str_ref};repmat({''},[size(Ydata_temp,1)-1,1])];
        end
    end
    
    % Collecting LFP data
    for i=1:length(list_lfp)  
        channel_name = strrep(char(list_lfp(i)),'.mat','');
        % ind_keep = find(strcmp(data_lfp.LFP_Selection(:,1),channel_name)==1);
        ind_keep = find(contains(data_lfp.LFP_Selection(:,1),channel_name)==1);
        if length(ind_keep)>1
            ind_keep = ind_keep(1);
        end
        
        if ~isempty(ind_keep)        
            Ydata_temp = cat(2,data_lfp.Ydata(:,:,ind_keep),NaN(size(data_lfp.Ydata,1),lmax-size(data_lfp.Ydata,2)));
            % rescaling
            Ydata_temp = rescale(Ydata_temp,0,100);
            Q(i).Ydata = [Q(i).Ydata;Ydata_temp];
            Xdata_temp = cat(2,data_lfp.ref_time,NaN(1,lmax-length(data_lfp.ref_time)));
            Xdata_temp = repmat(Xdata_temp,[size(Ydata_temp,1),1]);
            Q(i).Xdata = [Q(i).Xdata;Xdata_temp];
            Q(i).label_events = [Q(i).label_events;data_lfp.label_events];
            Q(i).t_start = [Q(i).t_start;data_lfp.Time_indices(:,2)-data_lfp.Time_indices(1,1)];
            Q(i).t_end = [Q(i).t_end;data_lfp.Time_indices(:,3)-data_lfp.Time_indices(1,1)];
            
            Q(i).channel = channel_name;
            Q(i).ind_start = [Q(i).ind_start;data_lfp.ind_start];
            Q(i).ind_end = [Q(i).ind_end;data_lfp.ind_end];
            
%             Q(i).rat_name = [Q(i).rat_name;repmat({D(index).rat_name},[size(Ydata_temp,1),1])];
%             Q(i).rat_id = [Q(i).rat_id;repmat({D(index).rat_id},[size(Ydata_temp,1),1])];
%             Q(i).file = [Q(i).file;repmat({cur_file},[size(Ydata_temp,1),1])];
%             Q(i).str_ref =[Q(i).str_ref;repmat({D(index).str_ref},[size(Ydata_temp,1),1])];      
            Q(i).rat_name = [Q(i).rat_name;{D(index).rat_name};repmat({''},[size(Ydata_temp,1)-1,1])];
            Q(i).rat_id = [Q(i).rat_id;{D(index).rat_id};repmat({''},[size(Ydata_temp,1)-1,1])];
            Q(i).file = [Q(i).file;{cur_file};repmat({''},[size(Ydata_temp,1)-1,1])];
            Q(i).str_ref =[Q(i).str_ref;{D(index).str_ref};repmat({''},[size(Ydata_temp,1)-1,1])];
        end
    end
    
    % Collecting average data
    data_ar = load(fullfile(fullpath,'AverageResponse.mat'));
    for i=1:length(list_average)
        
        channel_name = strrep(char(list_average(i)),'.mat','');
        ind_keep = find(contains(data_ar.labels,channel_name)==1);
        if length(ind_keep)>1
            ind_keep = ind_keep(1);
        end
        if ~isempty(ind_keep)
            R(i).ind_start = [R(i).ind_start;mean(data_ar.ind_start)];
            R(i).ind_end = [R(i).ind_end;mean(data_ar.ind_end)];
            R(i).channel = channel_name;
            R(i).str_popup = [R(i).str_popup;{data_ar.str_popup}];
            
            R(i).ref_time = [R(i).ref_time;[data_ar.ref_time,NaN(1,lmax-length(data_ar.ref_time))]];
            R(i).m = [R(i).m;[data_ar.m(:,:,i),NaN(1,lmax-length(data_ar.ref_time))]];
            R(i).s = [R(i).s;[data_ar.s(:,:,i),NaN(1,lmax-length(data_ar.ref_time))]];
        end
    end
end
end

function plot1_Figure5(S,list_regions,cur_list,timegroup,gather_regions,flag_save)

% Drawing results
f = figure;
clrmenu(f);
%f.Name = sprintf('Synthesis Hemodynamics Response all_trials [%s | %s]',cur_list,timegroup);
f.Name = sprintf('Fig2_SynthesisB_%s-%s',cur_list,timegroup);
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
colormap(f,'parula');
f_colors = f.Colormap(round(1:64/length(S):64),:);

% Sixth tab
all_axes = [];
all_axes2 = [];
margin_w=.02;
margin_h=.02;
n_columns = 8;
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
        ax.Position = [x+margin_w y+2*margin_h (1/n_columns)-2*margin_w (1/n_rows)-6*margin_h];
        ax.XAxisLocation ='origin';
        %ax.Title.String = sprintf('Ax-%02d',index);
        ax.Title.Visible = 'on';
        all_axes = [all_axes;ax];
        %ax2
        ax2 = axes('Parent',f);
        ax2.Position = [ax.Position(1) ax.Position(2)+ax.Position(4)+0*margin_h ax.Position(3) 3*margin_h];
        %ax2.Title.String = sprintf('Ax-%02d',index);
        ax2.Title.Visible = 'on';
        all_axes2 = [all_axes2;ax2];
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
            ax.Position= [x+margin_w y+3*margin_h (1/n_columns)-2*margin_w (1/n_rows)-4*margin_h];       
        end
    end
    all_axes = all_axes(ic);
else
    labels_gathered = list_regions;
end
labels_gathered=regexprep(labels_gathered,'.mat','');

% Plotting
for index = 1:length(S)
    
    ax = all_axes(index);
    ax2 = all_axes2(index);
    linkaxes([ax,ax2],'x');
    if isempty(S(index).region)
        continue;
    end
    
    % Main line
    ref_time = mean(S(index).Xdata,1,'omitnan');
    Ydata = S(index).Ydata;
    ind_start = S(index).ind_start;
    ind_end = S(index).ind_end;
    imagesc(Ydata,'Parent',ax);
    %title(ax,labels_gathered(index));
    ax.FontSize = 8;
    %grid(ax,'on');
    
    % ticks on graph
    line('XData',ind_start,'YData',1:length(ind_start),...
        'Color','w','LineWidth',.1,'Linestyle','none',...
        'Marker','.','MarkerSize',1,'MarkerFaceColor','w',...
        'MarkerEdgeColor','w','Parent',ax);
    line('XData',ind_end,'YData',1:length(ind_end),...
        'Color','w','LineWidth',.1,'Linestyle','none',...
        'Marker','.','MarkerSize',1,'MarkerFaceColor','w',...
        'MarkerEdgeColor','w','Parent',ax);
    
    % recording line
    ind_new = find(~strcmp(S(index).rat_id,'')==1);
    for j=1:length(ind_new)
        line('XData',[ax.XLim(1)-1000 ax.XLim(2)+1000],'YData',[ind_new(j) ind_new(j)]-.5,...
        'Color','w','LineWidth',.2,'Linestyle','-',...
        'Marker','none','MarkerSize',1,'MarkerFaceColor','w',...
        'MarkerEdgeColor','w','Parent',ax);
    end
    
    % potentiation line
    % Reference time
    ind_ref = ind_end;
    lag = 500;
    %m_dat = mean(Ydata,2,'omitnan');
    m_dat = [];
    for ii=1:size(Ydata,1)
        m_dat = [m_dat;mean(Ydata(ii,ind_ref(ii)-lag:ind_ref(ii)+lag),'omitnan')];
    end
    l = line('XData',ind_start/2+50*m_dat,'YData',1:length(ind_start),...
        'Color','r','LineWidth',.1,'Linestyle','-',...
        'Marker','none','MarkerSize',1,'MarkerFaceColor','r',...
        'MarkerEdgeColor','w','Parent',ax);
    %l.XData = S(index).t_start;
    
    % axes limits
    ax.YTick = 1:length(S(index).rat_id);
    ax.YTickLabel = S(index).rat_id;
    ax.TickLength = [0 0];
    
    % XTick
    ind_keep = find(sum(~isnan(S(index).Xdata))/size(S(index).Xdata,1)>.5);
    ax.XTick = ind_keep(1):500:ind_keep(end);
    str_label = [];
    for i =1:length(ax.XTick)
        str_label = [str_label;{ref_time(ax.XTick(i))}];
    end
    ax.XTickLabel = str_label;
    ax.XLim = [ind_keep(1),ind_keep(end)];
    ax.CLim = [-5;20];
    
    % colorbar
    c = colorbar(ax,'northoutside');
    c.Position = [ax.Position(1) ax.Position(2)-1.5*margin_h ax.Position(3) margin_h/2];
    c.Box = 'off';
    c.TickLength = [0 0];
    c.FontSize = 5;
    
    % display average
    m = mean(Ydata,'omitnan');
    s = std(Ydata,[],'omitnan');
    modifier = sqrt(sum(~isnan(Ydata)));
    modifier(modifier==0)=1;
    sem = s./modifier;
    % draw mean
    linestyle='-';
    marker = 'none';
    patch_alpha = .5;
    xdat = 1:length(ref_time);
    line('XData',xdat,'YData',m,'Tag',char(list_regions(index)),...
        'Color',f_colors(index,:),'LineWidth',1,'Linestyle',linestyle,...
        'Marker',marker','MarkerSize',3,'MarkerFaceColor','none',...
        'MarkerEdgeColor',f_colors(index,:),'Parent',ax2)
    %Patch
    p_xdat = [xdat,fliplr(xdat)];
    p_ydat = [m-sem,fliplr(m+sem)];
    %p_ydat = [m-s,fliplr(m+s)];
    patch('XData',p_xdat(~isnan(p_ydat)),'YData',p_ydat(~isnan(p_ydat)),...
        'FaceColor',f_colors(index,:),'FaceAlpha',patch_alpha,'EdgeColor','none',...
        'LineWidth',.25,'Parent',ax2);
    
    title(ax2,sprintf('%s [n=%d]',char(labels_gathered(index)),size(S(index).Xdata,1)));
    ax2.FontSize = 8;
    ax2.YLim = [-2;10];
    ax2.XTickLabel = '';
    ax2.TickLength = [0 0];
    grid(ax2,'on');
end

f.Units = 'pixels';
f.Position = [195          59        1045         919];

global DIR_STATS;
if flag_save
    folder = fullfile(DIR_STATS,'fUS_PeriEventHistogram');
    fullname = fullfile(folder,sprintf('%s%s',f.Name,'.pdf'));
    saveas(f,fullname);
    fprintf('Figure Saved [%s].\n',fullname);
end

end

function plot2_Figure5(Q,list_lfp,cur_list,timegroup,flag_save)

% Drawing results
f = figure;
clrmenu(f);
%f.Name = sprintf('Synthesis Hemodynamics Response all_trials [%s | %s]',cur_list,timegroup);
f.Name = sprintf('Fig2_SynthesisC_%s-%s',cur_list,timegroup);
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
colormap(f,'parula');
f_colors = f.Colormap(round(1:64/length(Q):64),:);

% Sixth tab
all_axes = [];
all_axes2 = [];
margin_w=.02;
margin_h=.02;
n_columns = 8;
n_rows = ceil(length(list_lfp)/n_columns);
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
        ax.Position = [x+margin_w y+2*margin_h (1/n_columns)-2*margin_w (1/n_rows)-6*margin_h];
        ax.XAxisLocation ='origin';
        %ax.Title.String = sprintf('Ax-%02d',index);
        ax.Title.Visible = 'on';
        all_axes = [all_axes;ax];
        %ax2
        ax2 = axes('Parent',f);
        ax2.Position = [ax.Position(1) ax.Position(2)+ax.Position(4)+0*margin_h ax.Position(3) 3*margin_h];
        %ax2.Title.String = sprintf('Ax-%02d',index);
        ax2.Title.Visible = 'on';
        all_axes2 = [all_axes2;ax2];
    end
end

% labels_gathered
labels_gathered = list_lfp;
labels_gathered=regexprep(labels_gathered,'.mat','');

% Plotting
for index = 1:length(Q)
    
    ax = all_axes(index);
    ax2 = all_axes2(index);
    linkaxes([ax,ax2],'x');
    if isempty(Q(index).channel)
        continue
    end
    
    % Main line
    ref_time = mean(Q(index).Xdata,1,'omitnan');
    Ydata = Q(index).Ydata;
    ind_start = Q(index).ind_start;
    ind_end = Q(index).ind_end;
    imagesc(Ydata,'Parent',ax);
    %title(ax,labels_gathered(index));
    %grid(ax,'on');
    
    % ticks on graph
    line('XData',ind_start,'YData',1:length(ind_start),...
        'Color','w','LineWidth',.1,'Linestyle','none',...
        'Marker','.','MarkerSize',1,'MarkerFaceColor','w',...
        'MarkerEdgeColor','w','Parent',ax);
    line('XData',ind_end,'YData',1:length(ind_end),...
        'Color','w','LineWidth',.1,'Linestyle','none',...
        'Marker','.','MarkerSize',1,'MarkerFaceColor','w',...
        'MarkerEdgeColor','w','Parent',ax);
    
    % recording line
    ind_new = find(~strcmp(Q(index).rat_id,'')==1);
    for j=1:length(ind_new)
        line('XData',[ax.XLim(1)-1000 ax.XLim(2)+1000],'YData',[ind_new(j) ind_new(j)]-.5,...
        'Color','w','LineWidth',.2,'Linestyle','-',...
        'Marker','none','MarkerSize',1,'MarkerFaceColor','w',...
        'MarkerEdgeColor','w','Parent',ax);
    end
    
    % potentiation line
    % Reference time
    ind_ref = ind_end;
    lag = 500;
    %m_dat = mean(Ydata,2,'omitnan');
    m_dat = [];
    for ii=1:size(Ydata,1)
        m_dat = [m_dat;mean(Ydata(ii,ind_ref(ii)-lag:ind_ref(ii)+lag),'omitnan')];
    end
    line('XData',ind_start/2+30*m_dat,'YData',1:length(ind_start),...
        'Color','r','LineWidth',.1,'Linestyle','-',...
        'Marker','none','MarkerSize',1,'MarkerFaceColor','r',...
        'MarkerEdgeColor','w','Parent',ax);
    
    % axes limits
    ax.FontSize = 8;
    ax.TickLength = [0 0];
    ax.YTick = 1:length(Q(index).rat_id);
    ax.YTickLabel = Q(index).rat_id;
    
    ind_keep = find(sum(~isnan(Q(index).Xdata))/size(Q(index).Xdata,1)>.5);
    ax.XTick = ind_keep(1):500:ind_keep(end);
    str_label = [];
    for i =1:length(ax.XTick)
        str_label = [str_label;{ref_time(ax.XTick(i))}];
    end
    ax.XTickLabel = str_label;
    ax.XLim = [ind_keep(1),ind_keep(end)];
    
    %ax.CLim = [-5;20];
    % colorbar
    c = colorbar(ax,'northoutside');
    c.Position = [ax.Position(1) ax.Position(2)-1.5*margin_h ax.Position(3) margin_h/2];
    c.Box = 'off';
    c.TickLength = [0 0];
    c.FontSize = 5;
    
    % display average
    m = mean(Ydata,'omitnan');
    s = std(Ydata,[],'omitnan');
    modifier = sqrt(sum(~isnan(Ydata)));
    modifier(modifier==0)=1;
    sem = s./modifier;
    % draw mean
    linestyle='-';
    marker = 'none';
    patch_alpha = .5;
    xdat = 1:length(ref_time);
    line('XData',xdat,'YData',m,'Tag',char(list_lfp(index)),...
        'Color',f_colors(index,:),'LineWidth',1,'Linestyle',linestyle,...
        'Marker',marker','MarkerSize',3,'MarkerFaceColor','none',...
        'MarkerEdgeColor',f_colors(index,:),'Parent',ax2)
    %Patch
    p_xdat = [xdat,fliplr(xdat)];
    p_ydat = [m-sem,fliplr(m+sem)];
    %p_ydat = [m-s,fliplr(m+s)];
    patch('XData',p_xdat(~isnan(p_ydat)),'YData',p_ydat(~isnan(p_ydat)),...
        'FaceColor',f_colors(index,:),'FaceAlpha',patch_alpha,'EdgeColor','none',...
        'LineWidth',.25,'Parent',ax2);
    
    title(ax2,sprintf('%s [n=%d]',char(labels_gathered(index)),size(Q(index).Xdata,1)));
    ax2.FontSize = 8;
    %ax2.YLim = [-2;10];
    ax2.XTickLabel = '';
    ax2.TickLength = [0 0];
    grid(ax2,'on');
end

f.Units = 'pixels';
f.Position = [195          59        1045         919];

global DIR_STATS;
if flag_save
    folder = fullfile(DIR_STATS,'fUS_PeriEventHistogram');
    fullname = fullfile(folder,sprintf('%s%s',f.Name,'.pdf'));
    saveas(f,fullname);
    fprintf('Figure Saved [%s].\n',fullname);
end

end