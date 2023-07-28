% data_dir = '/media/hobbes/DataMOBs171/Antoine-fUSDataset/NEUROLAB/NLab_Figures/Movie_Normalized';
data_dir = '/Volumes/DataMOBs171/Antoine-fUSDataset/NEUROLAB/NLab_Figures/Movie_Normalized[V3]';

d1 = dir(fullfile(data_dir,'*','*.avi'));
d2 = dir(fullfile(data_dir,'*','*.mp4'));
d=[d1;d2];
d=d2;
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));

list_files = {d(:).name}';
% dir_store = '/media/hobbes/DataMOBs171/Movies';
dir_store = '/Users/tonio/Desktop/Movies_V3(mp4)';

for i = 1:length(d)
    if isfile(fullfile(d(i).folder,d(i).name))
        copyfile(fullfile(d(i).folder,d(i).name),fullfile(dir_store,d(i).name));
        fprintf('File %d/%d copied [%s].\n',i,length(d),d(i).name);
    else
        fprintf('File not found [%s].\n',d(i).name);
    end
end

