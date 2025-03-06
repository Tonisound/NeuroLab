function f2 = synthesis_CorrelationAnalysis()
% Time Tag Selection Callback

%global FILES;

f2 = figure('Units','normalized',... 
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Position',[.1 .1 .8 .6],...
    'Name','Correlation Analysis Synthesis');
f2.UserData.CurrentPanel=1;
colormap(f2,'jet');

iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 .1],...
    'Tag','InfoPanel',...
    'Parent',f2);

% Texts and Edits
uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String','fUS_Correlation','Tag','Text1','Position',[.01 .6 .18 .3]);
uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String','Current Panel : 1','Tag','Text2','Position',[.01 .1 .09 .3]);
uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String','Current Ref : 1','Tag','Text3','Position',[.11 .1 .09 .3]);


uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String','2','TooltipString','# Panels','Tag','Edit1','Position',[.4 .2 .04 .6]);
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String','2','TooltipString','# horizontal axes','Tag','Edit2','Position',[.5 .05 .04 .4]);
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String','2','TooltipString','# vertical axes','Tag','Edit3','Position',[.5 .55 .04 .4]);

uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'Value',1,'TooltipString','Link Axes','Tag','Checkbox1','Position',[.45 .7 .02 .3]);
uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'Value',1,'TooltipString','Labels','Tag','Checkbox2','Position',[.45 .35 .02 .3]);
uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'Value',1,'TooltipString','Autoscale','Tag','Checkbox3','Position',[.45 0 .02 .3]);
uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'Value',0,'TooltipString','Resample','Tag','Checkbox4','Position',[.475 .7 .02 .3]);

% Buttons 
uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset','Position',[.8 .5 .1 .5]);
uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute','Position',[.9 .5 .1 .5]);
uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save','Tag','ButtonSave','Position',[.8 0 .1 .5]);
uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Batch Save','Tag','ButtonBatch','Position',[.9 0 .1 .5]);

% Creating uitabgroup

handles2 = guihandles(f2);
reset_Callback([],[],handles2);

end

function reset_Callback(~,~,handles)
% Resets figures depending on button values

initialize_mainPanel(handles);

% Reattributing callbacks
handles2 = guihandles(handles.MainFigure);

% Callback attribution
handles.ButtonReset.Callback = {@reset_Callback,handles2};
handles.ButtonCompute.Callback = {@compute_Callback,handles2};
handles.MainFigure.KeyPressFcn={@f_keypress_fcn,handles2};
handles.Checkbox1.Callback = {@checkbox1_Callback,handles2};
handles.Checkbox2.Callback = {@checkbox2_Callback,handles2};
handles.Checkbox3.Callback = {@checkbox3_Callback,handles2};
handles.Checkbox4.Callback = {@checkbox4_Callback,handles2};

end

function initialize_mainPanel(handles)

%Deleting previous panels
panels = findobj(handles.MainFigure,'Type','uipanel','-not','Tag','InfoPanel');
n_panels = str2double(handles.Edit1.String);

if size(panels,1)/2<n_panels
    %create
    for i=size(panels,1)/2+1:n_panels
        pu_panel = uipanel('FontSize',12,...
            'Units','normalized',...
            'Tag',sprintf('PopupPanel%d',i),...
            'Parent',handles.MainFigure);
        pu_panel.UserData.number = i;
        panel = uipanel('FontSize',12,...
            'Units','normalized',...
            'Tag',sprintf('MainPanel%d',i),...
            'Parent',handles.MainFigure);
        panel.UserData.number = i;
        fill_mainPanel(pu_panel,i,handles);
    end
    

elseif size(panels,1)/2>n_panels
    %delete
    for i=n_panels+1:size(panels,1)/2
        panel = findobj(handles.MainFigure,'Tag',sprintf('MainPanel%d',i));
        delete(panel);
        pu_panel = findobj(handles.MainFigure,'Tag',sprintf('PopupPanel%d',i));
        delete(pu_panel);
    end
end

