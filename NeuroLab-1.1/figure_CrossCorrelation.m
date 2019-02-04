function f2 = figure_CrossCorrelation(myhandles,val,str_tag)

global DIR_SAVE FILES CUR_FILE START_IM END_IM;

% Loading Time Reference
if (exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file'))
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','n_burst','length_burst');
else
    warning('Missing Reference Time File (%s)\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
    return;
end
% Loading Time Tags
if (exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'file'))
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags','TimeTags_strings','TimeTags_cell');
else
    warning('Missing Time Tags File (%s)\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
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
    'Name','Cross Correlation LFP-fUS');
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
cb2_def = 0;
cb2_tip = '';
cb3_def = 0;
cb3_tip = '';
e3_def = '1';
e3_tip = 'LFP Gaussian smoothing';
e4_def = '1';
e4_tip = 'CBV Gaussian smoothing';
e5_def = '5';
e5_tip = 'Marker Size';
e6_def = '.01';
e6_tip = 'Step size';
e7_def = '-20';
e7_tip = 'Thresh_inf (s)';
e8_def = '20';
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
    'String',sprintf('File : %s\n (Source : %s) ',FILES(CUR_FILE).nlab,strtrim(myhandles.CenterPanelPopup.String(myhandles.CenterPanelPopup.Value,:))),...
    'Tag','Text1');

p = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'ToolTipString','Channel Selection',...
    'Tag','Popup1');
p.UserData.index=1;
str = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Trace_LFP.mat'),'traces');
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
    'Title','Cross-Correlation',...
    'Tag','FirstTab');
uitab('Parent',tabgp,...
    'Title','LFP Synthesis',...
    'Tag','SecondTab');
uitab('Parent',tabgp,...
    'Title','fUS Synthesis',...
    'Tag','ThirdTab');


%Traces
subplot(211,'Parent',tab0,'Tag','Ax_LFP');
subplot(212,'Parent',tab0,'Tag','Ax_fUS');
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .58 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','glow','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .62 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','gmid','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .66 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','gmidup','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .7 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ghigh','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .74 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ghighup','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .78 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ripple','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .82 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','theta','Value',1);

uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .21 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ycortex','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .25 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','yhpc','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .29 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ythal','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .33 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ywhole','Value',1);


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
handles.CenterAxes = handles.Ax_LFP;
all_axes = findobj(handles.MainTab,'Type','Axes');

% Callback function Attribution
% Loading traces
pu = handles.Popup1;
traces = flipud(findobj(old_handles.RightAxes,'Tag','Trace_Cerep'));
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

set(handles.ButtonReset,'Callback',{@reset_Callback,handles,old_handles});
set(handles.ButtonCompute,'Callback',{@compute_crosscorr_Callback,handles});
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
all_tabs = findobj([handles.FirstTab;handles.SecondTab;handles.ThirdTab],'Type','axes');
for i =1:length(all_tabs)
    delete(all_tabs(i).Children);
end

% Legend/ticks Dipslay
checkbox1_Callback(handles.Checkbox1,[],handles);

% Linking axes x
linkaxes([handles.Ax_LFP;handles.Ax_fUS],'x');
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
ax = handles.Ax_LFP;
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
% ind_glow = ~(cellfun('isempty',strfind(str_traces,'Gamma-low/')));
% ind_gmid = ~(cellfun('isempty',strfind(str_traces,'Gamma-mid/')));
% ind_gmidup = ~(cellfun('isempty',strfind(str_traces,'Gamma-mid-up')));
% ind_ghigh = ~(cellfun('isempty',strfind(str_traces,'Gamma-high/')));
% ind_ghighup = ~(cellfun('isempty',strfind(str_traces,'Gamma-high-up/')));
% ind_ripple = ~(cellfun('isempty',strfind(str_traces,'Ripple/')));
% ind_theta = ~(cellfun('isempty',strfind(str_traces,'Phasic-theta/')));
ind_glow = contains(str_traces,{'Gamma-low/';'Power-gammalow/'});
ind_gmid = contains(str_traces,{'Gamma-mid/';'Power-gammamid/'});
ind_gmidup = contains(str_traces,{'Gamma-mid-up/';'Power-gammamid/'});
ind_ghigh = contains(str_traces,{'Gamma-high/';'Power-gammahigh/'});
ind_ghighup = contains(str_traces,{'Gamma-high-up/';'Power-gammahigh/'});
ind_ripple = contains(str_traces,{'Ripple/';'Power-ripple/'});
ind_theta = contains(str_traces,{'Phasic-theta/';'Power-theta/'});


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
label_lfp = {'gamma low';'gamma mid';'gamma mid up';'gamma high';'gamma high up';'ripple';'theta'};
legend(ax,label_lfp,'Tag','Legend');
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
handles.MainFigure.UserData.label_lfp = label_lfp;

