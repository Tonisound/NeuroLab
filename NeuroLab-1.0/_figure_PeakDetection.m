function f2 = figure_PeakDetection(myhandles,val,str_tag)

global DIR_SAVE FILES CUR_FILE START_IM END_IM;

% Loading Time Reference
if (exist(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Reference.mat'),'file'))
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Reference.mat'),'time_ref','n_burst','length_burst');
else
    warning('Missing Reference Time File (%s)\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus));
    return;
end
% Loading Time Tags
if (exist(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'file'))
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags','TimeTags_strings','TimeTags_cell');
else
    warning('Missing Time Tags File (%s)\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus));
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
    'Name','Peak Detection');
set(f2,'Position',[.1 .1 .6 .6]);
clrmenu(f2);

% Storing Time reference
f2.UserData.time_ref = time_ref;
f2.UserData.n_burst = n_burst;
f2.UserData.length_burst = length_burst;
f2.UserData.TimeTags = TimeTags;
f2.UserData.TimeTags_strings = TimeTags_strings;
f2.UserData.TimeTags_cell = TimeTags_cell;
f2.UserData.g_colors = get(groot,'DefaultAxesColorOrder');

%Parameters
L = 10;                      % Height top panels
l = 1;                       % Height info panel
cb1_def = 1;
cb1_tip = 'Legend Visibility';
cb2_def = 1;
cb2_tip = 'Dot Visibility';
cb3_def = 0;
cb3_tip = 'Tick Visibility';
e3_def = '1';
e3_tip = 'LFP Gaussian smoothing';
e4_def = '1';
e4_tip = 'CBV Gaussian smoothing';
e5_def = '5';
e5_tip = 'Marker Size';
e6_def = '.5';
e6_tip = 'Line Width';
e7_def = '-1';
e7_tip = 'Thresh_inf (s)';
e8_def = '4';
e8_tip = 'Thresh_sup (s)';

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
    'String',sprintf('File : %s\n (Source : %s) ',FILES(CUR_FILE).gfus,strtrim(myhandles.CenterPanelPopup.String(myhandles.CenterPanelPopup.Value,:))),...
    'Tag','Text1');

p = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'ToolTipString','Channel Selection',...
    'Tag','Popup1');
p.UserData.index=1;
str = load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Trace_LFP.mat'),'traces');
str = str.traces(~cellfun('isempty',strfind(str.traces(:,1),'LFP'))==1,1);
str = regexprep(str,'LFP/','');
str = regexprep(str,'LFP-theta/','');
p.String = flipud(unique(str));

e1 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','Start Time',...
    'String',myhandles.TimeDisplay.UserData(START_IM,:),...
    'Parent',iP,...
    'Tag','Edit1');
e2 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','End Time',...
    'String',myhandles.TimeDisplay.UserData(END_IM,:),...
    'Parent',iP,...
    'Tag','Edit2');

e3 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',iP,...
    'String',e3_def,...
    'Tag','Edit3',...
    'Tooltipstring',e3_tip);
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
e6 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',iP,...
    'String',e6_def,...
    'Tag','Edit6',...
    'Tooltipstring',e6_tip);
e7 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',iP,...
    'String',e7_def,...
    'Tag','Edit7',...
    'Tooltipstring',e7_tip);
e8 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',iP,...
    'String',e8_def,...
    'Tag','Edit8',...
    'Tooltipstring',e8_tip);

cb1 = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Parent',iP,...
    'Value',cb1_def,...
    'Tag','Checkbox1',...
    'Tooltipstring',cb1_tip);
cb2 = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Parent',iP,...
    'Value',cb2_def,...
    'Tag','Checkbox2',...
    'Tooltipstring',cb2_tip);
cb3 = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Parent',iP,...
    'Value',cb3_def,...
    'Tag','Checkbox3',...
    'Tooltipstring',cb3_tip);

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
t1.Position =       [ipos(3)/100     ipos(4)/2    4*ipos(3)/20   ipos(4)/2];
p.Position=     [0     ipos(4)/10    ipos(3)/6   ipos(4)/3];
e1.Position =  [5*ipos(3)/10     2.75*ipos(4)/5   ipos(3)/12   3.5*ipos(4)/10];
e2.Position = [5*ipos(3)/10     ipos(4)/10           ipos(3)/12   3.5*ipos(4)/10];
e3.Position = [6*ipos(3)/10      2.75*ipos(4)/5           ipos(3)/20   3.5*ipos(4)/10];
e4.Position = [6*ipos(3)/10     ipos(4)/10           ipos(3)/20   3.5*ipos(4)/10];
e5.Position = [6.5*ipos(3)/10      2.75*ipos(4)/5           ipos(3)/20   3.5*ipos(4)/10];
e6.Position = [6.5*ipos(3)/10     ipos(4)/10           ipos(3)/20   3.5*ipos(4)/10];
e7.Position = [7*ipos(3)/10      2.75*ipos(4)/5           ipos(3)/20   3.5*ipos(4)/10];
e8.Position = [7*ipos(3)/10     ipos(4)/10           ipos(3)/20   3.5*ipos(4)/10];

cb1.Position = [11.65*ipos(3)/20     2*ipos(4)/3.25           ipos(3)/55   ipos(4)/4];
cb2.Position = [11.65*ipos(3)/20     ipos(4)/3.25           ipos(3)/55   ipos(4)/4];
cb3.Position = [11.65*ipos(3)/20     0           ipos(3)/55   ipos(4)/4];
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
tab0 = uitab('Parent',tabgp,...
    'Title','Traces',...
    'Tag','MainTab');
uitab('Parent',tabgp,...
    'Title','Raster-y',...
    'Tag','FirstTab');
uitab('Parent',tabgp,...
    'Title','Timing-y',...
    'Tag','SecondTab');
uitab('Parent',tabgp,...
    'Title','Raster-dydt',...
    'Tag','ThirdTab');
uitab('Parent',tabgp,...
    'Title','Timing-dydt',...
    'Tag','FourthTab');
tab5 = uitab('Parent',tabgp,...
    'Title','Synthesis',...
    'Tag','FifthTab');
tab6 = uitab('Parent',tabgp,...
    'Title','Continuous',...
    'Tag','SixthTab');

%Traces
subplot(311,'Parent',tab0,'Tag','Ax1');
subplot(312,'Parent',tab0,'Tag','Ax2');
subplot(313,'Parent',tab0,'Tag','Ax3');
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .68 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','glow','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .72 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','gmid','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .76 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','gmidup','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .8 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ghigh','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .84 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ghighup','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .88 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ripple','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .92 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','theta','Value',1);

uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .41 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ycortex','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .45 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','yhpc','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .49 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ythal','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .53 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ywhole','Value',1);

uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .08 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','dcortex','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .12 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','dhpc','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .16 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','dthal','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .2 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','dwhole','Value',1);

% Synthesis
subplot(221,'Parent',tab5,'Tag','Ax4');
subplot(222,'Parent',tab5,'Tag','Ax5');
subplot(223,'Parent',tab5,'Tag','Ax6');
subplot(224,'Parent',tab5,'Tag','Ax7');
axes('Parent',tab6,'Tag','Ax8','Position',[.1 .775 .8 .2]);
axes('Parent',tab6,'Tag','Ax9','Position',[.1 .55 .8 .2]);
axes('Parent',tab6,'Tag','Ax10','Position',[.1 .05 .35 .4]);
axes('Parent',tab6,'Tag','Ax11','Position',[.55 .05 .35 .4]);

handles2 = guihandles(f2) ;
if ~isempty(handles2.TagButton.UserData)&&length(handles2.TagButton.UserData.Selected)>1
    handles2.TagButton.UserData=[];
end

handles2 = reset_Callback([],[],handles2,myhandles);
colormap(f2,'jet');
edit_Callback([handles2.Edit1 handles2.Edit2],[],handles2.CenterAxes);

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
% str_tag contains group names 
if val==0
    batchsave_Callback([],[],handles2,str_tag,1);
end

end

function boxVisible_Callback(hObj,~)

l = findobj(hObj.Parent,'Tag',hObj.String);
%ylim = l(1).Parent.YLim;
if hObj.Value
    for i =1:length(l)
        l(i).Visible = 'on';
    end
else
    for i =1:length(l)
        l(i).Visible = 'off';
    end
end
%l(1).Parent.YLim = ylim;

end

function handles = reset_Callback(~,~,handles,old_handles)

handles = guihandles(handles.MainFigure);
handles.CenterAxes = handles.Ax1;
all_axes = findobj(handles.MainTab,'Type','Axes');

% Callback function Attribution
% Loading traces
pu = handles.Popup1;
traces = flipud(findobj(old_handles.RightAxes,'Tag','Trace_Spiko'));
handles.MainFigure.UserData.traces = traces;
pu.Callback = {@update_popup_Callback,handles};
update_popup_Callback(pu,[],handles);

% Draw CBV traces
update_cbv_traces(handles,old_handles);

% BoxVisible
boxes = findobj(handles.MainFigure,'Tag','BoxVisible');
for i =1:length(boxes)
    boxVisible_Callback(boxes(i),[]);
end

set(handles.Edit1,'Callback',{@edit_Callback,all_axes});
set(handles.Edit2,'Callback',{@edit_Callback,all_axes});
set(handles.Checkbox1,'Callback',{@checkbox1_Callback,handles});
set(handles.Checkbox2,'Callback',{@checkbox2_Callback,handles});
set(handles.Checkbox3,'Callback',{@checkbox3_Callback,handles});

set(handles.ButtonReset,'Callback',{@reset_Callback,handles,old_handles});
set(handles.ButtonCompute,'Callback',{@compute_peaks_Callback,handles});
set(handles.ButtonAutoScale,'Callback',{@buttonAutoScale_Callback,handles});
set(handles.ButtonSaveImage,'Callback',{@saveimage_Callback,handles});
set(handles.ButtonSaveStats,'Callback',{@savestats_Callback,handles});
set(handles.ButtonBatchSave,'Callback',{@batchsave_Callback,handles});

