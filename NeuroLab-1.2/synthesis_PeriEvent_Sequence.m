function synthesis_PeriEvent_Sequence(all_event_names)
% Reorganizes Event-Imaging figures in one folder
% Generates a synthesis video of fUS peri-event activations
% Generates Event Detection synthesis figures


global DIR_SYNT DIR_FIG DIR_STATS;
load('Preferences.mat','GTraces');


% Parameters
if nargin ==0
    all_event_names = {'[NREM]Ripples-Merged-All'};
%     all_event_names = {'[NREM]Ripples-Merged-Occurence-Q1';'[NREM]Ripples-Merged-Occurence-Q2';'[NREM]Ripples-Merged-Occurence-Q3';'[NREM]Ripples-Merged-Occurence-Q4';...
%         '[NREM]Ripples-Merged-Amplitude-Q1';'[NREM]Ripples-Merged-Amplitude-Q2';'[NREM]Ripples-Merged-Amplitude-Q3';'[NREM]Ripples-Merged-Amplitude-Q4';...
%         '[NREM]Ripples-Merged-Duration-Q1';'[NREM]Ripples-Merged-Duration-Q2';'[NREM]Ripples-Merged-Duration-Q3';'[NREM]Ripples-Merged-Duration-Q4';...
%         '[NREM]Ripples-Merged-Frequency-Q1';'[NREM]Ripples-Merged-Frequency-Q2';'[NREM]Ripples-Merged-Frequency-Q3';'[NREM]Ripples-Merged-Frequency-Q4'};
%     all_event_names = {'[NREM]Ripples-Merged-Amplitude[Top50]';...
%         '[NREM]Ripples-Merged-Duration[Top50]';...
%         '[NREM]Ripples-Merged-Frequency[Top50]'};
%     all_event_names = {'[NREM]Ripples-Merged-Burst-Single[1.00sec]';...
%         '[NREM]Ripples-Merged-Burst-Duet[1.00sec]';...
%         '[NREM]Ripples-Merged-Burst-Triplet[1.00sec]';...
%         '[NREM]Ripples-Merged-Burst-Quadruplet[1.00sec]'};   
end
flag_moving_figures = false;
flag_synthesis_figure = true;
flag_synthesis_movie = false;
flag_event_detection = false;
flag_regions_averages = false;

% Display Parameters
% sequence_display_reg = 'mean';            % Displaying region sequence
% sequence_display_vox = 'mean';            % Displaying voxel sequence
cmap_figure = 'jet';
cmap_movie = 'jet';
CLim_movie = [-5;10];
main_text_fontsize = 30;
ax_fontsize = 12;
cbar_fontsize = 22;
title_fontsize = 14;
valmax_map_thresh = 5;


% Sanity Checks
folder_source_figs = fullfile(DIR_FIG,'PeriEvent_Sequence');
if ~isfolder(folder_source_figs)
    errordlg(sprintf('Not a directory [%s]',folder_source_figs));
    return;
end
folder_source_stats = fullfile(DIR_STATS,'PeriEvent_Sequence');
if ~isfolder(folder_source_stats)
    errordlg(sprintf('Not a directory [%s]',folder_source_stats));
    return;
end


% Regions
list_regions = {'[CTX-ACA-L]';'[CTX-ACA-R]';...
    '[CTX-AI-L]';'[CTX-AI-R]';...'[CTX-AUD-L]';'[CTX-AUD-R]';... '[CTX-Ect-L]';'[CTX-Ect-R]';...
    '[CTX-GU-L]';'[CTX-GU-R]';...
    '[CTX-ILA-L]';'[CTX-ILA-R]';...
    '[CTX-MO-L]';'[CTX-MO-R]';...'[CTX-PERI-L]';'[CTX-PERI-R]';...
    '[CTX-RSP-L]';'[CTX-RSP-R]';...
    '[CTX-SS-L]';'[CTX-SS-R]';...'[CTX-TeA-L]';'[CTX-TeA-R]';...
    '[CTX-VIS-L]';'[CTX-VIS-R]';...
    '[HPF-HIPd-L]';'[HPF-HIPd-R]';...'[OLF-DP-L]';'[OLF-DP-R]';...'[OLF-PIR-L]';'[OLF-PIR-R]';...'[OLF-COA-L]';'[OLF-COA-R]';...'[OLF-TT-L]';'[OLF-TT-R]';...
    '[HPF-HIPv-L]';'[HPF-HIPv-R]';...
    '[RHP-SUB-L]';'[RHP-SUB-R]';...
    '[RHP-ENT-L]';'[RHP-ENT-R]';...
    '[CTXsp-CLA-L]';'[CTXsp-CLA-R]';...
    '[CTXsp-EP-L]';'[CTXsp-EP-R]';...
    '[CTXsp-Amy-L]';'[CTXsp-Amy-R]';...
    '[STRd-CP-L]';'[STRd-CP-R]';...
    '[STRv-OT-L]';'[STRv-OT-R]';...
    '[STRv-ACB-L]';'[STRv-ACB-R]';...
    '[BS-THAL-L]';'[BS-THAL-R]';...
    '[CNU-PAL-LR]';...
    '[CNU-LSx-LR]';...
    '[BS-MID-LR]';...
    '[MID-PAG-LR]';...
    '[MID-SC-LR]';...
    '[BS-HYPO-LR]';...
    '[tracts-LR]';...
    '[ventricles-LR]'};
% list_regions = {'[SR]AnteriorCortex-L';'[SR]AnteriorCortex-R';...
%     '[SR]PosteriorCortex-L';'[SR]PosteriorCortex-R';...
%     '[SR]HippocampalFormation-L';'[SR]HippocampalFormation-R';...
%     '[SR]Midbrain-L';'[SR]Midbrain-R';...
%     '[SR]Thalamus-L';'[SR]Thalamus-R';...
%     '[SR]Amygdala-L';'[SR]Amygdala-R';...
%     '[SR]Hypothalamus-L';'[SR]Hypothalamus-R';...
%     '[SR]Other-L}';'[SR]Hypothalamus-R'};
% list_regions = {'dCA1-L';'dCA1-R';...
%     'dDG-L';'dDG-R';...
%     'vCA1-L';'vCA1-R';...
%     'vCA3-L';'vCA3-R';...
%     'VS-L';'VS-R'};
% list_regions = {'OrbitalCortex-L';'OrbitalCortex-R';...
%     'OrbitalCortex-L';'OrbitalCortex-R';...
%     'CingulateCortex-L';'CingulateCortex-R';...
%     'InsularCortex-L';'InsularCortex-R';...
%     'MotorCortex-L';'MotorCortex-R';...
%     'SomatosensoryCortex-L';'SomatosensoryCortex-R';...
%     'PiriformCortex-L';'PiriformCortex-R';...
%     'RetrosplenialCortex-L';'RetrosplenialCortex-R';...
%     'ParietalCortex-L';'ParietalCortex-R';...
%     'AuditoryCortex-L';'AuditoryCortex-R';...
%     'RhinalCortex-L';'RhinalCortex-R';...
%     'EntorhinalCortex-L';'EntorhinalCortex-R';...
%     'VisualCortex-L';'VisualCortex-R';...
%     'Septum-L';'Septum-R';...
%     'DentateGyrus-L';'DentateGyrus-R';...
%     'CA1Region-L';'CA1Region-R';...
%     'CA2Region-L';'CA2Region-R';...
%     'CA3Region-L';'CA3Region-R';...
%     'Subiculum-L';'Subiculum-R';...
%     'Fimbria-L';'Fimbria-R';...
%     'ResidualHippocampus-L';'ResidualHippocampus-R';...
%     'Claustrum-L';'Claustrum-R';...
%     'Striatum-L';'Striatum-R';...
%     'BasalForebrain-L';'BasalForebrain-R';...
%     'SubstantiaNigra-L';'SubstantiaNigra-R';...
%     'SuperiorColliculus-L';'SuperiorColliculus-R';...
%     'DPAG-L';'DPAG-R';...
%     'VPAG-L';'VPAG-R';...
%     'DThalamus-L';'DThalamus-R';...
%     'VThalamus-L';'VThalamus-R';...
%     'Habenulla-L';'Habenulla-R';...
%     'ZonaIncerta-L';'ZonaIncerta-R';...
%     'PretectalNuclei-L';'PretectalNuclei-R';...
%     'GeniculateNuclei-L';'GeniculateNuclei-R';...
%     'ReticularFormation-L';'ReticularFormation-R';...
%     'AnteriorAmygdala-L';'AnteriorAmygdala-R';...
%     'PosteriorAmygdala-L';'PosteriorAmygdala-R';...
%     'StriaTerminalis-L';'StriaTerminalis-R';...
%     'DHypothalamus-L';'DHypothalamus-R';...
%     'LHypothalamus-L';'LHypothalamus-R';...
%     'VHypothalamus-L';'VHypothalamus-R';...
%     'VTegmentalArea-L';'VTegmentalArea-R';...
%     'PreopticArea-L';'PreopticArea-R';...
%     'MammillaryNuclei-L';'MammillaryNuclei-R';...
%     'OlfactoryNuclei-L';'OlfactoryNuclei-R'};


