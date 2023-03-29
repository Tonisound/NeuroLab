function script_dynamic_crosscorrelation(myhandles)%(recording_name,channel_id,band_name)

global DIR_SAVE DIR_STATS FILES;
close all;

recording_name = '20190416_SD032_P301_R_nlab'; 
channel_id = '005';
band_name = 'ripple';

channel_raw = strcat('LFP_',channel_id);
channel1 = strcat('Power-',band_name,'_',channel_id);

% all_channels_2 = {'RetrosplenialCortex';'[SR]HippocampalFormation'};%;'[SR]Thalamus'
d_channels = dir(fullfile(DIR_SAVE,recording_name,'Sources_fUS','[SR]*.mat'));
d_channels = d_channels(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_channels));
[ind_channels,v] = listdlg('Name','Region Selection','PromptString','Select Regions to display',...
    'SelectionMode','multiple','ListString',{d_channels(:).name}','InitialValue',1,'ListSize',[300 500]);
if v==0
    return;
end
all_channels_2 = strrep({d_channels(ind_channels).name}','.mat','');

n_channels = length(all_channels_2);
label1 = strrep(channel1,'_','-');
label1 = strcat('[LFP]',label1);
all_labels_2 = strrep(all_channels_2,'_','-');
all_labels_2 = strrep(all_labels_2,'[SR]','');
all_labels_2 = strcat('[fUS]',all_labels_2);

timegroup = 'NREM';
t_step = .1;
markersize = 3;
face_color = [0.9300    0.6900    0.1900];
face_alpha = .5 ;
% g_colors = get(groot,'DefaultAxesColorOrder');
f_colors =    flipud([0.2422    0.1504    0.6603;
    0.2504    0.1650    0.7076;
    0.2578    0.1818    0.7511;
    0.2647    0.1978    0.7952;
    0.2706    0.2147    0.8364;
    0.2751    0.2342    0.8710;
    0.2783    0.2559    0.8991;
    0.2803    0.2782    0.9221;
    0.2813    0.3006    0.9414;
    0.2810    0.3228    0.9579;
    0.2795    0.3447    0.9717;
    0.2760    0.3667    0.9829;
    0.2699    0.3892    0.9906;
    0.2602    0.4123    0.9952;
    0.2440    0.4358    0.9988
    0.2206    0.4603    0.9973;
    0.1963    0.4847    0.9892;
    0.1834    0.5074    0.9798;
    0.1786    0.5289    0.9682;
    0.1764    0.5499    0.9520;
    0.1687    0.5703    0.9359;
    0.1540    0.5902    0.9218;
    0.1460    0.6091    0.9079;
    0.1380    0.6276    0.8973;
    0.1248    0.6459    0.8883;
    0.1113    0.6635    0.8763;
    0.0952    0.6798    0.8598;
    0.0689    0.6948    0.8394;
    0.0297    0.7082    0.8163;
    0.0036    0.7203    0.7917;
    0.0067    0.7312    0.7660;
    0.0433    0.7411    0.7394;
    0.0964    0.7500    0.7120;
    0.1408    0.7584    0.6842;
    0.1717    0.7670    0.6554;
    0.1938    0.7758    0.6251;
    0.2161    0.7843    0.5923;
    0.2470    0.7918    0.5567;
    0.2906    0.7973    0.5188;
    0.3406    0.8008    0.4789;
    0.3909    0.8029    0.4354;
    0.4456    0.8024    0.3909;
    0.5044    0.7993    0.3480;
    0.5616    0.7942    0.3045;
    0.6174    0.7876    0.2612;
    0.6720    0.7793    0.2227;
    0.7242    0.7698    0.1910;
    0.7738    0.7598    0.1646;
    0.8203    0.7498    0.1535;
    0.8634    0.7406    0.1596;
    0.9035    0.7330    0.1774;
    0.9393    0.7288    0.2100;
    0.9728    0.7298    0.2394;
    0.9956    0.7434    0.2371;
    0.9970    0.7659    0.2199;
    0.9952    0.7893    0.2028;
    0.9892    0.8136    0.1885;
    0.9786    0.8386    0.1766;
    0.9676    0.8639    0.1643;
    0.9610    0.8890    0.1537;
    0.9597    0.9135    0.1423;
    0.9628    0.9373    0.1265;
    0.9691    0.9606    0.1064;
    0.9769    0.9839    0.0805]);
ind_colors = round(rescale((1:n_channels+1)',1,length(f_colors)));
g_colors = f_colors(ind_colors,:);
% g_colors = f_colors;

% Loading time reference
data_tr = load(fullfile(DIR_SAVE,recording_name,'Time_Reference.mat'));
% Loading atlas
data_atlas = load(fullfile(DIR_SAVE,recording_name,'Atlas.mat'));
switch data_atlas.AtlasName
    case 'Rat Coronal Paxinos'
        atlas_name = sprintf('AP=%.2fmm',data_atlas.AP_mm);
    case 'Rat Sagittal Paxinos'
        atlas_name = sprintf('ML=%.2fmm',data_atlas.ML_mm);
end

% Loading time groups
data_tg = load(fullfile(DIR_SAVE,recording_name,'Time_Groups.mat'));
ind_group = strcmp(data_tg.TimeGroups_name,timegroup);
if isempty(ind_group)
    warning('Time Group not found [%s-%s]',recording_name,timegroup);
    return;
end
S = data_tg.TimeGroups_S(ind_group);
temp = datenum(S.TimeTags_strings(:,1));
t_start = (temp-floor(temp))*24*3600;
temp = datenum(S.TimeTags_strings(:,2));
t_end = (temp-floor(temp))*24*3600;



% Loading channels
d_raw = dir(fullfile(DIR_SAVE,recording_name,'*',strcat(channel_raw,'.mat')));
d1 = dir(fullfile(DIR_SAVE,recording_name,'*',strcat(channel1,'.mat')));
d2 = [];
for i = 1:n_channels
    channel2 = char(all_channels_2(i,:));
    d2 = [d2;dir(fullfile(DIR_SAVE,recording_name,'*',strcat(channel2,'.mat')))];
end
% Loading spectrogramm
d_spectro = dir(fullfile(DIR_STATS,'Wavelet_Analysis',recording_name,'*',strcat(recording_name,'*',channel_raw,'.mat')));

if isempty(d_raw)
    warning('Channel not found [%s-%s]',recording_name,channel_raw);
    return;
else
    data_raw = load(fullfile(d_raw.folder,d_raw.name));
    Xraw = (data_raw.x_start:data_raw.f:data_raw.x_end)';
    Yraw = data_raw.Y;
end

if isempty(d1)
    warning('Channel not found [%s-%s]',recording_name,channel1);
    return;
else
    data_1 = load(fullfile(d1.folder,d1.name));
    X1 = (data_1.x_start:data_1.f:data_1.x_end)';
    Y1 = data_1.Y;
end

if isempty(d2)
    warning('Channel not found [%s-%s]',recording_name,channel2);
    return;
else
    Y2 = [];
    for i = 1:n_channels
        data_2 = load(fullfile(d2(i).folder,d2(i).name));
        X2 = data_tr.time_ref.Y;
        Y2 = [Y2,data_2.Y];
    end
end

if isempty(d_spectro)
    warning('Spectrogram not found [%s-%s]',recording_name,channel_raw);
    return;
else
    data_spectro = load(fullfile(d_spectro.folder,d_spectro.name));
end

% Interpolation
Xq = (data_tr.time_ref.Y(1):t_step:data_tr.time_ref.Y(end))';
Y1q = interp1(X1,Y1,Xq);
Y2q = interp1(X2,Y2,Xq);

% Restricting time frames and Z-scoring
X_restrict = zeros(size(Xq));
for k=1:length(S.Name)
    temp = sign((Xq-t_start(k)).*(Xq-t_end(k)));
    X_restrict = X_restrict+(temp<0);
end
% Removing NaN frames
X_NaN = (sum(isnan([Y1q,Y2q]),2))>0;
X_restrict(X_NaN==1)=0;

X = Xq(X_restrict==1);
Z1 = zscore(Y1q(X_restrict==1));
Z2 = zscore(Y2q(X_restrict==1,:));
% Z1 = Y1q;
% Z1 = bsxfun(@minus,Z1,nanmean(Z1,1));
% Z1 = bsxfun(@rdivide,Z1,nanstd(Z1,[],1));
% Z2 = Y2q;
% Z2 = bsxfun(@minus,Z2,nanmean(Z2,1));
% Z2 = bsxfun(@rdivide,Z2,nanstd(Z2,[],1));

% Cross_correlogramm
n_lags = 200;
lags = (-n_lags:n_lags)*t_step;
all_r = [];
all_lagmax = [];
all_rmax = [];
all_Z2_max = [];
% all_Z1_max = [];
X_CC = [NaN(n_lags,1);X;NaN(n_lags,1)];
    
for i = 1:n_channels
    Z1_CC = [NaN(n_lags,length(lags));repmat(Z1,[1 length(lags)]);NaN(n_lags,length(lags))];
    Z2_CC = NaN(size(Z1_CC,1),size(Z1_CC,2));
    for k=1:length(lags)
        Z2_CC(k:k+length(Z2)-1,k) = Z2(:,i);
    end
    Z2_CC = fliplr(Z2_CC);
    r = corr(Z2_CC,Z1_CC(:,1),'rows','complete');
    [rmax,ind_max] = max(r);
    lagmax = lags(ind_max);
    Z2_max=Z2_CC(:,ind_max);
    Z1_max=Z1_CC(:,1);
    
    all_r = [all_r,r];
    all_lagmax = [all_lagmax,lagmax];
    all_rmax = [all_rmax,rmax];
    all_Z2_max = [all_Z2_max,Z2_max];
%     all_Z1_max = [all_Z1_max,Z1_max];
end

% Detecting ripples
channel_ripple = '005';
channel_non_ripple = '025';
[ripples_abs,LFPrip meanVal, stdVal] = detect_ripples_abs(recording_name,channel_ripple,channel_non_ripple,timegroup);

durations = 100;
cleaning = 0;
PlotFigure = 1;
newfig = 0;
[M,T] = PlotRipRaw(LFPrip, ripples_abs(:,2), durations, cleaning, PlotFigure, newfig);

% Dynamic Cross-Correlation
% thresh = 2;
% temp = Z1_max.*Z2_max;
% live_CC = temp(~isnan(Z1_max));
% live_CC_restricted = live_CC;
% live_CC_restricted(live_CC<thresh)=NaN;
% ax3=subplot(212,'parent',f2);
% plot(X,Z1,'bo','MarkerSize',markersize);
% hold(ax3,'on');
% plot(X,Z2,'ro','MarkerSize',markersize);
% plot(X+lagmax,live_CC,'k','Parent',ax3);
% ax3.Title.String = 'Restricted to NREM bouts then Z-scored + Dynamic Cross-Correlation';
% legend(ax3,{label1;label2;'Dynamic cc'});
% ax3.XLim = [X(1) X(end)];

% Plotting
f1=figure;
f1.Name = sprintf(strcat('[%s]%s[%s-%s-dynamics]'),atlas_name,strrep(recording_name,'_nlab',''),band_name,channel_id);

colormap(f1,'jet');
ax1 = subplot(411,'parent',f1);
hold(ax1,'on');
plot(Xraw,Yraw,'Color','k','Parent',ax1);
% plot(data_spectro.X_trace,data_spectro.Y_trace,'ro','Parent',ax1)
ax1.Title.String = 'Raw trace LFP';
n_iqr1 = 4;
ax1.YLim = [median(Yraw(:))-n_iqr1*iqr(Yraw(:)),median(Yraw(:))+n_iqr1*iqr(Yraw(:))];

% % Displaying patch
% for i=1:length(t_start)
%     patch('XData',[t_start(i) t_end(i) t_end(i) t_start(i)],'YData',[ax1.YLim(1) ax1.YLim(1) ax1.YLim(2) ax1.YLim(2)],...
%         'FaceColor',face_color,'FaceAlpha',face_alpha,'EdgeColor','none','Parent',ax1,'Tag','TagPatch','HitTest','off');
% end

ax2 = subplot(412,'parent',f1);

% Correction
exp_cor = .5;
t_gauss = .1;
n_iqr2 = 1.5;
correction = repmat((data_spectro.freqdom(:).^exp_cor),1,size(data_spectro.Cdata_sub,2));
correction = correction/correction(end,1);
Cdata_corr = data_spectro.Cdata_sub.*correction;
%Gaussian smoothing
step = t_gauss*round(1/median(diff(data_spectro.Xdata_sub)));
Cdata_smooth = imgaussfilt(Cdata_corr,[1 step]);
Cdata = Cdata_smooth;

hold(ax2,'on');
im = imagesc('XData',data_spectro.Xdata_sub,'YData',data_spectro.freqdom,'CData',Cdata,'HitTest','off','Parent',ax2);
ax2.CLim = [median(Cdata(:))-n_iqr2*iqr(Cdata(:)),median(Cdata(:))+n_iqr2*iqr(Cdata(:))];
ax2.YLim = [data_spectro.freqdom(1),data_spectro.freqdom(end)];

ax3 = subplot(413,'parent',f1);
% plot(X1,Y1,'b','Parent',ax3);
hold(ax3,'on');
plot(Xq,Y1q,'Color',g_colors(1,:),'Marker','.','MarkerSize',markersize,'Parent',ax3);
for i = 1:n_channels
%     plot(X2,Y2(:,i),'r','Parent',ax3);
    plot(Xq,Y2q(:,i),'Color',g_colors(i+1,:),'Marker','.','MarkerSize',markersize,'Parent',ax3);
end
ax3.Title.String = 'Full Episode - Raw traces';
legend(ax3,cat(1,label1,all_labels_2))

ax4 = subplot(414,'parent',f1);
plot(X,Z1,'Color',g_colors(1,:),'LineStyle','none','Marker','.','MarkerSize',markersize,'Parent',ax4);
hold(ax4,'on');
for i = 1:n_channels
    plot(X,Z2(:,i),'Color',g_colors(i+1,:),'LineStyle','none','Marker','.','MarkerSize',markersize,'Parent',ax4);
end
ax4.Title.String = 'Restricted to NREM bouts then Z-scored';
leg = legend(ax4,cat(1,label1,all_labels_2));

f1_axes=[ax1;ax2;ax3;ax4];
linkaxes(f1_axes,'x');
ax1.XLim = [X(1) X(end)];

% Displaying ripples
for i=1:size(ripples_abs,1)
%     for j=1:length(f1_axes)
        ax = f1_axes(1);
        l1 = line('XData',[ripples_abs(i,1) ripples_abs(i,1)],'YData',[ax.YLim(1) ax.YLim(2)],'LineStyle','-','Color','g','Parent',ax,'Tag','EventLine','HitTest','off');
        l2 = line('XData',[ripples_abs(i,2) ripples_abs(i,2)],'YData',[ax.YLim(1) ax.YLim(2)],'LineStyle','-','Color','b','Parent',ax,'Tag','EventLine','HitTest','off');
        l3 = line('XData',[ripples_abs(i,3) ripples_abs(i,3)],'YData',[ax.YLim(1) ax.YLim(2)],'LineStyle','-','Color','r','Parent',ax,'Tag','EventLine','HitTest','off');
        l1.Color(4) = .5;
        l2.Color(4) = .5;
        l3.Color(4) = .5;
%     end
% i
end

f1b=figure;
f1b.Name = sprintf(strcat('[%s]%s[%s-%s-dynamics-detailed]'),atlas_name,strrep(recording_name,'_nlab',''),band_name,channel_id);

eps = .01;
n_windows = 6;
ratio = .65;
t_span = (X(end)-X(1))/n_windows;
f1b_axes = [];
for i=1:n_windows
    ax = copyobj(ax4,f1b);
    colormap(ax,'jet');
    im2 = copyobj(im,ax);
    if i==1
        leg2 = legend(ax,cat(1,label1,all_labels_2));
    end
    im2.YData = rescale(im.YData,ax4.YLim(1),ax4.YLim(2));
    uistack(im2,'bottom');
%     im2.AlphaData = .5;
%     all_lines = findobj(ax,'Type','line');
%     for j=1:length(all_lines)
%         all_lines(j).LineStyle = '-';
%     end
    
    ax.Title.String = '';
    ax.FontSize = 8;
    ax.Position = [.05 1-(i/n_windows)+eps .9 (ratio/n_windows)];
    ax.YLim = [im2.YData(1) im2.YData(end)];
    
    ax_ = copyobj(ax1,f1b);
%     ax_.Position = [.05 1-(i/n_windows)+(ratio/n_windows) .9 ((1-ratio)/n_windows)-eps];
    ax_.Position = [.05 ax.Position(2)+ax.Position(4) .9 ((1-ratio)/n_windows)-eps];
    ax_.Visible = 'off';
    linkaxes([ax;ax_],'x');
    
    ax.XLim = [X(1)+(i-1)*t_span X(1)+i*t_span];
    f1b_axes = [f1b_axes;ax;ax_];
end

f2=figure;
f2.Name = sprintf(strcat('[%s]%s[%s-%s-crosscorr]'),atlas_name,strrep(recording_name,'_nlab',''),band_name,channel_id);
counter = 0;
f2_axes=[];

for i =1:n_channels
    
    rmax = all_rmax(i);
    lagmax = all_lagmax(i);
    r = all_r(:,i);
    Z2_max = all_Z2_max(:,i);
    label2 = all_labels_2(i);
    
    counter = counter+1;
    ax1=subplot(2,n_channels,counter,'parent',f2);
    plot(lags,r,'Color',g_colors(i+1,:));
    hold(ax1,'on');
    % ax1.YLim = [-1 1];
    line('XData',[lagmax lagmax],'YData',[ax1.YLim(1) ax1.YLim(2)],'Color',[.5 .5 .5]);
    line('XData',[ax1.XLim(1) ax1.XLim(2)],'YData',[rmax rmax],'Color',[.5 .5 .5]);
    % ax1.Title.String = sprintf('Cross Correlation\n %s-%s',label1,label2);
    ax1.Title.String = sprintf('Cross Correlation Peak %.2f - Lag %.1f s',rmax,lagmax);
    grid(ax1,'on');
    ax1.FontSize = 8;
    
%     counter = counter+1;
    ax2=subplot(2,n_channels,counter+n_channels,'parent',f2);
    hold(ax2,'on');
    grid(ax2,'on');
    plot(Z1_max,Z2_max,'.','MarkerSize',markersize,'MarkerEdgeColor',g_colors(i+1,:),'Tag','crosscorr');
    set(ax2,'XLim',[min(Z1_max) max(Z1_max)],'YLim',[min(Z2_max) max(Z2_max)])
    line('XData',[0 0],'YData',[ax2.YLim(1) ax2.YLim(2)],'Color','k');
    line('XData',[ax2.XLim(1) ax2.XLim(2)],'YData',[0 0],'Color','k');
    ax2.XLabel.String = label1;
    ax2.YLabel.String = label2;
    r0 = corr(Z1_max,Z2_max,'rows','complete');
    ax2.Title.String = sprintf('Max-lag Correlation [r=%.2f]',r0);
    ax2.XLabel.String = label1;
    ax2.YLabel.String = label2;
%     axis(ax2,'equal');
    ax2.FontSize = 8;
    
    f2_axes=cat(2,f2_axes,[ax1;ax2]);
end

data_dir='/media/hobbes/DataMOBs171/Synthesis-fUS-Correlation';
% save_name = strcat(f1.Name,'-1');
set(f1,'Units','normalized','OuterPosition',[0 0 1 1]);
saveas(f1,fullfile(data_dir,f1.Name),'jpeg');
set(f1b,'Units','normalized','OuterPosition',[0 0 1 1]);
saveas(f1b,fullfile(data_dir,f1b.Name),'jpeg');
% save_name = strcat(f2.Name,'-2');
set(f2,'Units','normalized','OuterPosition',[0 0 1 1]);
saveas(f2,fullfile(data_dir,f2.Name),'jpeg');

xpatch = 10;
all_axes_control = [f1_axes;f1b_axes];
for i =1:length(all_axes_control)
    ax_control = all_axes_control(i);
    set(ax_control,'ButtonDownFcn',{@quick_axes_clickFcn,2,all_axes_control,xpatch});
    ax_control.UserData.X_CC = X_CC;
    ax_control.UserData.Z1_CC = Z1_CC;
    ax_control.UserData.Z2_CC = Z2_CC;
    ax_control.UserData.f2_axes = f2_axes;
    ax_control.UserData.f2 = f2;
    ax_control.UserData.t_step = t_step;
end

e1 = uicontrol('Units','normalized','Parent',f1,'Style','edit','ToolTipString','Patch Length (s)','Tag','Edit1','String',xpatch);
e1.Position = [.01 .01 .04 .04];
e1.Callback = {@e1_Callback,all_axes_control};



sb = copyobj(myhandles.ScaleButton,f1);
mb =copyobj(myhandles.MinusButton,f1);
pb = copyobj(myhandles.PlusButton,f1);
rb = copyobj(myhandles.RescaleButton,f1);
bb = copyobj(myhandles.BackButton,f1);
skb = copyobj(myhandles.SkipButton,f1);
tb = copyobj(myhandles.TagButton,f1);
ptb = copyobj(myhandles.prevTagButton,f1);
ntb = copyobj(myhandles.nextTagButton,f1);

e2 = uicontrol('Units','normalized','Parent',f1,'Style','edit','ToolTipString','Start Time','Tag','Edit2','String',xpatch);
e2.Position = [sb.Position(1) sb.Position(2)+sb.Position(4) sb.Position(3) sb.Position(4)];
% e2.Callback = {@e1_Callback,all_axes_control};
e3 = uicontrol('Units','normalized','Parent',f1,'Style','edit','ToolTipString','End Time','Tag','Edit3','String',xpatch);
e3.Position = [e2.Position(1) e2.Position(2)+e2.Position(4) e2.Position(3) e2.Position(4)];
% e3.Callback = {@e1_Callback,all_axes_control};


edits = [e2;e3];
ax_control = f1_axes(1);
set(sb,'Callback',{@template_buttonScale_Callback,ax_control});
set(ptb,'Callback',{@template_prevTag_Callback,tb,ax_control,edits});
set(ntb,'Callback',{@template_nextTag_Callback,tb,ax_control,edits});
set(pb,'Callback',{@template_buttonPlus_Callback,ax_control,edits});
set(mb,'Callback',{@template_buttonMinus_Callback,ax_control,edits});
set(rb,'Callback',{@template_buttonRescale_Callback,ax_control,edits});
set(skb,'Callback',{@template_buttonSkip_Callback,ax_control,edits});
set(bb,'Callback',{@template_buttonBack_Callback,ax_control,edits});
set(tb,'Callback',{@template_button_TagSelection_Callback,ax_control,edits,'single'});

end

function e1_Callback(hObj,~,all_axes_control)

all_axes_control = all_axes_control(isgraphics(all_axes_control));

xpatch = str2double(hObj.String);
for i =1:length(all_axes_control)
    ax_control = all_axes_control(i);
    set(ax_control,'ButtonDownFcn',{@quick_axes_clickFcn,2,all_axes_control,xpatch});
end

end

function quick_axes_clickFcn(hObj,~,version,axes,xpatch)

f = get_parentfigure(hObj);
pt_rp = get(hObj,'CurrentPoint');
Xlim = get(hObj,'XLim');
Ylim = get(hObj,'YLim');

if isgraphics(hObj.UserData.f2)
    f2_axes = squeeze(hObj.UserData.f2_axes(2,:));
else
    f2_axes = [];
end

cursor_color = 'r';
cursor_linewidth = 1;

if nargin<3
    version = 0;
end

switch version
    case 0
        % Single-line
        all_axes = hObj;
    case 1
        % Muti-line (All axes in Figure affected)
        all_axes = findobj(f,'Type','Axes');
    case 2
        % Multi-line (Only axes specified in arguments are affected)
        all_axes = axes;
        all_axes = all_axes(isgraphics(all_axes));
end

for i=1:length(all_axes)
    delete(findobj(all_axes(i),'Tag','T1'));
    delete(findobj(all_axes(i),'Tag','T2'));
    hObj.UserData.current_time = [];
end

if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
%     set(hObj,'UserData',[pt_rp(1,1),pt_rp(1,2)]);
    set(f,'WindowButtonMotionFcn', {@quick_axes_motionFcn,hObj,all_axes,xpatch});
    set(f,'WindowButtonUpFcn',@quick_axes_unclickFcn);
    
    for i=1:length(all_axes)
        line([pt_rp(1,1) pt_rp(1,1)],all_axes(i).YLim,'Tag','T1','Color',cursor_color,...
            'LineWidth',cursor_linewidth,'LineStyle','-','Parent', all_axes(i),'HitTest','off');
        patch([pt_rp(1,1)-xpatch pt_rp(1,1)-xpatch pt_rp(1,1)+xpatch pt_rp(1,1)+xpatch],[all_axes(i).YLim(1) all_axes(i).YLim(2) all_axes(i).YLim(2) all_axes(i).YLim(1)],[0.5 0.5 0.5],...
            'EdgeColor','none','Tag','T2','FaceAlpha',.5,'LineWidth',.5,'Parent', all_axes(i),'HitTest','off');
    end 
end

hObj.UserData.current_time = pt_rp(1,1);

if ~isempty(f2_axes)
    
    temp = abs((hObj.UserData.X_CC-hObj.UserData.current_time))<xpatch;
    ind_current_time = find(temp==1);
    
    for i=1:length(f2_axes)
        
        cur_ax = f2_axes(i);
        delete(findobj(cur_ax,'Tag','BigDot'));
        cur_ax.UserData.l_bigdot = [];
        bd_color = [.5 .5 .5];
        l_bigdot = line('XData',NaN,'YData',NaN,'Tag','BigDot','Parent',cur_ax,...
            'MarkerSize',10,'Marker','.','MarkerEdgeColor',bd_color,'MarkerFaceColor',bd_color,'Color',bd_color,'LineStyle','none');
        if ~isempty(ind_current_time)
            l = findobj(cur_ax,'Tag','crosscorr');
            set(l_bigdot,'XData',l.XData(ind_current_time),'YData',l.YData(ind_current_time));
        end
        cur_ax.UserData.l_bigdot = l_bigdot;
    end
end

end

function quick_axes_motionFcn(~,~,ax,all_axes,xpatch)

pt = get(ax,'CurrentPoint');
for i=1:length(all_axes)
    t1 = findobj(all_axes(i),'Tag','T1');
    set(t1,'XData',[pt(1,1) pt(1,1)]);
    t2 = findobj(all_axes(i),'Tag','T2');
    t2.XData = [pt(1,1)-xpatch pt(1,1)-xpatch pt(1,1)+xpatch pt(1,1)+xpatch];
    t2.YData = [all_axes(i).YLim(1) all_axes(i).YLim(2) all_axes(i).YLim(2) all_axes(i).YLim(1)];
end

if isgraphics(ax.UserData.f2)
    f2_axes = squeeze(ax.UserData.f2_axes(2,:));
else
    f2_axes = [];
end

ax.UserData.current_time = pt(1,1);

if ~isempty(f2_axes)
    
    temp = abs((ax.UserData.X_CC-ax.UserData.current_time))<xpatch;
    ind_current_time = find(temp==1);
    
    for i=1:length(f2_axes)
        
        cur_ax = f2_axes(i);
        l_bigdot = cur_ax.UserData.l_bigdot;
        if ~isempty(ind_current_time)
            l = findobj(cur_ax,'Tag','crosscorr');
            set(l_bigdot,'XData',l.XData(ind_current_time),'YData',l.YData(ind_current_time));
        else
            set(l_bigdot,'XData',NaN,'YData',NaN);
        end
    end
end

end

function quick_axes_unclickFcn(hObj,~)

set(hObj,'WindowButtonUp','');
set(hObj,'WindowButtonMotionFcn','');
end