%Interactive Control
edits = [handles.Edit1;handles.Edit2];
set(handles.prevTagButton,'Callback',{@template_prevTag_Callback,handles.TagButton,handles.CenterAxes,edits});
set(handles.nextTagButton,'Callback',{@template_nextTag_Callback,handles.TagButton,handles.CenterAxes,edits});
set(handles.PlusButton,'Callback',{@template_buttonPlus_Callback,handles.CenterAxes,edits});
set(handles.MinusButton,'Callback',{@template_buttonMinus_Callback,handles.CenterAxes,edits});
set(handles.RescaleButton,'Callback',{@template_buttonRescale_Callback,handles.CenterAxes,edits});
set(handles.SkipButton,'Callback',{@template_buttonSkip_Callback,handles.CenterAxes,edits});
set(handles.BackButton,'Callback',{@template_buttonBack_Callback,handles.CenterAxes,edits});
set(handles.TagButton,'Callback',{@template_button_TagSelection_Callback,handles.CenterAxes,edits,'single'});

% All Axes
for i=1:length(all_axes)
    set(all_axes(i),'ButtonDownFcn',{@template_axes_clickFcn,0,edits});
end

% Clear secondary panels
all_tabs = findobj([handles.FirstTab;handles.SecondTab;handles.ThirdTab;handles.FourthTab;handles.FifthTab;handles.SixthTab],'Type','axes');
for i =1:length(all_tabs)
    delete(all_tabs(i).Children);
end

% Legend/ticks Dipslay
checkbox1_Callback(handles.Checkbox1,[],handles);
checkbox2_Callback(handles.Checkbox2,[],handles);
checkbox3_Callback(handles.Checkbox3,[],handles);

% Linking axes x
linkaxes([handles.Ax1;handles.Ax2;handles.Ax3],'x');
buttonAutoScale_Callback([],[],handles);

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
        case 'Edit1'
            for i =1:length(ax)
                ax(i).XLim(1) = B;
            end
        case 'Edit2'
            for i =1:length(ax)
                ax(i).XLim(2) = B;
            end
    end
end

end

function update_popup_Callback(pu,~,handles)

% Extracting EEG curves
traces = handles.MainFigure.UserData.traces;
ax = handles.Ax1;
channel = char(pu.String(pu.Value,:));
str_traces = [];
ind_keep = zeros(length(traces),1);
for i =1 : length(traces)
    if ~isempty(strfind(traces(i).UserData.Name,channel))
        ind_keep(i) = 1;
        str_traces =[str_traces;{traces(i).UserData.Name}];
    end
end

traces = traces(ind_keep==1);
ind_glow = ~(cellfun('isempty',strfind(str_traces,'Gamma-low/')));
ind_gmid = ~(cellfun('isempty',strfind(str_traces,'Gamma-mid/')));
ind_gmidup = ~(cellfun('isempty',strfind(str_traces,'Gamma-mid-up')));
ind_ghigh = ~(cellfun('isempty',strfind(str_traces,'Gamma-high/')));
ind_ghighup = ~(cellfun('isempty',strfind(str_traces,'Gamma-high-up/')));
ind_ripple = ~(cellfun('isempty',strfind(str_traces,'Ripple/')));
ind_theta = ~(cellfun('isempty',strfind(str_traces,'Phasic-theta/')));
x_glow = traces(ind_glow).UserData.X(:);
y_glow = traces(ind_glow).UserData.Y(:);
x_gmid = traces(ind_gmid).UserData.X(:);
y_gmid = traces(ind_gmid).UserData.Y(:);
x_gmidup = traces(ind_gmidup).UserData.X(:);
y_gmidup = traces(ind_gmidup).UserData.Y(:);
x_ghigh = traces(ind_ghigh).UserData.X(:);
y_ghigh = traces(ind_ghigh).UserData.Y(:);
x_ghighup = traces(ind_ghighup).UserData.X(:);
y_ghighup = traces(ind_ghighup).UserData.Y(:);
x_ripple = traces(ind_ripple).UserData.X(:);
y_ripple = traces(ind_ripple).UserData.Y(:);
x_theta = traces(ind_theta).UserData.X(:);
y_theta = traces(ind_theta).UserData.Y(:);

% Computing factors & delta
x_start = ax.XLim(1);
x_end = ax.XLim(2);
t_gauss = str2double(handles.Edit3.String);

x = x_glow;
y = y_glow;
[~,ind_1_glow] = min((x-x_start).^2);
[~,ind_2_glow] = min((x-x_end).^2);
factor_glow = max(y(ind_1_glow:ind_2_glow));
delta_glow = x_glow(2)-x_glow(1);
y_glow = imgaussfilt(y_glow/factor_glow,round(t_gauss/delta_glow));

x = x_gmid;
y = y_gmid;
[~,ind_1_gmid] = min((x-x_start).^2);
[~,ind_2_gmid] = min((x-x_end).^2);
factor_gmid = max(y(ind_1_gmid:ind_2_gmid));
delta_gmid = x_gmid(2)-x_gmid(1);
y_gmid = imgaussfilt(y_gmid/factor_gmid,round(t_gauss/delta_gmid));

x = x_gmidup;
y = y_gmidup;
[~,ind_1_gmidup] = min((x-x_start).^2);
[~,ind_2_gmidup] = min((x-x_end).^2);
factor_gmidup = max(y(ind_1_gmidup:ind_2_gmidup));
delta_gmidup = x_gmidup(2)-x_gmidup(1);
y_gmidup = imgaussfilt(y_gmidup/factor_gmidup,round(t_gauss/delta_gmidup));

x = x_ghigh;
y = y_ghigh;
[~,ind_1_ghigh] = min((x-x_start).^2);
[~,ind_2_ghigh] = min((x-x_end).^2);
factor_ghigh = max(y(ind_1_ghigh:ind_2_ghigh));
delta_ghigh = x_ghigh(2)-x_ghigh(1);
y_ghigh = imgaussfilt(y_ghigh/factor_ghigh,round(t_gauss/delta_ghigh));

x = x_ghighup;
y = y_ghighup;
[~,ind_1_ghighup] = min((x-x_start).^2);
[~,ind_2_ghighup] = min((x-x_end).^2);
factor_ghighup = max(y(ind_1_ghighup:ind_2_ghighup));
delta_ghighup = x_ghighup(2)-x_ghighup(1);
y_ghighup = imgaussfilt(y_ghighup/factor_ghighup,round(t_gauss/delta_ghighup));

x = x_ripple;
y = y_ripple;
[~,ind_1_ripple] = min((x-x_start).^2);
[~,ind_2_ripple] = min((x-x_end).^2);
factor_ripple = max(y(ind_1_ripple:ind_2_ripple));
delta_ripple = x_ripple(2)-x_ripple(1);
y_ripple = imgaussfilt(y_ripple/factor_ripple,round(t_gauss/delta_ripple));

x = x_theta;
y = y_theta;
[~,ind_1_theta] = min((x-x_start).^2);
[~,ind_2_theta] = min((x-x_end).^2);
factor_theta = max(y(ind_1_theta:ind_2_theta));
delta_theta = x_theta(2)-x_theta(1);
y_theta = imgaussfilt(y_theta/factor_theta,round(t_gauss/delta_theta));

% Plotting
g_colors = handles.MainFigure.UserData.g_colors;
delete(ax.Children);
hold(ax,'on');
plot(x_glow,y_glow,'Tag','glow','LineWidth',2,'Parent',ax,'Color',g_colors(1,:));
plot(x_gmid,y_gmid,'Tag','gmid','LineWidth',2,'Parent',ax,'Color',g_colors(2,:));
plot(x_gmidup,y_gmidup,'Tag','gmidup','LineWidth',2,'Parent',ax,'Color',g_colors(3,:));
plot(x_ghigh,y_ghigh,'Tag','ghigh','LineWidth',2,'Parent',ax,'Color',g_colors(4,:));
plot(x_ghighup,y_ghighup,'Tag','ghighup','LineWidth',2,'Parent',ax,'Color',g_colors(5,:));
plot(x_ripple,y_ripple,'Tag','ripple','LineWidth',2,'Parent',ax,'Color',g_colors(6,:));
plot(x_theta,y_theta,'k','Tag','theta','LineWidth',.5,'Parent',ax);
ax.YLabel.String = 'LFP filtered'; 
legend(ax,{'gamma low';'gamma mid';'gamma mid up';'gamma high';'gamma high up';'ripple';'theta'},'Tag','Legend');
hold(ax,'off');

% Storing
handles.MainFigure.UserData.t_gauss_lfp = t_gauss;
handles.MainFigure.UserData.x_glow = x_glow;
handles.MainFigure.UserData.y_glow = y_glow;
handles.MainFigure.UserData.x_gmid = x_gmid;
handles.MainFigure.UserData.y_gmid = y_gmid;
handles.MainFigure.UserData.x_gmidup = x_gmidup;
handles.MainFigure.UserData.y_gmidup = y_gmidup;
handles.MainFigure.UserData.x_ghigh = x_ghigh;
handles.MainFigure.UserData.y_ghigh = y_ghigh;
handles.MainFigure.UserData.x_ghighup = x_ghighup;
handles.MainFigure.UserData.y_ghighup = y_ghighup;
handles.MainFigure.UserData.x_ripple = x_ripple;
handles.MainFigure.UserData.y_ripple = y_ripple;
handles.MainFigure.UserData.x_theta = x_theta;
handles.MainFigure.UserData.y_theta = y_theta;
% Storing 
handles.MainFigure.UserData.delta_glow = delta_glow;
handles.MainFigure.UserData.delta_gmid = delta_gmid;
handles.MainFigure.UserData.delta_gmidup = delta_gmidup;
handles.MainFigure.UserData.delta_ghigh = delta_ghigh;
handles.MainFigure.UserData.delta_ghighup = delta_ghighup;
handles.MainFigure.UserData.delta_ripple = delta_ripple;
handles.MainFigure.UserData.delta_theta = delta_theta;

