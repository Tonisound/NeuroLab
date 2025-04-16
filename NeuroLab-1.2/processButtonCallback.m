function processButtonCallback(~,~,handles)
% 213 -- Process List Callbacks

global DIR_SAVE FILES CUR_FILE;
load('Preferences.mat','GFilt');

val = get(handles.ProcessListPopup,'Value');
str = get(handles.ProcessListPopup,'String');

switch strtrim(str(val,:))
    
    case 'Compute Normalized Movie'
        compute_normalizedmovie(FILES(CUR_FILE),handles);
        
    case 'Edit Anatomical Regions - Register Atlas'
        menuEdit_AnatRegions_Callback(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).recording,handles);
        
    case 'Convert Neuroshop Masks'
        convert_neuroshop_masks(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).recording,handles);
        
    case 'Import Anatomical Regions'
        import_regions(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).recording,handles);
    
    case 'Generate Region Groups'
        generate_region_groups(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).recording,handles);
        
    case 'Import LFP Traces'
        import_lfptraces(FILES(CUR_FILE),handles);
        
    case 'Import Intan Files'
        import_intan_files(FILES(CUR_FILE),handles);
        
    case'Import External Files'
        import_externalfiles(FILES(CUR_FILE).fullpath,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Import NEV Tracking'
        import_tracking_info(FILES(CUR_FILE),handles);

    case 'Duplicate main LFP channel'
        duplicate_main_channel(FILES(CUR_FILE),handles);
        
    case 'Divide LFP Frequency Bands'
        divide_lfp_bands(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Detect Vascular Surges'
        detect_vascular_surges(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Detect Locomotion Events'
        detect_locomotion_events(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Compute Body Speed'
        compute_body_speed(fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).dir_ext),handles);
        
    case 'Detect Sleep Events'
        detect_sleep_events(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Detect Left-Right Runs'
        detect_leftright_runs(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Detect Hippocampal Ripples'
        switch GFilt.ripple_detection_algo
            case 'detect_ripples_both.m'
                detect_ripples_both(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).dir_dat,1);
            case 'detect_hippocampal_ripples.m'
                detect_hippocampal_ripples(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).dir_dat,1);
        end

    case 'Segregate Hippocampal Ripples'
        segregate_ripple_events(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),1);

    case 'Compute Peri-Event Sequence'
        compute_peri_event_sequence(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),1);
        
    case 'Detect Early-Mid-Late Runs'
        detect_earlymidlate_runs(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Generate Time Indexes'
        generate_time_indexes(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Generate Time Groups'
        generate_time_groups(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
    
    case 'Filter LFP channels - Extract Power Envelope'
        filter_lfp_extractenvelope(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
            
    case 'Filter ACC/GYR/EMG channels - Extract Power Envelope'
        filter_accgyremg_extractenvelope(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Compute Wavelet Spectrogram'
        compute_wavelet_channels(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);

    case 'Run GLM Analysis'
        run_glm_analysis(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Export Time Tags'
        export_time_tags(FILES(CUR_FILE).fullpath,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
        
    case 'Export Image Patches'
        export_image_patches(handles,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
        
    case 'Export Anatomical Regions'
        export_regions(handles,FILES(CUR_FILE).recording);
        
    case 'Export LFP Traces (.dat)'
        export_lfptraces(handles,FILES(CUR_FILE));

    case 'Export fUS Time Series (.csv)'
        export_fus_time_series(handles,FILES(CUR_FILE));
end

end