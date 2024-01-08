% Script - Dec 23
% Modifies event files name

global DIR_SAVE;
d_csv = dir(fullfile(DIR_SAVE,'*','Events','*','*.csv'));

for i=1:length(d_csv)
    old_csv = char(d_csv(i).name);
    new_csv = strrep(old_csv,']Ripples','-000]Ripples');
    movefile(fullfile(d_csv(i).folder,old_csv),fullfile(d_csv(i).folder,new_csv));
    fprintf('%d/%d.\n',i,length(d_csv));
end