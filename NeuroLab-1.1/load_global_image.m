function success = load_global_image(F,str_popup,flag_hard)
% Updates IM and LAST_IM depending on index
% if flag_hard, perform hard loading from acq file
% else reload Doppler.mat

%str_popup = strtrim(handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:));
str_popup = strtrim(str_popup);

%global DIR_SAVE LAST_IM IM FILES CUR_FILE;
global SEED DIR_SAVE IM LAST_IM CUR_IM;
folder_name = fullfile(DIR_SAVE,F.nlab);

tic;
success = false;

% if flag_hard not specified, set to false
if nargin<3
    flag_hard = false;
end

% Testing if 
load('Preferences.mat','GImport','GTraces');
if strcmp(GImport.Doppler_loading,'skip')
    data_l = load(fullfile(folder_name,'Config.mat'),'Current_Image');
    IM = zeros(size(data_l.Current_Image,1),size(data_l.Current_Image,2),LAST_IM);
    IM(:,:,CUR_IM) = data_l.Current_Image;
    fprintf('Loading Doppler_film skipped : %s\n',fullfile(folder_name,'Doppler.mat'));
    return;
end

% Loading Doppler_type
dd = load(fullfile(folder_name,'Doppler.mat'),'Doppler_type');

if strcmp(str_popup,dd.Doppler_type) && ~flag_hard
    % Directly loading Doppler.mat
    fprintf('Loading Doppler_film [%s] ...',fullfile(folder_name,'Doppler.mat'));
    dd = load(fullfile(folder_name,'Doppler.mat'),'Doppler_film');
    fprintf(' done.\n');
    IM = dd.Doppler_film;
