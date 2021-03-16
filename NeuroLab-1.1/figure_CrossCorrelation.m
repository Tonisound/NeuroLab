function f2 = figure_CrossCorrelation(myhandles,val,str_tag)

global DIR_SAVE FILES CUR_FILE START_IM END_IM;

% Loading Time Reference
if (exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file'))
    data_tr = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),...
        'time_ref','n_burst','length_burst','rec_mode');
    time_ref = data_tr.time_ref;
    rec_mode = data_tr.rec_mode;
    length_burst = data_tr.length_burst;
    n_burst = data_tr.n_burst;
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
f2.UserData.x_start = time_ref.Y(1);
f2.UserData.x_end = time_ref.Y(end);
f2.UserData.n_burst = n_burst;
f2.UserData.length_burst = length_burst;
f2.UserData.rec_mode = rec_mode;
f2.UserData.TimeTags = TimeTags;
f2.UserData.TimeTags_strings = TimeTags_strings;
f2.UserData.TimeTags_cell = TimeTags_cell;
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
e6_def = '.1';
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
    'String',sprintf('File : %s\n (Source : %s) ',FILES(CUR_FILE).nlab,...
    strtrim(myhandles.CenterPanelPopup.String(myhandles.CenterPanelPopup.Value,:))),...
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
ax1 = axes('Parent',tab0,'Tag','Ax_LFP','Position',[.06 .54 .9 .435]);
ax2 = axes('Parent',tab0,'Tag','Ax_fUS','Position',[.06 .04 .9 .435]);


handles2 = guihandles(f2) ;
if ~isempty(handles2.TagButton.UserData)&&length(handles2.TagButton.UserData.Selected)>1
    handles2.TagButton.UserData=[];
end

handles2 = reset_Callback([],[],handles2,myhandles);
edit_Callback([handles2.Edit1 handles2.Edit2],[],handles2.CenterAxes);
colormap(f2,'jet');

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
% str_tag contains group names 
if val==0
    batchsave_Callback([],[],handles2,str_tag,1);
end

end

function boxVisible_Callback(hObj,~)

l = findobj(hObj.Parent,'Tag',hObj.TooltipString);
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
boxes = findobj(handles.MainFigure,'Tag','BoxVisibleCBV','-or','Tag','BoxVisibleLFP');
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
    set(all_axes(i),'ButtonDownFcn',{@template_axes_clickFcn,0,[],edits});
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
%buttonAutoScale_Callback([],[],handles);

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
x_start = handles.MainFigure.UserData.x_start;
x_end = handles.MainFigure.UserData.x_end;
t_gauss = str2double(handles.Edit3.String);
ax = handles.Ax_LFP;
tab0 = handles.MainTab;
channel = char(pu.String(pu.Value,:));
folder_name = handles.MainFigure.UserData.folder_name;
time_ref = handles.MainFigure.UserData.time_ref;

