b = datenum(myhandles.TimeDisplay.UserData);
t = (b-floor(b))*24*3600;
l = findobj(myhandles.RightAxes,'Tag','Trace_Region');
l(1).UserData.X = t-4.25;
l(1).UserData.Y = l(1).YData(1:end-1)';