function f2 = figure_AutoCorrelation(myhandles,val,str_tag)

global DIR_SAVE FILES CUR_FILE START_IM END_IM;

% Loading Time Reference
if (exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file'))
    data_tr = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),...
        'time_ref','n_burst','length_burst','rec_mode');
else
    warning('Missing Reference Time File (%s)\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
    return;
end

% Loading Time Tags
if (exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'file'))
    data_tt = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags','TimeTags_strings','TimeTags_cell','TimeTags_images');
else
    warning('Missing Time Tags File (%s)\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
    return;
end

f2 = figure('Units','normalized',...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'MenuBar','none',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Auto Correlation Analysis');
set(f2,'Position',[.1 .1 .6 .8]);
clrmenu(f2);

% Storing Time reference
f2.UserData.success = false;
f2.UserData.time_ref = data_tr.time_ref;
f2.UserData.x_start = data_tr.time_ref.Y(1);
f2.UserData.x_end = data_tr.time_ref.Y(end);
f2.UserData.t_step = median(diff(data_tr.time_ref.Y));
% f2.UserData.n_burst = data_tr.n_burst;
% f2.UserData.length_burst = data_tr.length_burst;
% f2.UserData.rec_mode = data_tr.rec_mode;

f2.UserData.TimeTags = data_tt.TimeTags;
f2.UserData.TimeTags_strings = data_tt.TimeTags_strings;
f2.UserData.TimeTags_images = data_tt.TimeTags_images;
f2.UserData.TimeTags_cell = data_tt.TimeTags_cell;
%f2.UserData.g_colors = get(groot,'DefaultAxesColorOrder');
f2.UserData.g_colors = [0         0    0.5625;
         0         0    0.6250;
         0         0    0.6875;
         0         0    0.7500;
         0         0    0.8125;
         0         0    0.8750;
         0         0    0.9375;
         0         0    1.0000;
         0    0.0625    1.0000;
         0    0.1250    1.0000;
         0    0.1875    1.0000;
         0    0.2500    1.0000;
         0    0.3125    1.0000;
         0    0.3750    1.0000;
         0    0.4375    1.0000;
         0    0.5000    1.0000;
         0    0.5625    1.0000;
         0    0.6250    1.0000;
         0    0.6875    1.0000;
         0    0.7500    1.0000;
         0    0.8125    1.0000;
         0    0.8750    1.0000;
         0    0.9375    1.0000;
         0    1.0000    1.0000;
    0.0625    1.0000    0.9375;
    0.1250    1.0000    0.8750;
    0.1875    1.0000    0.8125;
    0.2500    1.0000    0.7500;
    0.3125    1.0000    0.6875;
    0.3750    1.0000    0.6250;
    0.4375    1.0000    0.5625;
    0.5000    1.0000    0.5000;
    0.5625    1.0000    0.4375;
    0.6250    1.0000    0.3750;
    0.6875    1.0000    0.3125;
    0.7500    1.0000    0.2500;
    0.8125    1.0000    0.1875;
    0.8750    1.0000    0.1250;
    0.9375    1.0000    0.0625;
    1.0000    1.0000         0;
    1.0000    0.9375         0;
    1.0000    0.8750         0;
    1.0000    0.8125         0;
    1.0000    0.7500         0;
    1.0000    0.6875         0;
    1.0000    0.6250         0;
    1.0000    0.5625         0;
    1.0000    0.5000         0;
    1.0000    0.4375         0;
    1.0000    0.3750         0;
    1.0000    0.3125         0;
    1.0000    0.2500         0;
    1.0000    0.1875         0;
    1.0000    0.1250         0;
    1.0000    0.0625         0;
    1.0000         0         0;
    0.9375         0         0;
    0.8750         0         0;
    0.8125         0         0;
    0.7500         0         0;
    0.6875         0         0;
    0.6250         0         0;
    0.5625         0         0;
    0.5000         0         0;];
f2.UserData.folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);

%Parameters
L = 10;                      % Height top panels
l = 1;                       % Height info panel
e1_def = '20';
e1_tip = 'Max Delay (s)';
e2_def = '.5';
e2_tip = 'Step Delay (s)';
% e3_def = '1';
% e3_tip = 'Right Delay (s)';
e4_def = '1';
e4_tip = 'LFP smoothing (s)';
e5_def = '1';
e5_tip = 'CBV smoothing (s)';
% e6_def = '20';
% e6_tip = 'Thresh_sup (s)';

% Information Panel
iP = uipanel('Units','normalized',...
    'bordertype','etchedin',...
    'Tag','InfoPanel',...
    'Parent',f2);
iP.Position = [0 0 1 l/L];

t1 = uicontrol('Units','normalized',...
    'Style','text',...
    'HorizontalAlignment','left',...
    'Parent',iP,...
    'String',sprintf('File: %s',FILES(CUR_FILE).nlab),...
    'Tag','Text1');

p = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'ToolTipString','Time Selection',...
    'String',{data_tt.TimeTags(:).Tag}',...
    'Tag','Popup1');