end

function update_cbv_traces(handles,myhandles)

ax1 = handles.Ax2;
t_gauss = str2double(handles.Edit4.String);
x_im = [handles.MainFigure.UserData.time_ref.Y;NaN];
tit_legend = {'cortex';'hpc';'thal';'whole'};

% Loading lines
lines = flipud(findobj(myhandles.RightAxes,'Tag','Trace_Region'));
ind_hpc = [];
ind_thal = [];
ind_cortex = [];
% for i =1:length(lines)
%     str = lower(lines(i).UserData.Name);
%     if ~isempty(strfind(str,'ca1'))||...
%             ~isempty(strfind(str,'ca2'))||...
%             ~isempty(strfind(str,'ca3'))||...
%             ~isempty(strfind(str,'dg'))||...
%             ~isempty(strfind(str,'subic'))||...
%             ~isempty(strfind(str,'lent-'))
%         ind_hpc = [ind_hpc;i];
%     elseif ~isempty(strfind(str,'thalamus'))
%         ind_thal = [ind_thal;i];
%     elseif ~isempty(strfind(str,'rs-'))||...
%             ~isempty(strfind(str,'ac-'))||...
%             ~isempty(strfind(str,'s1'))||...
%             ~isempty(strfind(str,'lpta'))||...
%             ~isempty(strfind(str,'m12'))||...
%             ~isempty(strfind(str,'v1'))||...
%             ~isempty(strfind(str,'v2'))||...
%             ~isempty(strfind(str,'cg-'))||...
%             ~isempty(strfind(str,'cx-'))||...
%             ~isempty(strfind(str,'ptp'))
%         ind_cortex = [ind_cortex;i];
%     end
% end
for i =1:length(lines)
    str = lower(lines(i).UserData.Name);
    if ~isempty(strfind(str,'dhpc'))||...
            ~isempty(strfind(str,'vhpc'))
        ind_hpc = [ind_hpc;i];
    elseif ~isempty(strfind(str,'thalamus'))
        ind_thal = [ind_thal;i];
    elseif ~isempty(strfind(str,'cortex-'))
        ind_cortex = [ind_cortex;i];
    end
end

lines_cortex = lines(ind_cortex);
lines_hpc = lines(ind_hpc);
lines_thal = lines(ind_thal);
lines_whole = findobj(myhandles.RightAxes,'Tag','Trace_Mean');

if isempty(lines_cortex)
    y_cortex = rand(size(lines_whole.YData));
    tit_legend(1)={'rand'};
else
    % Extracting main regions average
    coeff = [];
    data = [];
    for i = 1:length(lines_cortex)
        l = lines_cortex(i);
        coeff = [coeff;sum(sum(l.UserData.Mask))*ones(1,length(l.YData))];
        data = [data; l.YData];
    end
    coeff = coeff/sum(coeff(:,1));
    y_cortex = sum(coeff.*data,1);
end

if isempty(lines_hpc)
    y_hpc = rand(size(lines_whole.YData));
    tit_legend(2)={'rand'};
else
    coeff = [];
    data = [];
    for i = 1:length(lines_hpc)
        l = lines_hpc(i);
        coeff = [coeff;sum(sum(l.UserData.Mask))*ones(1,length(l.YData))];
        data = [data; l.YData];
    end
    coeff = coeff/sum(coeff(:,1));
    y_hpc = sum(coeff.*data,1);
end

if isempty(lines_thal)
    y_thal = rand(size(lines_whole.YData));
    tit_legend(3)={'rand'};
else
    coeff = [];
    data = [];
    for i = 1:length(lines_thal)
        l = lines_thal(i);
        coeff = [coeff;sum(sum(l.UserData.Mask))*ones(1,length(l.YData))];
        data = [data; l.YData];
    end
    coeff = coeff/sum(coeff(:,1));
    y_thal = sum(coeff.*data,1);
end

y_whole = lines_whole.YData;

% Gaussian Smoothing
delta = x_im(2)-x_im(1);
y_cortex = imgaussfilt(y_cortex,round(t_gauss/delta));
y_hpc = imgaussfilt(y_hpc,round(t_gauss/delta));
y_thal = imgaussfilt(y_thal,round(t_gauss/delta));
y_whole = imgaussfilt(y_whole,round(t_gauss/delta));

% Plotting fus
g_colors = handles.MainFigure.UserData.g_colors;
delete(ax1.Children);
hold(ax1,'on');
plot(x_im,y_cortex,'Tag','ycortex','LineWidth',2,'Parent',ax1,'Color',g_colors(1,:))
plot(x_im,y_hpc,'Tag','yhpc','LineWidth',2,'Parent',ax1,'Color',g_colors(2,:))
plot(x_im,y_thal,'Tag','ythal','LineWidth',2,'Parent',ax1,'Color',g_colors(3,:))
plot(x_im,y_whole,'k','Tag','ywhole','LineWidth',.5,'Parent',ax1);
ax1.YLabel.String = 'CBV traces';
legend(ax1,tit_legend,'Tag','Legend');
hold(ax1,'off');

% Time derivative
ax2 = handles.Ax3;
y = y_cortex;
d_cortex = interp1(.5:length(y)+.5,[NaN,diff(y),NaN],1:length(y));
y = y_hpc;
d_hpc = interp1(.5:length(y)+.5,[NaN,diff(y),NaN],1:length(y));
y = y_thal;
d_thal = interp1(.5:length(y)+.5,[NaN,diff(y),NaN],1:length(y));
y = y_whole;
d_whole = interp1(.5:length(y)+.5,[NaN,diff(y),NaN],1:length(y));

% Thresholding
thresh = .0;
val_thresh = 0;
d_cortex(d_cortex<thresh) = val_thresh;
d_hpc(d_hpc<thresh) = val_thresh;
d_thal(d_thal<thresh) = val_thresh;
d_whole(d_whole<thresh) = val_thresh;

% Gaussian Smoothing
delta = x_im(2)-x_im(1);
d_cortex = imgaussfilt(d_cortex,round(t_gauss/delta));
d_hpc = imgaussfilt(d_hpc,round(t_gauss/delta));
d_thal = imgaussfilt(d_thal,round(t_gauss/delta));
d_whole = imgaussfilt(d_whole,round(t_gauss/delta));

% Drawing derivative
g_colors = handles.MainFigure.UserData.g_colors;
delete(ax2.Children);
hold(ax2,'on');
plot(x_im,d_cortex,'Tag','dcortex','LineWidth',2,'Parent',ax2,'Color',g_colors(1,:))
plot(x_im,d_hpc,'Tag','dhpc','LineWidth',2,'Parent',ax2,'Color',g_colors(2,:))
plot(x_im,d_thal,'Tag','dthal','LineWidth',2,'Parent',ax2,'Color',g_colors(3,:))
plot(x_im,d_whole,'k','Tag','dwhole','LineWidth',.5,'Parent',ax2);
ax2.YLabel.String = 'CBV derivatives';
legend(ax2,tit_legend,'Tag','Legend');
hold(ax2,'off');

CBV_data = NaN(length(lines),length(x_im));
dCBVdt_data = NaN(length(lines),length(x_im));
label_channels = cell(length(lines),1);
for i =1:length(lines)
    label_channels(i) = {lines(i).UserData.Name};
    y = lines(i).YData;
    y = imgaussfilt(y,round(t_gauss/delta));
    d_y = interp1(.5:length(y)+.5,[NaN,diff(y),NaN],1:length(y));
    d_y(d_y<thresh) = val_thresh;
    d_y = imgaussfilt(d_y,round(t_gauss/delta));
    CBV_data(i,:) = y;
    dCBVdt_data(i,:) = d_y;
end

% Storing 
handles.MainFigure.UserData.t_gauss_cbv = t_gauss;
handles.MainFigure.UserData.x_im = x_im;
handles.MainFigure.UserData.y_cortex = y_cortex;
handles.MainFigure.UserData.y_hpc = y_hpc;
handles.MainFigure.UserData.y_thal = y_thal;
handles.MainFigure.UserData.y_whole = y_whole;
handles.MainFigure.UserData.d_cortex = d_cortex;
handles.MainFigure.UserData.d_hpc = d_hpc;
handles.MainFigure.UserData.d_thal = d_thal;
handles.MainFigure.UserData.d_whole = d_whole;
handles.MainFigure.UserData.tit_legend = tit_legend;
handles.MainFigure.UserData.CBV_data = CBV_data;
handles.MainFigure.UserData.dCBVdt_data = dCBVdt_data;
handles.MainFigure.UserData.label_channels = label_channels;

end

function checkbox1_Callback(hObj,~,handles)
% Display legend

l = findobj(handles.MainFigure,'Tag','Legend');
if hObj.Value
    for i =1:length(l)
        l(i).Visible ='on';
    end
else
    for i =1:length(l)
        l(i).Visible ='off';
    end
end

end

function checkbox2_Callback(hObj,~,handles)
% Display dots

l = findobj(handles.MainFigure,'Tag','Dot_peak');
if hObj.Value
    for i =1:length(l)
        l(i).Visible ='on';
    end
else
    for i =1:length(l)
        l(i).Visible ='off';
    end
end

end

function checkbox3_Callback(hObj,~,handles)
% Display ticks

l = findobj(handles.MainFigure,'Tag','Tick_peak');
if hObj.Value
    for i =1:length(l)
        l(i).Visible ='on';
    end
else
    for i =1:length(l)
        l(i).Visible ='off';
    end
end

end

function compute_peaks_Callback(~,~,handles)

handles.MainFigure.Pointer = 'watch';
handles.MainFigure.UserData.success = false;
tic;
drawnow;

%buttonAutoScale_Callback([],[],handles);
g_colors = handles.MainFigure.UserData.g_colors;
markersize = str2double(handles.Edit5.String);
linewidth = str2double(handles.Edit6.String);
time_ref = handles.MainFigure.UserData.time_ref;
TimeTags = handles.MainFigure.UserData.TimeTags;
TimeTags_strings = handles.MainFigure.UserData.TimeTags_strings;

