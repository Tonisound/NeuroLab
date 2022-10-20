function f2 = figure_SleepScoring(old_handles,savedir,recording,val)

%global DIR_SAVE FILES CUR_FILE START_IM END_IM;
%savedir = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);
%recording = FILES(CUR_FILE).recording;
global DIR_STATS;

% Loading Config.mat
data_config = load(fullfile(savedir,'Config.mat'));

if exist(fullfile(savedir,'Nconfig.mat'),'file')
    data_nconfig = load(fullfile(savedir,'Nconfig.mat'));
else
    data_nconfig = [];
end

% Loading Time Reference
if (exist(fullfile(savedir,'Time_Reference.mat'),'file'))
    data_tr = load(fullfile(savedir,'Time_Reference.mat'),...
        'time_ref','n_burst','length_burst','rec_mode');
    time_ref = data_tr.time_ref;
    n_burst = data_tr.n_burst;
    length_burst = data_tr.length_burst;
    rec_mode = data_tr.rec_mode;
    xdat = [reshape(time_ref.Y,[length_burst,n_burst]);NaN(1,n_burst)];
else
    warning('Missing Reference Time File (%s)\n',savedir);
    return;
end

% Loading Time Tags
if (exist(fullfile(savedir,'Time_Tags.mat'),'file'))
    data_tt = load(fullfile(savedir,'Time_Tags.mat'));
    if isempty(data_tt.TimeTags_strings)
        data_tt = [];
    end
else
    %warning('Missing Time Tags File (%s)\n',savedir);
    data_tt = [];
end

% Loading Time Groups
if (exist(fullfile(savedir,'Time_Groups.mat'),'file'))
    data_tg = load(fullfile(savedir,'Time_Groups.mat'));
    if isempty(data_tg.TimeGroups_S)
        data_tg = [];
    end
else
    %warning('Missing Time Tags File (%s)\n',savedir);
    data_tg = [];
end

% Loading Sleep Scoring if exists
if exist(fullfile(savedir,'Sleep_Scoring.mat'),'file')
    data_ss = load(fullfile(savedir,'Sleep_Scoring.mat'));
else
    data_ss = [];
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
    'Name',sprintf('Sleep Scoring [%s]',recording));
set(f2,'Position',[.1 .1 .6 .6]);
clrmenu(f2);

f2.Pointer = 'watch';
drawnow;

% Storing Data
f2.UserData.time_ref = time_ref;
f2.UserData.n_burst = n_burst;
f2.UserData.length_burst = length_burst;
f2.UserData.xdat = xdat(:);
f2.UserData.rec_mode = rec_mode;
f2.UserData.g_colors = get(groot,'DefaultAxesColorOrder');
f2.UserData.savedir = savedir;
f2.UserData.recording = recording;
f2.UserData.data_config = data_config;
f2.UserData.data_tt = data_tt;
f2.UserData.data_tg = data_tg;
f2.UserData.SleepScore = data_ss;
f2.UserData.TimeDisplay = old_handles.TimeDisplay.UserData;

% Getting file_nlab
temp = regexp(savedir,filesep,'split');
file_nlab = char(temp(end));
f2.UserData.file_nlab = file_nlab;

% Information Panel
iP = uipanel('Units','normalized',...
    'bordertype','etchedin',...
    'Tag','InfoPanel',...
    'Parent',f2);
iP.Position = [0 0 1 .15];

% Popup LFP
d_lfp = dir(fullfile(savedir,'Sources_LFP','LFP_*.mat'));

% If NConfig file exists, keep electrode order
if ~isempty(data_nconfig)
    lfp_ordered = data_nconfig.channel_list(contains(data_nconfig.channel_list,'LFP'));
    lfp_str = regexprep(lfp_ordered,'/','_');
else
    lfp_str = regexprep({d_lfp(:).name}','.mat','');
end
% lfp_str = regexprep({d_lfp(:).name}','.mat','');

pu_lfp = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'String',lfp_str,...
    'ToolTipString','LFP Channel Selection',...
    'Tag','Popup_LFP');
%picking channel
if ~isempty(data_ss)
    ind_mainlfp = find(strcmp(lfp_str,strrep(data_ss.channel_lfp,'.mat',''))==1);
    pu_lfp.UserData.channel_1 = data_ss.channel_1;
    pu_lfp.UserData.channel_2 = data_ss.channel_2;
else
    ind_mainlfp = find(strcmp(lfp_str,strcat('LFP_',data_config.File.mainlfp))==1);
    pu_lfp.UserData.channel_1 = [];
    pu_lfp.UserData.channel_2 = [];
end
if~isempty(ind_mainlfp)
    pu_lfp.Value = ind_mainlfp;
else
    pu_lfp.Value = 1;
end
%path to data
pu_lfp.UserData.path = fullfile(savedir,'Sources_LFP');
pu_lfp.UserData.channel_type = 'LFP';
path_spectro= fullfile(DIR_STATS,'Wavelet_Analysis',file_nlab);
if exist(path_spectro,'dir')
    pu_lfp.UserData.path_spectro = path_spectro;
else
    pu_lfp.UserData.path_spectro = [];
end

% Popup EMG
d_emg = dir(fullfile(savedir,'Sources_LFP','EMG_*.mat'));
if isempty(d_emg)
    emg_str = '.';
else
    emg_str = regexprep({d_emg(:).name}','.mat','');
end
    
pu_emg = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'String',emg_str,...
    'ToolTipString','EMG Channel Selection',...
    'Tag','Popup_EMG');
%picking channel
if ~isempty(data_ss)
    ind_mainemg = find(strcmp(emg_str,strrep(data_ss.channel_emg,'.mat',''))==1);
    pu_emg.UserData.thresh_init = data_ss.thresh_emg;
else
    ind_mainemg = find(strcmp(emg_str,strcat('EMG_',data_config.File.mainemg))==1);
    pu_emg.UserData.thresh_init = [];
end
if ~isempty(ind_mainemg)
    pu_emg.Value = ind_mainemg;
else
    pu_emg.Value = 1;
end
%path to data
pu_emg.UserData.path = fullfile(savedir,'Sources_LFP');
pu_emg.UserData.channel_type = 'EMG';

% Popup ACC
d_acc = dir(fullfile(savedir,'Sources_LFP','ACC_*.mat'));
if isempty(d_acc)
    acc_str = '.';
else
    acc_str = regexprep({d_acc(:).name}','.mat','');
end
pu_acc = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'String',acc_str,...
    'ToolTipString','ACC Channel Selection',...
    'Tag','Popup_ACC');
%picking channel
if ~isempty(data_ss)
    ind_mainacc = find(strcmp(acc_str,strrep(data_ss.channel_acc,'.mat',''))==1);
    pu_acc.UserData.thresh_init = data_ss.thresh_acc;
else
    ind_mainacc = find(strcmp(acc_str,strcat('ACC_',data_config.File.mainacc))==1);
    pu_acc.UserData.thresh_init = [];
end
if ~isempty(ind_mainacc)
    pu_acc.Value = ind_mainacc;
else
    pu_acc.Value = 1;
end
%path to data
pu_acc.UserData.path = fullfile(savedir,'Sources_LFP');
pu_acc.UserData.channel_type = 'ACC';

% Ratio popups
pu_ratio1 = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'String','.',...
    'Value',1,...
    'ToolTipString','Sleep scoring ratio 1',...
    'Tag','Popup_Ratio1');
pu_ratio2 = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'String','.',...
    'Value',1,...
    'ToolTipString','Sleep scoring ratio 1',...
    'Tag','Popup_Ratio2');
if ~isempty(data_ss)
    pu_ratio1.UserData.thresh_init = data_ss.thresh_ratio1;
    pu_ratio2.UserData.thresh_init = data_ss.thresh_ratio2;
else
    pu_ratio1.UserData.thresh_init = [];
    pu_ratio2.UserData.thresh_init = [];