% Adjust Position
panels = findobj(handles.MainFigure,'Type','uipanel','-not','Tag','InfoPanel');
N = size(panels,1)/2;
for i =1:N
    panel = findobj(handles.MainFigure,'Tag',sprintf('MainPanel%d',i));
    pu_panel = findobj(handles.MainFigure,'Tag',sprintf('PopupPanel%d',i));
    panel.Position = [(i-1)/N .1 1/N .75];
    pu_panel.Position = [(i-1)/N .85 1/N .15];
end


end

function fill_mainPanel(panel,val,handles)

global SEED_SWL;

p1 = uicontrol('Units','normalized','Style','popup','HorizontalAlignment','left','Parent',panel,...
     'String','REC_LIST','Tag','Popup1','TooltipString','Recording List Selection','Position',[0 0.65 1 .3]);
p2 = uicontrol('Units','normalized','Style','popup','HorizontalAlignment','left','Parent',panel,...
     'String','FILES','Tag','Popup2','TooltipString','File Selection','Position',[0 0.35 1 .3]);
p3 = uicontrol('Units','normalized','Style','popup','HorizontalAlignment','left','Parent',panel,...
     'String','REFS','Tag','Popup3','TooltipString','Reference Selection','Position',[0 0 .33 .3]);
p4 = uicontrol('Units','normalized','Style','popup','HorizontalAlignment','left','Parent',panel,...
     'String','','Tag','Popup4','TooltipString','Time Group Selection','Position',[.335 0 .33 .3]);
p5 = uicontrol('Units','normalized','Style','popup','HorizontalAlignment','left','Parent',panel,...
     'String','RT Pattern|Rmax|Tmax|Functional Connectivity|*.mat','Value',5,...
     'Tag','Popup5','TooltipString','Pattern Selection','Position',[.67 0  .33 .3]);
all_popups = [p1;p2;p3;p4;p5];

rec_list = dir(fullfile(SEED_SWL,'*.swl'));
p1.String = {rec_list.name};
p1.Callback = {@update_popup1,all_popups,handles};
p2.Callback = {@update_popup2,all_popups,handles};
p3.Callback = {@update_popup3,all_popups,handles};
p4.Callback = {@update_popup5,all_popups,handles};
p5.Callback = {@update_popup5,all_popups,handles};

switch val
    case 1
        ind_keep = ~(cellfun('isempty',strfind(p1.String,'BURST_CORONAL.swl')));
    case 2
        ind_keep = ~(cellfun('isempty',strfind(p1.String,'REM_CORONAL.swl')));
    otherwise
        ind_keep = 0;
end
if sum(ind_keep)==1
    p1.Value = find(ind_keep==1);
end
update_popup1(p1,[],all_popups,handles);
 
end

function update_popup1(hObj,~,all_popups,handles)

p2 = all_popups(2);
swl_file = char(strtrim(hObj.String(hObj.Value,:)));

files = read_recordinglist(swl_file);
%p2.String = [{'*'},{files.eeg}];
%p2.Value = 2;
p2.String = {files.eeg};
p2.Value = 1;
update_popup2(p2,[],all_popups,handles);

end

function update_popup2(hObj,~,all_popups,handles)

global DIR_STATS;
eeg_file = char(strtrim(hObj.String(hObj.Value,:)));
p3 = all_popups(3);

all_refs = dir(fullfile(DIR_STATS,'fUS_Correlation',eeg_file));
ind_keep=ones(size(all_refs));
for i =1:length(all_refs)
    if strcmp(all_refs(i).name(1),'.')||~isdir(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,all_refs(i).name))
        ind_keep(i)=0;
    end
end
all_refs=all_refs(ind_keep==1);

if ~isempty(all_refs)
    p3.String = {all_refs.name};
    p3.Value = 1;
    update_popup3(p3,[],all_popups,handles);
else
    p3.String = {''};
end


end

function update_popup3(hObj,~,all_popups,handles)

global DIR_STATS;
p2 = all_popups(2);
p4 = all_popups(4);
eeg_file = char(strtrim(p2.String(p2.Value,:)));
ref_file = char(strtrim(hObj.String(hObj.Value,:)));