% Storing Timing
x_start = handles.Ax1.XLim(1);
x_end = handles.Ax1.XLim(2);
Time_indices = [x_start,x_end];
str = datestr((Time_indices(2)-Time_indices(1))/(24*3600),'HH:MM:SS.FFF');
Tag_Selection = {'CURRENT',handles.Edit1.String,str};
% Test if axis limits matches Whole
if round(Time_indices(1)-time_ref.Y(1))==0 && round(Time_indices(2)-time_ref.Y(end))==0
    tag = 'WHOLE';
    Tag_Selection ={tag,handles.Edit1.String,str};
% Test if axis limits matches tag
else
    for i = 1:size(TimeTags_strings,1);
        tts1 = char(TimeTags_strings(i,1));
        tts1_s = (datenum(tts1)-floor(datenum(tts1)))*24*3600;
        tts2 = char(TimeTags_strings(i,2));
        tts2_s = (datenum(tts2)-floor(datenum(tts2)))*24*3600;
        %fprintf('i = %d, delay_1 %.1f, delay_2 %.1f\n',i,tts1_s-x_start,tts2_s-x_end);
        if abs(tts1_s-x_start)<1 && abs(tts2_s-x_end)<1
            tag = char(TimeTags(i).Tag);
            Tag_Selection ={tag,handles.Edit1.String,str};
        end
    end
end
channel = char(handles.Popup1.String(handles.Popup1.Value,:));
handles.Ax1.Title.String = sprintf('%s (Duration %s) - LFP Channel : %s',char(Tag_Selection(1)),char(Tag_Selection(3)),channel);
handles.MainFigure.UserData.Tag_Selection = Tag_Selection;
handles.MainFigure.UserData.channel = strcat('LFP_',channel);

% Loading 
x_glow = handles.MainFigure.UserData.x_glow;
y_glow = handles.MainFigure.UserData.y_glow;
x_gmid = handles.MainFigure.UserData.x_gmid;
y_gmid = handles.MainFigure.UserData.y_gmid;
x_gmidup = handles.MainFigure.UserData.x_gmidup;
y_gmidup = handles.MainFigure.UserData.y_gmidup;
x_ghigh = handles.MainFigure.UserData.x_ghigh;
y_ghigh = handles.MainFigure.UserData.y_ghigh;
x_ghighup = handles.MainFigure.UserData.x_ghighup;
y_ghighup = handles.MainFigure.UserData.y_ghighup;
x_ripple = handles.MainFigure.UserData.x_ripple;
y_ripple = handles.MainFigure.UserData.y_ripple;
x_theta = handles.MainFigure.UserData.x_theta;
y_theta = handles.MainFigure.UserData.y_theta;
% Loading 
x_im = handles.MainFigure.UserData.x_im;
y_cortex = handles.MainFigure.UserData.y_cortex;
y_thal = handles.MainFigure.UserData.y_thal;
y_hpc = handles.MainFigure.UserData.y_hpc;
y_whole = handles.MainFigure.UserData.y_whole;
d_cortex = handles.MainFigure.UserData.d_cortex;
d_thal = handles.MainFigure.UserData.d_thal;
d_hpc = handles.MainFigure.UserData.d_hpc;
d_whole = handles.MainFigure.UserData.d_whole;
CBV_data = handles.MainFigure.UserData.CBV_data;
dCBVdt_data = handles.MainFigure.UserData.dCBVdt_data;
label_channels = handles.MainFigure.UserData.label_channels;

% Extracting indices
[~,ind_1_glow] = min((x_glow-x_start).^2);
[~,ind_2_glow] = min((x_glow-x_end).^2);
[~,ind_1_gmid] = min((x_gmid-x_start).^2);
[~,ind_2_gmid] = min((x_gmid-x_end).^2);
[~,ind_1_gmidup] = min((x_gmidup-x_start).^2);
[~,ind_2_gmidup] = min((x_gmidup-x_end).^2);
[~,ind_1_ghigh] = min((x_ghigh-x_start).^2);
[~,ind_2_ghigh] = min((x_ghigh-x_end).^2);
[~,ind_1_ghighup] = min((x_ghighup-x_start).^2);
[~,ind_2_ghighup] = min((x_ghighup-x_end).^2);
[~,ind_1_ripple] = min((x_ripple-x_start).^2);
[~,ind_2_ripple] = min((x_ripple-x_end).^2);
[~,ind_1_theta] = min((x_theta-x_start).^2);
[~,ind_2_theta] = min((x_theta-x_end).^2);

% Keeping only REM dots
x_glow = x_glow(ind_1_glow:ind_2_glow);
x_gmid = x_gmid(ind_1_gmid:ind_2_gmid);
x_gmidup = x_gmidup(ind_1_gmidup:ind_2_gmidup);
x_ghigh = x_ghigh(ind_1_ghigh:ind_2_ghigh);
x_ghighup = x_ghighup(ind_1_ghighup:ind_2_ghighup);
x_ripple = x_ripple(ind_1_ripple:ind_2_ripple);
x_theta = x_theta(ind_1_theta:ind_2_theta);

y_glow = y_glow(ind_1_glow:ind_2_glow);
y_gmid = y_gmid(ind_1_gmid:ind_2_gmid);
y_gmidup = y_gmidup(ind_1_gmidup:ind_2_gmidup);
y_ghigh = y_ghigh(ind_1_ghigh:ind_2_ghigh);
y_ghighup = y_ghighup(ind_1_ghighup:ind_2_ghighup);
y_ripple = y_ripple(ind_1_ripple:ind_2_ripple);
y_theta = y_theta(ind_1_theta:ind_2_theta);

% Clearing dots and peaks
all_dots = findobj(handles.MainFigure,'Tag','Tick_peak','-or','Tag','Dot_peak');
for i =1:length(all_dots)
    delete(all_dots(i));
end

fprintf('Extracting peaks lfp, cbv and derivative...');
% Extracting peaks eeg
ax = handles.Ax1;
hold(ax,'on');
m = ax.YLim(1)+ .9*(ax.YLim(2)-ax.YLim(1));
M = ax.YLim(2);

y = y_glow;
x = x_glow;
[~,ind_pks] = findpeaks(y);
peaks_y_glow = ind_pks;
l = findobj(handles.MainFigure,'Tag','glow');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(1,:),'MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(1,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = y_gmid;
x = x_gmid;
[~,ind_pks] = findpeaks(y);
peaks_y_gmid = ind_pks;
l = findobj(handles.MainFigure,'Tag','gmid');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(2,:),'MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(2,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = y_gmidup;
x = x_gmidup;
[~,ind_pks] = findpeaks(y);
peaks_y_gmidup = ind_pks;
l = findobj(handles.MainFigure,'Tag','gmidup');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(3,:),'MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(3,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = y_ghigh;
x = x_ghigh;
[~,ind_pks] = findpeaks(y);
peaks_y_ghigh = ind_pks;
l = findobj(handles.MainFigure,'Tag','ghigh');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(4,:),'MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(4,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = y_ghighup;
x = x_ghighup;
[~,ind_pks] = findpeaks(y);
peaks_y_ghighup = ind_pks;
l = findobj(handles.MainFigure,'Tag','ghighup');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(5,:),'MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(5,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = y_ripple;
x = x_ripple;
[~,ind_pks] = findpeaks(y);
peaks_y_ripple = ind_pks;
l = findobj(handles.MainFigure,'Tag','ripple');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(6,:),'MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(6,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = y_theta;
x = x_theta;
[~,ind_pks] = findpeaks(y);
peaks_y_theta = ind_pks;
l = findobj(handles.MainFigure,'Tag','theta');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'ko','MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color','k','LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end
hold(ax,'off');

% Extracting peaks cbv
ax = handles.Ax2;
hold(ax,'on');
m = ax.YLim(1)+ .9*(ax.YLim(2)-ax.YLim(1));
M = ax.YLim(2);

y = y_cortex;
x = x_im;
[~,ind_pks] = findpeaks(y);
peaks_y_cortex = ind_pks;
l = findobj(handles.MainFigure,'Tag','ycortex');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(1,:),'MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(1,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = y_hpc;
[~,ind_pks] = findpeaks(y);
peaks_y_hpc = ind_pks;
l = findobj(handles.MainFigure,'Tag','yhpc');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(2,:),'MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(2,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = y_thal;
[~,ind_pks] = findpeaks(y);
peaks_y_thal = ind_pks;
l = findobj(handles.MainFigure,'Tag','ythal');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(3,:),'MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(3,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = y_whole;
[~,ind_pks] = findpeaks(y);
peaks_y_whole = ind_pks;
l = findobj(handles.MainFigure,'Tag','ywhole');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'ko','MarkerSize',markersize,'Parent',ax,'Tag','Dot_peak');
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color','k','LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end
hold(ax,'off');

% Extracting peaks derivative
ax = handles.Ax3;
hold(ax,'on');
m = ax.YLim(1)+ .9*(ax.YLim(2)-ax.YLim(1));
M = ax.YLim(2);

y = d_cortex;
x = x_im;
[~,ind_pks] = findpeaks(y);
peaks_d_cortex = ind_pks;
l = findobj(handles.MainFigure,'Tag','dcortex');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(1,:),'MarkerSize',markersize,'Parent',ax);
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(1,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = d_hpc;
[~,ind_pks] = findpeaks(y);
peaks_d_hpc = ind_pks;
l = findobj(handles.MainFigure,'Tag','dhpc');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(2,:),'MarkerSize',markersize,'Parent',ax);
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(2,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = d_thal;
[~,ind_pks] = findpeaks(y);
peaks_d_thal = ind_pks;
l = findobj(handles.MainFigure,'Tag','dthal');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'o','Color',g_colors(3,:),'MarkerSize',markersize,'Parent',ax);
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color',g_colors(3,:),'LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

