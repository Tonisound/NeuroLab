folder = 'D:\NEUROLAB\NLab_Figures\fUS_Statistics';
folder_dest1 = 'C:\Users\Antoine\Desktop\Bordeaux\Histograms';
folder_dest2 = 'C:\Users\Antoine\Desktop\Bordeaux\BoxPlots';

if exist(folder_dest1,'dir')
    rmdir(folder_dest1,'s');
end
mkdir(folder_dest1);
if exist(folder_dest2,'dir')
    rmdir(folder_dest2,'s');
end
mkdir(folder_dest2);

d = dir(fullfile(folder,'*R_nlab'));
for i =1:length(d)
    rec_name = char(d(i).name);
    dd=dir(fullfile(folder,rec_name,'*Histograms.jpg'));
    if ~isempty(dd)
        file_name = char(dd(1).name);
        copyfile(fullfile(folder,rec_name,file_name),folder_dest1);
    end
    dd=dir(fullfile(folder,rec_name,'*BoxPlot.jpg'));
    if ~isempty(dd)
        file_name = char(dd(1).name);
        copyfile(fullfile(folder,rec_name,file_name),folder_dest2);
    end
end