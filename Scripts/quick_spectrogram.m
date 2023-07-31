function quick_spectrogram()

global DIR_SAVE FILES CUR_FILE;
filename = FILES(CUR_FILE).nlab;

% % Loading Time Reference
% data_tr = load(fullfile(DIR_SAVE,filename,'Time_Reference.mat'));
% t = data_tr.time_ref.Y;

f = figure('Units','normalized','Name',sprintf('[%s] fUS Spectrogram',filename),'Tag','MainFigure');

% Loading Traces
d_fus = dir(fullfile(DIR_SAVE,filename,'Sources_fUS','*.mat'));
list_tracename = strrep({d_fus(:).name}','.mat','');

% Loading Time Tags
data_tt = load(fullfile(DIR_SAVE,filename,'Time_Tags.mat'));
list_tags = {data_tt.TimeTags(:).Tag}';

pu1 = uicontrol('Style','popupmenu','Units','normalized','String',list_tracename,'Position',[.1 .95 .4 .025],'Parent',f,'Tag','Popup1');
pu2 = uicontrol('Style','popupmenu','Units','normalized','String',list_tags,'Position',[.5 .95 .4 .025],'Parent',f,'Tag','Popup2');
ax1 = subplot(211,'Tag','Ax1');
ax2 = subplot(212,'Tag','Ax2');

handles = guihandles(f);
f.UserData.d_fus = d_fus;
f.UserData.data_tt = data_tt;
pu1.Callback = {@compute_spectrogram,handles};
pu2.Callback = {@compute_spectrogram,handles};

compute_spectrogram([],[],handles);

end

function compute_spectrogram(~,~,handles)

pu1 = handles.Popup1;
pu2 = handles.Popup2;
list_tracename = pu1.String;
list_tags = pu2.String;
d_fus = handles.MainFigure.UserData.d_fus;
data_tt = handles.MainFigure.UserData.data_tt;

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
try
    [p,fdom,tdom] = pspectrum(y_nn,t_nn,'spectrogram','TimeResolution',30, 'Leakage', 0);
catch
    [p,fdom,tdom] = pspectrum(y_nn,t_nn);
end


ax1 = handles.Ax1;
cla(ax1);
imagesc('XData',t_nn,'YData',fdom,'CData',log(p),'Parent',ax1);
colormap(ax1,'parula');
ax1.XLim = [t_nn(1) t_nn(end)];
ax1.YLim = [fdom(1) fdom(end)];
ax1.CLim = [-Inf log(max(p(:)))];
ax1.YLabel.String = 'Freauency (Hz)';
ax1.Title.String = tracename;

ax2 = handles.Ax2;
cla(ax2);
plot(t_nn,y_nn);
ax2.XLim = [t_nn(1) t_nn(end)];
ax2.XLabel.String = 'Time (s)';
ax2.YLabel.String = 'CBV Change (%)';
linkaxes([ax1,ax2],'x');

end