all_folds = dir(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file));
ind_keep=ones(size(all_folds));
for i =1:length(all_folds)
    if strcmp(all_folds(i).name(1),'.')||~isdir(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file,all_folds(i).name))
        ind_keep(i)=0;
    end
end
all_folds=all_folds(ind_keep==1);

if ~isempty(all_folds)
    p4.String = {all_folds.name};
    update_popup5(p4,[],all_popups,handles);
else
    p4.String = {''};
end

end

function update_popup5(hObj,~,all_popups,handles)

global DIR_STATS;
p2 = all_popups(2);
p3 = all_popups(3);
p4 = all_popups(4);
p5 = all_popups(5);

eeg_file = char(strtrim(p2.String(p2.Value,:)));
ref_file = char(strtrim(p3.String(p3.Value,:)));
folder = char(strtrim(p4.String(p4.Value,:)));

load(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file,folder,'UF.mat'),'UF');
%UF = load(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file,folder,'UF.mat'),'UF');
switch strtrim(p5.String(p5.Value,:))
    
    case 'RT Pattern'
        S = load(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file,folder,'Correlation_pattern.mat'),'RT_pattern');
        
    case 'Tmax'
        S = load(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file,folder,'Correlation_pattern.mat'),'Tmax_map');

    case 'Rmax'
        S = load(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file,folder,'Correlation_pattern.mat'),'Rmax_map');

    case 'Functional Connectivity'
        S = load(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file,folder,'fCorrelation.mat'),'Cor');
        
    case '*.mat',
        S1 = load(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file,folder,'fCorrelation.mat'),'Cor');
        S2 = load(fullfile(DIR_STATS,'fUS_Correlation',eeg_file,ref_file,folder,'Correlation_pattern.mat'));
        S.Cor=S1.Cor;
        S.RT_pattern=S2.RT_pattern;
        S.Tmax_map=S2.Tmax_map;
        S.Rmax_map=S2.Rmax_map;       
end

%Storing S and UF in Panel.UserData
hObj.Parent.UserData.S = S;
hObj.Parent.UserData.UF = UF;

val = hObj.Parent.UserData.number;
p =findobj(handles.MainFigure,'Tag',sprintf('MainPanel%d',val));
p.UserData.S = S;
p.UserData.UF = UF;

compute_Callback([],[],handles,hObj.Parent.UserData.number);

end

function compute_Callback(~,~,handles,val)

if nargin<4
    val = 0;
end

switch val
    case 0
        %disp('Update all axes');
        n_panels = length(findobj(handles.MainFigure,'Type','uipanel','-not','Tag','InfoPanel'))/2;
        all_panels =[];
        for i = 1:n_panels
            panel = findobj(handles.MainFigure,'Tag',sprintf('MainPanel%d',i));
            all_panels =[all_panels;panel];
        end
    otherwise
        %fprintf('Update panel %d\n',val);
        all_panels = findobj(handles.MainFigure,'Tag',sprintf('MainPanel%d',val));
end

for i=1:length(all_panels)
    if isempty(all_panels(i).UserData)
        warning('No available data to display (Panel %d).\n',i);
        continue;
    end
    
    % delete previous axes
    delete(all_panels(i).Children);
    
    UF = all_panels(i).UserData.UF;
    lags_labels={};
    for k =1:2:length(UF.lags)
        lags_labels(k) = {sprintf('%.1f',UF.step*UF.lags(k))};
    end
    S = all_panels(i).UserData.S;
    x = str2double(handles.Edit2.String);
    y = str2double(handles.Edit3.String);
    
    % Plotting
    f = fieldnames(S);
    for j=1:size(f,1)
        im = getfield(S,char(f(j)));
        if size(f,1)>1
            ax = subplot(x,y,j,'Parent',all_panels(i));
        else
            ax = axes('Parent',all_panels(i),'Position',[.1 .1 .8 .8]);
        end
        
        switch char(f(j))
            case 'RT_pattern';
                imagesc(im(2:end,:),'Parent',ax,'XData',UF.step*UF.lags);
                ax.Title.String = 'CBV pattern';
                ax.UserData.OriginalData = im(2:end,:);
                
            case 'Cor';
                %index = find(UF.lags==0);
                imagesc(im(2:end,2:end,UF.lags==0),'Parent',ax);
                ax.Title.String = 'Connectivity (0-lag)';
                
            case {'Rmax_map','Tmax_map'}
                imagesc(im,'Parent',ax);
                ax.Title.String = strrep(char(f(j)),'_','-');
        end
        colorbar;
        ax.Tag = sprintf('Ax%d',j);
        ax.TickLength=[0,.25];      
    end
    