e_start = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','Start Time',...
    'String',myhandles.TimeDisplay.UserData(START_IM,:),...
    'Parent',iP,...
    'Tag','EditStart');
e_end = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','End Time',...
    'String',myhandles.TimeDisplay.UserData(END_IM,:),...
    'Parent',iP,...
    'Tag','EditEnd');

e1 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',iP,...
    'String',e1_def,...
    'Tag','Edit1',...
    'Tooltipstring',e1_tip);
e2 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',iP,...
    'String',e2_def,...
    'Tag','Edit2',...
    'Tooltipstring',e2_tip);
% e3 = uicontrol('Units','normalized',...
%     'Style','edit',...
%     'HorizontalAlignment','center',...
%     'Parent',iP,...
%     'String',e3_def,...
%     'Tag','Edit3',...
%     'Tooltipstring',e3_tip);
e4 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',iP,...
    'String',e4_def,...
    'Tag','Edit4',...
    'Tooltipstring',e4_tip);
e5 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',iP,...
    'String',e5_def,...
    'Tag','Edit5',...
    'Tooltipstring',e5_tip);
% e6 = uicontrol('Units','normalized',...
%     'Style','edit',...
%     'HorizontalAlignment','center',...
%     'Parent',iP,...
%     'String',e6_def,...
%     'Tag','Edit6',...
%     'Tooltipstring',e6_tip);

br = uicontrol('Units','normalized',...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Reset',...
    'Tag','ButtonReset');
bc = uicontrol('Units','normalized',...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Compute',...
    'Tag','ButtonCompute');
ba = uicontrol('Units','normalized',...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Autoscale',...
    'Tag','ButtonAutoScale');
bss = uicontrol('Units','normalized',...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Save Stats',...
    'Tag','ButtonSaveStats');
bsi = uicontrol('Units','normalized',...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Save Image',...
    'Tag','ButtonSaveImage');
bbs = uicontrol('Units','normalized',...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Batch Save',...
    'Tag','ButtonBatchSave');

mb =copyobj(myhandles.MinusButton,iP);
pb = copyobj(myhandles.PlusButton,iP);
rb = copyobj(myhandles.RescaleButton,iP);
bb = copyobj(myhandles.BackButton,iP);
skb = copyobj(myhandles.SkipButton,iP);
tb = copyobj(myhandles.TagButton,iP);
ptb = copyobj(myhandles.prevTagButton,iP);
ntb = copyobj(myhandles.nextTagButton,iP);
mb.Units='normalized';
pb.Units='normalized';
rb.Units='normalized';
bb.Units='normalized';
skb.Units='normalized';
tb.Units='normalized';
ptb.Units='normalized';
ntb.Units='normalized';

% Info Panel Position
ipos = [0 0 1 1];
t1.Position =       [ipos(3)/100     ipos(4)/2    4*ipos(3)/20   ipos(4)/3];
p.Position=     [0     ipos(4)/10    ipos(3)/6   ipos(4)/3];
e_start.Position =  [5*ipos(3)/10     2.75*ipos(4)/5   ipos(3)/12   3.5*ipos(4)/10];
e_end.Position = [5*ipos(3)/10     ipos(4)/10           ipos(3)/12   3.5*ipos(4)/10];
e1.Position = [6*ipos(3)/10      2.75*ipos(4)/5           ipos(3)/20   3.5*ipos(4)/10];
e2.Position = [6.5*ipos(3)/10      2.75*ipos(4)/5           ipos(3)/20   3.5*ipos(4)/10];
% e3.Position = [7*ipos(3)/10      2.75*ipos(4)/5           ipos(3)/20   3.5*ipos(4)/10];
e4.Position = [6*ipos(3)/10     ipos(4)/10           ipos(3)/20   3.5*ipos(4)/10];
e5.Position = [6.5*ipos(3)/10     ipos(4)/10           ipos(3)/20   3.5*ipos(4)/10];
% e6.Position = [7*ipos(3)/10     ipos(4)/10           ipos(3)/20   3.5*ipos(4)/10];

