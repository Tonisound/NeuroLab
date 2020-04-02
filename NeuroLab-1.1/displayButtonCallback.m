function displayButtonCallback(~,~,handles)
% 213 -- Figure & Movie Options Callbacks

global DIR_SAVE FILES CUR_FILE;
savedir = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);
recording = FILES(CUR_FILE).recording;
data_config = load(fullfile(savedir,'Config.mat'));

if exist(fullfile(savedir,'Time_Reference.mat'),'file')
    load(fullfile(savedir,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
else
    warning('Missing File %s',fullfile(savedir,'Time_Reference.mat'));
    length_burst = data_config.n_frames;
    n_burst =1;
end

val = get(handles.FigureListPopup,'Value');
str = get(handles.FigureListPopup,'String');


switch strtrim(str(val,:))
    
    case '(Movie) Normalized Movie'
        movie_normalized(handles);
        
    case '(Movie) Deformation Field'
        try
            load(fullfile(savedir,'Doppler.mat'),'Doppler_film');
            load(fullfile(savedir.nlab,'Doppler_deformation.mat'),'Doppler_def','Doppler_defx','Doppler_defy');
            movie_deformation(Doppler_film,Doppler_defx,Doppler_defy);
        catch
            errordlg(sprintf('Missing File Doppler_deformation : %s\n',fullfile(savedir,'Doppler_deformation.mat')));
            return;
        end
    case '(Movie) Data Reconstruction'
        try
            %load(fullfile(savedir,'Doppler.mat'),'Doppler_film');
            load(fullfile(savedir,'Doppler_normalized.mat'),'Doppler_normalized');
            load(fullfile(savedir,'Doppler_reconstructed.mat'),'Doppler_reconstructed_ICA','Doppler_reconstructed_PCA');
            
            if ~isempty(X)&&~isempty(Y)
                movie_reconstruction(Doppler_normalized,Doppler_reconstructed_ICA,Doppler_reconstructed_PCA,'Normalized Movie','ICA Reconstruction','PCA Reconstruction',X,Y);
            else
                movie_reconstruction(Doppler_normalized,Doppler_reconstructed_ICA,Doppler_reconstructed_PCA,'Normalized Movie','ICA Reconstruction','PCA Reconstruction');
            end
        catch
            errordlg(sprintf('Missing File Doppler_reconstructed : %s\n',fullfile(savedir,'Doppler_reconstructed.mat')));
            return;
        end
        
    case '(Figure) Principal and Independent Component Analysis'
        figure_ICA_PCA(handles);
    
    case '(Figure) Correlation Analysis'
        figure_Correlation_Analysis(handles,1);
    
    case '(Figure) LFP Wavelet Analysis'
        figure_Wavelet_Analysis(handles,1);
        
    case '(Figure) Sleep Scoring'
        figure_SleepScoring(handles,savedir,recording,1);
        
    case '(Figure) fUS Fourier Analysis'
        figure_fUS_FrequencyAnalysis(handles);
        
    case '(Figure) Vascular Potentiation'
        figure_VascularPotentiation(handles,1);
        
    case '(Figure) fUS Episode Statistics'
        figure_fUS_EpisodeStatistics(handles,1);
        
    case '(Figure) Peak Detection'
        figure_PeakDetection(handles,1);

    case '(Figure) Peri-Event Time Histogram'
        figure_PeriEventHistogramm(handles,1);
        
    case '(Figure) Global Episode Display'
        figure_GlobalDisplay(handles,1);
        
    case '(Figure) Cross-Correlation LFP-fUS'
        figure_CrossCorrelation(handles,1);
        
end

end
