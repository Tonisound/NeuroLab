function mainFigure_closeFcn(~,~,handles)
% GUI closing function
% Saving Config.mat & Files.mat

% global FILES CUR_FILE DIR_SAVE;
% 
% if ~isempty(FILES)
%     % Saving Configuration
%     save_graphicdata(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),handles);
%     % Saving Files.mat
%     save('Files.mat','CUR_FILE','-append');
%     fprintf('Files.mat Saved %s.\n',fullfile(pwd,'Files.mat'));
% end
% % Saving GUI figure
% savefig('main_NeuroLab.fig');
% fprintf('main_NeuroLab.fig Saved %s.\n Thanks for using NeuroLab ! Goodbye !\n',fullfile(pwd,'main_NeuroLab.fig'));
% close(handles.MainFigure);

delete(handles.VideoFigure);

end