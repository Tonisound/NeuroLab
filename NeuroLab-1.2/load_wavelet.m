function [Cdata_sub,Xdata_sub,freqdom] = load_wavelet(recording_name,channel)

global DIR_SAVE;

Cdata_sub = [];
Xdata_sub = [];
freqdom = [];

d_wav = dir(fullfile(DIR_SAVE,recording_name,'Wavelet',sprintf('Wav_%s*.mat',channel)));

if isempty(d_wav)
    warning('No wavelet File to load [%s][%s].',recording_name,channel);
    return;
end

% all_Cdata = [all_Cdata,Cdata];
Cdata_sub = [];
Xdata_sub = [];
for k=1:length(d_wav)
    fprintf('Loading Time-Frequency Spectrogramm [%s] [%d/%d] ...',channel,k,length(d_wav));
    data_wav = load(fullfile(d_wav(k).folder,d_wav(k).name),'Cdata_sub_int','x_start','step_save_duration','x_end','freqdom','save_ratio');
    fprintf(' done.\n');
    
    Cdata_sub = [Cdata_sub,double(data_wav.Cdata_sub_int/data_wav.save_ratio)];
    Xdata_sub = [Xdata_sub,data_wav.x_start:data_wav.step_save_duration:data_wav.x_end];
    freqdom = data_wav.freqdom;
    
end

end
