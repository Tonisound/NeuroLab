function videoFigure_closereqFcn(hObj,~,handles)

% selection = questdlg('Close This Figure?',...
%     'Close Request Function',...
%     'Yes','No','Yes');
% switch selection
%     case 'Yes'
%         delete(hObj)
%     case 'No'
%         return
% end

    handles.ViewMenu_Video.Checked = 'off';
    hObj.Visible = 'off';

end