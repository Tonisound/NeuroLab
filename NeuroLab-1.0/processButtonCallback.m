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
            
    case 'Filter LFP for theta'
        filter_lfp_theta(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
%     case 'Edit Time Tags'
%         menuEdit_TimeTagEdition_Callback(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
%     
%     case 'Edit Time Groups'
%         menuEdit_TimeGroupEdition_Callback(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
%         
%     case 'Load Spikoscope Regions'
%         load_regions(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
%     
%     case 'Load Cereplex Traces'
%         load_lfptraces(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Detect Vascular Surges'
        detect_vascular_surges(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
        
    case 'Edit Anatomical Regions'
        edit_patches(handles);
    
    case 'Export Anatomical Regions'
        export_patches(handles);
        
end

end