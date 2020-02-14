function batch_generalscript(~,~,myhandles)
% Batch Processing

%global DIR_SAVE FILES;
%val = handles.FileSelectPopup.Value;
%handles = myhandles;
load('Preferences.mat','GTraces','GImport');

h_infoPanel = 0.3;
w_infotable = 0.85;
w_col = 120;        % Column Width UItable
w_margin = 4;       % Column Width margin

f2 = figure('Units','normalized',...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'MenuBar','figure',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'Position',[.1 .1 .8 .8],...
    'PaperPositionMode','auto',...
    'Name','Batch Processing');
clrmenu(f2);
colormap('jet');

% Information Panel
iP = uipanel('Units','normalized',...
    'Position',[0 0 1 h_infoPanel],...
    'bordertype','etchedin',...
    'Tag','InfoPanel',...
    'Parent',f2);
h_button = .4/(10*h_infoPanel);
bc = uicontrol('Units','normalized',...
    'Position',[w_infotable 1-h_button 1-w_infotable h_button],...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Compute',...
    'Tag','ButtonCompute');
br = uicontrol('Units','normalized',...
    'Position',[w_infotable 1-2*h_button 1-w_infotable h_button],...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Clear',...
    'Tag','ButtonReset');

p1 = uicontrol('Units','normalized',...
    'Position',[w_infotable 1-3.25*h_button 1-w_infotable h_button],...
    'Style','popup',...
    'Parent',iP,...
    'String','Graphic_objects.mat|Graphic_objects_full.mat',...
    'TooltipString','Graphic loading format',...
    'Value',GTraces.GraphicLoadFormat_index,...
    'Tag','Popup1');
p2 = uicontrol('Units','normalized',...
    'Position',[w_infotable 1-4*h_button 1-w_infotable h_button],...
    'Style','popup',...
    'Parent',iP,...
    'TooltipString','Graphic saving format',...
    'Value',GTraces.GraphicSaveFormat_index,...
    'String','Graphic_objects.mat|Graphic_objects_full.mat|skip',...
    'Tag','Popup2');
p3 = uicontrol('Units','normalized',...
    'Position',[w_infotable 1-4.75*h_button 1-w_infotable h_button],...
    'Style','popup',...
    'Parent',iP,...
    'TooltipString','Doppler loading format',...
    'Value',GImport.Doppler_loading_index,...
    'String','Load Doppler film|Skip Doppler loading',...
    'Tag','Popup3');

ot = uitable('Units','normalized',...
    'Position',[0 0 w_infotable 1],...
    'ColumnFormat',{'char','char','char','char','char','char'},...
    'ColumnWidth',{w_col w_col w_col w_col w_col},...
    'ColumnEditable',[false,false,false,false,false],...
    'ColumnName',{'File' 'Process' 'Success' 'Failure' 'Duration'},...
    'Data',[],...
    'RowName','',...
    'Tag','Output_table',...
    'RowStriping','on',...
    'Parent',iP);
% Adjust Columns
ot.Units = 'pixels';
ot.ColumnWidth ={.35*(ot.Position(3)-w_margin),.35*(ot.Position(3)-w_margin),.1*(ot.Position(3)-w_margin),.1*(ot.Position(3)-w_margin),.1*(ot.Position(3)-w_margin)};
ot.Units = 'normalized';
%ot.Data = cellstr(sprintf('Test1\nTest2'));

% File Panel
fP = uipanel('Units','normalized',...
    'Position',[0 h_infoPanel .25 1-h_infoPanel],...
    'bordertype','etchedin',...
    'Title','Files',...
    'Tag','FilesPanel',...
    'Parent',f2);
% Process Panel
pP = uipanel('Units','normalized',...
    'Position',[.25 h_infoPanel .15 1-h_infoPanel],...
    'bordertype','etchedin',...
    'Title','Processes',...
    'Tag','ProcessPanel',...
    'Parent',f2);
