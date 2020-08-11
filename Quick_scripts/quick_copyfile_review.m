% Correlation movies
% folder_in = 'I:\NEUROLAB\NLab_Figures\fUS_Correlation\2020*\RUN\Ref-SPEED\*.mp4';
% folder_out = 'C:\Users\Antoine\Desktop\fUS_Correlation\Ref-SPEED';

% PeriEvent Regression
% folder_in = 'I:\NEUROLAB\NLab_Figures\fUS_PeriEventHistogram\*\RUN\2020*Regression*';
% folder_out = 'C:\Users\Antoine\Desktop\fUS_PeriEvent\Regression';

% % PeriEvent Peak-to-Peak
% folder_in = 'I:\NEUROLAB\NLab_Figures\fUS_PeriEventHistogram\*\RUN\2020*Peak-to-Peak*';
% folder_out = 'C:\Users\Antoine\Desktop\fUS_PeriEvent\Peak-to-Peak';

folder_in = 'I:\NEUROLAB\NLab_Figures\fUS_Correlation\2020*\STABLE\Ref-Power-gamma*[M1]\*Pattern.jpg';
folder_out = 'C:\Users\Antoine\Desktop\CFC';

d = dir(folder_in)
for i=1:length(d)
    copyfile(fullfile(d(i).folder,d(i).name),fullfile(folder_out,d(i).name));
    fprintf('File [%s] => [%s].\n',char(d(i).name),folder_out);
end