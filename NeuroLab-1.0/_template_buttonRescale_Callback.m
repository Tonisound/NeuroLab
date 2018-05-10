function template_buttonRescale_Callback(~,~,ax,edits)

l = findobj(ax,'Type','line','-not','Tag','T2','-not','Tag','Tick_peak');
if length(l)>1
    l = l(1);
end

xlim1 = l.XData(1);
xlim2 = l.XData(end);
ax.XLim =[xlim1,xlim2];
if nargin>3
    edits(1).String = datestr(xlim1/(24*3600),'HH:MM:SS.FFF');
    edits(2).String = datestr(xlim2/(24*3600),'HH:MM:SS.FFF');
end

end