%choosing electrodes
% figure(1);
% n1=31;
% n2=32;
% all_axes = [];
% for i = n1:n2
%     ax = subplot(n2-n1+1,1,i+1-n1);
%     plot(NS2.Data(i,:));
%     ax.YLabel.String = (sprintf('EEG%2d',i));
%     ax.Visible ='off';
%     all_axes = [all_axes;ax];
% end
% linkaxes(all_axes,'x');

%Parameters
Fc=2;
Fb=2;
fdom_min = 1;
fdom_max = 200;
fdom_step = .5;
f_sub = 1000;
t_smooth = .5;
exp_cor = .5;
frame_start = 1;
frame_end = 60000;
index_eeg = 32;

% Loading trace
y = NS2.Data(index_eeg,:);
x = (1:length(y))/f_sub;
x = x(frame_start:frame_end);
y = y(frame_start:frame_end);

% Computing Wavelet
freqdom = fdom_min:fdom_step:fdom_max;
scales = Fc*f_sub./freqdom;
coefs_wav   = cmorcwt(y,scales,Fb,Fc);
Cdata = log10(abs(coefs_wav)).^2;
fprintf(' done.\n');

%Gaussian smoothing
step = t_smooth*round(f_sub);
Cdata_smooth = imgaussfilt(Cdata,[1 step]);
%Cdata_smooth = imgaussfilt(Cdata,[1 1]);

% First Tab
correction_Cdata = ones(size(Cdata_smooth));
%correction_Cdata = repmat(sqrt(freqdom(:)),1,size(Cdata,2));
%correction_Cdata = repmat(freqdom(:).^exp_cor,1,size(Cdata,2));
correction_Cdata = correction_Cdata/correction_Cdata(end,1);

figure(2);
ax1 = subplot(211);
plot(x,y);
ax1.YLabel.String = (sprintf('EEG%2d',index_eeg));
ax2 = subplot(212);
imagesc('Xdata',x,'Ydata',freqdom,'Cdata',Cdata_smooth.*correction_Cdata);
%colorbar(ax2);
ax2.YDir = 'normal';
ax2.XLim = [x(1),x(end)];
ax2.YLim = [freqdom(1),freqdom(end)];
linkaxes([ax1;ax2],'x');
colormap(ax2,'jet');
ax2.CLim(2)=10;

%Loading wavelet
