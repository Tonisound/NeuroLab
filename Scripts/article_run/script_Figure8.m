% Article RUN
% Figure 8
% to run after batch Peri-Event Time Histogram 
% Display (and save figure) polar plots for all brain regions
% Sorts all trials relative to the time of first trial 

function script_Figure8(cur_list,timegroup)

flag_grouped = true;
flag_save = true;

[S,list_regions] = compute_script_Figure8(cur_list,timegroup,flag_grouped);
plot1_Figure8(S,list_regions,cur_list,timegroup,flag_save);

end

function [S,list_regions] = compute_script_Figure8(cur_list,timegroup,flag_grouped)

close all;
folder = 'I:\NEUROLAB\NLab_Statistics\fUS_PeriEventHistogram';
all_files = dir(fullfile(folder,'*_E'));
index = 0;

list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';...
    '20150225_154031_E';'20150226_173600_E';'20150619_132607_E';'20150620_175137_E';...
    '20150714_191128_E';'20150715_181141_E';'20150716_130039_E';'20150717_133756_E';...
    '20150724_170457_E';'20150726_152241_E';'20150728_134238_E';'20151126_170516_E';...
    '20151201_144024_E';'20151202_141449_E';'20151203_113703_E';'20160622_191334_E';...
    '20160623_123336_E';'20160624_120239_E';'20160628_171324_E';'20160629_134749_E';...
    '20160629_191304_E'};
%list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';'20150225_154031_E'};

list_diagonal = {'20150227_134434_E';'20150304_150247_E';'20150305_190451_E';'20150306_162342_E';...
    '20150718_135026_E';'20150722_121257_E';'20150723_123927_E';'20150724_131647_E';...
    '20150725_130514_E';'20150725_160417_E';'20150727_114851_E';'20151127_120039_E';...
    '20151128_133929_E';'20151204_135022_E';'20160622_122940_E';'20160623_163228_E';...
    '20160623_193007_E';'20160624_171440_E';'20160625_113928_E';'20160625_163710_E';...
    '20160630_114317_E';'20160701_130444_E'};

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
    if ~flag_grouped
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
S = struct('file',[],'region',[],'rat_name',[],'rat_id',[],'str_ref',[],'str_autocorr',[],'corr_type',[],...
    'align1',[],'align2',[],'xdata',[],'label_events',[],'C_FIRST',[],'C_LAST',[],...
    'R_data_file',[],'R_data_str_ref',[],'R_data_rat_name',[],'R_data_rat_id',[]);
S(length(list_regions)).file = [];

