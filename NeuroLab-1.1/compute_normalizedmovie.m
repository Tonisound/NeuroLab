function success = compute_normalizedmovie(F,handles)

success = false;

global SEED DIR_SAVE IM;
folder_name = fullfile(DIR_SAVE,F.nlab);

handles.MainFigure.Pointer = 'watch';
drawnow;

load('Preferences.mat','GImport');

% fprintf('Loading Doppler_film ...\n');
% load(fullfile(folder_name,'Doppler.mat'),'Doppler_film');
% fprintf('===> Doppler_film loaded from %s.\n',fullfile(folder_name,'Doppler.mat'));

% create Doppler.mat
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
    errordlg('Cannot compute normalized movie: File .acq not found [%s].',F.acq);
    return;
end

% Removing selected frames (stored in ind_remove)
dd = load(fullfile(folder_name,'Doppler.mat'),'ind_remove');
Doppler_film(:,:,dd.ind_remove) = NaN(size(Doppler_film,1),size(Doppler_film,2),sum(dd.ind_remove));

normalization = GImport.Doppler_normalization;
index_baseline = zeros(size(Doppler_film,3),1);
im_baseline = [];
im_mean = [];
im_std = [];

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
    case 'baseline'
        dt = load(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_images');
        %ind_base = contains({dt.TimeTags(:).Tag}','BASELINE');
        ind_base = contains({dt.TimeTags(:).Tag}','STABLE');
        if isempty(dt.TimeTags_images(ind_base))
            warning('No Tag baseline defined.\n')
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

fprintf('Saving Doppler_normalized ...');
Doppler_film = Doppler_normalized;
Doppler_type = 'Doppler_normalized';
% save(fullfile(folder_name,'Doppler_normalized.mat'),'Doppler_normalized',...
% 'normalization','im_mean','im_std','im_baseline','ind_keep','-v7.3');
save(fullfile(folder_name,'Doppler.mat'),'Doppler_film','Doppler_type',...
    'normalization','im_mean','im_std','im_baseline','index_baseline','-append');
fprintf(' done.\n');
fprintf('===> File Doppler.mat appended [%s].\n',fullfile(folder_name,'Doppler.mat'));

% Update Config.mat
data_config = load(fullfile(folder_name,'Config.mat'),'UiValues');
UiValues = data_config.UiValues;
UiValues.CenterPanelPopup = handles.CenterPanelPopup.Value;
save(fullfile(folder_name,'Config.mat'),'UiValues','-append');
fprintf('Config.mat file updated [%s].\n',fullfile(folder_name,'Config.mat'));

% Display directly Normalized Movie
str = strtrim(handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:));
if ~strcmp(str,'Doppler_normalized')
     %ind = strcmp(handles.CenterPanelPopup.String,'Doppler_normalized');
     handles.CenterPanelPopup.Value = 2;
end
IM = Doppler_normalized;
%LAST_IM = size(Doppler_normalized,3);
actualize_traces(handles);
actualize_plot(handles);
buttonAutoScale_Callback(0,0,handles);

handles.MainFigure.Pointer = 'arrow';
success = true;

end