br.Position = [7.6*ipos(3)/10     ipos(4)/2     .8*ipos(3)/10   4.5*ipos(4)/10];
bc.Position = [8.4*ipos(3)/10     ipos(4)/2     .8*ipos(3)/10   4.5*ipos(4)/10];
ba.Position = [9.2*ipos(3)/10     ipos(4)/2     .8*ipos(3)/10   4.5*ipos(4)/10];
bss.Position = [7.6*ipos(3)/10     0      .8*ipos(3)/10    4.5*ipos(4)/10];
bsi.Position = [8.4*ipos(3)/10     0      .8*ipos(3)/10    4.5*ipos(4)/10];
bbs.Position = [9.2*ipos(3)/10     0      .8*ipos(3)/10    4.5*ipos(4)/10];

mb.Position =   [4*ipos(3)/20 2.75*ipos(4)/5    ipos(3)/15 3.5*ipos(4)/10];
pb.Position =   [4*ipos(3)/20 ipos(4)/10        ipos(3)/15 3.5*ipos(4)/10];
rb.Position =   [5.5*ipos(3)/20 2.75*ipos(4)/5    ipos(3)/15 3.5*ipos(4)/10];
bb.Position =   [5.5*ipos(3)/20 ipos(4)/10        ipos(3)/15 3.5*ipos(4)/10];
skb.Position =  [7*ipos(3)/20 2.75*ipos(4)/5    ipos(3)/15 3.5*ipos(4)/10];
tb.Position =   [7*ipos(3)/20 ipos(4)/10        ipos(3)/15 3.5*ipos(4)/10];
ptb.Position =  [8.5*ipos(3)/20 2.75*ipos(4)/5    ipos(3)/15 3.5*ipos(4)/10];
ntb.Position =  [8.5*ipos(3)/20 ipos(4)/10        ipos(3)/15 3.5*ipos(4)/10];

% Top Panel
tP = uipanel('Units','normalized',...
    'bordertype','etchedin',...
    'Tag','TopPanel',...
    'Parent',f2);
tP.Position = [0 l/L 1 (L-l)/L];

tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',tP,...
    'Tag','TabGroup');
tab1 = uitab('Parent',tabgp,...
    'Title','Pixels',...
    'Tag','PixelTab');
tab2 = uitab('Parent',tabgp,...
    'Title','Synthesis',...
    'Tag','SecondTab');

l_mean = findobj(myhandles.RightAxes,'Tag','Trace_Mean');
l_pixel = findobj(myhandles.RightAxes,'Tag','Trace_Pixel');
all_lines = [l_mean;l_pixel];
ax1=axes('Parent',tab1,'Tag','Ax_Pixel','Position',[.06 .04 .9 .1],'FontSize',6);
for i=1:length(all_lines)
    l_temp = copyobj(all_lines(i),ax1);
%     l_temp.XData = l_temp.XData(1:end-1);
    l_temp.XData = data_tr.time_ref.Y';
    l_temp.YData = l_temp.YData(1:end-1);
    l_temp.Visible = 'on';
end

ax2=axes('Parent',tab2,'Tag','Ax_Second','Position',[.06 .04 .9 .1],'FontSize',6);
l_temp = copyobj(l_mean,ax2);
l_temp.XData = l_temp.XData(1:end-1);
l_temp.YData = l_temp.YData(1:end-1);
l_temp.Visible = 'on';

handles2 = guihandles(f2) ;
% if ~isempty(handles2.TagButton.UserData)&&length(handles2.TagButton.UserData.Selected)>1
%     handles2.TagButton.UserData=[];
% end

handles2 = reset_Callback([],[],handles2,myhandles);
edit_Callback([handles2.EditStart handles2.EditEnd],[],handles2.CenterAxes);
colormap(f2,'jet');

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
% str_tag contains group names 
if val==0
    batchsave_Callback([],[],handles2,str_tag,1);
