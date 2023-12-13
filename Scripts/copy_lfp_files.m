% Copy all files in folder_source to folder_dest

folder_source = '/media/hobbes/DataMOBs171/Ephys';
folder_dest = '/media/hobbes/DataMOBs171/EphysFiltered';

d_nrs = dir(fullfile(folder_source,'*','*','*','*.nrs'));
d_xml = dir(fullfile(folder_source,'*','*','*','*.xml'));
d_txt = dir(fullfile(folder_source,'*','*','*','*.txt'));
d = [d_nrs;d_xml;d_txt];

for i =1:length(d)
   dest_folder = strrep(d(i).folder,folder_source,folder_dest);
   if ~isfolder(dest_folder)
       mkdir(dest_folder);
   end
   copyfile(fullfile(d(i).folder,d(i).name),fullfile(dest_folder,d(i).name));
   fprintf('[%s]->[%s]\n.',fullfile(d(i).folder,d(i).name),fullfile(dest_folder,d(i).name))
end