end

function update_cbv_traces(handles,myhandles)

ax1 = handles.Ax_fUS;
t_gauss = str2double(handles.Edit4.String);
x_im = [handles.MainFigure.UserData.time_ref.Y;NaN];
label_fus = {'cortex';'hpc';'thal';'whole'};

% Loading lines
lines = flipud(findobj(myhandles.RightAxes,'Tag','Trace_Region'));
ind_hpc = [];
ind_thal = [];
ind_cortex = [];

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
    label_fus(1)={'rand'};
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
    label_fus(2)={'rand'};
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
    label_fus(3)={'rand'};
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
legend(ax1,label_fus,'Tag','Legend');
hold(ax1,'off');


CBV_data = NaN(length(lines),length(x_im));
label_channels = cell(length(lines),1);
for i =1:length(lines)
    label_channels(i) = {lines(i).UserData.Name};
    y = lines(i).YData;
    y = imgaussfilt(y,round(t_gauss/delta));
    CBV_data(i,:) = y;
end

% Storing 
handles.MainFigure.UserData.t_gauss_cbv = t_gauss;
handles.MainFigure.UserData.x_im = x_im;
handles.MainFigure.UserData.y_cortex = y_cortex;
handles.MainFigure.UserData.y_hpc = y_hpc;
handles.MainFigure.UserData.y_thal = y_thal;
handles.MainFigure.UserData.y_whole = y_whole;
handles.MainFigure.UserData.label_fus = label_fus;
handles.MainFigure.UserData.CBV_data = CBV_data;
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

function compute_crosscorr_Callback(~,~,handles)

handles.MainFigure.Pointer = 'watch';
handles.MainFigure.UserData.success = false;
tic;
drawnow;

%buttonAutoScale_Callback([],[],handles);
g_colors = handles.MainFigure.UserData.g_colors;
time_ref = handles.MainFigure.UserData.time_ref;
TimeTags = handles.MainFigure.UserData.TimeTags;
TimeTags_strings = handles.MainFigure.UserData.TimeTags_strings;

% Storing Timing
x_start = handles.Ax_LFP.XLim(1);
x_end = handles.Ax_LFP.XLim(2);
Time_indices = [x_start,x_end];
str = datestr((Time_indices(2)-Time_indices(1))/(24*3600),'HH:MM:SS.FFF');
Tag_Selection = {'CURRENT',handles.Edit1.String,str};
% Test if axis limits matches Whole
if round(Time_indices(1)-time_ref.Y(1))==0 && round(Time_indices(2)-time_ref.Y(end))==0
    tag = 'WHOLE';
    Tag_Selection ={tag,handles.Edit1.String,str};
% Test if axis limits matches tag
else
    for i = 1:size(TimeTags_strings,1)
        tts1 = char(TimeTags_strings(i,1));
        tts1_s = (datenum(tts1)-floor(datenum(tts1)))*24*3600;
        tts2 = char(TimeTags_strings(i,2));
        tts2_s = (datenum(tts2)-floor(datenum(tts2)))*24*3600;
        %fprintf('i = %d, delay_1 %.1f, delay_2 %.1f\n',i,tts1_s-x_start,tts2_s-x_end);
        delta_t = .01;
        if abs(tts1_s-x_start)<delta_t && abs(tts2_s-x_end)<delta_t
            tag = char(TimeTags(i).Tag);
            Tag_Selection ={tag,handles.Edit1.String,str};
            % option to retain only 
            continue;
        end
    end
