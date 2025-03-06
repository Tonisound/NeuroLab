function quick_fUS_spectrogram()

global FILES CUR_FILE;
list_files = {FILES(:).nlab}';

% % Loading Time Reference
% data_tr = load(fullfile(DIR_SAVE,filename,'Time_Reference.mat'));
% t = data_tr.time_ref.Y;

f = figure('Units','normalized','Name','Quick fUS Spectrogram','Tag','MainFigure','Position',[.1 .2 .8 .8]);
pu0 = uicontrol('Style','popupmenu','Units','normalized','String',list_files,'Value',CUR_FILE,'Position',[0 .95 .5 .025],'Parent',f,'Tag','Popup0');
pu1 = uicontrol('Style','popupmenu','Units','normalized','String','-','Position',[.5 .95 .25 .025],'Parent',f,'Tag','Popup1');
pu2 = uicontrol('Style','popupmenu','Units','normalized','String','-','Position',[.75 .95 .25 .025],'Parent',f,'Tag','Popup2');

exc = uicontrol('Units','normalized','Style','edit','Parent',f,'String',0,'Tag','EditExpCor','Tooltipstring','Correction factor','Position',[.75 .91 .04 .025]);
exs = uicontrol('Units','normalized','Style','edit','Parent',f,'String',0,'Tag','TSmoothing','Tooltipstring','Smoothing constant','Position',[.8 .91 .04 .025]);
exf1 = uicontrol('Units','normalized','Style','edit','Parent',f,'String',0.005,'Tag','Fmin','Tooltipstring','Min Frequency','Position',[.85 .91 .04 .025]);
exf2 = uicontrol('Units','normalized','Style','edit','Parent',f,'String',0.01,'Tag','Fmax','Tooltipstring','Max Frequency','Position',[.9 .91 .04 .025]);
exfres = uicontrol('Units','normalized','Style','edit','Parent',f,'String',0.005,'Tag','EditFreqRes','Tooltipstring','Frequency Resolution','Position',[.05 .91 .04 .025]);
extres = uicontrol('Units','normalized','Style','edit','Parent',f,'String',30,'Tag','EditTimeRes','Tooltipstring','Time Resolution','Position',[.1 .91 .04 .025]);
extres.Enable = 'off';
exylim1 = uicontrol('Units','normalized','Style','edit','Parent',f,'String',0,'Tag','EditYlim1','Tooltipstring','YLim 1','Position',[.15 .91 .04 .025]);
exylim2 = uicontrol('Units','normalized','Style','edit','Parent',f,'String',0.5,'Tag','EditYlim2','Tooltipstring','YLim 2','Position',[.2 .91 .04 .025]);
exclim1 = uicontrol('Units','normalized','Style','edit','Parent',f,'String',0,'Tag','EditClim1','Tooltipstring','CLim 1','Position',[.25 .91 .04 .025]);
exclim2 = uicontrol('Units','normalized','Style','edit','Parent',f,'String',8,'Tag','EditClim2','Tooltipstring','CLim 2','Position',[.3 .91 .04 .025]);
exclim3 = uicontrol('Units','normalized','Style','checkbox','Parent',f,'Value',0,'Tag','BoxAuto','Tooltipstring','CLimMode','Position',[.35 .91 .01 .025]);


ax1 = axes('Parent',f,'Tag','Ax1','Position',[.05 .75 .9 .15]);
cbar1 = colorbar(ax1,'Position',[.955 .75 .02 .15],'Tag','Cbar1');
ax2 = axes('Parent',f,'Tag','Ax2','Position',[.05 .55 .9 .15]);

ax3 = axes('Parent',f,'Tag','Ax3','Position',[.05 .3 .2 .2]);
ax4 = axes('Parent',f,'Tag','Ax4','Position',[.275 .3 .2 .2]);
ax5 = axes('Parent',f,'Tag','Ax5','Position',[.525 .3 .2 .2]);
ax6 = axes('Parent',f,'Tag','Ax6','Position',[.75 .3 .2 .2]);

