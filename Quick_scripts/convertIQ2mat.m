% Script written by Antoine
% converts Aixplorer data (V6) to high definition Doppler.mat
% Can specify the sampling rate of Doppler.mat
% converts normal trigger.txt to HD trigger.txt

% all files
all_files = {...'20141216_225758_E','20141216_225559_V6_U';...
%     '20141226_154835_E','20141226_154653_V6_U';...
%     '20150223_170742_E','20150223_170148_V6_U';...
%     '20150224_175307_E','20150224_174502_V6_U';...
%     '20150225_154031_E','20150225_153617_V6_U';...
%     '20150226_173600_E','20150226_173132_V6_U';...
%     '20150227_134434_E','20150227_134224_V6_U';...
%     '20150304_150247_E','20150304_145903_V6_U';...
%     '20150305_190451_E','20150305_190203_V6_U';...
%     '20150306_162342_E','20150306_162155_V6_U';...
%     '20150619_132607_E','20150619_122217_V6_U';...
%     '20150620_175137_E','20150620_164845_V6_U';...
%     '20150714_191128_E','20150714_180807_V6_U';...
%     '20150715_181141_E','20150715_170820_V6_U';...
%     '20150716_130039_E','20150716_115621_V6_U';...
%     '20150717_133756_E','20150717_123436_V6_U';...
%     '20150718_135026_E','20150718_124602_V6_U';...
%     '20150722_121257_E','20150722_110928_V6_U';...
%     '20150723_123927_E','20150723_113509_V6_U';...
%     '20150724_131647_E','20150724_121215_V6_U';...
%     '20150724_170457_E','20150724_160123_V6_U';...
%     '20150725_130514_E','20150725_120141_V6_U';...
%     '20150725_160417_E','20150725_145946_V6_U';...
%     '20150726_152241_E','20150726_141815_V6_U';...
%     '20150727_114851_E','20150727_104523_V6_U';...
%     '20150728_134238_E','20150728_123904_V6_U';...
%     '20151126_170516_E','20151126_160624_V6_U';...
%     '20151127_120039_E','20151127_110119_V6_U';...
%     '20151128_133929_E','20151128_123945_V6_U';...
%     '20151201_144024_E','20151201_134136_V6_U';...
%     '20151202_141449_E','20151202_141503_R_6BMU';...
%     '20151203_113703_E','20151203_103726_V6_U';...
%     '20151204_135022_E','20151204_125057_V6_U'};%;...
%     '20160622_122940_E','20160622_122937_R_6BMU';...
%     '20160622_191334_E','20160622_191350_R_6BMU';...
%     '20160623_123336_E','20160623_123326_6BMU';...
    '20160623_163228_E','20160623_163213_6BMU';...
%     '20160623_193007_E','20160623_193030_6BMU';...
%     '20160624_120239_E','20160624_120213_6BMU';...
%     '20160624_171440_E','20160624_171460_6BMU';...
%     '20160625_113928_E','20160625_113927_6BMU';...
%     '20160625_163710_E','20160625_163726_6BMU';...
%     '20160628_171324_E','20160628_171256_6BMU';...
%     '20160629_134749_E','20160629_134705_6BMU';...
%     '20160629_191304_E','20160629_191230_6BMU';...
    '20160630_114317_E','20160630_114226_6BMU';...
%     '20160701_130444_E','20160701_130308_6BMU'...
};
files_E = all_files(:,1);
files_U = all_files(:,2);

% repo architecture
repo_iq = 'F:\DATA_6BMU';
% repo_iq = 'F:\DATA_V6_U';
repo_original = 'I:\DATA\PHD-fUS-VIDEO';
repo_hd = 'I:\DATA\PHD-fUS-VIDEO_HD';

TotalFrames = 6000;

% finding session
for index_file =1:size(all_files,1)
    cur_file = char(files_E(index_file));
    cur_iq = char(files_U(index_file));
    d = dir(fullfile(repo_original,'*',cur_file));
    temp = char(unique({d(:).folder}'));
    temp = strrep(temp,repo_original,'');
    temp = strrep(temp,cur_file,'');
    temp = strrep(temp,filesep,'');
    
    % finding fus
    cur_session = temp;
    d = dir(fullfile(repo_original,cur_session,cur_file,'*_fus'));
    cur_fus = char(d(1).name);
    
    % file architecture
    % folder_iq = '20150724_160123_V6_U';
    % folder_original = fullfile('20150724_SD05_MySession','20150724_170457_E','20150724_170457_E_fus');
    % folder_hd = fullfile('20150724_SD05_MySession','20150724_170457B_E','20150724_170457_E_fus');
    folder_iq = cur_iq;
    folder_original = fullfile(cur_session,cur_file,cur_fus);
    folder_hd = fullfile(cur_session,strcat(cur_file(1:end-2),'B',cur_file(end-1:end)),cur_fus);
    
    %% Doppler
    folder_in = fullfile(repo_iq,folder_iq);
    file_out = fullfile(repo_hd,folder_hd,'Doppler.mat');
    
    % parameters
    %extension = 'IQandMore*.mat';
    extension = 'IQUF*.mat';
    NbFrames = 100;
    n_overlap = 95;
    fcut = 60;
    Doppler_film =[];
    
    % searching IQ files
    d = dir (fullfile(folder_in,extension));
    n_burst = length(d);
    
%     % keeping only full bursts
%     ind_keep = false(n_burst,1);
%     for i=1:n_burst
%         fprintf('Loading [%s]...',fullfile(d(i).folder,d(i).name));
%         data_iq = load(fullfile(d(i).folder,d(i).name));
%         fprintf(' done.\n');
%         if isfield(data_iq,'IQ')
%             ind_keep(i)=true;
%         else
%             ind_keep(i)=false;
%         end
%     end
%     d = d(ind_keep);
%     n_burst = length(d);
    
    for i=1:n_burst
        
        count=0;
        data_iq = load(fullfile(d(i).folder,d(i).name));
%         try
%             TotalFrames = size(data_iq.IQ,3);
%         catch
%             continue;
%         end
        if  size(data_iq.IQ,3)~=TotalFrames
            last_frame = data_iq.IQ(:,:,end);
            data_iq.IQ = cat(3,data_iq.IQ,repmat(last_frame,[1 1 TotalFrames-size(data_iq.IQ,3)]));
        end
        
        indexes = 1:NbFrames-n_overlap:TotalFrames-NbFrames+1; % blocs de NbFrames images with n_overlap
        Doppler_film_HD = NaN(size(data_iq.IQ,1),size(data_iq.IQ,2),length(indexes));
        
        for k=indexes
            
            count=count+1;
            IQ_flat = data_iq.IQ(:,:,k:k+NbFrames-1);
            Doppler_HD = filter_SVD(IQ_flat,fcut);
            %Doppler_film_HD = cat(3,Doppler_film_HD,Doppler_HD);
            Doppler_film_HD(:,:,count) = Doppler_HD;
            
            figure(1);
            imagesc(log10(squeeze(Doppler_HD(:,:))));
            colormap hot;
            colorbar;
            title(sprintf('SVD HD - Burst %d Image %d (from IQ image %d to IQ image%d)',i,count,k,k+NbFrames-1));
            drawnow;
            
        end
        fprintf('Burst %d : OK\n',i);
        Doppler_film = cat(3,Doppler_film,Doppler_film_HD);
        
    end
    
    % saving
    fprintf('Saving file [%s] ...',file_out);
    save(file_out,'Doppler_film','-v7.3');
    fprintf(' done\n');
    
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
end