% Time Groups Panel
gP = uipanel('Units','normalized',...
    'Position',[.4 h_infoPanel .15 1-h_infoPanel],...
    'bordertype','etchedin',...
    'Title','Time Groups',...
    'Tag','GroupPanel',...
    'Parent',f2);
% Time Tags Panel
tP = uipanel('Units','normalized',...
    'Position',[.55 h_infoPanel .15 1-h_infoPanel],...
    'bordertype','etchedin',...
    'Title','Time Tags',...
    'Tag','TimePanel',...
    'Parent',f2);
% Trace Region Panel
rP = uipanel('Units','normalized',...
    'Position',[.7 h_infoPanel .15 1-h_infoPanel],...
    'bordertype','etchedin',...
    'Title','Regions',...
    'Tag','RegionPanel',...
    'Parent',f2);
% Traces Spiko Panel
sP = uipanel('Units','normalized',...
    'Position',[.85 h_infoPanel .15 1-h_infoPanel],...
    'bordertype','etchedin',...
    'Title','Traces',...
    'Tag','SpikoPanel',...
    'Parent',f2);


% Files Table  
D = cellstr(myhandles.FileSelectPopup.String);
ft = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName','',...
    'ColumnFormat',{'char'},...
    'ColumnEditable',false,...
    'ColumnWidth',{w_col},...
    'Data',D,...
    'Position',[0 0 1 1],...
    'Tag','File_table',...
    'RowStriping','on',...
    'Parent',fP);
%ft.CellSelectionCallback = {@filetable_uitable_select};    
% Adjust Columns
ft.Units = 'pixels';
%ft.ColumnWidth ={.4*(ft.Position(3)-w_margin) .6*(ft.Position(3)-w_margin)};
ft.ColumnWidth ={ft.Position(3)-w_margin};
ft.Units = 'normalized';
ft.UserData.Selection = [];

% Process Table
ind_1 = ~(cellfun('isempty',strfind(cellstr(myhandles.FigureListPopup.String),'(Figure)')));
D = [{'Clear Sources_LFP'};{'Delete Region Traces'};cellstr(myhandles.ProcessListPopup.String);cellstr(myhandles.FigureListPopup.String(ind_1,:));...
    {'Import Reference Time'};{'Import Time Tags'};{'Trace Edition'};{'Time Tag Edition'};{'Time Group Edition'};{'Edit Anatomical Regions'};{'Edit LFP Configuration'}];
pt = uitable('Units','normalized',...
    'Position',[0 0 1 1],...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{w_col},...
    'ColumnEditable',false,...
    'ColumnName','',...
    'Data',D,...
    'RowName','',...
    'Tag','Process_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',pP);
% Adjust Columns
pt.Units = 'pixels';
pt.ColumnWidth ={pt.Position(3)-w_margin};
pt.Units = 'normalized';
pt.UserData.Selection = [];

% Group Table
gt = uitable('Units','normalized',...
    'Position',[0 0 1 1],...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{w_col},...
    'ColumnEditable',false,...
    'ColumnName','',...
    'Data','',...
    'RowName','',...
    'Tag','Group_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',gP);
% Adjust Columns
gt.Units = 'pixels';
gt.ColumnWidth ={gt.Position(3)-w_margin};
gt.Units = 'normalized';
gt.UserData.Selection = [];

% Tag Table
tt = uitable('Units','normalized',...
    'Position',[0 0 1 1],...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{w_col},...
    'ColumnEditable',false,...
    'ColumnName','',...
    'Data','',...
    'RowName','',...
    'Tag','Tag_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',tP);
% Adjust Columns
tt.Units = 'pixels';
tt.ColumnWidth ={tt.Position(3)-6*w_margin};
tt.Units = 'normalized';
tt.UserData.Selection = [];

% Region Table
rt = uitable('Units','normalized',...
    'Position',[0 0 1 1],...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{w_col},...
    'ColumnEditable',false,...
    'ColumnName','',...
    'Data',[],...
    'RowName','',...
    'Tag','Region_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',rP);
% Adjust Columns
rt.Units = 'pixels';
rt.ColumnWidth ={rt.Position(3)-w_margin};
rt.Units = 'normalized';
rt.UserData.Selection = [];

