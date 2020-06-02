function tag =  import_DopplerFilm(F,handles,flag,Doppler_film)
% Import Doppler movie from .acq file
% Generates Configuration file Config.mat
% flag 0 - first import
% flag 1 - reimport

if nargin == 3
    Doppler_film = [];
end

global IM LAST_IM SEED DIR_SAVE;
tag = [];

% create Doppler.mat
if isempty(Doppler_film)
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
        % case file_acq ends .mat (Aixplorer)
        warning('File .acq not found %s.',F.acq)
        Doppler_film = NaN(0,0,2);
    end
end


% Checking Doppler
if flag == 0
    % first import
    [ind_remove,thresh,tag] = check_Doppler(Doppler_film);
    Doppler_type = 'Doppler_source';
else
    % re-import
    % d = load(fullfile(DIR_SAVE,F.nlab,'Doppler.mat'),'ind_remove','thresh','Doppler_type');
    d = load(fullfile(DIR_SAVE,F.nlab,'Doppler.mat'),'ind_remove','thresh');
    [ind_remove,thresh,tag] = check_Doppler(Doppler_film,d.ind_remove,d.thresh);
    %Doppler_type = d.Doppler_type;
    Doppler_type = 'Doppler_source';
end
if isempty(ind_remove)
    return;
end
Doppler_film(:,:,ind_remove) = NaN(size(Doppler_film,1),size(Doppler_film,2),sum(ind_remove));

% Saving Doppler_film
% Overwrite previous file Doppler.mat
fprintf('Saving Doppler_film ...');
save(fullfile(DIR_SAVE,F.nlab,'Doppler.mat'),'Doppler_film','Doppler_type','ind_remove','thresh','-v7.3');
handles.RightAxes.UserData.ind_remove = ind_remove;
fprintf(' done.\n');

% create and save Config.mat
if flag == 0
    START_IM = 1;
    CUR_IM = 1;
    END_IM = size(Doppler_film,3);
    LAST_IM = size(Doppler_film,3);
    X = size(Doppler_film,1);
    Y = size(Doppler_film,2);
    n_frames = size(Doppler_film,3);
    Current_Image = Doppler_film(X,Y,1);
    File = F;
    l = load('Files.mat','UiValues_default');
    UiValues = l.UiValues_default;
    save(fullfile(DIR_SAVE,F.nlab,'Config.mat'),...
        'START_IM','CUR_IM','END_IM','LAST_IM','X','Y','n_frames','Current_Image','File','UiValues','-v7.3');
    fprintf('Config.mat saved.\n');
else
    % Updating global variables
    %     if handles.CenterPanelPopup.Value == 1
    %         IM = Doppler_film;
    %         LAST_IM = size(IM,3);
    %         actualize_traces(handles);
    %         actualize_plot(handles);
    %     end
    
    % Forcing Doppler_source
    handles.CenterPanelPopup.Value = 1;
    IM = Doppler_film;
    LAST_IM = size(IM,3);
    actualize_traces(handles);
    actualize_plot(handles);
    
end

end

% Interpolate usinf ind_keep
% tic
% for i =1:size(Doppler_film,1)
%     for j =1:size(Doppler_film,2)
%         test = permute(Doppler_film(i,j,:),[3,1,2]);
%         test_interp = interp1(t(ind_keep),test(ind_keep),t);
%         test_interp = permute(test_interp,[2,3,1]);
%         Doppler_checked(i,j,:) = test_interp;
%     end
% end
% toc
%Doppler_checked = f.UserData;

% % Doppler Resampling
% delta_t = time_ref.Y(2)-time_ref.Y(1);
% if n_burst==1
%     rate = round(delta_t/GImport.resamp_cont);
% else
%     rate = round(delta_t/GImport.resamp_burst);
% end
% if rate>1
%     promptMessage = sprintf('NeuroLab is about to resample by factor %d,\nThis will modify Doppler_film.\nDo you want to continue ?',rate);
%     button = questdlg(promptMessage, 'Continue', 'Continue', 'Cancel', 'Continue');
%     if strcmpi(button, 'Cancel')
%         return;
%     end
%
%     % Reshaping Doppler_film
%     temp=[];
%     Doppler_line = reshape(permute(Doppler_film,[3,1,2]),[size(Doppler_film,3) size(IM,1)*size(Doppler_film,2)]);
%     Doppler_dummy = [Doppler_line;Doppler_line(end,:)];
%     Doppler_line = resample(Doppler_dummy,rate,1);
%     Doppler_line = Doppler_line(1:end-rate,:);
%     Doppler_resample = zeros(size(IM,1),size(IM,2),size(Doppler_line,1));
%     for k = 1:size(Doppler_line,1)
%         Doppler_resample(:,:,k) = reshape(Doppler_line(k,:),[size(IM,1),size(IM,2)]);
%         temp=[temp;time_ref.Y(ceil(k/rate))+(delta_t/rate*mod(k-1,rate))];
%     end
%     % Removing last image
%     for i = flip(length_burst*rate*(1:n_burst)')
%         Doppler_resample(:,:,i)=[];
%         temp(i)=[];
%     end
%     Doppler_film = Doppler_resample;
%
%     % Reshaping time_ref
%     time_ref.Y = temp;
%     time_ref.X = (1:length(temp))';
%     time_ref.nb_images = length(time_ref.Y);
%     length_burst = length_burst*rate-1;
%
% end
%
% % Updating global variables
% IM = Doppler_film;
% LAST_IM = size(IM,3);
% % Saving Doppler_film
% save(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Doppler.mat'),'Doppler_film','-v7.3');
% fprintf('Doppler_film saved at %s.mat\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Doppler.mat'));