% Loading directly from Sources_LFP 
dir_traces = dir(fullfile(folder_name,'Sources_LFP','Power-*.mat'));
dir_traces = dir_traces(contains({dir_traces(:).name}',sprintf('_%s.',channel)));
str_traces = {dir_traces(:).name}';

% Building reference time
f_samp = .1;
x_lfp = (x_start:f_samp:x_end)';
all_patterns = {'delta_';'theta_';'beta_';'gammalow_';'gammamid_';'gammamidup_';'gammahigh_';'gammahighup_';'ripple_'};
label_lfp = {'delta';'theta';'beta';'gamma low';'gamma-mid';'gamma-mid-up';'gamma-high';'gamma-high-up';'ripple'};
LFP_data = NaN(length(all_patterns),length(x_lfp));

for j=1:length(all_patterns)
    ind_band = contains(str_traces,all_patterns(j));
    if sum(ind_band)>0
        data_channel = load(fullfile(dir_traces(ind_band).folder,dir_traces(ind_band).name));
        x_band = (data_channel.x_start:data_channel.f:data_channel.x_end)';
        y_band = data_channel.Y;
        %Resamp
        y_band = interp1(x_band,y_band,x_lfp);
%         % Rescale
%         y_band = rescale(y_band,0,1);
        % Filter
        y_band = imgaussfilt(y_band,round(2*t_gauss/f_samp));
    else
        y_band = NaN(size(x_lfp));
        warning('No trace found[%s-%s]',char(all_patterns(j)),channel);
    end
    LFP_data(j,:) = y_band';
end


% Plotting
ind_colors = round(rescale(1:length(label_lfp),1,64));
g_colors = handles.MainFigure.UserData.g_colors(ind_colors,:);
ax.UserData.Colors = g_colors;

delete(ax.Children);
hold(ax,'on');
for j = 1:length(all_patterns)
    y_band = LFP_data(j,:);
    plot(x_lfp,y_band,'Color',g_colors(j,:),'Tag',char(label_lfp(j)),'LineWidth',1,'Parent',ax);
end
ax.YLabel.String = 'LFP filtered';
legend(ax,label_lfp,'Tag','Legend');
hold(ax,'off');

delete(findobj(tab0,'Tag','BoxVisibleLFP'));
for i =1:length(label_lfp)
    uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
        'TooltipString',char(label_lfp(i)),'Position',[.98 .04*(i-1) .02 .04],...
        'Callback',{@boxVisible_Callback},'Tag','BoxVisibleLFP','Value',1);
end

% Visible/Not visible
all_boxes = findobj(handles.MainTab,'Tag','BoxVisibleLFP');
for i =1:length(all_boxes)
    boxVisible_Callback(all_boxes(i),[]);
end

% Storing 
handles.MainFigure.UserData.t_gauss_lfp = t_gauss;
handles.MainFigure.UserData.x_lfp = x_lfp;
handles.MainFigure.UserData.LFP_data = LFP_data;
handles.MainFigure.UserData.label_lfp = label_lfp;
%handles.MainFigure.UserData.all_patterns = all_patterns;

end

function update_cbv_traces(handles,myhandles)

%global LAST_IM;
ax1 = handles.Ax_fUS;
tab0 = handles.MainTab;
t_gauss = str2double(handles.Edit4.String);
x_fus = [handles.MainFigure.UserData.time_ref.Y;NaN];
x_start = handles.MainFigure.UserData.time_ref.Y(1);
x_end = handles.MainFigure.UserData.time_ref.Y(end);

rec_mode = handles.MainFigure.UserData.rec_mode;
length_burst = handles.MainFigure.UserData.length_burst;
n_burst = handles.MainFigure.UserData.n_burst;

% Loading lines
% lines = flipud(findobj(myhandles.RightAxes,'Tag','Trace_Region','-or','Tag','Trace_RegionGroup'));
% lines = flipud(findobj(myhandles.RightAxes,'Tag','Trace_Region'));
lines = flipud(findobj(myhandles.RightAxes,'Tag','Trace_RegionGroup'));

% Building CBV data
CBV_data = NaN(length(lines),length(x_fus));
label_fus = cell(length(lines),1);
x_fus = [handles.MainFigure.UserData.time_ref.Y;NaN];
delta = x_fus(2)-x_fus(1);
w = gausswin(round(2*t_gauss/delta));
s=sum(w);
w = w/s;

for i =1:length(lines)
    label_fus(i) = {lines(i).UserData.Name};
    y = lines(i).YData;
    
    % Reshaping if rec_mode = BURST
    if strcmp(rec_mode,'BURST')
        xq = x_start:f_samp:x_end;
        yq = NaN(size(xq));
        % add NaN values between bursts
        for ii=1:n_burst
            % adding values to yq for each burst
            ind_burst = (ii-1)*length_burst+1:(ii*length_burst);
            xburst = x_fus(ind_burst);
            yburst = y(ind_burst);
            [~,i1]=min((xq-xburst(1)).^2);
            [~,i2]=min((xq-xburst(end)).^2);
            y_int = interp1(xburst,yburst,xq(i1:i2));
            yq(i1:i2) = y_int;
        end
        y = yq;
    end
    % gaussian filtering
    %y = imgaussfilt(y,round(t_gauss/delta));
    y_conv = s*nanconv(y,w,'same');
    CBV_data(i,:) = y_conv;
end

%renaming
if strcmp(rec_mode,'BURST')
    x_fus = xq;
end


% Plotting fus
% g_colors = handles.MainFigure.UserData.g_colors;
ind_colors = round(rescale(1:length(label_fus),1,64));
g_colors = handles.MainFigure.Colormap(ind_colors,:);
ax1.UserData.Colors = g_colors;
delete(ax1.Children);
hold(ax1,'on');
for i =1:length(label_fus)
    plot(x_fus,CBV_data(i,:),'Tag',char(label_fus(i)),'LineWidth',1,'Parent',ax1,'Color',g_colors(i,:));
end
ax1.YLabel.String = 'CBV traces';
legend(ax1,label_fus,'Tag','Legend');
hold(ax1,'off');

% Visible/Not visible
delete(findobj(tab0,'Tag','BoxVisibleCBV'));
for i =1:length(label_fus)
    uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
        'TooltipString',char(label_fus(i)),'Position',[0 .04*(i-1) .02 .04],...
        'Callback',{@boxVisible_Callback},'Tag','BoxVisibleCBV','Value',1);
