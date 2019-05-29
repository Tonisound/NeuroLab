
function f = figure_VascularPotentiation(handles)

global FILES CUR_FILE START_IM END_IM IM;
start_im = START_IM;
end_im = END_IM;
margin_w = .02;
margin_h = .05;

f = figure('Units','normalized',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Peri Event Histogramm');
clrmenu(f);
colormap(f,'hot');
f.UserData.success = false;
f.UserData.IM = IM;

iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','InfoPanel',...
    'Position',[0 0 1 .15],...
    'Parent',f);
% Creating uitabgroup
mP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 iP.Position(4) 1 1-iP.Position(4)],...
    'Parent',f);
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',mP,...
    'Tag','TabGroup');
% Potentiation Tab
uitab('Parent',tabgp,...
    'Title','Potentiation',...
    'Tag','PotentiationTab');

% Texts and Edits
t1 = uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('File : %s',FILES(CUR_FILE).nlab),'Tag','Text1');
t2 = uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf(handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:)),...
    'Tag','Text2');
e1 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',start_im,'Tag','Edit1','Tooltipstring','Start Image');
e2 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',end_im,'Tag','Edit2','Tooltipstring','End Image');
e3 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',margin_w,'Tag','Edit3','Tooltipstring','margin_w');
e4 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',margin_h,'Tag','Edit4','Tooltipstring','margin_h');

% Buttons 
br = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset');
bc = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute');
bsi = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save Image','Tag','ButtonSaveImage');
bss = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save Stats','Tag','ButtonSaveStats');
bb = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Batch','Tag','ButtonBatch');
bb.UserData.fUSData = [];
bb.UserData.LFPData = [];
bb.UserData.CFCData = [];

% position
t1.Position = [0     .4    .25   .5];
t2.Position = [0     -.1    .25   .5];
e1.Position = [.25     .5    .05   .5];
e2.Position = [.25     0    .05   .5];
e3.Position = [.35     .5    .05   .5];
e4.Position = [.35     0    .05   .5];
bc.Position = [7/10     .5      .1   .5];
br.Position = [7/10     0      .1   .5];
bss.Position = [8/10     .5      .1   .5];
bsi.Position = [8/10     0      .1   .5];
bb.Position = [9/10     .5      .1   .5];

f.Position = [0.12    0.2    0.75    0.5];

handles2 = guihandles(f);
%reset_Callback([],[],handles2);
bc.Callback = {@compute_Callback,handles2};
bsi.Callback = {@saveimage_Callback,handles2};
bss.Callback = {@savestats_Callback,handles2};
bb.Callback = {@batchsave_Callback,handles2};

end

% function reset_Callback(~,~,handles)
% end

function compute_Callback(~,~,handles)

tab0 = handles.PotentiationTab;
f = handles.MainFigure;
start_im = str2double(handles.Edit1.String);
end_im = str2double(handles.Edit2.String);
margin_w = str2double(handles.Edit3.String);
margin_h = str2double(handles.Edit4.String);
IM = f.UserData.IM;

delete(tab0.Children);

X = (1:end_im-start_im+1)';
n = 1;
P1 = NaN(size(IM(:,:,1)));
P2 = NaN(size(IM(:,:,1)));
h = waitbar(0,'start');

for i =1:size(IM,1)
    for j =1:size(IM,2)
        Y = squeeze(IM(i,j,start_im:end_im));
        P = polyfit(X,Y,n);
        P1(i,j) = P(1);
        P2(i,j) = P(2);
    end
    x=i/size(IM,1);
    waitbar(x,h,sprintf('%.1f/100 completed',100*x));

end
close(h);

ax1 = axes('Parent',tab0);
imagesc(P2,'parent',ax1);
title(sprintf('offset (%d-%d)',start_im,end_im))
colorbar(ax1);

ax2 = axes('Parent',tab0);
im = imagesc(P1,'parent',ax2);
im.AlphaData = P1>0;
title(sprintf('slope + (%d-%d)',start_im,end_im))
colorbar(ax2);
ax3 = axes('Parent',tab0);
im = imagesc(P1,'parent',ax3);
im.AlphaData = P1<0;
title(sprintf('slope - (%d-%d)',start_im,end_im))
colorbar(ax3);

ax1.Position = [margin_w margin_h 1/3-3*margin_w 1-2*margin_h];
ax1.Visible = 'off';
ax1.Title.Visible = 'on';
ax2.Position = [1/3+margin_w margin_h 1/3-3*margin_w 1-2*margin_h];
ax2.Visible = 'off';
ax2.Title.Visible = 'on';
ax3.Position = [2/3+margin_w margin_h 1/3-3*margin_w 1-2*margin_h];
ax2.Visible = 'off';
ax2.Title.Visible = 'on';

f.UserData.success = true;

end

function saveimage_Callback(~,~,handles)

global FILES CUR_FILE DIR_FIG;
load('Preferences.mat','GTraces');

%Loading data
% tag = char(handles.MainFigure.UserData.Tag_Selection(1));
% channel = handles.MainFigure.UserData.channel;
% Creating Save Directory
save_dir = fullfile(DIR_FIG,'Vascular Potentiation',FILES(CUR_FILE).recording);
if ~isdir(save_dir)
    mkdir(save_dir);
end

% Saving Image
cur_tab = handles.TabGroup.SelectedTab;
handles.TabGroup.SelectedTab = handles.PotentiationTab;
pic_name = sprintf('%s_Vascular_Potentiation_%s_%s%s',FILES(CUR_FILE).recording,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FirstTab;
pic_name = sprintf('%s_Peak_Detection_RasterY_%s_%s%s',FILES(CUR_FILE).recording,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.SecondTab;
pic_name = sprintf('%s_Peak_Detection_TimingY_%s_%s%s',FILES(CUR_FILE).recording,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.ThirdTab;
pic_name = sprintf('%s_Peak_Detection_RasterdYdt_%s_%s%s',FILES(CUR_FILE).recording,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FourthTab;
pic_name = sprintf('%s_Peak_Detection_TimingdYdt_%s_%s%s',FILES(CUR_FILE).recording,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FifthTab;
pic_name = sprintf('%s_Peak_Detection_Synthesis_%s_%s%s',FILES(CUR_FILE).recording,tag,channel,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.SixthTab;
pic_name = sprintf('%s_Peak_Detection_Continuous_%s_%s%s',FILES(CUR_FILE).recording,tag,channel,GTraces.ImageSaveExtension);
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
recording = FILES(CUR_FILE).recording;
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
data_dir = fullfile(DIR_STATS,'Peak_Detection',FILES(CUR_FILE).recording);
if ~isdir(data_dir)
    mkdir(data_dir);
end

% Saving data
filename = sprintf('%s_Peak_Detection_%s_%s.mat',FILES(CUR_FILE).recording,channel,tag);
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