else
    % Re-computing from acq file
    switch str_popup
        case {'Doppler_source','Doppler_normalized','Doppler_dB'}
            % Loading Doppler.mat from acq file
            if ~isempty(F.acq)
                file_acq = fullfile(SEED,F.parent,F.session,F.recording,F.dir_fus,F.acq);
                fprintf('Loading Doppler_film [%s] ...',F.acq);
                if contains(F.acq,'.acq')
                    % case file_acq ends .acq (Verasonics)
                    data = load(file_acq,'-mat');
                    Doppler_film = permute(data.Acquisition.Data,[3,1,4,2]);
                elseif contains(F.acq,'.mat')
                    % case file_acq ends .mat (Aixplorer)
                    data = load(file_acq,'Doppler_film');
                    Doppler_film = data.Doppler_film;
                end
                fprintf(' done.\n');
            else
                errordlg('Cannot load Doppler: File .acq not found [%s].',F.acq);
                return;
            end
            % Removing selected frames (stored in ind_remove)
            dd = load(fullfile(folder_name,'Doppler.mat'),'ind_remove');
            Doppler_film(:,:,dd.ind_remove) = NaN(size(Doppler_film,1),size(Doppler_film,2),sum(dd.ind_remove));
            
            % Initialization
            normalization = [];
            index_baseline = [];
            im_baseline = [];
            im_mean = [];
            im_std = [];
            
            switch str_popup
                case 'Doppler_source'
                    % Doppler_film
                    IM = Doppler_film;
                    
                case 'Doppler_normalized'
                    % Doppler_normalized
                    normalization = GImport.Doppler_normalization;
                    index_baseline = zeros(size(Doppler_film,3),1);
                    im_baseline = [];
                    im_mean = [];
                    im_std = [];
                    str_baseline = [];
                    
                    switch normalization
                        case 'std'
                            im_mean = mean(Doppler_film,3,'omitnan');
                            im_std = std(Doppler_film,0,3,'omitnan');
                            M = repmat(im_mean,1,1,size(Doppler_film,3));
                            S = repmat(im_std,1,1,size(Doppler_film,3));
                            Doppler_normalized = (Doppler_film-M)./S;
                        case 'mean'
                            im_mean = mean(Doppler_film,3,'omitnan');
                            M = repmat(im_mean,1,1,size(Doppler_film,3));
                            Doppler_normalized = 100*(Doppler_film-M)./M;
                        case {'baseline1';'baseline2';'baseline3'}
                            switch normalization
                                case 'baseline1'
                                    str_baseline='BASELINE';
                                case 'baseline2'
                                    str_baseline='BASELINE-QW';
                                case 'baseline3'
                                    str_baseline='BASELINE-AW';
                            end
                            dt = load(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_images');
                            % ind_base = contains({dt.TimeTags(:).Tag}',str_baseline);
                            ind_base = strcmp({dt.TimeTags(:).Tag}',str_baseline);
                            if isempty(dt.TimeTags_images(ind_base))
                                warning('Cannot compute Normalized Movie: Missing baseline Tag [%s].',str_baseline);
                                return;
                            else
                                temp = dt.TimeTags_images(ind_base,:);
                                for i=1:size(temp,1)
                                    index_baseline(temp(i,1):temp(i,2))=1;
                                end
                            end
                            
                            Doppler_baseline = Doppler_film(:,:,index_baseline==1);
                            im_baseline = mean(Doppler_baseline,3,'omitnan');
                            M = repmat(im_baseline,1,1,size(Doppler_film,3));
                            Doppler_normalized = 100*(Doppler_film-M)./M;
                        otherwise
                            return
                    end
                    fprintf('Normalized Movie computed from %s\n',normalization);
                    IM = Doppler_normalized;
                    
                case 'Doppler_dB'
                    % Doppler_dB
                    IM = 20*log10(abs(Doppler_film)/max(max(abs(Doppler_film(:,:,CUR_IM)))));
            end
            
        case 'Differential Movie'
            % Differential Movie
            im_diff = diff(IM,1,3);
            IM = cat(3,im_diff,im_diff(:,:,end));
    end
    
    % Save Doppler.mat
    fprintf('Saving Doppler_film [%s] ...',fullfile(folder_name,'Doppler.mat'));
    Doppler_film = IM;
    Doppler_type = str_popup;
    save(fullfile(folder_name,'Doppler.mat'),'Doppler_film','Doppler_type',...
        'normalization','im_mean','im_std','im_baseline','index_baseline','-append');
    fprintf(' done.\n');
    % fprintf('===> File Doppler.mat appended [%s].\n',fullfile(folder_name,'Doppler.mat'));

end

% Temporal smoothing of IM
data_tr = load(fullfile(folder_name,'Time_Reference.mat'),...
    'n_burst','length_burst','time_ref','rec_mode');
time_ref = data_tr.time_ref;
try
    % new format
    rec_mode = data_tr.rec_mode;
catch
    % Recurring bug - Need to run import Time Reference
    % old format
    if isfield(data_tr, 'rec_mode')
        rec_mode = data_tr.rec_mode;
    else
        rec_mode = 'CONTINUOUS';
    end
end

% Smooting Movie
t_gauss = GTraces.GaussianSmoothing;
delta =  time_ref.Y(2)-time_ref.Y(1);
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);
% Smoothing Doopler
if t_gauss>0
    %try
    if strcmp(rec_mode,'BURST')
        for i=1:size(IM,1)
            for j=1:size(IM,2)
                y = IM(i,j,:);
                length_burst = data_tr.length_burst;
                % length_burst = 1181;
                n_burst = length(y)/length_burst;
                y_reshape = [reshape(squeeze(y),[length_burst,n_burst]);NaN(length(w),n_burst)];
                y_conv = nanconv(y_reshape(:),w,'same');
                y_reshaped = reshape(y_conv,[length_burst+length(w),n_burst]);
                y_final = reshape(y_reshaped(1:length_burst,:),[length_burst*n_burst,1]);
                IM(i,j,:) = permute(y_final,[3,2,1]);
            end
            fprintf('Smoothing Doppler [%.1f s] - %d/%d\n',t_gauss,i,size(IM,1));
        end
        %catch
    else
        for i=1:size(IM,1)
            for j=1:size(IM,2)
                y_smooth =  squeeze(IM(i,j,:));
                y_conv = nanconv(y_smooth,w,'same');
                IM(i,j,:) = permute(y_conv',[3,2,1]);
            end
            fprintf('Smoothing Doppler [%.1f s] - %d/%d\n',t_gauss,i,size(IM,1));
        end
    end
else
    fprintf('Smoothing Doppler: none.\n');
end

%IM=double(IM);
%LAST_IM = size(IM,3);
success = true;
toc;

end