y = d_whole;
[~,ind_pks] = findpeaks(y);
peaks_d_whole = ind_pks;
l = findobj(handles.MainFigure,'Tag','dwhole');
if strcmp(l.Visible,'on')
    plot(x(ind_pks),y(ind_pks),'ko','MarkerSize',markersize,'Parent',ax);
    for i =1:length(ind_pks)
        ind = ind_pks(i);
        line([x(ind),x(ind)],[m M],'Color','k','LineWidth',linewidth,'Parent',ax,'Tag','Tick_peak');
    end
end

hold(ax,'off');
checkbox2_Callback(handles.Checkbox2,[],handles);
checkbox3_Callback(handles.Checkbox3,[],handles);
drawnow;

%Extracting peaks S_cbv
S_cbv = struct('x',[],'y',[],'name',[],'x_scaled',[],'y_scaled',[]);
S_dcbvdt = struct('x',[],'y',[],'name',[],'x_scaled',[],'y_scaled',[]);

for i =1:length(label_channels)
    S_cbv(i).name = char(label_channels(i));
    S_dcbvdt(i).name = char(label_channels(i));
    
    y = CBV_data(i,:);
    [~,peaks_y] = findpeaks(y);
    peaks_y(x_im(peaks_y)<x_start)=[];
    peaks_y(x_im(peaks_y)>x_end)=[];
    S_cbv(i).x = x_im(peaks_y);
    S_cbv(i).y = y(peaks_y);
    S_cbv(i).x_scaled = (x_im(peaks_y)-x_start)/(x_end-x_start);
    %y_scaled
    m = min(S_cbv(i).y,[],'omitnan');
    M = max(S_cbv(i).y,[],'omitnan');
    if m<M
        S_cbv(i).y_scaled = (S_cbv(i).y-m)/(M-m);
    else
        S_cbv(i).y_scaled = NaN(size(S_cbv(i).y));
    end
    
    y = dCBVdt_data(i,:);
    [~,peaks_y] = findpeaks(y);
    peaks_y(x_im(peaks_y)<x_start)=[];
    peaks_y(x_im(peaks_y)>x_end)=[];
    S_dcbvdt(i).x = x_im(peaks_y);
    S_dcbvdt(i).y = y(peaks_y);
    S_dcbvdt(i).x_scaled = (x_im(peaks_y)-x_start)/(x_end-x_start);
    %y_scaled
    m = min(S_dcbvdt(i).y,[],'omitnan');
    M = max(S_dcbvdt(i).y,[],'omitnan');
    if m<M
        S_dcbvdt(i).y_scaled = (S_dcbvdt(i).y-m)/(M-m);
    else
        S_dcbvdt(i).y_scaled = NaN(size(S_dcbvdt(i).y));
    end
end

% Removing unrelevant peaks
peaks_y_cortex(x_im(peaks_y_cortex)<x_start)=[];
peaks_y_cortex(x_im(peaks_y_cortex)>x_end)=[];
peaks_y_hpc(x_im(peaks_y_hpc)<x_start)=[];
peaks_y_hpc(x_im(peaks_y_hpc)>x_end)=[];
peaks_y_thal(x_im(peaks_y_thal)<x_start)=[];
peaks_y_thal(x_im(peaks_y_thal)>x_end)=[];
peaks_y_whole(x_im(peaks_y_whole)<x_start)=[];
peaks_y_whole(x_im(peaks_y_whole)>x_end)=[];
peaks_d_cortex(x_im(peaks_d_cortex)<x_start)=[];
peaks_d_cortex(x_im(peaks_d_cortex)>x_end)=[];
peaks_d_hpc(x_im(peaks_d_hpc)<x_start)=[];
peaks_d_hpc(x_im(peaks_d_hpc)>x_end)=[];
peaks_d_thal(x_im(peaks_d_thal)<x_start)=[];
peaks_d_thal(x_im(peaks_d_thal)>x_end)=[];
peaks_d_whole(x_im(peaks_d_whole)<x_start)=[];
peaks_d_whole(x_im(peaks_d_whole)>x_end)=[];

% Storing 
handles.MainFigure.UserData.peaks_y_glow = peaks_y_glow;
handles.MainFigure.UserData.peaks_y_gmid = peaks_y_gmid;
handles.MainFigure.UserData.peaks_y_gmidup = peaks_y_gmidup;
handles.MainFigure.UserData.peaks_y_ghigh = peaks_y_ghigh;
handles.MainFigure.UserData.peaks_y_ghighup = peaks_y_ghighup;
handles.MainFigure.UserData.peaks_y_ripple = peaks_y_ripple;

handles.MainFigure.UserData.peaks_y_theta = peaks_y_theta;
handles.MainFigure.UserData.peaks_y_cortex = peaks_y_cortex;
handles.MainFigure.UserData.peaks_y_hpc = peaks_y_hpc;
handles.MainFigure.UserData.peaks_y_thal = peaks_y_thal;
handles.MainFigure.UserData.peaks_y_whole = peaks_y_whole;
handles.MainFigure.UserData.peaks_d_cortex = peaks_d_cortex;
handles.MainFigure.UserData.peaks_d_hpc = peaks_d_hpc;
handles.MainFigure.UserData.peaks_d_thal = peaks_d_thal;
handles.MainFigure.UserData.peaks_d_whole = peaks_d_whole;
handles.MainFigure.UserData.S_cbv = S_cbv;
handles.MainFigure.UserData.S_dcbvdt = S_dcbvdt;

% Clear secondary panels
all_tabs = [handles.FirstTab;handles.SecondTab;handles.ThirdTab;handles.FourthTab;handles.FifthTab;handles.SixthTab];
ax = findobj(all_tabs,'Type','axes');
for i =1:length(ax)
    delete(ax(i).Children);
end
l = findobj(all_tabs,'Tag','Legend','-or','Type','Colorbar');
for i =1:length(l)
    delete(l(i));
end

% Compute Raster & timing y 
thresh_inf = str2double(handles.Edit7.String);
thresh_sup = str2double(handles.Edit8.String);
marker_type = {'o','*','diamond','.'};

% Saving lfp
S_lfp = struct('x',[],'y',[],'name',[],'x_scaled',[],'y_scaled',[]);
S_lfp(1).x = x_glow(peaks_y_glow);
S_lfp(1).y = y_glow(peaks_y_glow);
S_lfp(1).name = 'gamma-low';
S_lfp(1).x_scaled = (S_lfp(1).x-x_start)/(x_end-x_start);
S_lfp(2).x = x_gmid(peaks_y_gmid);
S_lfp(2).y = y_gmid(peaks_y_gmid);
S_lfp(2).name = 'gamma-mid';
S_lfp(2).x_scaled = (S_lfp(2).x-x_start)/(x_end-x_start);
S_lfp(3).x = x_gmidup(peaks_y_gmidup);
S_lfp(3).y = y_gmidup(peaks_y_gmidup);
S_lfp(3).name = 'gamma-midup';
S_lfp(3).x_scaled = (S_lfp(3).x-x_start)/(x_end-x_start);
S_lfp(4).x = x_ghigh(peaks_y_ghigh);
S_lfp(4).y = y_ghigh(peaks_y_ghigh);
S_lfp(4).name = 'gamma-high';
S_lfp(4).x_scaled = (S_lfp(4).x-x_start)/(x_end-x_start);
S_lfp(5).x = x_ghighup(peaks_y_ghighup);
S_lfp(5).y = y_ghighup(peaks_y_ghighup);
S_lfp(5).name = 'gamma-highup';
S_lfp(5).x_scaled = (S_lfp(5).x-x_start)/(x_end-x_start);
S_lfp(6).x = x_ripple(peaks_y_ripple);
S_lfp(6).y = y_ripple(peaks_y_ripple);
S_lfp(6).name = 'ripple';
S_lfp(6).x_scaled = (S_lfp(6).x-x_start)/(x_end-x_start);
S_lfp(7).x = x_theta(peaks_y_theta);
S_lfp(7).y = y_theta(peaks_y_theta);
S_lfp(7).name = 'theta';
S_lfp(7).x_scaled = (S_lfp(7).x-x_start)/(x_end-x_start);
%y_scaled
for i=1:length(S_lfp)
    m = min(S_lfp(i).y,[],'omitnan');
    M = max(S_lfp(i).y,[],'omitnan');
    if m<M
        S_lfp(i).y_scaled = (S_lfp(i).y-m)/(M-m);
    else
        S_lfp(i).y_scaled = NaN(size(S_lfp(i).y));
    end
end

% Saving fus
S_fus = struct('x',[],'y',[],'name',[],'x_scaled',[],'y_scaled',[]);
S_fus(1).x = x_im(peaks_y_cortex);
S_fus(1).y = y_cortex(peaks_y_cortex);
S_fus(1).name = 'cortex';
S_fus(1).x_scaled = (S_fus(1).x-x_start)/(x_end-x_start);
S_fus(2).x = x_im(peaks_y_hpc);
S_fus(2).y = y_hpc(peaks_y_hpc);
S_fus(2).x_scaled = (S_fus(2).x-x_start)/(x_end-x_start);
S_fus(2).name = 'hpc';
S_fus(3).x = x_im(peaks_y_thal);
S_fus(3).y = y_thal(peaks_y_thal);
S_fus(3).name = 'thal';
S_fus(3).x_scaled = (S_fus(3).x-x_start)/(x_end-x_start);
S_fus(4).x = x_im(peaks_y_whole);
S_fus(4).y = y_whole(peaks_y_whole);
S_fus(4).name = 'whole';
S_fus(4).x_scaled = (S_fus(4).x-x_start)/(x_end-x_start);
%y_scaled
for i=1:length(S_fus)
    m = min(S_fus(i).y,[],'omitnan');
    M = max(S_fus(i).y,[],'omitnan');
    if m<M
        S_fus(i).y_scaled = (S_fus(i).y-m)/(M-m);
    else
        S_fus(i).y_scaled = NaN(size(S_fus(i).y));
    end
end

