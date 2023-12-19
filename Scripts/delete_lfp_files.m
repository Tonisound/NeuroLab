% Delete all LFP files listed in folder_source
% Use with caution

folder_source = '/media/hobbes/DataMOBS189/DATA/';
d_txt = dir(fullfile(folder_source,'*','*_MySession','*','*_lfp','*.txt'));
d_dat = dir(fullfile(folder_source,'*','*_MySession','*','*_lfp','*.dat'));
d_xml = dir(fullfile(folder_source,'*','*_MySession','*','*_lfp','*.xml'));
d_nrs = dir(fullfile(folder_source,'*','*_MySession','*','*_lfp','*.nrs'));
d = [d_txt;d_dat;d_xml;d_nrs];


for i =1:length(d)
   delete(fullfile(d(i).folder,d(i).name));
   fprintf('File [%s] Deleted.\n',fullfile(d(i).folder,d(i).name));
end