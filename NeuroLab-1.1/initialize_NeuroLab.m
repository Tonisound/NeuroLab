function [f,myhandles] = initialize_NeuroLab(str,UiValues)
% GUI Reinitialization 
% Author : AB
% Last modified: 10/04/18

global IM CUR_IM START_IM END_IM LAST_IM CUR_FILE FILES DIR_SAVE ;

load('Preferences.mat','GDisp','GTraces');

%% GUI layout
% Display Parameters for GUI initialization
panelColor = get(0,'DefaultUicontrolBackgroundColor');
% w0 = .4;
% h0 = .1;
% W = .8;
% H = .8;
W = GDisp.W;
H = GDisp.H;
w0 = GDisp.w0;
h0 = GDisp.h0;

% Setting fonts
fontsize = 12;
fontname = 'Arial';  
set(0, 'DefaultAxesFontName',fontname);
set(0, 'DefaultUiControlFontName',fontname);

% Time Reference Loading
if ~isempty(FILES) && exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file')
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','length_burst','n_burst','rec_mode');
else
    %warning('Missing File Time_Reference.mat');
    length_burst = size(IM,3);
    n_burst = 1;
end

% handles.MainFigure
f = figure('Units','normalized',...
    'Position',[w0 h0 W H],...
    'Color',panelColor,...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'WindowStyle','docked',...
    'Name','Functional Ultrasound Imaging Lab');
cmap = [0         0    0.5625
         0         0    0.6250
         0         0    0.6875
         0         0    0.7500
         0         0    0.8125
         0         0    0.8750
         0         0    0.9375
         0         0    1.0000
         0    0.0625    1.0000
         0    0.1250    1.0000
         0    0.1875    1.0000
         0    0.2500    1.0000
         0    0.3125    1.0000
         0    0.3750    1.0000
         0    0.4375    1.0000
         0    0.5000    1.0000
         0    0.5625    1.0000
         0    0.6250    1.0000
         0    0.6875    1.0000
         0    0.7500    1.0000
         0    0.8125    1.0000
         0    0.8750    1.0000
         0    0.9375    1.0000
         0    1.0000    1.0000
    0.0625    1.0000    0.9375
    0.1250    1.0000    0.8750
    0.1875    1.0000    0.8125
    0.2500    1.0000    0.7500
    0.3125    1.0000    0.6875
    0.3750    1.0000    0.6250
    0.4375    1.0000    0.5625
    0.5000    1.0000    0.5000
    0.5625    1.0000    0.4375
    0.6250    1.0000    0.3750
    0.6875    1.0000    0.3125
    0.7500    1.0000    0.2500
    0.8125    1.0000    0.1875
    0.8750    1.0000    0.1250
    0.9375    1.0000    0.0625
    1.0000    1.0000         0
    1.0000    0.9375         0
    1.0000    0.8750         0
    1.0000    0.8125         0
    1.0000    0.7500         0
    1.0000    0.6875         0
    1.0000    0.6250         0
    1.0000    0.5625         0
    1.0000    0.5000         0
    1.0000    0.4375         0
    1.0000    0.3750         0
    1.0000    0.3125         0
    1.0000    0.2500         0
    1.0000    0.1875         0
    1.0000    0.1250         0
    1.0000    0.0625         0
    1.0000         0         0
    0.9375         0         0
    0.8750         0         0
    0.8125         0         0
    0.7500         0         0
    0.6875         0         0
    0.6250         0         0
    0.5625         0         0
    0.5000         0         0];
f.Colormap = cmap;

% handles.FileMenu
m1 = uimenu('Label','File','Tag','FileMenu','Parent',f);
uimenu(m1,'Label','Manage Files','Tag','FileMenu_Manage','Accelerator','F');
uimenu(m1,'Label','Next File','Tag','FileMenu_Next','Accelerator','L');
uimenu(m1,'Label','Previous File','Tag','FileMenu_Prev','Accelerator','P');
uimenu(m1,'Label','Load Recording List','Tag','FileMenu_LoadRecList','Separator','on');
uimenu(m1,'Label','Save Recording List','Tag','FileMenu_SaveRecList');
uimenu(m1,'Label','Save UF Params','Tag','FileMenu_SaveUFParams');
uimenu(m1,'Label','Save Configuration','Tag','FileMenu_Save','Accelerator','S');

