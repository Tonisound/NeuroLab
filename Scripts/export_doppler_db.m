global FILES IM CUR_IM;
folder = 'C:\Users\Antoine\Desktop\Doppler_dB';
load('Preferences.mat','GTraces');

for ii = 50:length(FILES)
    
    %File Selection
    myhandles.FileSelectPopup.Value=ii;
    fileSelectionPopup_Callback(myhandles.FileSelectPopup,[],myhandles);
    
    myhandles.CenterPanelPopup.Value = 3;
    centerPanel_controlCallback(myhandles.CenterPanelPopup,[],myhandles);
    
    % Save Doppler_db
    Image = IM(:,:,CUR_IM);
    %picname = FILES(ii).nlab;
    picname = sprintf('Essai%03d',ii+1);
    saveas(f,fullfile(folder,picname),GTraces.ImageSaveFormat);
    save(fullfile(folder,strcat(picname,'.mat')),'Image');
    fprintf('===== File %s saved ===== \n',fullfile(folder,picname));
    
    myhandles.CenterPanelPopup.Value = 2;
    centerPanel_controlCallback(myhandles.CenterPanelPopup,[],myhandles);
end