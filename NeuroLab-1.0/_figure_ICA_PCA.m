function figure_ICA_PCA(myhandles)

global DIR_SAVE START_IM END_IM FILES CUR_FILE;

f2 = figure('Units','characters',...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'MenuBar','none',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Independent Component Analysis');
clrmenu(f2);

% Information Panel
iP = uipanel('Units','characters',...
    'bordertype','etchedin',...
    'Tag','InfoPanel',...
    'Parent',f2);

uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('File : %s',FILES(CUR_FILE).gfus),'Tag','Text1');
uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('Source : %s',myhandles.CenterPanelPopup.String(myhandles.CenterPanelPopup.Value,:)),...
    'Tag','Text2');

e1 = uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','START_IM',...
    'Parent',iP,'String',START_IM,'Tag','Edit1');
e1.UserData = myhandles.TimeDisplay.UserData;
uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('%s',myhandles.TimeDisplay.UserData(START_IM,:)),...
    'Tag','Text3');
e2 = uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',END_IM,'Tag','Edit2','Tooltipstring','END_IM');
e2.UserData = myhandles.TimeDisplay.UserData;
uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('%s',myhandles.TimeDisplay.UserData(END_IM,:)),...
    'Tag','Text4');

e3 = uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',4,'Tag','Edit3','Tooltipstring','# Channels');
b3 = uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'Value',1,'ToolTipString','Cursor Extent: Single/Multiple Axes','Tag','Box3');
b4 = uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'Value',1,'ToolTipString','Link/Unlink Axes','Tag','Box4');

re = uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset');
re.UserData.CenterAxes = myhandles.CenterAxes;
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Load Data','Tag','ButtonLoad');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Compute ICA','Tag','ButtonICA');
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'Value',0,'ToolTipString','Use Stored Covariance Matrix','Tag','Box1');
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'Value',1,'ToolTipString','Display Covariance & Components','Tag','Box2');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Reconstruct Data','Tag','ButtonRecon');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Display Reconstruction','Tag','ButtonDisp');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Save','Tag','ButtonSave');

copyobj(myhandles.PlusButton,iP);
copyobj(myhandles.MinusButton,iP);
copyobj(myhandles.RescaleButton,iP);
copyobj(myhandles.SkipButton,iP);
copyobj(myhandles.BackButton,iP);
copyobj(myhandles.TagButton,iP);
copyobj(myhandles.nextTagButton,iP);
copyobj(myhandles.prevTagButton,iP);

% Number of Components display
channels = str2double(e3.String);

% Left Panel
lP = uipanel('Units','characters',...
    'bordertype','etchedin',...
    'Tag','LeftPanel',...
    'Parent',f2);

uicontrol('Units','characters','Style','popupmenu','Parent',lP,...
    'String','Original Data','Tag','PopupLeft1');
uicontrol('Units','characters','Style','popupmenu','Parent',lP,...
    'String','<0>','Tag','PopupLeft2');

for i=1:channels
    ax = subplot(channels,1,i,'Parent',lP,'Tag',sprintf('Ax%d',i));
    ax.XLim = [START_IM,END_IM];
    %set(axes_left,'ButtonDownFcn',{@template_axes_clickFcn,b3.Value});
end

% Right Panel
rP = uipanel('Units','characters',...
    'bordertype','etchedin',...
    'Tag','RightPanel',...
    'Parent',f2);

uicontrol('Units','characters','Style','popupmenu','Parent',rP,...
    'String','<0>','Tag','PopupRight1','Enable','off');
uicontrol('Units','characters','Style','popupmenu','Parent',rP,...
    'String','<0>','Tag','PopupRight2');

for i=1:channels
    ax = subplot(channels,1,i,'Parent',rP,'Tag',sprintf('Ax%d',i));
    ax.XLim = [START_IM,END_IM];
    %set(axes_right,'ButtonDownFcn',{@template_axes_clickFcn,b3.Value});
end

handles2 = guihandles(f2);

% Resize Function Attribution
set(handles2.MainFigure,'ResizeFcn',{@resize_Figure,handles2});
set(handles2.LeftPanel,'ResizeFcn',{@resize_lPanel,handles2});
set(handles2.RightPanel,'ResizeFcn',{@resize_rPanel,handles2});
set(handles2.InfoPanel,'ResizeFcn',{@resize_infoPanel,handles2});
set(f2,'Position',[30 30 120 40]);

% Interactive Control
all_axes = findobj(handles2.MainFigure,'Type','Axes');
set(all_axes,'ButtonDownFcn',{@template_axes_clickFcn,b3.Value});
set(handles2.PlusButton,'Callback',{@template_buttonPlus_Callback,all_axes(1)});
set(handles2.MinusButton,'Callback',{@template_buttonMinus_Callback,all_axes(1)});
set(handles2.RescaleButton,'Callback',{@template_buttonRescale_Callback,all_axes(1)});
set(handles2.SkipButton,'Callback',{@template_buttonSkip_Callback,all_axes(1)});
set(handles2.BackButton,'Callback',{@template_buttonBack_Callback,all_axes(1)});
set(handles2.TagButton,'Callback',{@custom_button_TagSelection_Callback,all_axes(1),handles2});
set(handles2.nextTagButton,'Callback',{@custom_button_nextTag_Callback,all_axes(1),handles2});
set(handles2.prevTagButton,'Callback',{@custom_button_prevTag_Callback,all_axes(1),handles2});

% Link all axes
if b4.Value
    linkaxes(all_axes,'x');
end

% Callback Function Attribution
set(handles2.ButtonReset,'Callback',{@reset_Callback,handles2});
set(handles2.ButtonLoad,'Callback',{@load_data,handles2});
handles2.ButtonLoad.UserData.Pixels = findobj(myhandles.CenterAxes,'Tag','Pixel');
handles2.ButtonLoad.UserData.Boxes = findobj(myhandles.CenterAxes,'Tag','Box');
handles2.ButtonLoad.UserData.Regions = findobj(myhandles.CenterAxes,'Tag','Region');
set(handles2.ButtonICA,'Callback',{@compute_ICA_PCA,handles2});
set(handles2.Edit1,'Callback',{@edit1_Callback,handles2});
set(handles2.Edit1,'KeyPressFcn',@keypress_increment_decrement);
set(handles2.Edit2,'Callback',{@edit2_Callback,handles2});
set(handles2.Edit2,'KeyPressFcn',@keypress_increment_decrement);
set(handles2.Box2,'Callback',{@box2_Callback,handles2});
set(handles2.Box4,'Callback',{@box4_Callback,handles2});
set(handles2.ButtonRecon,'Callback',{@reconstruct_data,handles2});
set(handles2.ButtonDisp,'Callback',{@display_reconstruction,handles2});
set(handles2.ButtonSave,'Callback',{@save_reconstruction,handles2});