% handles.ImportMenu
m1b = uimenu('Label','Import','Tag','ImportMenu','Parent',f);
uimenu(m1b,'Label','Import File','Tag','FileMenu_Import');
uimenu(m1b,'Label','Import Doppler film','Tag','ImportMenu_Doppler','Separator','on');
uimenu(m1b,'Label','Import Reference Time','Tag','ImportMenu_ReferenceTime');
uimenu(m1b,'Label','Import Time Tags','Tag','ImportMenu_TimeTags');
uimenu(m1b,'Label','Import Video','Tag','ImportMenu_Video');
uimenu(m1b,'Label','Import LFP Configuration','Tag','ImportMenu_ImportConfig');
% uimenu(m1b,'Label','Import LFP Traces','Tag','ImportMenu_LFPTraces');
% uimenu(m1b,'Label','Import Regions','Tag','ImportMenu_Regions');
% uimenu(m1b,'Label','Import External Files','Tag','ImportMenu_ExternalFiles');

uimenu(m1b,'Label','Reload Doppler film','Tag','ImportMenu_ReloadDoppler','Separator','on');
uimenu(m1b,'Label','Reload Graphics','Tag','ImportMenu_ReloadGraphic');
% uimenu(m1b,'Label','Load Cereplex Traces','Tag','ImportMenu_LoadTraces','Enable','on');
% uimenu(m1b,'Label','Load Regions','Tag','ImportMenu_LoadRegions','Enable','on');

% handles.EditMenu
m2 = uimenu('Label','Edit','Tag','EditMenu','Parent',f);
uimenu(m2,'Label','Edit Traces','Tag','EditMenu_Edition','Accelerator','T');
uimenu(m2,'Label','Edit Time Tags','Tag','EditMenu_TimeTagEdition');
uimenu(m2,'Label','Edit Time Groups','Tag','EditMenu_TimeGroupEdition');
uimenu(m2,'Label','Edit LFP Configuration','Tag','EditMenu_LFPConfig');

uimenu(m2,'Label','Delete All Traces','Tag','EditMenu_Delete_All','Separator','on');
uimenu(m2,'Label','Delete Pixels and Boxes','Tag','EditMenu_Delete_Pixels');
uimenu(m2,'Label','Delete Region Traces','Tag','EditMenu_Delete_Regions');
uimenu(m2,'Label','Delete Cereplex Traces','Tag','EditMenu_Delete_Spiko');

uimenu(m2,'Label','Actualize Traces','Tag','ImportMenu_ActualizeTraces','Separator','on');

% handles.DisplayMenu
m1c = uimenu('Label','Display','Tag','DisplayMenu','Parent',f);
uimenu(m1c,'Label','Show Video','Tag','DisplayMenu_Video','Checked',UiValues.video_status);
uimenu(m1c,'Label','Split axes','Tag','DisplayMenu_Split','Enable','off');
uimenu(m1c,'Label','Select Time Tags','Tag','DisplayMenu_TagSelection','Separator','on');
uimenu(m1c,'Label','Select Time Groups','Tag','DisplayMenu_TimeGroupSelection');


% handles.SynthesisMenu
m2c = uimenu('Label','Synthesis','Tag','SynthesisMenu','Parent',f);
uimenu(m2c,'Label','Correlation Analysis','Tag','SynthesisMenu_Correlation');
uimenu(m2c,'Label','Region Statistics','Tag','SynthesisMenu_Region');
uimenu(m2c,'Label','Global Display','Tag','SynthesisMenu_Display');
uimenu(m2c,'Label','fUS Episode Statistics','Tag','SynthesisMenu_Statistics');
uimenu(m2c,'Label','Peak Detection','Tag','SynthesisMenu_PeakDetection');
uimenu(m2c,'Label','Cross-Correlation LFP-fUS','Tag','SynthesisMenu_CrossCorrelation');
uimenu(m2c,'Label','Vascular Surge','Tag','SynthesisMenu_VascularSurge');
uimenu(m2c,'Label','Peak Count','Tag','SynthesisMenu_PeakCount');
uimenu(m2c,'Label','Batch Processing','Tag','SynthesisMenu_Batch','Accelerator','B','Separator','on');

