close all;

temp = datenum(myhandles.TimeDisplay.UserData);
t = (temp-floor(temp))*24*3600;
l = findobj(myhandles.RightAxes,'Tag','Trace_Region');
index = 5;
Y=l(index).YData(1:end-1);

[Cdata_sub_int_full,freqdom,scales] = compute_wavelet(t,Y);

figure; 
ax1=subplot(211);
line('XData',t,'YData',Y,'Parent',ax1);
ax1.Title.String = l(index).UserData.Name;

ax2=subplot(212);
imagesc('XData',t,'YData',freqdom,'CData',Cdata_sub_int_full,'Parent',ax2);

ax2.YLim = [freqdom(1) freqdom(end)];

linkaxes([ax1,ax2],'x');
ax1.XLim = [t(1) t(end)];