end
all_boxes = findobj(tab0,'Tag','BoxVisibleCBV');
for i =1:length(all_boxes)
    boxVisible_Callback(all_boxes(i),[]);
end

% Storing 
handles.MainFigure.UserData.t_gauss_cbv = t_gauss;
handles.MainFigure.UserData.x_fus = x_fus;
handles.MainFigure.UserData.label_fus = label_fus;
handles.MainFigure.UserData.CBV_data = CBV_data;

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
rec_mode = handles.MainFigure.UserData.rec_mode;

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
x_lfp = handles.MainFigure.UserData.x_lfp;
LFP_data = handles.MainFigure.UserData.LFP_data;
label_lfp = handles.MainFigure.UserData.label_lfp;
% Loading 
x_fus = handles.MainFigure.UserData.x_fus;
CBV_data = handles.MainFigure.UserData.CBV_data;
label_fus = handles.MainFigure.UserData.label_fus;
% Colors
g_colors = handles.Ax_LFP.UserData.Colors;
f_colors = handles.Ax_fUS.UserData.Colors;

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
for i = 1:length(label_fus)
    S_fus(i).x = x_fus(:);
    S_fus(i).y = CBV_data(i,:);
    S_fus(i).name = char(label_fus(i));
end

% Building S_lfp
S_lfp = struct('x',[],'y',[],'name',[]);
for i = 1:length(label_lfp)
    S_lfp(i).x = x_lfp(:);
    S_lfp(i).y = LFP_data(i,:);
    S_lfp(i).name = char(label_lfp(i));
end


% Compute cross-correlations
fprintf('Computing cross-correlations lfp-fus ...');

thresh_inf = str2double(handles.Edit7.String);
thresh_sup = str2double(handles.Edit8.String);
thresh_step = str2double(handles.Edit6.String);
%thresh_step = .1;
thresh_dom = thresh_inf:thresh_step:thresh_sup;
%marker_type = {'o','*','diamond','.'};
markersize = str2double(handles.Edit5.String);

% Reinitialize panels
n_fus = length(S_fus);
n_lfp = length(S_lfp);
initialize_panels(handles,n_fus,n_lfp);

% Compute cross correlation
R_peak = NaN(n_fus,n_lfp);
T_peak = NaN(n_fus,n_lfp);
X_corr = NaN(n_fus,n_lfp,length(thresh_dom));