% handles.ExportMenu
m2d = uimenu('Label','Export','Tag','Export Menu','Parent',f);
uimenu(m2d,'Label','Export Time Tags','Tag','ExportMenu_TimeTags');
uimenu(m2d,'Label','Export Anatomical Regions','Tag','ExportMenu_Regions');
uimenu(m2d,'Label','Export IMO file','Tag','ExportMenu_IMOfile');



% handles.ColorMapsMenu
clrmenu(f);

% handles.PrefMenu
m3 = uimenu('Label','Preferences','Tag','PrefMenu','Parent',f);
uimenu(m3,'Label','Edit Preferences','Tag','PrefMenu_Edit','Accelerator','G');
uimenu(m3,'Label','Reset','Tag','PrefMenu_Reset','Separator','on','Enable','off');
uimenu(m3,'Label','Export','Tag','PrefMenu_Export','Enable','off');

% handles.CenterPanel
centerPanel = uipanel('bordertype','etchedin',...
    'Units','normalized',...
    'Tag','CenterPanel',...
    'Parent',f);
% handles.RightPanel
rightPanel = uipanel('bordertype','etchedin',...
    'BackgroundColor',panelColor,...
    'Units','normalized',...
    'Tag','RightPanel',...
    'Parent',f);
% handles.TopPanel
topPanel = uipanel('BorderType','etchedin',...
    'BackgroundColor',panelColor,...
    'Units','normalized',...
    'Tag','TopPanel',...
    'Parent',f);
% handles.BottonPanel
botPanel = uipanel('BorderType','etchedin',...
    'BackgroundColor',panelColor,...
    'Units','normalized',...
    'Tag','BottomPanel',...
    'Parent',f);
% Resizing
topPanel.Position =     [0 1-h0 1 h0];
botPanel.Position =     [0 0 1 h0];
centerPanel.Position =  [0 h0 w0 1-2*h0];
rightPanel.Position =   [w0 h0 1-w0 1-2*h0];

% handles.CenterAxes
%load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.mat'),'CurrentImage');
a = axes('Parent',centerPanel,'NextPlot','replace');
imagesc(IM(:,:,CUR_IM),'Tag','MainImage','HitTest','off','Parent',a);
set(a,'Tag','CenterAxes')
%a.Title.String = 'fUS Image';
a.XLabel.String = 'MesioLateral';
a.YLabel.String = 'DorsoVentral';

% handles.RightAxes
b = axes('Parent',rightPanel,'Xlim',[START_IM END_IM],'Tag','RightAxes');
b.XLabel.String = '# Image';
%b.Title.String = 'Hemodynamics';
%b.YLabel.String = 'Amplitude Response';

% Cursor
line([CUR_IM CUR_IM], ylim(b),...
    'Tag','Cursor',...
    'Color','black',...
    'HitTest','off',...
    'Parent', b);

% Mean Trace
xdata = [reshape(1:LAST_IM,[length_burst,n_burst]);NaN(1,n_burst)];
ydata = [reshape(mean(mean(IM,2,'omitnan'),1,'omitnan'),[length_burst,n_burst]);NaN(1,n_burst)];
hl = line('XData',xdata(:),...
    'YData',ydata(:),...
    'Tag','Trace_Mean',...
    'Color','black',...
    'HitTest','off',...
    'Parent', b);
s.Name = 'Whole';
hl.UserData = s;

