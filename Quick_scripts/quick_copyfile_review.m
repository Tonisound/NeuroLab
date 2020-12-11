% Correlation movies
% folder_in = 'I:\NEUROLAB\NLab_Figures\fUS_Correlation\2020*\STABLE\Ref-SPEED\*.mp4';
% folder_out = 'C:\Users\Antoine\Desktop\fUS_Correlation\STABLE';

% PeriEvent Regression
% folder_in = 'I:\NEUROLAB\NLab_Figures\fUS_PeriEventHistogram\*\RUN\2015*Regression*';
% folder_out = 'C:\Users\Antoine\Desktop\fUS_PeriEvent\Regression2';

% % PeriEvent Peak-to-Peak
% folder_in = 'I:\NEUROLAB\NLab_Figures\fUS_PeriEventHistogram\*\RUN\2015*Peak-to-Peak*';
% folder_out = 'C:\Users\Antoine\Desktop\fUS_PeriEvent\Peak-to-Peak2';

% fUS_Correlation
folder_in = 'D:\NEUROLAB\NLab_Figures\fUS_Correlation\*\REM\Ref-Power-gammamid*\*Pattern.jpg';
folder_out = 'C:\Users\Antoine\Desktop\fUS_Correlation';

% % fUS_Correlation
% folder_in = 'I:\NEUROLAB\NLab_Figures\Cross_Correlation\2020*\*fUS-Synthesis_STABLE*';
% folder_out = 'C:\Users\Antoine\Desktop\Cross_Correlation';

d = dir(folder_in);
for i=1:length(d)
    copyfile(fullfile(d(i).folder,d(i).name),fullfile(folder_out,d(i).name));
    fprintf('File [%s] => [%s].\n',char(d(i).name),folder_out);
end