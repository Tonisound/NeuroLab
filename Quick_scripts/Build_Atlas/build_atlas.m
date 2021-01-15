function build_atlas(AtlasType)
% Build Atlas
% Requires Atlas.mat plates to be stored in folder_mat
% Requires plates.txt to be stored in folder_txt
% Uses RegionLedger.txt and RatCoronalPaxinos-plateXX.txt files

if nargin ==0
    AtlasType = 'RatCoronal';
end

% Adding path
folder_atlas = '/Users/tonio/Documents/MATLAB/NeuroLab/Quick_scripts/Build_Atlas';
%addpath(genpath(folder_atlas));

switch AtlasType
    case 'RatCoronal'
        folder_mat = fullfile(folder_atlas,'RatCoronal');
        folder_txt = fullfile(folder_atlas,'NAtlas','RatCoronalPaxinos');
        plate_name = 'RatCoronalPaxinos';
    case 'RatSagittal'
        folder_mat = fullfile(folder_atlas,'RatSagittal');
        folder_txt = fullfile(folder_atlas,'NAtlas','RatSagittalPaxinos');
        plate_name = 'RatSagittalPaxinos';
end

Atlas = struct('xyfig',[],'line_x',[],'line_z',[],'Mask',[],...
    'list_regions',[],'index_regions',[],'region_groups',[]);

d = dir(fullfile(folder_mat,'Atlas*.mat'));
for xyfig = 1:length(d)
    % load
    plate_file = sprintf('Atlas_%03d.mat',xyfig);
    data_atlas = load(fullfile(folder_mat,plate_file));
    
    Atlas(xyfig).xyfig=data_atlas.xyfig;
    Atlas(xyfig).line_x=data_atlas.line_x;
    Atlas(xyfig).line_z=data_atlas.line_z;
    Atlas(xyfig).Mask=data_atlas.Mask(:,:,1);
    
    % Getting Region Name
    atlas_txt =  fullfile(folder_txt,sprintf('%s-plate%d.txt',plate_name,xyfig));
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
        Atlas(xyfig).list_regions = atlas_name(~contains(atlas_name,'region'));
        Atlas(xyfig).index_regions = region_id(~contains(atlas_name,'region'));
    end
    
    % Getting Region Ledger
    region_groups = [];
    counter = 0;
    
    ledger_txt =  fullfile(folder_atlas,'NAtlas','RegionLedger.txt');
    if exist(ledger_txt,'file')
        fileID = fopen(ledger_txt);
        %header
        fgetl(fileID);
        while ~feof(fileID)
            hline = fgetl(fileID);
            cline = regexp(hline,'\t','split');
            c1 = strtrim(cline(1));
            c2 = strtrim(cline(2));
%             % Atlas restriction
%             if ~strcmp(c2,'-') ~strcmp(c2,plate_name);
%                 continue;
%             end
%             % Plate restriction
            c3 = strtrim(cline(3));
%             if ~strcmp(c3,'-')
%                 temp = regexp(char(c3),'-','split');
%                 if xyfig<str2double(char(temp(1))) || xyfig>str2double(char(temp(2)))$
%                     continue;
%                 end
%             end   
            c4 = strtrim(cline(4));
            temp = regexp(char(c4),' ','split')';
            
            ind_cmp = [];
            for i =1:length(temp)
                ind_cmp = [ind_cmp;find(strcmp(Atlas(xyfig).list_regions,temp(i))==1)];
            end
            
            if ~isempty(ind_cmp)
                counter = counter+1;
                region_groups(counter).name = c1;
                region_groups(counter).list_regions = Atlas(xyfig).list_regions(ind_cmp);
                region_groups(counter).index_regions = Atlas(xyfig).index_regions(ind_cmp);
            end
        
            Atlas(xyfig).region_groups = region_groups;
        end
        
        fclose(fileID);
    end
end

% Saving plotable Atlas
save(fullfile(folder_atlas,sprintf('PlotableAtlas_%s.mat',plate_name)),'Atlas','AtlasType',...
    'folder_mat','folder_txt','plate_name','-v7.3');
fprintf('Plotable Atlas (%d plates) saved [%s].\n',length(d),folder_atlas);
end