% Saving dfus/dt
S_dfusdt = struct('x',[],'y',[],'name',[],'x_scaled',[],'y_scaled',[]);
S_dfusdt(1).x = x_im(peaks_d_cortex);
S_dfusdt(1).y = d_cortex(peaks_d_cortex);
S_dfusdt(1).name = 'cortex';
S_dfusdt(1).x_scaled = (S_dfusdt(1).x-x_start)/(x_end-x_start);
S_dfusdt(2).x = x_im(peaks_d_hpc);
S_dfusdt(2).y = d_hpc(peaks_d_hpc);
S_dfusdt(2).name = 'hpc';
S_dfusdt(2).x_scaled = (S_dfusdt(2).x-x_start)/(x_end-x_start);
S_dfusdt(3).x = x_im(peaks_d_thal);
S_dfusdt(3).y = d_thal(peaks_d_thal);
S_dfusdt(3).name = 'thal';
S_dfusdt(3).x_scaled = (S_dfusdt(3).x-x_start)/(x_end-x_start);
S_dfusdt(4).x = x_im(peaks_d_whole);
S_dfusdt(4).y = d_whole(peaks_d_whole);
S_dfusdt(4).name = 'whole';
S_dfusdt(4).x_scaled = (S_dfusdt(4).x-x_start)/(x_end-x_start);
%y_scaled
for i=1:length(S_dfusdt)
    m = min(S_dfusdt(i).y,[],'omitnan');
    M = max(S_dfusdt(i).y,[],'omitnan');
    if m<M
        S_dfusdt(i).y_scaled = (S_dfusdt(i).y-m)/(M-m);
    else
        S_dfusdt(i).y_scaled = NaN(size(S_dfusdt(i).y));
    end
end

fprintf(' done\n');
fprintf('Computing raster and timing y...');

% Reinitialize panels
n_fus = length(S_fus);
n_lfp = length(S_lfp);
initialize_panels(handles,n_fus,n_lfp);

% Compute Raster y
R_y = NaN(n_fus,n_lfp);
ratio_y = NaN(n_fus,n_lfp);
M_y = NaN(n_fus,n_lfp);
data_y = struct('delta_t',[],'val_peak',[],'name',[],'val_peak_scaled',[]);

% S_ref = S_fus;
% S_test = S_lfp;
for j =1:length(S_fus)
    x = S_fus(j).x;
    y = S_fus(j).y;
    [delta_t,val_peak,val_peak_scaled] = extract_peaks(x,y,S_lfp,thresh_inf,thresh_sup);
    data_y(j).delta_t = delta_t;
    data_y(j).val_peak = val_peak;
    data_y(j).val_peak_scaled = val_peak_scaled;
    data_y(j).name = S_fus(j).name;
    
    for i=1:length(S_lfp)
        ax = findobj(handles.FirstTab,'Tag',sprintf('Ax%d-%d',j,i));
        data = val_peak(:,i+1);
        delays = delta_t(:,i+1);
        %[~, ind_sort] = sort(data,'ascend');
        ind_sort = 1:length(data);
        
        % test if more than two dots
        t = length(data);
        s = sum(isnan(data));
        if (t-s)<2
            continue;
        end
        
        plot(data,val_peak(:,1),'o','Color',g_colors(i,:),'Parent',ax);
        ax.Tag = sprintf('Ax%d-%d',j,i);
        ax.XLim = [min(data)-1e-4,max(data)+1e-4];
        ax.YLim = [min(val_peak(:,1))-1e-4,max(val_peak(:,1))+1e-4];
        r = corr(val_peak(:,1),data,'rows','complete');
        ax.XLabel.String = S_lfp(i).name;
        ax.YLabel.String = S_fus(j).name;
        ax.Title.String = sprintf('r = %.2f (%d/%d)',r,t-s,t);
        lsline(ax);
        
        ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d-%d',j,i));
        m = mean(delays,'omitnan');
        barh(delays(ind_sort),'EdgeColor','none','FaceColor',g_colors(i,:),'Parent',ax);
        ax.Tag = sprintf('Ax%d-%d',j,i);
        ax.YLim = [.5 length(delays)+.5];
        ax.XLim = [thresh_inf thresh_sup];
        ax.YLabel.String = S_fus(j).name;
        ax.Title.String = sprintf('m = %.2f (%d/%d)',m,t-s,t);
        
        % Synthesis
        ax = findobj(handles.FirstTab,'Tag',sprintf('Ax%d-%d',length(S_fus)+1,i));
        hold(ax,'on');
        plot(data,val_peak(:,1),char(marker_type(j)),'MarkerSize',markersize,'Color',g_colors(i,:),'Parent',ax);
        ax.Tag = sprintf('Ax%d-%d',length(S_fus)+1,i);
        ax.Title.String = 'Synthesis';
        ax.YLabel.String = S_lfp(i).name;
        hold(ax,'off');
        
        % Storing data
        R_y(j,i) = r;
        M_y(j,i) = m;
        ratio_y(j,i) = (t-s)/t;
        
        if j==4
            legend(ax,handles.MainFigure.UserData.tit_legend,'Tag','Legend');
            lsline(ax);
        end
    end
end

fprintf(' done\n');
fprintf('Computing raster and timing dydt...');

% Compute Raster dy/dt 
R_dydt = NaN(n_fus,n_lfp);
M_dydt = NaN(n_fus,n_lfp);
ratio_dydt = NaN(n_fus,n_lfp);
data_dydt = struct('delta_t',[],'val_peak',[],'name',[],'val_peak_scaled',[]);

for j =1:length(S_dfusdt) 
    x = S_dfusdt(j).x;
    y = S_dfusdt(j).y;
    [delta_t, val_peak,val_peak_scaled] = extract_peaks(x,y,S_lfp,thresh_inf,thresh_sup);
    data_dydt(j).delta_t = delta_t;
    data_dydt(j).val_peak = val_peak;
    data_dydt(j).val_peak_scaled = val_peak_scaled;
    data_dydt(j).name = S_dfusdt(j).name;
    
    for i=1:length(S_lfp) 
        ax = findobj(handles.ThirdTab,'Tag',sprintf('Ax%d-%d',j,i));
        data = val_peak(:,i+1);
        delays = delta_t(:,i+1);
        %[~, ind_sort] = sort(data,'ascend');
        ind_sort = 1:length(data);
        
        % test if more than two dots
        t = length(data);
        s = sum(isnan(data));
        if (t-s)<2
            continue;
        end
        
        plot(data,val_peak(:,1),'o','Color',g_colors(i,:),'Parent',ax);
        ax.Tag = sprintf('Ax%d-%d',j,i);
        ax.XLim = [min(data)-1e-4,max(data)+1e-4];
        ax.YLim = [min(val_peak(:,1))-1e-4,max(val_peak(:,1))+1e-4];
        r = corr(val_peak(:,1),data,'rows','complete');
        ax.XLabel.String = S_lfp(i).name;
        ax.YLabel.String = S_dfusdt(j).name;
        ax.Title.String = sprintf('r = %.2f (%d/%d)',r,t-s,t);
        lsline(ax);
        
        ax = findobj(handles.FourthTab,'Tag',sprintf('Ax%d-%d',j,i));
        m = mean(delays,'omitnan');
        barh(delays(ind_sort),'EdgeColor','none','FaceColor',g_colors(i,:),'Parent',ax);
        ax.Tag = sprintf('Ax%d-%d',j,i);
        ax.YLim = [.5 length(delays)+.5];
        ax.XLim = [thresh_inf thresh_sup];
        ax.YLabel.String = S_dfusdt(j).name;
        ax.Title.String = sprintf('m = %.2f (%d/%d)',m,t-s,t);
        
        % Synthesis
        ax = findobj(handles.ThirdTab,'Tag',sprintf('Ax%d-%d',length(S_dfusdt)+1,i));
        hold(ax,'on');
        plot(data,val_peak(:,1),char(marker_type(j)),'MarkerSize',markersize,'Color',g_colors(i,:),'Parent',ax);
        ax.Tag = sprintf('Ax%d-%d',length(S_dfusdt)+1,i);
        ax.Title.String = 'Synthesis';
        ax.YLabel.String = S_lfp(i).name;
        hold(ax,'off');
        
        % Storing data
        R_dydt(j,i) = r;
        M_dydt(j,i) = m;
        ratio_dydt(j,i) = (t-s)/t;
        
        if j==4
            legend(ax,handles.MainFigure.UserData.tit_legend,'Tag','Legend');
            lsline(ax);
        end
    end
end

fprintf(' done\n');
fprintf('Computing synthesis correlations...');

%R_all
R_all = NaN(length(S_cbv),length(S_lfp));
%x = x_im;
for j =1:length(S_cbv)
    x = S_cbv(j).x;
    y = S_cbv(j).y;
    [~, val_peak] = extract_peaks(x,y,S_lfp,thresh_inf,thresh_sup);
    for i=1:length(S_lfp)
        try
            R_all(j,i) = corr(val_peak(:,1),val_peak(:,i+1),'rows','complete');
        catch
            R_all(j,i) = NaN;
        end
            
    end
end
R_dalldt = NaN(length(S_dcbvdt),length(S_lfp));
for j =1:length(S_cbv) 
    x = S_dcbvdt(j).x;
    y = S_dcbvdt(j).y;
    [~, val_peak] = extract_peaks(x,y,S_lfp,thresh_inf,thresh_sup);
    for i=1:length(S_lfp)
        R_dalldt(j,i) = corr(val_peak(:,1),val_peak(:,i+1),'rows','complete');
    end
end

