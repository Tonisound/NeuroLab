% Script - Dec 23
% Compute Wavelet for all channels

global FILES DIR_SAVE ;

% Parameters
fdom_min = 1;
fdom_max = 250;
fdom_step = 1;
Fb = 2;
Fc = 2;
freqdom = fdom_min:fdom_step:fdom_max;


for i =1:length(FILES)
    
    cur_recording = FILES(i).nlab;
    
    % LFP Channel Loading
    d_lfp = dir(fullfile(DIR_SAVE,cur_recording,'Sources_LFP','LFP_*.mat'));
    % renaming LFP channels
    all_lfp_channels = {d_lfp(:).name}';
    all_lfp_channels = strrep(all_lfp_channels,'LFP_','');
    all_lfp_channels = strrep(all_lfp_channels,'.mat','');
    n_channels = length(all_lfp_channels);
    
    % Loading data
    for j=1:n_channels
        cur_channel = char(all_lfp_channels(j));
        d_raw = dir(fullfile(DIR_SAVE,cur_recording,'Sources_LFP',sprintf('LFP_%s.mat',cur_channel)));
        if isempty(d_raw)
            warning('No channel found [%s]',cur_recording);
            continue
        else
            data_raw = load(fullfile(d_raw.folder,d_raw.name));
            Xraw = data_raw.x_start:data_raw.f:data_raw.x_end;
%             x_start = data_raw.x_start;
%             x_end = data_raw.x_end;
            Yraw = data_raw.Y;
            f_samp = 1/data_raw.f;
        end  
        
        % Computing Wavelet
        sub_samp = floor(f_samp/(2*fdom_max));          % subsampling frequency factor
        f_sub = f_samp/sub_samp;
        scales = Fc*f_sub./freqdom;
        
        n_samples = 1200*f_samp;
        index_start = 1:n_samples:length(Yraw);
        index_end = [n_samples:n_samples:length(Yraw),length(Yraw)];
        
%         all_Cdata = [];
        
        data_dir = fullfile(DIR_SAVE,cur_recording,'Wavelet');
        if ~isfolder(data_dir)
            mkdir(data_dir);
        end
        for k=1:length(index_start)
            fprintf('Computing Time-Frequency Spectrogramm [%s] [%d/%d] ...',cur_channel,k,length(index_start));
            Y = Yraw(index_start(k):index_end(k));
            coefs_wav   = cmorcwt(Y,scales,Fb,Fc);
            Cdata = log10(abs(coefs_wav)).^2;
%             all_Cdata = [all_Cdata,Cdata];
            fprintf(' done.\n');
            
            x_start = Xraw(index_start(k));
            x_end = Xraw(index_end(k));
            
            % Saving    
            filename = sprintf('Wav_%s_%03d.mat',cur_channel,k);
            save(fullfile(data_dir,filename),'Fb','Fc','fdom_step','fdom_min','fdom_max','freqdom',...
                'cur_recording','cur_channel','x_start','x_end',...
                'f_sub','f_samp','sub_samp','scales','Cdata','-v7.3');
            fprintf('Data saved at %s.\n',fullfile(data_dir,filename));
        end
        
%         tic;
%         fprintf('Computing Time-Frequency Spectrogramm [%s] ...',cur_channel);
%         coefs_wav   = cmorcwt(Yraw,scales,Fb,Fc);
%         Cdata = log10(abs(coefs_wav)).^2;
%         fprintf(' done.\n');
%         toc;
        
% 
%         filename = sprintf('[%s][%s]Wavelet_Analysis.mat',cur_recording,cur_channel);
%         save(fullfile(data_dir,filename),'Fb','Fc','fdom_step','fdom_min','fdom_max','freqdom',...
%             'cur_recording','cur_channel','x_start','x_end',...
%             'f_sub','f_samp','sub_samp','scales','all_Cdata','-v7.3');
%         fprintf('Data saved at %s.\n',fullfile(data_dir,filename));
        
    end
end