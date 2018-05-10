function processButtonCallback(~,~,handles)
% 213 -- Process List Callbacks

global DIR_SAVE FILES CUR_FILE SEED SEED_REGION ;
%global DIR_SAVE FILES CUR_FILE SEED SEED_REGION LAST_IM CUR_IM START_IM END_IM IM DIR_SYNT;

val = get(handles.ProcessListPopup,'Value');
str = get(handles.ProcessListPopup,'String');

switch strtrim(str(val,:))
    
    case 'Compute Normalized Movie'
        compute_normalizedmovie(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Compute Deformation Field'
        compute_deformationfield(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Import Reference Time'
        import_reference_time(fullfile(SEED,FILES(CUR_FILE).parent,FILES(CUR_FILE).spiko),fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
    
    case 'Import Spikoscope Time Tags' 
        import_time_tags(fullfile(SEED,FILES(CUR_FILE).parent,FILES(CUR_FILE).spiko),fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Edit Time Tags'
        menuTag_TimeTagEdition_Callback(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
    
    case 'Edit Time Groups'
        menuTag_TimeGroupEdition_Callback(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);

    case 'Import Spikoscope Regions'
        import_regions(SEED_REGION,FILES(CUR_FILE).spiko,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
        load_regions(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles); 
    
    case 'Import Spikoscope Traces'
        v = import_traces(fullfile(SEED,FILES(CUR_FILE).parent,FILES(CUR_FILE).spiko),fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
        if v==1
            load_traces(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        end
    
    case 'Import Spikoscope Episodes'
        import_episodes(fullfile(SEED,FILES(CUR_FILE).parent,FILES(CUR_FILE).spiko),fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
        
    case 'Load Spikoscope Regions'
        load_regions(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
    
    case 'Load Spikoscope Traces'
        load_traces(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Detect Vascular Surges'
        detect_vascular_surges(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Edit Anatomical Regions'
        edit_patches(handles);
    
    case 'Export Anatomical Regions'
        export_patches(handles);
        
end

end