% Direct Load
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'ICA_PCA.mat'),'file')
    
    set(f2,'Pointer','watch');
    drawnow;
    % Setting Button Load for Browsing
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'ICA_PCA.mat'),'data','channel_title','hint_label','r_label','ind_real','ind_null','IM_vect','im','data_ica','data_pca','data_rec_ica','data_rec_pca');
    handles2.ButtonLoad.UserData.data = data;
    handles2.ButtonLoad.UserData.channel_title = channel_title;
    handles2.ButtonLoad.UserData.hint_label = hint_label;
    handles2.ButtonLoad.UserData.r_label = r_label;
    handles2.ButtonLoad.UserData.ind_real = ind_real;
    handles2.ButtonLoad.UserData.ind_null = ind_null;
    handles2.ButtonLoad.UserData.IM_vect = IM_vect;
    handles2.ButtonLoad.UserData.im = im;

    handles2.ButtonICA.UserData.data_ica = data_ica;
    handles2.ButtonICA.UserData.data_pca = data_pca;
    handles2.ButtonRecon.UserData.data_rec_pca = data_rec_pca;
    handles2.ButtonRecon.UserData.data_rec_ica = data_rec_ica;
    
    % Setting PopupLeft for Browsing
    handles2.PopupLeft1.String = 'Original Data|ICA Components|PCA Components|Reconstructed Data ICA|Reconstructed Data PCA';
    handles2.PopupLeft1.Value = 1;
    handles2.PopupLeft1.Callback = {@update_popup,handles2};
    handles2.PopupLeft2.Callback = {@update_data,handles2};
    update_popup(handles2.PopupLeft1,[],handles2);

    % Setting PopupRight for Browsing
    handles2.PopupRight1.String = 'Original Data|ICA Components|PCA Components|Reconstructed Data ICA|Reconstructed Data PCA';
    handles2.PopupRight1.Value = 4;
    handles2.PopupRight1.Enable = 'on';
    handles2.PopupRight1.Callback = {@update_popup,handles2};
    handles2.PopupRight2.Callback = {@update_data,handles2};
    update_popup(handles2.PopupRight1,[],handles2)
    set(f2,'Pointer','arrow');
    
else
    load_data(handles2.ButtonLoad,[],handles2);
end

end

function resize_Figure(~,~,handles)

% Main Figure resize function
fpos = get(handles.MainFigure,'Position');
set(handles.LeftPanel,'Position',[0 2*fpos(4)/30 fpos(3)/2 28*fpos(4)/30]);
set(handles.RightPanel,'Position',[fpos(3)/2 2*fpos(4)/30 fpos(3)/2 28*fpos(4)/30]);
set(handles.InfoPanel,'Position',[0 0 fpos(3) 2*fpos(4)/30]);

end

function resize_infoPanel(~,~,handles)

ipos = get(handles.InfoPanel,'Position');
handles.Text1.Position = [0     ipos(4)/2-.5    ipos(3)/5   ipos(4)/2];
handles.Text2.Position = [0     -.5             ipos(3)/5   ipos(4)/2];
handles.Edit1.Position = [ipos(3)/5     ipos(4)/2   ipos(3)/20   ipos(4)/2];
handles.Edit2.Position = [ipos(3)/5     0           ipos(3)/20   ipos(4)/2];
handles.Text3.Position = [ipos(3)/4     ipos(4)/2-.5            ipos(3)/10   ipos(4)/2];
handles.Text4.Position = [ipos(3)/4     -.5            ipos(3)/10   ipos(4)/2];

