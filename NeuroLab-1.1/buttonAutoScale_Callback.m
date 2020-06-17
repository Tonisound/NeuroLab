function buttonAutoScale_Callback(~,~,handles)
% 403 -- Callback AutoScale Button

global IM;

% set(findobj(handles.RightAxes,'Tag','Cursor'),'Visible','off');
% axis(handles.RightAxes,'auto y');
% set(findobj(handles.RightAxes,'Tag','Cursor'),'YData',ylim(handles.RightAxes),'Visible','on');

all_lines = findobj(handles.RightAxes,'Type','line','-not','Tag','Cursor','-and','Visible','on');
all_M = [];
for i =1:length(all_lines)
    index_x = find((all_lines(i).XData>handles.RightAxes.XLim(1)).*(all_lines(i).XData<handles.RightAxes.XLim(2))==1);
    all_M = [all_M;[min(all_lines(i).YData(index_x),[],'omitnan') max(all_lines(i).YData(index_x),[],'omitnan')]];
end

% update
if size(all_M,1)==1 && ~isempty(all_M)
    handles.RightAxes.YLim = all_M;
elseif size(all_M,1)>1
    handles.RightAxes.YLim = [min(all_M(:,1),[],'omitnan') max(all_M(:,2),[],'omitnan')];
end

handles.CenterAxes.YLim  = [.5 size(IM,1)+.5];
handles.CenterAxes.XLim  = [.5 size(IM,2)+.5];
boxCLim_Callback(handles.CLimBox,[],handles);

end