%Synthesis
ax4 = handles.Ax4;
imagesc(R_y,'Parent',ax4);
ax4.YTick = 1:size(R_dydt,1);
ax4.YTickLabel = handles.MainFigure.UserData.tit_legend;
ax4.XTick = 1:length(S_lfp);
ax4.XTickLabel = {S_lfp(:).name}';
ax4.XTickLabelRotation = 90;
ax4.Title.String = 'Synthesis CBV';
ax4.Tag = 'Ax4';
ax4.CLim = [-1,1];
colorbar(ax4);
ax5 = handles.Ax5;
imagesc(R_dydt,'Parent',ax5);
ax5.YTick = 1:size(R_dydt,1);
ax5.YTickLabel = handles.MainFigure.UserData.tit_legend;
ax5.XTick = 1:length(S_lfp);
ax5.XTickLabel = {S_lfp(:).name}';
ax5.XTickLabelRotation = 90;
ax5.Title.String = 'Synthesis dCBV/dt';
ax5.Tag = 'Ax5';
ax5.CLim = [-1,1];
colorbar(ax5);
%Synthesis
ax6 = handles.Ax6;
imagesc(R_all,'Parent',ax6);
ax6.YTick = 1:size(R_all,1);
ax6.YTickLabel = {S_cbv(:).name}';
ax6.XTick = 1:length(S_lfp);
ax6.XTickLabel = {S_lfp(:).name}';
ax6.XTickLabelRotation = 90;
ax6.Title.String = 'All CBV';
ax6.Tag = 'Ax6';
ax6.CLim = [-1,1];
colorbar(ax6);
ax7 = handles.Ax7;
imagesc(R_dalldt,'Parent',ax7);
ax7.YTick = 1:size(R_dalldt,1);
ax7.YTickLabel = {S_cbv(:).name}';
ax7.XTick = 1:length(S_lfp);
ax7.XTickLabel = {S_lfp(:).name}';
ax7.XTickLabelRotation = 90;
ax7.Title.String = 'All dCBVdt';
ax7.Tag = 'Ax7';
ax7.CLim = [-1,1];
colorbar(ax7);

fprintf(' done\n');
fprintf('Extracting peaks...');

% Synthesis Continuous
% Fetching correlogram
global DIR_STATS FILES CUR_FILE;
folder = fullfile(DIR_STATS,'Wavelet_Analysis',FILES(CUR_FILE).eeg);
tag = char(Tag_Selection(1));
channel = char(handles.Popup1.String(handles.Popup1.Value,:));
d = dir(folder);
str = {d(:).name}';
ind_1 = ~(cellfun('isempty',strfind(str,tag)));
ind_2 = ~(cellfun('isempty',strfind(str,channel)));
if ~isempty(d(ind_1.*ind_2==1))
    filename = d(ind_2.*ind_1==1).name;
    data_eeg = load(fullfile(folder,filename),'Cdata_sub','Xdata_sub','x_start','x_end',...
        'step_sub','f_sub','fdom_min','fdom_max','fdom_step');
end
freqdom = data_eeg.fdom_min:data_eeg.fdom_step:data_eeg.fdom_max;
Cdata = data_eeg.Cdata_sub;
% Subsampling 
sub_step = 1;
freqdom = freqdom(1:sub_step:end);
Cdata = Cdata(1:sub_step:end,:);
%Gaussian smoothing
t_gauss = handles.MainFigure.UserData.t_gauss_lfp;
step = t_gauss*round(data_eeg.f_sub/data_eeg.step_sub);
Cdata = imgaussfilt(Cdata,[1 step]);
%Correction
exp_cor = 0.75;
correction = repmat((freqdom(:).^exp_cor),1,size(Cdata,2));
Cdata = Cdata.*correction;

%Extracting peaks
S_lfp_cont = struct('x',[],'y',[],'name',[],'x_scaled',[],'y_scaled',[]);
x = data_eeg.Xdata_sub;
for i =1:size(Cdata,1)
    fprintf('\nExtracting peaks at frequency %.1f',freqdom(i));
    y = imgaussfilt(Cdata(i,:),step);
    [~,ind_peaks] = findpeaks(y);
    S_lfp_cont(i).x = x(ind_peaks);
    S_lfp_cont(i).y = y(ind_peaks);
    S_lfp_cont(i).name = sprintf('%.1f',freqdom(i));
    S_lfp_cont(i).x_scaled = (S_lfp_cont(i).x-x_start)/(x_end-x_start);
    %y_scaled
    m = min(S_lfp_cont(i).y,[],'omitnan');
    M = max(S_lfp_cont(i).y,[],'omitnan');
    if m<M
        S_lfp_cont(i).y_scaled = (S_lfp_cont(i).y-m)/(M-m);
    else
        S_lfp_cont(i).y_scaled = NaN(size(S_lfp_cont(i).y));
    end
end

%R_cont
R_cont = NaN(length(S_cbv),length(S_lfp_cont));
for j =1:length(S_cbv)
    fprintf('Computing correlations for Region %s [%d/%d].\n',char(S_cbv(j).name),j,length(S_cbv))
    x = S_cbv(j).x;
    y = S_cbv(j).y;
    [~, val_peak] = extract_peaks(x,y,S_lfp_cont,thresh_inf,thresh_sup);
    for i=1:length(S_lfp_cont)
        try
            R_cont(j,i) = corr(val_peak(:,1),val_peak(:,i+1),'rows','complete');
        catch
            R_cont(j,i)=NaN;
        end
    end
end
R_dcont = NaN(length(S_dcbvdt),length(S_lfp_cont));
for j =1:length(S_dcbvdt)
    fprintf('Computing correlations for Region %s [%d/%d].\n',char(S_cbv(j).name),j,length(S_cbv))
    x = S_dcbvdt(j).x;
    y = S_dcbvdt(j).y;
    [~, val_peak] = extract_peaks(x,y,S_lfp_cont,thresh_inf,thresh_sup);
    for i=1:length(S_lfp_cont)
        R_dcont(j,i) = corr(val_peak(:,1),val_peak(:,i+1),'rows','complete');
    end
end

% Displaying Spectrogram
ax = handles.Ax8;
imagesc('CData',Cdata,'XData',data_eeg.Xdata_sub,'YData',freqdom,'Parent',ax);
ax.XLim = [x_start,x_end];
ax.YLim = [freqdom(1),freqdom(end)];
ax.YDir = 'normal';
ax.Tag = 'Ax8';
hold(ax,'on');
for i =1:length(S_lfp_cont)
    plot(S_lfp_cont(i).x,freqdom(i)*ones(size(S_lfp_cont(i).x)),...
        'Color','k','LineStyle','none','Marker','.','MarkerSize',1,'Parent',ax);
end
hold(ax,'off');

% Displaying CBV traces
ax = handles.Ax9;
imagesc('CData',CBV_data(:,1:end-1),'XData',x_im(1:end-1),'Parent',ax);
ax.XLim = [x_start,x_end];
ax.YLim = [.5,size(CBV_data,1)+.5];
ax.CLim = [-.2 .8];
ax.YDir = 'normal';
ax.YTick = 1:size(CBV_data,1);
ax.YTickLabel = {S_cbv(:).name}';
ax.Tag = 'Ax9';
hold(ax,'on');
for i =1:length(S_cbv)
    plot(S_cbv(i).x,i*ones(size(S_cbv(i).x)),...
        'Color','k','LineStyle','none','Marker','.','MarkerSize',2,'Parent',ax);
end
hold(ax,'off');

% Displaying Continuous
ax = handles.Ax10;
imagesc(R_cont,'Parent',ax);
ax.YTick = 1:size(R_cont,1);
ax.YTickLabel = {S_cbv(:).name}';
ax.Title.String = 'Correlogram LFP - CBV';
ax.Tag = 'Ax10';
ax.CLim = [-1,1];
colorbar(ax);

ax = handles.Ax11;
imagesc(R_dcont,'Parent',ax);
ax.YTick = 1:size(R_dcont,1);
ax.YTickLabel = {S_cbv(:).name}';
ax.Title.String = 'Correlogram LFP - dCBVdt';
ax.Tag = 'Ax11';
ax.CLim = [-1,1];
colorbar(ax);

fprintf(' done\n');
handles.MainFigure.Pointer = 'arrow';
handles.MainFigure.UserData.success = true;
toc;

% Storing parameters
handles.MainFigure.UserData.thresh_inf = thresh_inf;
handles.MainFigure.UserData.thresh_sup = thresh_sup;
handles.MainFigure.UserData.freqdom = freqdom;
%handles.MainFigure.UserData.t_gauss_lfp = str2double(handles.Edit3.String);
%handles.MainFigure.UserData.t_gauss_cbv = str2double(handles.Edit4.String);
% Storing data
handles.MainFigure.UserData.R_y = R_y;
handles.MainFigure.UserData.M_y = M_y;
handles.MainFigure.UserData.ratio_y = ratio_y;
handles.MainFigure.UserData.data_y = data_y;
handles.MainFigure.UserData.R_dydt = R_dydt;
handles.MainFigure.UserData.M_dydt = M_dydt;
handles.MainFigure.UserData.ratio_dydt = ratio_dydt;
handles.MainFigure.UserData.data_dydt = data_dydt;
handles.MainFigure.UserData.S_lfp = S_lfp;
handles.MainFigure.UserData.S_lfp_cont = S_lfp_cont;
handles.MainFigure.UserData.S_fus = S_fus;
handles.MainFigure.UserData.S_dfusdt = S_dfusdt;

handles.MainFigure.UserData.R_all = R_all;
handles.MainFigure.UserData.R_dalldt = R_dalldt;
handles.MainFigure.UserData.R_cont = R_cont;
handles.MainFigure.UserData.R_dcont = R_dcont;

end

function buttonAutoScale_Callback(~,~,handles)

ax = handles.Ax1;
x_start = ax.XLim(1);
x_end = ax.XLim(2);
glow = findobj(handles.MainFigure,'Tag','glow');
gmid = findobj(handles.MainFigure,'Tag','gmid');
gmidup = findobj(handles.MainFigure,'Tag','gmidup');
ghigh = findobj(handles.MainFigure,'Tag','ghigh');
ghighup = findobj(handles.MainFigure,'Tag','ghighup');
ripple = findobj(handles.MainFigure,'Tag','ripple');
theta = findobj(handles.MainFigure,'Tag','theta');

x = glow.XData;
y = glow.YData;
[~,ind_1] = min((x-x_start).^2);
[~,ind_2] = min((x-x_end).^2);
factor = max(y(ind_1:ind_2));
glow.YData = glow.YData/factor;
handles.MainFigure.UserData.y_glow = handles.MainFigure.UserData.y_glow/factor;

