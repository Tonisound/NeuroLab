function success = run_glm_analysis(foldername,handles,val,str_group,str_regions)
% Run GLM Analysis

success = false;
global IM DIR_STATS;

if nargin<3
    % user mode
    val = 1;
end

temp = regexp(foldername,filesep,'split');
cur_file = char(temp(end));

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

% Getting Time Groups
if exist(fullfile(foldername,'Time_Groups.mat'),'file')
    data_groups = load(fullfile(foldername,'Time_Groups.mat'));
    TimeGroups_name = data_groups.TimeGroups_name;
    TimeGroups_S = data_groups.TimeGroups_S;
else
    errordlg(sprintf('Missing File %s',fullfile(folder_name,'Time_Groups.mat')));
    return;
end

% Getting Time Tags
if exist(fullfile(foldername,'Time_Tags.mat'),'file')
    data_tags = load(fullfile(foldername,'Time_Tags.mat'));
    TimeTags = data_tags.TimeTags;
    TimeTags_images = data_tags.TimeTags_images;
else
    errordlg(sprintf('Missing File %s',fullfile(folder_name,'Time_Tags.mat')));
    return;
end

% Selecting regressors;
if val ==1
    % user mode
    [ind_regressors,ok] = listdlg('PromptString','Select Regressors','SelectionMode','multiple',...
        'ListString',TimeGroups_name,'ListSize',[300 500]);
    if isempty(ind_regressors)
        return;
    else
        all_regressors  = TimeGroups_name(ind_regressors);
    end
else
    % batch mode
    if isempty(str_group)
        all_regressors  = TimeGroups_name;
    else
        all_regressors  = TimeGroups_name(contains(TimeGroups_name,str_group));
    end
end
% all_regressors  = {'QW';'AW';'NREM';'REM-PHASIC';'REM-TONIC'};


% Buidling predictor variables
% X = NaN(length(time_ref.Y),size(all_regressors,1)+1);
X = NaN(length(time_ref.Y),size(all_regressors,1));
all_y_regressor = zeros(length(time_ref.Y),1);

for i = 1:size(all_regressors,1)
    cur_regressor = all_regressors(i);
    ind_group = find(strcmp(TimeGroups_name,cur_regressor)==1);
    S = TimeGroups_S(ind_group);
    if length(S)>1
        warning('Mutltipe TimeGroups found [%s,%s].',cur_regressor,cur_file);
        S = S(1);
    end
    y_regressor = zeros(length(time_ref.Y),1);
    for j = 1:size(S.TimeTags_images,1)
        index_start = S.TimeTags_images(j,1);
        index_end = S.TimeTags_images(j,2);
        y_regressor(index_start:index_end-1)=1;
    end
    X(:,i) = y_regressor;
    all_y_regressor = all_y_regressor+y_regressor;
end
% % adding last column
% X(:,end) = (all_y_regressor==0);

% % Removing last column
% X = X(:,1:end-1);

% Making regressors orthogonal
ind_conflicts = find(sum(X,2)>1);
if ~isempty(ind_conflicts)
    for j=1:length(ind_conflicts)
        temp = find(X(ind_conflicts(j),:)==1);
        X(ind_conflicts(j),temp(2:end))=0;
    end 
end
% Sanity Check
ind_conflicts = find(sum(X,2)>1);
if ~isempty(ind_conflicts)
    errordlg(sprintf('Non-orthogonal regressors [File: %s].',cur_file));
    return;
end

% Find mask whole
if exist(fullfile(foldername,'Sources_fUS','Whole-reg.mat'),'file')
    d = load(fullfile(foldername,'Sources_fUS','Whole-reg.mat'));
    mask_whole = d.mask;
else
    warning('Whole-reg.mat not found [File: %s].',cur_file);
    mask_whole = ones(size(IM(:,:,1)));
end

% Selecting regions
lines_regions = findobj(handles.RightAxes,'Tag','Trace_Region');
lines_groups = findobj(handles.RightAxes,'Tag','Trace_RegionGroup');
lines_all = [lines_regions ; lines_groups];
all_regions = [];
for i =1:length(lines_all)
    all_regions = [all_regions ;{lines_all(i).UserData.Name}];
end

if val ==1
    % user mode
    [ind_regions,ok] = listdlg('PromptString','Select Regions','SelectionMode','multiple',...
        'ListString',all_regions,'ListSize',[300 500]);
else
    % batch mode
    ind_regions = [];
    for i =1:length(str_regions)
        cur_region = char(str_regions(i));
        ind_regions = [ind_regions ;find(strcmp(all_regions,cur_region)==1)];
    end
    ok = true;
end

% Buidling response variables Y
Y = NaN(length(time_ref.Y),length(ind_regions));
actual_regions = [];
for i = 1:length(ind_regions)
    cur_region = char(lines_all(ind_regions(i)).UserData.Name);
    actual_regions = [actual_regions ;{cur_region}];
    y_data = lines_all(ind_regions(i)).YData(1:length_burst);
    Y(:,i) = y_data';
