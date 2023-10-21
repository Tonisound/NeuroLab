function f2 = figure_AutoCorrelation(myhandles,val,str_tag,str_regions,str_group_regions)

global DIR_SAVE FILES CUR_FILE START_IM END_IM;

if nargin<3
    str_regions = [];
    str_group_regions = [];
    str_tag = [];
    %     str_group = [];
    %     str_traces = [];
end

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

% Copying MainImage & Atlas
atlas_mask = findobj(myhandles.CenterAxes,'Tag','AtlasMask');

% Copying Trace_Region
l_reg = flipud(findobj(myhandles.RightAxes,'Tag','Trace_Region'));
if val==0 && ~isempty(l_reg)
    % Restricting to selected regions in batch mode
    ind_keep = zeros(length(l_reg),1);
    for i =1:length(l_reg)
        if sum(strcmp(str_regions,l_reg(i).UserData.Name))>0
            ind_keep(i)=1;
        end
    end
    l_reg = l_reg(ind_keep==1);
end

IM_region = [];
mask_regions = [];
label_regions = [];
color_regions = [];
n_regions = length(l_reg);
for i=1:length(l_reg)
    temp=permute(l_reg(i).YData(1:end-1),[1 3 2]);
    IM_region = cat(1,IM_region,temp);
    mask_regions = cat(3,mask_regions,l_reg(i).UserData.Mask);
    color_regions = cat(1,color_regions,l_reg(i).Color);
    label_regions = [label_regions;{l_reg(i).UserData.Name}];
end


% Copying Trace_RegionGroup
l_group = flipud(findobj(myhandles.RightAxes,'Tag','Trace_RegionGroup'));
if val==0 && ~isempty(l_group)
    % Restricting to selected groups in batch mode
    ind_keep = zeros(length(l_group),1);
    for i =1:length(l_group)
        if sum(strcmp(str_group_regions,l_group(i).UserData.Name))>0
            ind_keep(i)=1;
        end
    end
    l_group = l_group(ind_keep==1);
end

IM_group = [];
mask_groups = [];
label_groups = [];
color_groups = [];
n_groups = length(l_group);
for i=1:length(l_group)
    temp=permute(l_group(i).YData(1:end-1),[1 3 2]);
    IM_group = cat(1,IM_group,temp);
    mask_groups = cat(3,mask_groups,l_group(i).UserData.Mask);
    color_groups = cat(1,color_groups,l_group(i).Color);
    label_groups = [label_groups;{l_group(i).UserData.Name}];
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
    'Name',sprintf('Auto Correlation Analysis [%s]',FILES(CUR_FILE).nlab));
set(f2,'Position',[.1 .1 .6 .8]);
clrmenu(f2);

% Storing Time reference
f2.UserData.success = false;
f2.UserData.flag_compute = false;
f2.UserData.nlab = FILES(CUR_FILE).nlab;
f2.UserData.time_ref = data_tr.time_ref;
f2.UserData.x_start = data_tr.time_ref.Y(1);
f2.UserData.x_end = data_tr.time_ref.Y(end);
f2.UserData.t_step = median(diff(data_tr.time_ref.Y));
% f2.UserData.n_burst = data_tr.n_burst;
% f2.UserData.length_burst = data_tr.length_burst;
% f2.UserData.rec_mode = data_tr.rec_mode;

f2.UserData.n_regions = n_regions;
f2.UserData.n_groups = n_groups;

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
L = 5;                      % Height top panels
l = 1;                       % Height info panel
ftsize = 8;                 % Ax fontsize
e1_def = '300';
e1_tip = 'Max Delay (s)';
e2_def = '2';
e2_tip = 'Step Delay (s)';
e3_def = '1200';
e3_tip = 'Dynamic Bin Length (s)';
e4_def = '5';
e4_tip = 'Data smoothing (s)';
e5_def = '5';
e5_tip = 'Correlogramm smoothing (s)';
e6_def = '120';
e6_tip = 'Dynamic Bin Size (s)';

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
    'String','',...sprintf('File: %s',FILES(CUR_FILE).nlab),...
    'BackgroundColor','w',...
    'Tag','Text1');

