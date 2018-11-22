function success = load_global_image(folder_name,index)
%Updates IM and LAST_IM depending on index

%global DIR_SAVE LAST_IM IM FILES CUR_FILE;
global IM LAST_IM CUR_IM;
tic;
success = false;

if nargin<1
    index=1;
end

load('Preferences.mat','GImport');
if strcmp(GImport.Doppler_loading,'skip')
    data_l = load(fullfile(folder_name,'Config.mat'),'Current_Image');
    IM = zeros(size(data_l.Current_Image,1),size(data_l.Current_Image,2),LAST_IM);
    IM(:,:,CUR_IM) = data_l.Current_Image;
    fprintf('Loading Doppler_film skipped : %s\n',fullfile(folder_name,'Doppler.mat'));
    return;
end

switch index
    case 1
        fprintf('Loading Doppler_film ...\n');
        data_l = load(fullfile(folder_name,'Doppler.mat'),'Doppler_film');
        fprintf('Doppler_film loaded : %s\n',fullfile(folder_name,'Doppler.mat'));
        IM = data_l.Doppler_film;
        
    case 2 
        if exist(fullfile(folder_name,'Doppler_normalized.mat'),'file')
            fprintf('Loading Doppler_normalized ...\n');
            data_l = load(fullfile(folder_name,'Doppler_normalized.mat'));
            fprintf('Doppler_normalized loaded : %s\n',fullfile(folder_name,'Doppler_normalized.mat'));
        else
            warning('Missing File Doppler_normalized : %s\n',fullfile(folder_name,'Doppler_normalized.mat'));
            return;
        end
        IM = data_l.Doppler_normalized;
    case 3
        im_diff = diff(IM,1,3);
        IM = cat(3,im_diff,im_diff(:,:,end));

end

%IM=double(IM);
%LAST_IM = size(IM,3);
success = true;
toc;

end