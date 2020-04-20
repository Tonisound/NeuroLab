function template_buttonRescale_Callback(~,~,ax,edits)

l = findobj(ax,'Type','line','-not','Tag','T2','-not','Tag','Tick_peak','-not','Tag','Threshold');
if length(l)>1
    l = l(1);
end

xlim1 = l.XData(1);
xlim2 = l.XData(end);
for i =1:length(ax)
    ax(i).XLim =[xlim1,xlim2];
end
if nargin>3
    edits(1).String = datestr(xlim1/(24*3600),'HH:MM:SS.FFF');
    edits(2).String = datestr(xlim2/(24*3600),'HH:MM:SS.FFF');
end

end