% Article RUN
% Figure 7
% to run after batch Peri-Event Time Histogram 
% Display (and save figure) polar plots for all brain regions
% Sorts all trials relative to the time of first trial 

function script_Figure7(cur_list,timegroup)

flag_grouped = false;
flag_save = true;
thresh_events = 10;
% ind_electrode = 1; %1: hpc; 2:cortex       
% [D,S,list_regions,list_lfp] = compute_script_Figure7(cur_list,timegroup,flag_grouped,thresh_events,ind_electrode);

% Same graph
[D,S1,list_regions,list_lfp] = compute_script_Figure7(cur_list,timegroup,flag_grouped,thresh_events,1);
[D,S2,list_regions,list_lfp] = compute_script_Figure7(cur_list,timegroup,flag_grouped,thresh_events,2);
%plot1_Figure7(S1,list_regions,list_lfp,cur_list,timegroup,flag_save);
plot1_sameax_Figure7(S1,S2,list_regions,list_lfp,cur_list,timegroup,flag_save);
%plot2_Figure7(S,list_regions,list_lfp,cur_list,timegroup,flag_save);

end

function [D,S,list_regions,list_lfp] = compute_script_Figure7(cur_list,timegroup,flag_grouped,thresh_events,ind_electrode)

close all;
folder = 'I:\NEUROLAB\NLab_Statistics\fUS_PeriEventHistogram';
all_files = dir(fullfile(folder,'*_E'));
index =0;
list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';...
    '20150225_154031_E';'20150226_173600_E';'20150619_132607_E';'20150620_175137_E';...
    '20150714_191128_E';'20150715_181141_E';'20150716_130039_E';'20150717_133756_E';...
    '20151126_170516_E';...'20150724_170457_E';'20150726_152241_E';'20150728_134238_E';
    '20151201_144024_E';'20151202_141449_E';'20151203_113703_E';'20160622_191334_E';...
    '20160623_123336_E';'20160624_120239_E';'20160628_171324_E';'20160629_134749_E';...
    '20160629_191304_E'};
% high-quality
list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';...
    '20150225_154031_E';'20150226_173600_E';'20150619_132607_E';'20150620_175137_E';...
    '20150714_191128_E';'20150715_181141_E';'20150716_130039_E';'20150717_133756_E';...
    '20151126_170516_E';...'20150724_170457_E';'20150726_152241_E';'20150728_134238_E';
    '20160622_191334_E';'20160623_123336_E'};
% % 6-best
% list_coronal = {'20150225_154031_E';'20150226_173600_E';'20150620_175137_E';...
%     '20150714_191128_E';'20150715_181141_E''20150717_133756_E'};

list_diagonal = {'20150227_134434_E';'20150304_150247_E';'20150305_190451_E';'20150306_162342_E';...
    '20150718_135026_E';'20150722_121257_E';'20150723_123927_E';'20150724_131647_E';...
    '20150725_130514_E';'20150725_160417_E';'20150727_114851_E';'20151127_120039_E';...
    '20151128_133929_E';'20151204_135022_E';'20160622_122940_E';'20160623_163228_E';...
    '20160623_193007_E';'20160624_171440_E';'20160625_113928_E';'20160625_163710_E';...
    '20160630_114317_E';'20160701_130444_E'};
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
        list_regions = {'AC-L.mat';'AC-R.mat';'S1BF-L.mat';'S1BF-R.mat';'LPtA-L.mat';'LPtA-R.mat';'RS-L.mat';'RS-R.mat';...
            'DG-L.mat';'DG-R.mat';'CA1-L.mat';'CA1-R.mat';'CA2-L.mat';'CA2-R.mat';'CA3-L.mat';'CA3-R.mat';...
            'dThal-L.mat';'dThal-R.mat';'Po-L.mat';'Po-R.mat';'VPM-L.mat';'VPM-R.mat'};...%'HypothalRg-L.mat';'HypothalRg-R.mat'
    else
        list_regions = {'AC.mat';'S1BF.mat';'LPtA.mat';'RS.mat';...
            'DG.mat';'CA1.mat';'CA2.mat';'CA3.mat';...
            'dThal.mat';'Po.mat';'VPM.mat';'Thalamus.mat';...'HypothalRg.mat';
            'Whole.mat'};
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