end

% Buidling response variables Z
Z = IM;

% Sanity check
if sum(strcmp(actual_regions,all_regions(ind_regions)))~= max(length(actual_regions),length(all_regions(ind_regions)))
    errordlg(sprintf('Error in selecting regions [File: %s].',cur_file));
    return;
end


% Restrict GLM Analysis to a given time period
% Searching Time Tags matching restrict patterns
restrict_period = 'WHOLE';
pattern_include = {'Whole-LFP'};
pattern_exclude = [];
% restrict_period = 'REM';
% pattern_include = {'REM-'};
% pattern_exclude = {'NREM-'};
ind_include = contains({TimeTags(:).Tag}',pattern_include);
if ~isempty(pattern_exclude)
    ind_exclude = contains({TimeTags(:).Tag}',pattern_exclude);
else
    ind_exclude = zeros(size(ind_include));
end
temp = ind_include.*(1-ind_exclude);
ind_restrict = find(temp==1);
% Generating index frames
index_frames_restrict = [];
for i =1:length(ind_restrict)
    index_frames_restrict = [index_frames_restrict;(TimeTags_images(ind_restrict(i),1):TimeTags_images(ind_restrict(i),2))'];
end
index_frames_restrict = unique(index_frames_restrict);

if isempty(index_frames_restrict)
    errordlg(sprintf('Restriction Period leads to empty file [Period: %s, File: %s].',restrict_period,cur_file));
    return;
end


% Restricting predictor and response variables
X = X(index_frames_restrict,:);
Y = Y(index_frames_restrict,:);
Z = Z(:,:,index_frames_restrict);


% Running GLM on regions
% fprintf('Running GLM Analysis on regions [File: %s, %d response variables, %d regressors]...',cur_file,length(ind_regions),size(all_regressors,1));
h = waitbar(0,'Running GLM Analysis on regions: 0.0 % completed.');
distr = 'normal';
regions_b = [];
regions_dev = [];
% regions_stats = [];
for j = 1:size(Y,2)
    y = Y(:,j);
%     [b,dev,stats] = glmfit(X,y,distr,'Constant','off');
    [b1,dev1,~] = glmfit(X,y,distr,'Constant','on');
    b = b1(2:end);
    dev = dev1;
    regions_b = cat(1,regions_b,b');
    regions_dev = cat(1,regions_dev,dev);
%     regions_stats = cat(1,regions_stats,stats);
    waitbar(j/size(Y,2),h,sprintf('Running GLM Analysis on regions: %.1f %% completed.',100*j/size(Y,2)));
end
close(h);


% Running GLM on pixels
% fprintf('Running GLM Analysis on pixels [File: %s, %d response variables, %d regressors]...',cur_file,length(ind_regions),size(all_regressors,1));
h = waitbar(0,'Running GLM Analysis on pixels: 0.0 % completed.');
pixels_b = NaN(size(Z,1),size(Z,2),size(X,2));
pixels_dev =  NaN(size(Z,1),size(Z,2),size(X,2)+1);
pixels_stats = struct('beta',[],'dfe',[],'sfit',[],'s',[],'estdisp',[],'covb',[],...
    'se',[],'coeffcorr',[],'t',[],'p',[],'resid',[],'residp',[],'residd',[],'resida',[],'wts',[]);
pixels_stats(size(Z,1),size(Z,2)).beta=[];

counter=0;
for i = 1:size(Z,1)
    for j = 1:size(Z,2)
        counter=counter+1;       
        if mask_whole(i,j)~=1
            continue;
        else
            y = squeeze(Z(i,j,:));
            %[b,dev,stats] = glmfit(X,y,distr,'Constant','off');
            [b1,dev1,~] = glmfit(X,y,distr,'Constant','on');
            b = b1(2:end);
            dev = dev1;
            pixels_b(i,j,:) = permute(b,[3 2 1]);
            pixels_dev(i,j) = dev;
%             pixels_stats(i,j) = stats;
        end   
        waitbar(counter/(size(Z,1)*size(Z,2)),h,sprintf('Running GLM Analysis on pixels: %.1f %% completed.',100*counter/(size(Z,1)*size(Z,2))));
    end
end
close(h);


% Save Data
fprintf('Saving GLM Data [File: %s, %d response variables, %d regressors] ...',cur_file,length(ind_regions),size(all_regressors,1));
container = fullfile(DIR_STATS,'GLM_Analysis',cur_file,restrict_period);
if ~exist(container,'dir')
    mkdir(container);
end
save(fullfile(container,'GLM_Analysis.mat'),'regions_b','regions_dev',...,'regions_stats'
    'pixels_b','pixels_dev',...,'pixels_stats'
    'restrict_period','pattern_include','pattern_exclude','index_frames_restrict',...
    'distr','actual_regions','all_regressors','X','-v7.3');
fprintf(' done.\n');

success = true;

end