end
channel = char(handles.Popup1.String(handles.Popup1.Value,:));
handles.Ax_LFP.Title.String = sprintf('%s (Duration %s) - LFP Channel : %s',char(Tag_Selection(1)),char(Tag_Selection(3)),channel);
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
CBV_data = handles.MainFigure.UserData.CBV_data;

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

% Keeping only relevant traces
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


% Clear secondary panels
all_tabs = [handles.FirstTab;handles.SecondTab;handles.ThirdTab];
ax = findobj(all_tabs,'Type','axes');
for i =1:length(ax)
    delete(ax(i).Children);
end
l = findobj(all_tabs,'Tag','Legend','-or','Type','Colorbar');
for i =1:length(l)
    delete(l(i));
end

% Building S_fus
S_fus = struct('x',[],'y',[],'name',[]);
S_fus(1).x = x_im;
S_fus(1).y = y_cortex(:);
S_fus(1).name = 'cortex';
S_fus(2).x = x_im;
S_fus(2).y = y_hpc(:);
S_fus(2).name = 'hpc';
S_fus(3).x = x_im;
S_fus(3).y = y_thal(:);
S_fus(3).name = 'thal';
S_fus(4).x = x_im;
S_fus(4).y = y_whole(:);
S_fus(4).name = 'whole';


% Building S_lfp
S_lfp = struct('x',[],'y',[],'name',[]);
S_lfp(1).x = x_glow;
S_lfp(1).y = y_glow;
S_lfp(1).name = 'gamma-low';
S_lfp(2).x = x_gmid;
S_lfp(2).y = y_gmid;
S_lfp(2).name = 'gamma-mid';
S_lfp(3).x = x_gmidup;
S_lfp(3).y = y_gmidup;
S_lfp(3).name = 'gamma-midup';
S_lfp(4).x = x_ghigh;
S_lfp(4).y = y_ghigh;
S_lfp(4).name = 'gamma-high';
S_lfp(5).x = x_ghighup;
S_lfp(5).y = y_ghighup;
S_lfp(5).name = 'gamma-highup';
S_lfp(6).x = x_ripple;
S_lfp(6).y = y_ripple;
S_lfp(6).name = 'ripple';
S_lfp(7).x = x_theta;
S_lfp(7).y = y_theta;
S_lfp(7).name = 'theta';


% Compute Raster & timing y
fprintf('Computing cross-correlations lfp-fus ...');

thresh_inf = str2double(handles.Edit7.String);
thresh_sup = str2double(handles.Edit8.String);
thresh_step = str2double(handles.Edit6.String);
%thresh_step = .1;
thresh_dom = thresh_inf:thresh_step:thresh_sup;
marker_type = {'o','*','diamond','.'};
markersize = str2double(handles.Edit5.String);

% Reinitialize panels
n_fus = length(S_fus);
n_lfp = length(S_lfp);
initialize_panels(handles,n_fus,n_lfp);

% Compute cross correlation
R_peak = NaN(n_fus,n_lfp);
T_peak = NaN(n_fus,n_lfp);
X_corr = NaN(n_fus,n_lfp,length(thresh_dom));