h = waitbar(0,'Please wait');
count =0;
for j =1:length(S_fus)
    %ind_notnan = (~isnan(S_fus(j).x)).*(~isnan(S_fus(j).y));
    ind_notnan = (~isnan(S_fus(j).x));
    xfus = S_fus(j).x(ind_notnan==1);
    yfus = S_fus(j).y(ind_notnan==1);
    %name_ref = S_fus(j).name;
    
    for i=1:length(S_lfp)
        count = count+1;
        ax = findobj(handles.FirstTab,'Tag',sprintf('Ax%d-%d',j,i));
        xlfp = S_lfp(i).x;
        ylfp = S_lfp(i).y;
        x_ref = (max(xlfp(1),xfus(1)):thresh_step: min(xlfp(end),xfus(end)))';
        y_fus = interp1(xfus,yfus,x_ref);
        y_lfp = interp1(xlfp,ylfp,x_ref);
        
        % normalization
        y_fus = (y_fus-mean(y_fus,'omitnan'))/std(y_fus,[],'omitnan');
        y_lfp = (y_lfp-mean(y_lfp,'omitnan'))/std(y_lfp,[],'omitnan');

        if sum(isnan(y_lfp))>0 || sum(isnan(y_fus))>0 % strcmp(rec_mode,'BURST')
            % compute xcorr with NaN
            lags = thresh_inf:thresh_step:thresh_sup;
            r = zeros(length(lags),1);
            for k = 1:length(lags)
                lag = lags(k);
                step = round(lag/thresh_step);
                if lag==0
                    r(k) = corr(y_fus,y_lfp,'rows','complete');
                elseif lag>0
                    r(k) = corr(y_fus(step+1:end),y_lfp(1:end-step),'rows','complete');
                elseif lag<0
                    r(k) = corr(y_fus(1:end-abs(step)),y_lfp(abs(step)+1:end),'rows','complete');
                end
            end
        else
            % compute xcorr
            [r,lags] = xcorr(y_fus(:),y_lfp(:),'coeff');
            lags = lags*thresh_step;
            ind_keep = ((lags>=thresh_inf).*(lags<=thresh_sup))';
            r = r(ind_keep==1);
            lags = lags(ind_keep==1);
        end
        prop = count/(length(S_fus)*length(S_lfp));
        waitbar(prop,h,sprintf('Computing lagged correlations %.1f %% completed',100*prop));
        
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
            ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d',i));
            set(ax,'XTick','','YTick','','XTickLabel','','YTickLabel','');
            for k =1:length(l)
                copyobj(l(k),ax);
            end
            leg = legend(ax,handles.MainFigure.UserData.label_fus,'Tag','Legend');
            leg.Position = ax.Position;
            ax.Title.String = '';
            
            ax = findobj(handles.ThirdTab,'Tag',sprintf('Ax%d',j));
            l = flipud(findobj(ax,'Type','line','-not','Tag','Hbar','-not','Tag','Peak'));
            ax = findobj(handles.ThirdTab,'Tag',sprintf('Ax%d',j));
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
close(h);

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
label_lfp = handles.MainFigure.UserData.label_lfp;
for i =1:length(label_lfp)
    l=findobj(handles.MainFigure,'Tag',char(label_lfp(i)));
    x = l.XData;
    y = l.YData;
    [~,ind_1] = min((x-x_start).^2);
    [~,ind_2] = min((x-x_end).^2);
    factor = max(y(ind_1:ind_2));
    l.YData = l.YData/factor;
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
handles.TabGroup.SelectedTab = handles.MainTab;
pic_name = sprintf('%s_Cross_Correlation_traces_%s%s',FILES(CUR_FILE).recording,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FirstTab;
pic_name = sprintf('%s_Cross_Correlation_Full_%s%s',FILES(CUR_FILE).recording,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.SecondTab;
pic_name = sprintf('%s_Cross_Correlation_LFP-Synthesis_%s%s',FILES(CUR_FILE).recording,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.ThirdTab;
pic_name = sprintf('%s_Cross_Correlation_fUS-Synthesis_%s%s',FILES(CUR_FILE).recording,channel,GTraces.ImageSaveExtension);
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

margin_w = .05;
margin_h = .05;

tab1 = handles.FirstTab;
tab2 = handles.SecondTab;
tab3 = handles.ThirdTab;
all_tabs = [tab1;tab2];
for i =1:length(all_tabs)
    delete(all_tabs(i).Children);
end

%Cross-correlations
ax_1 = gobjects(x,y);
n_rows = x;
n_columns = y;
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        xx = mod(index-1,n_columns)/n_columns;
        yy = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax_1(ii,jj) = axes('Parent',tab1);
        ax_1(ii,jj).Position= [xx+margin_w yy+margin_h/2 (1/n_columns)-margin_w (1/n_rows)-1.5*margin_h];
        ax_1(ii,jj).Title.String = sprintf('Ax%d-%d',ii,jj);
        ax_1(ii,jj).Tag = sprintf('Ax%d-%d',ii,jj);
        ax_1(ii,jj).YLim = [0 .1];
    end
end

%Band Synthesis 
ax_2 = gobjects(y);
n_rows = ceil(sqrt(y));
n_columns = ceil(y/n_rows);
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>y
            continue;
        end
        xx = mod(index-1,n_columns)/n_columns;
        yy = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax_2(index) = axes('Parent',tab2);
        ax_2(index).Position= [xx+margin_w yy+margin_h/2 (1/n_columns)-margin_w (1/n_rows)-1.5*margin_h];
        ax_2(index).Tag= sprintf('Ax%d',index);
        ax_2(index).Title.String= sprintf('Ax%d',index);
    end
end

%Band Synthesis 
ax_3 = gobjects(x);
n_rows = ceil(sqrt(x));
n_columns = ceil(x/n_rows);
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>x
            continue;
        end
        xx = mod(index-1,n_columns)/n_columns;
        yy = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax_3(index) = axes('Parent',tab3);
        ax_3(index).Position= [xx+margin_w yy+margin_h/2 (1/n_columns)-margin_w (1/n_rows)-1.5*margin_h];
        ax_3(index).Tag= sprintf('Ax%d',index);
        ax_3(index).Title.String= sprintf('Ax%d',index);
    end
end

end