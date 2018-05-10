function success = import_regions(seed_region,spikodir,dir_save)
% Searches SEED_REGION directory for file 'spiko_dir'_region_archive/Mask*
% Select most recent Mask directory and extracts name, mask and patch for
% each region

success = false;
dir_regions = dir(sprintf('%s_region_archive/Mask*',fullfile(seed_region,spikodir)));
dir_regions = fullfile(seed_region,strcat(spikodir,'_region_archive'),dir_regions(end).name);
files_regions = dir(fullfile(dir_regions,'*.U8'));

if isempty(files_regions)
    return;
end
regions = struct('name',{},'mask',{},'patch_x',{},'patch_y',{});

%Sorting by datenum
S = [files_regions(:).datenum];
[~,ind] = sort(S);
files_regions = files_regions(ind);

for i=1:length(files_regions)
    filename = fullfile(dir_regions,files_regions(i).name);
    fileID = fopen(filename,'r');
    raw = fread(fileID,8,'uint8')';
    X = raw(8);
    Y = raw(4);
    mask = fread(fileID,[X,Y],'uint8')';
    fclose(fileID);
    regions(i).name = files_regions(i).name;
    regions(i).mask = mask';
    
    % Creating Patch
    [y,x]= find(mask'==1);
    try
        k = convhull(x,y);
        regions(i).patch_x = x(k);
        regions(i).patch_y = y(k);
    catch
        % Problem when points are colinear
        regions(i).patch_x = x;
        regions(i).patch_y = y ;
    end
end

% Removing largest prefix and suffix from regions.name
C = permute(struct2cell(regions),[3,1,2]);
C = C(:,1);
C = regexprep(C,'_','-');
prefix = largest_prefix(C);
suffix = largest_suffix(C);

for i=1:length(files_regions)
    %root = regexp(char(C(i)),prefix,'split');
    %root = regexp(char(root(2)),suffix,'split');
    root=char(C(i));
    regions(i).name = root(length(prefix)+1:end-length(suffix));
end

% Saving Regions
save(fullfile(dir_save,'Spikoscope_Regions.mat'),'X','Y','regions');
fprintf('Spikoscope Regions Imported (%s) \n===> Saved in %s\n',dir_regions,fullfile(dir_save,'Spikoscope_Regions.mat'));
success = true;

end

function pattern = largest_prefix(C)
pattern = char(C(1,1));
%while length(pattern)>1 && length(cell2mat(regexp(C,pattern)))<length(C)
%    pattern = pattern(1:end-1);
%end
cur=1;
while length(pattern)>1 && cur<length(C)
    if isempty(strfind(char(C(cur,1)),pattern))
        pattern = pattern(1:end-1);
    else
        cur = cur+1;
    end
end
end

function pattern = largest_suffix(C)
Pattern = char(C(1,1));
pattern = Pattern(end);
while length(pattern)<length(Pattern) && length(cell2mat(regexp(C,pattern)))>=length(C)
    pattern = Pattern(end-length(pattern):end);
end
pattern = pattern(2:end);
end