for index = 1:length(D)
    
    cur_file = D(index).file;
    str_ref = D(index).str_ref;
    timegroup = D(index).timegroup;
    fullpath = fullfile(folder,cur_file,timegroup);
    rat_name = D(index).rat_name;
    rat_id = D(index).rat_id;
    
    % Loading rmax, tmax
    data_fus = load(fullfile(fullpath,'AutoCorr.mat'));
    %label_fus = data_fus.label_fus;
    %label_lfp = data_fus.label_lfp;
    
    % test if data not too sparse
    thresh_events = 10;
    if length(data_fus.label_events)<thresh_events
        warning('Insufficient episode number (%d) [File: %s]',length(data_fus.label_events),cur_file);
        continue;
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
        S(j).region = region_name;
        S(j).align1 = [S(j).align1;data_fus.align1];
        S(j).align2 = [S(j).align2;data_fus.align2];
        S(j).corr_type = [S(j).corr_type;data_fus.corr_type];
        S(j).str_autocorr = [S(j).str_autocorr;data_fus.str_autocorr'];
        S(j).file = [S(j).file;{cur_file}];
        S(j).str_ref = [S(j).str_ref;{str_ref}];
        S(j).rat_name = [S(j).rat_name;{rat_name}];
        S(j).rat_id = [S(j).rat_id;{rat_id}];
        % all_events
        N = length(data_fus.label_events);
        S(j).xdata = [S(j).xdata; data_fus.xdata];
        S(j).label_events = [S(j).label_events; data_fus.xdata];
        S(j).C_FIRST = [S(j).C_FIRST; data_fus.C_FIRST(:,:,ind_reg)];
        S(j).C_LAST = [S(j).C_LAST; data_fus.C_LAST(:,:,ind_reg)];
        
        S(j).R_data_file = [S(j).R_data_file; cellstr(repmat(cur_file,[N,1]))];
        S(j).R_data_str_ref = [S(j).R_data_str_ref; cellstr(repmat(str_ref,[N,1]))];
        S(j).R_data_rat_name = [S(j).R_data_rat_name; cellstr(repmat(rat_name,[N,1]))];
        S(j).R_data_rat_id = [S(j).R_data_rat_id; cellstr(repmat(rat_id,[N,1]))];
        
    end
end

end

function plot1_Figure8(S,list_regions,cur_list,timegroup,flag_save)

% Drawing results
f = figure;
f.Name = sprintf('Fig8_SynthesisA_%s-%s',cur_list,timegroup);
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
colormap(f,'parula');
f_colors = f.Colormap(round(1:64/length(S):64),:);
list_regions=regexprep(list_regions,'.mat','');

% Sixth tab
all_axes = [];
margin_w = .02;
margin_h =.02;
n_columns = 4;
n_rows = ceil(length(list_regions)/n_columns);
all_P = [];
all_E = [];
pu1 = uicontrol('style','popup','String','Single|2 trials|3 trials',...
    'Units','normalized','Position',[.9 .01 .08 .03],...
    'Value',1,'Tag','Popup_AutoCorr1','Parent',f);
pu2 = uicontrol('style','popup','String','Raw|Best Fit',...
    'Units','normalized','Position',[.8 .01 .08 .03],...
    'Value',1,'Tag','Popup_AutoCorr2','Parent',f);
corr_type = S(1).corr_type(1,:);
pu2.Value = find(strcmp(cellstr(pu2.String),corr_type)==1);
pu2.Enable = 'off';
    
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
        ax.Title.String = S(index).region;
        % ax.Title.String = sprintf('Ax-%02d',index);
        ax.Title.Visible = 'on';
        all_axes = [all_axes;ax];
    end
end

% Callback attribution
pu1.Callback = {@update_axes,S,all_axes};
%Update axes
update_axes(pu1,[],S,all_axes);

if flag_save
    f.Units = 'pixels';
    f.Position = [195          59        1045         919];
    saveas(f,fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s_%s%s',f.Name,corr_type,'.pdf')));
    fprintf('Figure Saved [%s].\n',fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s_%s%s',f.Name,corr_type,'.pdf')));
end

end

function update_axes(hObj,~,S,all_axes)

hObj.Parent.Pointer = 'watch';
drawnow;

% Plotting
for index = 1:length(S)
    
    if isempty(S(index).region)
        continue;
    end
    
    % clean
    ax = all_axes(index);
    delete(ax.Children);
    
    % Building index_binned
    step_bin = 60;
    bins = 0:step_bin:1800;
    t_value = S(index).xdata;
    t_value_binned = repmat(t_value,[1 length(bins)]);
    %index_binned = true(size(t_value,1),length(bins));
    crit_inf = repmat(bins,[size(t_value,1),1]);
    crit_sup = repmat([bins(2:end),Inf],[size(t_value,1),1]);
    index_binned = (t_value_binned>=crit_inf).*(t_value_binned<crit_sup);
    % Matrix notation
    T = index_binned./repmat(sum(index_binned),[size(index_binned,1) 1]);
    T(isnan(T))=0;
    
    % Building M_binned
    val = hObj.Value;
    m2 = S(index).C_FIRST(:,val);
    m3 = S(index).C_LAST(:,val);
    %m2_binned = m2'*T;
    %m3_binned = m3'*T;
    % Alternative
    index_binned_NaN = index_binned;
    index_binned_NaN(index_binned_NaN==0)=NaN;
    M2 = index_binned_NaN.*(repmat(m2,[1,size(T,2)]));
    M2_binned = mean(M2,'omitnan');
    S2_binned = std(M2,[],'omitnan');
    div = sum(~isnan(M2));
    div(div==0)=1;
    SEM2_binned = S2_binned./sqrt(div);
    M3 = index_binned_NaN.*(repmat(m3,[1,size(T,2)]));
    M3_binned = mean(M3,'omitnan');
    S3_binned = std(M3,[],'omitnan');
    div = sum(~isnan(M3));
    div(div==0)=1;
    SEM3_binned = S3_binned./sqrt(div);
    
    % Plot corr line
    %bins_center = bins+.5*(bins(2)+bins(1));
    %bins_center1 = (1:length(bins))-.2;
    %bins_center2 = (1:length(bins))+.2;
    bins_center1 = bins+.4*(bins(2)+bins(1));
    bins_center2 = bins+.6*(bins(2)+bins(1));
    
    line('XData',bins_center1,'YData',M2_binned,'Parent',ax,...
        'Marker','o','MarkerSize',3,'MarkerFaceColor','b','MarkerEdgeColor','none',...
        'LineStyle','-','LineWidth',1,'Color','b','Tag','Corr_First');
    line('XData',bins_center2,'YData',M3_binned,'Parent',ax,...
        'Marker','o','MarkerSize',3,'MarkerFaceColor','r','MarkerEdgeColor','none',...
        'LineStyle','-','LineWidth',1,'Color','r','Tag','Corr_Last');
    
    % Plot corr errorbar
    marker_color1 = 'b';
    marker_color2 = 'r';
    marker_size = 3;
    for i =1:length(M2_binned)
        l1 = line('XData',[bins_center1(i),bins_center1(i)],'YData',[M2_binned(i)-SEM2_binned(i),M2_binned(i)+SEM2_binned(i)],'Parent',ax,...
            'Marker','.','MarkerSize',marker_size,'MarkerFaceColor','b','MarkerEdgeColor',marker_color1,...
            'LineStyle','-','LineWidth',.2,'Color','b','Tag','Corr_First_ebar');
        l2 = line('XData',[bins_center2(i),bins_center2(i)],'YData',[M3_binned(i)-SEM3_binned(i),M3_binned(i)+SEM3_binned(i)],'Parent',ax,...
            'Marker','.','MarkerSize',marker_size,'MarkerFaceColor','r','MarkerEdgeColor',marker_color2,...
            'LineStyle','-','LineWidth',.2,'Color','r','Tag','Corr_Last_ebar');
        %l1.YData = [M2_binned(i)-S2_binned(i),M2_binned(i)+S2_binned(i)];
        %l2.YData = [M3_binned(i)-S3_binned(i),M3_binned(i)+S3_binned(i)];
    end
    
    % axes limits
    ax.FontSize = 8;
    %ax.XTick = 0:10:60;
    %ax.XTickLabel = {'0';'10';'20';'30';'40';'50';'60'};
    ax.XTick = bins(1:5:end);
    ax.XTickLabel = num2cell(ax.XTick/60);
    %ax.XLim = [.5 30+.5];
    ax.XLim = [.5 bins(end)+.5];
    ax.YLim = [-1 1];
    ax.TickLength = [0 0];
    
end

hObj.Parent.Pointer = 'arrow';

end