end

% Popup Algorithm
pu_algo = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'String','.',...
    'Value',1,...
    'ToolTipString','Sleep scoring Algorithm',...
    'Tag','Popup_Algo');
d_algo = dir(fullfile('NeuroLab*','algos_scoring','*.m'));
if ~isempty(d_algo)
    pu_algo.String = {d_algo(:).name}';
%     all_paths = unique({d_algo(:).folder}');
%     for i=1:length(all_paths)
%         addpath(genpath(char(all_paths(i))));
%     end
    addpath(genpath(char(d_algo(1).folder)));
else
    errordlg('No algorithm file found in packages/Scoring. Please update.\n');
    return;
end
if ~isempty(data_ss)
    ind_algo = find(strcmp(pu_algo.String,char(data_ss.algorithm))==1);
else
    ind_algo = [];
end
if ~isempty(ind_algo)
    pu_algo.Value = ind_algo;
else
    pu_algo.Value = 1;
end

e1 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','Start Time',...
    'String',old_handles.TimeDisplay.UserData(1,:),...
    'Parent',iP,...
    'Tag','Edit1');
e2 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','End Time',...
    'String',old_handles.TimeDisplay.UserData(end,:),...
    'Parent',iP,...
    'Tag','Edit2');
e3 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','Autoset Threshold (z-score)',...
    'String','1',...
    'Parent',iP,...
    'Tag','Edit3');
if ~isempty(data_ss)
    e3.String = data_ss.z_score;
end
e4 = uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','Minimal Event Duration (s)',...
    'String','5',...
    'Parent',iP,...
    'Tag','Edit4');
if ~isempty(data_ss)
    e4.String = data_ss.t_min;
end

cb1 = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Parent',iP,...
    'Value',1,...
    'Tag','Checkbox1',...
    'Tooltipstring','Show/hide source/spectrogram');
cb2 = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Parent',iP,...
    'Value',1,...
    'Tag','Checkbox2',...
    'Tooltipstring','Show/hide patches');
cb3 = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Parent',iP,...
    'Value',0,...
    'Tag','Checkbox3',...
    'Tooltipstring','Log Scale');
cb4 = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Parent',iP,...
    'Value',1,...
    'Tag','Checkbox4',...
    'Tooltipstring','Overwrite Time Tags');

br = uicontrol('Units','normalized',...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Autoset',...
    'Tag','ButtonAutoset');
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

mb = copyobj(old_handles.MinusButton,iP);
pb = copyobj(old_handles.PlusButton,iP);
rb = copyobj(old_handles.RescaleButton,iP);
bb = copyobj(old_handles.BackButton,iP);
skb = copyobj(old_handles.SkipButton,iP);
tb = copyobj(old_handles.TagButton,iP);
ptb = copyobj(old_handles.prevTagButton,iP);
ntb = copyobj(old_handles.nextTagButton,iP);
mb.Units='normalized';
pb.Units='normalized';
rb.Units='normalized';
bb.Units='normalized';
skb.Units='normalized';
tb.Units='normalized';
ptb.Units='normalized';
ntb.Units='normalized';

% Info Panel Position
pu_lfp.Position=     [0     .025    .15   .25];
pu_emg.Position=     [0     .35    .15   .25];
pu_acc.Position=     [0     .675    .15   .25];
e1.Position =   [.41     .55  .09   .35];
e2.Position =   [.41     .1   .09   .35];

pu_ratio1.Position=     [.51     .675    .15   .25];
pu_ratio2.Position=     [.51     .35    .15   .25];
pu_algo.Position =   [.51     .025    .15   .25];

e3.Position =   [.68     .65     .05  .3];
e4.Position =   [.68     .325     .05  .3];

cb1.Position = [.74     .75   .02   .2];
cb2.Position = [.74     .5   .02   .2];
cb3.Position = [.74     .25   .02   .2];
cb4.Position = [.74     0   .02   .2];

ba.Position = [.76     .5     .08       .45];
br.Position = [.84     .5     .08       .45];
bc.Position = [.92     .5     .08       .45];
bss.Position = [.76     0     .08       .45];
bsi.Position = [.84     0     .08       .45];
bbs.Position = [.92     0     .08       .45];

mb.Position =   [.15     .55    .06      .35];
pb.Position =   [.15     .1     .06      .35];
rb.Position =   [.215   .55    .06      .35];
bb.Position =   [.215   .1     .06      .35];
skb.Position =  [.28    .55    .06      .35];
tb.Position =   [.28    .1     .06      .35];
ptb.Position =  [.345   .55    .06      .35];
ntb.Position =  [.345   .1     .06      .35];

% Top Panel
tP = uipanel('Units','normalized',...
    'bordertype','etchedin',...
    'Tag','TopPanel',...
    'Position',[0 iP.Position(4) 1 1-iP.Position(4)],...
    'Parent',f2);