x = gmid.XData;
y = gmid.YData;
[~,ind_1] = min((x-x_start).^2);
[~,ind_2] = min((x-x_end).^2);
factor = max(y(ind_1:ind_2));
gmid.YData = gmid.YData/factor;
handles.MainFigure.UserData.y_gmid = handles.MainFigure.UserData.y_gmid/factor;

x = gmidup.XData;
y = gmidup.YData;
[~,ind_1] = min((x-x_start).^2);
[~,ind_2] = min((x-x_end).^2);
factor = max(y(ind_1:ind_2));
gmidup.YData = gmidup.YData/factor;
handles.MainFigure.UserData.y_gmidup = handles.MainFigure.UserData.y_gmidup/factor;

x = ghigh.XData;
y = ghigh.YData;
[~,ind_1] = min((x-x_start).^2);
[~,ind_2] = min((x-x_end).^2);
factor = max(y(ind_1:ind_2));
ghigh.YData = ghigh.YData/factor;
handles.MainFigure.UserData.y_ghigh = handles.MainFigure.UserData.y_ghigh/factor;

x = ghighup.XData;
y = ghighup.YData;
[~,ind_1] = min((x-x_start).^2);
[~,ind_2] = min((x-x_end).^2);
factor = max(y(ind_1:ind_2));
ghighup.YData = ghighup.YData/factor;
handles.MainFigure.UserData.y_ghighup = handles.MainFigure.UserData.y_ghighup/factor;

x = ripple.XData;
y = ripple.YData;
[~,ind_1] = min((x-x_start).^2);
[~,ind_2] = min((x-x_end).^2);
factor = max(y(ind_1:ind_2));
ripple.YData = ripple.YData/factor;
handles.MainFigure.UserData.y_ripple = handles.MainFigure.UserData.y_ripple/factor;

x = theta.XData;
y = theta.YData;
[~,ind_1] = min((x-x_start).^2);
[~,ind_2] = min((x-x_end).^2);
factor = max(y(ind_1:ind_2));
theta.YData = theta.YData/factor;
handles.MainFigure.UserData.y_theta = handles.MainFigure.UserData.y_theta/factor;

end

function [delta_t, val_peak, val_peak_scaled] = extract_peaks(x,y,S,thresh_inf,thresh_sup)

val_peak = NaN(length(x),length(S)+1);
delta_t = NaN(length(x),length(S)+1);

for i=1:length(x)
    
    delta_t(i,1) = x(i);
    val_peak(i,1) = y(i);
    
    for j=1:length(S)
        xj = S(j).x;
        yj = S(j).y;
        % finding closest peak to xj in x
        [~,ind] = min((xj-x(i)).^2);
        delta_j = x(i)-xj(ind);
        
        try
            if delta_j < thresh_inf || delta_j > thresh_sup
                delta_j = NaN;
                val_j = NaN;
            else
                val_j = yj(ind);
            end
        catch
            delta_j = NaN;
            val_j = NaN;
        end
        
        delta_t(i,j+1) = delta_j;
        val_peak(i,j+1) = val_j;
    end

end

% val_peak_scaled
m = min(val_peak,[],1,'omitnan');
m = repmat(m,[size(val_peak,1),1]);
M = max(val_peak,[],1,'omitnan');
M = repmat(M,[size(val_peak,1),1]);
try
    val_peak_scaled = (val_peak-m)./(M-m);
catch
    val_peak_scaled = NaN(size(val_peak));
end

end

function saveimage_Callback(~,~,handles)

global FILES CUR_FILE DIR_FIG;
load('Preferences.mat','GTraces');

%Loading data
tag = char(handles.MainFigure.UserData.Tag_Selection(1));
channel = handles.MainFigure.UserData.channel;
% Creating Save Directory
save_dir = fullfile(DIR_FIG,'Peak_Detection',FILES(CUR_FILE).eeg);
if ~isdir(save_dir)
    mkdir(save_dir);
end

% Saving Image
cur_tab = handles.TabGroup.SelectedTab;
handles.TabGroup.SelectedTab = handles.MainTab;
pic_name = sprintf('%s_Peak_Detection_traces_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FirstTab;
pic_name = sprintf('%s_Peak_Detection_RasterY_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.SecondTab;
pic_name = sprintf('%s_Peak_Detection_TimingY_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.ThirdTab;
pic_name = sprintf('%s_Peak_Detection_RasterdYdt_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FourthTab;
pic_name = sprintf('%s_Peak_Detection_TimingdYdt_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FifthTab;
pic_name = sprintf('%s_Peak_Detection_Synthesis_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.SixthTab;
pic_name = sprintf('%s_Peak_Detection_Continuous_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = cur_tab;
end

function savestats_Callback(~,~,handles)

global FILES CUR_FILE DIR_STATS;
load('Preferences.mat','GTraces');

%Loading data
tag = char(handles.MainFigure.UserData.Tag_Selection(1));
channel = handles.MainFigure.UserData.channel;
recording = FILES(CUR_FILE).eeg;
% Storing parameters
Tag_Selection = handles.MainFigure.UserData.Tag_Selection;
thresh_inf = handles.MainFigure.UserData.thresh_inf;
thresh_sup = handles.MainFigure.UserData.thresh_sup;
t_gauss_lfp = handles.MainFigure.UserData.t_gauss_lfp;
t_gauss_cbv = handles.MainFigure.UserData.t_gauss_cbv;
freqdom = handles.MainFigure.UserData.freqdom;
% Storing data
R_y = handles.MainFigure.UserData.R_y;
M_y = handles.MainFigure.UserData.M_y;
ratio_y = handles.MainFigure.UserData.ratio_y;
data_y = handles.MainFigure.UserData.data_y;
R_dydt = handles.MainFigure.UserData.R_dydt;
M_dydt = handles.MainFigure.UserData.M_dydt;
ratio_dydt = handles.MainFigure.UserData.ratio_dydt;
data_dydt = handles.MainFigure.UserData.data_dydt;
S_lfp = handles.MainFigure.UserData.S_lfp;
S_lfp_cont = handles.MainFigure.UserData.S_lfp_cont;
S_fus = handles.MainFigure.UserData.S_fus;
S_dfusdt = handles.MainFigure.UserData.S_dfusdt;
S_cbv = handles.MainFigure.UserData.S_cbv;
S_dcbvdt = handles.MainFigure.UserData.S_dcbvdt;
label_channels = handles.MainFigure.UserData.label_channels;
%Correlogram
R_all = handles.MainFigure.UserData.R_all;
R_dalldt = handles.MainFigure.UserData.R_dalldt;
R_cont = handles.MainFigure.UserData.R_cont;
R_dcont = handles.MainFigure.UserData.R_dcont;

% Creating Stats Directory
data_dir = fullfile(DIR_STATS,'Peak_Detection',FILES(CUR_FILE).eeg);
if ~isdir(data_dir)
    mkdir(data_dir);
end

% Saving data
filename = sprintf('%s_Peak_Detection_%s_%s.mat',FILES(CUR_FILE).eeg,channel,tag);
save(fullfile(data_dir,filename),'recording','tag','channel','label_channels','Tag_Selection',...
    'thresh_inf','thresh_sup','t_gauss_lfp','t_gauss_cbv','freqdom',...
    'S_lfp','S_lfp_cont','S_fus','S_dfusdt','S_cbv','S_dcbvdt',...
    'R_all','R_dalldt','R_cont','R_dcont',...
    'R_y','M_y','ratio_y','data_y',...
    'R_dydt','M_dydt','ratio_dydt','data_dydt','-v7.3');
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
end

% Compute for whole recording
edits = [handles.Edit1,handles.Edit2];

% Compute for designated time tags
for i = 1:length(ind_tag)%size(TimeTags_strings,1)
    val = handles.Popup1.Value;
    for j =1:size(handles.Popup1.String,1)
        handles.Popup1.Value = j;
        update_popup_Callback(handles.Popup1,[],handles);
        template_button_TagSelection_Callback(handles.TagButton,[],handles.CenterAxes,edits,'single',ind_tag(i),v)
        buttonAutoScale_Callback([],[],handles);
        compute_peaks_Callback([],[],handles);
        savestats_Callback([],[],handles);
        saveimage_Callback([],[],handles);
    end
    handles.Popup1.Value = val;
    update_popup_Callback(handles.Popup1,[],handles);
end

end

function initialize_panels(handles,x,y)

%x = 4
%y = 5
tab1 = handles.FirstTab;
tab2 = handles.SecondTab;
tab3 = handles.ThirdTab;
tab4 = handles.FourthTab;
all_tabs = [tab1;tab2;tab3;tab4];
for i =1:length(all_tabs)
    delete(all_tabs(i).Children);
end

%Raster
ax_1 = gobjects(x+1,y);
for ind = 1:(x+1)*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_1(i,j) = subplot(x+1,y,ind,'Parent',tab1,'Tag',sprintf('Ax%d-%d',i,j));
    ax_1(i,j).Title.String = sprintf('Ax%d-%d',i,j);
end

%Timing
ax_2 = gobjects(x,y);
for ind = 1:x*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_2(i,j) = subplot(x,y,ind,'Parent',tab2,'Tag',sprintf('Ax%d-%d',i,j));
    ax_2(i,j).Title.String = sprintf('Ax%d-%d',i,j);
end

%Raster
ax_1 = gobjects(x+1,y);
for ind = 1:(x+1)*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_1(i,j) = subplot(x+1,y,ind,'Parent',tab3,'Tag',sprintf('Ax%d-%d',i,j));
    ax_1(i,j).Title.String = sprintf('Ax%d-%d',i,j);
end

%Timing
ax_2 = gobjects(x,y);
for ind = 1:x*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_2(i,j) = subplot(x,y,ind,'Parent',tab4,'Tag',sprintf('Ax%d-%d',i,j));
    ax_2(i,j).Title.String = sprintf('Ax%d-%d',i,j);
end

end