global FILES DIR_SAVE;

for i =1:length(FILES)
    
    hd_file = FILES(i).nlab;
    ld_file = strrep(hd_file,'B_E','_E');
    
    if exist(fullfile(DIR_SAVE,ld_file,'Spikoscope_Episodes.mat'),'file')
        copyfile(fullfile(DIR_SAVE,ld_file,'Spikoscope_Episodes.mat'),fullfile(DIR_SAVE,hd_file,'Spikoscope_Episodes.mat'));
        fprintf('[%d] File [%s] copied in [%s].\n',i,fullfile(DIR_SAVE,ld_file,'Spikoscope_Episodes.mat'),fullfile(DIR_SAVE,hd_file,'Spikoscope_Episodes.mat'))
    end
end