st = uitable('Units','normalized',...
    'Position',[0 0 1 1],...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{w_col},...
    'ColumnEditable',false,...
    'ColumnName','',...
    'Data',[],...
    'RowName','',...
    'Tag','Spiko_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',sP);
% Adjust Columns
st.Units = 'pixels';
st.ColumnWidth ={st.Position(3)-w_margin};
st.Units = 'normalized';
st.UserData.Selection = [];

handles = guihandles(f2);
bc.Callback = {@compute_Callback,handles,myhandles};
br.Callback = {@reset_Callback,handles};
p1.Callback = {@update_popup1_Callback,handles};
ft.CellSelectionCallback = {@filetable_uitable_select,handles};
update_popup1_Callback(p1,[],handles);

end

function filetable_uitable_select(hObj,evnt,handles)

global DIR_SAVE FILES;

if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
else
    hObj.UserData.Selection = [];
    handles.Group_table.UserData.Selection = [];
    handles.Tag_table.UserData.Selection = [];
    handles.Region_table.UserData.Selection = [];
    handles.Spiko_table.UserData.Selection = [];
    handles.Group_table.Data = [];
    handles.Tag_table.Data = [];
    handles.Region_table.Data = [];
    handles.Spiko_table.Data = [];
    return;
end

% Loading all Time groups
str_group = [];
for i =1:length(hObj.UserData.Selection)
    ii = hObj.UserData.Selection(i);
    if exist(fullfile(DIR_SAVE,FILES(ii).nlab,'Time_Groups.mat'),'file')
        load(fullfile(DIR_SAVE,FILES(ii).nlab,'Time_Groups.mat'),'TimeGroups_name');
        str_group = [str_group;TimeGroups_name];
    end
end

if ~isempty(str_group)
    str_group = unique(str_group);
    handles.Group_table.Data = cellstr(str_group);
end
handles.Group_table.UserData.Selection = [];

% Loading all Time Tags
str_tag = [];
for i =1:length(hObj.UserData.Selection)
    ii = hObj.UserData.Selection(i);
    if exist(fullfile(DIR_SAVE,FILES(ii).nlab,'Time_Tags.mat'),'file')
        load(fullfile(DIR_SAVE,FILES(ii).nlab,'Time_Tags.mat'),'TimeTags_cell');
        str_tag = [str_tag;TimeTags_cell(2:end,2)];
    end
end
str_tag = unique(str_tag);
handles.Tag_table.Data = cellstr(str_tag);
handles.Tag_table.UserData.Selection = [];

% update popup
update_popup1_Callback(handles.Popup1,[],handles);

end

function update_popup1_Callback(hObj,~,handles)

global DIR_SAVE FILES;
str = strtrim(hObj.String(hObj.Value,:));
rt = handles.Region_table;
st = handles.Spiko_table;
ft = handles.File_table;

if isempty(ft.UserData.Selection)
    return;
end

% Loading all Regions
% Loading all Spiko
str_regions = [];
str_spiko = [];
for i =1:length(ft.UserData.Selection)%size(FILES,2)
    ii = ft.UserData.Selection(i);
    switch str
            
        case 'Graphic_objects.mat'
            if exist(fullfile(DIR_SAVE,FILES(ii).nlab,'Trace_light.mat'),'file')
                data = load(fullfile(DIR_SAVE,FILES(ii).nlab,'Trace_light.mat'),'traces');
                ind_regions = strcmp(data.traces(:,2),'Trace_Region');
                ind_spiko = strcmp(data.traces(:,2),'Trace_Cerep');
                str_regions = [str_regions;data.traces(ind_regions,1)];
                str_spiko = [str_spiko;data.traces(ind_spiko,1)];
            end
        case 'Graphic_objects_full.mat'
            if exist(fullfile(DIR_SAVE,FILES(ii).nlab,'Trace_light.mat'),'file')
                data = load(fullfile(DIR_SAVE,FILES(ii).nlab,'Trace_light.mat'),'traces');
                ind_regions = strcmp(data.traces(:,2),'Trace_Region');
                ind_spiko = strcmp(data.traces(:,2),'Trace_Cerep');
                str_regions = [str_regions;data.traces(ind_regions,1)];
                str_spiko = [str_spiko;data.traces(ind_spiko,1)];
            end
            if exist(fullfile(DIR_SAVE,FILES(ii).nlab,'Trace_LFP.mat'),'file')
                data = load(fullfile(DIR_SAVE,FILES(ii).nlab,'Trace_LFP.mat'),'traces');
                ind_regions = strcmp(data.traces(:,2),'Trace_Region');
                ind_spiko = strcmp(data.traces(:,2),'Trace_Cerep');
                str_regions = [str_regions;data.traces(ind_regions,1)];
                str_spiko = [str_spiko;data.traces(ind_spiko,1)];
            end           
    end  