ax7 = axes('Parent',f,'Tag','Ax7','Position',[.05 .05 .2 .2]);
ax8 = axes('Parent',f,'Tag','Ax8','Position',[.275 .05 .2 .2]);
ax9 = axes('Parent',f,'Tag','Ax9','Position',[.525 .05 .2 .2]);
ax10 = axes('Parent',f,'Tag','Ax10','Position',[.75 .05 .2 .2]);


handles = guihandles(f);

pu0.Callback = {@compute_spectrogram,handles};
pu1.Callback = {@compute_spectrogram,handles};
pu2.Callback = {@compute_spectrogram,handles};

exc.Callback = {@compute_spectrogram,handles};
exs.Callback = {@compute_spectrogram,handles};
exf1.Callback = {@compute_spectrogram,handles};
exf2.Callback = {@compute_spectrogram,handles};
exfres.Callback = {@compute_spectrogram,handles};
extres.Callback = {@compute_spectrogram,handles};
exylim1.Callback = {@compute_spectrogram,handles};
exylim2.Callback = {@compute_spectrogram,handles};
exclim1.Callback = {@compute_spectrogram,handles};
exclim2.Callback = {@compute_spectrogram,handles};
exclim3.Callback = {@compute_spectrogram,handles};

compute_spectrogram(pu0,[],handles);

end

function compute_spectrogram(hObj,~,handles)

global DIR_SAVE;

pu0 = handles.Popup0;
pu1 = handles.Popup1;
pu2 = handles.Popup2;
f = handles.MainFigure;