n_regions = length(list_regions);


for index_event=1:length(all_event_names)
    
    % Event Selection
    event_name = all_event_names{index_event};
    
    folder_dest = fullfile(DIR_SYNT,'PeriEvent_Sequence',event_name);
    if ~isfolder(folder_dest)
        mkdir(folder_dest);
    end
    
    % Listing files
    d = dir(fullfile(folder_source_stats,'*',sprintf('%s_PeriEventSequence.mat',event_name)));
    all_files = strrep({d(:).folder}',strcat(folder_source_stats,filesep),'');
    
    % Listing animals
    all_animals = cell(size(all_files));
    for i=1:length(all_files)
        temp = regexp(char(all_files(i)),'_','split');
        all_animals(i)=temp(2);
    end
    unique_animals = unique(all_animals);
    
    
    %% Browsing stats - Buidling struct
    if exist(fullfile(folder_dest,strcat(event_name,'.mat')),'file')
        
        fprintf('Loading file [%s] ...',folder_dest,strcat(event_name,'.mat'));
        data_full = load(fullfile(folder_dest,strcat(event_name,'.mat')));
        all_planes = data_full.all_planes;
        %     all_coordinates = data_full.all_coordinates;
        list_regions = data_full.list_regions;
        t_bins_fus = data_full.t_bins_fus;
        t_bins_lfp = data_full.t_bins_lfp;
        R = data_full.R;
        Q = data_full.Q;
        S = data_full.S;
        fprintf(' done.\n');
        
    else
        
        S = struct('name',[],'atlas_name',[],'atlas_fullname',[],'atlas_coordinate',[],'data_atlas',[]);
        
        % Listing planes
        all_planes = cell(size(all_files));
        all_coordinates = NaN(size(all_files));
        label_Y3q_evt = {'Mean';'Median'};
        
        
        R = struct('recording_name',[],'region',[],'animal',[],'plane',[],...
            'single_events',[],'atlas_coordinate',[],'atlas_fullname',[]);
        R(n_regions).recording_name = [];
        
        Q = struct('recording_name',[],'region',[],'animal',[],'plane',[],...
            'mean_events',[],'median_events',[],'atlas_coordinate',[],'atlas_fullname',[],...
            'valmax_mean',[],'valmax_median',[],'tmax_mean',[],'tmax_median',[]);
        Q(n_regions).recording_name = [];
        
        for i=1:length(all_files)
            
            % PeriEvent_Sequence.mat
            file_pe = fullfile(folder_source_stats,char(all_files(i)),sprintf('%s_PeriEventSequence.mat',event_name));
            if isfile(file_pe)
                fprintf('Loading file [%s].\n',file_pe);
                data_pe = load(file_pe,'Params','freqdom','Cdata_mean',...
                    'data_atlas','atlas_name','atlas_fullname','atlas_coordinate',...
                    'all_labels_channels','t_bins_lfp','Y0q_evt_mean','Y0q_evt_median','Y0q_evt_std','Y0q_evt_sem',...
                    'Z0q_evt_mean','Z0q_evt_median','Z0q_evt_std','Z0q_evt_sem',...
                    'Y1q_evt_mean','Y1q_evt_median','Y1q_evt_std','Y1q_evt_sem',...
                    'all_labels_regions','t_bins_fus','Y2q_evt_mean','Y2q_evt_median','Y2q_evt_std','Y2q_evt_sem',...
                    'Y2q_tmax_mean','Y2q_tmax_median','Y2q_valmax_mean','Y2q_valmax_median',...
                    'Y3q_tmax_mean','Y3q_tmax_median','Y3q_valmax_mean','Y3q_valmax_median',...
                    'Y3q_evt_mean_reshaped','Y3q_evt_median_reshaped');
            else
                warning('No PeriEvent_Sequence File found [%s][%s].',event_name,char(all_files(i)));
                continue;
            end
            
            t_bins_fus = data_pe.t_bins_fus;
            all_coordinates(i) = data_pe.atlas_coordinate;
            all_planes(i) = {strtrim(strrep(strrep(strrep(data_pe.data_atlas.AtlasName,'Mouse',''),'Rat',''),'Paxinos',''))};
            
            % Traces
            S(i).t_bins_lfp = data_pe.t_bins_lfp;
            S(i).all_labels_channels = data_pe.all_labels_channels;
            S(i).freqdom = data_pe.freqdom;
            S(i).Cdata_mean = data_pe.Cdata_mean;
            
            S(i).Y0q_evt_mean = data_pe.Y0q_evt_mean;
            S(i).Y0q_evt_median = data_pe.Y0q_evt_median;
            S(i).Y0q_evt_std = data_pe.Y0q_evt_std;
            S(i).Y0q_evt_sem = data_pe.Y0q_evt_sem;
            
            S(i).Z0q_evt_mean = data_pe.Z0q_evt_mean;
            S(i).Z0q_evt_median = data_pe.Z0q_evt_median;
            S(i).Z0q_evt_std = data_pe.Z0q_evt_std;
            S(i).Z0q_evt_sem = data_pe.Z0q_evt_sem;
            
            S(i).Y1q_evt_mean = data_pe.Y1q_evt_mean;
            S(i).Y1q_evt_median = data_pe.Y1q_evt_median;
            S(i).Y1q_evt_std = data_pe.Y1q_evt_std;
            S(i).Y1q_evt_sem = data_pe.Y1q_evt_sem;
            
            % Sequence
            S(i).Y3q_tmax_mean = data_pe.Y3q_tmax_mean;
            S(i).Y3q_tmax_median = data_pe.Y3q_tmax_median;
            S(i).Y3q_valmax_mean = data_pe.Y3q_valmax_mean;
            S(i).Y3q_valmax_median = data_pe.Y3q_valmax_median;
            S(i).Y3q_evt_mean_reshaped = data_pe.Y3q_evt_mean_reshaped;
            S(i).Y3q_evt_median_reshaped = data_pe.Y3q_evt_median_reshaped;
            
            S(i).t_bins_fus = data_pe.t_bins_fus;
            S(i).name = strrep(strrep(data_pe.Params.recording_name,'_nlab',''),'_','-');
            S(i).animal = char(all_animals(i));
            S(i).atlas_coordinate = data_pe.atlas_coordinate;
            S(i).atlas_name = data_pe.atlas_name;
            S(i).atlas_fullname = data_pe.atlas_fullname;
            S(i).data_atlas = data_pe.data_atlas;
            S(i).plane = char(all_planes(i));
            S(i).n_events = data_pe.Params.n_events;
            S(i).density_events = data_pe.Params.density_events;
            S(i).channel_id = data_pe.Params.channel_id;
            S(i).ind_channel_id = data_pe.Params.ind_channel_id;
            
            % Regions
            S(i).t_bins_fus = data_pe.t_bins_fus;
            S(i).all_labels_regions = data_pe.all_labels_regions;
            S(i).Y2q_evt_mean = data_pe.Y2q_evt_mean;
            S(i).Y2q_evt_median = data_pe.Y2q_evt_median;
            S(i).Y2q_evt_std = data_pe.Y2q_evt_std;
            S(i).Y2q_evt_sem = data_pe.Y2q_evt_sem;
            S(i).Y2q_valmax_mean = data_pe.Y2q_valmax_mean;
            S(i).Y2q_valmax_median = data_pe.Y2q_valmax_median;
            S(i).Y2q_tmax_mean = data_pe.Y2q_tmax_mean;
            S(i).Y2q_tmax_median = data_pe.Y2q_tmax_median;
            
            for k=1:n_regions
                cur_region = char(list_regions(k));
                ind_label = find(strcmp(data_pe.all_labels_regions,cur_region)==1);
                if ~isempty(ind_label)
                    
                    n_events = data_pe.Params.n_events;
                    cur_names = repmat({data_pe.Params.recording_name},[n_events,1]);
                    cur_regions = repmat(list_regions(k),[n_events,1]);
                    cur_animals = repmat(all_animals(i),[n_events,1]);
                    cur_planes = repmat(all_planes(i),[n_events,1]);
                    atlas_coordinates = repmat(data_pe.atlas_coordinate,[n_events,1]);
                    atlas_fullnames = repmat({data_pe.atlas_fullname},[n_events,1]);
                    % single_events = squeeze(data_pe.Y2q_evt_normalized(ind_label,:,:))';
                    single_events = repmat(data_pe.Y2q_evt_mean(ind_label,:),[n_events,1]);
                    
                    R(k).recording_name = [R(k).recording_name;cur_names];
                    R(k).region = [R(k).region;cur_regions];
                    R(k).animal = [R(k).animal;cur_animals];
                    R(k).plane = [R(k).plane;cur_planes];
                    R(k).atlas_coordinate = [R(k).atlas_coordinate;atlas_coordinates];
                    R(k).atlas_fullname = [R(k).atlas_fullname;atlas_fullnames];
                    R(k).single_events = [R(k).single_events;single_events];
                    
                    Q(k).recording_name = [Q(k).recording_name;{data_pe.Params.recording_name}];
                    Q(k).region = [Q(k).region;list_regions(k)];
                    Q(k).animal = [Q(k).animal;all_animals(i)];
                    Q(k).plane = [Q(k).plane;all_planes(i)];
                    Q(k).atlas_coordinate = [Q(k).atlas_coordinate;data_pe.atlas_coordinate];
                    Q(k).atlas_fullname = [Q(k).atlas_fullname;{data_pe.atlas_fullname}];
                    Q(k).mean_events = [Q(k).mean_events;data_pe.Y2q_evt_mean(ind_label,:)];
                    Q(k).median_events = [Q(k).median_events;data_pe.Y2q_evt_median(ind_label,:)];
                    Q(k).valmax_mean = [Q(k).valmax_mean;data_pe.Y2q_valmax_mean(ind_label)];
                    Q(k).valmax_median = [Q(k).valmax_median;data_pe.Y2q_valmax_median(ind_label)];
                    Q(k).tmax_mean = [Q(k).tmax_mean;data_pe.Y2q_tmax_mean(ind_label)];
                    Q(k).tmax_median = [Q(k).tmax_median;data_pe.Y2q_tmax_median(ind_label)];
                    
                end
            end
            
        end
        % Sorting S
        [~,ind_sorted] = sort(all_coordinates,'descend');
        S = S(ind_sorted);
        
        %     % Saving
        %     fprintf('Saving file [%s] ...',folder_dest,strcat(event_name,'.mat'));
        %     save(fullfile(folder_dest,strcat(event_name,'.mat')),...
        %         'all_planes','all_coordinates',...
        %         'list_regions','t_bins_fus','t_bins_lfp',...
        %         'R','Q','S','-v7.3');
        %     fprintf(' done.\n');
        
    end
    
    % Create folders
    unique_planes = unique(all_planes);
    for i=1:length(unique_animals)
        for j=1:length(unique_planes)
            if ~isfolder(fullfile(folder_dest,strcat(char(unique_animals(i)),'-',char(unique_planes(j)))))
                mkdir(fullfile(folder_dest,strcat(char(unique_animals(i)),'-',char(unique_planes(j)))));
            end
        end
    end
    
    
    %% Moving figures
    if flag_moving_figures
        for i=1:length(all_files)
            dd = dir(fullfile(folder_source_figs,char(all_files(i)),strcat(event_name,'_PeriEventSequence','*')));
            for k=1:length(dd)
                dd_dest = fullfile(folder_dest,strcat(char(all_animals(i)),'-',char(all_planes(i))));
                if ~isfolder(dd_dest)
                    mkdir(dd_dest)
                end
                copyfile(fullfile(dd(k).folder,dd(k).name),fullfile(dd_dest,strcat(char(all_files(i)),'_',dd(k).name)));
                fprintf('File copied [%s] ---> [%s].\n',dd(k).name,dd_dest);
            end
        end
    end
    
    
    %% Displaying synthesis figure
    w_margin_1 = .05;       % left margin
    w_margin_2 = .05;       % right margin
    w_eps = .02;            % horizontal spacing
    h_margin_1 = .05;       % bottom margin
    h_margin_2 = .05;       % top margin
    h_eps = .02;            % vertical spacing
    margins = [w_margin_1,w_margin_2,w_eps;h_margin_1,h_margin_2,h_eps];
    
    if flag_synthesis_figure
        for j=1:length(unique_animals)
            cur_animal = char(unique_animals(j));
            S_animal = S(strcmp({S(:).animal}',cur_animal)==1);
            
            for jj=1:length(unique_planes)
                cur_plane = char(unique_planes(jj));
                S_animal_plane = S_animal(strcmp({S_animal(:).plane}',cur_plane)==1);
                
                % Sanity Check
                if isempty(S_animal_plane)
                    continue;
                end
                
                % n_col = 6;
                n_col = ceil(1.2*sqrt(length(S_animal_plane)));
                n_rows = ceil(length(S_animal_plane)/n_col);
                
                for l=1:length(label_Y3q_evt)
                    cur_label = char(label_Y3q_evt(l));
                    f1 = figure('Units','normalized','OuterPosition',[0 0 1 1],'Name',strcat('Event-Synthesis_',cur_animal,'-',cur_plane,'_',cur_label));
                    f2 = figure('Units','normalized','OuterPosition',[0 0 1 1],'Name',strcat('Event-Synthesis_',cur_animal,'-',cur_plane,'_',cur_label));
                    colormap(f1,cmap_movie);
                    colormap(f2,cmap_movie);
                    f1_axes = [];
                    f2_axes = [];
                    for i=1:length(S_animal_plane)
                        ax1 = axes('Parent',f1);
                        ax2 = axes('Parent',f2);
                        ax1.Position = get_position(n_rows,n_col,i,margins);
                        ax2.Position = get_position(n_rows,n_col,i,margins);
                        f1_axes = [f1_axes;ax1];
                        f2_axes = [f2_axes;ax2];
                    end
                    t1 = uicontrol(f1,'Style','text','BackgroundColor','w','FontSize',main_text_fontsize,'FontWeight','bold',...
                        'Units','normalized','Position',[.15 .96 .7 .03],'Parent',f1);
                    t2 = uicontrol(f1,'Style','text','BackgroundColor','w','FontSize',main_text_fontsize,'FontWeight','bold',...
                        'Units','normalized','Position',[.15 .96 .7 .03],'Parent',f2);
                    
                    for i=1:length(f1_axes)
                        ax1 = f1_axes(i);
                        ax2 = f2_axes(i);
                        ax1.FontSize = ax_fontsize;
                        ax2.FontSize = ax_fontsize;
                        cla(ax1);
                        cla(ax2);
                        hold(ax1,'on');
                        hold(ax2,'on');
                        switch cur_label
                            case 'Mean'
                                valmax_map = S_animal_plane(i).Y3q_valmax_mean;
                                tmax_map = S_animal_plane(i).Y3q_tmax_mean;
                            case 'Median'
                                valmax_map = S_animal_plane(i).Y3q_valmax_median;
                                tmax_map = S_animal_plane(i).Y3q_tmax_median;
                            otherwise
                                Y3q_evt = NaN(1,1);
                        end
                        
                        im1 = imagesc(valmax_map,'Parent',ax1);
                        im2 = imagesc(tmax_map,'Parent',ax2);
                        im2.AlphaData = im1.CData > valmax_map_thresh;
                        ax1.Title.String = sprintf('%s [N=%d][%.2fHz]',S_animal_plane(i).atlas_fullname,S_animal_plane(i).n_events,S_animal_plane(i).density_events);
                        ax2.Title.String = sprintf('%s [N=%d][%.2fHz]',S_animal_plane(i).atlas_fullname,S_animal_plane(i).n_events,S_animal_plane(i).density_events);
                        ax1.YLabel.String = S_animal_plane(i).name;
                        ax2.YLabel.String = S_animal_plane(i).name;
                        t1.String = sprintf('[%s][%s] Peak Amplitude Map',event_name,cur_label);
                        l1 = line('XData',S_animal_plane(i).data_atlas.line_x,'YData',S_animal_plane(i).data_atlas.line_z,'Tag','AtlasMask',...
                            'LineWidth',.5,'Color','r','Parent',ax1);
                        l1.Color(4)=.5;
                        t2.String = sprintf('[%s][%s] Peak Time Map',event_name,cur_label);
                        l2 = line('XData',S_animal_plane(i).data_atlas.line_x,'YData',S_animal_plane(i).data_atlas.line_z,'Tag','AtlasMask',...
                            'LineWidth',.5,'Color','r','Parent',ax2);
                        l2.Color(4)=.5;
                        l2.Visible = 'on';
                        
                        ax1.CLim = [CLim_movie(1),CLim_movie(2)];
                        ax2.CLim = [0,3];
                        ax1.XLim = [.5 size(valmax_map,2)+.5];
                        ax2.XLim = [.5 size(tmax_map,2)+.5];
                        ax1.YLim = [.5 size(valmax_map,1)+.5];
                        ax2.YLim = [.5 size(tmax_map,1)+.5];
                        set(ax1,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                        set(ax2,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                        ax1.YDir = 'reverse';
                        ax2.YDir = 'reverse';
                        if i == length(f1_axes)
                            pos = ax1.Position;
                            c1 = colorbar(ax1,"eastoutside");
                            c2 = colorbar(ax2,"eastoutside");
                            c1.Position(1) = pos(1)+pos(3)+.01;
                            c2.Position(1) = pos(1)+pos(3)+.01;
                        end
                    end
                    pic_name1 = sprintf(strcat('%s_PeakAmplitudeMap-%s'),event_name,cur_label);
                    saveas(f1,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name1,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
                    pic_name2 = sprintf(strcat('%s_PeakTimeMap-%s'),event_name,cur_label);
                    saveas(f2,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name2,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
                    % delete(c);
                    close(f1);
                    close(f2);
                end
            end
        end
    end
    
    
    %% Displaying synthesis movie
    w_margin_1 = .05;       % left margin
    w_margin_2 = .05;       % right margin
    w_eps = .02;            % horizontal spacing
    h_margin_1 = .05;       % bottom margin
    h_margin_2 = .06;       % top margin
    h_eps = .02;            % vertical spacing
    margins = [w_margin_1,w_margin_2,w_eps;h_margin_1,h_margin_2,h_eps];
    
    if flag_synthesis_movie
        for j=1:length(unique_animals)
            cur_animal = char(unique_animals(j));
            S_animal = S(strcmp({S(:).animal}',cur_animal)==1);
            
            for jj=1:length(unique_planes)
                cur_plane = char(unique_planes(jj));
                S_animal_plane = S_animal(strcmp({S_animal(:).plane}',cur_plane)==1);
                
                % Sanity Check
                if isempty(S_animal_plane)
                    continue;
                end
                
                % n_col = 6;
                n_col = ceil(1.2*sqrt(length(S_animal_plane)));
                n_rows = ceil(length(S_animal_plane)/n_col);
                
                for l=1:length(label_Y3q_evt)
                    cur_label = char(label_Y3q_evt(l));
                    f = figure('Units','normalized','OuterPosition',[0 0 1 1],'Name',strcat('Event-Synthesis_',cur_animal,'-',cur_plane,'_',cur_label));
                    colormap(f,cmap_movie);
                    f_axes = [];
                    for i=1:length(S_animal_plane)
                        ax = axes('Parent',f);
                        ax.Position = get_position(n_rows,n_col,i,margins);
                        f_axes = [f_axes;ax];
                    end
                    t = uicontrol(f,'Style','text','BackgroundColor','w','FontSize',main_text_fontsize,...'FontWeight','bold',
                        'Units','normalized','Position',[.15 .95 .7 .04],'Parent',f);
                    
                    work_dir = fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat('Frames-',cur_animal,'-',cur_plane,'_',cur_label));
                    if isfolder(work_dir)
                        rmdir(work_dir,'s');
                    end
                    mkdir(work_dir);
                    
                    for k=1:length(t_bins_fus)
                        for i=1:length(f_axes)
                            ax = f_axes(i);
                            ax.FontSize = ax_fontsize;
                            cla(ax);
                            hold(ax,'on');
                            switch cur_label
                                case 'Mean'
                                    Y3q_evt = S_animal_plane(i).Y3q_evt_mean_reshaped;
                                case 'Median'
                                    Y3q_evt = S_animal_plane(i).Y3q_evt_median_reshaped;
                                otherwise
                                    Y3q_evt = NaN(1,1,length(t_bins_fus));
                            end
                            
                            imagesc(Y3q_evt(:,:,k),'Parent',ax);
                            ax.Title.String = sprintf('%s [N=%d][%.2fHz]',S_animal_plane(i).atlas_fullname,S_animal_plane(i).n_events,S_animal_plane(i).density_events);
                            ax.YLabel.String = S_animal_plane(i).name;
                            % t.String = sprintf('[%s][%s] Time from Event Peak = %.2f s',event_name, cur_label,t_bins_fus(k));
                            t.String = sprintf('Time from Ripple Peak = %.2f sec',t_bins_fus(k));
                            l_ = line('XData',S_animal_plane(i).data_atlas.line_x,'YData',S_animal_plane(i).data_atlas.line_z,'Tag','AtlasMask',...
                                'LineWidth',.5,'Color','r','Parent',ax);
                            l_.Color(4)=.5;
                            % ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                            ax.CLim = [CLim_movie(1),CLim_movie(2)];
                            ax.XLim = [.5 size(Y3q_evt,2)+.5];
                            ax.YLim = [.5 size(Y3q_evt,1)+.5];
                            set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                            ax.YDir = 'reverse';
                            if i ==length(f_axes)
                                pos = ax.Position;
                                c = colorbar(ax,"eastoutside");
                                c.Position(1) = pos(1)+pos(3)+.01;
                                c.Position(3) = pos(3)/10;
                                c.FontSize = cbar_fontsize;
                            end
                        end
                        pic_name = sprintf(strcat('%s_Event-Synthesis_%03d.mat'),event_name,k);
                        saveas(f,fullfile(work_dir,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
                        delete(c);
                    end
                    
                    video_name = strcat(event_name,'_Event-Synthesis_',cur_animal,'-',cur_plane,'_',cur_label);
                    save_video(work_dir,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane)),video_name);
%                     rmdir(work_dir,'s');
                    close(f);
                end
            end
        end
    end
    
    
    %% Displaying event detection
    w_margin_1 = .05;       % left margin
    w_margin_2 = .05;       % right margin
    w_eps = .02;            % horizontal spacing
    h_margin_1 = .05;       % bottom margin
    h_margin_2 = .05;       % top margin
    h_eps = .03;            % vertical spacing
    margins = [w_margin_1,w_margin_2,w_eps;h_margin_1,h_margin_2,h_eps];
    
    if flag_event_detection
        for j=1:length(unique_animals)
            cur_animal = char(unique_animals(j));
            S_animal = S(strcmp({S(:).animal}',cur_animal)==1);
            
            for jj=1:length(unique_planes)
                cur_plane = char(unique_planes(jj));
                S_animal_plane = S_animal(strcmp({S_animal(:).plane}',cur_plane)==1);
                
                % Sanity Check
                if isempty(S_animal_plane)
                    continue;
                end
                
                n_col = ceil(1.2*sqrt(length(S_animal_plane)));
                n_rows = ceil(length(S_animal_plane)/n_col);
                
                f = figure('Units','normalized','OuterPosition',[0 0 1 1],'Name',strcat('Event-Detection_',cur_animal,'-',cur_plane));
                colormap(f,cmap_figure);
                f_axes = [];
                for i=1:length(S_animal_plane)
                    ax = axes('Parent',f);
                    ax.FontSize = ax_fontsize;
                    ax.Position = get_position(n_rows,n_col,i,margins);
                    f_axes = [f_axes;ax];
                end
                
                % Displaying event detection - Raw Trace
                for i=1:length(f_axes)
                    ax = f_axes(i);
                    cla(ax);
                    hold(ax,'on');
                    
                    % Data
                    t_bins_lfp = S_animal_plane(i).t_bins_lfp;
                    Y0mean = S_animal_plane(i).Y0q_evt_mean(S_animal_plane(i).ind_channel_id,:);
                    Y0std = S_animal_plane(i).Y0q_evt_std(S_animal_plane(i).ind_channel_id,:);
                    Y0mean = Y0mean(:);
                    Y0std = Y0std(:);
                    % Patch
                    px_data = [t_bins_lfp;flipud(t_bins_lfp)];
                    py_data = [Y0mean+Y0std;flipud(Y0mean-Y0std)];
                    patch('XData',px_data,'YData',py_data,'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax,'FaceAlpha',.5);
                    % Line
                    line('XData',t_bins_lfp,'YData',Y0mean,'Color','r','LineWidth',2,'Parent',ax);
                    ax.Title.String = sprintf('[Rip:%s][N=%d][%.2fHz]',S_animal_plane(i).channel_id,S_animal_plane(i).n_events,S_animal_plane(i).density_events);
                    ax.YLabel.String = S_animal_plane(i).name;
                    % Display
                    n_iqr = 20;
                    Yraw_evt = Y0mean;
                    data_iqr = Yraw_evt(~isnan(Yraw_evt));
                    ax.YLim = [median(data_iqr(:))-2*n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                    ax.XLim = [-.1 .1];
                    set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                    
                end
                pic_name = sprintf(strcat(event_name,'_','Event-Detection-Raw','_',cur_animal,'-',cur_plane));
                saveas(f,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
                fprintf('File Saved  [%s].\n',pic_name);
                
                % Displaying event detection - Zcored Trace
                for i=1:length(f_axes)
                    ax = f_axes(i);
                    cla(ax);
                    hold(ax,'on');
                    
                    % Data
                    t_bins_lfp = S_animal_plane(i).t_bins_lfp;
                    Z0mean = S_animal_plane(i).Z0q_evt_mean(:);
                    Z0std = S_animal_plane(i).Z0q_evt_std(:);
                    % Patch
                    px_data = [t_bins_lfp;flipud(t_bins_lfp)];
                    py_data = [Z0mean+Z0std;flipud(Z0mean-Z0std)];
                    patch('XData',px_data,'YData',py_data,'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax,'FaceAlpha',.5);
                    % Line
                    line('XData',t_bins_lfp,'YData',Z0mean,'Color','r','LineWidth',2,'Parent',ax);
                    ax.Title.String = sprintf('[Rip:%s][N=%d][%.2fHz]',S_animal_plane(i).channel_id,S_animal_plane(i).n_events,S_animal_plane(i).density_events);
                    ax.YLabel.String = S_animal_plane(i).name;
                    % Display
                    n_iqr = 20;
                    Yraw_evt = Z0mean;
                    data_iqr = Yraw_evt(~isnan(Yraw_evt));
                    ax.YLim = [median(data_iqr(:))-2*n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                    ax.XLim = [-.1 .1];
                    set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                end
                pic_name = sprintf(strcat(event_name,'_','Event-Detection-Zscored','_',cur_animal,'-',cur_plane));
                saveas(f,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
                fprintf('File Saved  [%s].\n',pic_name);
                
                % Displaying event detection - Filtered Trace
                for i=1:length(f_axes)
                    ax = f_axes(i);
                    cla(ax);
                    hold(ax,'on');
                    
                    % Data
                    t_bins_lfp = S_animal_plane(i).t_bins_lfp;
                    Y1mean = S_animal_plane(i).Y1q_evt_mean(:);
                    Y1std = S_animal_plane(i).Y1q_evt_std(:);
                    % Patch
                    px_data = [t_bins_lfp;flipud(t_bins_lfp)];
                    py_data = [Y1mean+Y1std;flipud(Y1mean-Y1std)];
                    patch('XData',px_data,'YData',py_data,'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax,'FaceAlpha',.5);
                    % Line
                    line('XData',t_bins_lfp,'YData',Y1mean,'Color','r','LineWidth',2,'Parent',ax);
                    ax.Title.String = sprintf('[Rip:%s][N=%d][%.2fHz]',S_animal_plane(i).channel_id,S_animal_plane(i).n_events,S_animal_plane(i).density_events);
                    ax.YLabel.String = S_animal_plane(i).name;
                    % Display
                    n_iqr = 200;
                    Yraw_evt = Y1mean;
                    data_iqr = Yraw_evt(~isnan(Yraw_evt));
                    ax.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                    ax.XLim = [-.1 .1];
                    set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                    
                end
                pic_name = sprintf(strcat(event_name,'_','Event-Detection-Filtered','_',cur_animal,'-',cur_plane));
                saveas(f,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
                fprintf('File Saved  [%s].\n',pic_name);
                
                % Displaying event detection - Spectrogram
                for i=1:length(f_axes)
                    ax = f_axes(i);
                    cla(ax);
                    hold(ax,'on');
                    
                    % Data
                    t_bins_lfp = S_animal_plane(i).t_bins_lfp;
                    freqdom = S_animal_plane(i).freqdom;
                    Cdata_mean = S_animal_plane(i).Cdata_mean;
                    imagesc('XData',t_bins_lfp,'YData',freqdom,'CData',Cdata_mean,'HitTest','off','Parent',ax);
                    ax.Title.String = sprintf('[Rip:%s][N=%d][%.2fHz]',S_animal_plane(i).channel_id,S_animal_plane(i).n_events,S_animal_plane(i).density_events);
                    ax.YLabel.String = S_animal_plane(i).name;
                    n_iqr = 3;
                    data_iqr = Cdata_mean(~isnan(Cdata_mean));
                    ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                    ax.YLim = [S_animal_plane(i).freqdom(1),S_animal_plane(i).freqdom(end)];
                    ax.XLim = [-.1 .1];
                    set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                    l = line('XData',[0 0],'YData',ax.YLim,'Color','r',...
                        'LineStyle','--','LineWidth',.1,'Parent',ax);
                    l.Color(4)=.75;
                end
                pic_name = sprintf(strcat(event_name,'_','Event-Detection-Spectrogram','_',cur_animal,'-',cur_plane));
                saveas(f,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
                fprintf('File Saved  [%s].\n',pic_name);
                close(f);
                
            end
        end
    end
    
    %% Displaying region averages
    if flag_regions_averages
        
        %         % All events
        %         mean_regions_events = NaN(n_regions,length(t_bins_fus));
        %         median_regions_events = NaN(n_regions,length(t_bins_fus));
        %         n_regions_events = NaN(n_regions,1);
        %         n_regions_recordings = NaN(n_regions,1);
        %         label_regions = cell(n_regions,1);
        %
        %         for i=1:n_regions
        %             if ~isempty(R(i).single_events)
        %                 mean_regions_events(i,:) = mean(R(i).single_events,1,'omitnan');
        %                 median_regions_events(i,:) = median(R(i).single_events,1,'omitnan');
        %             end
        %             n_regions_events(i) = size(R(i).single_events,1);
        %             n_regions_recordings(i) = size(unique(R(i).recording_name),1);
        %             label_regions(i) = {sprintf('%s [N=%d-R=%d]',char(strrep(list_regions(i),'_','-')),n_regions_events(i),n_regions_recordings(i))};
        %         end
        %
        %         f = figure('Units','normalized','OuterPosition',[0 0 1 1]);
        %         colormap(f,cmap_figure);
        %
        %         ax1 = axes('Parent',f,'Position',[.1 .05 .4 .9]);
        %         hold(ax1,'on');
        %         imagesc('XData',t_bins_fus,'YData',1:n_regions,'CData',mean_regions_events,'HitTest','off','Parent',ax1);
        %         n_iqr = 6;
        %         data_iqr = mean_regions_events(~isnan(mean_regions_events));
        %         ax1.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
        %         ax1.YLim = [.5 n_regions+.5];
        %         ax1.XLim = [t_bins_fus(1),t_bins_fus(end)];
        %         ax1.YTick = 1:n_regions;
        %         ax1.YTickLabel = label_regions;
        %         ax1.Title.String = 'Mean Regions All Events';
        %         ax1.YDir = 'reverse';
        %         colorbar(ax1,'eastoutside');
        %         line('XData',[0 0],'YData',ax1.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax1);
        %
        %         ax2 = axes('Parent',f,'Position',[.6 .05 .4 .9]);
        %         hold(ax2,'on');
        %         imagesc('XData',t_bins_fus,'YData',1:n_regions,'CData',median_regions_events,'HitTest','off','Parent',ax2);
        %         n_iqr = 6;
        %         data_iqr = median_regions_events(~isnan(mean_regions_events));
        %         ax2.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
        %         ax2.YLim = [.5 n_regions+.5];
        %         ax2.XLim = [t_bins_fus(1),t_bins_fus(end)];
        %         ax2.YTick = 1:n_regions;
        %         ax2.YTickLabel = label_regions;
        %         ax2.Title.String = 'Median Regions All Events';
        %         ax2.YDir = 'reverse';
        %         colorbar(ax2,'eastoutside');
        %         line('XData',[0 0],'YData',ax2.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax2);
        %         f_axes = [ax1;ax2];
        %
        %         pic_name = strcat(event_name,'_','Regional-Responses_All-Trials-1');
        %         saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        %         fprintf('File Saved  [%s].\n',pic_name);
        %         % close(f);
        %
        %         delete(f_axes);
        %         %     n_col = 10;
        %         n_col = ceil(sqrt(n_regions));
        %         n_rows = ceil(n_regions/n_col);
        %
        %         f_axes=[];
        %         for i=1:n_regions
        %             ax = axes('Parent',f,'Position',get_position(n_rows,n_col,i,[.05 .05 .01;.05 .05 .02]));
        %             hold(ax,'on');
        %
        %             YData = R(i).single_events;
        %             YData_median = median(YData,1,'omitnan');
        %             YData_mean = mean(YData,1,'omitnan');
        %             if ~isempty(YData_mean)
        %                 YData_std = std(YData,0,1,'omitnan');
        %                 l1 = line('XData',t_bins_fus,'YData',YData_mean,'Color','r','LineWidth',1,'Parent',ax);
        %                 l2 = line('XData',t_bins_fus,'YData',YData_median,'Color','b','LineWidth',1,'Parent',ax);
        %                 n_samples = sum(~isnan(YData),1);
        %                 ebar_data = YData_std./sqrt(n_samples);
        %                 errorbar(t_bins_fus,YData_mean,ebar_data,'Color','r',...
        %                     'linewidth',1,'linestyle','none',...
        %                     'Parent',ax,'Visible','on','Tag','ErrorBar');
        %                 errorbar(t_bins_fus,YData_median,ebar_data,'Color','b',...
        %                     'linewidth',1,'linestyle','none',...
        %                     'Parent',ax,'Visible','on','Tag','ErrorBar');
        %
        %                 uistack([l1;l2],'top');
        %                 ax.XLim = [t_bins_fus(1),t_bins_fus(end)];
        %
        %                 n_iqr= 2;
        %                 data_iqr = YData_mean(~isnan(YData_mean));
        %                 % ax.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
        %                 ax.YLim = [median(data_iqr(:))-5,median(data_iqr(:))+10];
        %             end
        %
        %             line('XData',[0 0],'YData',ax.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax);
        %             ax.Title.String = char(label_regions(i));
        %             set(ax,'XTick',[],'XTickLabel',[]);
        %             f_axes=[f_axes;ax];
        %
        %         end
        %
        %         pic_name = strcat(event_name,'_','Regional-Responses_All-Trials-2');
        %         saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        %         fprintf('File Saved  [%s].\n',pic_name);
        %         % close(f);
        %
        %         delete(f_axes);
        %         f_axes=[];
        %         for i=1:n_regions
        %             ax = axes('Parent',f,'Position',get_position(n_rows,n_col,i,[.05 .05 .01;.05 .05 .02]));
        %             hold(ax,'on');
        %             YData = R(i).single_events;
        %             if ~isempty(YData)
        %                 imagesc('XData',t_bins_fus,'YData',1:n_regions_events(i),'CData',YData,'Parent',ax);
        %                 line('XData',[0 0],'YData',ax.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax);
        %
        %                 ax.XLim = [t_bins_fus(1),t_bins_fus(end)];
        %                 ax.YLim = [.5,n_regions_events(i)+.5];
        %                 ax.YDir = 'reverse';
        %                 %     colorbar(ax,'eastoutside');
        %                 %     ax.FontSize = cbar_fontsize;
        %
        %                 n_iqr= 3;
        %                 data_iqr = YData(~isnan(YData));
        %                 %     ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
        %                 ax.CLim = [-10,30];
        %
        %             end
        %
        %             ax.Title.String = char(label_regions(i));
        %             set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
        %
        %             f_axes=[f_axes;ax];
        %         end
        %
        %         pic_name = strcat(event_name,'_','Regional-Responses_All-Trials-3');
        %         saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        %         fprintf('File Saved  [%s].\n',pic_name);
        %         close(f);
        
        % All recordings
        mean_regions_recordings = NaN(n_regions,length(t_bins_fus));
        median_regions_recordings = NaN(n_regions,length(t_bins_fus));
        n_regions_recordings = NaN(n_regions,1);
        label_regions = cell(n_regions,1);
        
        for i=1:n_regions
            if ~isempty(Q(i).mean_events)
                mean_regions_recordings(i,:) = mean(Q(i).mean_events,1,'omitnan');
                median_regions_recordings(i,:) = median(Q(i).median_events,1,'omitnan');
            end
            n_regions_recordings(i) = size(unique(Q(i).recording_name),1);
            label_regions(i) = {sprintf('%s [R=%d]',char(strrep(list_regions(i),'_','-')),n_regions_recordings(i))};
        end
        
        f = figure('Units','normalized','OuterPosition',[0 0 1 1]);
        colormap(f,cmap_figure);
        
        ax1 = axes('Parent',f,'Position',[.1 .05 .4 .9]);
        hold(ax1,'on');
        imagesc('XData',t_bins_fus,'YData',1:n_regions,'CData',mean_regions_recordings,'HitTest','off','Parent',ax1);
        n_iqr = 6;
        data_iqr = mean_regions_recordings(~isnan(mean_regions_recordings));
        ax1.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
        ax1.YLim = [.5 n_regions+.5];
        ax1.XLim = [t_bins_fus(1),t_bins_fus(end)];
        ax1.YTick = 1:n_regions;
        ax1.YTickLabel = label_regions;
        ax1.Title.String = 'Mean Regions - All Recordings';
        ax1.YDir = 'reverse';
        colorbar(ax1,'eastoutside');
        line('XData',[0 0],'YData',ax1.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax1);
        
        ax2 = axes('Parent',f,'Position',[.6 .05 .4 .9]);
        hold(ax2,'on');
        imagesc('XData',t_bins_fus,'YData',1:n_regions,'CData',median_regions_recordings,'HitTest','off','Parent',ax2);
        n_iqr = 6;
        data_iqr = median_regions_recordings(~isnan(median_regions_recordings));
        ax2.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
        ax2.YLim = [.5 n_regions+.5];
        ax2.XLim = [t_bins_fus(1),t_bins_fus(end)];
        ax2.YTick = 1:n_regions;
        ax2.YTickLabel = label_regions;
        ax2.Title.String = 'Median Regions - All Recordings';
        ax2.YDir = 'reverse';
        colorbar(ax2,'eastoutside');
        line('XData',[0 0],'YData',ax2.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax2);
        f_axes = [ax1;ax2];
        
        pic_name = strcat(event_name,'_','Regional-Responses_All-Recordings-1');
        saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('File Saved  [%s].\n',pic_name);
        % close(f);
        
        delete(f_axes);
        % n_col = 10;
        n_col = ceil(sqrt(n_regions));
        n_rows = ceil(n_regions/n_col);
        
        f_axes=[];
        for i=1:n_regions
            ax = axes('Parent',f,'Position',get_position(n_rows,n_col,i,[.05 .05 .01;.05 .05 .02]));
            hold(ax,'on');
            
            YData1 = Q(i).mean_events;
            YData_mean = mean(YData1,1,'omitnan');
            YData2 = Q(i).median_events;
            YData_median = median(YData2,1,'omitnan');
            if ~isempty(YData_mean)
                YData1_std = std(YData1,0,1,'omitnan');
                YData2_std = std(YData2,0,1,'omitnan');
                l1 = line('XData',t_bins_fus,'YData',YData_mean,'Color','r','LineWidth',1,'Parent',ax);
                l2 = line('XData',t_bins_fus,'YData',YData_median,'Color','b','LineWidth',1,'Parent',ax);
                n_samples_1 = sum(~isnan(YData1),1);
                ebar_data_1 = YData1_std./sqrt(n_samples_1);
                errorbar(t_bins_fus,YData_mean,ebar_data_1,'Color','r',...
                    'linewidth',1,'linestyle','none',...
                    'Parent',ax,'Visible','on','Tag','ErrorBar');
                n_samples_2 = sum(~isnan(YData2),1);
                ebar_data_2 = YData2_std./sqrt(n_samples_2);
                errorbar(t_bins_fus,YData_median,ebar_data_2,'Color','b',...
                    'linewidth',1,'linestyle','none',...
                    'Parent',ax,'Visible','on','Tag','ErrorBar');
                
                uistack([l1;l2],'top');
                ax.XLim = [t_bins_fus(1),t_bins_fus(end)];
                
                n_iqr= 2;
                data_iqr = YData_mean(~isnan(YData_mean));
                % ax.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                ax.YLim = [median(data_iqr(:))-5,median(data_iqr(:))+10];
            end
            
            line('XData',[0 0],'YData',ax.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax);
            ax.Title.String = char(label_regions(i));
            set(ax,'XTick',[],'XTickLabel',[]);
            f_axes=[f_axes;ax];
            
        end
        
        pic_name = strcat(event_name,'_','Regional-Responses_All-Recordings-2');
        saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('File Saved  [%s].\n',pic_name);
        % close(f);
        
        delete(f_axes);
        f_axes=[];
        for i=1:n_regions
            ax = axes('Parent',f,'Position',get_position(n_rows,n_col,i,[.05 .05 .01;.05 .05 .02]));
            hold(ax,'on');
            YData = Q(i).mean_events;
            if ~isempty(YData)
                imagesc('XData',t_bins_fus,'YData',1:n_regions_recordings(i),'CData',YData,'Parent',ax);
                line('XData',[0 0],'YData',ax.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax);
                
                ax.XLim = [t_bins_fus(1),t_bins_fus(end)];
                ax.YLim = [.5,n_regions_recordings(i)+.5];
                ax.YDir = 'reverse';
                %     colorbar(ax,'eastoutside');
                %     ax.FontSize = cbar_fontsize;
                
                n_iqr= 3;
                data_iqr = YData(~isnan(YData));
                %     ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                ax.CLim = [-5,15];
                
            end
            
            ax.Title.String = char(label_regions(i));
            set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
            
            f_axes=[f_axes;ax];
        end
        
        pic_name = strcat(event_name,'_','Regional-Responses_All-Recordings-3');
        saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('File Saved  [%s].\n',pic_name);
        close(f);
        
        % Swarn Plots per mean and tmax
        f = figure('Units','normalized','OuterPosition',[0 0 1 1]);
        colormap(f,cmap_figure);
        Xq = 1:length(f.Colormap)/(n_regions+1):length(f.Colormap);
        f_colors = interp1(1:length(f.Colormap),f.Colormap,Xq);
        
        % ax1 = axes('Parent',f,'Position',[.05 .55 .4 .4]);
        ax1 = axes('Parent',f,'Position',[.05 .15 .9 .8]);
        ax1.Title.String = 'PeakAmplitude-Mean';
        hold(ax1,'on');
        grid(ax1,'on');
        ax1.FontSize = ax_fontsize;
        ax1.Title.FontSize = title_fontsize;
        for k=1:n_regions
            ydata1 = Q(k).valmax_mean(:);
            xdata = k*ones(size(ydata1))+rand(size(ydata1))/5;
            %             swarmchart(xdata(:),ydata1(:),'Color',f_colors(k,:),'Parent',ax1,...
            %                 'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',f_colors(k,:),'MarkerFaceAlpha',1,...
            %                 'XJitterWidth',.5,'SizeData',30);
            line('XData',xdata(:),'YData',ydata1(:),'Color',f_colors(k,:),'LineStyle','none','Parent',ax1,...
                'Marker','o','MarkerEdgeColor',f_colors(k,:),'MarkerFaceColor',f_colors(k,:),'MarkerSize',5);
            
            n_samples1 = sum(~isnan(ydata1));
            m1 = mean(ydata1,'omitnan');
            line('Xdata',k,'YData',m1,'Parent',ax1,'LineStyle','none','LineWidth',1,...
                'Marker','+','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
            line('Xdata',[k,k],'YData',[m1-std(ydata1,[],'omitnan')/sqrt(n_samples1),m1+std(ydata1,[],'omitnan')/sqrt(n_samples1)],'Parent',ax1,...
                'LineStyle','-','LineWidth',2,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',1);
            %             text(k-.25,ax1.YLim(1)+.9*(ax1.YLim(2)-ax1.YLim(1)),sprintf('%.2f',m1),'Parent',ax1);
        end
        ax1.XLim = [.5 n_regions+.5];
        ax1.YLim = [0 10];
        ax1.XTick = 1:n_regions;
        ax1.XTickLabel = label_regions;
        ax1.XTickLabelRotation = 45;
        % Intermediate save
        pic_name = strcat(event_name,'_','Regional-Responses_',ax1.Title.String);
        saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('File Saved  [%s].\n',pic_name);
        
        clf(f);
        % ax2 = axes('Parent',f,'Position',[.55 .55 .4 .4]);
        ax2 = axes('Parent',f,'Position',[.05 .15 .9 .8]);
        ax2.Title.String = 'PeakAmplitude-Median';
        hold(ax2,'on');
        grid(ax2,'on');
        ax2.FontSize = ax_fontsize;
        ax2.Title.FontSize = title_fontsize;
        for k=1:n_regions
            ydata1 = Q(k).valmax_median(:);
            xdata = k*ones(size(ydata1))+rand(size(ydata1))/5;
            %             swarmchart(xdata(:),ydata1(:),'Color',f_colors(k,:),'Parent',ax2,...
            %                 'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',f_colors(k,:),'MarkerFaceAlpha',1,...
            %                 'XJitterWidth',.5,'SizeData',30);
            line('XData',xdata(:),'YData',ydata1(:),'Color',f_colors(k,:),'LineStyle','none','Parent',ax2,...
                'Marker','o','MarkerEdgeColor',f_colors(k,:),'MarkerFaceColor',f_colors(k,:),'MarkerSize',5);
            n_samples1 = sum(~isnan(ydata1));
            m1 = mean(ydata1,'omitnan');
            line('Xdata',k,'YData',m1,'Parent',ax2,'LineStyle','none','LineWidth',1,...
                'Marker','+','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
            line('Xdata',[k,k],'YData',[m1-std(ydata1,[],'omitnan')/sqrt(n_samples1),m1+std(ydata1,[],'omitnan')/sqrt(n_samples1)],'Parent',ax2,...
                'LineStyle','-','LineWidth',2,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',1);
            %             text(k-.25,ax2.YLim(1)+.9*(ax2.YLim(2)-ax2.YLim(1)),sprintf('%.2f',m1),'Parent',ax2);
        end
        ax2.XLim = [.5 n_regions+.5];
        ax2.YLim = [0 10];
        ax2.XTick = 1:n_regions;
        ax2.XTickLabel = label_regions;
        ax2.XTickLabelRotation = 45;
        % Intermediate save
        pic_name = strcat(event_name,'_','Regional-Responses_',ax2.Title.String);
        saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('File Saved  [%s].\n',pic_name);
        
        clf(f);
        % ax3 = axes('Parent',f,'Position',[.05 .05 .4 .4]);
        ax3 = axes('Parent',f,'Position',[.05 .15 .9 .8]);
        ax3.Title.String = 'PeakTime-Mean';
        hold(ax3,'on');
        grid(ax3,'on');
        ax3.FontSize = ax_fontsize;
        ax3.Title.FontSize = title_fontsize;
        for k=1:n_regions
            ydata1 = Q(k).tmax_mean(:);
            xdata = k*ones(size(ydata1))+rand(size(ydata1))/5;
            %             swarmchart(xdata(:),ydata1(:),'Color',f_colors(k,:),'Parent',ax3,...
            %                 'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',f_colors(k,:),'MarkerFaceAlpha',1,...
            %                 'XJitterWidth',.5,'SizeData',30);
            line('XData',xdata(:),'YData',ydata1(:),'Color',f_colors(k,:),'LineStyle','none','Parent',ax3,...
                'Marker','o','MarkerEdgeColor',f_colors(k,:),'MarkerFaceColor',f_colors(k,:),'MarkerSize',5);
            n_samples1 = sum(~isnan(ydata1));
            m1 = mean(ydata1,'omitnan');
            line('Xdata',k,'YData',m1,'Parent',ax3,'LineStyle','none','LineWidth',1,...
                'Marker','+','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
            line('Xdata',[k,k],'YData',[m1-std(ydata1,[],'omitnan')/sqrt(n_samples1),m1+std(ydata1,[],'omitnan')/sqrt(n_samples1)],'Parent',ax3,...
                'LineStyle','-','LineWidth',2,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',1);
            %             text(k-.25,ax3.YLim(1)+.9*(ax3.YLim(2)-ax3.YLim(1)),sprintf('%.2f',m1),'Parent',ax3);
        end
        ax3.XLim = [.5 n_regions+.5];
        ax3.YLim = [-1 5];
        ax3.XTick = 1:n_regions;
        ax3.XTickLabel = label_regions;
        ax3.XTickLabelRotation = 45;
        % Intermediate save
        pic_name = strcat(event_name,'_','Regional-Responses_',ax3.Title.String);
        saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('File Saved  [%s].\n',pic_name);
        
        clf(f);
        % ax4 = axes('Parent',f,'Position',[.55 .05 .4 .4]);
        ax4 = axes('Parent',f,'Position',[.05 .15 .9 .8]);
        ax4.Title.String = 'PeakTime-Median';
        hold(ax4,'on');
        grid(ax4,'on');
        ax4.FontSize = ax_fontsize;
        ax4.Title.FontSize = title_fontsize;
        for k=1:n_regions
            ydata1 = Q(k).tmax_median(:);
            xdata = k*ones(size(ydata1))+rand(size(ydata1))/5;
            %             swarmchart(xdata(:),ydata1(:),'Color',f_colors(k,:),'Parent',ax4,...
            %                 'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',f_colors(k,:),'MarkerFaceAlpha',1,...
            %                 'XJitterWidth',.5,'SizeData',30);
            line('XData',xdata(:),'YData',ydata1(:),'Color',f_colors(k,:),'LineStyle','none','Parent',ax4,...
                'Marker','o','MarkerEdgeColor',f_colors(k,:),'MarkerFaceColor',f_colors(k,:),'MarkerSize',5);
            n_samples1 = sum(~isnan(ydata1));
            m1 = mean(ydata1,'omitnan');
            line('Xdata',k,'YData',m1,'Parent',ax4,'LineStyle','none','LineWidth',1,...
                'Marker','+','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
            line('Xdata',[k,k],'YData',[m1-std(ydata1,[],'omitnan')/sqrt(n_samples1),m1+std(ydata1,[],'omitnan')/sqrt(n_samples1)],'Parent',ax4,...
                'LineStyle','-','LineWidth',2,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',1);
            %             text(k-.25,ax4.YLim(1)+.9*(ax4.YLim(2)-ax4.YLim(1)),sprintf('%.2f',m1),'Parent',ax4);
        end
        ax4.XLim = [.5 n_regions+.5];
        ax4.YLim = [-1 5];
        ax4.XTick = 1:n_regions;
        ax4.XTickLabel = label_regions;
        ax4.XTickLabelRotation = 45;
        % Intermediate save
        pic_name = strcat(event_name,'_','Regional-Responses_',ax4.Title.String);
        saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('File Saved  [%s].\n',pic_name);
        
        %         pic_name = strcat(event_name,'_','Regional-Responses_MeanTimeDistributions');
        %         saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        %         fprintf('File Saved  [%s].\n',pic_name);
        close(f);
        
    end
end
end