handles.PlusButton.Position = [3.5*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.MinusButton.Position = [4*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.RescaleButton.Position = [4.5*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.TagButton.Position = [5*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.SkipButton.Position = [3.5*ipos(3)/10     0             ipos(3)/20   ipos(4)/2];
handles.BackButton.Position = [4*ipos(3)/10     0             ipos(3)/20   ipos(4)/2];
handles.nextTagButton.Position = [4.5*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];
handles.prevTagButton.Position = [5*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];

handles.ButtonLoad.Position = [4.4*ipos(3)/8+1     ipos(4)/2-.25      ipos(3)/8-2   ipos(4)/2];
handles.ButtonICA.Position = [4.4*ipos(3)/8+1     0      ipos(3)/8-2   ipos(4)/2];

handles.Box1.Position = [5.3*ipos(3)/8+1     ipos(4)/2-.25      ipos(3)/50   ipos(4)/2];
handles.Box2.Position = [5.3*ipos(3)/8+1     0         ipos(3)/50   ipos(4)/2];
handles.ButtonRecon.Position = [5.5*ipos(3)/8+1     ipos(4)/2-.25      1.25*ipos(3)/8-2   ipos(4)/2];
handles.ButtonDisp.Position = [5.5*ipos(3)/8+1     0      1.25*ipos(3)/8-2   ipos(4)/2];

handles.Edit3.Position = [6.68*ipos(3)/8+1     ipos(4)/2-.1           ipos(3)/25   ipos(4)/2-.25];
handles.Box3.Position = [6.7*ipos(3)/8+.5     0           ipos(3)/50   ipos(4)/2];
handles.Box4.Position = [6.7*ipos(3)/8+3.5     0           ipos(3)/50   ipos(4)/2];
handles.ButtonReset.Position = [7*ipos(3)/8+1     ipos(4)/2-.25      ipos(3)/8-2   ipos(4)/2];
handles.ButtonSave.Position = [7*ipos(3)/8+1     0      ipos(3)/8-2   ipos(4)/2];

end

function resize_lPanel(hObj,~,handles)
lpos = get(handles.LeftPanel,'Position');
handles.PopupLeft1.Position = [0     (19*lpos(4)/20)-.5    lpos(3)/2   2];
handles.PopupLeft2.Position = [lpos(3)/2     (19*lpos(4)/20)-.5    lpos(3)/2   2];

l = handles.PopupLeft1.Position(2)/lpos(4);
channels = str2double(handles.Edit3.String);
margin = .03;
for k=1:channels
    ax = findobj(hObj,'Tag',sprintf('Ax%d',k));
    ax.Position = [1.5*margin (l*(channels-k)/channels)+margin 1-2*margin (l/channels)-2*margin];
end

end

function resize_rPanel(hObj,~,handles)
rpos = get(handles.LeftPanel,'Position');
handles.PopupRight1.Position = [0     (19*rpos(4)/20)-.5    rpos(3)/2   2];
handles.PopupRight2.Position = [rpos(3)/2     (19*rpos(4)/20)-.5    rpos(3)/2   2];

l = handles.PopupRight1.Position(2)/rpos(4);
channels = str2double(handles.Edit3.String);
margin = .03;
for k=1:channels
    ax = findobj(hObj,'Tag',sprintf('Ax%d',k));
    ax.Position = [1.5*margin (l*(channels-k)/channels)+margin 1-2*margin (l/channels)-2*margin];
end
end

function reset_Callback(hObj,~,handles)

global LAST_IM;

% Number of Components display
channels = str2double(handles.Edit3.String);
version = handles.Box3.Value;

% Left Panel
axes = findobj(handles.LeftPanel,'Type','axes');
for i=1:length(axes)
    delete(axes(i));
end
for k=1:channels
    ax = subplot(channels,1,k,'Parent',handles.LeftPanel,'Tag',sprintf('Ax%d',k));
    set(ax,'ButtonDownFcn',{@template_axes_clickFcn,version});
end
update_popup(handles.PopupLeft1,[],handles);

% Right Panel
axes = findobj(handles.RightPanel,'Type','axes');
for i=1:length(axes)
    delete(axes(i));
end
for k=1:channels
    ax = subplot(channels,1,k,'Parent',handles.RightPanel,'Tag',sprintf('Ax%d',k));
    set(ax,'ButtonDownFcn',{@template_axes_clickFcn,version});
end
update_popup(handles.PopupRight1,[],handles);

% Interactive Control
all_axes = findobj(handles.MainFigure,'Type','Axes');
b3 = handles.Box3;
set(all_axes,'ButtonDownFcn',{@template_axes_clickFcn,b3.Value});
set(handles.PlusButton,'Callback',{@template_buttonPlus_Callback,all_axes(1)});
set(handles.MinusButton,'Callback',{@template_buttonMinus_Callback,all_axes(1)});
set(handles.RescaleButton,'Callback',{@template_buttonRescale_Callback,all_axes(1)});
set(handles.SkipButton,'Callback',{@template_buttonSkip_Callback,all_axes(1)});
set(handles.BackButton,'Callback',{@template_buttonBack_Callback,all_axes(1)});
set(handles.TagButton,'Callback',{@custom_button_TagSelection_Callback,all_axes(1),handles});
set(handles.nextTagButton,'Callback',{@custom_button_nextTag_Callback,all_axes(1),handles});
set(handles.prevTagButton,'Callback',{@custom_button_prevTag_Callback,all_axes(1),handles});

% Reset Axes Limits
handles.Edit1.String = 1;
handles.Edit2.String = LAST_IM;
edit1_Callback(handles.Edit1,[],handles);
edit2_Callback(handles.Edit2,[],handles);

% Reset Traces
handles.ButtonLoad.UserData.Pixels = findobj(hObj.UserData.CenterAxes,'Tag','Pixel');
handles.ButtonLoad.UserData.Boxes = findobj(hObj.UserData.CenterAxes,'Tag','Box');
handles.ButtonLoad.UserData.Regions = findobj(hObj.UserData.CenterAxes,'Tag','Region');

% Relink all axes
handles.Box4.Value = 1;
all_axes = findobj(handles.MainFigure,'Type','Axes');
linkaxes(all_axes,'x');

% Fixing non automatic Main Panel resize
resize_rPanel(handles.RightPanel,[],handles);
resize_lPanel(handles.LeftPanel,[],handles);

end

function edit1_Callback(hObj,~,handles)

vs = round(str2double(get(hObj,'String')));
if (vs>=1 && vs<= str2double(handles.Edit2.String))
    set(hObj,'String',vs);
    handles.Text3.String = sprintf('(%s)',hObj.UserData(vs,:));
    ax = [findobj(handles.LeftPanel,'Type','Axes');findobj(handles.RightPanel,'Type','Axes')];
    for i=1:length(ax)
        ax(i).XLim  = [vs-.5 str2double(handles.Edit2.String)+.5];
        axis(ax(i),'auto y');
    end
else
    errordlg(sprintf('START_IM must be between %d and %d',1,str2double(handles.Edit2.String)),'modal');
    set(hObj,'String',1);
    return;
end

end

function edit2_Callback(hObj,~,handles)

global LAST_IM;

vs = round(str2double(get(hObj,'String')));
if (vs>=str2double(handles.Edit1.String) && vs<= LAST_IM)
    set(hObj,'String',vs);
    handles.Text4.String = sprintf('(%s)',hObj.UserData(vs,:));
    ax = [findobj(handles.LeftPanel,'Type','Axes');findobj(handles.RightPanel,'Type','Axes')];
    for i=1:length(ax)
        ax(i).XLim  = [str2double(handles.Edit1.String)-.5 vs+.5];
        axis(ax(i),'auto y');
    end
else
    errordlg(sprintf('END_IM must be between %d and %d',str2double(handles.Edit1.String),LAST_IM),'modal');
    set(hObj,'String',LAST_IM);
    return;
end

end

function update_popup(hObj,~,handles)

val = hObj.Value;
str = hObj.String;
parent = hObj.Parent;
channels = str2double(handles.Edit3.String);

switch strtrim(str(val,:))
    case 'Original Data',
        data = handles.ButtonLoad.UserData.data;
        str_title = 'Channel';
        color = 'k';
    case 'ICA Components',
        data = handles.ButtonICA.UserData.data_ica;
        str_title = 'ICA component';
        color = 'r';
    case 'PCA Components',
        data = handles.ButtonICA.UserData.data_pca;
        str_title = 'PCA component';
        color = 'r';
    case 'Reconstructed Data ICA',
        data = handles.ButtonRecon.UserData.data_rec_ica;
        str_title = 'Reconstructed ICA';
        color = 'b';
    case 'Reconstructed Data PCA',
        data = handles.ButtonRecon.UserData.data_rec_pca;
        str_title = 'Reconstructed PCA';
        color = 'b';
    otherwise,
        return,
end

% Building String
if size(data,1) > channels
    ind_channels = 1:channels:size(data,1);
    str = sprintf('%s 1 - %d',str_title,channels);
    for i=2:length(ind_channels)-1
        str = strcat(str,'|',sprintf('%s %d - %d',str_title,(channels*(i-1))+1,channels*i));
    end
    str = strcat(str,'|',sprintf('%s %d - %d',str_title,ind_channels(end),size(data,1)));
else
    str = sprintf('%s 1 - %d',str_title,size(data,1));
end

% Updating Popup
if strcmp(parent.Tag,'RightPanel')
    h = handles.PopupRight2;
elseif strcmp(parent.Tag,'LeftPanel')
    h = handles.PopupLeft2;
end
h.String = str;
h.Value = 1;
h.UserData.data = data;
h.UserData.str_title = str_title;
h.UserData.color = color;
update_data(h,[],handles);

end

function update_data(hObj,~,handles)
    
val = hObj.Value;
parent = hObj.Parent;
data = hObj.UserData.data;
str_title = hObj.UserData.str_title;
color = hObj.UserData.color;
channel_title = handles.ButtonLoad.UserData.channel_title;
%start_im = str2double(handles.Edit1.String);
%end_im = str2double(handles.Edit2.String);
channels = str2double(handles.Edit3.String);

% Clear Axes
h_all = findobj(parent,'Type','Axes');
for i=1:length(h_all)
    cla(h_all(i));
    delete(h_all(i).Title);
end

% Update Axes
for i=1:channels
    if ((val-1)*channels+i) <= size(data,1)
        h = findobj(parent,'Tag',sprintf('Ax%d',i));
        line(1:size(data,2),data((val-1)*channels+i,:),'Color',color,'Parent',h,'HitTest','off');
        %h.XLim  = [start_im-.5 end_im+.5];
 
        % Temporaire : On adapte juste le titre si Original Data
        if strcmp(str_title,'Channel')
            title(h,sprintf('%s',char(channel_title((val-1)*channels+i,:))));
        elseif strcmp(str_title,'Reconstructed ICA')
            title(h,strcat(sprintf('%s',char(channel_title((val-1)*channels+i,:))),' (Reconstructed ICA)'));
        elseif strcmp(str_title,'Reconstructed PCA')
            title(h,strcat(sprintf('%s',char(channel_title((val-1)*channels+i,:))),' (Reconstructed PCA)'));
        else
            title(h,sprintf('%s %d',str_title,(val-1)*channels+i));
        end
    end
end

end

function update_slider(hObj,~,axes)
    
r_label = hObj.UserData.r_label;
val = round(hObj.Value);
ica = hObj.UserData.data;
t = hObj.UserData.title;

imagesc(ica(:,:,val),'Parent',axes);
title(axes,char(t(val)));
if ~isempty(r_label)
    set(axes,'YTickLabel',r_label,'YTick',1:length(r_label));
end
    
end

function box2_Callback(hObj,~,handles)

if hObj.Value
    f_1 = figure_aux([],[],handles);
    hObj.UserData = f_1;
else
    if ~isempty(hObj.UserData)
        close(hObj.UserData);
    end
end

end

function box4_Callback(hObj,~,handles)

% Link all axes
all_axes = findobj(handles.MainFigure,'Type','Axes');
if hObj.Value
    linkaxes(all_axes,'x');
else
    linkaxes(all_axes,'off');
end

end

function f_1 = figure_aux(~,~,handles)

covarianceMat = handles.ButtonICA.UserData.covarianceMat;
hint_label = handles.ButtonLoad.UserData.hint_label;
r_label = handles.ButtonLoad.UserData.r_label;
ICA_component = handles.ButtonRecon.UserData.ICA_component;
ICA_title = handles.ButtonRecon.UserData.ICA_title;
PCA_component = handles.ButtonRecon.UserData.PCA_component;
PCA_title = handles.ButtonRecon.UserData.PCA_title;

% Display Covariance Matrix
f_1 = figure('Units','characters',...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'MenuBar','none',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','CovarianceMat',...
    'PaperPositionMode','auto',...
    'DeleteFcn',{@close_aux,handles},...
    'Name','Covariance and Components');

% Hint_Label On Covariance Matrix
label_list = unique(hint_label);
label_length = zeros(size(label_list));
ind_permute = [];
for k = 1:length(label_list)
    temp = find(ismember(hint_label,label_list(k)));
    ind_permute = [ind_permute;temp];
    label_length(k) = length(temp);
end
covarianceMat_sorted  = covarianceMat(ind_permute,ind_permute);
label_length = [.5;cumsum(label_length)+.5];
label_list = [label_list;{''}];
label_list_short = cell(size(label_list));
for i=1:length(label_list)
    str = char(label_list(i));
    try
        label_list_short(i) = {strcat(str(1:3),str(end-1:end))};
    catch
        label_list_short(i) = label_list(i);
    end
end

% Correlation Matrix
ax = subplot(2,1,1,'Parent',f_1);
imagesc(covarianceMat_sorted,'Parent',ax);
set(ax,'Xlim',[.5,length(hint_label)+.5],'XTick',label_length,'XTicklabel',label_list);
set(ax,'Ylim',[.5,length(hint_label)+.5],'YTick',label_length,'YTicklabel',label_list_short);
ax1 = ticklabel(ax);
ax1.XTickLabelRotation = 45;
ax1.YTickLabelRotation = 0;
title(ax,'Covariance Matrix');
colorbar(ax,'eastoutside');
c = colorbar(ax1,'eastoutside');
c.Visible='off';
clrmenu(f_1);

% Display ICA/PCA components
sl1 = uicontrol('Units','characters','Style','slider',...
    'HorizontalAlignment','left','Parent',f_1,...
    'Min',1,'Max',length(ICA_title),'Value',1,...
    'Tag','Slider1');
ax1 = subplot(2,2,3,'Parent',f_1,'YDir','reverse');
sl1.SliderStep = [1/abs(sl1.Max-sl1.Min) 5/abs(sl1.Max-sl1.Min)];
sl1.UserData.data = ICA_component;
sl1.UserData.title = ICA_title;
sl1.UserData.r_label = r_label;
sl1.Callback = {@update_slider,ax1};
update_slider(sl1,[],ax1);

sl2 = uicontrol('Units','characters','Style','slider',...
    'HorizontalAlignment','left','Parent',f_1,...
    'Min',1,'Max',length(PCA_title),'Value',1,...
    'Tag','Slider2');
ax2 = subplot(2,2,4,'Parent',f_1,'YDir','reverse');
axis(ax2,'off');
sl2.SliderStep = [1/abs(sl2.Max-sl2.Min) 5/abs(sl2.Max-sl2.Min)];
sl2.UserData.data = PCA_component;
sl2.UserData.title = PCA_title;
sl2.UserData.r_label = r_label;
sl2.Callback = {@update_slider,ax2};
update_slider(sl2,[],ax2);

set(f_1,'ResizeFcn',@resize_aux);
f_1.Position = [30 30 80 40];

end

function resize_aux(hObj,~)

pos = hObj.Position;
sl1 = findobj(hObj,'Tag','Slider1');
sl1.Position = [pos(3)/10 1 3*pos(3)/10 1];
sl2 = findobj(hObj,'Tag','Slider2');
sl2.Position = [6*pos(3)/10 1 3*pos(3)/10 1];
        

end

function close_aux(~,~,handles)
    handles.Box2.Value=0;
    handles.Box2.UserData = '';
end

function load_data(hObj,~,handles)

global IM;
set(handles.MainFigure,'Pointer','watch');
drawnow;

l_string(1) = {'Subsampled Image'};
l_string(2) = {'All Pixels in Image'};
l_string(3) = {'All Pixels in Specified Regions'};
l_string(4) = {'Pixel Traces'};
l_string(5) = {'Box Traces'};
l_string(6) = {'Region Traces'};
%l_string(7) = {'Spikoscope Traces'};
%l_string(8) = {'All Traces'};

ind_data = listdlg('PromptString','Select Data','SelectionMode','single','ListString',l_string,'ListSize',[300 500]);
channels = str2double(handles.Edit3.String);

if isempty(ind_data)
    set(handles.MainFigure, 'pointer', 'arrow');
    return;
end
switch ind_data
    case 1,
        
        %Subsampled image
        prompt={'SubSampling Size';'Mean (0) Median (1)'};
        name = 'Select Subsampling Parameters';
        defaultans = {'3';'0'};
        answer = inputdlg(prompt,name,[1 40],defaultans);
        step_sub = str2double(char(answer(1)));
        a = 1:step_sub:size(IM,1);
        b = 1:step_sub:size(IM,2);
        im = zeros(length(a),length(b),size(IM,3));
        switch str2double(char(answer(2)))
            case 0,
                for i=1:length(a)
                    for j=1:length(b)
                        im(i,j,:) = mean(mean(IM(a(i):min(a(i)+step_sub-1,end),b(j):min(b(j)+step_sub-1,end),:),2,'omitnan'),1,'omitnan');
                    end
                end
            case 1,
                for i=1:length(a)
                    for j=1:length(b)
                        im(i,j,:) = median(median(IM(a(i):min(a(i)+step_sub-1,end),b(j):min(b(j)+step_sub-1,end),:),2,'omitnan'),1,'omitnan');
                    end
                end
            otherwise,
                errordlg('Unrecognized Operation');
                set(handles.MainFigure, 'pointer', 'arrow');
                return;
        end
    case 2,
        im = NaN(size(IM));
        % All Pixels in Image
        prompt={'Index first row';'Index last row';'Index first column';'Index last column'};
        name = 'SubImage coordinates';
        defaultans = {'1';sprintf('%d',size(IM,1));'1';sprintf('%d',size(IM,2))};
        answer = inputdlg(prompt,name,[1 40],defaultans);
        i = str2double(cell2mat(answer(1)));
        I = str2double(cell2mat(answer(2)));
        j = str2double(cell2mat(answer(3)));
        J = str2double(cell2mat(answer(4)));
        im(i:I,j:J,:) =  IM(i:I,j:J,:);
    case 3,
        im = NaN(size(IM));
        % All Pixels in Specified Regions
        regions = hObj.UserData.Regions;
        str_regions = cell(length(regions),1);
        for i=1:length(regions)
            str_regions(i,:) = {regions(i).UserData.Name};
        end
        ind_regions = listdlg('PromptString','Select Region','SelectionMode','mutiple','ListString',str_regions,'ListSize',[300 500]);
        full_mask = zeros(size(im,1),size(im,2));
        for i=1:length(ind_regions)
            full_mask = full_mask+regions(ind_regions(i)).UserData.Mask;
        end
        full_mask = full_mask>0;
        im = IM.*repmat(full_mask,[1,1,size(im,3)]);
        im(im==0) = NaN;
    case 4,
        % Pixel Traces
        pix = hObj.UserData.Pixels;
        im = NaN(length(pix),1,size(IM,3));
        for i =1:length(pix)
            im(i,1,:) =  pix(i).UserData.Trace.YData(~isnan(pix(i).UserData.Trace.YData));
        end
    case 5,
        % Box Traces
        box = hObj.UserData.Boxes;
        im = NaN(length(box),1,size(IM,3));
        for i =1:length(box)
            im(i,1,:) =  box(i).UserData.Trace.YData(~isnan(box(i).UserData.Trace.YData));
        end
    case 6,
        % Region Traces
        reg = hObj.UserData.Regions;
        im = NaN(length(reg),1,size(IM,3));
        for i =1:length(reg)
            im(i,1,:) =  reg(i).UserData.Trace.YData(~isnan(reg(i).UserData.Trace.YData));
        end
    
    otherwise,
        warning('Problem in case selection : Unrecognized case in SWITCH.\n');
        return,
end

% Formatting data
IM_vect = reshape(permute(im,[3,1,2]),[size(im,3) size(im,1)*size(im,2)]);
IM_vect = IM_vect';
ind_null = find(isnan(IM_vect(:,1)));
ind_real = find(~isnan(IM_vect(:,1)));
data = IM_vect(ind_real,:);

channel_title = cell(length(ind_real),1);
rlabels = get_regionlabels();
r_label = '';
[ind_i,ind_j] = ind2sub([size(im,1),size(im,2)],ind_real);

% Building Channel_title
switch ind_data
    case 1,
        %Subsampled image
        hint_label = rlabels(a,b);
        hint_label = hint_label(ind_real);
        for k=1:length(ind_real)
            channel_title(k,:) = {sprintf('Subsampled Pixel %d (X=%d,Y=%d) (Region : %s)',k,ind_i(k),ind_j(k),char(hint_label(k)))};
        end
        
    case {2,3},
        % All Pixels in Image
        % All Pixels in Specified Regions
        hint_label = rlabels(ind_real);
        for k=1:length(ind_real)
            channel_title(k,:) = {sprintf('Pixel %d (X=%d,Y=%d) (Region : %s)',k,ind_i(k),ind_j(k),char(hint_label(k)))};
        end
 
    case 4,
        % Pixel Traces
        r_label = cell(length(pix),1);
        hint_label = cell(length(pix),1);
        for i =1:length(pix)
            r_label(i) =  {pix(i).UserData.Name};
            hint_label(i) = rlabels(pix(i).YData,pix(i).XData);
            channel_title(i,:) = {sprintf('%s (X=%d,Y=%d) (Region : %s)',char(r_label(i)),pix(i).YData,pix(i).XData,char(hint_label(i)))};
        end
        
    case 5,
        % Box Traces
        r_label = cell(length(box),1);
        hint_label = cell(length(box),1);
        for i =1:length(box)
            r_label(i) =  {box(i).UserData.Name};
            vert = round(mean(box(i).Vertices));
            hint_label(i) = rlabels(vert(2),vert(1));
            channel_title(i,:) = {sprintf('%s (Center :X=%d,Y=%d) (Region : %s)',char(r_label(i)),vert(2),vert(1),char(hint_label(i)))};
        end
        
    case 6,
        % Region Traces
        r_label = cell(length(reg),1);
        for i =1:length(reg)
            r_label(i) =  {reg(i).UserData.Name};
            channel_title(i,:) = {sprintf('Region %s',char(r_label(i)))};
        end
        hint_label = r_label;
end

% Feeding data for ICA & PCA
handles.ButtonLoad.UserData.data = data;
handles.ButtonLoad.UserData.channel_title = channel_title;
handles.ButtonLoad.UserData.hint_label = hint_label;
handles.ButtonLoad.UserData.r_label = r_label;
handles.ButtonLoad.UserData.ind_real = ind_real;
handles.ButtonLoad.UserData.ind_null = ind_null;
handles.ButtonLoad.UserData.IM_vect = IM_vect;
handles.ButtonLoad.UserData.im = im;

% Clear Right Axes & Panel
h = [findobj(handles.RightPanel,'Type','Axes');findobj(handles.LeftPanel,'Type','Axes')];
for i=1:length(h)
    cla(h(i));
end

% Setting Buttons
handles.PopupLeft1.String = 'Original Data';
handles.PopupLeft1.Value = 1;
handles.PopupLeft1.Callback = {@update_popup,handles};
handles.PopupLeft2.Callback = {@update_data,handles};
update_popup(handles.PopupLeft1,[],handles)

if size(data,1)>channels
    handles.PopupRight1.String = 'Original Data';
    handles.PopupRight1.Value = 1;
    handles.PopupRight1.Callback = {@update_popup,handles};
    handles.PopupRight1.Enable = 'on';
    update_popup(handles.PopupRight1,[],handles);
    handles.PopupRight2.Callback = {@update_data,handles};
    handles.PopupRight2.Value = 2;
    update_data(handles.PopupRight2,[],handles);
else
    handles.PopupRight1.String = '<0>';
    handles.PopupRight1.Value = 1;
    handles.PopupRight1.Callback = '';
    handles.PopupRight1.Enable = 'off';
    handles.PopupRight2.String = '<0>';
    handles.PopupRight2.Value = 1;
    handles.PopupRight2.UserData = '';
    handles.PopupRight2.Callback = '';
end
set(handles.MainFigure,'Pointer','arrow');

end

function compute_ICA_PCA(hObj,~,handles)

global DIR_SAVE FILES CUR_FILE;

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

im = handles.ButtonLoad.UserData.im;
IM_vect = handles.ButtonLoad.UserData.IM_vect;
ind_real = handles.ButtonLoad.UserData.ind_real;
data = handles.ButtonLoad.UserData.data;
start_im = str2double(handles.Edit1.String);
end_im = str2double(handles.Edit2.String);
%channels = str2double(handles.Edit3.String);

prompt={'Number of Independent Components';'Index first Eigen Value to be retained';'Index last Eigen Value to be retained'};
name = 'Select ICA parameters';
defaultans = {'50';'1';sprintf('%d',size(data,1))};
answer = inputdlg(prompt,name,[1 40],defaultans);
if isempty(answer)
    set(handles.MainFigure, 'pointer', 'arrow');
    return;
end
numOfIC = str2double(cell2mat(answer(1)));
firstEig = str2double(cell2mat(answer(2)));
lastEig = str2double(cell2mat(answer(3)));

% Performing ICA & PCA
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'covarianceMat.mat'),'file') && handles.Box1.Value
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'covarianceMat.mat'),'covarianceMat','pcaD','pcaE');
    [A, W]  = fastica(data(:,start_im:end_im),'pcaD',pcaD,'pcaE',pcaE,'numOfIC',numOfIC,'firstEig',firstEig,'lastEig',lastEig);
