% Export files for Jehanne Lafargue TINS project
function main_export_files_TINS()

    % Files to export
    path_in = '/Users/tonio/Documents/Antoine-fUSDataset/NEUROLAB/NLab_DATA';
    path_out = '/Users/tonio/Desktop/Stage Jehanne TINS/Data Jehanne';
%     filenames = {'20240812_K1653_001_E_nlab';'20240812_K1653_002_E_nlab';'20240813_K1653_001_E_nlab'};
    filenames = {'20240814_K1653_001_E_nlab';'20240819_K1653_001_E_nlab';'20240820_K1656_001_E_nlab';'20240820_K1657_001_E_nlab'};
    
    for i =1:length(filenames)
        filename_in = fullfile(path_in,filenames{i});
        export_files_TINS(filename_in,path_out);
    end

end

function execute_this_first()

    % Run Generate Time Indexes first
    global DIR_SAVE FILES CUR_FILE;
    l = findobj(myhandles.RightAxes,'Tag','Trace_Cerep');
    for i =1:length(l)
        if strcmp(l(i).UserData.Name,'Index-NREM')
            X = l(i).XData(1:end);
            Y = l(i).YData(1:end);
            save(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Index-NREM.mat'),'X','Y','-v7.3');
        end
    end
    % Select Pixel Noise manually first
    l = findobj(myhandles.RightAxes,'Tag','Trace_Pixel');
    X = l.XData(1:end-1);
    Y = l.YData(1:end-1);
    save(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Pixel_Noise.mat'),'X','Y','-v7.3');
    % Generate Whole-reg.mat first
    l = findobj(myhandles.CenterAxes,'Tag','Region');
    for i =1:length(l)
        if strcmp(l(i).UserData.UserData.Name,'Whole-reg')
            whole_mask = l(i).UserData.UserData.Mask;
            save(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Mask.mat'),'whole_mask','-v7.3');
        end
    end

end

function export_masks_Jehanne()

global  FILES CUR_FILE;

l1 = findobj(myhandles.CenterAxes,'Tag','Region');
l2 = findobj(myhandles.CenterAxes,'Tag','RegionGroup');
l = [l1;l2];

export_folder = fullfile('/Users/tonio/Desktop/Stage Jehanne TINS/Masks Jehanne',strrep(FILES(CUR_FILE).nlab,'_nlab',''));

if isfolder(export_folder)
    rmdir(export_folder,'s');
end
mkdir(export_folder,'s');

for i =1:length(l)
    filename = l(i).UserData.UserData.Name;
    mask = l(i).UserData.UserData.Mask;
    save(fullfile(export_folder,filename),'mask','-v7.3');
    fprintf('File [%s] saved at [%s],\n',filename,export_folder);
end

end

function export_files_TINS(folder_in,path_out)
    
    [~,filename,~]=fileparts(folder_in);
    filename_out = strrep(filename,'_nlab','');

    % Exportation start
    tic;
    fprintf("============== File Exportation: [%s] -> [%s] ==============\n",filename,path_out);
    
    % Create folder_out
    folder_out = fullfile(path_out,filename_out);
    if isfolder(folder_out)
        rmdir(folder_out,'s');
    end
    mkdir(folder_out);

    % Doppler.mat
    doppler_file = fullfile(folder_in,'Doppler.mat');
    if isfile(doppler_file)
        copyfile(doppler_file,folder_out);
        fprintf("Doppler file exported.\n");
    else
        warning("Doppler file not found.");
    end

    % Atlas.mat
    atlas_file = fullfile(folder_in,'Atlas.mat');
    if isfile(atlas_file)
        copyfile(atlas_file,folder_out);
        fprintf("Atlas file exported.\n");
    else
        warning("Atlas file not found.");
    end

    % Time_Reference.mat
    timeref_file = fullfile(folder_in,'Time_Reference.mat');
    if isfile(timeref_file)
        copyfile(timeref_file,folder_out);
        fprintf("Time_Reference file exported.\n");
    else
        warning("Time_Reference file not found.");
    end

    % LFP traces
    folder_lfp_out = fullfile(folder_out,'LFP');
    lfp_folder = fullfile(folder_in,'Sources_LFP');
    d_lfp = dir(fullfile(lfp_folder,'LFP_*.mat'));
    mkdir(folder_lfp_out);
    for i=1:length(d_lfp)
        lfp_file = fullfile(d_lfp(i).folder,d_lfp(i).name);
        if ~strcmp(d_lfp(i).name,"LFP_999.mat")
            copyfile(lfp_file,folder_lfp_out);
            fprintf("LFP channel exported [%s].\n",d_lfp(i).name);
        end
    end
    % LFP ripple
    data_config = load(fullfile(folder_in,'Config.mat'));
    ripple_file = fullfile(lfp_folder,sprintf("LFP-ripple_%s.mat",data_config.File.mainlfp));
    if isfile(ripple_file)
        copyfile(ripple_file,folder_lfp_out);
        fprintf("Ripple channel exported [%s].\n",sprintf("LFP-ripple_%s.mat",data_config.File.mainlfp));
    else
        warning("Ripple channel not found.");
    end
    % NConfig file
    ncf_file = fullfile(folder_in,'NConfig.mat');
    if isfile(ncf_file)
        copyfile(ncf_file,folder_lfp_out);
        fprintf("NConfig file exported.\n");
    else
        warning("NConfig file not found.");
    end
    
    % Events
    folder_event_out = fullfile(folder_out,'Events');
    mkdir(folder_event_out);
    event_folder = fullfile(folder_in,'Events');
    d_evt = dir(fullfile(event_folder,'[NREM]*.csv'));

    for i=1:length(d_evt)
        evt_file = fullfile(d_evt(i).folder,d_evt(i).name);
        copyfile(evt_file,folder_event_out);
        fprintf("CSV file exported [%s].\n",d_evt(i).name);
    end

    % PeriEvent file
    % Run Compute Peri Event Sequence
    perievent_folder = fullfile('/Users/tonio/Documents/Antoine-fUSDataset/NEUROLAB/NLab_Statistics/PeriEvent_Sequence',filename);
    perievent_file = '[NREM]Ripples-Merged-All_PeriEvent_AllEvents_normalized.mat';
    if isfile(fullfile(perievent_folder,perievent_file))
        copyfile(fullfile(perievent_folder,perievent_file),folder_out);
        fprintf("PeriEvent file exported.\n");
    else
        warning("PeriEvent file not found.");
    end
    perievent_file = '[NREM]Ripples-Merged-All_PeriEvent_AllEvents_raw.mat';
    if isfile(fullfile(perievent_folder,perievent_file))
        copyfile(fullfile(perievent_folder,perievent_file),folder_out);
        fprintf("PeriEvent file exported.\n");
    else
        warning("PeriEvent file not found.");
    end
    
    % Index NREM
    index_file = fullfile(folder_in,'Index-NREM.mat');
    if isfile(index_file)
        copyfile(index_file,folder_out);
        fprintf("Index-NREM.mat file exported.\n");
    else
        warning("Index-NREM.mat file not found.");
    end

    % Pixel Noise
    pixel_file = fullfile(folder_in,'Pixel_Noise.mat');
    if isfile(pixel_file)
        copyfile(pixel_file,folder_out);
        fprintf("Pixel_Noise.mat file exported.\n");
    else
        warning("Pixel_Noise.mat file not found.");
    end
    
    % Mask.mat
    mask_file = fullfile(folder_in,'Mask.mat');
    if isfile(mask_file)
        copyfile(mask_file,folder_out);
        fprintf("Mask.mat file exported.\n");
    else
        warning("Mask.mat file not found.");
    end

%    % Exportation end
%    fprintf("File Exportation done: [%s] -> [%s].\n",filename,path_out);
    toc;

end


