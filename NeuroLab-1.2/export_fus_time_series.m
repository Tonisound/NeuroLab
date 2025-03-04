function success = export_fus_time_series(handles,F,val) 
% Export fUS Time Series to .csv file

success = false;
%load('Preferences.mat','GImport','GFilt');

global DIR_SAVE IM;
dir_save = fullfile(DIR_SAVE,F.nlab);

% Loading Time Reference
if exist(fullfile(dir_save,'Time_Reference.mat'),'file')
    data_tr = load(fullfile(dir_save,'Time_Reference.mat'),'time_ref','time_str');
else
    errordlg('File Time_Reference.mat not found.');
    return;
end

% Manual mode val = 1; batch mode val =0
if nargin<3
    val=1;
end

flag_pixels = true;
flag_regions = true;
flag_voxels = false;
folder_export = fullfile(dir_save,'Export');

if val==1
    % asks confirmation in user mode
    prompt = [{'Export pixels and boxes'};{'Export regions and groups'};{'Export raw fUS voxels'};{'Saving Folder'}];
    dlg_title = 'Export Options';
    dims = [1,150];
    def = [{sprintf('%d',flag_pixels)};{sprintf('%d',flag_regions)};{sprintf('%d',flag_voxels)};{sprintf('%s',folder_export)}];
    answer = inputdlg(prompt,dlg_title,dims,def);
    
    if ~isempty(answer)
        flag_pixels = str2num(answer{1});
        flag_regions = str2num(answer{2});
        flag_voxels = str2num(answer{3});
        folder_export = char(answer{4});
    else
        fprintf('Time Series exportation cancelled [%s].\n',folder_export);
        return;
    end
end


% Loading Pixels and Boxes
if flag_pixels
    all_obj = findobj(handles.CenterAxes,'Tag','Pixel','-or','Tag','Box');
    all_names = [];
    all_ydata = [];
    
    for i = 1:length(all_obj)
        this_ydata = all_obj(i).UserData.YData(:);
        this_name = all_obj(i).UserData.UserData.Name;
        all_ydata = [all_ydata,this_ydata];
        all_names = [all_names,{this_name}];
    end

    % file export
    filename = strcat(strrep(sprintf('[%s]',datetime),':','-'),'Pixels-Boxes','.csv');
    file_txt = fullfile(folder_export,filename); 
    
    if ~isfolder(folder_export)
        mkdir(folder_export);
    end

    fid_w = fopen(file_txt,'w');
    fwrite(fid_w,sprintf('<im_id>,<im_time(s)>'));
    for k = 1:length(all_names)
        fwrite(fid_w,sprintf(',%s',char(all_names(k))));
    end
    fwrite(fid_w,newline);
    for i=1:length(data_tr.time_ref.X)
        fwrite(fid_w,sprintf('%d,%.3f',data_tr.time_ref.X(i),data_tr.time_ref.Y(i)));
        for k = 1:length(all_names)
            fwrite(fid_w,sprintf(',%.3f',all_ydata(i,k)));
        end
        fwrite(fid_w,newline);
    end
    fclose(fid_w);
    fprintf('fUS Time Series Exportation successful [%s].\n',file_txt);
end


% Loading Regions and Groups
if flag_regions
    all_obj = findobj(handles.CenterAxes,'Tag','Region','-or','Tag','RegionGroup');
    all_names = [];
    all_ydata = [];
    
    for i = 1:length(all_obj)
        this_ydata = all_obj(i).UserData.YData(:);
        this_name = all_obj(i).UserData.UserData.Name;
        all_ydata = [all_ydata,this_ydata];
        all_names = [all_names,{this_name}];
    end

    % file export
    filename = strcat(strrep(sprintf('[%s]',datetime),':','-'),'Regions-Groups','.csv');
    file_txt = fullfile(folder_export,filename); 
    
    if ~isfolder(folder_export)
        mkdir(folder_export);
    end

    fid_w = fopen(file_txt,'w');
    fwrite(fid_w,sprintf('<im_id>,<im_time(s)>'));
    for k = 1:length(all_names)
        fwrite(fid_w,sprintf(',%s',char(all_names(k))));
    end
    fwrite(fid_w,newline);
    for i=1:length(data_tr.time_ref.X)
        fwrite(fid_w,sprintf('%d,%.3f',data_tr.time_ref.X(i),data_tr.time_ref.Y(i)));
        for k = 1:length(all_names)
            fwrite(fid_w,sprintf(',%.3f',all_ydata(i,k)));
        end
        fwrite(fid_w,newline);
    end
    fclose(fid_w);
    fprintf('fUS Time Series Exportation successful [%s].\n',file_txt);
end


% Loading all voxels
step_voxel = 10;
% precision = '%.3f'

if flag_voxels
    all_names = [];
    all_ydata = [];
    
    for i = 1:step_voxel:size(IM,1)
        for j = 1:step_voxel:size(IM,2)
            this_ydata = squeeze(IM(i,j,:));
            this_name = sprintf('Voxel(%d-%d)',i,j);
            all_ydata = [all_ydata,this_ydata];
            all_names = [all_names,{this_name}];
        end
    end

    % file export
    filename = strcat(strrep(sprintf('[%s]',datetime),':','-'),'All-Voxels','.csv');
    file_txt = fullfile(folder_export,filename); 
    
    if ~isfolder(folder_export)
        mkdir(folder_export);
    end

    fid_w = fopen(file_txt,'w');
    fwrite(fid_w,sprintf('<im_id>,<im_time(s)>'));
    for k = 1:length(all_names)
        fwrite(fid_w,sprintf(',%s',char(all_names(k))));
    end
    fwrite(fid_w,newline);
    for i=1:length(data_tr.time_ref.X)
        fwrite(fid_w,sprintf('%d,%.3f',data_tr.time_ref.X(i),data_tr.time_ref.Y(i)));
        for k = 1:length(all_names)
            fwrite(fid_w,sprintf(',%.3f',all_ydata(i,k)));
        end
        fwrite(fid_w,newline);
    end
    fclose(fid_w);
    fprintf('fUS Time Series Exportation successful [%s].\n',file_txt);
end


success = true;

end
