function processButtonCallback(~,~,handles)
% 213 -- Process List Callbacks

global DIR_SAVE FILES CUR_FILE SEED_SPIKO ;
%global DIR_SAVE FILES CUR_FILE SEED SEED_REGION LAST_IM CUR_IM START_IM END_IM IM DIR_SYNT;

val = get(handles.ProcessListPopup,'Value');
str = get(handles.ProcessListPopup,'String');

switch strtrim(str(val,:))
    
    case 'Compute Normalized Movie'
        compute_normalizedmovie(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);     

    case 'Detect Vascular Surges'
        detect_vascular_surges(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Detect Left-Right Runs'
        detect_leftright_runs(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Sleep Score'
        sleep_score_analysis(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Import LFP Traces'
        import_lfptraces(FILES(CUR_FILE),handles);
        
    case 'Import Anatomical Regions'
        import_regions(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).recording,handles);
        
    case'Import External Files'
        import_externalfiles(FILES(CUR_FILE).fullpath,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
    
    case 'Export LFP bands'
        export_lfp_bands(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Convert Neuroshop Masks'
        convert_neuroshop_masks(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE),handles);
        
%     case 'Filter LFP for theta'
%         filter_lfp_theta(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);

    case 'Export Patches'
        export_patches(handles);
        
    case 'Export Anatomical Regions'
        export_regions(handles,FILES(CUR_FILE).recording);
        
    case 'Export IMO file'
        export_imofile(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),SEED_SPIKO,FILES(CUR_FILE).session);
        
        
end

end