end

end

function handles = reset_Callback(~,~,handles,old_handles)

handles = guihandles(handles.MainFigure);
handles.CenterAxes = handles.Ax_Pixel;
tab1 = handles.PixelTab;
tab2 = handles.SecondTab;

% Callback function Attribution
pu = handles.Popup1;
pu.Callback = {@update_popup_Callback,handles};

set(handles.ButtonReset,'Callback',{@reset_Callback,handles,old_handles});
set(handles.ButtonCompute,'Callback',{@compute_autocorr_Callback,handles});
set(handles.ButtonAutoScale,'Callback',{@buttonAutoScale_Callback,handles});
set(handles.ButtonSaveImage,'Callback',{@saveimage_Callback,handles});
set(handles.ButtonSaveStats,'Callback',{@savestats_Callback,handles});
set(handles.ButtonBatchSave,'Callback',{@batchsave_Callback,handles});

% Interactive Control Buttons
edits = [handles.EditStart;handles.EditEnd];
set(handles.prevTagButton,'Callback',{@template_prevTag_Callback,handles.TagButton,handles.CenterAxes,edits});
set(handles.nextTagButton,'Callback',{@template_nextTag_Callback,handles.TagButton,handles.CenterAxes,edits});
set(handles.PlusButton,'Callback',{@template_buttonPlus_Callback,handles.CenterAxes,edits});
set(handles.MinusButton,'Callback',{@template_buttonMinus_Callback,handles.CenterAxes,edits});
set(handles.RescaleButton,'Callback',{@template_buttonRescale_Callback,handles.CenterAxes,edits});
set(handles.SkipButton,'Callback',{@template_buttonSkip_Callback,handles.CenterAxes,edits});
set(handles.BackButton,'Callback',{@template_buttonBack_Callback,handles.CenterAxes,edits});
set(handles.TagButton,'Callback',{@template_button_TagSelection_Callback,handles.CenterAxes,edits,'single'});

% Interactive Control Axes
all_axes = findobj(handles.MainFigure,'Tag','Ax_Pixel','-or','Tag','Ax_Second');
set(handles.EditStart,'Callback',{@edit_Callback,all_axes});
set(handles.EditEnd,'Callback',{@edit_Callback,all_axes});
for i=1:length(all_axes)
    set(all_axes(i),'ButtonDownFcn',{@template_axes_clickFcn,0,[],edits});
end
% Linking axes x
linkaxes(all_axes,'x');

% Display Axes
all_display_axes1 = findobj(tab1,'Tag','Ax1a','-or','Tag','Ax1b','-or','Tag','Ax1c','-or','Tag','Ax1d','-or','Tag','Ax1e','-or','Tag','Ax1f');
delete(all_display_axes1);
% ax1a=axes('Parent',tab1,'Tag','Ax1a','Position',[.1 .6 .3 .35],'FontSize',6);
ax1a = copyobj(old_handles.CenterAxes,tab1);
set(ax1a,'Tag','Ax1a','Position',[.025 .6 .3 .35],'FontSize',8);
all_children = ax1a.Children;
for i =1:length(all_children)
    if strcmp(all_children(i).Tag,'Pixel')|| strcmp(all_children(i).Tag,'MainImage')
        all_children(i).Visible='on';
    else
        all_children(i).Visible='off';
    end
end
ax1b=axes('Parent',tab1,'Tag','Ax1b','Position',[.35 .6 .3 .35],'FontSize',6);
ax1c=axes('Parent',tab1,'Tag','Ax1c','Position',[.675 .6 .3 .35],'FontSize',6);
ax1d=axes('Parent',tab1,'Tag','Ax1d','Position',[.025 .2 .3 .35],'FontSize',6);
ax1e=axes('Parent',tab1,'Tag','Ax1e','Position',[.35 .2 .3 .35],'FontSize',6);
ax1f=axes('Parent',tab1,'Tag','Ax1f','Position',[.675 .2 .3 .35],'FontSize',6);