else
    [A, W, covarianceMat, pcaD, pcaE]  = fastica(data(:,start_im:end_im),'numOfIC',numOfIC,'firstEig',firstEig,'lastEig',lastEig);
end
   
data_ica = W*data;
data_pca = NaN(size(pcaD,1),size(data,2));
for k=1:size(data_pca,1)
    data_pca(k,:) = sum(repmat(pcaE(:,end-k+1),1,size(data,2)).*data,1);
end

hObj.UserData.data_ica = data_ica;
hObj.UserData.data_pca = data_pca;
hObj.UserData.A = A;
hObj.UserData.W = W;
hObj.UserData.covarianceMat = covarianceMat;
hObj.UserData.pcaD = pcaD;
hObj.UserData.pcaE = pcaE;

% Reshape ICA components
B = NaN(size(IM_vect,1),size(A,2));
B(ind_real,:) = A;
ICA_component = zeros(size(im,1),size(im,2),size(B,2));
ICA_title = cell(size(A,2),1);
for k = 1:size(A,2)
    ICA_component(:,:,k) = reshape(B(:,k),[size(im,1),size(im,2)]);
    ICA_title(k) = {sprintf('ICA component %d',k)};
end

% Reshape PCA components
C = NaN(size(IM_vect,1),size(pcaE,2));
C(ind_real,:) = pcaE;
PCA_component = zeros(size(im,1),size(im,2),size(C,2));
PCA_title = cell(size(C,2),1);
for k = 1:size(C,2)
    PCA_component(:,:,k) = reshape(C(:,end-k+1),[size(im,1),size(im,2)]);
    PCA_title(k) = {strcat(sprintf('PCA component %d - (',k),'\lambda',sprintf('_%d = %.3f)',k,pcaD(end-k+1,end-k+1)))};
