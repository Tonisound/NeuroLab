% Quick script - Add empty fields to struct FILES
% Dec 23
global DIR_SAVE ;

d = dir(fullfile(DIR_SAVE,'*_nlab'));

for i=1:length(d)
    
    % Loading Config.mat
    data_c = load(fullfile(d(i).folder,d(i).name,'Config.mat'),'File');
    
    % Modify
    File=data_c.File;
    File.dat = [];
    File.dir_dat = [];
     
    % Saving Config.mat
    save(fullfile(d(i).folder,d(i).name,'Config.mat'),'File','-append');
    fprintf('File [%s] updated.\n',fullfile(d(i).folder,d(i).name,'Config.mat'));

end
