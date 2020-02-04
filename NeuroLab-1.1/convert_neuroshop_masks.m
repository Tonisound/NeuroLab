function success = convert_neuroshop_masks(folder_name,F,handles,val)
% Converting Neuroshop masks to binary file format (.U8)
% Looking for Atlas.mat in dir_save/F.nlab Storing U8 masks in dir_regions
% Uses Neuroshop txt files to get region name

success = false;
global DIR_SAVE;

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 3
    val=1;
end

% Parameters
global SEED_ATLAS;
load('Preferences.mat','GImport');
pixel_thresh = GImport.pixel_thresh; % minimum region size (pixels);
test_whole = 1; %adding whole-reg (largest cover from Neuroshop regions)
test_erase = 0; %empty region folder

if val==1
    prompt = [{'Insert whole region'};{'Erase NRegion folder'}];
    dlg_title = 'Convert Options';
    num_lines = 1;
    def = [{sprintf('%d',test_whole)};{sprintf('%d',test_erase)}];
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    if ~isempty(answer)
        test_whole=str2num(answer{1});
        test_erase=str2num(answer{2});
    else
        return;
    end
end

% Check for import folder
if exist(fullfile(DIR_SAVE,F.nlab,'Atlas.mat'),'file')
    % Loading Atlas.mat
    data_r = load(fullfile(DIR_SAVE,F.nlab,'Atlas.mat'));
    X = size(data_r.Mask,2);
    Y = size(data_r.Mask,1);
    z = 0;
else
    warning('No binary masks to export [%s].',folder_name);
    return;
end

% Getting Region Name
atlas_txt =  fullfile(SEED_ATLAS,data_r.AtlasName,sprintf('f%d.txt',data_r.FigName));
region_id = [];
atlas_name = [];
if exist(atlas_txt,'file')
    fileID = fopen(atlas_txt);
    %channel_type = [];
    while ~feof(fileID)
        hline = fgetl(fileID);
        cline = regexp(hline,'\t','split');
        c1 = strtrim(cline(1));
        c2 = strtrim(cline(2));
        c2 = strrep(c2,'_','-');
        %c3 = strtrim(cline(3));
        region_id = [region_id;eval(char(c1))];
        atlas_name = [atlas_name;c2];
        %channel_type = [channel_type;c3];
    end
    fclose(fileID);
end


% Creating binary masks
all_masks = [];
region_name = [];
region_index = [];
for i = 1:max(max(data_r.Mask(:,:,1)))
    if sum(sum(data_r.Mask(:,:,1)==i)) > pixel_thresh
        all_masks = cat(3,all_masks,data_r.Mask(:,:,1)==i);
        region_index = [region_index;i];
        
        ind_keep = find(region_id==i);
        if ~isempty(ind_keep)
            %atlas name
            if length(ind_keep)>1
                ind_keep = ind_keep(1);
                %warning('Several regions found under index %d. Keeping first. [%s]',i,atlas_txt);
                fprintf('Warning: Several regions found under index %d. Keeping first. [%s]\n',i,atlas_txt);
            end
            aname = atlas_name(ind_keep(1));
            rname = {sprintf('Nshop-reg_%s_%d_%d.U8',char(aname),X,Y)};
            region_name = [region_name;rname];
        else
            %default name
            region_name = [region_name;{sprintf('Nshop-reg_reg-%03d_%d_%d.U8',i,X,Y)}];
        end
    end
end

% Adding whole region if test_whole is true
if test_whole
    whole_mask = sum(all_masks,3)>0;
    [y,x]= find(whole_mask'==1);
    k = convhull(x,y);
    new_mask = double(poly2mask(y(k),x(k),size(whole_mask,1),size(whole_mask,2)));
    all_masks = cat(3,all_masks,new_mask);
    region_name = [region_name;{sprintf('Nshop-reg_Whole-reg_%d_%d.U8',X,Y)}];
    region_index = [region_index;0];
end

% Create export folder
global SEED_REGION;
dir_regions = fullfile(SEED_REGION,F.recording);
if test_erase && exist(dir_regions,'dir')
    rmdir(dir_regions,'s')
end
if ~exist(dir_regions,'dir')
    mkdir(dir_regions)
end

% Export to binary format
for i =1:size(all_masks,3)
    
    mask = all_masks(:,:,i);
    filename = fullfile(dir_regions,char(region_name(i)));
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

fprintf('Binary masks successfully imported [%s].\n',dir_regions);
success = true;

end