pu1 = uicontrol('Units','normalized',...
    'Style','popupmenu',...
    'Parent',iP,...
    'ToolTipString','Time Selection',...
    'String',[{data_tt.TimeTags(:).Tag}';{'MANUAL'}],...{data_tt.TimeTags(:).Tag}',...
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

ax_info=axes('Parent',iP,'Tag','Ax_Info','Position',[.225 .55 .75 .4],'FontSize',ftsize);
% Copying Trace_Mean
l_mean = findobj(myhandles.RightAxes,'Tag','Trace_Mean');
l_temp = copyobj(l_mean,ax_info);
l_temp.XData = data_tr.time_ref.Y';
l_temp.YData = l_temp.YData(1:end-1);
l_temp.Visible = 'on';

% Info Panel Position
ipos = [0 0 1 1];
t1.Position =       [0     0    3.9*ipos(3)/20   3.2*ipos(4)/4];
pu1.Position=     [0     4.75*ipos(4)/6    ipos(3)/6   ipos(4)/6];
e_start.Position =  [5*ipos(3)/10     2.75*ipos(4)/10   ipos(3)/12   3.5*ipos(4)/20];
e_end.Position = [5*ipos(3)/10     ipos(4)/20           ipos(3)/12   3.5*ipos(4)/20];
e1.Position = [6*ipos(3)/10      2.75*ipos(4)/10           ipos(3)/20   3.5*ipos(4)/20];
e2.Position = [6.5*ipos(3)/10      2.75*ipos(4)/10           ipos(3)/20   3.5*ipos(4)/20];
e3.Position = [7*ipos(3)/10      2.75*ipos(4)/10           ipos(3)/20   3.5*ipos(4)/20];
e4.Position = [6*ipos(3)/10     ipos(4)/20           ipos(3)/20   3.5*ipos(4)/20];
e5.Position = [6.5*ipos(3)/10     ipos(4)/20           ipos(3)/20   3.5*ipos(4)/20];
e6.Position = [7*ipos(3)/10     ipos(4)/20           ipos(3)/20   3.5*ipos(4)/20];

br.Position = [7.6*ipos(3)/10     ipos(4)/4     .8*ipos(3)/10   4.5*ipos(4)/20];
bc.Position = [8.4*ipos(3)/10     ipos(4)/4     .8*ipos(3)/10   4.5*ipos(4)/20];
ba.Position = [9.2*ipos(3)/10     ipos(4)/4     .8*ipos(3)/10   4.5*ipos(4)/20];
bss.Position = [7.6*ipos(3)/10     0      .8*ipos(3)/10    4.5*ipos(4)/20];
bsi.Position = [8.4*ipos(3)/10     0      .8*ipos(3)/10    4.5*ipos(4)/20];
bbs.Position = [9.2*ipos(3)/10     0      .8*ipos(3)/10    4.5*ipos(4)/20];

mb.Position =   [4*ipos(3)/20 2.75*ipos(4)/10    ipos(3)/15 3.5*ipos(4)/20];
pb.Position =   [4*ipos(3)/20 ipos(4)/20        ipos(3)/15 3.5*ipos(4)/20];
rb.Position =   [5.5*ipos(3)/20 2.75*ipos(4)/10    ipos(3)/15 3.5*ipos(4)/20];
bb.Position =   [5.5*ipos(3)/20 ipos(4)/20        ipos(3)/15 3.5*ipos(4)/20];
skb.Position =  [7*ipos(3)/20 2.75*ipos(4)/10    ipos(3)/15 3.5*ipos(4)/20];
tb.Position =   [7*ipos(3)/20 ipos(4)/20        ipos(3)/15 3.5*ipos(4)/20];
ptb.Position =  [8.5*ipos(3)/20 2.75*ipos(4)/10    ipos(3)/15 3.5*ipos(4)/20];
ntb.Position =  [8.5*ipos(3)/20 ipos(4)/20        ipos(3)/15 3.5*ipos(4)/20];

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
    'Tag','FirstTab');
tab2 = uitab('Parent',tabgp,...
    'Title','Regions & Groups',...
    'Tag','SecondTab');
tab3 = uitab('Parent',tabgp,...
    'Title','Region Dynamics',...
    'Tag','ThirdTab');
tab4 = uitab('Parent',tabgp,...
    'Title','Group Dynamics',...
    'Tag','FourthTab');

f2.UserData.atlas_mask = atlas_mask;
f2.UserData.IM_region = IM_region;
f2.UserData.mask_regions = mask_regions;
f2.UserData.label_regions = label_regions;
f2.UserData.color_regions = color_regions;
f2.UserData.IM_group = IM_group;
f2.UserData.mask_groups = mask_groups;
f2.UserData.label_groups = label_groups;
f2.UserData.color_groups = color_groups;


handles2 = guihandles(f2) ;
% if ~isempty(handles2.TagButton.UserData)&&length(handles2.TagButton.UserData.Selected)>1
%     handles2.TagButton.UserData=[];
% end

handles2 = reset_Callback([],[],handles2,myhandles);
edit_Callback([handles2.EditStart handles2.EditEnd],[],handles2.CenterAxes);
buttonAutoScale_Callback([],[],handles2);
colormap(f2,'jet');

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
% str_tag contains group names
if val==0
    batchsave_Callback([],[],handles2,str_tag,0);
end

end

function handles = reset_Callback(~,~,handles,old_handles)

handles = guihandles(handles.MainFigure);
handles.CenterAxes = handles.Ax_Info;
tab1 = handles.FirstTab;
tab2 = handles.SecondTab;
tab3 = handles.ThirdTab;
tab4 = handles.FourthTab;
ftsize = 8;
handles.MainFigure.UserData.flag_compute = false;
n_regions = handles.MainFigure.UserData.n_regions;
n_groups = handles.MainFigure.UserData.n_groups;

% Callback function Attribution
pu1 = handles.Popup1;
pu1.Callback = {@update_popup_Callback,handles};

set(handles.ButtonReset,'Callback',{@reset_Callback,handles,old_handles});
set(handles.ButtonCompute,'Callback',{@compute_autocorr_Callback,handles,1});
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
ax_info = findobj(handles.MainFigure,'Tag','Ax_Info');
set(ax_info,'ButtonDownFcn',{@template_axes_clickFcn,0,[],edits});
set(handles.EditStart,'Callback',{@edit_Callback,ax_info});
set(handles.EditEnd,'Callback',{@edit_Callback,ax_info});


% Display Axes Tab 1
all_display_axes1 = findobj(tab1,'Tag','Ax1aa','-or','Tag','Ax1ab','-or','Tag','Ax1ac','-or','Tag','Ax1ad',...
    '-or','Tag','Ax1ba','-or','Tag','Ax1bb','-or','Tag','Ax1bc','-or','Tag','Ax1bd',...
    '-or','Tag','Ax1ca','-or','Tag','Ax1cb','-or','Tag','Ax1cc','-or','Tag','Ax1cd');
delete(all_display_axes1);

ax1aa=axes('Parent',tab1,'Tag','Ax1aa','Position',[.025 .7 .2 .25],'FontSize',ftsize);
ax1ab=axes('Parent',tab1,'Tag','Ax1ab','Position',[.275 .7 .2 .25],'FontSize',ftsize);
ax1ab.YLim=[-.5 1];
ax1ac=axes('Parent',tab1,'Tag','Ax1ac','Position',[.525 .7 .2 .25],'FontSize',ftsize);
ax1ad=axes('Parent',tab1,'Tag','Ax1ad','Position',[.775 .7 .2 .25],'FontSize',ftsize);

ax1ba=axes('Parent',tab1,'Tag','Ax1ba','Position',[.025 .37 .2 .25],'FontSize',ftsize);
ax1bb=axes('Parent',tab1,'Tag','Ax1bb','Position',[.275 .37 .2 .25],'FontSize',ftsize);
ax1bb.YLim=[-.5 1];
ax1bc=axes('Parent',tab1,'Tag','Ax1bc','Position',[.525 .37 .2 .25],'FontSize',ftsize);
ax1bd=axes('Parent',tab1,'Tag','Ax1bd','Position',[.775 .37 .2 .25],'FontSize',ftsize);

ax1ca=axes('Parent',tab1,'Tag','Ax1ca','Position',[.025 .04 .2 .25],'FontSize',ftsize);
ax1cb=axes('Parent',tab1,'Tag','Ax1cb','Position',[.275 .04 .2 .25],'FontSize',ftsize);
ax1cb.YLim=[-.5 1];
ax1cc=axes('Parent',tab1,'Tag','Ax1cc','Position',[.525 .04 .2 .25],'FontSize',ftsize);
ax1cd=axes('Parent',tab1,'Tag','Ax1cd','Position',[.775 .04 .2 .25],'FontSize',ftsize);

% Display Axes Tab 2
all_display_axes2 = findobj(tab2,'Tag','Ax2aa','-or','Tag','Ax2ab',...
    '-or','Tag','Ax2ba','-or','Tag','Ax2bb');
delete(all_display_axes2);

ax2aa=axes('Parent',tab2,'Tag','Ax2aa','Position',[.05 .55 .4 .4],'FontSize',ftsize);
ax2ab=axes('Parent',tab2,'Tag','Ax2ab','Position',[.55 .55 .4 .4],'FontSize',ftsize);
ax2ab.YLim=[-.5 1];

ax2ba=axes('Parent',tab2,'Tag','Ax2ba','Position',[.05 .05 .4 .4],'FontSize',ftsize);
ax2bb=axes('Parent',tab2,'Tag','Ax2bb','Position',[.55 .05 .4 .4],'FontSize',ftsize);
ax2bb.YLim=[-.5 1];

% Display Axes Tab 3
all_display_axes3 = findobj(tab3,'Type','Axes');
delete(all_display_axes3);

eps = .003;
for i=1:n_regions
    ax2aa=axes('Parent',tab3,'Tag',sprintf('Ax%da',i),'Position',[(i-1)/n_regions+eps .525 1/n_regions-2*eps .45],'FontSize',ftsize);
    ax2ab=axes('Parent',tab3,'Tag',sprintf('Ax%db',i),'Position',[(i-1)/n_regions+eps .025 1/n_regions-2*eps .45],'FontSize',ftsize);
end

% Display Axes Tab 4
all_display_axes4 = findobj(tab4,'Type','Axes');
delete(all_display_axes4);

eps = .003;
for i=1:n_groups
    ax2aa=axes('Parent',tab4,'Tag',sprintf('Ax%da',i),'Position',[(i-1)/n_groups+eps .525 1/n_groups-2*eps .45],'FontSize',ftsize);
    ax2ab=axes('Parent',tab4,'Tag',sprintf('Ax%db',i),'Position',[(i-1)/n_groups+eps .025 1/n_groups-2*eps .45],'FontSize',ftsize);
end



% Execute popup Callback
pu1.UserData.cur_tag = [];
pu1.UserData.im_start = [];
pu1.UserData.im_end = [];
pu1.UserData.t_start = [];
pu1.UserData.t_end = [];

% template_buttonRescale_Callback(handles.RescaleButton,[],handles.CenterAxes,edits);
if ~isempty(handles.TagButton.UserData)&&length(handles.TagButton.UserData.Selected)==1
    %     pu1.Value=handles.TagButton.UserData.Selected;
    pu1.Value = find(strcmp(pu1.String,handles.TagButton.UserData.Name)==1);
end
update_popup_Callback(pu1,[],handles);

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

ax_info = findobj(handles.MainFigure,'Tag','Ax_Info');
face_color = [.5 .5 .5];
face_alpha = .5;

cur_tag = strtrim(char(hObj.String(hObj.Value,:)));
% folder_name = handles.MainFigure.UserData.folder_name;
time_ref = handles.MainFigure.UserData.time_ref;
TimeTags = handles.MainFigure.UserData.TimeTags;
TimeTags_images = handles.MainFigure.UserData.TimeTags_images;
TimeTags_strings = handles.MainFigure.UserData.TimeTags_strings;
% tts1 = datenum(tt_data.TimeTags_strings(:,1));
% tts2 = datenum(tt_data.TimeTags_strings(:,2));
% TimeTags_seconds = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;
ind_tag = find(strcmp({TimeTags(:).Tag}',cur_tag)==1);

if isempty(ind_tag)
    t_start =  ax_info.XLim(1);
    t_end =  ax_info.XLim(2);
    [~,im_start] = min((time_ref.Y-t_start).^2);
    [~,im_end] = min((time_ref.Y-t_end).^2);

else
    im_start = TimeTags_images(ind_tag,1);
    im_end = TimeTags_images(ind_tag,2);

    temp = datenum(TimeTags_strings(ind_tag,1));
    t_start = (temp-floor(temp))*24*3600+.1;
    temp = datenum(TimeTags_strings(ind_tag,2));
    t_end = (temp-floor(temp))*24*3600-.1;
end

% Displaying patch
delete(findobj(ax_info,'Tag','TagPatch'));
patch('XData',[t_start t_end t_end t_start],...
    'YData',[ax_info.YLim(1) ax_info.YLim(1) ax_info.YLim(2) ax_info.YLim(2)],...
    'FaceColor',face_color,'FaceAlpha',face_alpha,'EdgeColor','none',...
    'Parent',ax_info,'Tag','TagPatch','HitTest','off');


% Storing
hObj.UserData.cur_tag = cur_tag;
hObj.UserData.im_start = im_start;
hObj.UserData.im_end = im_end;
hObj.UserData.t_start = t_start;
hObj.UserData.t_end = t_end;
hObj.UserData.tts_start = datestr(t_start/(24*3600),'HH:MM:SS.FFF');
hObj.UserData.tts_end = datestr(t_end/(24*3600),'HH:MM:SS.FFF');

end

function compute_autocorr_Callback(~,~,handles,val,flags)

if nargin <5
    flag_pixels = false;
    flag_regions = true;
    flag_groups = true;
    flag_dynamics = true;
    flag_dynamics_groups = true;
else
    flag_pixels = flags(1);
    flag_regions = flags(2);
    flag_groups = flags(3);
    flag_dynamics = flags(4);
    flag_dynamics_groups = flags(5);
end

handles.MainFigure.Pointer = 'watch';
handles.MainFigure.UserData.success = false;
drawnow;

% g_colors = handles.MainFigure.UserData.g_colors;
cur_file = handles.MainFigure.UserData.nlab;
t_step = handles.MainFigure.UserData.t_step;
time_ref = handles.MainFigure.UserData.time_ref;
% TimeTags = handles.MainFigure.UserData.TimeTags;
% TimeTags_strings = handles.MainFigure.UserData.TimeTags_strings;
% rec_mode = handles.MainFigure.UserData.rec_mode;

max_delay = str2double(handles.Edit1.String);
step_delay = str2double(handles.Edit2.String);
t_gauss_data = str2double(handles.Edit4.String);
t_gauss_corr = str2double(handles.Edit5.String);
bin_length = str2double(handles.Edit3.String);
bin_size = str2double(handles.Edit6.String);
% marker_type = {'o','*','diamond','.'};
% markersize = str2double(handles.Edit3.String);
ftsize = 8;

% Retrieving timing
cur_tag = handles.Popup1.UserData.cur_tag;
im_start = handles.Popup1.UserData.im_start;
im_end = handles.Popup1.UserData.im_end;
t_start = handles.Popup1.UserData.t_start;
t_end = handles.Popup1.UserData.t_end;
tts_start = handles.Popup1.UserData.tts_start;
tts_end = handles.Popup1.UserData.tts_end;

% Retrieving regions and region groups
label_regions = handles.MainFigure.UserData.label_regions;
% mask_regions = handles.MainFigure.UserData.mask_regions;
color_regions = handles.MainFigure.UserData.color_regions;
IM_region = handles.MainFigure.UserData.IM_region;
label_groups = handles.MainFigure.UserData.label_groups;
% mask_groups = handles.MainFigure.UserData.mask_groups;
IM_group = handles.MainFigure.UserData.IM_group;
color_groups = handles.MainFigure.UserData.color_groups;


% Sanity Check Time Tag Duration
if (t_end-t_start) < (2*max_delay)
    if val ~=0
        errordlg(sprintf('Current Time Tag must be 2 times longer than max delay.\n[Time Tag Duration %.1f, Max Delay %.1f]',t_end-t_start,max_delay));
    else
        warning('Current Time Tag must be 2 times longer than max delay.\n[Time Tag Duration %.1f, Max Delay %.1f]',t_end-t_start,max_delay);
    end
    handles.MainFigure.Pointer = 'arrow';
    return;
end

handles.Text1.String = sprintf('Recording:%s\nTag:%s\n[Start:%.2f s - End:%.2f s]\n[%s - %s]',cur_file,cur_tag,t_start,t_end,tts_start,tts_end);


% Parameters auto-correlation
Params.cur_file = cur_file;
Params.t_step = t_step;
Params.max_delay = max_delay;
Params.step_delay = step_delay;
Params.t_gauss_data = t_gauss_data;
Params.t_gauss_corr = t_gauss_corr;
Params.str='1x1';

lags = [];
IM_all_r=[];
IM_all_pks=[];
IM_all_locs=[];
IM_all_r_2x2=[];
IM_all_pks_2x2=[];
IM_all_locs_2x2=[];
IM_all_r_3x3=[];
IM_all_pks_3x3=[];
IM_all_locs_3x3=[];
all_r_regions =[];
all_pks_regions =[];
all_locs_regions =[];
all_r_groups =[];
all_pks_groups =[];
all_locs_groups =[];

IM_all_r_dynamic = [];
IM_all_pks_dynamic = [];
IM_all_locs_dynamic = [];
IM_all_r_dynamic_groups = [];
IM_all_pks_dynamic_groups = [];
IM_all_locs_dynamic_groups = [];

if flag_pixels
    % Compute auto-correlations
    % No subsampling
    global IM;
    IM_restricted = IM(:,:,im_start:im_end);
    [all_r,all_pks,all_locs,lags] = main_autocorr(IM_restricted,Params);
    IM_all_r = reshape(all_r,[size(IM_restricted,1),size(IM_restricted,2),size(all_r,2)]);
    for k=1:4
        IM_all_pks(:,:,k) = reshape(all_pks(:,k),[size(IM_restricted,1),size(IM_restricted,2)]);
        IM_all_locs(:,:,k) = reshape(all_locs(:,k),[size(IM_restricted,1),size(IM_restricted,2)]);
    end

    % Display results
    ax1aa = findobj(handles.FirstTab,'Tag','Ax1aa');
    cla(ax1aa);
    imagesc('XData',lags,'CData',all_r,'Parent',ax1aa);
    hold(ax1aa,'on');
    %     line('XData',all_locs(:,2),'YData',1:length(all_locs(:,2)),'Parent',ax1aa,'Tag','MaxPeak',...
    %         'LineStyle','none','Color','k','Linewidth',1,...
    %         'MarkerSize',1,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
    line('XData',all_locs(:,1),'YData',1:length(all_locs(:,1)),'Parent',ax1aa,'Tag','FirstPeak',...
        'LineStyle','none','Color','k','Linewidth',1,...
        'MarkerSize',1,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
    ax1aa.XLim =[lags(1) lags(end)];
    ax1aa.YLim =[.5 size(all_r,1)+.5];
    ax1aa.Title.String = sprintf('Auto-Correlation 1 [%s]',Params.str);
    ax1aa.CLim = [-.5 1];
    colorbar(ax1aa);
    ax1aa.Tag = 'Ax1aa';

    ax1ab = findobj(handles.FirstTab,'Tag','Ax1ab');
    cla(ax1ab);
    hold(ax1ab,'on');
    % for i=1:size(all_r,1)
    %     line('XData',lags,'YData',all_r(i,:),'Parent',ax1ab,'Tag','Line_R',...
    %         'LineStyle','-','Color',[.5 .5 .5],'Linewidth',.1);
    % end
    line('XData',lags,'YData',mean(all_r,1,'omitnan'),'Parent',ax1ab,'Tag','Mean_R',...
        'LineStyle','-','Color','r','Linewidth',1);
    line('XData',lags,'YData',mean(all_r,1,'omitnan')+sem(all_r,1,'omitnan'),'Parent',ax1ab,'Tag','Mean_R',...
        'LineStyle','-','Color',[.5 .5 .5],'Linewidth',.5);
    line('XData',lags,'YData',mean(all_r,1,'omitnan')-sem(all_r,1,'omitnan'),'Parent',ax1ab,'Tag','Mean_R',...
        'LineStyle','-','Color',[.5 .5 .5],'Linewidth',.5);
    hold(ax1ab,'off');
    ax1ab.XLim =[lags(1) lags(end)];
    ax1ab.YLim =[-.5 1];
    ax1ab.Title.String = sprintf('Auto-Correlation 2 [%s]',Params.str);
    ax1ab.Tag = 'Ax1ab';

    ax1ac = findobj(handles.FirstTab,'Tag','Ax1ac');
    cla(ax1ac);
    imagesc(IM_all_locs(:,:,2),'Parent',ax1ac);
    ax1ac.XLim =[.5 size(IM_restricted,2)+.5];
    ax1ac.YLim =[.5 size(IM_restricted,1)+.5];
    ax1ac.Title.String = sprintf('Max Peak Time [%s]',Params.str);
    colorbar(ax1ac);
    ax1ac.FontSize = ftsize;
    ax1ac.Tag = 'Ax1ac';

    ax1ad = findobj(handles.FirstTab,'Tag','Ax1ad');
    cla(ax1ad);
    imagesc(IM_all_locs(:,:,1),'Parent',ax1ad);
    ax1ad.XLim =[.5 size(IM_restricted,2)+.5];
    ax1ad.YLim =[.5 size(IM_restricted,1)+.5];
    ax1ad.Title.String = sprintf('First Peak Time [%s]',Params.str);
    colorbar(ax1ad);
    ax1ad.FontSize = ftsize;
    ax1ad.Tag = 'Ax1ad';


    % Compute auto-correlations
    % Subsampling 2x2
    Params.str='2x2';
    temp = convn(IM_restricted,ones(2,2,1),'same');
    IM_restricted_2x2 = temp(1:2:end,1:2:end,:);
    [all_r_2x2,all_pks_2x2,all_locs_2x2,lags] = main_autocorr(IM_restricted_2x2,Params);
    IM_all_r_2x2 = reshape(all_r_2x2,[size(IM_restricted_2x2,1),size(IM_restricted_2x2,2),size(all_r_2x2,2)]);
    for k=1:4
        IM_all_pks_2x2(:,:,k) = reshape(all_pks_2x2(:,k),[size(IM_restricted_2x2,1),size(IM_restricted_2x2,2)]);
        IM_all_locs_2x2(:,:,k) = reshape(all_locs_2x2(:,k),[size(IM_restricted_2x2,1),size(IM_restricted_2x2,2)]);
    end

    % Display results
    ax1ba = findobj(handles.FirstTab,'Tag','Ax1ba');
    cla(ax1ba);
    imagesc('XData',lags,'CData',all_r_2x2,'Parent',ax1ba);
    hold(ax1ba,'on');
    %     line('XData',all_locs_2x2(:,2),'YData',1:length(all_locs_2x2(:,2)),'Parent',ax1ba,'Tag','MaxPeak',...
    %         'LineStyle','none','Color','k','Linewidth',1,...
    %         'MarkerSize',1,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5])
    line('XData',all_locs_2x2(:,1),'YData',1:length(all_locs_2x2(:,1)),'Parent',ax1ba,'Tag','FirstPeak',...
        'LineStyle','none','Color','k','Linewidth',1,...
        'MarkerSize',1,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
    ax1ba.XLim =[lags(1) lags(end)];
    ax1ba.YLim =[.5 size(all_r_2x2,1)+.5];
    ax1ba.Title.String = sprintf('Auto-Correlation 1 [%s]',Params.str);
    ax1ba.CLim = [-.5 1];
    colorbar(ax1ba);
    ax1ba.Tag = 'Ax1ba';

    ax1bb = findobj(handles.FirstTab,'Tag','Ax1bb');
    cla(ax1bb);
    hold(ax1bb,'on');
    %     for i=1:size(all_r_2x2,1)
    %         line('XData',lags,'YData',all_r_2x2(i,:),'Parent',ax1bb,'Tag','Line_R',...
    %             'LineStyle','-','Color',[.5 .5 .5],'Linewidth',.1);
    %     end
    line('XData',lags,'YData',mean(all_r_2x2,1,'omitnan'),'Parent',ax1bb,'Tag','Mean_R',...
        'LineStyle','-','Color','r','Linewidth',1);
    line('XData',lags,'YData',mean(all_r_2x2,1,'omitnan')+sem(all_r_2x2,1,'omitnan'),'Parent',ax1bb,'Tag','Mean_R',...
        'LineStyle','-','Color',[.5 .5 .5],'Linewidth',.5);
    line('XData',lags,'YData',mean(all_r_2x2,1,'omitnan')-sem(all_r_2x2,1,'omitnan'),'Parent',ax1bb,'Tag','Mean_R',...
        'LineStyle','-','Color',[.5 .5 .5],'Linewidth',.5);

    hold(ax1bb,'off');
    ax1bb.XLim =[lags(1) lags(end)];
    ax1bb.YLim =[-.5 1];
    ax1bb.Title.String = sprintf('Auto-Correlation 2 [%s]',Params.str);
    ax1bb.Tag = 'Ax1bb';

    ax1bc = findobj(handles.FirstTab,'Tag','Ax1bc');
    cla(ax1bc);
    imagesc(IM_all_locs_2x2(:,:,1),'Parent',ax1bc);
    ax1bc.XLim =[.5 size(IM_restricted_2x2,2)+.5];
    ax1bc.YLim =[.5 size(IM_restricted_2x2,1)+.5];
    ax1bc.Title.String = sprintf('Max Peak Time [%s]',Params.str);
    colorbar(ax1bc);
    ax1bc.FontSize = ftsize;
    ax1bc.Tag = 'Ax1bc';

    ax1bd = findobj(handles.FirstTab,'Tag','Ax1bd');
    cla(ax1bd);
    imagesc(IM_all_locs_2x2(:,:,1),'Parent',ax1bd);
    ax1bd.XLim =[.5 size(IM_restricted_2x2,2)+.5];
    ax1bd.YLim =[.5 size(IM_restricted_2x2,1)+.5];
    ax1bd.Title.String = sprintf('First Peak Time [%s]',Params.str);
    colorbar(ax1bd);
    ax1bd.FontSize = ftsize;
    ax1bd.Tag = 'Ax1bd';


    % Compute auto-correlations
    % Subsampling 3x3
    Params.str='3x3';
    temp = convn(IM_restricted,ones(3,3,1),'same');
    IM_restricted_3x3 = temp(1:3:end,1:3:end,:);
    [all_r_3x3,all_pks_3x3,all_locs_3x3,lags] = main_autocorr(IM_restricted_3x3,Params);
    IM_all_r_3x3 = reshape(all_r_3x3,[size(IM_restricted_3x3,1),size(IM_restricted_3x3,2),size(all_r_3x3,2)]);
    for k=1:4
        IM_all_pks_3x3(:,:,k) = reshape(all_pks_3x3(:,k),[size(IM_restricted_3x3,1),size(IM_restricted_3x3,2)]);
        IM_all_locs_3x3(:,:,k) = reshape(all_locs_3x3(:,k),[size(IM_restricted_3x3,1),size(IM_restricted_3x3,2)]);
    end

    % Display results
    ax1ca = findobj(handles.FirstTab,'Tag','Ax1ca');
    cla(ax1ca);
    imagesc('XData',lags,'CData',all_r_3x3,'Parent',ax1ca);
    hold(ax1ca,'on');
    %     line('XData',all_locs_3x3(:,1),'YData',1:length(all_locs_3x3(:,2)),'Parent',ax1ca,'Tag','MaxPeak',...
    %         'LineStyle','none','Color','k','Linewidth',1,...
    %         'MarkerSize',1,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
    line('XData',all_locs_3x3(:,1),'YData',1:length(all_locs_3x3(:,1)),'Parent',ax1ca,'Tag','FirstPeak',...
        'LineStyle','none','Color','k','Linewidth',1,...
        'MarkerSize',1,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
    ax1ca.XLim =[lags(1) lags(end)];
    ax1ca.YLim =[.5 size(all_r_3x3,1)+.5];
    ax1ca.Title.String = sprintf('Auto-Correlation 1 [%s]',Params.str);
    ax1ca.CLim = [-.5 1];
    colorbar(ax1ca);
    ax1ca.Tag = 'Ax1ca';

    ax1cb = findobj(handles.FirstTab,'Tag','Ax1cb');
    cla(ax1cb);
    hold(ax1cb,'on');
    %     for i=1:size(all_r_3x3,1)
    %         line('XData',lags,'YData',all_r_3x3(i,:),'Parent',ax1cb,'Tag','Line_R',...
    %             'LineStyle','-','Color',[.5 .5 .5],'Linewidth',.1);
    %     end
    line('XData',lags,'YData',mean(all_r_3x3,1,'omitnan'),'Parent',ax1cb,'Tag','Mean_R',...
        'LineStyle','-','Color','r','Linewidth',1);
    line('XData',lags,'YData',mean(all_r_3x3,1,'omitnan')+sem(all_r_3x3,1,'omitnan'),'Parent',ax1cb,'Tag','Mean_R',...
        'LineStyle','-','Color',[.5 .5 .5],'Linewidth',.5);
    line('XData',lags,'YData',mean(all_r_3x3,1,'omitnan')+sem(all_r_3x3,1,'omitnan'),'Parent',ax1cb,'Tag','Mean_R',...
        'LineStyle','-','Color',[.5 .5 .5],'Linewidth',.5);
    hold(ax1cb,'off');
    ax1cb.XLim =[lags(1) lags(end)];
    ax1cb.YLim =[-.5 1];
    ax1cb.Title.String = sprintf('Auto-Correlation 2 [%s]',Params.str);
    ax1cb.Tag = 'Ax1cb';

    ax1cc = findobj(handles.FirstTab,'Tag','Ax1cc');
    cla(ax1cc);
    imagesc(IM_all_locs_3x3(:,:,1),'Parent',ax1cc);
    ax1cc.XLim =[.5 size(IM_restricted_3x3,2)+.5];
    ax1cc.YLim =[.5 size(IM_restricted_3x3,1)+.5];
    ax1cc.Title.String = sprintf('Max Peak Time [%s]',Params.str);
    colorbar(ax1cc);
    ax1cc.FontSize = ftsize;
    ax1cc.Tag = 'Ax1cc';

    ax1cd = findobj(handles.FirstTab,'Tag','Ax1cd');
    cla(ax1cd);
    imagesc(IM_all_locs_3x3(:,:,1),'Parent',ax1cd);
    ax1cd.XLim =[.5 size(IM_restricted_3x3,2)+.5];
    ax1cd.YLim =[.5 size(IM_restricted_3x3,1)+.5];
    ax1cd.Title.String = sprintf('First Peak Time [%s]',Params.str);
    colorbar(ax1cd);
    ax1cd.FontSize = ftsize;
    ax1cd.Tag = 'Ax1cd';
end

if flag_regions && ~isempty(IM_region)
    % Compute auto-correlations
    % Regions
    Params.str='Regions';
    IM_restricted = IM_region(:,:,im_start:im_end);
    [all_r_regions,all_pks_regions,all_locs_regions,lags] = main_autocorr(IM_restricted,Params);

    % Display results
    ax2aa = findobj(handles.SecondTab,'Tag','Ax2aa');
    cla(ax2aa);
    imagesc('XData',lags,'CData',all_r_regions,'Parent',ax2aa);
    hold(ax2aa,'on');
    line('XData',all_locs_regions(:,1),'YData',1:length(all_locs_regions(:,1)),'Parent',ax2aa,'Tag','FirstPeak',...
        'LineStyle','none','Color','k','Linewidth',1,...
        'MarkerSize',3,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
    line('XData',all_locs_regions(:,3),'YData',1:length(all_locs_regions(:,3)),'Parent',ax2aa,'Tag','SecondPeak',...
        'LineStyle','none','Color','k','Linewidth',1,...
        'MarkerSize',3,'Marker','o','MarkerFaceColor','none','MarkerEdgeColor',[.5 .5 .5]);
    ax2aa.XLim =[lags(1) lags(end)];
    ax2aa.YLim =[.5 size(all_r_regions,1)+.5];
    ax2aa.YTick = 1:size(all_r_regions,1);
    ax2aa.YTickLabel = label_regions;
    ax2aa.Title.String = 'Auto-Correlation Regions';
    ax2aa.CLim = [-.5 1];
    colorbar(ax2aa);
    ax2aa.Tag = 'Ax2aa';

    ax2ab = findobj(handles.SecondTab,'Tag','Ax2ab');
    cla(ax2ab);
    hold(ax2ab,'on');
    all_lines = [];
    for i=1:size(all_r_regions,1)
        l=line('XData',lags,'YData',all_r_regions(i,:),'Parent',ax2ab,'Tag','Line_R',...
            'LineStyle','-','Color',color_regions(i,:),'Linewidth',.5);
        all_lines = [all_lines;l];
        % First Peak
        line('XData',all_locs_regions(i,1),'YData',all_pks_regions(i,1),'Parent',ax2ab,'Tag','FirstPeak',...
            'LineStyle','none','Color','k','Linewidth',1,...
            'MarkerSize',5,'Marker','o','MarkerFaceColor',color_regions(i,:),'MarkerEdgeColor',color_regions(i,:));
        % Second Peak
        line('XData',all_locs_regions(i,3),'YData',all_pks_regions(i,3),'Parent',ax2ab,'Tag','SecondPeak',...
            'LineStyle','none','Color','k','Linewidth',1,...
            'MarkerSize',5,'Marker','o','MarkerFaceColor','none','MarkerEdgeColor',color_regions(i,:));
    end
    %     line('XData',lags,'YData',mean(all_r_regions,1,'omitnan'),'Parent',ax2ab,'Tag','Mean_R',...
    %         'LineStyle','-','Color','r','Linewidth',1);
    %     legend(ax2ab,label_regions);
    legend(ax2ab,all_lines,label_regions);
    hold(ax2ab,'off');
    ax2ab.XLim =[lags(1) lags(end)];
    ax2ab.YLim =[-.5 1];
    ax2ab.Title.String = 'Auto-Correlation Regions';
    ax2ab.Tag = 'Ax2ab';

end

if flag_groups && ~isempty(IM_group)
    % Compute auto-correlations
    % Region Groups
    Params.str='Region Groups';
    IM_restricted = IM_group(:,:,im_start:im_end);
    [all_r_groups,all_pks_groups,all_locs_groups,lags] = main_autocorr(IM_restricted,Params);

    % Display results
    ax2ba = findobj(handles.SecondTab,'Tag','Ax2ba');
    cla(ax2ba);
    imagesc('XData',lags,'CData',all_r_groups,'Parent',ax2ba);
    hold(ax2ba,'on');
    line('XData',all_locs_groups(:,1),'YData',1:length(all_locs_groups(:,1)),'Parent',ax2ba,'Tag','FirstPeak',...
        'LineStyle','none','Color','k','Linewidth',1,...
        'MarkerSize',3,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
    line('XData',all_locs_groups(:,3),'YData',1:length(all_locs_groups(:,3)),'Parent',ax2ba,'Tag','SecondPeak',...
        'LineStyle','none','Color','k','Linewidth',1,...
        'MarkerSize',3,'Marker','o','MarkerFaceColor','none','MarkerEdgeColor',[.5 .5 .5]);
    ax2ba.XLim =[lags(1) lags(end)];
    ax2ba.YLim =[.5 size(all_r_groups,1)+.5];
    ax2ba.YTick = 1:size(all_r_groups,1);
    ax2ba.YTickLabel = label_groups;
    ax2ba.Title.String = 'Auto-Correlation Region Groups';
    ax2ba.CLim = [-.5 1];
    colorbar(ax2ba);
    ax2ba.Tag = 'Ax2ba';

    ax2bb = findobj(handles.SecondTab,'Tag','Ax2bb');
    cla(ax2bb);
    hold(ax2bb,'on');
    all_lines = [];
    for i=1:size(all_r_groups,1)
        l = line('XData',lags,'YData',all_r_groups(i,:),'Parent',ax2bb,'Tag','Line_R',...
            'LineStyle','-','Color',color_groups(i,:),'Linewidth',.5);
        all_lines = [all_lines;l];
        % Peak Max
        line('XData',all_locs_groups(i,1),'YData',all_pks_groups(i,1),'Parent',ax2bb,'Tag','FirstPeak',...
            'LineStyle','none','Color','k','Linewidth',1,...
            'MarkerSize',5,'Marker','o','MarkerFaceColor',color_groups(i,:),'MarkerEdgeColor',color_groups(i,:));
        % Peak Min
        line('XData',all_locs_groups(i,3),'YData',all_pks_groups(i,3),'Parent',ax2bb,'Tag','SecondPeak',...
            'LineStyle','none','Color','k','Linewidth',1,...
            'MarkerSize',5,'Marker','o','MarkerFaceColor','none','MarkerEdgeColor',color_groups(i,:));
    end
    %     line('XData',lags,'YData',mean(all_r_groups,1,'omitnan'),'Parent',ax2bb,'Tag','Mean_R',...
    %         'LineStyle','-','Color','r','Linewidth',1);
    legend(ax2bb,label_groups);
    legend(ax2bb,all_lines,label_groups);
    hold(ax2bb,'off');
    ax2bb.XLim =[lags(1) lags(end)];
    ax2bb.YLim =[-.5 1];
    ax2bb.Title.String = 'Auto-Correlation Region Groups';
    ax2bb.Tag = 'Ax2bb';

end

if flag_dynamics && ~isempty(IM_region)

    % Compute auto-correlations dynamics
    % Regions
    Params.str = 'Region Dynamics';
    IM_dynamic=[];
    im_start = 1:bin_size:size(IM_region,3)-bin_length+1;
    im_end = im_start+bin_length-1;
    im_mid = (im_start+im_end)/2;
    %     label_mid = datestr(time_ref.Y(round(im_mid(1:10:end)))/(24*3600),'HH:MM:SS.FFF');
    label_mid = datestr(time_ref.Y(round(im_mid(1:10:end)))/(24*3600),'HH:MM:SS');

    for j=1:length(im_start)
        IM_dynamic=cat(2,IM_dynamic,IM_region(:,:,im_start(j):im_end(j)));
    end
    [all_r_dynamic,all_pks_dynamic,all_locs_dynamic,lags] = main_autocorr(IM_dynamic,Params);
    IM_all_r_dynamic = reshape(all_r_dynamic,[size(IM_dynamic,1),size(IM_dynamic,2),size(all_r_dynamic,2)]);
    IM_all_pks_dynamic=[];
    for k=1:4
        IM_all_pks_dynamic(:,:,k) = reshape(all_pks_dynamic(:,k),[size(IM_dynamic,1),size(IM_dynamic,2)]);
    end
    IM_all_locs_dynamic = [];
    for k=1:4
        IM_all_locs_dynamic(:,:,k) = reshape(all_locs_dynamic(:,k),[size(IM_dynamic,1),size(IM_dynamic,2)]);
    end

    for i = 1:length(label_regions)
        all_r_dynamic=squeeze(IM_all_r_dynamic(i,:,:));
        all_locs_dynamic=squeeze(IM_all_locs_dynamic(i,:,1));
        all_pks_dynamic=squeeze(IM_all_pks_dynamic(i,:,1));
        all_locs_dynamic_min=squeeze(IM_all_locs_dynamic(i,:,3));
        all_pks_dynamic_min=squeeze(IM_all_pks_dynamic(i,:,3));

        % Building colors
        color1=[255, 255, 150]/255;
        color2=[108, 108, 43]/255;
        colors_p = [linspace(color1(1),color2(1),size(all_r_dynamic,1))',...
            linspace(color1(2),color2(2),size(all_r_dynamic,1))',...
            linspace(color1(3),color2(3),size(all_r_dynamic,1))'];

        % Display results
        ax1a = findobj(handles.ThirdTab,'Tag',sprintf('Ax%da',i));
        cla(ax1a);

        imagesc('XData',lags,'YData',im_mid,'CData',all_r_dynamic,'Parent',ax1a);
        hold(ax1a,'on');
        line('XData',all_locs_dynamic,'YData',im_mid,'Parent',ax1a,'Tag','MaxPeak',...
            'LineStyle','none','Color','k','Linewidth',1,...
            'MarkerSize',3,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
        line('XData',all_locs_dynamic_min,'YData',im_mid,'Parent',ax1a,'Tag','MinPeak',...
            'LineStyle','none','Color','k','Linewidth',1,...
            'MarkerSize',3,'Marker','o','MarkerFaceColor','none','MarkerEdgeColor',[.5 .5 .5]);
        ax1a.XLim =[lags(1) lags(end)];
        ax1a.YDir ='reverse';
        ax1a.YLim =[im_mid(1) im_mid(end)];

        ax1a.YTick = im_mid(1:10:end);
        ax1a.Title.String = label_regions(i);
        ax1a.CLim = [-.5 1];
        ax1a.Tag = sprintf('Ax%da',i);

        % buidling offset
        offset_bound = 20;
        offset_vec = rescale(flipud(1:size(all_r_dynamic,1)),0,offset_bound)';
        offset_mat = repmat(offset_vec,[1,size(all_r_dynamic,2)]);
        all_r_dynamic_offset=-all_r_dynamic+offset_mat;
        ax1b = findobj(handles.ThirdTab,'Tag',sprintf('Ax%db',i));
        cla(ax1b);
        hold(ax1b,'on');
        for j=1:size(all_r_dynamic,1)
            line('XData',lags,'YData',all_r_dynamic_offset(j,:),'Parent',ax1b,'Tag','Line_R',...
                'LineStyle','-','Color',colors_p(j,:),'Linewidth',.5);%[.5 .5 .5]
            line('XData',all_locs_dynamic(j),'YData',all_r_dynamic(j)+offset_vec(j),'Parent',ax1b,'Tag','MaxPeak',...
                'LineStyle','none','Color','k','Linewidth',1,...
                'MarkerSize',3,'Marker','o','MarkerFaceColor',colors_p(j,:),'MarkerEdgeColor',colors_p(j,:));
            line('XData',all_locs_dynamic_min(j),'YData',all_r_dynamic(j)+offset_vec(j),'Parent',ax1b,'Tag','MinPeak',...
                'LineStyle','none','Color','k','Linewidth',1,...
                'MarkerSize',3,'Marker','o','MarkerFaceColor','none','MarkerEdgeColor',colors_p(j,:));
        end
        %     line('XData',lags,'YData',mean(all_r_regions,1,'omitnan'),'Parent',ax1b,'Tag','Mean_R',...
        %         'LineStyle','-','Color','r','Linewidth',1);
        hold(ax1b,'off');
        ax1b.YDir = 'reverse';
        ax1b.XLim =[lags(1) lags(end)];
        ax1b.YLim =[-1 .5+offset_bound];
        ax1b.YTick = rescale(im_mid(1:10:end),0,offset_bound);
        ax1b.Title.String = label_regions(i);
        ax1b.Tag = sprintf('Ax%db',i);

        % Colorbars and labels
        if i==1
            ax1a.YTickLabel = label_mid;
            ax1b.YTickLabel = label_mid;
        else
            ax1a.YTickLabel = [];
            ax1b.YTickLabel = [];
            %             if i==length(label_regions)
            %                 colorbar(ax1a,"north");
            %             end
        end
    end

end

if flag_dynamics_groups && ~isempty(IM_group)

    % Compute auto-correlations dynamics
    % Groups
    Params.str = 'Group Dynamics';
    IM_dynamic_groups=[];
    im_start = 1:bin_size:size(IM_group,3)-bin_length+1;
    im_end = im_start+bin_length-1;
    im_mid = (im_start+im_end)/2;
    %     label_mid = datestr(time_ref.Y(round(im_mid(1:10:end)))/(24*3600),'HH:MM:SS.FFF');
    label_mid = datestr(time_ref.Y(round(im_mid(1:10:end)))/(24*3600),'HH:MM:SS');

    for j=1:length(im_start)
        IM_dynamic_groups=cat(2,IM_dynamic_groups,IM_group(:,:,im_start(j):im_end(j)));
    end
    [all_r_dynamic_groups,all_pks_dynamic_groups,all_locs_dynamic_groups,lags] = main_autocorr(IM_dynamic_groups,Params);
    IM_all_r_dynamic_groups = reshape(all_r_dynamic_groups,[size(IM_dynamic_groups,1),size(IM_dynamic_groups,2),size(all_r_dynamic_groups,2)]);
    IM_all_pks_dynamic_groups=[];
    for k=1:4
        IM_all_pks_dynamic_groups(:,:,k) = reshape(all_pks_dynamic_groups(:,k),[size(IM_dynamic_groups,1),size(IM_dynamic_groups,2)]);
    end
    IM_all_locs_dynamic_groups = [];
    for k=1:4
        IM_all_locs_dynamic_groups(:,:,k) = reshape(all_locs_dynamic_groups(:,k),[size(IM_dynamic_groups,1),size(IM_dynamic_groups,2)]);
    end

    for i = 1:length(label_groups)
        all_r_dynamic_groups=squeeze(IM_all_r_dynamic_groups(i,:,:));
        all_locs_dynamic_groups=squeeze(IM_all_locs_dynamic_groups(i,:,1));
        all_pks_dynamic_groups=squeeze(IM_all_pks_dynamic_groups(i,:,1));
        all_locs_dynamic_groups_min=squeeze(IM_all_locs_dynamic_groups(i,:,3));
        all_pks_dynamic_groups_min=squeeze(IM_all_pks_dynamic_groups(i,:,3));

        % Building colors
        color1=[255, 255, 150]/255;
        color2=[108, 108, 43]/255;
        colors_p = [linspace(color1(1),color2(1),size(all_r_dynamic_groups,1))',...
            linspace(color1(2),color2(2),size(all_r_dynamic_groups,1))',...
            linspace(color1(3),color2(3),size(all_r_dynamic_groups,1))'];

        % Display results
        ax1a = findobj(handles.FourthTab,'Tag',sprintf('Ax%da',i));
        cla(ax1a);
        imagesc('XData',lags,'YData',im_mid,'CData',all_r_dynamic_groups,'Parent',ax1a);
        hold(ax1a,'on');
        line('XData',all_locs_dynamic_groups,'YData',im_mid,'Parent',ax1a,'Tag','MaxPeak',...
            'LineStyle','none','Color','k','Linewidth',1,...
            'MarkerSize',3,'Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5]);
        line('XData',all_locs_dynamic_groups_min,'YData',im_mid,'Parent',ax1a,'Tag','MinPeak',...
            'LineStyle','none','Color','k','Linewidth',1,...
            'MarkerSize',3,'Marker','o','MarkerFaceColor','none','MarkerEdgeColor',[.5 .5 .5]);
        ax1a.XLim =[lags(1) lags(end)];
        ax1a.YDir ='reverse';
        ax1a.YLim =[im_mid(1) im_mid(end)];
        ax1a.YTick = im_mid(1:10:end);
        ax1a.Title.String = label_groups(i);
        ax1a.CLim = [-.5 1];
        ax1a.Tag = sprintf('Ax%da',i);

        % buidling offset
        offset_bound = 20;
        offset_vec = rescale(flipud(1:size(all_r_dynamic_groups,1)),0,offset_bound)';
        offset_mat = repmat(offset_vec,[1,size(all_r_dynamic_groups,2)]);
        all_r_dynamic_groups_offset=-all_r_dynamic_groups+offset_mat;
        ax1b = findobj(handles.FourthTab,'Tag',sprintf('Ax%db',i));
        cla(ax1b);
        hold(ax1b,'on');
        for j=1:size(all_r_dynamic,1)
            line('XData',lags,'YData',all_r_dynamic_groups_offset(j,:),'Parent',ax1b,'Tag','Line_R',...
                'LineStyle','-','Color',colors_p(j,:),'Linewidth',.5); % [.5 .5 .5]
            line('XData',all_locs_dynamic_groups(j),'YData',all_r_dynamic_groups(j)+offset_vec(j),'Parent',ax1b,'Tag','MaxPeak',...
                'LineStyle','none','Color','k','Linewidth',1,...
                'MarkerSize',3,'Marker','o','MarkerFaceColor',colors_p(j,:),'MarkerEdgeColor',colors_p(j,:));
            line('XData',all_locs_dynamic_groups_min(j),'YData',all_r_dynamic_groups(j)+offset_vec(j),'Parent',ax1b,'Tag','MinPeak',...
                'LineStyle','none','Color','k','Linewidth',1,...
                'MarkerSize',3,'Marker','o','MarkerFaceColor','none','MarkerEdgeColor',colors_p(j,:));
        end
        %     line('XData',lags,'YData',mean(all_r_dynamic_groups,1,'omitnan'),'Parent',ax1b,'Tag','Mean_R',...
        %         'LineStyle','-','Color','r','Linewidth',1);
        hold(ax1b,'off');
        ax1b.YDir = 'reverse';
        ax1b.XLim =[lags(1) lags(end)];
        ax1b.YLim =[-1 .5+offset_bound];
        ax1b.YTick = rescale(im_mid(1:10:end),0,offset_bound);
        ax1b.YTickLabel = label_mid;
        ax1b.Title.String = label_groups(i);
        ax1b.Tag = sprintf('Ax%db',i);

        % Colorbars and labels
        if i==1
            ax1a.YTickLabel = label_mid;
            ax1b.YTickLabel = label_mid;
        else
            ax1a.YTickLabel = [];
            ax1b.YTickLabel = [];
            %             if i==length(label_groups)
            %                 colorbar(ax1a,"north");
            %             end
        end
    end
end

handles.MainFigure.Pointer = 'arrow';
handles.MainFigure.UserData.success = true;

% Signaling flag_compute
handles.MainFigure.UserData.flag_compute = true;

% Storing parameters
Params.cur_file = cur_file;
Params.cur_tag = cur_tag;
Params.max_delay = max_delay;
Params.step_delay = step_delay;
Params.t_gauss_data = t_gauss_data;
Params.t_gauss_corr = t_gauss_corr;
Params.t_step = t_step;
Params.im_start = im_start;
Params.im_end = im_end;
Params.t_start = t_start;
Params.t_end = t_end;
Params.tts_start = tts_start;
Params.tts_end = tts_end;
Params.lags = lags;
handles.ButtonCompute.UserData.Params = Params;

% Storing data
handles.ButtonCompute.UserData.IM_all_r = IM_all_r;
handles.ButtonCompute.UserData.IM_all_pks = IM_all_pks;
handles.ButtonCompute.UserData.IM_all_locs = IM_all_locs;
handles.ButtonCompute.UserData.IM_all_r_2x2 = IM_all_r_2x2;
handles.ButtonCompute.UserData.IM_all_pks_2x2 = IM_all_pks_2x2;
handles.ButtonCompute.UserData.IM_all_locs_2x2 = IM_all_locs_2x2;
handles.ButtonCompute.UserData.IM_all_r_3x3 = IM_all_r_3x3;
handles.ButtonCompute.UserData.IM_all_pks_3x3 = IM_all_pks_3x3;
handles.ButtonCompute.UserData.IM_all_locs_3x3 = IM_all_locs_3x3;

handles.ButtonCompute.UserData.label_regions = label_regions;
handles.ButtonCompute.UserData.label_groups = label_groups;
handles.ButtonCompute.UserData.all_r_regions = all_r_regions;
handles.ButtonCompute.UserData.all_pks_regions = all_pks_regions;
handles.ButtonCompute.UserData.all_locs_regions = all_locs_regions;
handles.ButtonCompute.UserData.all_r_groups = all_r_groups;
handles.ButtonCompute.UserData.all_pks_groups = all_pks_groups;
handles.ButtonCompute.UserData.all_locs_groups = all_locs_groups;

handles.ButtonCompute.UserData.IM_all_r_dynamic = IM_all_r_dynamic;
handles.ButtonCompute.UserData.IM_all_pks_dynamic = IM_all_pks_dynamic;
handles.ButtonCompute.UserData.IM_all_locs_dynamic = IM_all_locs_dynamic;

handles.ButtonCompute.UserData.IM_all_r_dynamic_groups = IM_all_r_dynamic_groups;
handles.ButtonCompute.UserData.IM_all_pks_dynamic_groups = IM_all_pks_dynamic_groups;
handles.ButtonCompute.UserData.IM_all_locs_dynamic_groups = IM_all_locs_dynamic_groups;

end

function [all_r,all_pks,all_locs,lags] = main_autocorr(IM_restricted,Params)

cur_file = Params.cur_file;
t_step = Params.t_step;
max_delay = Params.max_delay;
step_delay = Params.step_delay;
t_gauss_data = Params.t_gauss_data;
t_gauss_corr = Params.t_gauss_corr;

all_pixels_aligned = reshape(IM_restricted,[size(IM_restricted,1)*size(IM_restricted,2),size(IM_restricted,3)]);

% Gaussian Smoothing Data
fprintf('Smoothing Data [File:%s, t=%.1f s] ...',cur_file,t_gauss_data);
step_data = max(round(t_gauss_data/t_step),1);
all_pixels_smoothed = imgaussfilt(all_pixels_aligned,[1 step_data]);
all_pixels_aligned = all_pixels_smoothed;
fprintf(' done.\n');

% Building parameters
maxlag = ceil(max_delay/t_step);
step_corr = max(round(t_gauss_corr/t_step),1);

h = waitbar(0,'Please wait');
all_r = NaN(size(all_pixels_aligned,1),2*maxlag+1);
for k = 1:size(all_pixels_aligned,1)
    prop = k/size(all_pixels_aligned,1);
    waitbar(prop,h,sprintf('Computing Auto-Correlation [%s] %.1f %% completed',Params.str,100*prop));

    % Using matlab corr
    A = squeeze(all_pixels_aligned(k,:))';
    B = NaN(size(A,1),2*maxlag+1);
    for kk = -maxlag:1:maxlag
        index_kk=kk+maxlag+1;
        if kk<0
            temp = A(abs(kk)+1:end);
            B(1:length(temp),index_kk) = temp;
        elseif k>0
            temp = A(1:end-kk);
            B(kk+1:end,index_kk) = temp;
        else
            B(:,:,index_kk) = A;
        end
    end
    r = corr(B,A,'rows','complete');

    %     % Using matlab xcorr (problem of normalization)
    %     X = squeeze(all_pixels_aligned(k,:));
    %     [r,lags] = xcorr(X,maxlag,'coeff');

    all_r(k,:) = r;

    % Gaussian Smoothing Correlogram
    r_smoothed = imgaussfilt(r,step_corr);
    all_r(k,:) = rescale(r_smoothed,min(r),max(r));
end
% resizing lags
lags = (-maxlag:1:maxlag)*t_step;
close(h);

% Interpolating Correlogram
fprintf('Interpolating Data [File:%s] ...',cur_file);
x = lags;
y = 1:size(all_r,1);
[X,Y]=meshgrid(x,y);
xq = -max_delay:step_delay:max_delay;
yq = y;
[Xq,Yq]=meshgrid(xq,yq);
V=all_r;
if size(all_r,1)==1
    Vq = interp1(X,V,Xq);
else
    Vq = interp2(X,Y,V,Xq,Yq);
end
fprintf(' done.\n');

% Renaming things
lags = xq;
all_r = Vq;

% finding peaks
h = waitbar(0,'Please wait');
all_pks = NaN(size(all_pixels_aligned,1),4);
all_locs = NaN(size(all_pixels_aligned,1),4);
% First Positive Peak - Max Positive Peak - First Negative Peak - Max Negative Peak
index_0=find(lags==0);

for k = 1:size(all_r,1)
    prop = k/size(all_r,1);
    waitbar(prop,h,sprintf('Finding peaks [%s] %.1f %% completed',Params.str,100*prop));

    r = all_r(k,index_0:end);
    % Positive peaks
    [pks,locs] = findpeaks(r);
    if length(pks)>1
        pk_first = pks(1);
        loc_first = locs(1)+(index_0-1);
        [pk_max,i_max] = max(pks);
        loc_max = locs(i_max)+(index_0-1);
        all_pks(k,1) = pk_first;
        all_locs(k,1) = lags(loc_first);
        all_pks(k,2) = pk_max;
        all_locs(k,2) = lags(loc_max);
    elseif length(pks)==1
        pk_max = pks;
        loc_max = locs+(index_0-1);
        all_pks(k,1) = pk_max;
        all_locs(k,1) = lags(loc_max);
        all_pks(k,2) = pk_max;
        all_locs(k,2) = lags(loc_max);
    end
    % Negative peaks
    [pks,locs] = findpeaks(-r);
    if length(pks)>1
        pk_second = pks(1);
        loc_second = locs(1)+(index_0-1);
        [pk_min,i_min] = max(pks);
        loc_min = locs(i_min)+(index_0-1);
        all_pks(k,3) = -pk_second;
        all_locs(k,3) = lags(loc_second);
        all_pks(k,4) = -pk_min;
        all_locs(k,4) = lags(loc_min);
    elseif length(pks)==1
        pk_min = pks;
        loc_min = locs+(index_0-1);
        all_pks_min(k,3) = -pk_min;
        all_locs_min(k,3) = lags(loc_min);
        all_pks_min(k,4) = -pk_min;
        all_locs_min(k,4) = lags(loc_min);
    end
end
close(h);

end

function buttonAutoScale_Callback(~,~,handles)

ax_info = findobj(handles.MainFigure,'Tag','Ax_Info');
x_start = ax_info.XLim(1);
x_end = ax_info.XLim(2);
lines=findobj(ax_info,'Tag','Trace_Pixel','-or','Tag','Trace_Mean');
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
ax_info.YLim = [m M];

end

function saveimage_Callback(~,~,handles,flags)

if nargin < 4
    flags = [1,1,1,1,1];
end
flag_pixels = flags(1);
flag_regions = flags(2);
flag_groups = flags(3);
flag_dynamics = flags(4);
flag_dynamics_groups = flags(5);


global DIR_FIG;
load('Preferences.mat','GTraces');

Params = handles.ButtonCompute.UserData.Params;
tag = Params.cur_tag;
recording = Params.cur_file;

% Creating Fig Directory
save_dir = fullfile(DIR_FIG,'Auto-Correlation',recording);
if ~isfolder(save_dir)
    mkdir(save_dir);
end

% Saving Image
cur_tab = handles.TabGroup.SelectedTab;

if flag_pixels==1
    handles.TabGroup.SelectedTab = handles.FirstTab;
    pic_name = sprintf('%s_Auto-Correlation-Pixels_%s%s',recording,tag,GTraces.ImageSaveExtension);
    saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
    fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
end

if flag_regions==1 || flag_groups==1
    handles.TabGroup.SelectedTab = handles.SecondTab;
    pic_name = sprintf('%s_Auto-Correlation-Regions_%s%s',recording,tag,GTraces.ImageSaveExtension);
    saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
    fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
end

if flag_dynamics==1
    handles.TabGroup.SelectedTab = handles.ThirdTab;
    pic_name = sprintf('%s_Auto-Correlation-RegionsDynamics%s',recording,GTraces.ImageSaveExtension);
    saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
    fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
end

if flag_dynamics_groups==1
    handles.TabGroup.SelectedTab = handles.FourthTab;
    pic_name = sprintf('%s_Auto-Correlation-GroupDynamics%s',recording,GTraces.ImageSaveExtension);
    saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
    fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
end

handles.TabGroup.SelectedTab = cur_tab;

end

function savestats_Callback(~,~,handles,flags)

if nargin < 4
    flags = [1,1,1,1,1];
end
flag_pixels = flags(1);
flag_regions = flags(2);
flag_groups = flags(3);
flag_dynamics = flags(4);
flag_dynamics_groups = flags(5);

global DIR_STATS;

Params = handles.ButtonCompute.UserData.Params;
tag = Params.cur_tag;
recording = Params.cur_file;

% Retrieving data
IM_all_r = handles.ButtonCompute.UserData.IM_all_r;
IM_all_pks = handles.ButtonCompute.UserData.IM_all_pks;
IM_all_locs = handles.ButtonCompute.UserData.IM_all_locs;
IM_all_r_2x2 = handles.ButtonCompute.UserData.IM_all_r_2x2;
IM_all_pks_2x2 = handles.ButtonCompute.UserData.IM_all_pks_2x2;
IM_all_locs_2x2 = handles.ButtonCompute.UserData.IM_all_locs_2x2;
IM_all_r_3x3 = handles.ButtonCompute.UserData.IM_all_r_3x3;
IM_all_pks_3x3 = handles.ButtonCompute.UserData.IM_all_pks_3x3;
IM_all_locs_3x3 = handles.ButtonCompute.UserData.IM_all_locs_3x3;

label_regions = handles.ButtonCompute.UserData.label_regions;
label_groups = handles.ButtonCompute.UserData.label_groups;
all_r_regions = handles.ButtonCompute.UserData.all_r_regions;
all_pks_regions = handles.ButtonCompute.UserData.all_pks_regions;
all_locs_regions = handles.ButtonCompute.UserData.all_locs_regions;
all_r_groups = handles.ButtonCompute.UserData.all_r_groups;
all_pks_groups = handles.ButtonCompute.UserData.all_pks_groups;
all_locs_groups = handles.ButtonCompute.UserData.all_locs_groups;

IM_all_r_dynamic = handles.ButtonCompute.UserData.IM_all_r_dynamic;
IM_all_pks_dynamic = handles.ButtonCompute.UserData.IM_all_pks_dynamic;
IM_all_locs_dynamic = handles.ButtonCompute.UserData.IM_all_locs_dynamic;
IM_all_r_dynamic_groups = handles.ButtonCompute.UserData.IM_all_r_dynamic_groups;
IM_all_pks_dynamic_groups = handles.ButtonCompute.UserData.IM_all_pks_dynamic_groups;
IM_all_locs_dynamic_groups = handles.ButtonCompute.UserData.IM_all_locs_dynamic_groups;


% Creating Stats Directory
data_dir = fullfile(DIR_STATS,'Auto-Correlation',recording);
if ~isfolder(data_dir)
    mkdir(data_dir);
end

if flag_pixels==1 || flag_regions==1 || flag_groups==1
    % Saving data by tag
    filename = sprintf('%s_Auto-Correlation_%s.mat',recording,tag);
    save(fullfile(data_dir,filename),'recording','tag', ...
        'IM_all_r','IM_all_pks','IM_all_locs',...
        'label_regions','all_r_regions','all_pks_regions','all_locs_regions',...
        'label_groups','all_r_groups','all_pks_groups','all_locs_groups',...
        'Params','-v7.3');
    fprintf('Data saved at %s.\n',fullfile(data_dir,filename));
end

if flag_dynamics==1 || flag_dynamics_groups==1
    % Saving data dynamic
    filename = sprintf('%s_Auto-Correlation-Dynamics.mat',recording);
    save(fullfile(data_dir,filename),'recording', ...
        'label_regions',...
        'label_groups',...
        'IM_all_r_dynamic','IM_all_pks_dynamic','IM_all_locs_dynamic',...
        'IM_all_r_dynamic_groups','IM_all_pks_dynamic_groups','IM_all_locs_dynamic_groups',...
        'Params','-v7.3');
    fprintf('Data saved at %s.\n',fullfile(data_dir,filename));
end

end

function batchsave_Callback(~,~,handles,str_tag,val)

time_ref = handles.MainFigure.UserData.time_ref;
x_start = handles.MainFigure.UserData.x_start;
x_end = handles.MainFigure.UserData.x_end;
t_step = handles.MainFigure.UserData.t_step;
TimeTags = handles.MainFigure.UserData.TimeTags;
TimeTags_strings = handles.MainFigure.UserData.TimeTags_strings;
TimeTags_images = handles.MainFigure.UserData.TimeTags_images;
TimeTags_cell = handles.MainFigure.UserData.TimeTags_cell;

if nargin == 3
    % If Manual Callback open inputdlg
    str_tag = strcat({TimeTags(:).Tag}',' - ',{TimeTags(:).Onset}',' - ',{TimeTags(:).Duration}');
    [ind_tag,v] = listdlg('Name','Tag Selection','PromptString','Select Time Tags',...
        'SelectionMode','multiple','ListString',str_tag,'InitialValue','','ListSize',[300 500]);
    if isempty(ind_tag)||v==0
        return
    end
else
    % If batch mode, keep only elements matching str_tag
    ind_tag = [];
    temp = {TimeTags(:).Tag}';
    for i=1:length(temp)
        ind_keep = ~(cellfun('isempty',strfind(str_tag,temp(i))));
        if sum(ind_keep)>0
            ind_tag=[ind_tag,i];
        end
    end
end

% % Restricts to time tags longer than 120 seconds
% temp=datenum({TimeTags(:).Duration}');
% TimeTags_dur = (temp-floor(temp))*24*3600;
% ind_tag = ind_tag(TimeTags_dur>600);

% Compute for designated time tags
% val = handles.Popup1.Value;
for i = 1:length(ind_tag)%size(TimeTags_strings,1)

    handles.Popup1.Value = ind_tag(i);
    update_popup_Callback(handles.Popup1,[],handles);
    buttonAutoScale_Callback([],[],handles);

    flags = [0,1,1,0,0];
    compute_autocorr_Callback([],[],handles,val,flags);
    savestats_Callback([],[],handles,flags);
    saveimage_Callback([],[],handles,flags);

end
% handles.Popup1.Value = val;
% update_popup_Callback(handles.Popup1,[],handles);

% flags = [0,0,0,1,1];
% compute_autocorr_Callback([],[],handles,val,flags);
% savestats_Callback([],[],handles,flags);
% saveimage_Callback([],[],handles,flags);

end