t_gauss = GTraces.GaussianSmoothing;
if t_gauss>0 && length(hl.YData)>3
    % Gaussian window
    delta =  time_ref.Y(2)-time_ref.Y(1);
    w = gausswin(round(2*t_gauss/delta));
    w = w/sum(w);
    % Gaussian smoothing
    y = hl.YData(1:end-1);
    if strcmp(rec_mode,'BURST')
        % gaussian nan convolution + nan padding (only for burst_recording)
        length_burst_smooth = 59;
        n_burst_smooth = length(y)/length_burst_smooth;
        y_reshape = [reshape(y,[length_burst_smooth,n_burst_smooth]);NaN(length(w),n_burst_smooth)];
        y_conv = nanconv(y_reshape(:),w,'same');
        y_reshaped = reshape(y_conv,[length_burst_smooth+length(w),n_burst_smooth]);
        y_final = reshape(y_reshaped(1:length_burst_smooth,:),[length_burst_smooth*n_burst_smooth,1]);
        hl.YData(1:end-1) = y_final';
    else
        hl.YData(1:end-1) = nanconv(y,w,'same');
    end
end


%% Main UiControls

% Popup Menu - Liste des fichiers
% handles.FileSelectPopup 
h11 = uicontrol(f,'Style', 'popup',...
    'Units','normalized',...
    'BackgroundColor',panelColor,...
    'String',str,...
    'Value',CUR_FILE,...
    'Tag','FileSelectPopup',...
    'FontSize',fontsize,...
    'Parent',topPanel);
h11.UserData = char(h11.String(h11.Value,:));
% Center Panel Display
% handles.CenterPanelPopup
h12 = uicontrol(f,'Style','popup',...
    'Units','normalized',...
    'String','Doppler_film|Doppler_normalized|Differential Movie',...
    'Value',UiValues.CenterPanelPopup,...
    'UserData',UiValues.CenterPanelPopup,...
    'Tag','CenterPanelPopup',...
    'FontSize',fontsize,...
    'Parent',topPanel);
% Right Panel Display
% handles.RightPanelPopup
h13 = uicontrol(f,'Style','popup',...
    'Units','normalized',...
    'String','Pixel Dynamics|Box Dynamics|Region Dynamics|Trace Dynamics',...
    'Value',UiValues.RightPanelPopup,...
    'Tag','RightPanelPopup',...
    'FontSize',fontsize,...
    'Parent',topPanel);
% Resizing
h11.Position = [0 .55 1 .4];
h12.Position = [0 .05 w0 .4];
h13.Position = [w0 .05 1-w0 .4];

% Processing Options
% handles.ProcessListPopup
pl = uicontrol(f,'Style','popup',...
    'Units','normalized',...
    'Value',UiValues.ProcessListPopup,...
    'Tag','ProcessListPopup',...
    'FontSize',fontsize,...
    'Parent',botPanel);
pl_str = 'Compute Normalized Movie|Detect Vascular Surges|Edit Anatomical Regions';
pl_str = strcat(pl_str,'|Import Regions|Import LFP Traces|Import External Files');
pl_str = strcat(pl_str,'|Export LFP bands|Export Anatomical Regions|Export IMO file');
pl.String = pl_str;

% Process Button
% handles.ProcessButton
h22 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','Process',...
    'Tag','ProcessButton',...
    'FontSize',fontsize,...
    'Parent',botPanel);
% Figure Options
% handles.FigureListPopup
fl = uicontrol(f,'Style','popup',...
    'Units','normalized',...
    'Value',UiValues.FigureListPopup,...
    'Tag','FigureListPopup',...
    'FontSize',fontsize,...
    'Parent',botPanel);
