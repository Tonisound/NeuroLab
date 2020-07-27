function success = generate_region_groups(foldername,file_recording,handles,val)
% Generates Groups of regions based on file Ledger_Regions.txt

success = false;
global IM SEED_REGION SEED_ATLAS;

if nargin<4
    % user mode
    val = 1;
end

% Parameters
data_config = load(fullfile(foldername,'Config.mat'));
ledger_name = 'RegionLedger.txt';                               % ledger filename
prefix = 'Nshop_';                                              % prefix used to search region directory
% suffix = '.U8';                                               % suffix used to search region directory
suffix = sprintf('_%d_%d.U8',data_config.Y,data_config.X);      % suffix used to search region directory
main_sep = '\t';                                                % ledger file separator
empty_c2 = '-';                                                 % empty atlas symbol 
empty_c3 = '-';                                                 % empty plate symbol 
region_sep = ' ';                                               % empty plate symbol 
case_sensitive = false;                                         % Case sensitivity 


% Getting region directory
if ~exist(fullfile(SEED_REGION,file_recording),'dir')
    errordlg(sprintf('Missing Region Directory [%s]',fullfile(SEED_REGION,file_recording)));
    return;
else
    dir_regions = fullfile(SEED_REGION,file_recording);
    files_regions = dir(fullfile(dir_regions,strcat(prefix,'*',suffix)));
    %files_regions = files_regions(arrayfun(@(x) ~strcmp(x.name(1),'.'),files_regions));
    if case_sensitive
        all_regions = regexprep({files_regions(:).name}',{prefix,suffix},'');
    else
        all_regions = lower(regexprep({files_regions(:).name}',{prefix,suffix},''));
    end
end

% Getting Time Reference
if exist(fullfile(foldername,'Time_Reference.mat'),'file')
    data_tr = load(fullfile(foldername,'Time_Reference.mat'),...
        'time_ref','length_burst','n_burst','rec_mode');
    rec_mode = data_tr.rec_mode;
    time_ref = data_tr.time_ref;
    length_burst = length(time_ref.Y);
    n_burst = 1;
else
    errordlg(sprintf('Missing File %s',fullfile(folder_name,'Time_Reference.mat')));
    return;
end

% Parsing Region Ledger
ledger_txt =  fullfile(SEED_ATLAS,ledger_name);
S_ledger = parse_ledger(ledger_txt,all_regions,files_regions);

% Browse S_ledger to find flag_found = true
% Then fill region_groups structure
region_groups = struct('name',{},'mask',{},'patch_x',{},'patch_y',{},'name_regions',{},'num_regions',{});

counter = 0;
for i=1:length(S_ledger)
    if S_ledger(i).flag_found == 0
        % No regions found matching group
        continue;
    else
        if ~isempty(data_config.File.atlas_name) && ~isempty(S_ledger(i).atlas)
            % Atlas restriction
            if ~strcmp(strrep(data_config.File.atlas_name,' ',''),S_ledger(i).atlas)
                warning('Group [%s] discarded: Atlas discrepancy [%s]',S_ledger(i).name,file_recording);
                continue;
            end
        end
        if ~isempty(data_config.File.atlas_plate) && ~isempty(S_ledger(i).plates)
            % Plate restriction
            if data_config.File.atlas_plate<S_ledger(i).plates(1) || data_config.File.atlas_plate>S_ledger(i).plates(2)
                warning('Group [%s] discarded: Plate discrepancy [%s]',S_ledger(i).name,file_recording);
                continue;
            end
        end
        % Getting Name
        counter = counter+1;
        region_groups(counter).name = S_ledger(i).name;
        % Getting Mask
        all_masks = [];
        all_patch_x = [];
        all_patch_y = [];
        flag_first = 0;
        name_regions = [];
        num_regions = 0;
        for j=1:length(S_ledger(i).flag_filenames)
            if S_ledger(i).flag_filenames(j)==1
                filename = fullfile(dir_regions,char(S_ledger(i).filenames(j)));
                fileID = fopen(filename,'r');
                raw = fread(fileID,8,'uint8')';
                X = raw(8);
                Y = raw(4);
                mask = fread(fileID,[X,Y],'uint8')';
                fclose(fileID);
                all_masks = cat(3,all_masks,mask');
                % Getting Patch
                [y,x]= find(mask'==1);
                try
                    k = convhull(x,y);
                    patch_x = x(k);
                    patch_y = y(k);
                catch
                    % Problem when points are colinear
                    patch_x = x;
                    patch_y = y ;
                end
                if flag_first == 0
                    flag_first = 1;
                    first_x = x(1);
                    first_y = y(1);
                end
                all_patch_x = [all_patch_x;patch_x(:);patch_x(1);first_x];
                all_patch_y = [all_patch_y;patch_y(:);patch_y(1);first_y];
                % regions
                num_regions = num_regions+1;
                name_reg = strrep(char(S_ledger(i).filenames(j)),prefix,'');
                name_reg = strrep(name_reg,suffix,'');
                %name_regions = [name_regions;{name_reg}];
                name_regions = strcat(name_regions,name_reg,'|');
            end
        end
        all_masks = sum(all_masks,3)>0;
        region_groups(counter).mask = double(all_masks);
        region_groups(counter).patch_x = all_patch_x;
        region_groups(counter).patch_y = all_patch_y;
        region_groups(counter).num_regions = num_regions;
        region_groups(counter).name_regions = name_regions(1:end-1);
    end
end


% % Sorting by name
% pattern_list = {'ac';'s1bf';'lpta';'rs';'v2';'antcortex';'amidcortex';'pmidcortex';'postcortex';'neocortex';...
%     'dg';'ca3';'ca2';'ca1';'fc';'subiculum';'dhpc';'vhpc';...
%     'dthal';'vthal';'vpm';'po';'thalamus';'cpu';'gp';'hypothalrg'};
% 
% files_regions_sorted = [];
% for i =1:length(pattern_list)
%     pattern = strcat('_',pattern_list(i),'_');
%     ind_sort = contains(lower({files_regions(:).name}'),pattern);
%     files_regions_sorted = [files_regions_sorted;files_regions(ind_sort)];
%     files_regions(ind_sort)=[];
% end
% files_regions = [files_regions_sorted;files_regions];
% 
% 
% for i=1:length(files_regions)
%     filename = fullfile(dir_regions,files_regions(i).name);
%     fileID = fopen(filename,'r');
%     raw = fread(fileID,8,'uint8')';
%     X = raw(8);
%     Y = raw(4);
%     mask = fread(fileID,[X,Y],'uint8')';
%     fclose(fileID);
%     regions(i).name = files_regions(i).name;
%     regions(i).mask = mask';
%     
%     % Creating Patch
%     [y,x]= find(mask'==1);
%     try
%         k = convhull(x,y);
%         regions(i).patch_x = x(k);
%         regions(i).patch_y = y(k);
%     catch
%         % Problem when points are colinear
%         regions(i).patch_x = x;
%         regions(i).patch_y = y ;
%     end
% end


% Selecting Region Groups to import
ind_selected = 1:length(region_groups);
if val == 1
    % user mode
    str_group = strcat({region_groups.name}',' [',{region_groups.name_regions}',']');
    [ind_groups,ok] = listdlg('PromptString','Select Region Groups to import','SelectionMode','multiple',...
        'ListString',str_group,'InitialValue',ind_selected,'ListSize',[300 500]);
else
    % batch mode
    ok = true;
    ind_groups = ind_selected;
end

if ~ok || isempty(ind_groups)
    return;
end


% Direct Region Loading
% Gaussian window
load('Preferences.mat','GTraces','GColors');
patch_alpha = GColors.patch_transparency;
patch_width = GColors.patch_width;
patch_color = GColors.patch_color;
t_gauss = GTraces.GaussianSmoothing;
delta =  time_ref.Y(2)-time_ref.Y(1);
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);

% Choosing regions
lines = findobj(handles.RightAxes,'Tag','Trace_RegionGroup');
% getting lines name
lines_name = cell(length(lines),1);
for i =1:length(lines)
    lines_name{i} = lines(i).UserData.Name;
end
count=length(lines);

for i=1:length(ind_groups)
    
    % finding trace name
    t = char(region_groups(ind_groups(i)).name);
    str = lower(t);
    
    if sum(strcmp(t,lines_name))>0
        %line already exists overwrite
        ind_overwrite = find(strcmp(t,lines_name)==1);
        hq = lines(ind_overwrite).UserData.Graphic;
        hl = lines(ind_overwrite);
        
        % patch update
        hq.XData = region_groups(ind_groups(i)).patch_x;
        hq.YData = region_groups(ind_groups(i)).patch_y;
        % mask update
        hl.UserData.Mask = region_groups(ind_groups(i)).mask;
        % line update
        im_mask = region_groups(ind_groups(i)).mask;
        im_mask(im_mask==0)=NaN;
        im_mask = IM.*repmat(im_mask,1,1,size(IM,3));
        Y = mean(mean(im_mask,2,'omitnan'),1,'omitnan');
        Y = [reshape(Y,[length_burst,n_burst]);NaN(1,n_burst)];
        hl.YData = Y;
        fprintf('Region Group %s Successfully Updated (%d/%d).\n',t,i,length(ind_groups));
        
    else
        
        % Color counter
        count = count+1;
        
        %if contains(str,{'hpc';'ca1';'ca2';'ca3';'dg';'fc-';'subic';'lent-'})
        if contains(str,{'hpc';'ca1';'ca2';'ca3';'dg';'fc';'subic';'lent'})
            delta = 10;
        %elseif contains(str,{'thal';'vpm-';'po-';'cpu-';'gp-';'septal'})
        elseif contains(str,{'thal';'vpm';'po';'cpu-';'gp';'septal'})
            delta = 20;
        %elseif contains(str,{'cortex';'rs-';'ac';'s1';'lpta';'m12';'v1';'v2';'cg-';'cx-';'ptp'})
        elseif contains(str,{'cortex';'rs';'ac';'s1';'lpta';'m12';'v1';'v2';'cg';'cx';'ptp'})
            delta = 0;
        else
            delta = 30;
        end
        ind_color = min(delta+count,length(handles.MainFigure.Colormap));
        color = handles.MainFigure.Colormap(ind_color,:);
        %fprintf('i = %d, ind_color %d, color [%.2f %.2f %.2f]\n',i,ind_color,color(:,1),color(:,2),color(:,3));
        
        % patch creation
        hq = patch('XData',region_groups(ind_groups(i)).patch_x,...
            'YData',region_groups(ind_groups(i)).patch_y,...
            'FaceColor',color,...
            'EdgeColor',patch_color,...
            'Tag','RegionGroup',...
            'FaceAlpha',patch_alpha,...
            'LineWidth',patch_width,...
            'ButtonDownFcn',{@click_RegionFcn,handles},...
            'Visible','off',...
            'Parent',handles.CenterAxes);
        
        % mask creation
        X = [reshape(1:size(IM,3),[length_burst,n_burst]);NaN(1,n_burst)];
        im_mask = region_groups(ind_groups(i)).mask;
        im_mask(im_mask==0)=NaN;
        im_mask = IM.*repmat(im_mask,1,1,size(IM,3));
        %im_mask = IM(:,:,:).*repmat(region_groups(ind_groups(i)).mask,1,1,size(IM,3));
        %im_mask(im_mask==0)=NaN;
        Y = mean(mean(im_mask,2,'omitnan'),1,'omitnan');
        Y = [reshape(Y,[length_burst,n_burst]);NaN(1,n_burst)];
        
        % line creation
        hl = line('XData',X(:),...
            'YData',Y(:),...
            'Color',color,...
            'Tag','Trace_RegionGroup',...
            'HitTest','on',...
            'Visible','off',...
            'LineWidth',1,...
            'Parent',handles.RightAxes);
        set(hl,'ButtonDownFcn',{@click_lineFcn,handles});
        
        % Updating UserData
        s.Name = region_groups(ind_groups(i)).name;
        s.Mask = region_groups(ind_groups(i)).mask;
        s.Graphic = hq;
        s.Selected = 0;
        hq.UserData = hl;
        hl.UserData = s;
        
        fprintf('Region Group %s Successfully Imported (%d/%d).\n',t,i,length(ind_groups));
    end
    
    % Line Visibility
    str_rpopup = strtrim(handles.RightPanelPopup.String(handles.RightPanelPopup.Value,:));
    if strcmp(str_rpopup,'Region Group Dynamics')
        set(hl,'Visible','on');
    end
    
    % Gaussian smoothing
    if t_gauss>0
        %fprintf(' Smoothing constant (%.1f s)... ',t_gauss);
        y = hl.YData(1:end-1); 
        if strcmp(rec_mode,'BURST')
            % gaussian nan convolution + nan padding (only for burst_recording)
            %length_burst_smooth = 1181;
            length_burst_smooth = data_tr.length_burst;
            n_burst_smooth = length(y)/length_burst_smooth;
            y_reshape = [reshape(y,[length_burst_smooth,n_burst_smooth]);NaN(length(w),n_burst_smooth)];
            y_conv = nanconv(y_reshape(:),w,'same');
            y_reshaped = reshape(y_conv,[length_burst_smooth+length(w),n_burst_smooth]);
            y_final = reshape(y_reshaped(1:length_burst_smooth,:),[length_burst_smooth*n_burst_smooth,1]);
            hl.YData(1:end-1) = y_final';
        else
            hl.YData(1:end-1) = nanconv(y,w,'same');
        end
    end
    
end

% Checkbox Update
boxMask_Callback(handles.MaskBox,[],handles);
boxPatch_Callback(handles.PatchBox,[],handles);        
actualize_plot(handles);
success = true;

end