end

str_regions_unique = unique(str_regions);
occurences= zeros(size(str_regions_unique));
for i =1:size(occurences,1)
    occurences(i) = sum(strcmp(str_regions,str_regions_unique(i)));
end
[~,ind_sorted]=sort(occurences,'descend');
str_regions = str_regions_unique(ind_sorted);
str_spiko = unique(str_spiko);

w_margin = 20;
rt.Data = str_regions;
% Adjust Columns
rt.Units = 'pixels';
rt.ColumnWidth ={rt.Position(3)-w_margin};
rt.Units = 'normalized';
rt.UserData.Selection = [];

st.Data = str_spiko;
% Adjust Columns
st.Units = 'pixels';
st.ColumnWidth ={st.Position(3)-w_margin};
st.Units = 'normalized';
st.UserData.Selection = [];

end

function reset_Callback(~,~,handles)

handles.Output_table.Data = [];
%handles.File_table.UserData.Selection = [];
%handles.Process_table.UserData.Selection = [];
%handles.Group_table.UserData.Selection = [];
%handles.Tag_table.UserData.Selection = [];

end

function compute_Callback(~,~,handles,myhandles)

handles.MainFigure.Pointer = 'watch';
drawnow;

% Update Preferences.mat
load('Preferences.mat','GTraces','GImport');
        
% Flag if gload changed
if ~strcmp(strtrim(handles.Popup1.String(handles.Popup1.Value,:)),GTraces.GraphicLoadFormat)
    flag_gload = true;
else
    flag_gload = false;
end
% Update gload and gsave 
GTraces.GraphicLoadFormat = strtrim(handles.Popup1.String(handles.Popup1.Value,:));
GTraces.GraphicLoadFormat_index = handles.Popup1.Value;
GTraces.GraphicSaveFormat = strtrim(handles.Popup2.String(handles.Popup2.Value,:));
GTraces.GraphicSaveFormat_index = handles.Popup2.Value;

str = {'full';'skip'};
% Flag if Doppler loading changed
if ~strcmp(char(str(handles.Popup3.Value)),GImport.Doppler_loading)
    flag_dload = true;
else
    flag_dload = false;
end
GImport.Doppler_loading_index = handles.Popup3.Value;
GImport.Doppler_loading = char(str(handles.Popup3.Value));

% Loading graphic data or Doppler if changed
global CUR_FILE DIR_SAVE FILES;
if flag_gload
    load_graphicdata(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles);
end
if flag_dload
    load_global_image(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles.CenterPanelPopup.Value);
    actualize_plot(myhandles);
end
save('Preferences.mat','GTraces','GImport','-append');

ot = handles.Output_table;
ind_files = handles.File_table.UserData.Selection;
ind_processes = handles.Process_table.UserData.Selection;
ind_group = handles.Group_table.UserData.Selection;
ind_tag = handles.Tag_table.UserData.Selection;

if isempty(ind_files)
    ot.Data = {'No File Selected'};
    return;
end
% if isempty(ind_processes)
%     ot.Data = {'No Process Selected'};
%     return;
% end
str_group = handles.Group_table.Data(ind_group,:);
str_tag = handles.Tag_table.Data(ind_tag,:);
str_processes = handles.Process_table.Data;