fl_str = '(Movie) Normalized Movie|(Movie) Deformation Field|(Movie) Data Reconstruction';
fl_str = strcat(fl_str,'|(Figure) Principal and Independent Component Analysis|(Figure) Global Episode Display|(Figure) fUS Episode Statistics');
fl_str = strcat(fl_str,'|(Figure) Correlation Analysis|(Figure) LFP Wavelet Analysis|(Figure) fUS Fourier Analysis');
fl_str = strcat(fl_str,'|(Figure) Peak Detection|(Figure) Peri-Event Time Histogram|(Figure) Cross-Correlation LFP-fUS');
fl.String = fl_str;    
% Process Button
% handles.DisplayButton
h24 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','Display',...
    'Tag','DisplayButton',...
    'FontSize',fontsize,...
    'Parent',botPanel);
% Resizing
pl.Position     = [0 .55 .8 .4];
h22.Position    = [.8 .55 .2 .4];
fl.Position     = [0 .05 .8 .4];
h24.Position    = [.8 .05 .2 .4];


% handles.Time Display
td = uicontrol(f,'Style','text',...
    'Units','normalized',...
    'BackgroundColor',panelColor,...
    'HorizontalAlignment','left',...
    'TooltipString', 'Current Time',...
    'UserData',repmat('00:00:00.000',size(IM,3),1),...
    'String','00:00:00.000',...
    'Tag','TimeDisplay',...
    'Parent',centerPanel);
if ~isempty(FILES) 
    if exist('time_ref','var')
        set(td,'UserData',datestr((time_ref.Y)/(24*3600),'HH:MM:SS.FFF'));
        set(td,'String',datestr(time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF'));
    end
end
% handles.PatchBox
pb = uicontrol(f,'Style','checkbox',...
    'Units','normalized',...
    'TooltipString','Patch Display',...
    'Tag','PatchBox',...
    'Value',0,...
    'Parent',centerPanel);
% handles.MaskBox
mb = uicontrol(f,'Style','checkbox',...
    'Units','normalized',...
    'TooltipString','Mask Display',...
    'Tag','MaskBox',...
    'Value',0,...
    'Parent',centerPanel);
% handles.CLimBox
cb = uicontrol(f,'Style','checkbox',...
    'Units','normalized',...
    'TooltipString','CLim mode (auto/manual)',...
    'Tag','CLimBox',...
    'Value',0,...
    'Parent',centerPanel);
% Updating box values
pb.Value = UiValues.PatchBox;
mb.Value = UiValues.MaskBox;
% Resizing
pb.Position = [0 28/30 2/30 1.5/30];
mb.Position = [0 26.5/30 2/30 1.5/30];
cb.Position = [0 25/30 2/30 1.5/30];
td.Position = [.01 0 .25 2/30];
a.Position = [.12 .12 .8 .8];


% Traces Edition
% handles.TracesButton
h41 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','t',...
    'TooltipString','Traces Edition',...
    'Tag','TracesButton',...
    'Parent',rightPanel);
% Horizontal Label Checkbox
% handles.LabelBox
h42 = uicontrol(f,'Style','checkbox',...
    'Units','normalized',...
    'TooltipString','Horizontal Axis Label',...
    'Tag','LabelBox',...
    'Value',0,...
    'Parent',rightPanel);
% AutoScale Button
% handles.AutoScaleButton
h43 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','Auto',...
    'TooltipString','Autoscale',...
    'Tag','AutoScaleButton',...
    'Parent',rightPanel);
% Image Display 
% handles.CurrentImageDisplay
h44 = uicontrol(f,'Style','text',...
    'Units','normalized',...
    'BackgroundColor',panelColor,... 
    'HorizontalAlignment','right',...
    'TooltipString', 'Current Image',...
    'String',sprintf('%d/%d',CUR_IM,END_IM),...
    'Tag','CurrentImageDisplay',...
    'Parent',rightPanel);
% handles.MinusButton
h45 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','-',...
    'TooltipString','Zoom out',...
    'Tag','MinusButton',...
    'Parent',rightPanel);
% handles.PlusButton
h46 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','+',...
    'TooltipString','Zoom in',...
    'Tag','PlusButton',...
    'Parent',rightPanel);
% handles.RescaleButton
h47 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','<->',...
    'TooltipString','Rescale',...
    'Tag','RescaleButton',...
    'Parent',rightPanel);
