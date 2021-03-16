% Quick script
% Import LFP config and details to load LFP in PHD-fUS-VIDEO_HD
global DIR_SAVE FILES;

for i=1:length(FILES)
    
    folder_hd = fullfile(DIR_SAVE,FILES(i).nlab);
    folder = strrep(folder_hd,'B_E_nlab','_E_nlab');
    
    % Loading Config.mat
    data_c = load(fullfile(folder,'Config.mat'),'File','UiValues');
    
    % Modify
    data_hd = load(fullfile(folder_hd,'Config.mat'),'File','UiValues');
    File = data_hd.File;
    File.mainlfp = data_c.File.mainlfp;
    File.mainemg = data_c.File.mainemg;
    
    % Saving Config.mat
    save(fullfile(folder_hd,'Config.mat'),'File','-append');
    fprintf('File [%s] updated.\n',fullfile(folder_hd,'Config.mat'));
    
    % copy Nconfig.mat
    copyfile(fullfile(folder,'Nconfig.mat'),fullfile(folder_hd,'Nconfig.mat'));
end