% Building str_regions and str_traces
str_regions = [];
if ~isempty(handles.Region_table.UserData)
    str_regions = handles.Region_table.Data(handles.Region_table.UserData.Selection,1);
end
str_traces = [];
if ~isempty(handles.Spiko_table.UserData)
    str_traces = handles.Spiko_table.Data(handles.Spiko_table.UserData.Selection,1);
end

% Looping on files
cur_file =  myhandles.FileSelectPopup.Value;
for i = 1:length(ind_files)
    
    %File Selection
    ii=ind_files(i);
    file_name = char(myhandles.FileSelectPopup.String(ii,:));
    time_s = datestr(now,'mmmm dd, yyyy HH:MM:SS.FFF');
    fprintf('File %s started at %s \n',file_name,time_s);
    %ot.Data = [ot.Data;{file_name sprintf('Start :    %s',time_s) '' '' ''}];
    
    %File Selection
    myhandles.FileSelectPopup.Value=ii;
    fileSelectionPopup_Callback(myhandles.FileSelectPopup,[],myhandles);
    load(fullfile(DIR_SAVE,FILES(ii).nlab,'Time_Reference.mat'),'n_burst');

    % Looping on processes
    for j=1:length(ind_processes)
        jj = ind_processes(j);
        process_name = strtrim(char(str_processes(jj,:)));
        c1 = now;
        
        %try
            switch process_name
                case 'Clear Sources_LFP'
                    % Housecleaning: emptying Sources_LFP/ before saving
                    load('Preferences.mat','GTraces');
                    save_fmt = GTraces.GraphicSaveFormat;
                    success=false;
                    if strcmp(save_fmt,'Graphic_objects_full.mat')
                        disp('============== Housecleaning ==================');
                        if exist(fullfile(DIR_SAVE,FILES(ii).nlab,'Sources_LFP'),'dir')
                            delete(findobj(myhandles.RightAxes,'Tag','Trace_Cerep'));
                            rmdir(fullfile(DIR_SAVE,FILES(ii).nlab,'Sources_LFP'),'s');
                            success=true;
                        end
                    end
                    
                case 'Delete Region Traces'
                    delete(findobj(myhandles.RightAxes,'Tag','Trace_Region'));
                    success=true;
                    
                case 'Compute Normalized Movie'
                    success = compute_normalizedmovie(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles);
                        
                case 'Edit Time Groups'
                    success = menuEdit_TimeGroupEdition_Callback(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles);
                        
                case 'Import Anatomical Regions'
                    success = import_regions(fullfile(DIR_SAVE,FILES(ii).nlab),FILES(ii).recording,myhandles,0);
                    
                case 'Import Reference Time'
                    success = import_reference_time(FILES(ii),myhandles);
                
                case 'Import Time Tags'
                    success = import_time_tags(FILES(ii).fullpath,fullfile(DIR_SAVE,FILES(ii).nlab));
                    
                case 'Import LFP Traces'
                    success = import_lfptraces(FILES(CUR_FILE),myhandles,0);
                    
                case'Import External Files'
                    success = import_externalfiles(FILES(CUR_FILE).fullpath,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles,0);
                    
                case 'Detect Vascular Surges'
                    success = detect_vascular_surges(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles,0);
                    
                case 'Detect Left-Right Runs'
                    success = detect_leftright_runs(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles,0);
                        
                case 'Register Atlas'
                    success = NeuroShopStart(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles,0);
                       
                case 'Perform sleep scoring'
                    %success = sleep_score_analysis(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles,0);
                    f2 = tempSleepScoring_NeuroLab(myhandles,0);
                    
                case 'Export LFP bands'
                    % in this case 1 select band manually, else 0 for all bands
                    success = export_lfp_bands(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles,0);
                                    
                case 'Export Anatomical Regions'
                    success = export_regions(myhandles,FILES(ii).recording,0);
                    
                case 'Edit Anatomical Regions'
                    success = menuEdit_AnatRegions_Callback(FILES(ii),myhandles,0);
                    
                case 'Edit LFP Configuration'
                    success = menuEdit_LFPConfig_Callback(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles,0);
                
                case 'Convert Neuroshop Masks'
                    success = convert_neuroshop_masks(fullfile(DIR_SAVE,FILES(ii).nlab),FILES(ii),myhandles,0);
                    
                case '(Figure) Global Episode Display'
                    f2 = figure_GlobalDisplay(myhandles,0,str_tag);
                     
                case '(Figure) Correlation Analysis'
                    f2 = figure_Correlation_Analysis(myhandles,0,str_group);
                    
                case '(Figure) LFP Wavelet Analysis'
                    f2 = figure_Wavelet_Analysis(myhandles,0,str_tag);
                    
                case '(Figure) fUS Episode Statistics'
                    f2 = figure_fUS_EpisodeStatistics(myhandles,0,str_group);
                
                case '(Figure) Vascular Potentiation'
                    f2 = figure_VascularPotentiation(myhandles,0,str_group);
                    
                case '(Figure) Peak Detection'
                    f2 = figure_PeakDetection(myhandles,0,str_tag);
                    
                case '(Figure) Peri-Event Time Histogram'
                    f2 = figure_PeriEventHistogramm(myhandles,0,str_group,str_regions,str_traces);
                    
                case '(Figure) Cross-Correlation LFP-fUS'
                    f2 = figure_CrossCorrelation(myhandles,0,str_tag);
                   
                case 'Trace Edition'
                    success = menuEdit_TracesEdition_Callback([],[],myhandles.RightAxes,myhandles);
                    
                case 'Import Reference Time'
                    success = import_reference_time(FILES(ii),myhandles);
                
                case 'Import LFP Configuration'
                    success = import_lfpconfig(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles);
                    
                case 'Actualize Traces'
                    success = actualize_traces(myhandles);
                    
                case 'Time Tag Edition'
                    success = menuEdit_TimeTagEdition_Callback(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles);
                    
                case 'Time Group Edition'
                    success = menuEdit_TimeGroupEdition_Callback(fullfile(DIR_SAVE,FILES(ii).nlab),myhandles);
                    
                case 'Save UF Params'
                    success = saving_UFParams(fullfile(FILES(ii).fullpath,FILES(ii).dir_fus),fullfile(DIR_SAVE,FILES(ii).nlab));
                                    
                otherwise
                    c2 = now;
                    dur = datestr(c2-c1,'HH:MM:SS.FFF');
                    ot.Data = [ot.Data;{file_name process_name 'Unimplemented' 'Unimplemented' dur}];
                    continue;
            end
            
            % Closing figure if exists
            if exist('f2','var')
                success = f2.UserData.success;
                close(f2);
                waitfor(f2);
            end
            % Update output table
            if success
                c2 = now;
                dur = datestr(c2-c1,'HH:MM:SS.FFF');
                ot.Data = [ot.Data;{file_name process_name 'Success' '' dur}];
            else
                c2 = now;
                dur = datestr(c2-c1,'HH:MM:SS.FFF');
                ot.Data = [ot.Data;{file_name process_name '' 'Failure' dur}];
            end
%         catch
%             if exist('f2','var')
%                 close(f2);
%             end
%             c2 = now;
%             dur = datestr(c2-c1,'HH:MM:SS.FFF');
%             ot.Data = [ot.Data;{file_name process_name '' 'Catch' dur}];
%         end
    end
    
    time_e = datestr(now,'mmmm dd, yyyy HH:MM:SS.FFF'); 
    fprintf('File %s ended at %s \n',file_name,time_e);
    ot.Data = [ot.Data;{sprintf('=== Start : %s - End : %s ===',time_s,time_e) '' '' '' ''}];
end

myhandles.FileSelectPopup.Value=cur_file;
fileSelectionPopup_Callback(myhandles.FileSelectPopup,[],myhandles);

fprintf('Done !\n');
handles.MainFigure.Pointer = 'arrow';
% close(handles.MainFigure);

end