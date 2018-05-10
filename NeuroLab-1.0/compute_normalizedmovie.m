function success = compute_normalizedmovie(folder_name,handles)

success = false;
global DIR_SAVE FILES CUR_FILE IM LAST_IM;
handles.MainFigure.Pointer = 'watch';
drawnow;

load('Preferences.mat','GImport');

fprintf('Loading Doppler_film ...\n');
load(fullfile(folder_name,'Doppler.mat'),'Doppler_film');
fprintf('===> Doppler_film loaded from %s.\n',fullfile(folder_name,'Doppler.mat'));

normalization = GImport.Doppler_normalization;
ind_keep = zeros(LAST_IM,1);
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
        Doppler_normalized = (Doppler_film-M)./M;
    case 'baseline'
        load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_S');
        ind_base = strcmp(TimeGroups_name,'BASELINE');
        ind_images = TimeGroups_S(ind_base).TimeTags_images;
        if isempty(ind_base)
            errordlg('Missing Time Group BASELINE');
            return;
        end
        
        for i=1:size(ind_images,1)
            ind_keep(ind_images(i,1):ind_images(i,2))=1;
        end
        Doppler_baseline = Doppler_film(:,:,ind_keep==1);
        im_baseline = mean(Doppler_baseline,3,'omitnan');
        M = repmat(im_baseline,1,1,size(Doppler_film,3));
        Doppler_normalized = 100*(Doppler_film-M)./M;
    otherwise
        return
end
fprintf('Normalized Movie computed from %s\n',normalization);

fprintf('Saving Doppler_normalized ...\n');
save(fullfile(folder_name,'Doppler_normalized.mat'),'Doppler_normalized','normalization','im_mean','im_std','im_baseline','ind_keep','-v7.3');
fprintf('===> Saved at %s.\n',fullfile(folder_name,'Doppler_normalized.mat'));

%Display directly Normalized Movie
str = strtrim(handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:));
if strcmp(str,'Doppler_normalized')
    IM = Doppler_normalized;
    LAST_IM = size(Doppler_normalized,3);
    actualize_traces(handles);
    actualize_plot(handles);
    buttonAutoScale_Callback(0,0,handles);
end

handles.MainFigure.Pointer = 'arrow';
success = true;

end