d = dir('I:\NEUROLAB\NLab_Statistics\fUS_PeriEventHistogram\*\*\AutoCorr.mat');

for i =1:length(d)
    %data_d = load(fullfile(d(i).folder,d(i).name),'str_autocorr');
    %data_d.str_autocorr
    str_autocorr = {'Single';'2 trials';'3 trials'};
    save(fullfile(d(i).folder,d(i).name),'str_autocorr','-append');
    fprintf('%d/%d\n',i,length(d));
end