for j =1:length(S_fus)
    ind_notnan = (~isnan(S_fus(j).x)).*(~isnan(S_fus(j).y));
    xfus = S_fus(j).x(ind_notnan==1);
    yfus = S_fus(j).y(ind_notnan==1);
    %name_ref = S_fus(j).name;
    
    for i=1:length(S_lfp)
        ax = findobj(handles.FirstTab,'Tag',sprintf('Ax%d-%d',j,i));
        xlfp = S_lfp(i).x;
        ylfp = S_lfp(i).y;
        x_ref = max(xlfp(1),xfus(1)):thresh_step: min(xlfp(end),xfus(end));
        y_fus = interp1(xfus,yfus,x_ref);
        y_lfp = interp1(xlfp,ylfp,x_ref);
        
        % normalization
        y_fus = (y_fus-mean(y_fus))/std(y_fus);
        y_lfp = (y_lfp-mean(y_lfp))/std(y_lfp);

        % compute xcorr
        [r,lags] = xcorr(y_fus(:),y_lfp(:),'coeff');
        lags = lags*thresh_step;
        ind_keep = ((lags>=thresh_inf).*(lags<=thresh_sup))';
        r = r(ind_keep==1);
        lags = lags(ind_keep==1);
        % max corr
        [rmax,ind_max] = max(r);
        rmin = min(r);
        tmax = lags(ind_max);
        
        %plotting
        plot(lags,r,'Color',g_colors(j,:),'Parent',ax);
        ax.Tag = sprintf('Ax%d-%d',j,i);
        ax.XLim = [thresh_inf thresh_sup];
        ax.YLim = [rmin,rmax];
        % ax.YLim = [-1,1];
        ax.XLabel.String = S_lfp(i).name;
        ax.YLabel.String = S_fus(j).name;
        ax.Title.String = sprintf('r=%.2f t=%.2f',rmax,tmax);
        line([0 0],[-1 1],'Parent',ax,'Color','k');
        line(tmax,rmax,'Parent',ax,'Marker','square',...
            'MarkerSize',markersize,'MarkerEdgeColor',g_colors(j,:),'MarkerFaceColor',g_colors(j,:));
        
        % LFP Synthesis
        ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d',i));
        hold(ax,'on');
        plot(lags,r,'Color',g_colors(j,:),'Parent',ax);
        ax.Tag = sprintf('Ax%d',i);
        ax.Title.String = S_lfp(i).name;
        ax.XLim = [thresh_inf thresh_sup];
        %ax.YLim = [min(rmin,ax.YLim(1)),max(rmax,ax.YLim(2))];
        ax.YLim = [-1 1];
        delete(findobj(ax,'Tag','Hbar'));
        line([0 0],[-1 1],'Parent',ax,'Color','k','Tag','Hbar');
        line(tmax,rmax,'Parent',ax,'Marker','square','Tag','Peak',...
            'MarkerSize',markersize,'MarkerEdgeColor',g_colors(j,:),'MarkerFaceColor',g_colors(j,:));
        hold(ax,'off');
        
        % fUS Synthesis
        ax = findobj(handles.ThirdTab,'Tag',sprintf('Ax%d',j));
        hold(ax,'on');
        plot(lags,r,'Color',g_colors(i,:),'Parent',ax);
        ax.Tag = sprintf('Ax%d',j);
        ax.Title.String = S_fus(j).name;
        ax.XLim = [thresh_inf thresh_sup];
        %ax.YLim = [min(rmin,ax.YLim(1)),max(rmax,ax.YLim(2))];
        ax.YLim = [-1 1];
        delete(findobj(ax,'Tag','Hbar'));
        line([0 0],[-1 1],'Parent',ax,'Color','k','Tag','Hbar');
        line(tmax,rmax,'Parent',ax,'Marker','square','Tag','Peak',...
            'MarkerSize',markersize,'MarkerEdgeColor',g_colors(i,:),'MarkerFaceColor',g_colors(i,:));
        hold(ax,'off');
        
        if j==length(S_fus) && i==length(S_lfp)
            ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d',i));
            l = flipud(findobj(ax,'Type','line','-not','Tag','Hbar','-not','Tag','Peak'));
            ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d',i+1));
            set(ax,'XTick','','YTick','','XTickLabel','','YTickLabel','');
            for k =1:length(l)
                copyobj(l(k),ax);
            end
            leg = legend(ax,handles.MainFigure.UserData.label_fus,'Tag','Legend');
            leg.Position = ax.Position;
            ax.Title.String = '';
            
            ax = findobj(handles.ThirdTab,'Tag',sprintf('Ax%d',j));
            l = flipud(findobj(ax,'Type','line','-not','Tag','Hbar','-not','Tag','Peak'));
            ax = findobj(handles.ThirdTab,'Tag',sprintf('Ax%d',j+1));
            set(ax,'XTick','','YTick','','XTickLabel','','YTickLabel','');
            for k =1:length(l)
                copyobj(l(k),ax);
            end
            leg = legend(ax,handles.MainFigure.UserData.label_lfp,'Tag','Legend');
            leg.Position = ax.Position;
            ax.Title.String = '';
        end
        
        % Storing data
        R_peak(j,i) = rmax;
        T_peak(j,i) = tmax;
        if length(r)==size(X_corr,3)
            X_corr(j,i,:) = r;
        else
            [~,ind_min]= min((thresh_dom-lags(1)).^2);
             X_corr(j,i,ind_min:ind_min+length(r)-1) = r;
        end
        
    end