all_display_axes2 = findobj(tab2,'Tag','Ax2a','-or','Tag','Ax2b','-or','Tag','Ax2c','-or','Tag','Ax2d');
delete(all_display_axes2);
ax2a=axes('Parent',tab2,'Tag','Ax2a','Position',[.1 .6 .3 .35],'FontSize',6);
ax2b=axes('Parent',tab2,'Tag','Ax2b','Position',[.6 .6 .3 .35],'FontSize',6);
ax2c=axes('Parent',tab2,'Tag','Ax2c','Position',[.1 .2 .3 .35],'FontSize',6);
ax2d=axes('Parent',tab2,'Tag','Ax2d','Position',[.6 .2 .3 .35],'FontSize',6);


% Execute popup Callback
pu.UserData.cur_tag = [];
pu.UserData.im_start = [];
pu.UserData.im_end = [];
pu.UserData.t_start = [];
pu.UserData.t_end = [];

template_buttonRescale_Callback(handles.RescaleButton,[],handles.CenterAxes,edits);
if ~isempty(handles.TagButton.UserData)&&length(handles.TagButton.UserData.Selected)==1
    pu.Value=handles.TagButton.UserData.Selected;
end
update_popup_Callback(pu,[],handles);

end

function edit_Callback(hObj,~,ax)
% Time edition 

if length(hObj)>1
    A = datenum(hObj(1).String);
    B1 = (A - floor(A))*24*3600;
    A = datenum(hObj(2).String);
    B2 = (A - floor(A))*24*3600;
    for i =1:length(ax)
        ax(i).XLim = [B1 B2];
    end
else
    A = datenum(hObj.String);
    B = (A - floor(A))*24*3600;
    hObj.String = datestr(B/(24*3600),'HH:MM:SS.FFF');
    
    switch hObj.Tag
        case 'EditStart'
            for i =1:length(ax)
                ax(i).XLim(1) = B;
            end
        case 'EditEnd'
            for i =1:length(ax)
                ax(i).XLim(2) = B;
            end
    end
end

end

function update_popup_Callback(hObj,~,handles)

all_axes = findobj(handles.MainFigure,'Tag','Ax_Pixel','-or','Tag','Ax_Second');
face_color = [.5 .5 .5];
face_alpha = .5;

