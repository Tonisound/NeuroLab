function mainFigure_saveFcn(~,~,handles)
% GUI saving function
% Saving Config.mat Files.mat

global FILES CUR_FILE DIR_SAVE;

if ~isempty(FILES)
    % Saving Configuration
    save_graphicdata(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
    % Saving Files.mat
    save('Files.mat','CUR_FILE','-append');
    fprintf('Files.mat Saved %s.\n',fullfile(pwd,'Files.mat'));
end

end