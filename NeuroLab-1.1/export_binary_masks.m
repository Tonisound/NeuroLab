function success = export_binary_masks(folder_name,F,handles,val)
% Binary Mask exportation from MATLAB folder

%global DIR_SAVE FILES CUR_FILE;
%folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab;
success = false;

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 3
    val=1;
end

% Check for import folder
pixel_thresh = 100; % minimum region size (pixels);
if exist(fullfile(F.fullpath,F.dir_fus,'Mask.mat'),'file')
    data_r = load(fullfile(F.fullpath,F.dir_fus,'Mask.mat'));
    all_binary = [];
    for i = 1:max(max(data_r.Mask(:,:,1)))
        if sum(sum(data_r.Mask(:,:,1)==i)) > pixel_thresh
            all_binary = cat(3,all_binary,data_r.Mask(:,:,1)==i);
        end
    end
else
    warning('No binary masks to export [%s].',folder_name);
    return;
end

% Create export folder
global SEED_REGION;
seed_region = fullfile(SEED_REGION,'Spikoscope_RegionArchive');
file_E = strcat(F.recording,'_spiko_region_archive');
file_R = strcat('Mask_',F.recording,'_',datestr(now,'yyyymmdd_hhMMss'));
dir_regions = fullfile(seed_region,file_E,file_R);
if ~exist(dir_regions,'dir')
    mkdir(dir_regions)
end

% Export
counter = 0;
X = size(data_r.Mask,2);
Y = size(data_r.Mask,1);
z = 0;
    
for i =1:size(all_binary,3)
    counter = counter +1;
    region_name = sprintf('fUS-Region-%03d_%d_%d.U8',counter,X,Y);
    mask = all_binary(:,:,counter);
    filename = fullfile(dir_regions,region_name);
    fileID = fopen(filename,'w');
    
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
end

fprintf('Binary masks successfully exported [%s].\n',folder_name);
success = true;

end