end

fprintf(' done\n');
handles.MainFigure.Pointer = 'arrow';
handles.MainFigure.UserData.success = true;
if handles.TabGroup.SelectedTab == handles.MainTab
    handles.TabGroup.SelectedTab = handles.FirstTab;
end
toc;

% Storing parameters
handles.MainFigure.UserData.thresh_inf = thresh_inf;
handles.MainFigure.UserData.thresh_sup = thresh_sup;
handles.MainFigure.UserData.thresh_step = thresh_step;
handles.MainFigure.UserData.t_gauss_lfp = str2double(handles.Edit3.String);
handles.MainFigure.UserData.t_gauss_cbv = str2double(handles.Edit4.String);
% Storing data
handles.MainFigure.UserData.R_peak = R_peak;
handles.MainFigure.UserData.T_peak = T_peak;
handles.MainFigure.UserData.X_corr = X_corr;
handles.MainFigure.UserData.S_lfp = S_lfp;
handles.MainFigure.UserData.S_fus = S_fus;

end

function buttonAutoScale_Callback(~,~,handles)

ax = handles.Ax_LFP;
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

function saveimage_Callback(~,~,handles)

global FILES CUR_FILE DIR_FIG;
load('Preferences.mat','GTraces');

%Loading data
tag = char(handles.MainFigure.UserData.Tag_Selection(1));
channel = handles.MainFigure.UserData.channel;
% Creating Save Directory
save_dir = fullfile(DIR_FIG,'Cross_Correlation',FILES(CUR_FILE).eeg);
if ~isdir(save_dir)
    mkdir(save_dir);
end

% Saving Image
cur_tab = handles.TabGroup.SelectedTab;
handles.TabGroup.SelectedTab = handles.MainTab;
pic_name = sprintf('%s_Cross_Correlation_traces_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FirstTab;
pic_name = sprintf('%s_Cross_Correlation_Full_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.SecondTab;
pic_name = sprintf('%s_Cross_Correlation_LFP-Synthesis_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.ThirdTab;
pic_name = sprintf('%s_Cross_Correlation_fUS-Synthesis_%s_%s%s',FILES(CUR_FILE).eeg,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = cur_tab;
end

function savestats_Callback(~,~,handles)

global FILES CUR_FILE DIR_STATS;
load('Preferences.mat','GTraces');


tag = char(handles.MainFigure.UserData.Tag_Selection(1));
channel = handles.MainFigure.UserData.channel;
recording = FILES(CUR_FILE).eeg;
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
data_dir = fullfile(DIR_STATS,'Cross_Correlation',FILES(CUR_FILE).eeg);
if ~isdir(data_dir)
    mkdir(data_dir);
end

% Saving data
filename = sprintf('%s_Cross_Correlation_%s_%s.mat',FILES(CUR_FILE).eeg,channel,tag);
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
        compute_crosscorr_Callback([],[],handles);
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
all_tabs = [tab1;tab2];
for i =1:length(all_tabs)
    delete(all_tabs(i).Children);
end

%Cross-correlations
ax_1 = gobjects(x,y);
for ind = 1:x*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_1(i,j) = subplot(x,y,ind,'Parent',tab1,'Tag',sprintf('Ax%d-%d',i,j));
    ax_1(i,j).Title.String = sprintf('Ax%d-%d',i,j);
    ax_1(i,j).YLim = [0 .1];
end

%Band Synthesis 
ax_2 = gobjects(y);
for ind = 1:y+1
    %i = ceil(ind/y);
    %j = mod(ind-1,y)+1;
    ax_2(ind) = subplot(2,ceil(y/2),ind,'Parent',tab2,'Tag',sprintf('Ax%d',ind));
    ax_2(ind).Title.String = sprintf('Ax%d',ind);
end

%Band Synthesis 
ax_3 = gobjects(x);
for ind = 1:x+1
    %i = ceil(ind/y);
    %j = mod(ind-1,y)+1;
    ax_3(ind) = subplot(2,ceil((x+1)/2),ind,'Parent',tab3,'Tag',sprintf('Ax%d',ind));
    ax_3(ind).Title.String = sprintf('Ax%d',ind);
end

end