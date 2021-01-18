function build_atlas(AtlasType)
% Build and Save Plotable Atlas
% Requires Atlas_XXX.mat plates to be stored in folder_mat
% Requires plates.txt & RegionLedger.txt to be stored in folder_txt
% Saves PlotableAtlas in folder_mat

if nargin ==0
    AtlasType = 'RatCoronal';
end

% Seed directory where atlas plates are located 
dir_atlas = fullfile(pwd,'Quick_scripts','Build_Atlas');

% Seed directory where atlas correspondances (txt files) are located
% Plotable Atlas will be saved there
global SEED_ATLAS
dir_txt = SEED_ATLAS;
%dir_txt = '/Users/tonio/Documents/NEUROLAB/Nlab_Files/NAtlas';

switch AtlasType
    case 'RatCoronal'
        plate_name = 'RatCoronalPaxinos';
    case 'RatSagittal'
        plate_name = 'RatSagittalPaxinos';
end
folder_mat = fullfile(dir_atlas,plate_name);
folder_txt = fullfile(dir_txt,plate_name);

% Searching for Atlas plates
d = dir(fullfile(folder_mat,'Atlas*.mat'));
if isempty(d)
    errordlg(sprintf('Wrong directory. Missing Atlas.mat Plates in [%s].',folder_mat));
    return;
end

% Searching for txt files
dd = dir(fullfile(folder_txt,'*.txt'));
if isempty(dd)
    errordlg(sprintf('Wrong directory. Missing txt files in [%s].',folder_txt));
    return;
end

% Creating save directory
savedir = fullfile(dir_txt,'PlotableAtlas',plate_name);
if isdir(savedir)
    rmdir(savedir,'s');
else
    mkdir(savedir);
end

% Creating structure Atlas
Atlas = struct('xyfig',[],'line_x',[],'line_z',[],'AP',[],......
    'list_regions',[],'mask_regions',[],...
    'list_groups',[],'mask_groups',[]);

% Saving Info.mat
save(fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)),...
    'AtlasType','plate_name','folder_mat','folder_txt','savedir','-v7.3');

Atlas(length(d)).xyfig = [];
for xyfig = 1:length(d)
    % load
    plate_file = sprintf('Atlas_%03d.mat',xyfig);
    data_atlas = load(fullfile(folder_mat,plate_file));
    
    switch AtlasType
        case 'RatCoronal'
            Atlas(xyfig).AP = data_atlas.AP_mm;
        case 'RatSagittal'
            Atlas(xyfig).AP = data_atlas.ML_mm;
    end
    
    Atlas(xyfig).xyfig=data_atlas.xyfig;
    Atlas(xyfig).line_x=data_atlas.line_x;
    Atlas(xyfig).line_z=data_atlas.line_z;
    %Atlas(xyfig).Mask=data_atlas.Mask(:,:,1);
    Mask=data_atlas.Mask(:,:,1);
    
    % Adding Regions
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
        index_regions = region_id(~contains(atlas_name,'region'));
        mask_regions=[];
        for i=1:length(index_regions)
            cur_mask = double(Mask==index_regions(i));
            mask_regions=cat(3,mask_regions,cur_mask);
        end
        %Atlas(xyfig).index_regions = index_regions;
        Atlas(xyfig).mask_regions = mask_regions;    
    end
    
    % Adding bilateral regions (only for coronal atlas)
    if strcmp(AtlasType,'RatCoronal')
        list_bilateral = [];
        for i = 1:length(Atlas(xyfig).list_regions)
            temp = char(Atlas(xyfig).list_regions(i));
            if strcmp(temp(end-1:end),'-L')||strcmp(temp(end-1:end),'-R')
                list_bilateral = [list_bilateral ; {temp(1:end-2)}];
            else
                list_bilateral = [list_bilateral ; {temp}];
            end
        end
        list_bilateral=unique(list_bilateral);
        for i = 1:length(list_bilateral)
            temp1 = strcat(char(list_bilateral(i)),'-L');
            temp2 = strcat(char(list_bilateral(i)),'-R');
            ind_1 = find(strcmp(Atlas(xyfig).list_regions,temp1)==1);
            ind_2 = find(strcmp(Atlas(xyfig).list_regions,temp2)==1);
            ind_3 = [ind_1;ind_2];
            if ~isempty(ind_1) && ~isempty(ind_2)
                Atlas(xyfig).list_regions = [Atlas(xyfig).list_regions;list_bilateral(i)];
                cur_mask = [];
                for k=1:length(ind_3)
                    cur_mask=cat(3,cur_mask,Atlas(xyfig).mask_regions(:,:,ind_3(k)));
                end
                cur_mask = double(sum(cur_mask,3)>0);
                Atlas(xyfig).mask_regions = cat(3,Atlas(xyfig).mask_regions,cur_mask);
            end
        end
    end
    
    % Adding Region Groups
    region_groups = [];
    counter = 0;
    
    ledger_txt =  fullfile(dir_txt,'RegionLedger.txt');
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
            
            cur_mask = [];
            if ~isempty(ind_cmp)
                counter = counter+1;
                region_groups(counter).name = char(c1);
                region_groups(counter).list_regions = Atlas(xyfig).list_regions(ind_cmp);
                %region_groups(counter).index_regions = Atlas(xyfig).index_regions(ind_cmp);
                cur_mask = double(sum(Atlas(xyfig).mask_regions(:,:,ind_cmp),3)>0);
                
                Atlas(xyfig).list_groups = [Atlas(xyfig).list_groups;c1];
                Atlas(xyfig).mask_groups = cat(3,Atlas(xyfig).mask_groups,cur_mask);
            end
            %Atlas(xyfig).region_groups = region_groups;
        end    
        fclose(fileID);
    end
    fprintf('Atlas Plate %d/%d imported.\n',xyfig,length(d));
   
    % Saving by plate
    xyfig= Atlas(xyfig).xyfig;
    line_x= Atlas(xyfig).line_x;
    line_z= Atlas(xyfig).line_z;
    AP= Atlas(xyfig).AP;
    list_regions = Atlas(xyfig).list_regions;
    mask_regions = Atlas(xyfig).mask_regions;
    list_groups = Atlas(xyfig).list_groups;
    mask_groups = Atlas(xyfig).mask_groups;

    save(fullfile(savedir,sprintf('%s-%03d.mat',plate_name,xyfig)),...
        'xyfig','line_x','line_z','AP',...
        'list_regions','mask_regions','list_groups','mask_groups','-v7.3');
end

% Saving plotable Atlas in full
save(fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)),'Atlas','-append');
fprintf('Plotable Atlas (%d plates) saved [%s].\n',length(d),savedir);

end