%Traces
ax1 = axes('Parent',tP,'Tag','Ax1','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax2 = axes('Parent',tP,'Tag','Ax2','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax3 = axes('Parent',tP,'Tag','Ax3','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax4 = axes('Parent',tP,'Tag','Ax4','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax5 = axes('Parent',tP,'Tag','Ax5','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax6 = axes('Parent',tP,'Tag','Ax6','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax7 = axes('Parent',tP,'Tag','Ax7','YTick',[1 2 3 4],'YTickLabel',{'AW';'QW';'NREM';'REM'},...
    'YDir','reverse','YLim',[.5 4.5]);
ax1.Position =  [.05   .83     .9      .12];
ax2.Position =  [.05   .7    .9      .12];
ax3.Position =  [.05   .57    .9      .12];
ax4.Position =  [.05   .44    .9      .12];
ax5.Position =  [.05   .31    .9      .12];
ax6.Position =  [.05   .18    .9      .12];
ax7.Position =  [.05   .05    .9      .12];

all_axes = [ax1;ax2;ax3;ax4;ax5;ax6;ax7];
linkaxes(all_axes,'x');

handles2 = guihandles(f2) ;
if ~isempty(handles2.TagButton.UserData)&&length(handles2.TagButton.UserData.Selected)>1
    handles2.TagButton.UserData=[];
end

%Interactive Control
edits = [handles2.Edit1;handles2.Edit2];
set(handles2.prevTagButton,'Callback',{@template_prevTag_Callback,handles2.TagButton,ax2,edits});
set(handles2.nextTagButton,'Callback',{@template_nextTag_Callback,handles2.TagButton,ax2,edits});
set(handles2.PlusButton,'Callback',{@template_buttonPlus_Callback,ax2,edits});
set(handles2.MinusButton,'Callback',{@template_buttonMinus_Callback,ax2,edits});
set(handles2.RescaleButton,'Callback',{@template_buttonRescale_Callback,ax2,edits});
set(handles2.SkipButton,'Callback',{@template_buttonSkip_Callback,ax2,edits});
set(handles2.BackButton,'Callback',{@template_buttonBack_Callback,ax2,edits});
set(handles2.TagButton,'Callback',{@template_button_TagSelection_Callback,ax2,edits,'single'});

set(handles2.Edit1,'Callback',{@edit_Callback,all_axes});
set(handles2.Edit2,'Callback',{@edit_Callback,all_axes});
set(handles2.Edit3,'Callback',{@buttonAutoSet_Callback,handles2,all_axes});
set(handles2.Edit4,'Callback',{@edit4_Callback,all_axes});

set(handles2.Checkbox1,'Callback',{@checkbox1_Callback,all_axes});
set(handles2.Checkbox2,'Callback',{@checkbox2_Callback,all_axes});
set(handles2.Checkbox3,'Callback',{@checkbox3_Callback,all_axes});

set(handles2.ButtonAutoset,'Callback',{@buttonAutoSet_Callback,handles2,all_axes});
set(handles2.ButtonAutoScale,'Callback',{@buttonAutoScale_Callback,all_axes});
set(handles2.ButtonCompute,'Callback',{@compute_Callback,handles2});
set(handles2.ButtonSaveImage,'Callback',{@saveimage_Callback,handles2});
set(handles2.ButtonSaveStats,'Callback',{@savestats_Callback,handles2});
set(handles2.ButtonBatchSave,'Callback',{@batchsave_Callback,handles2,all_axes});

% Popup LFP control
pu_lfp.Callback = {@update_popup_lfp_Callback,handles2,ax2};
update_popup_lfp_Callback(pu_lfp,[],handles2,ax2);
% Popup EMG/ACC control
pu_acc.Callback = {@update_popup_accemg_Callback,handles2,ax3};
update_popup_accemg_Callback(pu_acc,[],handles2,ax3);
pu_emg.Callback = {@update_popup_accemg_Callback,handles2,ax4};
update_popup_accemg_Callback(pu_emg,[],handles2,ax4);
% Popup Ratio 1 & 2 control
pu_ratio1.Callback = {@update_popup_ratio_Callback,handles2,ax5};
pu_ratio2.Callback = {@update_popup_ratio_Callback,handles2,ax6};

% Initialize Ax1
% Importing all lines to ax1
all_lines = flipud(findobj(old_handles.RightAxes,'type','line','-not','Tag','Cursor'));
for i =1:length(all_lines)
    newl = copyobj(all_lines(i),ax1);
    if strcmp(newl.Tag,'Trace_Region')
        newl.Marker ='.';
        newl.MarkerSize = 5;
        newl.LineStyle ='none';
    end
end
% Updating XData
all_obj = ax1.Children;
for j = 1:length(all_obj)
    ll = all_obj(j);
    if strcmp(ll.Tag,'Trace_Cerep')
        ll.XData = ll.UserData.X;
        ll.YData = 1+rescale(ll.UserData.Y,0,1);
    elseif strcmp(ll.Type,'line')
        ll.XData = xdat(:);
        ll.YData = 1+rescale(ll.YData,0,1);
    end
end
% Importing button
button = copyobj(old_handles.TracesButton,tP);
button.Units = 'normalized';
button.Tag = sprintf('Button%d',1);
button.TooltipString = 'Traces Edition Ax1';
button.Callback = {@menuEdit_TracesEdition_Callback,ax1,old_handles};
%button.Position = [];
ax1.YLim = [0 1];
ax1.YLabel.String = {'Nlab traces'};

% All Axes
for i=1:length(all_axes)
    set(all_axes(i),'ButtonDownFcn',{@template_axes_clickFcn,0,all_axes,edits});
end

% Set Time Limits 
edit_Callback(edits,[],all_axes);
buttonAutoScale_Callback([],[],all_axes);
template_buttonRescale_Callback([],[],ax2,edits);
colormap(f2,'jet');

% Compute scoring
if ~isempty(data_ss)
    compute_Callback([],[],handles2);
end

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
% str_tag contains group names 
if val==0
    batchsave_Callback([],[],handles2,all_axes);
end

handles2.MainFigure.Pointer = 'arrow';

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

function edit4_Callback(~,~,all_axes)

for i=1:length(all_axes)
    update_threshpatch(all_axes(i));
end

end

function checkbox1_Callback(hObj,~,ax)

for i =1:length(ax)
    source = findobj(ax(i),'Tag','Source');
    spectro = findobj(ax(i),'Tag','Spectro');
    for j=1:length(source)
        if hObj.Value
            source(j).Visible='on';
            spectro(j).Visible='off';
        else
            source(j).Visible='off';
            spectro(j).Visible='on';
        end
    end
end

end

function checkbox2_Callback(hObj,~,ax)

for i =1:length(ax)
    source = findobj(ax(i),'Tag','Threshold','-or','Tag','Threshold_patch');
    for j=1:length(source)
        if hObj.Value
            source(j).Visible='on';
        else
            source(j).Visible='off';
        end
    end
end

end

function checkbox3_Callback(hObj,~,ax)

for i =1:length(ax)
    
    if ~hObj.Value
        ax(i).YScale ='linear';
    else
        ax(i).YScale ='log';
    end
    
    % Update threshold patch
    update_threshpatch(ax(i));
end

end

function click_threshold(hObj,~,ax)
%ax = hObj.Parent;
%ax.UserData = 2;
%pt_rp = hObj.Parent.CurrentPoint;
f = ax.Parent.Parent;
f.Pointer = 'hand';
set(f,'WindowButtonMotionFcn', {@figure_motionFcn,ax});
set(f,'WindowButtonUpFcn', {@unclickFcn,ax});

end

function figure_motionFcn(~,~,ax)

pt_rp = ax.CurrentPoint;
Xlim = ax.XLim;
Ylim = ax.YLim;
l_thresh = findobj(ax,'Tag','Threshold');
l_power = findobj(ax,'Tag','Power');
l_threshpatch = findobj(ax,'Tag','Threshold_patch');

edit4 = findobj(ax.Parent.Parent,'Tag','Edit4');
t_min = str2double(edit4.String);
cb2 = findobj(ax.Parent.Parent,'Tag','Checkbox2');
if cb2.Value visible2='on' ;else visible2='off' ;end

delete(l_threshpatch);
% Move thresh
if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
    
    thresh = pt_rp(1,2);
    test = l_power.YData;

    % Dilation: Including short below-threshold episodes
    ind_below = test<thresh;
    % Building ind_start & ind_end
    ind_start = find(diff(ind_below)==1)+1;
    ind_end = find(diff(ind_below)==-1);
    if ind_end(1)<ind_start(1)
        ind_start = [1;ind_start(:)];
    end
    if ind_start(end)>ind_end(end)
        ind_end = [ind_end(:);length(ind_below)];
    end  
    % Getting coordinates
    coordinates_up = [ind_start(:),ind_end(:)];
    times_up = [];
    for j =1:size(coordinates_up,1)
        times_up = [times_up;l_power.XData(ind_start(j)) l_power.XData(ind_end(j))];
    end  
    % Removing
    ind_rm = (times_up(:,2)-times_up(:,1))<t_min;
    temp = coordinates_up(ind_rm,:);
    for i=1:size(temp,1)
        ind_below(temp(i,1):temp(i,2)) = false;
    end
    times_up(ind_rm,:) = [];
    coordinates_up(ind_rm,:) = [];
    ind_start(ind_rm)=[];
    ind_end(ind_rm)=[];
    
    % Erosion: Removing short below-threshold episodes
    ind_above = ~ind_below;
    % Building ind_start & ind_end
    ind_start = find(diff(ind_above)==1)+1;
    ind_end = find(diff(ind_above)==-1);
    if ind_end(1)<ind_start(1)
        ind_start = [1;ind_start(:)];
    end
    if ind_start(end)>ind_end(end)
        ind_end = [ind_end(:);length(ind_above)];
    end  
    % Getting coordinates
    coordinates_up = [ind_start(:),ind_end(:)];
    times_up = [];
    for j =1:size(coordinates_up,1)
        times_up = [times_up;l_power.XData(ind_start(j)) l_power.XData(ind_end(j))];
    end  
    % Removing
    ind_rm = (times_up(:,2)-times_up(:,1))<t_min;
    temp = coordinates_up(ind_rm,:);
    for i=1:size(temp,1)
        ind_above(temp(i,1):temp(i,2)) = false;
    end
    times_up(ind_rm,:) = [];
    coordinates_up(ind_rm,:) = [];
    ind_start(ind_rm)=[];
    ind_end(ind_rm)=[];

    %Updating lines
    l_thresh.YData = [thresh, thresh];
    for i =1:size(coordinates_up,1)
%         line('XData',[l_power.XData(ind_start(i)) l_power.XData(ind_end(i))],'YData',[thresh, thresh],...
%             'LineWidth',2,'Color','r','Tag','Threshold_patch','Visible','on','HitTest','off');
        patch('XData',[l_power.XData(ind_start(i)) l_power.XData(ind_end(i)) l_power.XData(ind_end(i)) l_power.XData(ind_start(i))],...
            'YData',[ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)],...
            'FaceColor','r','FaceAlpha',.5,'EdgeColor','none','LineWidth',.1,...
            'Tag','Threshold_patch','Visible',visible2,'HitTest','off');
    end   
    
    % Storing
    ax.UserData.ypower = test;
    ax.UserData.thresh = thresh;
    ax.UserData.ind_keep = ind_above;
    ax.UserData.coordinates_up = coordinates_up;
    ax.UserData.times_up = times_up;

end

end

function unclickFcn(~,~,ax)
f = ax.Parent.Parent;
set(f,'WindowButtonMotionFcn','');
set(f,'WindowButtonUpFcn', '');
%ax2.UserData = [];
f.Pointer = 'arrow';
end

function update_popup_accemg_Callback(pu,~,handles,ax)

if strcmp(pu.String,'.')
    pu.Enable = 'off';
    return;
end

% Clearing ax
delete(ax.Children);

% Visible status
if handles.Checkbox2.Value visible2='on' ;else visible2='off' ;end

% Loading data
path = pu.UserData.path;
channel_type = pu.UserData.channel_type;
channel = char(pu.String(pu.Value,:));
g_colors = handles.MainFigure.UserData.g_colors;
% savedir = handles.MainFigure.UserData.savedir;
% time_ref = handles.MainFigure.UserData.time_ref;

if ~exist(fullfile(path,strcat(channel,'.mat')),'file')
    warning('Problem loading channel [%s].',channel);
    return;
else
    data_source = load(fullfile(path,strcat(channel,'.mat')));
end

if ~exist(fullfile(path,strcat('Power-',channel,'.mat')),'file')
    warning('Problem loading Power channel [%s].',channel);
    return;
else
    data_power = load(fullfile(path,strcat('Power-',channel,'.mat')));
end

switch channel_type
    case 'EMG'
        color = [.5 .5 .5];
    case 'ACC'
        color = [0 1 0];
    case 'GYR'
        color = [0 0 1];
    otherwise
        color = g_colors(1,:);
end

% X = (data_source.x_start:data_source.f:data_source.x_end)';
% Y = 1+rescale(data_source.Y,0,1);
% line('XData',X,'YData',Y,'Parent',ax,'Color',color,'Tag','Source','HitTest','off','Visible',visible1);

X = (data_power.x_start:data_power.f:data_power.x_end)';
% Y = 1+rescale(data_power.Y,0,1);
Y = 1+rescale(log(1+data_power.Y),0,1);
% Interpolate to t_source
t_source = handles.MainFigure.UserData.t_source;
Y = interp1(X,Y,t_source);
X = t_source;
line('XData',X,'YData',Y,'Parent',ax,'Color',color,'Tag','Power','HitTest','off','Visible','on');
ax.YLabel.String = strrep(channel,'_','-');

% Setting threshold
if isempty(pu.UserData.thresh_init)
    z_score = str2double(handles.Edit3.String);
    val = mean(Y,'omitnan')+z_score*std(Y,[],'omitnan');
else
    val = pu.UserData.thresh_init;
    pu.UserData.thresh_init = [];
end

l = line('XData',[X(1) X(end)],'YData',[val val],'Parent',ax,...
    'LineWidth',.5,'Color','k','Tag','Threshold','Visible',visible2);
l.ButtonDownFcn = {@click_threshold,ax};

% Update threshold patch
update_threshpatch(ax);

end

function update_popup_lfp_Callback(pu,~,handles,ax)

% Clearing ax
delete(ax.Children);

% Visible status
if handles.Checkbox1.Value 
    visible1='on';
    not_visible1='off';
else
    visible1='off';
    not_visible1='on';
end

% Loading data
path = pu.UserData.path;
path_spectro = pu.UserData.path_spectro;
channel_type = pu.UserData.channel_type;
channel = char(pu.String(pu.Value,:));
g_colors = handles.MainFigure.UserData.g_colors;
% savedir = handles.MainFigure.UserData.savedir;
% time_ref = handles.MainFigure.UserData.time_ref;

pu_ratio1 = findobj(handles.MainFigure,'Tag','Popup_Ratio1');
pu_ratio2 = findobj(handles.MainFigure,'Tag','Popup_Ratio2');

if ~exist(fullfile(path,strcat(channel,'.mat')),'file')
    warning('Problem loading channel [%s].',channel);
    pu_ratio1.String = ' ';
    pu_ratio1.Value = 1;
    pu_ratio2.String = ' ';
    pu_ratio2.Value = 1;
    return;
else
    data_source = load(fullfile(path,strcat(channel,'.mat')));
end

if ~isempty(path_spectro)  
    handles.Checkbox1.Enable = 'on';
    d_spectro = dir(fullfile(path_spectro,'*.mat'));
    ind_channel = find(contains({d_spectro(:).name}',channel)==1);
    if ~isempty(ind_channel)
        ind_channel_whole = find(contains({d_spectro(:).name}',strcat(channel,'_Whole-LFP'))==1);
        if ~isempty(ind_channel_whole)
            ind_channel = ind_channel_whole;
        elseif length(ind_channel)>1
            ind_channel = ind_channel(1);
        end
        data_spectro = load(fullfile(path_spectro,d_spectro(ind_channel).name));
    else
        data_spectro = [];
        handles.Checkbox1.Enable = 'off';
        warning('Empty Spectrogramm folder.');
    end
else
    data_spectro = [];
    handles.Checkbox1.Enable = 'off';
    warning('Missing Spectrogramm folder.');
end

% if ~exist(fullfile(path,strcat('Power-broadband',strrep(channel,'LFP',''),'.mat')),'file')
%     warning('Problem loading broadband channel [%s].',channel);
%     pu_ratio1.String = ' ';
%     pu_ratio1.Value = 1;
%     pu_ratio2.String = ' ';
%     pu_ratio2.Value = 1;
%     return;
% else
%     data_power = load(fullfile(path,strcat('Power-broadband',strrep(channel,'LFP',''),'.mat')));
% end

% Plotting Source
color = [0 0 0];
X = (data_source.x_start:data_source.f:data_source.x_end)';
Y = 1+rescale(data_source.Y,0,1);
line('XData',X,'YData',Y,'Parent',ax,'Color',color,'Tag','Source','Visible',visible1);
ax.YLabel.String = strrep(channel,'_','-');

% Storing X_source as time reference
t_source = X;
handles.MainFigure.UserData.t_source = t_source;
delta_source = t_source(2)-t_source(1);
handles.MainFigure.UserData.delta_source = delta_source;

% Plotting Spectro
delete(findobj(ax,'Tag','Spectro'));
if ~isempty(data_spectro)
    hold(ax,'on');
    X_spectro = data_spectro.Xdata_sub;
    %Y_spectro = rescale(data_spectro.fdom_min:data_spectro.fdom_step:data_spectro.fdom_max,0,1);
    Y_spectro = 1:1/(length(X_spectro)-1):2;
    C_spectro = data_spectro.Cdata_sub;
    imagesc('XData',X_spectro,'YData',Y_spectro,'CData',C_spectro,...
        'Parent',ax,'Tag','Spectro','Visible',not_visible1,'HitTest','off');
    %ax.YTickLabel.String = []
    hold(ax,'off');
end

% Storing X_source as time reference
t_source = X;
handles.MainFigure.UserData.t_source = t_source;

% X = (data_power.x_start:data_power.f:data_power.x_end)';
% Y = 1+rescale(data_power.Y,0,1);
% % Interpolate to t_source
% Y = interp1(X,Y,t_source);
% X = t_source;
% line('XData',X,'YData',Y,'Parent',ax,'Color',color,'Tag','Power','Visible',visible2);

% Updating pu_ratio1
d_envelope = dir(fullfile(path,strcat('Power-*.mat')));
% ind_keep = contains({d_envelope(:).name}',strrep(channel,'LFP',''));
ind_keep = contains({d_envelope(:).name}',strcat(strrep(channel,'LFP',''),'.mat'));
d_envelope = d_envelope(ind_keep);
pu_ratio1.UserData.d_envelope = d_envelope;
pu_ratio2.UserData.d_envelope = d_envelope;

temp = {d_envelope.name}';
temp = regexprep(temp,'Power-','');
temp = regexprep(temp,'.mat','');
%temp = regexprep(temp,strrep(channel,'LFP',''),'');
temp = strrep(temp,strrep(channel,'LFP',''),'');

temp2 = [];
for i =1:length(temp)
    for j =1:length(temp)
        if i~=j
            temp2 = [temp2;{sprintf('%s/%s',char(temp(j)),char(temp(i)))}];
        end
    end
end
% adding empty denominator
temp2 = [temp2;temp];

if isempty(temp2)
    warning('No Power trace found for this channel [%s].',channel);
    pu_ratio1.String = ' ';
    pu_ratio1.Value = 1;
    pu_ratio2.String = ' ';
    pu_ratio2.Value = 1;
    return;
else
    % Popup 1
    pu_ratio1.String = temp2;   
    if ~isempty(pu.UserData.channel_1)
        pu_ratio1.Value = find(contains(temp2,pu.UserData.channel_1)==1);
        pu.UserData.channel1 = [];
    elseif sum(contains(temp2,'theta/delta')>0)
        pu_ratio1.Value = find(contains(temp2,'theta/delta')==1);
    else
        pu_ratio1.Value = 1;
    end
    update_popup_ratio_Callback(pu_ratio1,[],handles,handles.Ax5);
    
    % Popup 2
    pu_ratio2.String = temp2;
    if ~isempty(pu.UserData.channel_2)
        pu_ratio2.Value = find(contains(temp2,pu.UserData.channel_2)==1);
        pu.UserData.channel2 = [];
    elseif sum(contains(temp2,'ripple/broadband')>0)
        pu_ratio2.Value = find(contains(temp2,'ripple/broadband')==1);
    else
        pu_ratio2.Value = 1;
    end
    update_popup_ratio_Callback(pu_ratio2,[],handles,handles.Ax6);
end

end

function update_popup_ratio_Callback(pu,~,handles,ax)

% Clearing ax
delete(ax.Children);

% Visible status
if handles.Checkbox2.Value 
    visible2='on';
else
    visible2='off';
end

d = pu.UserData.d_envelope;
ratio = pu.String(pu.Value,:);
%ax.YLabel.String = ratio;
g_colors = handles.MainFigure.UserData.g_colors;
t_source = handles.MainFigure.UserData.t_source;
    
% Finding traces
temp = regexp(char(ratio),'/','split');
numerator = char(temp(1));
% Loading traces
ind_num = find(contains({d(:).name}',strcat('Power-',numerator,'_'))==1);
data_num = load(fullfile(d(ind_num).folder,d(ind_num).name));

if length(temp)>1
    % Loading traces
    denominator = char(temp(2));
    ax.YLabel.String = sprintf('%s/\n%s',numerator,denominator);
    ind_den = find(contains({d(:).name}',strcat('Power-',denominator,'_'))==1);
    data_den = load(fullfile(d(ind_den).folder,d(ind_den).name));
    
    % Interpolate to t_source
    X1 = (data_num.x_start:data_num.f:data_num.x_end)';
    Y1 = interp1(X1,data_num.Y,t_source);
    X2 = (data_den.x_start:data_den.f:data_den.x_end)';
    Y2 = interp1(X2,data_den.Y,t_source);
    Y = Y1./Y2;
    X = t_source;

else
    ax.YLabel.String = sprintf('%s',numerator);
    
    % Interpolate to t_source
    X1 = (data_num.x_start:data_num.f:data_num.x_end)';
    Y = interp1(X1,data_num.Y,t_source);
    X = t_source;
end

switch ax.Tag
    case 'Ax5'
        color = g_colors(2,:);
    case 'Ax6'
        color = g_colors(3,:);
end
line('XData',X,'YData',Y,'Parent',ax,'Color',color,'Tag','Power','HitTest','off','Visible','on');

% Setting threshold
if isempty(pu.UserData.thresh_init)
    z_score = str2double(handles.Edit3.String);
    val = mean(Y,'omitnan')+z_score*std(Y,[],'omitnan');
else
    val = pu.UserData.thresh_init;
    pu.UserData.thresh_init = [];
end
l = line('XData',[X(1) X(end)],'YData',[val val],'Parent',ax,...
    'LineWidth',.5,'Color','k','Tag','Threshold','Visible',visible2);
l.ButtonDownFcn = {@click_threshold,ax};

% Update threshold patch
update_threshpatch(ax);

end

function buttonAutoScale_Callback(~,~,all_axes)

epsilon = 1e-3;

for i =1:length(all_axes)
    ax = all_axes(i);
    xlim1 = ax.XLim(1);
    xlim2 = ax.XLim(2);
    
    switch ax.Tag
        case 'Ax1'
            % Autoscale upper axis
            all_lines = findobj(ax,'Type','Line','-not','Tag','Cursor','-and','Visible','on');
            l_main = all_lines(1);
            l_second = all_lines(2:end);
            l_spectro = [];
        case 'Ax2'
            % Autoscale LFP, EMG, GYR Axes
            l_main = findobj(ax,'Tag','Source','-and','Visible','on');
            % l_second = findobj(ax,'Tag','Power','-and','Visible','on');
            l_second = [];
            l_spectro = findobj(ax,'Tag','Spectro');
        otherwise
            l_main = findobj(ax,'Tag','Power','-and','Visible','on');
            l_second = [];
            l_spectro = [];
            
    end
    % Autoscaling
    if ~isempty(l_main)
        [~,ind1] = min((l_main.XData-xlim1).^2);
        [~,ind2] = min((l_main.XData-xlim2).^2);
        ylim1 = min(l_main.YData(ind1:ind2),[],'omitnan');
        ylim2 = max(l_main.YData(ind1:ind2),[],'omitnan');
        if ~isnan(ylim1)&&~isnan(ylim2)
            ax.YLim = [ylim1-epsilon,ylim2+epsilon];
        end
    end
    % Secondary lines
    for j=1:length(l_second)
        l_source = l_second(j);
        [~,ind3] = min((l_source.XData-xlim1).^2);
        [~,ind4] = min((l_source.XData-xlim2).^2);
        ylim3 = min(l_source.YData(ind3:ind4),[],'omitnan');
        ylim4 = max(l_source.YData(ind3:ind4),[],'omitnan');
        %ax.YLim = [ylim1,ylim2];
        factor = (ylim2-ylim1)/(ylim4-ylim3);
        l_source.YData = factor*l_source.YData;
        ylim3 = min(l_source.YData(ind3:ind4),[],'omitnan');
        l_source.YData = l_source.YData -(ylim3-ylim1);
    end 
    % Spectro
    for j=1:length(l_spectro)
        l_spectro = l_spectro(j);
        %l_spectro.YData = rescale(l_spectro.YData,ax.YLim(1),ax.YLim(2));
        l_spectro.YData = ax.YLim(1):(ax.YLim(2)+1-ax.YLim(1))/(length(l_spectro.XData)-1):ax.YLim(2);
        [~,ind5] = min((l_spectro.XData-xlim1).^2);
        [~,ind6] = min((l_spectro.XData-xlim2).^2);
        clim1 = min(min(l_spectro.CData(ind5:ind6),[],'omitnan'),[],'omitnan');
        clim2 = max(max(l_spectro.CData(ind5:ind6),[],'omitnan'),[],'omitnan');
        ax.CLim = [clim1,clim2];
    end 
    
    % Threshold Patch
    update_threshpatch(ax);   
    
end

end

function buttonAutoSet_Callback(~,~,handles,all_axes)

for i =1:length(all_axes)
    ax = all_axes(i);
    % xlim1 = ax.XLim(1);
    % xlim2 = ax.XLim(2);
    
    l_thresh = findobj(ax,'Tag','Threshold');
    l_power = findobj(ax,'Tag','Power');
    
    % Update thresh
    if ~isempty(l_thresh)
        Y = l_power.YData;
        % Setting threshold
        z_score = str2double(handles.Edit3.String);
        val = mean(Y,'omitnan')+z_score*std(Y,[],'omitnan');
        l_thresh.YData = [val val];
    end
    
    % Update threshold patch
    update_threshpatch(ax);
    
end

end

function update_threshpatch(ax)

edit4 = findobj(ax.Parent.Parent,'Tag','Edit4');
t_min = str2double(edit4.String);
delta_source = ax.Parent.Parent.UserData.delta_source;
step = round(t_min/delta_source);
l_thresh = findobj(ax,'Tag','Threshold');
l_power = findobj(ax,'Tag','Power');
l_threshpatch = findobj(ax,'Tag','Threshold_patch'); 

cb2 = findobj(ax.Parent.Parent,'Tag','Checkbox2');
if cb2.Value visible2='on' ;else visible2='off' ;end

% Deleting existing patches
delete(l_threshpatch);

% Move thresh
if ~isempty(l_thresh)
    
    thresh = l_thresh.YData(1);
    test = l_power.YData;
    
    % Dilation: Including short below-threshold episodes
    ind_below = test<thresh;
    % Building ind_start & ind_end
    ind_start = find(diff(ind_below)==1)+1;
    ind_end = find(diff(ind_below)==-1);
    if ind_end(1)<ind_start(1)
        ind_start = [1;ind_start(:)];
    end
    if ind_start(end)>ind_end(end)
        ind_end = [ind_end(:);length(ind_below)];
    end  
    % Getting coordinates
    coordinates_up = [ind_start(:),ind_end(:)];
    times_up = [];
    for j =1:size(coordinates_up,1)
        times_up = [times_up;l_power.XData(ind_start(j)) l_power.XData(ind_end(j))];
    end  
    % Removing
    ind_rm = (times_up(:,2)-times_up(:,1))<t_min;
    temp = coordinates_up(ind_rm,:);
    for i=1:size(temp,1)
        ind_below(temp(i,1):temp(i,2)) = false;
    end
    times_up(ind_rm,:) = [];
    coordinates_up(ind_rm,:) = [];
    ind_start(ind_rm)=[];
    ind_end(ind_rm)=[];
    
    % Erosion: Removing short below-threshold episodes
    ind_above = ~ind_below;
    % Building ind_start & ind_end
    ind_start = find(diff(ind_above)==1)+1;
    ind_end = find(diff(ind_above)==-1);
    if ind_end(1)<ind_start(1)
        ind_start = [1;ind_start(:)];
    end
    if ind_start(end)>ind_end(end)
        ind_end = [ind_end(:);length(ind_above)];
    end  
    % Getting coordinates
    coordinates_up = [ind_start(:),ind_end(:)];
    times_up = [];
    for j =1:size(coordinates_up,1)
        times_up = [times_up;l_power.XData(ind_start(j)) l_power.XData(ind_end(j))];
    end  
    % Removing
    ind_rm = (times_up(:,2)-times_up(:,1))<t_min;
    temp = coordinates_up(ind_rm,:);
    for i=1:size(temp,1)
        ind_above(temp(i,1):temp(i,2)) = false;
    end
    times_up(ind_rm,:) = [];
    coordinates_up(ind_rm,:) = [];
    ind_start(ind_rm)=[];
    ind_end(ind_rm)=[];

    % Recreating patches
    l_thresh.YData = [thresh, thresh];
    for j =1:size(coordinates_up,1)
        %         line('XData',[l_power.XData(ind_start(j)) l_power.XData(ind_end(j))],'YData',[thresh, thresh],...
        %             'LineWidth',2,'Color','r','Tag','Threshold_patch','Visible','on','HitTest','off');
        patch('XData',[l_power.XData(ind_start(j)) l_power.XData(ind_end(j)) l_power.XData(ind_end(j)) l_power.XData(ind_start(j))],...
            'YData',[ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)],...
            'FaceColor','r','FaceAlpha',.5,'EdgeColor','none','LineWidth',.1,...
            'Tag','Threshold_patch','Visible',visible2,'HitTest','off','Parent',ax);
    end
    % Storing
    ax.UserData.ypower = test;
    ax.UserData.thresh = thresh;
    ax.UserData.ind_keep = ind_above;
    ax.UserData.coordinates_up = coordinates_up;
    ax.UserData.times_up = times_up;   
else
    ax.UserData.ypower = [];
    ax.UserData.thresh = [];
    ax.UserData.ind_keep = [];
    ax.UserData.coordinates_up = [];
    ax.UserData.times_up = [];
end

end

function compute_Callback(~,~,handles)

% Pointer
handles.MainFigure.Pointer = 'watch';
handles.MainFigure.UserData.success = false;
drawnow;

% Getting parameters
g_colors = handles.MainFigure.UserData.g_colors;
t_source = handles.MainFigure.UserData.t_source;

% Getting values
S.index_acc = handles.Ax3.UserData.ind_keep;
S.index_emg = handles.Ax4.UserData.ind_keep;
S.index_ratio1 = handles.Ax5.UserData.ind_keep;
S.index_ratio2 = handles.Ax6.UserData.ind_keep;
S.thresh_acc = handles.Ax3.UserData.thresh;
S.thresh_emg = handles.Ax4.UserData.thresh;
S.thresh_ratio1 = handles.Ax5.UserData.thresh;
S.thresh_ratio2 = handles.Ax6.UserData.thresh;
S.algorithm = handles.Popup_Algo.String(handles.Popup_Algo.Value,:);

% Sleep Scoring Algo
[t_sleepscored,T] = sleep_score(t_source,S);
all_times = T.all_times;
timeData = T.timeData;

% Plot Sleep Score
%cla(handles.Ax7.Children);
delete(findobj(handles.Ax7,'Tag','Hypnogram'));
line('XData',t_source,'YData',t_sleepscored,'Tag','Hypnogram','Parent',handles.Ax7);

% Create Time Patches
load('Preferences.mat','GColors');
delete(findobj(handles.Ax7,'Tag','TimePatch'));
all_patterns = {'QW';'AW';'NREM';'REM'};
for index = 1:size(all_patterns,1)
    pattern = all_patterns(index);
    index_pattern = strcmp({GColors.TimeGroups(:).Name}',pattern);
    face_color = GColors.TimeGroups(index_pattern).Color;
    face_alpha = GColors.TimeGroups(index_pattern).Transparency;
    
    ind_pattern = strcmp(timeData,pattern);
    timeData_pattern = timeData(ind_pattern,:);
    xdata = all_times(ind_pattern,:);
    for i =1:size(timeData_pattern,1)
        %create patch
        %ylim = [handles.RightAxes.YLim];
        patch('XData',[xdata(i,1) xdata(i,2) xdata(i,2) xdata(i,1)],...
            'YData',[0 0 5 5],...
            'FaceColor',face_color,'FaceAlpha',face_alpha,'EdgeColor','none',...
            'Parent',handles.Ax7,'Tag','TimePatch','HitTest','off');
    end
end

handles.MainFigure.Pointer = 'arrow';
handles.MainFigure.UserData.success = true;

% Storing parameters
handles.MainFigure.UserData.t_source = t_source;
handles.MainFigure.UserData.t_sleepscored = t_sleepscored;
handles.MainFigure.UserData.T = T;
% Storing
handles.MainFigure.UserData.channel_lfp = char(handles.Popup_LFP.String(handles.Popup_LFP.Value,:));
handles.MainFigure.UserData.channel_acc = char(handles.Popup_ACC.String(handles.Popup_ACC.Value,:));
handles.MainFigure.UserData.channel_emg = char(handles.Popup_EMG.String(handles.Popup_EMG.Value,:));
handles.MainFigure.UserData.channel_1 = char(handles.Popup_Ratio1.String(handles.Popup_Ratio1.Value,:));
handles.MainFigure.UserData.channel_2 = char(handles.Popup_Ratio2.String(handles.Popup_Ratio2.Value,:));
handles.MainFigure.UserData.thresh_acc = S.thresh_acc;
handles.MainFigure.UserData.thresh_emg = S.thresh_emg;
handles.MainFigure.UserData.thresh_ratio1 = S.thresh_ratio1;
handles.MainFigure.UserData.thresh_ratio2 = S.thresh_ratio2;
handles.MainFigure.UserData.algorithm = S.algorithm;

handles.MainFigure.UserData.z_score = str2double(handles.Edit3.String);
handles.MainFigure.UserData.t_min = str2double(handles.Edit4.String);

end

function [t_sleepscored,T] = sleep_score(t_source,S)

% Initializing
index_acc = S.index_acc;
index_emg = S.index_emg;
index_ratio1 = S.index_ratio1;
index_ratio2 = S.index_ratio2;
algorithm = char(regexprep(S.algorithm,'.m',''));

% Scoring
% t_sleepscored = sleep_score_rat(index_acc,index_emg,index_ratio1,index_ratio2);
t_sleepscored = feval(algorithm,index_acc,index_emg,index_ratio1,index_ratio2);

% Getting times
times1 = [];
times2 = [];
times3 = [];
times4 = [];

i=1;
cur_state = t_sleepscored(i);
t_start = t_source(1);
all_times = [];
timeData = [];
for i=1:length(t_source)
    if t_sleepscored(i)~=cur_state ||i==length(t_source)
        t_end = t_source(i);
        switch cur_state
            case 1
                times1 = [times1; t_start t_end];
                timeData = [timeData;{'AW'} {sprintf('AW-%03d',size(times1,1))} {datestr(t_start/(24*3600),'HH:MM:SS.FFF')} {datestr(t_end/(24*3600),'HH:MM:SS.FFF')}];
                all_times = [all_times;t_start t_end];
            case 2
                times2 = [times2; t_start t_end];
                timeData = [timeData;{'QW'} {sprintf('QW-%03d',size(times2,1))} {datestr(t_start/(24*3600),'HH:MM:SS.FFF')} {datestr(t_end/(24*3600),'HH:MM:SS.FFF')}];
                all_times = [all_times;t_start t_end];
            case 3
                times3 = [times3; t_start t_end];
                timeData = [timeData;{'NREM'} {sprintf('NREM-%03d',size(times3,1))} {datestr(t_start/(24*3600),'HH:MM:SS.FFF')} {datestr(t_end/(24*3600),'HH:MM:SS.FFF')}];
                all_times = [all_times;t_start t_end];
            case 4
                times4 = [times4; t_start t_end];
                timeData = [timeData;{'REM'} {sprintf('REM-%03d',size(times4,1))} {datestr(t_start/(24*3600),'HH:MM:SS.FFF')} {datestr(t_end/(24*3600),'HH:MM:SS.FFF')}];
                all_times = [all_times;t_start t_end];
        end
        cur_state = t_sleepscored(i);
        t_start = t_end;
    end
end

T.all_times = all_times;
T.timeData = timeData;

end

function saveimage_Callback(~,~,handles)

load('Preferences.mat','GTraces');
global DIR_FIG;

%Loading data
channel_lfp = handles.MainFigure.UserData.channel_lfp;
%savedir = handles.MainFigure.UserData.savedir;
recording = handles.MainFigure.UserData.recording;

% Creating Save Directory
save_dir = fullfile(DIR_FIG,'Sleep_Scoring',recording);
if ~isdir(save_dir)
    mkdir(save_dir);
end

% Saving Image
pic_name = sprintf('%s_Sleep_Scoring(%s)%s',recording,strrep(channel_lfp,'.mat',''),GTraces.ImageSaveExtension);
if exist(fullfile(save_dir,pic_name),'file')
    fprintf('Image overwritten [%s].\n',fullfile(save_dir,pic_name));
else
    fprintf('Image saved [%s].\n',fullfile(save_dir,pic_name));
end
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);


end

function savestats_Callback(~,~,handles,val)
% Saves Sleep Scoring in stats dir
% Saves Sleep_Scoring.mat in savedir if val =1
% Saves Time_Tags.mat and Time_Groups.mat in savedir if val =1

if nargin<4
    val=1;
end

global DIR_STATS;
load('Preferences.mat','GTraces');

%Loading data
recording = handles.MainFigure.UserData.recording;
% Retrieving parameters
channel_lfp = handles.MainFigure.UserData.channel_lfp;
channel_acc = handles.MainFigure.UserData.channel_acc;
channel_emg = handles.MainFigure.UserData.channel_emg;
channel_1 = handles.MainFigure.UserData.channel_1;
channel_2 = handles.MainFigure.UserData.channel_2;
thresh_acc = handles.MainFigure.UserData.thresh_acc;
thresh_emg = handles.MainFigure.UserData.thresh_emg;
thresh_ratio1 = handles.MainFigure.UserData.thresh_ratio1;
thresh_ratio2 = handles.MainFigure.UserData.thresh_ratio2;
t_source = handles.MainFigure.UserData.t_source;
t_sleepscored = handles.MainFigure.UserData.t_sleepscored;
T = handles.MainFigure.UserData.T;
all_times = T.all_times;
timeData = T.timeData;
algorithm = handles.MainFigure.UserData.algorithm;
savedir = handles.MainFigure.UserData.savedir;
z_score = handles.MainFigure.UserData.z_score;
t_min = handles.MainFigure.UserData.t_min;

% Building TimeTags from all_times
n = size(all_times,1);
%TimeTags_strings
TimeTags_strings = timeData(:,3:4);
tts1 = datenum(TimeTags_strings(:,1));
tts2 = datenum(TimeTags_strings(:,2));
TimeTags_seconds = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;
%TimeTags_seconds = all_times;
TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');
% TimeTags_cell & TimeTags
TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
TimeTags_cell = cell(n+1,6);
TimeTags_cell(1,:) = {'Episode','Tag','Onset','Duration','Reference','Tokens'};
for k=1:n
    TimeTags_cell(k+1,:) = {'',char(timeData(k,2)),char(timeData(k,3)),char(TimeTags_dur(k,:)),char(timeData(k,3)),''};
    TimeTags(k,1).Episode = '';
    TimeTags(k,1).Tag = char(timeData(k,2));
    TimeTags(k,1).Onset = char(timeData(k,3));
    TimeTags(k,1).Duration = char(TimeTags_dur(k,:));
    TimeTags(k,1).Reference = char(timeData(k,3));
    TimeTags(k,1).Tokens = '';
end
% TimeTags_images
TimeTags_images = zeros(n,2);
tts = datenum(handles.MainFigure.UserData.TimeDisplay);
for k=1:size(TimeTags_strings,1)
    min_time = tts1(k);
    max_time = tts2(k);
    [~, ind_min_time] = min(abs(tts-datenum(min_time)));
    [~, ind_max_time] = min(abs(tts-datenum(max_time)));
    %TimeTags_strings(k,:) = {min_time,max_time};
    TimeTags_images(k,:) = [ind_min_time,ind_max_time];
end

% % Building TimeGroups from TimeTags
load('Preferences.mat','GColors');
all_names = {'QW';'AW';'NREM';'REM'};
all_strings = [];
for i=1:length(all_names)
    index = find(strcmp({GColors.TimeGroups(:).Name}',all_names(i))==1);
    all_strings = [all_strings;{GColors.TimeGroups(index(1)).String}'];
end
% all_tags = {TimeTags(:).Tag}';
% TimeGroups_name = [];
% TimeGroups_frames = [];
% TimeGroups_duration = [];
% TimeGroups_S = [];
% for i=1:size(all_names,1)
%     %indices = find(contains(all_tags,all_strings(i))==1);
%     indices = find(startsWith(all_tags,all_strings(i))==1);
%     if isempty(indices)
%         continue;
%     end
%     group_name = all_names(i);
%     n_frames = sum(TimeTags_images(indices,2)+1-TimeTags_images(indices,1));
%     duration_s = sum(datenum(TimeTags_strings(indices,2))-datenum(TimeTags_strings(indices,1)));
%     duration = datestr(duration_s,'HH:MM:SS.FFF');
%     % Struct S
%     S.Name = {TimeTags(indices).Tag}';
%     S.Selected = indices;
%     S.TimeTags_strings = TimeTags_strings(indices,:);
%     S.TimeTags_images = TimeTags_images(indices,:);
%     
%     % Building objects
%     TimeGroups_name = [TimeGroups_name;group_name];
%     TimeGroups_frames = [TimeGroups_frames;{sprintf('%d',n_frames)}];
%     TimeGroups_duration = [TimeGroups_duration;{duration}];
%     TimeGroups_S = [TimeGroups_S;S];  
% end

% Creating Stats Directory
data_dir = fullfile(DIR_STATS,'Sleep_Scoring',recording);
if ~isdir(data_dir)
    mkdir(data_dir);
end

% Saving data in stats dir
filename = sprintf('%s_Sleep_Scoring(%s).mat',recording,strrep(channel_lfp,'.mat',''));
save(fullfile(data_dir,filename),'recording','algorithm','z_score','t_min',...
    't_source','t_sleepscored','all_times','timeData',...
    'channel_lfp','channel_acc','channel_emg','channel_1','channel_2',...
    'thresh_acc','thresh_emg','thresh_ratio1','thresh_ratio2',...
    'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
%     'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
if exist(fullfile(data_dir,filename),'file')
    fprintf('Data overwritten [%s].\n',fullfile(data_dir,filename));
else
    fprintf('Data saved [%s].\n',fullfile(data_dir,filename));
end

if val==0
    % fprintf('Batch Mode Saving mode. No update in [%s].\n',savedir);
    warning('Batch Mode Saving mode. No update in [%s].',savedir);
    return;
end

% Saving Sleep_Scoring.mat
save(fullfile(savedir,'Sleep_Scoring.mat'),'recording','algorithm','z_score','t_min',...
    't_source','t_sleepscored','all_times','timeData',...
    'channel_lfp','channel_acc','channel_emg','channel_1','channel_2',...
    'thresh_acc','thresh_emg','thresh_ratio1','thresh_ratio2');
if exist(fullfile(savedir,'Sleep_Scoring.mat'),'file')
    fprintf('File Sleep_Scoring.mat updated [%s].\n',fullfile(savedir,'Sleep_Scoring.mat'));
else
    fprintf('File Sleep_Scoring.mat saved [%s].\n',fullfile(savedir,'Sleep_Scoring.mat'));
end

% Loading Time Tags
tt_data = handles.MainFigure.UserData.data_tt;
% tt_data = load(fullfile(savedir,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_images','TimeTags_strings');
if isempty(tt_data)
    save(fullfile(savedir,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    fprintf('===> Time Tags saved at %s.\n',fullfile(savedir,'Time_Tags.mat'));
else
    if handles.Checkbox4.Value
        % Overwrite        
        temp ={tt_data.TimeTags(:).Tag}';
        ind_keep = ~contains(temp,all_strings);
        tt_data.TimeTags_images = tt_data.TimeTags_images(ind_keep,:);
        tt_data.TimeTags_strings = tt_data.TimeTags_strings(ind_keep,:);
        tt_data.TimeTags_cell = [tt_data.TimeTags_cell(1,:);tt_data.TimeTags_cell(find(ind_keep==1)+1,:)];
        tt_data.TimeTags = tt_data.TimeTags(ind_keep);    
    end
    
    % Concatenate
    TimeTags_images = [tt_data.TimeTags_images;TimeTags_images];
    TimeTags_strings = [tt_data.TimeTags_strings;TimeTags_strings];
    TimeTags_cell = [TimeTags_cell(1,:);tt_data.TimeTags_cell(2:end,:);TimeTags_cell(2:end,:)];
    TimeTags = [tt_data.TimeTags;TimeTags];
    save(fullfile(savedir,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    if handles.Checkbox4.Value
        fprintf('===> Time Tags overwritten [%s].\n',fullfile(savedir,'Time_Tags.mat'));
    else
        fprintf('===> Time Tags concatenated [%s].\n',fullfile(savedir,'Time_Tags.mat'));
    end
end


% % Loading Time Groups
% tg_data = handles.MainFigure.UserData.data_tg;
% %tg_data = load(fullfile(savedir,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
% if isempty(tg_data)
%     save(fullfile(savedir,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
%     fprintf('===> Time Groups saved at %s\n',fullfile(savedir,'Time_Groups.mat'));
% else
%     if handles.Checkbox4.Value
%         % Overwrite
%         ind_keep = ones(size(tg_data.TimeGroups_name));
%         for i =1:length(all_names)
%             if sum(strcmp(tg_data.TimeGroups_name(i),all_names))>0
%                 ind_keep(i)=0;
%             end
%         end
%         ind_keep = find(ind_keep==1);
%         tg_data.TimeGroups_name = tg_data.TimeGroups_name(ind_keep,:);
%         tg_data.TimeGroups_frames = tg_data.TimeGroups_frames(ind_keep,:);
%         tg_data.TimeGroups_duration = tg_data.TimeGroups_duration(ind_keep,:);
%         tg_data.TimeGroups_S = tg_data.TimeGroups_S(ind_keep);  
%     end
%     % Concatenate Time_Groups.mat
%     TimeGroups_name = [tg_data.TimeGroups_name;TimeGroups_name];
%     TimeGroups_frames = [tg_data.TimeGroups_frames;TimeGroups_frames];
%     TimeGroups_duration = [tg_data.TimeGroups_duration;TimeGroups_duration];
%     TimeGroups_S = [tg_data.TimeGroups_S;TimeGroups_S];
%     save(fullfile(savedir,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
%     fprintf('===> Time Groups saved at %s.\n',fullfile(savedir,'Time_Groups.mat'));
% end

end

function batchsave_Callback(~,~,handles,all_axes)
% Batch mode : Save stats and images for all LFP electrodes
% Does not update Sleep_Scoring.mat in savedir

value = handles.Popup_LFP.Value;

% Compute for designated time tags
for j =1:size(handles.Popup_LFP.String,1)
    if j==value
        continue;
    end
    handles.Popup_LFP.Value = j;
    update_popup_lfp_Callback(handles.Popup_LFP,[],handles,handles.Ax2);
    
    buttonAutoScale_Callback([],[],all_axes);
    buttonAutoSet_Callback([],[],handles,all_axes);
    compute_Callback([],[],handles);
    saveimage_Callback([],[],handles);
    savestats_Callback([],[],handles,0);
end

handles.Popup_LFP.Value = value;
update_popup_lfp_Callback(handles.Popup_LFP,[],handles,handles.Ax2);
buttonAutoScale_Callback([],[],all_axes);
buttonAutoSet_Callback([],[],handles,all_axes);
compute_Callback([],[],handles);
saveimage_Callback([],[],handles);
savestats_Callback([],[],handles,0);

end