% handles.SkipButton
h48 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','>>',...
    'TooltipString','Forward Step',...
    'Tag','SkipButton',...
    'Parent',rightPanel);
% handles.BackButton
h49 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','<<',...
    'TooltipString','Backward Step',...
    'Tag','BackButton',...
    'Parent',rightPanel);
% handles.TagButton
h50 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','Tags',...
    'TooltipString','Tag Selection',...
    'UserData',UiValues.TagSelection,...
    'Tag','TagButton',...
    'Parent',rightPanel);
% handles.nextTagButton
h51 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','T >>',...
    'TooltipString','Next Tag',...
    'Tag','nextTagButton',...
    'Parent',rightPanel);
% handles.prevTagButton
h52 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','<< T',...
    'TooltipString','Previous Tag',...
    'Tag','prevTagButton',...
    'Parent',rightPanel);

% handles.ScaleButton
h53 = uicontrol(f,'Style','togglebutton',...
    'Units','normalized',...
    'String','Scale',...
    'TooltipString','Scale Traces',...
    'Value',0,...
    'Tag','ScaleButton',...
    'Parent',rightPanel);
% handles.PlayToggle
h54 = uicontrol(f,'Style','toggle',...
    'Units','normalized',...
    'TooltipString','Play-Pause',...
    'String','>',...
    'Value',0,...
    'Tag','PlayToggle',...
    'Parent',rightPanel);
% handles.addTagButton
h55 = uicontrol(f,'Style','pushbutton',...
    'Units','normalized',...
    'String','T +',...
    'TooltipString','Add Tag',...
    'Tag','addTagButton',...
    'Parent',rightPanel);

% Resizing
b.Position = [.05 .1 .85 .8];
h41.Position = [.25/60 28/30 1.25/60 1.5/30];
h42.Position = [0 .01 2/60 1.4/30];

h43.Position = [56/60 3/30 3/60 1.5/30];
h44.Position = [50/60 -.5/30 9/60 2/30];
h45.Position = [56/60 28/30 3/60 1.5/30]; 
h46.Position = [56/60 26.5/30 3/60 1.5/30];
h47.Position = [56/60 25/30 3/60 1.5/30];
h48.Position = [56/60 22/30 3/60 1.5/30];
h49.Position = [56/60 23.5/30 3/60 1.5/30];
h50.Position = [56/60 20.5/30 3/60 1.5/30];
h51.Position = [56/60 17.5/30 3/60 1.5/30];
h52.Position = [56/60 19/30 3/60 1.5/30];
h53.Position = [56/60 6/30 3/60 1.5/30];
h54.Position = [56/60 4.5/30 3/60 1.5/30];
h55.Position = [56/60 16/30 3/60 1.5/30];

% Handles for argument passing
myhandles = guihandles(f);

f2 = figure('Units','normalized',...
    'Position',[.25*w0 .4*h0 .25*W .4*H],...
    'Color',panelColor,...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','none',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Tag','VideoFigure',...
    'Visible',UiValues.video_status,...
    'WindowStyle','normal',...
    'Name','Behavior');

myhandles.VideoFigure=f2;
%myhandles.VideoAxes=axes('Parent',f2);
%myhandles.VideoImage = image(zeros(10,10,3),'Parent',myhandles.VideoAxes);
myhandles.VideoAxes = axes('Parent',f2,'Tag','VideoAxes',...
    'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],...
        'Position',[.05 .05 .9 .9],'Box','on');


% Interactive Control
set(myhandles.MainFigure,'KeyPressFcn',{@mainFigure_keypressFcn,myhandles});
set(myhandles.MainFigure,'WindowScrollWheelFcn',{@mainFigure_windowscrollwheelFcn,myhandles});
set(myhandles.RightAxes,'ButtonDownFcn',{@rightPanel_clickFcn,myhandles});
set(myhandles.CenterAxes,'ButtonDownFcn',{@centerPanel_clickFcn,myhandles});
set(myhandles.MainFigure,'DeleteFcn',{@mainFigure_closeFcn,myhandles});
set(f2,'CloseRequestFcn',{@videoFigure_closereqFcn,myhandles});