end

handles.ButtonRecon.UserData.ICA_component = ICA_component;
handles.ButtonRecon.UserData.ICA_title = ICA_title;
handles.ButtonRecon.UserData.PCA_component = PCA_component;
handles.ButtonRecon.UserData.PCA_title = PCA_title;

% Setting Buttons
handles.PopupLeft1.String = 'Original Data|ICA Components|PCA Components';
handles.PopupRight1.Enable = 'on';
handles.PopupRight1.String = 'Original Data|ICA Components|PCA Components';
handles.PopupRight1.Value = 2;
handles.PopupRight1.Callback = {@update_popup,handles};
handles.PopupRight2.Callback = {@update_data,handles};
update_popup(handles.PopupRight1,[],handles);

box2_Callback(handles.Box2,[],handles);
set(handles.MainFigure, 'pointer', 'arrow');

end

function reconstruct_data(hObj,~,handles)

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

data_ica = handles.ButtonICA.UserData.data_ica;
A = handles.ButtonICA.UserData.A;
channels = str2double(handles.Edit3.String);

ind_ica = listdlg('PromptString','Select ICA components to reconstruct data','SelectionMode','multiple',...
    'ListString',hObj.UserData.ICA_title,'ListSize',[500 500]);

data_pca = handles.ButtonICA.UserData.data_pca;
pcaE = handles.ButtonICA.UserData.pcaE;
pcaD = handles.ButtonICA.UserData.pcaD;
eigenvalues = flipud(diag(pcaD));
variance_exp = eigenvalues.^2/sum(eigenvalues.^2);
variance_cumsum = cumsum(variance_exp);

