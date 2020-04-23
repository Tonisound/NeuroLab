function processButtonCallback(~,~,handles)
% 213 -- Process List Callbacks

global DIR_SAVE FILES CUR_FILE;

val = get(handles.ProcessListPopup,'Value');
str = get(handles.ProcessListPopup,'String');

switch strtrim(str(val,:))
    
    case 'Compute Normalized Movie'
        compute_normalizedmovie(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Edit Anatomical Regions - Register Atlas'
        menuEdit_AnatRegions_Callback(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).recording,handles);
        
    case 'Convert Neuroshop Masks'
        convert_neuroshop_masks(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).recording,handles);
        
    case 'Import Anatomical Regions'
        import_regions(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).recording,handles);
        
    case 'Import LFP Traces'
        import_lfptraces(FILES(CUR_FILE),handles);
        
    case'Import External Files'
        import_externalfiles(FILES(CUR_FILE).fullpath,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);

    case 'Detect Vascular Surges'
        detect_vascular_surges(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Detect Left-Right Runs'
        detect_leftright_runs(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Generate Time Indexes'
        generate_time_indexes(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Generate Time Groups'
        generate_time_groups(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
    
    case 'Filter LFP channels - Extract Power Envelope'
        filter_lfp_extractenvelope(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
            
    case 'Filter ACC/GYR/EMG channels - Extract Power Envelope'
        filter_accgyremg_extractenvelope(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Export Patches'
        export_patches(handles);
        
    case 'Export Anatomical Regions'
        export_regions(handles,FILES(CUR_FILE).recording);
        
end

end