end

% Linking axes
checkbox1_Callback(handles.Checkbox1,[],handles);

% Changing Labels
checkbox2_Callback(handles.Checkbox2,[],handles);

% Autoscale
checkbox3_Callback(handles.Checkbox3,[],handles);

% Resample
checkbox4_Callback(handles.Checkbox4,[],handles);

end

function checkbox4_Callback(hObj,~,handles)

all_axes = findobj(handles.MainFigure,'Type','axes');
ind_keep = zeros(size(all_axes));
for i=1:length(all_axes)
    if strcmp(all_axes(i).Title.String,'CBV pattern')
        ind_keep(i)=1;
    end
end
all_axes = flipud(all_axes(ind_keep==1));

if isempty(all_axes)
    return;
end

for i=1:length(all_axes)
    ax = all_axes(i);
    UF = ax.Parent.UserData.UF;
    im = findobj(ax,'Type','Image');
    original_im = ax.UserData.OriginalData;
    
    if hObj.Value
        t_samp = 0.01;%s
        factor = round(UF.step/t_samp);
        im_resamp = resample(original_im',factor,1)';
        im_resamp = im_resamp(:,1:end-factor+1);
        lags_resamp = resample(UF.lags,factor,1);
        lags_resamp = lags_resamp(:,1:end-factor+1);
        im.CData = im_resamp;
        im.XData = lags_resamp*UF.step;
        %im
        %ax.XLim = [lags_resamp(1)*UF.step,lags_resamp(end)*UF.step];
    else
        im.CData = original_im;
        im.XData = UF.lags*UF.step;
        %ax.XLim = [UF.lags(1)*UF.step,UF.lags(end)*UF.step];
    end
    
%     load('A.mat');
%     [~,ind1] = min((A_REM_X-A_RUN_X(1)).^2);
%     A_REM = A_REM(:,ind1:ind1+min(l1,l2)-1);
end

end

function checkbox3_Callback(hObj,~,handles)

all_axes = findobj(handles.MainFigure,'Type','axes');

for i =1:length(all_axes)
    ax = all_axes(i);
    if hObj.Value
        switch ax.Title.String
            case {'CBV pattern','Connectivity (0-lag)','Rmax-map'};
                ax.CLimMode = 'auto';
                %ax.CLim = [-1;1];
        end
    else
        switch ax.Title.String
            case {'CBV pattern','Connectivity (0-lag)','Rmax-map'};
                ax.CLimMode = 'manual';
                ax.CLim = [-1;1];
        end
    end
end

end

function checkbox2_Callback(hObj,~,handles)

all_axes = findobj(handles.MainFigure,'Type','axes');

for i =1:length(all_axes)
    ax = all_axes(i);
    UF = ax.Parent.UserData.UF;
    if hObj.Value
        switch ax.Title.String
            case {'CBV pattern'};
                %ax.XTick= 1:length(lags_labels);
                %ax.XTickLabel = lags_labels;
                ax.XLabel.String = 'Lag(s)';
                ax.YTick= 1:length(UF.labels(2:end));
                ax.YTickLabel = UF.labels(2:end);
            case {'Connectivity (0-lag)'};
                ax.YTick= 1:length(UF.labels(2:end));
                ax.YTickLabel = UF.labels(2:end);
                ax.XTick= 1:length(UF.labels(2:end));
                ax.XTickLabel = UF.labels(2:end);
                ax.XTickLabelRotation = 90;
        end
    else
        switch ax.Title.String
            case {'CBV pattern'};
                ax.XLabel.String = 'Lag(s)';
                ax.YTick=[];
                ax.YTickLabel = '';
            case {'Connectivity (0-lag)'};
                ax.YTick= [];
                ax.YTickLabel = '';
                ax.XTick= [];
                ax.XTickLabel = '';
        end
    end
end

end

function checkbox1_Callback(hObj,~,handles)

all_axes = findobj(handles.MainFigure,'Type','axes');
ind_keep = zeros(size(all_axes));
for i=1:length(all_axes)
    if strcmp(all_axes(i).Title.String,'CBV pattern')
        ind_keep(i)=1;
    end
end
all_axes = flipud(all_axes(ind_keep==1));

if isempty(all_axes)
    return;
end

if hObj.Value
    linkaxes(all_axes,'x');
else
    linkaxes(all_axes,'off');
    for k=1:length(all_axes)
        im = findobj(all_axes(k),'Type','Image');
        all_axes(k).XLim = [im.XData(1), im.XData(end)];
    end
end

end

function f_keypress_fcn(hObj,evnt,handles)

%hObj.UserData.flag
n_panels = str2double(handles.Edit1.String);

switch evnt.Key

    case 'rightarrow'
        if hObj.UserData.CurrentPanel<n_panels
            hObj.UserData.CurrentPanel = hObj.UserData.CurrentPanel+1;
        end
        handles.Text2.String = sprintf('Current Panel : %d',hObj.UserData.CurrentPanel);
        panel = findobj(handles.MainFigure,'Tag',sprintf('PopupPanel%d',hObj.UserData.CurrentPanel));
        pu = findobj(panel,'Tag','Popup3');
        handles.Text3.String = sprintf('Current Ref : %d',pu.Value);
        
    case 'leftarrow'
        if hObj.UserData.CurrentPanel>1
            hObj.UserData.CurrentPanel = hObj.UserData.CurrentPanel-1;
        end
        handles.Text2.String = sprintf('Current Panel : %d',hObj.UserData.CurrentPanel);
        panel = findobj(handles.MainFigure,'Tag',sprintf('PopupPanel%d',hObj.UserData.CurrentPanel));
        pu = findobj(panel,'Tag','Popup3');
        handles.Text3.String = sprintf('Current Ref : %d',pu.Value);
        
    case 'uparrow'
        panel = findobj(handles.MainFigure,'Tag',sprintf('PopupPanel%d',hObj.UserData.CurrentPanel));
        pu = findobj(panel,'Tag','Popup3');
        if pu.Value>1
            pu.Value=pu.Value-1;
        end
        handles.Text3.String = sprintf('Current Ref : %d',pu.Value);
    case 'downarrow'
        panel = findobj(handles.MainFigure,'Tag',sprintf('PopupPanel%d',hObj.UserData.CurrentPanel));
        pu = findobj(panel,'Tag','Popup3');
        if pu.Value<size(pu.String,1)
            pu.Value=pu.Value+1;
        end
        handles.Text3.String = sprintf('Current Ref : %d',pu.Value);
    case 'p'
        panel = findobj(handles.MainFigure,'Tag',sprintf('PopupPanel%d',hObj.UserData.CurrentPanel));
        pu = findobj(panel,'Tag','Popup2');
        if pu.Value>1
            pu.Value=pu.Value-1;
        end
    case 'n'
        panel = findobj(handles.MainFigure,'Tag',sprintf('PopupPanel%d',hObj.UserData.CurrentPanel));
        pu = findobj(panel,'Tag','Popup2');
        if pu.Value<size(pu.String,1)
            pu.Value=pu.Value+1;
        end
end

p1 = findobj(panel,'Tag','Popup1');
p2 = findobj(panel,'Tag','Popup2');
p3 = findobj(panel,'Tag','Popup3');
p4 = findobj(panel,'Tag','Popup4');
p5 = findobj(panel,'Tag','Popup5');
all_popups = [p1;p2;p3;p4;p5];

switch evnt.Key
    case {'leftarrow','rightarrow','downarrow','uparrow'}
        update_popup3(p3,[],all_popups,handles);
    case {'p','n'}
        update_popup2(p2,[],all_popups,handles);
end

end