cur_tag = strtrim(char(hObj.String(hObj.Value,:)));
% folder_name = handles.MainFigure.UserData.folder_name;
% time_ref = handles.MainFigure.UserData.time_ref;
TimeTags = handles.MainFigure.UserData.TimeTags;
TimeTags_images = handles.MainFigure.UserData.TimeTags_images;
TimeTags_strings = handles.MainFigure.UserData.TimeTags_strings;
ind_tag = find(strcmp({TimeTags(:).Tag}',cur_tag)==1);

im_start = TimeTags_images(ind_tag,1);
im_end = TimeTags_images(ind_tag,2);

temp = datenum(TimeTags_strings(ind_tag,1));
t_start = (temp-floor(temp))*24*3600+.1;
temp = datenum(TimeTags_strings(ind_tag,2));
t_end = (temp-floor(temp))*24*3600-.1;

% Displaying patch
for i = 1:length(all_axes)
    ax = all_axes(i);
    delete(findobj(ax,'Tag','TagPatch'));
    patch('XData',[t_start t_end t_end t_start],...
        'YData',[ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)],...
        'FaceColor',face_color,'FaceAlpha',face_alpha,'EdgeColor','none',...
        'Parent',ax,'Tag','TagPatch','HitTest','off');
end

% Storing
hObj.UserData.cur_tag = cur_tag;
hObj.UserData.im_start = im_start;
hObj.UserData.im_end = im_end;
hObj.UserData.t_start = t_start;
hObj.UserData.t_end = t_end;

end

function compute_autocorr_Callback(~,~,handles)

global IM;

handles.MainFigure.Pointer = 'watch';
handles.MainFigure.UserData.success = false;
tic;
drawnow;

buttonAutoScale_Callback([],[],handles);

% g_colors = handles.MainFigure.UserData.g_colors;
t_step = handles.MainFigure.UserData.t_step;
% time_ref = handles.MainFigure.UserData.time_ref;
% TimeTags = handles.MainFigure.UserData.TimeTags;
% TimeTags_strings = handles.MainFigure.UserData.TimeTags_strings;
% rec_mode = handles.MainFigure.UserData.rec_mode;
 
max_delay = str2double(handles.Edit1.String);
step_delay = str2double(handles.Edit2.String);
% thresh_step = str2double(handles.Edit4.String);
% %thresh_step = .1;
% thresh_dom = thresh_inf:thresh_step:thresh_sup;
% %marker_type = {'o','*','diamond','.'};
% markersize = str2double(handles.Edit3.String);

% Retireving timing
cur_tag = handles.Popup1.UserData.cur_tag;
im_start = handles.Popup1.UserData.im_start;
im_end = handles.Popup1.UserData.im_end;
t_start = handles.Popup1.UserData.t_start;
t_end = handles.Popup1.UserData.t_end;

% Compute auto-correlations
fprintf('Computing auto-correlation fus ...');
IM_restricted = IM(:,:,im_start:im_end);
all_pixels_aligned = reshape(IM_restricted,[size(IM_restricted,1)*size(IM_restricted,2),size(IM_restricted,3)]);
% IM_restricted_2 = reshape(all_pixels_aligned,[size(IM_restricted,1),size(IM_restricted,2),size(IM_restricted,3)]);


h = waitbar(0,'Please wait');
maxlag = ceil(max_delay/t_step);
all_r = NaN(size(all_pixels_aligned,1),2*maxlag+1);
for k = 1:size(all_pixels_aligned,1)
    prop = k/size(all_pixels_aligned,1);
    waitbar(prop,h,sprintf('Computing auto-correlation %.1f %% completed',100*prop));

    X = squeeze(all_pixels_aligned(k,:));
    [r,lags] = xcorr(X,maxlag,'coeff');
%     r = rescale(r,-1,1);
    all_r(k,:) = r;
end
close(h);

% finding peaks
h = waitbar(0,'Please wait');
all_pks = ones(size(all_pixels_aligned,1),1);
all_locs = zeros(size(all_pixels_aligned,1),1);
for k = 1:size(all_r,1)
    prop = k/size(all_r,1);
    waitbar(prop,h,sprintf('Finding peaks %.1f %% completed',100*prop));

    r = all_r(k,:);
    [pks,locs] = findpeaks(r);
    if length(pks)>1
        pks_ = pks(pks<1);
        locs_= locs(pks<1);
        [pk_max,i_max] = max(pks_);
        loc_max = locs_(i_max);
%         ind_pks = find(pks==1);
%         pk_max = pks(ind_pks+1);
%         loc_max = locs(ind_pks+1);
        all_pks(k)=pk_max;
        all_locs(k)=loc_max;
    end
end
close(h);

IM_all_r = reshape(all_r,[size(IM_restricted,1),size(IM_restricted,2),size(all_r,2)]);
IM_all_pks = reshape(all_pks,[size(IM_restricted,1),size(IM_restricted,2)]);
IM_all_locs = reshape(all_locs,[size(IM_restricted,1),size(IM_restricted,2)]);

fprintf(' done\n');

% Display results
ax1c = findobj(handles.PixelTab,'Tag','Ax1c');
cla(ax1c);
imagesc('XData',lags,'CData',all_r,'Parent',ax1c);
hold(ax1c,'on');
% line('XData',all_locs,'YData',1:length(all_locs),'Parent',ax1c,'Tag','FirstPeak',...
%     'LineStyle','none','Color','k','Linewidth',1,...
%     'MarkerSize',3,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5])
ax1c.XLim =[lags(1) lags(end)];
ax1c.YLim =[.5 size(all_r,1)+.5];
ax1c.Title.String = 'Auto-Correlation'; 
ax1c.CLim = [-1 1];
colorbar(ax1c);

ax1a = findobj(handles.PixelTab,'Tag','Ax1a');
ax1b = findobj(handles.PixelTab,'Tag','Ax1b');
cla(ax1b);
hold(ax1b,'on');
all_pixels = findobj(ax1a,'Tag','Pixel');
for i =1:length(all_pixels)
    cur_pixel = all_pixels(i);
    color = cur_pixel.MarkerFaceColor;
    color_edge = cur_pixel.MarkerEdgeColor;
    cur_r = squeeze(IM_all_r(cur_pixel.YData,cur_pixel.XData,:));
    cur_pks = IM_all_pks(cur_pixel.YData,cur_pixel.XData);
    cur_loc = IM_all_locs(cur_pixel.YData,cur_pixel.XData);
    
    line('XData',lags,'YData',cur_r,'Parent',ax1b,'Tag','AutoCorr_Pixel',...
        'LineStyle','-','Color',color,'Linewidth',1);
    