PCA_title = hObj.UserData.PCA_title;
for i =1:length(PCA_title)
    PCA_title(i) = {strcat(char(PCA_title(i)),sprintf(' (Variance Explained : %.3f - %.3f/100)',variance_exp(i),variance_cumsum(i)))};
end

ind_pca = listdlg('PromptString','Select PCA components to reconstruct data','SelectionMode','multiple',...
    'ListString',PCA_title,'ListSize',[500 500]);

% Modify data using ICA
data_modified = zeros(size(data_ica));
data_modified(ind_ica,:) = data_ica(ind_ica,:);
data_rec_ica = A*data_modified;
hObj.UserData.data_rec_ica = data_rec_ica;

% Modify data using PCA
data_modified = zeros(size(data_pca));
data_modified(ind_pca,:) = data_pca(ind_pca,:);
data_rec_pca = fliplr(pcaE)*data_modified;
hObj.UserData.data_rec_pca = data_rec_pca;

% Form Reconstruction Movies
IM_vect = handles.ButtonLoad.UserData.IM_vect;
ind_real = handles.ButtonLoad.UserData.ind_real;
im = handles.ButtonLoad.UserData.im;

% ICA Reconstruction
B = NaN(size(IM_vect));
B(ind_real,:) = data_rec_ica;
Doppler_reconstructed_ICA = zeros(size(im,1),size(im,2),size(B,2));
for k = 1:size(data_rec_ica,2)
    Doppler_reconstructed_ICA(:,:,k) = reshape(B(:,k),[size(im,1),size(im,2)]);
