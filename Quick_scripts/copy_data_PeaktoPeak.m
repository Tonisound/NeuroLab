folder = 'I:\NEUROLAB\NLab_Figures\fUS_PeriEventHistogram';
folder_dest1 = 'C:\Users\Antoine\Desktop\Fig7\RUN';

if exist(folder_dest1,'dir')
    rmdir(folder_dest1,'s');
end
mkdir(folder_dest1);

d = dir(fullfile(folder,'*','RUN','*Peak-to-Peak*'));
for i =1:length(d)
    rec_name = char(d(i).name);
    path = char(d(i).folder);
    copyfile(fullfile(path,rec_name),folder_dest1);
end
% for i =1:length(d)
%     rec_name = char(d(i).name);
%     dd=dir(fullfile(folder,rec_name,'*Histograms.jpg'));
%     if ~isempty(dd)
%         file_name = char(dd(1).name);
%         copyfile(fullfile(folder,rec_name,file_name),folder_dest1);
%     end
%     dd=dir(fullfile(folder,rec_name,'*BoxPlot.jpg'));
%     if ~isempty(dd)
%         file_name = char(dd(1).name);
%         copyfile(fullfile(folder,rec_name,file_name),folder_dest2);
%     end
% end