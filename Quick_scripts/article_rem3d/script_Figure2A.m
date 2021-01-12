% Article REM 3d - Figure 2
% Synthesis fUS episode statistics

function script_Figure2A()

if nargin <3
    gather_regions = true;
end

fName = sprintf('Fig2A_Synthesis_%s-%s.mat','Episodes','Statistics');
if exist(fName,'file')
    load(fName,'S','P','list_regions','list_group','list_files');
else
    [S,P,list_regions,list_group,list_files] = browse_data(fName);
end
plot1(S,P,fName,list_regions,list_group,list_files)

end

function [S,P,list_regions,list_group,list_files] = browse_data(fName)

folder = 'F:\SHARED_DATASET\NEUROLAB\NLab_Statistics\fUS_Statistics';

list_files = {'20190225_SD025_P202_R_nlab';
    '20190226_SD025_P101_R_nlab';
    '20190226_SD025_P201_R_nlab';
    '20190226_SD025_P301_R_nlab';
    '20190226_SD025_P302_R_nlab';
    '20190226_SD025_P401_R_nlab';
    '20190227_SD025_P102_R_nlab';
    '20190227_SD025_P201_R_nlab';
    '20190227_SD025_P202_R_nlab';
    '20190227_SD025_P501_R_nlab';
    '20190228_SD025_P301_R_nlab';
    '20190228_SD025_P302_R_nlab';
    '20190301_SD025_P401_R_nlab';
    '20190301_SD025_P402_R_nlab';
    '20190306_SD025_P301_R_nlab';
    '20190306_SD025_P401_R_nlab';
    '20190415_SD032_P201_R_nlab';
    '20190415_SD032_P202_R_nlab';
    '20190415_SD032_P301_R_nlab';
    '20190415_SD032_P302_R_nlab';
    '20190416_SD032_P102_R_nlab';
    '20190416_SD032_P201_R_nlab';
    '20190416_SD032_P202_R_nlab';
    '20190416_SD032_P203_R_nlab';
    '20190416_SD032_P301_R_nlab';
    '20190416_SD032_P302_R_nlab';
    '20190416_SD032_P303_R_nlab';
    '20190416_SD032_P402_R_nlab';
    '20190417_SD032_P102_R_nlab';
    '20190417_SD032_P103_R_nlab';
    '20190417_SD032_P202_R_nlab';
    '20190417_SD032_P203_R_nlab';
    '20190417_SD032_P301_R_nlab';
    '20190417_SD032_P302_R_nlab';
    '20190417_SD032_P303_R_nlab';
    '20190417_SD032_P401_R_nlab';
    '20190417_SD032_P402_R_nlab';
    '20190417_SD032_P403_R_nlab';
    '20190418_SD032_P102_R_nlab';
    '20190418_SD032_P103_R_nlab';
    '20190418_SD032_P201_R_nlab';
    '20190418_SD032_P202_R_nlab';
    '20190418_SD032_P203_R_nlab';
    '20190418_SD032_P301_R_nlab';
    '20190418_SD032_P302_R_nlab';
    '20190418_SD032_P303_R_nlab';
    '20190418_SD032_P401_R_nlab';
    '20190419_SD032_P201_R_nlab';
    '20190419_SD032_P202_R_nlab';
    '20190419_SD032_P301_R_nlab';
    '20190419_SD032_P302_R_nlab';
    '20190419_SD032_P401_R_nlab';
    '20190419_SD032_P402_R_nlab';
    '20190710_SD041_P201_R_nlab';
    '20190710_SD041_P301_R_nlab';
    '20190710_SD041_P401_R_nlab';
    '20190710_SD041_P402_R_nlab';
    '20190710_SD041_P501_R_nlab';
    '20190711_SD041_P103_R_nlab';
    '20190711_SD041_P401_R_nlab';
    '20190711_SD041_P402_R_nlab';
    '20190716_SD041_P201_R_nlab';
    '20190716_SD041_P203_R_nlab';
    '20190716_SD041_P301_R_nlab';
    '20190716_SD041_P302_R_nlab';
    '20190717_SD041_P103_R_nlab';
    '20190717_SD041_P104_R_nlab';
    '20190717_SD041_P201_R_nlab';
    '20190717_SD041_P401_R_nlab';
    '20190718_SD041_P201_R_nlab';
    '20190718_SD041_P202_R_nlab';
    '20190718_SD041_P302_R_nlab'};

% list of time groups
% list_group = {'QW';'AW';'NREM';'REM';};
list_group = {'QW';'AW';'NREM';'REM';'REM-TONIC';'REM-PHASIC';};


