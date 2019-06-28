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
binary_count = [];
if exist(fullfile(F.fullpath,F.dir_fus,'Mask.mat'),'file')
    data_r = load(fullfile(F.fullpath,F.dir_fus,'Mask.mat'));
    all_binary = [];
    for i = 1:max(max(data_r.Mask(:,:,1)))
        if sum(sum(data_r.Mask(:,:,1)==i)) > pixel_thresh
            all_binary = cat(3,all_binary,data_r.Mask(:,:,1)==i);
            binary_count = [binary_count,i];
        end
    end
else
    warning('No binary masks to export [%s].',folder_name);
    return;
end

% Adding whole region
whole_mask = sum(all_binary,3)>0;
[y,x]= find(whole_mask'==1);
k = convhull(x,y);
new_mask = double(poly2mask(y(k),x(k),size(whole_mask,1),size(whole_mask,2)));
binary_count = [binary_count,0];
all_binary = cat(3,all_binary,new_mask);

% Create export folder
global SEED_REGION;
% seed_region = fullfile(SEED_REGION,'Spikoscope_RegionArchive');
% file_E = strcat(F.recording,'_spiko_region_archive');
% file_R = strcat('Mask_',F.recording,'_',datestr(now,'yyyymmdd_hhMMss'));
% dir_regions = fullfile(seed_region,file_E,file_R);
dir_regions = fullfile(SEED_REGION,F.recording);
if ~exist(dir_regions,'dir')
    mkdir(dir_regions)
end

% Export
X = size(data_r.Mask,2);
Y = size(data_r.Mask,1);
z = 0;

for i =1:size(all_binary,3)
    %region_name = sprintf('fUS-Region-%03d_%d_%d.U8',i,X,Y);
    region_name = assign_name(binary_count(i),X,Y);
    mask = all_binary(:,:,i);
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

% fprintf('Binary masks successfully exported [%s].\n',folder_name);
fprintf('Binary masks successfully exported [%s].\n',dir_regions);
success = true;

end

function name = assign_name(counter,X,Y)

switch counter
    case 0
        region = 'Whole-reg';
    case 2
        region = 'S1J-L';
    case 6
        region = 'S1FL-L';
    case 8
        region = 'AIV-L';
    case 10
        region = 'M1-L';
    case 16
        region = 'fmi-L';
    case 20
        region = 'CPu-L';
    case 23
        region = 'AcbC-L';
    case 27
        region = 'M2-L';
    case 29
        region = 'Cg1-L';
    case 33
        region = 'Cg2-L';
    case 52
        region = 'Cg1-R';
    case 53
        region = 'Cg2-R';
    case 62
        region = 'M2-R';
    case 71
        region = 'fmi-R';
    case 77
        region = 'AcbC-R';
    case 78
        region = 'CPu-R';
    case 84
        region = 'M1-R';
    case 90
        region = 'AIV-R';
    case 91
        region = 'S1FL-R';
    case 96
        region = 'S1J-R';
    otherwise
        region = sprintf('%03d',counter);
end
name = sprintf('fUS-Region-%s_%d_%d.U8',region,X,Y);
end