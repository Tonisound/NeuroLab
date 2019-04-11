function success = load_global_image(folder_name,index)
%Updates IM and LAST_IM depending on index

%global DIR_SAVE LAST_IM IM FILES CUR_FILE;
global IM LAST_IM CUR_IM;
tic;
success = false;

if nargin<1
    index=1;
end

load('Preferences.mat','GImport','GTraces');
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

% Gaussian window
load(fullfile(folder_name,'Time_Reference.mat'),'time_ref','rec_mode');
t_gauss = GTraces.GaussianSmoothing;
delta =  time_ref.Y(2)-time_ref.Y(1);
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);
% Smoothing Doopler
if t_gauss>0
    %if strcmp(rec_mode,'BURST')
    try
        for i=1:size(IM,1)
            for j=1:size(IM,2)
                y = IM(i,j,:);
                length_burst = 59;
                % length_burst = 30;
                n_burst = length(y)/length_burst;
                y_reshape = [reshape(squeeze(y),[length_burst,n_burst]);NaN(length(w),n_burst)];
                y_conv = nanconv(y_reshape(:),w,'same');
                y_reshaped = reshape(y_conv,[length_burst+length(w),n_burst]);
                y_final = reshape(y_reshaped(1:length_burst,:),[length_burst*n_burst,1]);
                IM(i,j,:) = permute(y_final,[3,2,1]);
            end
            fprintf('Smoothing Doppler [%.1f s] - %d/%d\n',t_gauss,i,size(IM,1));
        end

    %else
    catch
        for i=1:size(IM,1)
            for j=1:size(IM,2)
                y_smooth =  squeeze(IM(i,j,:));
                y_conv = nanconv(y_smooth,w,'same');
                IM(i,j,:) = permute(y_conv',[3,2,1]);
            end
        end
         fprintf('Smoothing Doppler [%.1f s] - %d/%d\n',t_gauss,i,size(IM,1));
    end
else
    fprintf('Smoothing Doppler: none.\n');
end

%IM=double(IM);
%LAST_IM = size(IM,3);
success = true;
toc;

end