elseif  strcmp(cur_list,'FRONTAL')
    if ~flag_grouped
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
    if ~flag_grouped
        list_regions =    {'Neocortex-L.mat';'Neocortex-R.mat';...
            'dHpc-L.mat';'dHpc-R.mat';...
            'Thalamus-L.mat';'Thalamus-R.mat';...
            'HypothalRg-L.mat';'HypothalRg-R.mat'};
    else
        list_regions =    {'Neocortex.mat';'dHpc.mat';'Thalamus.mat';'HypothalRg.mat';'Whole.mat'};
    end
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
% list_lfp = [{'Power-ACC'};
%     {'SPEED'}];

% Buidling struct S
% All_trials
S = struct('region_fus',[],'channel_lfp',[],'R',[],'R_data1',[],'R_data2',[],'R_data1_scaled',[],'R_data2_scaled',[],...
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
    
    % test if data not too sparse
    if length(data_fus.label_events)<thresh_events
        warning('Insufficient episode number (%d) [File: %s]',length(data_fus.label_events),cur_file);
        continue;
    end
    
    for i=1:length(list_lfp)
        lfp_name = strrep(char(list_lfp(i)),'.mat','');
        %ind_lfp = find(strcmp(data_fus.label_lfp,lfp_name)==1);
        ind_lfp = find(contains(data_fus.label_lfp,lfp_name)==1);
        
        % Selecting ind_lfp
        if isempty(ind_lfp)
            fprintf('No match LFP [%s][%s].\n',cur_file,char(list_lfp(i)));
            continue;
        elseif length(ind_lfp)>1
            warning('Multiple pattern matches [Pattern: %s /File: %s /Selected: %s].',char(lfp_name),char(cur_file),char(data_fus.label_lfp(ind_lfp)));
            % ind_lfp = ind_lfp(1);
            % ind_electrode = 1; %1: hpc; 2:cortex
            ind_lfp = ind_lfp(contains(data_fus.label_lfp(ind_lfp),get_electrode(cur_file,ind_electrode)));
        end
            
        for j=1:length(list_regions)
            region_name = strrep(char(list_regions(j)),'.mat','');
            ind_reg = find(strcmp(data_fus.label_fus,region_name)==1);
            
            % Selecting ind_reg
            if isempty(ind_reg)
                fprintf('No match regions [%s][%s].\n',cur_file,char(list_regions(j)));
                continue;
            elseif length(ind_reg)>1
                ind_reg = ind_reg(1);
                warning('Multiple pattern matches [Pattern: %s /File: %s /Selected: %s]',region_name,cur_file,data_fus.label_fus(ind_reg));
            end
            
            % Filling Data
            S(i,j).region_fus = [S(i,j).region_fus;data_fus.label_fus(ind_reg)];
            S(i,j).channel_lfp = [S(i,j).channel_lfp;data_fus.label_lfp(ind_lfp)];
            S(i,j).R = [S(i,j).R;data_fus.C_XY(ind_reg,ind_lfp)];
            S(i,j).index_ref = [S(i,j).index_ref;{data_fus.index_ref}];
            S(i,j).corr_type = [S(i,j).corr_type;{data_fus.corr_type}];
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
    %        try
            S(i,j).R_data_rat_name = [S(i,j).R_data_rat_name; cellstr(repmat(rat_name,[N,1]))];
%             catch
%                 S(i,j).R_data_rat_name
%             end
            S(i,j).R_data_rat_id = [S(i,j).R_data_rat_id; cellstr(repmat(rat_id,[N,1]))];
        end
    end
    
end

end

function plot1_Figure7(S,list_regions,list_lfp,cur_list,timegroup,flag_save)

% Drawing results
f = figure;
f.Name = sprintf('Fig7_SynthesisA_%s-%s',cur_list,timegroup);
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
colormap(f,'jet');
f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
g_colors = f.Colormap(round(1:64/length(list_lfp):64),:);
list_regions = regexprep(list_regions,'.mat','');
list_lfp = regexprep(list_lfp,'/','');
list_lfp = regexprep(list_lfp,'\','');
str_fig =  char(S(1,1).index_ref(1,:));

% Sixth tab
all_paxes = [];
margin_w = .02;
margin_h =.02;
n_columns = 4;
n_rows = ceil(length(list_lfp)/n_columns);
lab_fus = [];
for k=1:length(list_regions)
    temp_regions = char(list_regions(k));
    lab_fus = [lab_fus;{temp_regions(1:2)}];
end

% Creating axes
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>length(list_lfp)
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        
        % Creating polar axes
        pax = polaraxes('Parent',f,'Tag',sprintf('PolarAx%d',index));
        hold(pax,'on');
        pax.Position= [x+margin_w y+margin_h (1/n_columns)-2*margin_w (1/n_rows)-3*margin_h];
        
        % polar hist with colors
        theta = rescale(1:length(list_regions)+1,0,2*pi);
        theta2 = theta(1:end-1)+.5*(theta(2)-theta(1));
        theta_tick = theta+(theta(2)-theta(1))/2;
        %rho = C_XY(:,index);
        rho = [];
        rho2 = [];
        rho3 = [];
        for k=1:length(list_regions)
            rho_mean = mean(S(index,k).R,'omitnan');
            rho_std = std(S(index,k).R,[],'omitnan');
            rho_sem = rho_std/sqrt(length(S(index,k).R));
            rho = [rho;rho_mean];
            rho2 = [rho2;rho_std];
            rho3 = [rho3;rho_sem];
            
            %             % polar plot dots
            %             theta_data = theta(k)*ones(size(S(index,k).R));
            %             r_data = S(index,k).R;
            %             % polar plot dots +
            %             polarplot(theta_data(r_data>=0),abs(r_data(r_data>=0)),'Parent',pax,...
            %                 'Color','none','Marker','o','MarkerSize',3,...
            %                 'MarkerFaceColor',f_colors(k,:),'MarkerEdgeColor','k');
            %             % polar plot dots -
            %             polarplot(theta_data(r_data<0),abs(r_data(r_data<0)),'Parent',pax,...
            %                 'Color','none','Marker','o','MarkerSize',3,...
            %                 'MarkerFaceColor',f_colors(k,:),'MarkerEdgeColor','w');
            % errorbar
            %rho_mean(isnan(rho_mean))=0;
            %rho_sem(isnan(rho_sem))=0;
            %             polarplot([theta_tick(k) theta_tick(k)],[abs(rho_mean)-rho_sem abs(rho_mean)+rho_sem],'Parent',pax,...
            %                 'Color','k','Marker','.','MarkerSize',1,'LineStyle','-','LineWidth',.5,...
            %                 'MarkerFaceColor',f_colors(k,:),'MarkerEdgeColor','k');
            polarplot([theta_tick(k) theta_tick(k)],[abs(rho_mean)-rho_sem abs(rho_mean)+rho_sem],'Parent',pax,...
                'Color',g_colors(index,:),'Marker','none','MarkerSize',1,'LineStyle','-','LineWidth',.5,...
                'MarkerFaceColor',f_colors(k,:),'MarkerEdgeColor','k');
        end
        
        % Simple polar plot 
        p = polarplot(theta2,abs(rho),'Parent',pax,...
            'Color',g_colors(index,:),'LineWidth',1,...
            'Marker','x','MarkerSize',3,'MarkerFaceColor',g_colors(index,:),'MarkerEdgeColor','k');
%         patch_x = [theta2;flipud(theta2)];
%         patch_y = [abs(rho)+rho3;flipud(abs(rho)-rho3)];
%         patch('XData',patch_x,'YData',patch_y,'Parent',pax,...
%             'FaceColor',g_colors(index,:),'FaceAlpha',.2,...
%             'EdgeColor','none');
        
%         % Polar histogram
%         rho_diag = diag(rho);
%         all_p = [];
%         for j=1:length(rho_diag)
%             p = polarhistogram('BinEdges',theta,'BinCounts',abs(rho_diag(j,:)),'Parent',pax,...
%                 'FaceColor',f_colors(j,:),'EdgeColor','none','FaceAlpha',1);
%             if sum(rho_diag(j,:))>0
%                 p.EdgeColor='k';
%             else
%                 p.EdgeColor='w';
%             end
%             all_p = [all_p;p];
%         end
        
        % Title and label
        pax.RLim = [0 .5];
        pax.Title.String = list_lfp(index);
        pax.ThetaAxisUnits = 'radian';
        pax.ThetaTick = theta_tick;
        pax.ThetaTickLabel = lab_fus;
        %pax.ThetaTick = '';
        %pax.ThetaTickLabel = '';
        pax.FontSize = 6;
        all_paxes = [all_paxes;pax];
    end
end

% Saving Figure
f.Units = 'pixels';
f.Position = [195          59        1045         919];

global DIR_SYNT;
savedir = fullfile(DIR_SYNT,'fUS_PeriEventHistogram');
if flag_save
    saveas(f,fullfile(savedir,sprintf('%s%s%s',f.Name,str_fig,'.pdf')));
    fprintf('Figure Saved [%s].\n',fullfile(sprintf('%s%s%s',f.Name,str_fig,'.pdf')));
end

end

function plot1_sameax_Figure7(S1,S2,list_regions,list_lfp,cur_list,timegroup,flag_save)

% Drawing results
f = figure;
f.Name = sprintf('Fig7_SynthesisB_%s-%s',cur_list,timegroup);
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
colormap(f,'jet');
f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
g_colors = f.Colormap(round(1:64/length(list_lfp):64),:);
list_regions = regexprep(list_regions,'.mat','');
list_lfp = regexprep(list_lfp,'/','');
list_lfp = regexprep(list_lfp,'\','');
str_fig =  char(S1(1,1).index_ref(1,:));

% Sixth tab
all_paxes = [];
margin_w = .02;
margin_h =.02;
n_columns = 4;
n_rows = ceil(length(list_lfp)/n_columns);
lab_fus = [];

for k=1:length(list_regions)
    temp_regions = char(list_regions(k));
    lab_fus = [lab_fus;{temp_regions(1:2)}];
end

% Creating axes
P_value = NaN(length(list_lfp),length(list_regions));
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>length(list_lfp)
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        
        % Creating polar axes
        pax = polaraxes('Parent',f,'Tag',sprintf('PolarAx%d',index));
        hold(pax,'on');
        pax.Position= [x+margin_w y+margin_h (1/n_columns)-2*margin_w (1/n_rows)-3*margin_h];
        
        % polar hist with colors
        theta = rescale(1:length(list_regions)+1,0,2*pi);
        theta2 = theta(1:end-1)+.5*(theta(2)-theta(1));
        theta_tick = theta+(theta(2)-theta(1))/2;
        %rho = C_XY(:,index);
        rho = [];
        visible_1 = 'off';
        visible_2 = 'off';
        lab_fus_stats = [];
        for k=1:length(list_regions)
            rho_mean = [mean(S1(index,k).R,'omitnan'),mean(S2(index,k).R,'omitnan')];
            rho_std = [std(S1(index,k).R,[],'omitnan'),std(S2(index,k).R,[],'omitnan')];
            rho_sem = [rho_std(:,1)/sqrt(length(S1(index,k).R)),rho_std(:,2)/sqrt(length(S2(index,k).R))];
            rho = [rho;rho_mean];
            
            p1 = polarplot([theta_tick(k) theta_tick(k)],[abs(rho_mean(:,1))-rho_sem(:,1) abs(rho_mean(:,1))+rho_sem(:,1)],...
                'Parent',pax,'Color',g_colors(index,:),'Marker','none','MarkerSize',1,...
                'LineStyle','-','LineWidth',1,'Visible',visible_1,...
                'MarkerFaceColor',f_colors(k,:),'MarkerEdgeColor','k');
            p2 = polarplot([theta_tick(k) theta_tick(k)],[abs(rho_mean(:,2))-rho_sem(:,2) abs(rho_mean(:,2))+rho_sem(:,2)],...
                'Parent',pax,'Color',g_colors(index,:),'Marker','none','MarkerSize',1,...
                'LineStyle','-','LineWidth',1,'Visible',visible_2,...
                'MarkerFaceColor',f_colors(k,:),'MarkerEdgeColor','k');
            
            % stats
            X = S1(index,k).R;
            X = X(~isnan(X));
            Zx = 0.5*(log(1+X)-log(1-X));
            Y = S2(index,k).R;
            Y = Y(~isnan(Y));
            Zy = 0.5*(log(1+Y)-log(1-Y));
            P = ranksum(Zx,Zy);
            if P<.001
                lab_fus_stats = [lab_fus_stats ;{'***'}];
            elseif P<.01
                lab_fus_stats = [lab_fus_stats ;{'**'}];
            elseif P<.05
                lab_fus_stats = [lab_fus_stats ;{'*'}];
            else
                lab_fus_stats = [lab_fus_stats ;{''}];
            end
            P_value(index,k)=P;
            
%             % fischer intervals
%             z_inf = rho_mean-1.96*rho_sem;
%             z_sup = rho_mean+1.96*rho_s;
%             r_inf = (exp(2*z_inf)-1)./(exp(2*z_inf)+1);
%             r_sup = (exp(2*z_sup)-1)./(exp(2*z_sup)+1);
%             p1 = polarplot([theta_tick(k) theta_tick(k)],[r_inf(:,1) r_sup(:,1)],...
%                 'Parent',pax,'Color',g_colors(index,:),'Marker','none','MarkerSize',1,...
%                 'LineStyle','-','LineWidth',1,'Visible',visible_1,...
%                 'MarkerFaceColor',f_colors(k,:),'MarkerEdgeColor','k');
%             p2 = polarplot([theta_tick(k) theta_tick(k)],[r_inf(:,2) r_sup(:,2)],...
%                 'Parent',pax,'Color',g_colors(index,:),'Marker','none','MarkerSize',1,...
%                 'LineStyle','-','LineWidth',1,'Visible',visible_2,...
%                 'MarkerFaceColor',f_colors(k,:),'MarkerEdgeColor','k');
        end
        
        % Simple polar plot 
        p1 = polarplot(theta2,abs(rho(:,1)),'Parent',pax,'Visible',visible_1,...
            'Color','k','LineWidth',.5,'LineStyle','-',...
            'Marker','o','MarkerSize',3,'MarkerFaceColor',g_colors(index,:),'MarkerEdgeColor','k');
        p2 = polarplot(theta2,abs(rho(:,2)),'Parent',pax,'Visible',visible_2,...
            'Color',[.5 .5 .5],'LineWidth',.5,'LineStyle','-',...
            'Marker','s','MarkerSize',3,'MarkerFaceColor',g_colors(index,:),'MarkerEdgeColor',[.5 .5 .5]);
        
        % Title and label
        pax.RLim = [0 .5];
        pax.Title.String = list_lfp(index);
        pax.ThetaAxisUnits = 'radian';
        pax.ThetaTick = theta_tick;
        %pax.ThetaTickLabel = lab_fus;
        pax.ThetaTickLabel = lab_fus_stats;
        if index==1
            pax.ThetaTickLabel = 1:length(lab_fus);
        else
            pax.ThetaTickLabel = '';
        end
        pax.FontSize = 6;
        all_paxes = [all_paxes;pax];
        
%         % Minimal Layout
%         grid(pax,'off');
%         pax.ThetaTick = '';
%         pax.ThetaTickLabel = '';
%         pax.Title.String = '';
%         pax.RTick = '';
%         pax.RTickLabel = '';
    end
end

% Saving Figure
f.Units = 'pixels';
f.Position = [195          59        1045         919];

global DIR_SYNT;
savedir = fullfile(DIR_SYNT,'fUS_PeriEventHistogram');
if flag_save
    saveas(f,fullfile(savedir,sprintf('%s%s%s',f.Name,str_fig,'.pdf')));
    fprintf('Figure Saved [%s].\n',fullfile(sprintf('%s%s%s',f.Name,str_fig,'.pdf')));
end

end

function plot2_Figure7(S,list_regions,list_lfp,cur_list,timegroup,flag_save)

% Drawing results
f = figure;
f.Name = sprintf('Fig7_SynthesisC_%s-%s',cur_list,timegroup);
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
colormap(f,'parula');
f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
list_regions = regexprep(list_regions,'.mat','');
list_lfp = regexprep(list_lfp,'/','');
list_lfp = regexprep(list_lfp,'\','');
%str_fig =  char(S(1,1).index_ref(1,:));

%TabGroup
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',f,...
    'Tag','TabGroup');
all_tabs = [];
for i =1:length(list_lfp)
    tab = uitab('Parent',tabgp,...
        'Tag',sprintf('Ax-%02d',i),...
        'Units','normalized',...
        'Title',char(list_lfp(i)),...
        'Tag','MainTab');
    all_tabs = [all_tabs ;tab];
end

for i =1:length(list_lfp)
    % Current tab
    tab = all_tabs(i);
    all_axes = [];
    margin_w = .02;
    margin_h =.02;
    n_columns = 4;
    n_rows = ceil(length(list_regions)/n_columns);
    lab_fus = [];
    for k=1:length(list_regions)
        temp_regions = char(list_regions(k));
        lab_fus = [lab_fus;{temp_regions(1:2)}];
    end
    
    % Creating axes
    for ii = 1:n_rows
        for jj = 1:n_columns
            index = (ii-1)*n_columns+jj;
            if index>length(list_regions)
                continue;
            end
            x = mod(index-1,n_columns)/n_columns;
            y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
            ax = axes('Parent',tab);
            ax.Position= [x+margin_w y+margin_h (1/n_columns)-2*margin_w (1/n_rows)-3*margin_h];
            ax.XAxisLocation ='origin';
            ax.Tag = sprintf('Ax-%02d',index);
            ax.Title.String = char(list_regions(index));
            ax.Title.Visible = 'on';
            all_axes = [all_axes;ax];
            
            % Plotting
            list_rat = unique(S(i,index).R_data_rat_name);
            markers = {'o';'+';'*';'x';'s';'d';'<';'>';'p';'h';...
                'o';'+';'*';'x';'s';'d';'<';'>';'p';'h'};
            xdata = S(i,index).R_data1_scaled;
            ydata = S(i,index).R_data2_scaled;
            %xdata = S(i,index).R_data1;
            %ydata = S(i,index).R_data2;
            corr_type = 'Kendall';
            r = corr(xdata,ydata,'rows','complete','type',corr_type);
%             %All rats
%             line('XData',xdata,'YData',ydata,'Parent',ax,...
%                 'Color',f_colors(index,:),'Marker','.','MarkerSize',5,...
%                 'LineStyle','none','Tag','Data');
            % Each rat
            for kk=1:length(list_rat)
                cur_rat = char(list_rat(kk));
                line('XData',xdata(strcmp(S(i,index).R_data_rat_name,cur_rat)),...
                    'YData',ydata(strcmp(S(i,index).R_data_rat_name,cur_rat)),'Parent',ax,...
                'Color',f_colors(index,:),'Marker',char(markers(kk)),'MarkerSize',3,...
                'LineStyle','none','Tag','Data');
            end
            lsline(ax);
            text(.8,.9,sprintf('r=%.2f',r),'Color',f_colors(index,:),...
                'FontWeight','bold','EdgeColor','k','BackgroundColor','w');
%             if index == length(list_regions)
%                 leg = legend(ax,markers,'Location','eastoutside');
%             end
            
            % Limits
            ax.XLim = [min(xdata) max(xdata)];
            ax.YLim = [min(ydata) max(ydata)];
        end
    end
end

% Saving Figure
f.Units = 'pixels';
f.Position = [195          59        1045         919];
global DIR_SYNT;
savedir = fullfile(DIR_SYNT,'fUS_PeriEventHistogram');

if flag_save
    for k = 1:length(all_tabs)
        tabgp.SelectedTab = all_tabs(k);
        str_fig = strrep(strcat('_',char(all_tabs(k).Title),'_',corr_type),filesep,'');
        saveas(f,fullfile(savedir,sprintf('%s%s%s',f.Name,str_fig,'.pdf')));
        fprintf('Figure Saved [%s].\n',fullfile(savedir,sprintf('%s%s%s',f.Name,str_fig,'.pdf')));
    end
end

end