if strcmp(hObj.Tag,'Popup0')
    
    % Loading Traces
    try
        previous_p1 = char(pu1.String(pu1.Value,:));
    catch
        previous_p1 =[];
    end
    filename = char(pu0.String(pu0.Value,:));
    d_fus = dir(fullfile(DIR_SAVE,filename,'Sources_fUS','*.mat'));
    % Removing hidden files
    d_fus = d_fus(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_fus));
    pu1.String = strrep({d_fus(:).name}','.mat','');
    if sum(strcmp(pu1.String,previous_p1))>0
        ind_tt = find(strcmp(pu1.String,previous_p1)==1);
        pu1.Value = ind_tt(1);
    else
        pu1.Value = 1;
    end
    
    % Loading Time Tags
    data_tt = load(fullfile(DIR_SAVE,filename,'Time_Tags.mat'));
    pu2.String = {data_tt.TimeTags(:).Tag}';
    if sum(strcmp(pu2.String,'Whole-fUS'))>0
        ind_tt = find(strcmp(pu2.String,'Whole-fUS')==1);
        pu2.Value = ind_tt(1);
    else
        pu2.Value = 1;
    end

    % Loading Time Tags
    try
        data_tg = load(fullfile(DIR_SAVE,filename,'Time_Groups.mat'));
    catch
        data_tg = [];
    end
    % Loading Ripple Events
    input_file = fullfile(DIR_SAVE,filename,'Events','Ripples-Sqrt-All.csv');
    [ripples,EventHeader,MetaData] = read_csv_events(input_file);

    % Storing
    f.UserData.d_fus = d_fus;
    f.UserData.data_tt = data_tt;
    f.UserData.data_tg = data_tg;
    f.UserData.ripples = ripples;
    f.UserData.EventHeader = EventHeader;
    f.UserData.MetaData = MetaData;
end

list_tracename = pu1.String;
list_tags = pu2.String;
d_fus = handles.MainFigure.UserData.d_fus;
data_tt = handles.MainFigure.UserData.data_tt;
data_tg = handles.MainFigure.UserData.data_tg;
ripples = handles.MainFigure.UserData.ripples;

% Loading fUS Trace
% tracename = 'S1BF';
tracename = pu1.String(pu1.Value,:);
ind_tracename = find(strcmp(list_tracename,tracename)==1);
if ~isempty(ind_tracename)
    data_fus = load(fullfile(d_fus(ind_tracename).folder,d_fus(ind_tracename).name));
end

% Loading tag
% tag_name = 'Whole-fUS';
tag_name = pu2.String(pu2.Value,:); 
ind_tagname = strcmp(list_tags,tag_name);
if ~isempty(ind_tagname)
    ind_start = data_tt.TimeTags_images(ind_tagname,1);
    ind_end = data_tt.TimeTags_images(ind_tagname,2);
end

X = data_fus.X(ind_start:ind_end);
Y = data_fus.Y(ind_start:ind_end);
% Removing Nan
t_nn = X(~isnan(Y));
y_nn = Y(~isnan(Y));

% Spectrogram
timeres = str2double(handles.EditTimeRes.String);
freqres = str2double(handles.EditFreqRes.String);
% flim1 = str2double(handles.EditFlim1.String);
% flim2 = str2double(handles.EditFlim2.String);
        
if strcmp(handles.EditTimeRes.Enable,'on')
    % timeres = 30;
    [p,fdom,tdom] = pspectrum(y_nn,t_nn,'spectrogram','TimeResolution',timeres);%,'FrequencyLimits',[flim1 flim2]
else
    % freqres = .01;
    [p,fdom,tdom] = pspectrum(y_nn,t_nn,'spectrogram','FrequencyResolution',freqres);%,'FrequencyLimits',[flim1 flim2]
end

ax1 = handles.Ax1;
cla(ax1);
im=imagesc('XData',t_nn,'YData',fdom,'CData',log(p),'Parent',ax1);
colormap(ax1,'parula');
ax1.XLim = [t_nn(1) t_nn(end)];
ax1.YLim = [fdom(1) fdom(end)];
ax1.CLim = [-Inf log(max(p(:)))];
ax1.YLabel.String = 'Freauency (Hz)';
% ax1.Title.String = tracename;

ax2 = handles.Ax2;
cla(ax2);
hold(ax2,'on');
plot(t_nn,y_nn,'Parent',ax2);
ax2.XLim = [t_nn(1) t_nn(end)];
ax2.XLabel.String = 'Time (s)';
ax2.YLabel.String = 'CBV Change (%)';
ax2.YLim = [min(y_nn) max(y_nn)];
linkaxes([ax1,ax2],'x');

% fprintf('Pass-band filtering %s [%.1f Hz; %.1f Hz]...',str_channel,f1,f2);
% f1 = 0.01;
f1 = str2double(handles.Fmin.String);
% f2 = 0.02;
f2 = str2double(handles.Fmax.String);
fs = 1/median(diff(data_fus.X));
[B,A]  = butter(1,[f1 f2]/(fs/2),'bandpass');
Y(isnan(Y))=0;
Y_filtered = filtfilt(B,A,Y);
plot(X,Y_filtered,'LineStyle','-','Parent',ax2);

% Gaussian smoothing
% t_gauss = 10;
t_gauss = str2double(handles.TSmoothing.String);
step = t_gauss*round(fs);
if t_gauss>0
    Cdata_smoothed = imgaussfilt(im.CData,[1 step]);
else
    Cdata_smoothed = im.CData;
end

% Correction
% exp_cor = .5;
exp_cor = str2double(handles.EditExpCor.String);
correction = repmat((fdom(:).^exp_cor),1,size(im.CData,2));
correction = correction/correction(end,1);
im.CData = Cdata_smoothed.*correction;

% ax1.CLim = [min(im.CData),max(im.CData)];
% Scaling
ylim1 = str2double(handles.EditYlim1.String);
ylim2 = str2double(handles.EditYlim2.String);
clim1 = str2double(handles.EditClim1.String);
clim2 = str2double(handles.EditClim2.String);
if handles.BoxAuto.Value
    ax1.CLimMode = 'auto';
else
    ax1.CLimMode = 'manual';
    ax1.CLim = [clim1,clim2];
end
ax1.YLim = [ylim1,ylim2];

% % Buidling phase signal
% Xq = X(1):.001:X(end);
% Y_interp = interp1(X,Y_filtered-mean(Y_filtered),Xq,'spline');
% 
% [~,locs_max]=findpeaks(Y_interp);
% time_max = Xq(locs_max);
% [~,locs_min]=findpeaks(-Y_interp);
% time_min = Xq(locs_min);
% locs_zero_crossings = find((sign(Y_interp(1:end-1)).*sign(Y_interp(2:end)))<0);
% locs_zero_ascend = locs_zero_crossings(sign(Y_interp(locs_zero_crossings))<0);
% time_zero_ascend = Xq(locs_zero_ascend);
% locs_zero_descend = locs_zero_crossings(sign(Y_interp(locs_zero_crossings))>0);
% time_zero_descend = Xq(locs_zero_descend);
% 
% Y_phase = NaN(size(Y_interp));
% Y_phase(locs_zero_ascend)=0;
% Y_phase(locs_max)=90;
% Y_phase(locs_zero_descend)=180;
% Y_phase(locs_min)=270;
% Y_phase(locs_zero_ascend-1)=360;
% Y_phase_nn = Y_phase(~isnan(Y_phase));
% X_phase_nn = Xq(~isnan(Y_phase));
% Y_phase = interp1(X_phase_nn,Y_phase_nn,Xq);
% 
% % figure;
% % ax = subplot(211);
% % plot(Xq,Y_interp,'Parent',ax);
% % hold on;
% % line('XData',time_max,'YData',Y_interp(locs_max),'Marker','o','MarkerEdgeColor','g','MarkerFaceColor','g','LineStyle','none','Parent',ax);
% % line('XData',time_min,'YData',Y_interp(locs_min),'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','LineStyle','none','Parent',ax);
% % line('XData',time_zero_ascend,'YData',Y_interp(locs_zero_ascend),'Marker','o','MarkerEdgeColor','b','MarkerFaceColor','b','LineStyle','none','Parent',ax);
% % line('XData',time_zero_descend,'YData',Y_interp(locs_zero_descend),'Marker','o','MarkerEdgeColor','y','MarkerFaceColor','y','LineStyle','none','Parent',ax);
% % line('XData',X_phase_nn,'YData',Y_phase_nn/100,'LineStyle','-','Parent',ax);
% % line('XData',Xq,'YData',Y_phase/100,'Marker','o','LineStyle','none','Parent',ax);
% 
% X_phase_ripple = [];
% Y_phase_ripple = [];
% for i=1:size(ripples,1)
%     if ripples(i,1)>X(1) && ripples(i,1)<X(end)
%         [~,ind_closest1] = min((ripples(i,1)-Xq).^2);
%         [~,ind_closest2] = min((ripples(i,2)-Xq).^2);
%         [~,ind_closest3] = min((ripples(i,3)-Xq).^2);
%         X_phase_ripple = [X_phase_ripple;Xq(ind_closest1),Xq(ind_closest2),Xq(ind_closest3)];
%         Y_phase_ripple = [Y_phase_ripple;Y_phase(ind_closest1),Y_phase(ind_closest2),Y_phase(ind_closest3)];
%     end
% %     l1 = line('XData',[ripples(i,1) ripples(i,1)],'YData',[ax.YLim(1) ax.YLim(2)],'LineWidth',1,'LineStyle','-','Color','g','Parent',ax,'Tag','EventLine','HitTest','off');
% %     l2 = line('XData',[ripples(i,2) ripples(i,2)],'YData',[ax.YLim(1) ax.YLim(2)],'LineWidth',1,'LineStyle','-','Color','b','Parent',ax,'Tag','EventLine','HitTest','off');
% %     l3 = line('XData',[ripples(i,3) ripples(i,3)],'YData',[ax.YLim(1) ax.YLim(2)],'LineWidth',1,'LineStyle','-','Color','r','Parent',ax,'Tag','EventLine','HitTest','off');
% end
% 
% % all_ripple_axes = [handles.Ax7;handles.Ax8;handles.Ax9];
% title_ripple_axes = {'Ripple start';'Ripple Peak';'Ripple End'};
% k=2;
% n_bins=4;
% cur_ax = handles.Ax7;
% cla(cur_ax);
% histogram(Y_phase_ripple(:,k),n_bins,'Parent',cur_ax,'Normalization','probability');
% cur_ax.Title.String = strcat(char(title_ripple_axes(k)),sprintf('[N=%d]',size(Y_phase_ripple,1)));
% n_bins=36;
% cur_ax = handles.Ax8;
% cla(cur_ax);
% histogram(Y_phase_ripple(:,k),n_bins,'Parent',cur_ax,'Normalization','probability');
% cur_ax.Title.String = strcat(char(title_ripple_axes(k)),sprintf('[N=%d]',size(Y_phase_ripple,1)));
% 
% 
% % Adding Time patches
% all_patch_axes = [handles.Ax3;handles.Ax4;handles.Ax5;handles.Ax6];
% list_timegroups = {'QW';'AW';'NREM';'REM'};
% patch_colors = [0.4700 0.6700 0.1900;0 0.4500 0.7400;0.9300 0.6900 0.1900;0.8500 0.3300 0.1000];
% y_inf = 1e6;
% 
% 
% % f2 = figure;
% for i =1:length(list_timegroups)
%     cur_timegroup = char(list_timegroups(i));
%     cur_ax = all_patch_axes(i);
%     cla(cur_ax);
%             
%     ind_timegroup = find(strcmp(data_tg.TimeGroups_name,cur_timegroup)==1);
%     if ~isempty(ind_timegroup)
%         temp = datenum(data_tg.TimeGroups_S(ind_timegroup).TimeTags_strings(:,1));
%         t_start = (temp-floor(temp))*24*3600;
%         temp = datenum(data_tg.TimeGroups_S(ind_timegroup).TimeTags_strings(:,2));
%         t_end = (temp-floor(temp))*24*3600;
%         tt_names = data_tg.TimeGroups_S(ind_timegroup).Name;tt_names = data_tg.TimeGroups_S(ind_timegroup).Name;
%         tt_names_keep = [];
%         all_p_sub = [];
% 
%         for j=1:length(tt_names)
%             cur_tag = tt_names(j);
%             x = [t_start(j),t_end(j),t_end(j),t_start(j)];
%             y = [-y_inf,-y_inf,y_inf,y_inf];
%             %Patch
%             patch('XData',x,'YData',y,'FaceColor',patch_colors(i,:),...
%                 'EdgeColor','none','FaceAlpha',.5,'Tag',char(tt_names(j)),'Parent',ax2);
% 
%             [~,ind_nn_start] = min((tdom-t_start(j)).^2);
%             [~,ind_nn_end] = min((tdom-t_end(j)).^2);
% 
%             if ind_nn_start<ind_nn_end
%                 p_sub = log(p(:,ind_nn_start:ind_nn_end,:));
%                 all_p_sub = cat(2,all_p_sub,p_sub);
%                 line('XData',fdom,'YData',mean(p_sub,2),'Color',patch_colors(i,:),'Parent',cur_ax);
%                 tt_names_keep = [tt_names_keep;cur_tag];
%                 cur_ax.XLim = [fdom(1) fdom(end)];
%                 cur_ax.YLim = [-10 10];
%             end         
%         end
%         if ~isempty(all_p_sub)
%             line('XData',fdom,'YData',mean(all_p_sub,2),'Color',patch_colors(i,:),'LineWidth',2,'Parent',cur_ax,'Tag',cur_timegroup);
%             tt_names_keep = [tt_names_keep;cur_timegroup];
%         end
% 
%         cur_ax.Title.String = cur_timegroup;
% %         ax2 = subplot(2,2,i,'Parent',f2);
% %         imagesc('YData',fdom,'CData',all_p_sub,'Parent',ax2);
% %         ax2.Title.String = cur_timegroup;
%     end
% end

end
