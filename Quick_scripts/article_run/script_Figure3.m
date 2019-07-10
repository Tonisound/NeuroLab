% Article RUN
% Figure 3
close all;

folder = 'I:\fUSLAB\fLab_Statistics\fUS_Correlation';
all_files = dir(fullfile(folder,'*_E'));
D = struct('file','','reference','','all_regions','','timegroup','','plane','');
index =0;

list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';...
    '20150225_154031_E';'20150226_173600_E';'20150619_132607_E';'20150620_175137_E';...
    '20150714_191128_E';'20150715_181141_E';'20150716_130039_E';'20150717_133756_E';...
    '20150724_170457_E';'20150726_152241_E';'20150728_134238_E';'20151126_170516_E';...
    '20151201_144024_E';'20151202_141449_E';'20151203_113703_E';'20160622_191334_E';...
    '20160623_123336_E';'20160624_120239_E';'20160628_171324_E';'20160629_134749_E';...
    '20160629_191304_E'};
list_diagonal = {'20150227_134434_E';'20150304_150247_E';'20150305_190451_E';'20150306_162342_E';...
    '20150718_135026_E';'20150722_121257_E';'20150723_123927_E';'20150724_131647_E';...
    '20150725_130514_E';'20150725_160417_E';'20150727_114851_E';'20151127_120039_E';...
    '20151128_133929_E';'20151204_135022_E';'20160622_122940_E';'20160623_163228_E';...
    '20160623_193007_E';'20160624_171440_E';'20160625_113928_E';'20160625_163710_E';...
    '20160630_114317_E';};%'20160701_130444_E'};

% list of references to search (in order)
list_ref = {'SPEED';'ACCEL'};
%list_ref = {'Theta'};
flag_mainchannel = true;
timegroup = 'RUN';
cur_list = 'CORONAL';