end

% PCA Reconstruction
B = NaN(size(IM_vect));
B(ind_real,:) = data_rec_pca;
Doppler_reconstructed_PCA = zeros(size(im,1),size(im,2),size(B,2));
for k = 1:size(data_rec_pca,2)
    Doppler_reconstructed_PCA(:,:,k) = reshape(B(:,k),[size(im,1),size(im,2)]);
end

% Feed data for reconstruction movie
handles.ButtonDisp.UserData.Doppler_reconstructed_PCA = Doppler_reconstructed_PCA;
handles.ButtonSave.UserData.Doppler_reconstructed_PCA = Doppler_reconstructed_PCA;
handles.ButtonDisp.UserData.Doppler_reconstructed_ICA = Doppler_reconstructed_ICA;
handles.ButtonSave.UserData.Doppler_reconstructed_ICA = Doppler_reconstructed_ICA;


% Setting Buttons
handles.PopupLeft1.String = 'Original Data|ICA Components|PCA Components|Reconstructed Data ICA|Reconstructed Data PCA';
handles.PopupLeft1.Value = 1;
update_popup(handles.PopupLeft1,[],handles);

handles.PopupRight1.String = 'Original Data|ICA Components|PCA Components|Reconstructed Data ICA|Reconstructed Data PCA';
handles.PopupRight1.Value = 4;
update_popup(handles.PopupRight1,[],handles);

set(handles.MainFigure, 'pointer', 'arrow');

end

function display_reconstruction(hObj,~,handles)

if isempty(hObj.UserData)
    errordlg('No reconstruction data available.');
    return;
else
    im = handles.ButtonLoad.UserData.im;
    Doppler_reconstructed_ICA = hObj.UserData.Doppler_reconstructed_ICA ;
    Doppler_reconstructed_PCA = hObj.UserData.Doppler_reconstructed_PCA;
    movie_reconstruction(im,Doppler_reconstructed_ICA,Doppler_reconstructed_PCA,'Original Movie','ICA Reconstruction','PCA Reconstruction');
end

end

function save_reconstruction(hObj,~,handles)

global DIR_SAVE FILES CUR_FILE;

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

if isempty(hObj.UserData)
    errordlg('No reconstruction data available.');
    return;
else
    Doppler_reconstructed_ICA = hObj.UserData.Doppler_reconstructed_ICA;
    Doppler_reconstructed_PCA = hObj.UserData.Doppler_reconstructed_PCA;
    
    data = handles.ButtonLoad.UserData.data;
    channel_title = handles.ButtonLoad.UserData.channel_title;
    hint_label = handles.ButtonLoad.UserData.hint_label;
    r_label = handles.ButtonLoad.UserData.r_label;
    ind_real = handles.ButtonLoad.UserData.ind_real;
    ind_null = handles.ButtonLoad.UserData.ind_null;
    IM_vect = handles.ButtonLoad.UserData.IM_vect;
    im = handles.ButtonLoad.UserData.im;
    
    covarianceMat = handles.ButtonICA.UserData.covarianceMat;
    pcaD = handles.ButtonICA.UserData.pcaD;
	pcaE = handles.ButtonICA.UserData.pcaE;
    data_ica = handles.ButtonICA.UserData.data_ica;
    data_pca = handles.ButtonICA.UserData.data_pca;
    
    data_rec_pca = handles.ButtonRecon.UserData.data_rec_pca;
    data_rec_ica = handles.ButtonRecon.UserData.data_rec_pca;    
    ICA_component = handles.ButtonRecon.UserData.ICA_component;
    ICA_title = handles.ButtonRecon.UserData.ICA_title;
    PCA_component = handles.ButtonRecon.UserData.PCA_component;
    PCA_title = handles.ButtonRecon.UserData.PCA_title;
    
    save(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler_reconstructed.mat'),'Doppler_reconstructed_ICA','Doppler_reconstructed_PCA','-v7.3');
    fprintf('===> Saved at %s.\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler_reconstructed.mat'));
    save(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'covarianceMat.mat'),'covarianceMat','pcaD','pcaE','-v7.3');
    save(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'ICA_PCA.mat'),'data','channel_title','hint_label','r_label','ind_real','ind_null','IM_vect','im','data_ica','data_pca','data_rec_ica','data_rec_pca','-v7.3');
    fprintf('===> Saved at %s.\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'ICAPCA_components.mat'));
    %fprintf('Reconstructed Movie computed from %s\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'));
    
