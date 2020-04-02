function template_buttonBack_Callback(~,~,ax,edits)

delta = ax(1).XLim(2)-ax(1).XLim(1);
xlim1 = ax(1).XLim(1)-delta;
xlim2 = ax(1).XLim(1);

for i=1:length(ax)
    ax(i).XLim =[xlim1,xlim2];
end
if nargin>3
    edits(1).String = datestr(xlim1/(24*3600),'HH:MM:SS.FFF');
    edits(2).String = datestr(xlim2/(24*3600),'HH:MM:SS.FFF');
end

end