% Menu Callback Attribution
set(myhandles.PrefMenu_Edit,'Callback',{@menuPreferences_Callback,myhandles});
% handles.FileMenu
set(myhandles.FileMenu_Manage,'Callback',{@menuFiles_Callback,myhandles});
set(myhandles.FileMenu_LoadRecList,'Callback',{@menuFiles_Callback,myhandles,2});
set(myhandles.FileMenu_SaveRecList,'Callback',{@menuFiles_SaveRec_Callback,myhandles});
set(myhandles.FileMenu_Next,'Callback',{@menuFiles_Next_Callback,myhandles});
set(myhandles.FileMenu_Prev,'Callback',{@menuFiles_Prev_Callback,myhandles});
set(myhandles.FileMenu_SaveUFParams,'Callback','saving_UFParams(fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).dir_fus),fullfile(DIR_SAVE,FILES(CUR_FILE).nlab))');
set(myhandles.FileMenu_Save,'Callback',{@mainFigure_saveFcn,myhandles});

% handles.ImportMenu
set(myhandles.FileMenu_Import,'Callback',{@menuFiles_Callback,myhandles,1});
set(myhandles.ImportMenu_Doppler,'Callback','import_DopplerFilm(FILES(CUR_FILE),myhandles,1);');
set(myhandles.ImportMenu_ReferenceTime,'Callback','import_reference_time(FILES(CUR_FILE),myhandles);');
set(myhandles.ImportMenu_TimeTags,'Callback','import_time_tags(FILES(CUR_FILE).fullpath,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));');
set(myhandles.ImportMenu_Video,'Callback','import_video(fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).video),myhandles);');
set(myhandles.ImportMenu_ImportConfig,'Callback','import_lfpconfig(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles);');
% set(myhandles.ImportMenu_LFPTraces,'Callback','import_lfptraces(FILES(CUR_FILE),myhandles);');
% set(myhandles.ImportMenu_Regions,'Callback','import_regions(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),FILES(CUR_FILE).recording,myhandles);');
% set(myhandles.ImportMenu_ExternalFiles,'Callback','import_externalfiles(FILES(CUR_FILE).fullpath,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles);');

set(myhandles.ImportMenu_ReloadDoppler,'Callback','load_global_image(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles.CenterPanelPopup.Value);actualize_plot(myhandles);');
set(myhandles.ImportMenu_ReloadGraphic,'Callback','load_graphicdata(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles);');
% set(myhandles.ImportMenu_LoadTraces,'Callback','load_lfptraces(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles);');
% set(myhandles.ImportMenu_LoadRegions,'Callback','load_regions(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles);');
set(myhandles.ImportMenu_ActualizeTraces,'Callback','actualize_traces(myhandles);');

% handles.EditMenu
set(myhandles.EditMenu_Edition,'Callback',{@menuEdit_TracesEdition_Callback,myhandles.RightAxes,myhandles});
set(myhandles.EditMenu_TimeTagEdition,'Callback','menuEdit_TimeTagEdition_Callback(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles);');
set(myhandles.EditMenu_TimeGroupEdition,'Callback','menuEdit_TimeGroupEdition_Callback(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles);');
set(myhandles.EditMenu_LFPConfig,'Callback','menuEdit_LFPConfig_Callback(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),myhandles);');
set(myhandles.EditMenu_Delete_All,'Callback',{@menuEdit_DeleteAll_Callback,myhandles});
set(myhandles.EditMenu_Delete_Pixels,'Callback',{@menuEdit_DeleteLines_Callback,myhandles,1});
set(myhandles.EditMenu_Delete_Regions,'Callback',{@menuEdit_DeleteLines_Callback,myhandles,2});
set(myhandles.EditMenu_Delete_Spiko,'Callback',{@menuEdit_DeleteLines_Callback,myhandles,3});

