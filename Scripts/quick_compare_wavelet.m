close all;

[Cdata_sub,Xq,freqdom] = load_wavelet('20190227_SD025_P102_R_nlab','011');
f= figure;
ax1= axes;
imagesc('XData',Xq,'CData',Cdata_sub_interp,'YData',freqdom,'Parent',ax1);
ax1.XLim=[Xq(1) Xq(end)];
ax1.YLim=[freqdom(1) 250];
ax1.Title.String = 'New Wavelet';
% ax1.CLim=[freqdom(1) freqdom(end)];
colorbar

parent='/media/hobbes/DataMOBs171/NEUROLAB/NLab_Statistics/Wavelet_Analysis/20190227_SD025_P102_R_nlab/CURRENT';
file='20190227_SD025_P102_R_nlab_Wavelet_Analysis_LFP_011.mat';
d=load(fullfile(parent,file));
f= figure;
ax2= axes;
imagesc('XData',d.Xdata_sub,'CData',d.Cdata_sub,'YData',d.freqdom,'Parent',ax2);
ax2.XLim=[d.Xdata_sub(1) d.Xdata_sub(end)];
ax2.YLim=[d.freqdom(1) 250];
ax2.Title.String = 'Old Wavelet';
% ax2.CLim=[freqdom(1) freqdom(end)];
colorbar