for i = 1:length(all_files)
    cur_file = char(all_files(i).name);
    
    % reference
    d = dir(fullfile(folder,cur_file,'*_normalized'));
    
    flag_ref=false;
    for j=1:length(list_ref) 
        pattern = char(list_ref(j));
        if sum(contains({d(:).name}',pattern))>0
            ind_keep = find(contains({d(:).name}',pattern)==1);
            if length(ind_keep)>1
                % Selecting
                rmax_score=[];
                for k=1:length(ind_keep)
                    if exist(fullfile(folder,cur_file,char(d(ind_keep(k)).name),timegroup,'Correlation_pattern.mat'),'file')
                        data_cp = load(fullfile(folder,cur_file,char(d(ind_keep(k)).name),timegroup,'Correlation_pattern.mat'),'RT_pattern');
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
    
    % timegroup
    dd = dir(fullfile(folder,cur_file,reference,timegroup));
    if ~isempty(dd)
        ddd = dir(fullfile(folder,cur_file,reference,timegroup,'Regions','*.mat'));
        all_regions = {ddd(:).name}';
    else
        continue;
    end
    
    % updating struct D
    index = index+1;
    D(index).file = cur_file;
    D(index).reference = reference;
    D(index).timegroup = timegroup;
    D(index).all_regions = all_regions;
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
    list_regions =    {'AC-L.mat';'AC-R.mat';'S1BF-L.mat';'S1BF-R.mat';'LPtA-L.mat';'LPtA-R.mat';'RS-L.mat';'RS-R.mat';...
        'DG-L.mat';'DG-R.mat';'CA1-L.mat';'CA1-R.mat';'CA2-L.mat';'CA2-R.mat';'CA3-L.mat';'CA3-R.mat';...
        'dThal-L.mat';'dThal-R.mat';'Po-L.mat';'Po-R.mat';'VPM-L.mat';'VPM-R.mat';...
        'HypothalRg-L.mat';'HypothalRg-R.mat'};
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
elseif  strcmp(cur_list,'DIAGONAL')
    list_regions = {'AntCortex-L.mat';'AMidCortex-L.mat';'PMidCortex-R.mat';'PostCortex-R.mat';...
        'DG-R.mat';'CA3-R.mat';'CA1-R.mat';'dHpc-R.mat';'vHpc-R.mat';...
        'dThal-R.mat';'vThal-R.mat';'Thalamus-L.mat';'Thalamus-R.mat';'GP-L.mat';'CPu-L.mat';...
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
    fulpath = fullfile(folder,cur_file,reference,timegroup,'Regions');
    
    % Loading UF
    data_uf = load(fullfile(folder,cur_file,reference,timegroup,'UF.mat'),'UF');
    data_c = load(fullfile(folder,cur_file,reference,timegroup,'Correlation_pattern.mat'),'RT_pattern','Rmax_map','Tmax_map');
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
        ddd = dir(fullfile(folder,cur_file,reference,timegroup,'Regions',region_name));
        if ~isempty(ddd)
            data_r = load(fullfile(folder,cur_file,reference,timegroup,'Regions',region_name),'tmax','rmax');
            rmax_regions(index,i) = data_r.rmax;
            tmax_regions(index,i) = data_r.tmax;
        end
    end

    % Computing rmax, tmax
    RT_pattern = S(index).RT_pattern;
    labels = S(index).labels ;
    lags_s = S(index).lags*S(index).step;
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
    folder_im = 'I:\NEUROLAB\NLab_DATA';
    try
        data_im = load(fullfile(folder_im,strcat(cur_file,'_nlab'),'Config.mat'),'Current_Image');
    catch
        data_im.Current_Image = zeros(size(data_c.Rmax_map));
    end
    im_baseline = data_im.Current_Image; 
    S(index).background = 20*log10(abs(im_baseline)/max(max(abs(im_baseline))));
end

% trasnforming tmax
%tmax_regions = tmax_regions-repmat(tmax_regions(:,1),[1 length(list_regions)]);

% Drawing results
f = figure;
colormap(f,'parula');
cmap = f.Colormap;
ax1 = subplot(121);
m = mean(rmax_regions,1,'omitnan');
s_sem = std(rmax_regions,[],1,'omitnan')./sum(~isnan(rmax_regions),1);
b1 = bar(1:length(list_regions),diag(m),'stacked','Parent',ax1);
hold on;
e1 = errorbar(diag(m),diag(s_sem),'Color','k',...
    'Parent',ax1,'LineStyle','none','LineWidth',1);
% dots = 
x_dots = repmat(1:length(list_regions),[length(D) 1]);
plot(x_dots',rmax_regions','Linestyle','none','Linewidth',.1,'Color','k',...
    'Marker','o','MarkerSize',3,'MarkerFaceColor','k','MarkerEdgeColor','none','Parent',ax1);
ax1.XTick = 1:length(list_regions);
ax1.XTickLabel = regexprep(list_regions,'.mat','');
ax1.XTickLabelRotation = 45;
ax1.YLabel.String = 'rmax';
ax2 = subplot(122);
m = mean(tmax_regions,1,'omitnan');
s_sem = std(tmax_regions,[],1,'omitnan')./sum(~isnan(tmax_regions),1);
ax1.YLim = [0, 1];

% sort timing
flag_sorted = true;
if flag_sorted
    [~,ind_sorted] = sort(m,'ascend');
else
    ind_sorted = 1:length(m);
end
m = m(ind_sorted);
s_sem = s_sem(ind_sorted);
list_regions_sorted = list_regions(ind_sorted);

b2 = bar(diag(m),'stacked','Parent',ax2);
hold on;
e2 = errorbar(diag(m),diag(s_sem),'Color','k',...
    'Parent',ax2,'LineStyle','none','LineWidth',1);
% dots = 
x_dots = repmat(1:length(list_regions_sorted),[length(D) 1]);
plot(x_dots',tmax_regions','Linestyle','none','Linewidth',.1,'Color','k',...
    'Marker','o','MarkerSize',3,'MarkerFaceColor','k','MarkerEdgeColor','none','Parent',ax2);
ax2.XTick = 1:length(list_regions_sorted);
ax2.XTickLabel = regexprep(list_regions_sorted,'.mat','');
ax2.XTickLabelRotation = 45;
ax2.YLabel.String = 'tmax';
ax2.YLim = [0, 3.5];
%[1.2, 1.6];

% colors
ind_cmap = round(1:length(cmap)/length(b1):length(cmap));
cmap = cmap(1:floor(length(cmap)/length(b1)):end,:);
cmap_sorted = cmap(ind_sorted,:);
for i =1:length(b1)
    b2(i).FaceColor = cmap(i,:);
    b2(i).EdgeColor='none';
    
    ind_b1 = find(strcmp(ax1.XTickLabel,ax2.XTickLabel(i))==1);
    b1(ind_b1).FaceColor=cmap(i,:);
    b1(ind_b1).EdgeColor='none';
end

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