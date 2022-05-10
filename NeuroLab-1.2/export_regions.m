function success = export_regions(handles,file_recording,val)

success = false;
global SEED_REGION;

%f = hObj.Parent;
%region_table = findobj(f,'Tag','Region_table');

if nargin<3
    % user mode
    val=1;
end

if ~exist(fullfile(SEED_REGION,file_recording),'dir')
    %rmdir(fullfile(SEED_REGION,file_recording),'s');
    mkdir(fullfile(SEED_REGION,file_recording));
end

lines_regions = findobj(handles.RightAxes,'Tag','Trace_Region');
region_name = [];
for i=1:length(lines_regions)
    region_name = [region_name;{lines_regions(i).UserData.Name}];
end

% Export Selection
if val==1
    %user mode
    [ind_export,v] = listdlg('Name','Region Exportation','PromptString','Select Regions to export',...
        'SelectionMode','multiple','ListString',region_name,'InitialValue',[],'ListSize',[300 500]);
else
    % batch mode
    ind_export = 1:length(lines_regions);
    v=1;
end

% return if selection empty
if v==0 || isempty(ind_export)
    return;
end

for i=1:length(ind_export)
    p = lines_regions(ind_export(i)).UserData.Graphic;
    mask = lines_regions(ind_export(i)).UserData.Mask;
    X = size(mask,2);
    Y = size(mask,1);
    z=0;
    % Writing into file
    filename = strcat('Nshop_',lines_regions(ind_export(i)).UserData.Name,sprintf('_%d_%d.U8',X,Y));
    filename_full = fullfile(SEED_REGION,file_recording,filename);
    fileID = fopen(filename_full,'w');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,X,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,Y,'uint8');
    fwrite(fileID,mask,'uint8');
    fclose(fileID);
    fprintf('NLab region successfully exported [%s].\n',filename);
end

success = true;

end