%     %re-finding peaks
%     [pks,locs] = findpeaks(cur_r);
%     if length(pks)>1
%         pks_ = pks(pks<1);
%         locs_= locs(pks<1);
%         [pk_max,i_max] = max(pks_);
%         loc_max = locs_(i_max);
%     end
%     line('XData',loc_max,'YData',pk_max,'Parent',ax1b,'Tag','AutoCorr_Max',...
%         'LineStyle','none','Color','k','Linewidth',1,...
%         'MarkerSize',6,'Marker','square','MarkerFaceColor',color,'MarkerEdgeColor',color_edge);
%     line('XData',cur_loc,'YData',cur_pks,'Parent',ax1b,'Tag','AutoCorr_Max',...
%         'LineStyle','none','Color','k','Linewidth',1,...
%         'MarkerSize',3,'Marker','square','MarkerFaceColor',color,'MarkerEdgeColor',color_edge);
end
ax1b.XLim = [lags(1) lags(end)];
hold(ax1b,'off');


ax1d = findobj(handles.PixelTab,'Tag','Ax1d');
cla(ax1d);
imagesc(IM_all_pks,'Parent',ax1d);
ax1d.XLim =[.5 size(IM_restricted,2)+.5];
ax1d.YLim =[.5 size(IM_restricted,1)+.5];
ax1d.Title.String = 'First Peak Value'; 
colorbar(ax1d);

ax1e = findobj(handles.PixelTab,'Tag','Ax1e');
cla(ax1e);
imagesc(IM_all_locs,'Parent',ax1e);
ax1e.XLim =[.5 size(IM_restricted,2)+.5];
ax1e.YLim =[.5 size(IM_restricted,1)+.5];
ax1e.Title.String = 'First Peak Location';
colorbar(ax1e);

handles.MainFigure.Pointer = 'arrow';
handles.MainFigure.UserData.success = true;


% Storing parameters
handles.MainFigure.UserData.max_delay = max_delay;
handles.MainFigure.UserData.step_delay = step_delay;
% Storing data
handles.MainFigure.UserData.IM_all_r = IM_all_r;
handles.MainFigure.UserData.IM_all_pks = IM_all_pks;
handles.MainFigure.UserData.IM_all_locs = IM_all_locs;
handles.MainFigure.UserData.S_lfp = S_lfp;
handles.MainFigure.UserData.S_fus = S_fus;

end

function buttonAutoScale_Callback(~,~,handles)

all_axes = findobj(handles.MainFigure,'Tag','Ax_Pixel','-or','Tag','Ax_Second');
for i =1:length(all_axes)
    ax = all_axes(i);
    x_start = ax.XLim(1);
    x_end = ax.XLim(2);
    lines=findobj(ax,'Tag','Trace_Pixel','-or','Tag','Trace_Mean');
    m=0;
    M=1;
    for j=1:length(lines)
        l=lines(j);
        x = l.XData;
        y = l.YData;
        [~,ind_1] = min((x-x_start).^2);
        [~,ind_2] = min((x-x_end).^2);
%         factor = max(y(ind_1:ind_2));
%         l.YData = l.YData/factor;
        M = max(max(y(ind_1:ind_2)),M);
        m = min(min(y(ind_1:ind_2)),m);
    end
    ax.YLim = [m M];
end

end

function saveimage_Callback(~,~,handles)

global FILES CUR_FILE DIR_FIG;
load('Preferences.mat','GTraces');

%Loading data
tag = char(handles.MainFigure.UserData.Tag_Selection(1));
channel = handles.MainFigure.UserData.channel;
% Creating Save Directory
save_dir = fullfile(DIR_FIG,'Cross_Correlation',FILES(CUR_FILE).recording,tag);
if ~isdir(save_dir)
    mkdir(save_dir);
end

