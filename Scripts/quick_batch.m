for ii = 27:42
    
    %File Selection
    file_name = char(myhandles.FileSelectPopup.String(ii,:));
    myhandles.FileSelectPopup.Value=ii;
    fileSelectionPopup_Callback(myhandles.FileSelectPopup,[],myhandles);
    %load(fullfile(DIR_SAVE,FILES(ii).nlab,'Time_Reference.mat'),'n_burst');
    script_Figure1C(myhandles);
    
end