end

set(handles.MainFigure, 'pointer', 'arrow');

end

function custom_button_TagSelection_Callback(hObj,~,ax,handles)

global DIR_SAVE FILES CUR_FILE;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags_cell');
catch
    errordlg(sprintf('Missing File Time_Tags.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus)));
    return;
end

if isempty(hObj.UserData)
    Selected = 1;
else
    Selected = hObj.UserData.Selected;
end

str_tag = arrayfun(@(i) strjoin(TimeTags_cell(i,2:4),' - '), 2:size(TimeTags_cell,1), 'unif', 0)';
[ind_tag,v] = listdlg('Name','Tag Selection','PromptString','Select Time Tags',...
    'SelectionMode','multiple','ListString',str_tag,...
    'InitialValue',Selected,'ListSize',[300 500]);
if v==0
    return;
elseif isempty(ind_tag)
    hObj.UserData='';
else
    hObj.UserData.Selected = ind_tag;
    TimeTags_images = zeros(length(ind_tag),2);
    for k=1:length(ind_tag)
        min_time = char(TimeTags_cell(ind_tag(k)+1,3));
        max_time_dur = char(TimeTags_cell(ind_tag(k)+1,4));
        t_end = datenum(min_time)+datenum(max_time_dur);
        max_time = datestr(t_end,'HH:MM:SS.FFF');
        [~, ind_min_time] = min(abs(datenum(handles.Edit1.UserData)-datenum(min_time)));
        [~, ind_max_time] = min(abs(datenum(handles.Edit1.UserData)-datenum(max_time)));
        TimeTags_images(k,:) = [ind_min_time,ind_max_time];
    end
    start_im = min(TimeTags_images(:,1));
    end_im = max(TimeTags_images(:,2));
 
    ax.XLim = [start_im,end_im];
    handles.Edit1.String = start_im;
    handles.Edit2.String = end_im;
    edit1_Callback(handles.Edit1,[],handles);
    edit2_Callback(handles.Edit2,[],handles);
end

end

function custom_button_nextTag_Callback(~,~,ax,handles)

global DIR_SAVE FILES CUR_FILE;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags_cell');
catch
    errordlg(sprintf('Missing File Time_Tags.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus)));
    return;
end

if ~isempty(handles.TagButton.UserData)
    ind_new = min(max(handles.TagButton.UserData.Selected)+1,size(TimeTags_cell,1)-1);
    handles.TagButton.UserData.Selected = ind_new;
    min_time = char(TimeTags_cell(ind_new+1,3));
    max_time_dur = char(TimeTags_cell(ind_new+1,4));
    t_end = datenum(min_time)+datenum(max_time_dur);
    max_time = datestr(t_end,'HH:MM:SS.FFF');
    [~, start_im] = min(abs(datenum(handles.Edit1.UserData)-datenum(min_time)));
    [~, end_im] = min(abs(datenum(handles.Edit1.UserData)-datenum(max_time)));
   
    ax.XLim = [start_im,end_im];
    handles.Edit1.String = start_im;
    handles.Edit2.String = end_im;
    edit1_Callback(handles.Edit1,[],handles);
    edit2_Callback(handles.Edit2,[],handles);
end

end

function custom_button_prevTag_Callback(~,~,ax,handles)

global DIR_SAVE FILES CUR_FILE;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags_cell');
catch
    errordlg(sprintf('Missing File Time_Tags.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus)));
    return;
end

if ~isempty(handles.TagButton.UserData)
    ind_new = max(min(handles.TagButton.UserData.Selected)-1,1);  
    handles.TagButton.UserData.Selected = ind_new;
    min_time = char(TimeTags_cell(ind_new+1,3));
    max_time_dur = char(TimeTags_cell(ind_new+1,4));
    t_end = datenum(min_time)+datenum(max_time_dur);
    max_time = datestr(t_end,'HH:MM:SS.FFF');
    [~, start_im] = min(abs(datenum(handles.Edit1.UserData)-datenum(min_time)));
    [~, end_im] = min(abs(datenum(handles.Edit1.UserData)-datenum(max_time)));
   
    ax.XLim = [start_im,end_im];
    handles.Edit1.String = start_im;
    handles.Edit2.String = end_im;
    edit1_Callback(handles.Edit1,[],handles);
    edit2_Callback(handles.Edit2,[],handles);
end

end

function ax2 = ticklabel(ax1)
% TICKLABEL  Shift the tick labels in the X axis
%    TICKLABEL(AX) shifts current ticklabels to the right between
%    tick marks in axis AX. It only works for the X axis.
%    Returns the handler to the hidden axis with the centered ticklabels.
% Author M. Vichi (CMCC), from ideas posted on the Mathworks forum

if nargin==0, ax1=gca; end
ax2=axes('position',get(ax1,'position'),'YDir','reverse');

%invert the order of the axes
c=get(gcf,'children');
set(gcf,'children',flipud(c))

xlim=get(ax1,'XLim');
xtick=get(ax1,'XTick');
delt=diff(xtick);
xtick2 = 0.5*[delt delt(end)]+xtick(1:end);
xticklabels = get(ax1,'XTickLabel');
set(ax2,'Xlim',xlim,'XTick',xtick2,'XTicklabel',xticklabels);

ylim=get(ax1,'YLim');
ytick=get(ax1,'YTick');
delt=diff(ytick);
ytick2 = 0.5*[delt delt(end)]+ytick(1:end);
yticklabels=get(ax1,'YTickLabel');
set(ax2,'Ylim',ylim,'YTick',ytick2,'YTicklabel',yticklabels);

set(ax1,'XTickLabel','','Visible', 'on');
set(ax1,'YTickLabel','','Visible', 'on');

end