% list_regions
list_regions = {'OrbitalCtx';
    'MotorCtx';
    'CingulateCtx';
    'LimbicCtx';
    'ParietalCtx';
    'RhinalCtx';
    'SomatoSensoryCtx';
    'InsularCtx';
    'CaudatePutamen';
    'GlobusPallidus';
    'BasalGanglia';
    'SubstantiaNigra';
    'VisualCtx';
    'AuditoryCtx';
    'MammillaryNuclei';
    'PiriformCtx';
    'OlfactoryNuclei';
    'Ventricules';
    'ZonaIncerta';
    'PAG';
    'SuperiorColliculus';
    'PretectalNuclei';
    'RetrosplenialCtx';
    'GeniculateNuclei';
    'DentateGyrus';
    'PreopticArea';
    'SeptalNuclei';
    'Hypothalamus';
    'PosteriorAmygdala';
    'AnteriorAmygdala';
    'CA';
    'CA1';
    'CA2';
    'CA3';
    'Thalamus';
    'AssociationCtx';
    'Vessels';
    'ach';
    'acer';
    'mcer';
    'basalvessel';
    'vessel';
    'lhia';};

    
% Buidling struct S
S = struct('t_data',[],'x_data',[],'y_data',[],...
    'group','','region','','recording','');
S(length(list_group),length(list_regions)).y_data = [];
    
for index = 1:length(list_files)
    
    cur_file = char(list_files(index));
    % Loading fUS_Statistics
    d = dir(fullfile(folder,cur_file,'*_fUS_Statistics_WHOLE.mat'));
    if isempty(d)
        warning('Absent file fUS Statistics [File: %s]',cur_file);
        continue;
    elseif length(d)>1
        warning('Multiple files fUS Statistics [File: %s]',cur_file);
        d = d(1);  
    end
    data_fus = load(fullfile(d.folder,d.name));
    fprintf('fUS Statistics loaded [File: %s]\n',cur_file);
    
    % Collecting fUS data
    for i=1:length(list_group)
        cur_group = char(list_group(i));
        index_group = find(strcmp(data_fus.label_episodes,cur_group)==1);
        
        for j=1:length(list_regions) 
            cur_region = char(list_regions(j));
            index_region = find(strcmp(data_fus.label_channels,cur_region)==1);
            if length(index_region)>1
                index_region = index_region(end);
            end
            
            % Getting data
            Sdata=data_fus.S(index_group,index_region);
            if ~isempty(Sdata)
                S(i,j).group = cur_group;
                S(i,j).region = cur_region;
                S(i,j).recording = [S(i,j).recording;{cur_file}];
                S(i,j).t_data = [S(i,j).t_data;Sdata.t_data(:)];
                S(i,j).x_data = [S(i,j).x_data;Sdata.x_data(:)];
                S(i,j).y_data = [S(i,j).y_data;Sdata.y_data(:)];
            end
        end
    end
end

% Setting Parameters
f = figure('Visible','off');
colormap(f,'parula');
P.Colormap = f.Colormap;
P.f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
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
save(fName,'S','P','list_regions','list_group','list_files','-v7.3');
fprintf('Synthesis Data Saved [%s]\n',fName);

end

function plot1(S,P,fName,list_regions,list_group,list_files)

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
ax = axes('Parent',panel,'Position',[.1 .1 .8 .8]);
ax_dummy = axes('Parent',panel,'Position',[.1 .1 .8 .8],'Visible','off');
clrmenu(f);
f.Name = fName;
f.Renderer = 'Painters';
f.PaperPositionMode='manual';

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

% %Clearing Axes
% delete(findobj(panel,'Type','legend'));
% delete(ax.Children);
% ax_dummy = findobj(panel,'Tag','DummyAxes');
% delete(ax_dummy.Children);

% Getting data
%tt_data = rand(10000,length(list_regions),length(list_group));
m = 0;
for i =1:length(list_group)
    for j = 1:length(list_regions)
        m = max(m,length(S(i,j).y_data));
    end
end
tt_data = NaN(m,length(list_regions),length(list_group));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        temp = S(i,j).y_data;
        tt_data(1:length(temp),j,i) = temp;
    end
end

dummy_data = rand(length(list_group),length(list_regions));
xtick_labs = list_group;
leg_labs = list_regions;

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
        'Widths',gpwidth/(n_bars+1),...
        'Parent',ax);

end
hold(ax,'off');
ax.Position = [.05 .05 .8 .9];

% Dummy axes for legend
b = bar(dummy_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
%     ind_color = max(round(i*length(cmap)/n_bars-1)+1,1);
%     b(i).FaceColor = cmap(ind_color,:);
    b(i).FaceColor = f_colors(i,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,leg_labs,'Visible','on');
ax_dummy.Position = [2 1 1 1];

% Axis limits
%ax.YLim = [min(tt_data(:)) max(tt_data(:))];
ax.YLim = [-20 60];
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = 'Synthesis Episode Statistics';
grid(ax,'on');

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .9*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

f.Units = 'pixels';
f.Position = [195          59        1045         919];

fullname = fullfile(strrep(fName,'.mat','.pdf'));
saveas(f,fullname);

end