% Script - Dec 23
% Modifying Config.mat files to add dat directory and file

global FILES DIR_SAVE;

for i=1:length(FILES)
    
    % Loading Config.mat
    data_c = load(fullfile(DIR_SAVE,FILES(i).nlab,'Config.mat'),'File');
    File = data_c.File;
    
    temp0 = strrep(DIR_SAVE,strcat('NEUROLAB',filesep,'NLab_DATA'),'Ephys');
    temp = regexp(FILES(i).nlab,'_','split');
    temp1 = sprintf('Rat-%s',char(temp(2)));
    temp2 = strrep(FILES(i).ns2,'.ns2','[ns2]');
    dir_dat = fullfile(temp0,temp1,temp2);
    str3 = strrep(FILES(i).ns2,'.ns2','[ns2].dat');
    if isfolder(dir_dat)
        File.dir_dat = dir_dat;
    else
        warning('Folder does not exist: [%s]',fullfile(temp0,temp1,temp2));
    end
    if isfile(fullfile(dir_dat,str3))
        File.dat = str3;
    else
        warning('File does not exist: [%s]',str3);
    end
    
    % Saving Config.mat
    save(fullfile(DIR_SAVE,FILES(i).nlab,'Config.mat'),'File','-append');
    fprintf('File [%s] updated.\n',fullfile(DIR_SAVE,FILES(i).nlab,'Config.mat'));
    
end
