function success = convert_neuroshop_masks(folder_name,file_recording,handles,val)
% Converting Neuroshop masks to binary file format (.U8)
% Looking for Atlas.mat in folder_name
% Storing U8 masks in dir_regions
% Uses Neuroshop txt files to get region names

global SEED_REGION;
success = false;
dir_regions = fullfile(SEED_REGION,file_recording);

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 3
    val=1;
end

% Parameters
global SEED_ATLAS;
load('Preferences.mat','GImport');
pixel_thresh = GImport.pixel_thresh;        % minimum region size (pixels);
pattern_ignore1 = GImport.pattern_ignore1;    % Ignore region starting with this pattern;
pattern_ignore2 = GImport.pattern_ignore2;    % Ignore region starting with this pattern;
test_whole = 0;                             % adding whole-reg (largest cover from Neuroshop regions)
test_erase = 0;                             % delete region folder

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
        fprintf('Binary mask importation cancelled [%s].\n',dir_regions);
        return;
    end
end

% Check for import folder
if exist(fullfile(folder_name,'Atlas.mat'),'file')
    % Loading Atlas.mat
    data_r = load(fullfile(folder_name,'Atlas.mat'));
    X = size(data_r.Mask,2);
    Y = size(data_r.Mask,1);
    z = 0;
else
    warning('No binary masks to export [%s].',folder_name);
    return;
end


% Export Parameters
region_prefix = 'NShop_';
region_suffix = sprintf('_%d_%d',X,Y);


% Getting Region Name
atlasName = strrep(data_r.AtlasName,' ','');
atlas_txt =  fullfile(SEED_ATLAS,atlasName,sprintf('%s-plate%d.txt',atlasName,data_r.xyfig));
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
        c2 = strrep(c2,'*','');
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
                warning('Several regions found under index %d. Keeping first. [%s]',i,atlas_txt);
                %fprintf('Warning: Several regions found under index %d. Keeping first. [%s]\n',i,atlas_txt);
            end
            aname = atlas_name(ind_keep(1));
            rname = {sprintf('%s%s%s.U8',region_prefix,char(aname),region_suffix)};
            region_name = [region_name;rname];
        else
            %default name
            region_name = [region_name;{sprintf('%sreg-%03d%s.U8',region_prefix.i,region_suffix)}];
        end
    end
end

% Removing duplicates
% indices to unique values in region_name
[~, ind] = unique(region_name);
duplicate_ind = setdiff(1:size(region_name,1),ind);
duplicate_value = region_name(duplicate_ind);
ind_remove = [];
for i = 1:size(duplicate_value,1)
    ind_merge = find(strcmp(region_name,duplicate_value(i))==1);
    new_mask = double(sum(all_masks(:,:,ind_merge),3)>0);
    % updating all masks
    all_masks(:,:,ind_merge(1)) = new_mask;
    ind_remove = [ind_remove;ind_merge(2:end)];
end
all_masks(:,:,ind_remove)=[];
region_name(ind_remove)=[];
region_index(ind_remove)=[];

% Removing unnamed regions
if ~isempty(pattern_ignore1)
    ind_remove1 = find(startsWith(region_name,strcat(region_prefix,pattern_ignore1))==1);
else
    ind_remove1 = [];
end
if ~isempty(pattern_ignore2)
    ind_remove2 = find(startsWith(region_name,strcat(region_prefix,pattern_ignore2))==1);
else
    ind_remove2 = [];
end
ind_remove = unique([ind_remove1;ind_remove2]);

all_masks(:,:,ind_remove)=[];
region_name(ind_remove)=[];
region_index(ind_remove)=[];

% Adding whole region if test_whole is true
if test_whole
    whole_mask = sum(all_masks,3)>0;
    [y,x]= find(whole_mask'==1);
    k = convhull(x,y);
    new_mask = double(poly2mask(y(k),x(k),size(whole_mask,1),size(whole_mask,2)));
    all_masks = cat(3,all_masks,new_mask);
    region_name = [region_name;{sprintf('Nshop_Whole-reg_%d_%d.U8',X,Y)}];
    region_index = [region_index;0];
end

% Create export folder
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

