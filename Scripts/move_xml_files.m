% Script - Dec 23
% Moving XML files to the correct destination using Neuroscope

seed_config = '/media/hobbes/DataMOBS189/Ephys/Config-Files/XML-files';
config_file = 'SD132.xml';

folder_dest = '/media/hobbes/DataMOBS189/Ephys/Rat-SD132';
d = dir(fullfile(folder_dest,'*[ns2]'));

for i = 1:length(d)
    final_name = strcat(d(i).name,'.xml');
     copyfile(fullfile(seed_config,config_file),fullfile(folder_dest,d(i).name,final_name));
    fprintf('[%s] ---> [%s].\n',fullfile(seed_config,config_file),fullfile(folder_dest,d(i).name,final_name));
end