% handles.DisplayMenu
set(myhandles.DisplayMenu_Video,'Callback',{@menuDisplay_Video_Callback,myhandles});
set(myhandles.DisplayMenu_TagSelection,'Callback',{@menuDisplay_TimeTagSelection_Callback,myhandles});
set(myhandles.DisplayMenu_TimeGroupSelection,'Callback',{@menuDisplay_TimeGroupSelection_Callback,myhandles});

% handles.SynthesisMenu
set(myhandles.SynthesisMenu_Batch,'Callback',{@batch_generalscript,myhandles});
set(myhandles.SynthesisMenu_Correlation,'Callback','synthesis_CorrelationAnalysis();');
set(myhandles.SynthesisMenu_Region,'Callback','synthesis_RegionStatistics();');
set(myhandles.SynthesisMenu_Display,'Callback','synthesis_Global_Display();');
set(myhandles.SynthesisMenu_Statistics,'Callback','synthesis_fUS_Statistics();');
set(myhandles.SynthesisMenu_PeakDetection,'Callback','synthesis_PeakDetection();');
set(myhandles.SynthesisMenu_CrossCorrelation,'Callback','synthesis_CrossCorrelation();');
set(myhandles.SynthesisMenu_VascularSurge,'Callback','synthesis_VascularSurges();');
set(myhandles.SynthesisMenu_PeakCount,'Callback','synthesis_PeakCount();');

% handles.ExportMenu
set(myhandles.ExportMenu_IMOfile,'Callback','export_imofile(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),SEED_SPIKO,FILES(CUR_FILE).session);');
set(myhandles.ExportMenu_Regions,'Callback','export_patches(myhandles);');
set(myhandles.ExportMenu_TimeTags,'Callback','export_time_tags(FILES(CUR_FILE).fullpath,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));');


% Control Callback Attribution
set(myhandles.FileSelectPopup,'Callback', {@fileSelectionPopup_Callback,myhandles});
set(myhandles.PlayToggle,'Callback',{@buttonPlay_Callback,myhandles});
set(myhandles.MinusButton,'Callback',{@buttonMinus_Callback,myhandles});
set(myhandles.PlusButton,'Callback',{@buttonPlus_Callback,myhandles});
set(myhandles.BackButton,'Callback', {@buttonBack_Callback,myhandles});
set(myhandles.SkipButton,'Callback', {@buttonSkip_Callback,myhandles});
set(myhandles.RescaleButton,'Callback', {@buttonRescale_Callback,myhandles});
set(myhandles.CenterPanelPopup,'Callback',{@centerPanel_controlCallback,myhandles});
set(myhandles.RightPanelPopup,'Callback',{@rightPanel_controlCallback,myhandles});
set(myhandles.ProcessButton,'Callback',{@processButtonCallback,myhandles});
set(myhandles.DisplayButton,'Callback',{@displayButtonCallback,myhandles});
set(myhandles.LabelBox,'Callback',{@boxLabel_Callback,myhandles});
set(myhandles.AutoScaleButton,'Callback',{@buttonAutoScale_Callback,myhandles});
set(myhandles.TracesButton,'Callback',{@menuEdit_TracesEdition_Callback,myhandles.RightAxes,myhandles});
set(myhandles.TagButton,'Callback',{@menuDisplay_TimeTagSelection_Callback,myhandles});
set(myhandles.prevTagButton,'Callback',{@menuEdit_prevTag_Callback,myhandles});
set(myhandles.nextTagButton,'Callback',{@menuEdit_nextTag_Callback,myhandles});
set(myhandles.addTagButton,'Callback',{@menuEdit_addTag_Callback,myhandles});
set(myhandles.ScaleButton,'Callback',{@buttonScale_Callback,myhandles.RightAxes});
set(myhandles.PatchBox,'Callback',{@boxPatch_Callback,myhandles});
set(myhandles.MaskBox,'Callback',{@boxMask_Callback,myhandles});
set(myhandles.CLimBox,'Callback',{@boxCLim_Callback,myhandles});

end