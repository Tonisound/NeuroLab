function template_buttonBack_Callback(~,~,ax,edits)

for i=1:length(ax)
    delta = ax(i).XLim(2)-ax(i).XLim(1);
    xlim1 = ax(i).XLim(1)-delta;
    xlim2 = ax(i).XLim(1);
    ax(i).XLim =[xlim1,xlim2];
end
if nargin>3
    edits(1).String = datestr(xlim1/(24*3600),'HH:MM:SS.FFF');
    edits(2).String = datestr(xlim2/(24*3600),'HH:MM:SS.FFF');
end

end