% Script written by Antoine
% converts Aixplorer data (V6) to high definition Doppler.mat
% Can specify the sampling rate of Doppler.mat
% converts normal trigger.txt to HD trigger.txt

% file architecture
repo_iq = 'F:\DATA_V6_U';
repo_original = 'I:\DATA\PHD-fUS-VIDEO';
repo_hd = 'I:\DATA\PHD-fUS-VIDEO_HD';

folder_iq = '20150724_160123_V6_U';
folder_original = fullfile('20150724_SD05_MySession','20150724_170457_E','20150724_170457_E_fus');
folder_hd = fullfile('20150724_SD05_MySession','20150724_170457B_E','20150724_170457_E_fus');

% %% Doppler
% folder_in = fullfile(repo_iq,folder_iq);
% file_out = fullfile(repo_hd,folder_hd,'Doppler.mat');
% 
% % parameters
% extension = 'IQandMore*.mat';
% NbFrames = 100;
% n_overlap = 95;
% fcut = 60;
% Doppler_film =[];
% 
% % searching IQ files
% d = dir (fullfile(folder_in,extension));
% n_burst = length(d);
% 
% for i=1:n_burst
%     
%     count=0;
%     data_iq = load(fullfile(d(i).folder,d(i).name));
%     TotalFrames = size(data_iq.IQ,3);
%     indexes = 1:NbFrames-n_overlap:TotalFrames-NbFrames+1; % blocs de NbFrames images with n_overlap
%     Doppler_film_HD = NaN(size(data_iq.IQ,1),size(data_iq.IQ,2),length(indexes));
%     
%     for k=indexes
%         
%         count=count+1;
%         IQ_flat = data_iq.IQ(:,:,k:k+NbFrames-1);
%         Doppler_HD = filter_SVD(IQ_flat,fcut);
%         %Doppler_film_HD = cat(3,Doppler_film_HD,Doppler_HD);
%         Doppler_film_HD(:,:,count) = Doppler_HD;
%         
%         figure(1);
%         imagesc(log10(squeeze(Doppler_HD(:,:))));
%         colormap hot;
%         colorbar;
%         title(sprintf('SVD HD - Burst %d Image %d (from IQ image %d to IQ image%d)',i,count,k,k+NbFrames-1));
%         drawnow;
%         
%     end
%     fprintf('Burst %d : OK\n',i);
%     Doppler_film = cat(3,Doppler_film,Doppler_film_HD);
% 
% end
% 
% % saving
% fprintf('Saving file [%s] ...',file_out);
% save(file_out,'Doppler_film','-v7.3');
% fprintf(' done\n');

%% trigger
trigger_in = fullfile(repo_original,folder_original,'trigger.txt');
trigger_out = fullfile(repo_hd,folder_hd,'trigger.txt');

% Trigger Readout
reference = 'default';
padding = 'none';
offset = 0; % default
trigger = [];

fid_txt = fopen(trigger_in,'r');
A = fread(fid_txt,'*char')';
fclose(fid_txt);

% REF
delim1 = '<REF>';
delim2 = '</REF>';
if strfind(A,delim1)
    %B = regexp(A,'<REF>|<\REF>','split');
    B = A(strfind(A,delim1)+length(delim1):strfind(A,delim2)-1);
    C = regexp(B,'\t|\n|\r','split');
    D = C(~cellfun('isempty',C));
    reference = char(D);
end
% PAD
delim1 = '<PAD>';
delim2 = '</PAD>';
if strfind(A,delim1)
    B = A(strfind(A,delim1)+length(delim1):strfind(A,delim2)-1);
    C = regexp(B,'\t|\n|\r','split');
    D = C(~cellfun('isempty',C));
    padding = char(D);
end
% OFFSET
delim1 = '<OFFSET>';
delim2 = '</OFFSET>';
if strfind(A,delim1)
    B = regexp(A,'<OFFSET>|</OFFSET>','split');
    C = char(B(2));
    D = textscan(C,'%f');
    offset = D{1,1};
end
% TRIG
B = regexp(A,'<TRIG>|</TRIG>','split');
C = char(B(2));
D = textscan(C,'%f');
trigger = D{1,1};

% reshape trigger
trigger_hd = [];
length_burst = 59;
n_burst =  length(trigger)/length_burst;
coeff = 20; % coeff must match noverlap
if n_burst-floor(n_burst) ~= 0
    errordlg('trigger length (%d) is not a multiple of length_burst (%d).',length(trigger),length_burst)
else
    for k=1:n_burst
        trig_burst = trigger((k-1)*length_burst+1:k*length_burst);
        trig_start = trig_burst(1);
        trig_end = trig_burst(end);
        delta = (trig_end-trig_start)/length_burst;
        trig = trig_start:delta/coeff:trig_end;
        trigger_hd = [trigger_hd;trig(:)];
    end
end

% Trigger Exportation
fid_txt = fopen(trigger_out,'w');
fprintf(fid_txt,'%s',sprintf('<REF>%s</REF>\n',reference));
fprintf(fid_txt,'%s',sprintf('<PAD>%s</PAD>\n',padding));
fprintf(fid_txt,'%s',sprintf('<OFFSET>%.3f</OFFSET>\n',offset));
fprintf(fid_txt,'%s',sprintf('<TRIG>\n'));
for k = 1:length(trigger_hd)
    fprintf(fid_txt,'%s',sprintf('%.3f\n',trigger_hd(k)));
end
fprintf(fid_txt,'%s',sprintf('</TRIG>'));
fclose(fid_txt);
fprintf('File trigger.txt saved at %s.\n',trigger_out);