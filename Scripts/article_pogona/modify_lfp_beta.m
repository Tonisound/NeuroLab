path_lfp = '/Users/tonio/Documents/Antoine-fUSDataset/NEUROLAB/NLab_DATA/20191003_P3-029_E_nlab/Sources_LFP';

% file_beta = 'LFP-beta_DVRR1.mat';
% data_beta = load(fullfile(path_lfp,file_beta));
% Y = data_beta.Y;
% Y(abs(Y)>1*1e-5)=NaN;
% save(fullfile(path_lfp,file_beta),'Y','-append');
% 
% file_beta = 'LFP-beta_DVRR2.mat';
% data_beta = load(fullfile(path_lfp,file_beta));
% Y = data_beta.Y;
% Y(abs(Y)>1*1e-5)=NaN;
% save(fullfile(path_lfp,file_beta),'Y','-append');
% 
% file_beta = 'LFP-beta_DVRR3.mat';
% data_beta = load(fullfile(path_lfp,file_beta));
% Y = data_beta.Y;
% Y(abs(Y)>1*1e-5)=NaN;
% save(fullfile(path_lfp,file_beta),'Y','-append');
% 
% file_beta = 'LFP-beta_DVRR4.mat';
% data_beta = load(fullfile(path_lfp,file_beta));
% Y = data_beta.Y;
% Y(abs(Y)>1*1e-5)=NaN;
% save(fullfile(path_lfp,file_beta),'Y','-append');

file_raw = 'LFP_DVRR1.mat';
data_raw = load(fullfile(path_lfp,file_raw));
Y = data_raw.Y;
Y(abs(Y)>1*1e-3)=NaN;
Y(isnan(Y))=0;
save(fullfile(path_lfp,file_raw),'Y','-append');

file_raw = 'LFP_DVRR2.mat';
data_raw = load(fullfile(path_lfp,file_raw));
Y = data_raw.Y;
Y(abs(Y)>1*1e-3)=NaN;
Y(isnan(Y))=0;
save(fullfile(path_lfp,file_raw),'Y','-append');

file_raw = 'LFP_DVRR3.mat';
data_raw = load(fullfile(path_lfp,file_raw));
Y = data_raw.Y;
Y(abs(Y)>1*1e-3)=NaN;
Y(isnan(Y))=0;
save(fullfile(path_lfp,file_raw),'Y','-append');

file_raw = 'LFP_DVRR4.mat';
data_raw = load(fullfile(path_lfp,file_raw));
Y = data_raw.Y;
Y(abs(Y)>1*1e-3)=NaN;
Y(isnan(Y))=0;
save(fullfile(path_lfp,file_raw),'Y','-append');

% Create new channel
file_new = 'LFP_DVRR12.mat';
file_raw1 = 'LFP_DVRR1.mat';
file_raw2 = 'LFP_DVRR2.mat';

data_raw1 = load(fullfile(path_lfp,file_raw1));
data_raw2 = load(fullfile(path_lfp,file_raw2));
x_start = data_raw1.x_start;
f = data_raw1.f;
x_end = data_raw1.x_end;
Y = data_raw1.Y-data_raw2.Y;
save(fullfile(path_lfp,file_new),'x_start','f','x_end','Y','-v7.3');

file_new = 'LFP_DVRR34.mat';
file_raw1 = 'LFP_DVRR3.mat';
file_raw2 = 'LFP_DVRR4.mat';

data_raw1 = load(fullfile(path_lfp,file_raw1));
data_raw2 = load(fullfile(path_lfp,file_raw2));
x_start = data_raw1.x_start;
f = data_raw1.f;
x_end = data_raw1.x_end;
Y = data_raw1.Y-data_raw2.Y;
save(fullfile(path_lfp,file_new),'x_start','f','x_end','Y','-v7.3');