% Saving Image
cur_tab = handles.TabGroup.SelectedTab;
handles.TabGroup.SelectedTab = handles.PixelTab;
pic_name = sprintf('%s_Cross_Correlation_traces_%s%s',FILES(CUR_FILE).recording,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.SecondTab;
pic_name = sprintf('%s_Cross_Correlation_Full_%s%s',FILES(CUR_FILE).recording,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = cur_tab;
end

function savestats_Callback(~,~,handles)

global FILES CUR_FILE DIR_STATS;
load('Preferences.mat','GTraces');

tag = char(handles.MainFigure.UserData.Tag_Selection(1));
channel = handles.MainFigure.UserData.channel;
recording = FILES(CUR_FILE).recording;
% Storing parameters
label_fus = handles.MainFigure.UserData.label_fus;
label_lfp = handles.MainFigure.UserData.label_lfp;

Tag_Selection = handles.MainFigure.UserData.Tag_Selection;
thresh_inf = handles.MainFigure.UserData.thresh_inf;
thresh_sup = handles.MainFigure.UserData.thresh_sup;
thresh_step = handles.MainFigure.UserData.thresh_step;
t_gauss_lfp = handles.MainFigure.UserData.t_gauss_lfp;
t_gauss_cbv = handles.MainFigure.UserData.t_gauss_cbv;
% Storing data
R_peak = handles.MainFigure.UserData.R_peak;
T_peak = handles.MainFigure.UserData.T_peak;
X_corr = handles.MainFigure.UserData.X_corr;
S_lfp = handles.MainFigure.UserData.S_lfp;
S_fus = handles.MainFigure.UserData.S_fus;


% Creating Stats Directory
data_dir = fullfile(DIR_STATS,'Cross_Correlation',FILES(CUR_FILE).recording,tag);
if ~isdir(data_dir)
    mkdir(data_dir);
end

% Saving data
filename = sprintf('%s_Cross_Correlation_%s.mat',FILES(CUR_FILE).recording,channel);
save(fullfile(data_dir,filename),'recording','tag','channel','label_lfp','label_fus','Tag_Selection',...
    'thresh_inf','thresh_sup','thresh_step','t_gauss_lfp','t_gauss_cbv',...
    'S_lfp','S_fus','R_peak','T_peak','X_corr','-v7.3');
fprintf('Data saved at %s.\n',fullfile(data_dir,filename));

end

function batchsave_Callback(~,~,handles,str_tag,v)

%TimeTags = handles.MainFigure.UserData.TimeTags;
%TimeTags_strings = handles.MainFigure.UserData.TimeTags_strings;
TimeTags_cell = handles.MainFigure.UserData.TimeTags_cell;

if nargin == 3
    % If Manual Callback open inputdlg
    str_tag = arrayfun(@(i) strjoin(TimeTags_cell(i,2:4),' - '), 2:size(TimeTags_cell,1), 'unif', 0)';
    [ind_tag,v] = listdlg('Name','Tag Selection','PromptString','Select Time Tags',...
        'SelectionMode','multiple','ListString',str_tag,'InitialValue','','ListSize',[300 500]);
   if isempty(ind_tag)||v==0
       return
   end
else
    % If batch mode, keep only elements in str_tag    
    ind_tag = [];
    temp = TimeTags_cell(2:end,2);
    for i=1:length(temp)
        ind_keep = ~(cellfun('isempty',strfind(str_tag,temp(i))));
        if sum(ind_keep)>0
            ind_tag=[ind_tag,i];
        end
    end
    
    % Restricts to episodes longer than 120 seconds
    tts1 = datenum(handles.MainFigure.UserData.TimeTags_strings(ind_tag,1));
    tts2 = datenum(handles.MainFigure.UserData.TimeTags_strings(ind_tag,2));
    TimeTags_seconds = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;
    TimeTags_dur = TimeTags_seconds(:,2)-TimeTags_seconds(:,1);
    ind_tag = ind_tag(TimeTags_dur>120);

end

% Compute for whole recording
edits = [handles.EditStart,handles.EditEnd];

% Compute for designated time tags
for i = 1:length(ind_tag)%size(TimeTags_strings,1)
    val = handles.Popup1.Value;
    for j =1:size(handles.Popup1.String,1)
        handles.Popup1.Value = j;
        update_popup_Callback(handles.Popup1,[],handles);
        template_button_TagSelection_Callback(handles.TagButton,[],handles.CenterAxes,edits,'single',ind_tag(i),v)
        buttonAutoScale_Callback([],[],handles);
        compute_autocorr_Callback([],[],handles);
        savestats_Callback([],[],handles);
        saveimage_Callback([],[],handles);
    end
    handles.Popup1.Value = val;
    update_popup_Callback(handles.Popup1,[],handles);
end

end
