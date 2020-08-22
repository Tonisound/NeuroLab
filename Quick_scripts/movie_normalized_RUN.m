function h = movie_normalized_RUN(handles)
% Process : Compute normalized Movie

global IM DIR_SAVE FILES CUR_FILE START_IM END_IM;
% Loading time reference
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
% Loading time tags
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'file')
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags_cell','TimeTags_images');
    flag_tag = 1;
    tt_cell = TimeTags_cell(2:end,2);
    ind1 = cellfun('isempty',strfind(tt_cell,'WHOLE'));
    ind2 = cellfun('isempty',strfind(tt_cell,'TEST'));
    ind3 = cellfun('isempty',strfind(tt_cell,'BASELINE'));
    tt_cell = tt_cell(ind1&ind2&ind3==1);
    TimeTags_images = TimeTags_images(ind1&ind2&ind3==1,:);
else
    flag_tag = 0;
end

% Parameters
t_lfp  = 5;
t_start = 3;
t_video = .005;
clim_default = handles.CenterAxes.CLimMode;

% Finding X Y if exist
l = findobj(handles.RightAxes,'Tag','Trace_Cerep');
X_m = [];
Y_m = [];
for i=1:length(l)
    if strcmp(l(i).UserData.Name,'X(m)')
        X_m = l(i).YData;
        %X_m = l(i).UserData.Y;
    end
    if strcmp(l(i).UserData.Name,'Y(m)')
        Y_m = l(i).YData;
        %Y_m = l(i).UserData.Y;
    end
end

% Finding LFP channels
l = findobj(handles.RightAxes,'Tag','Trace_Cerep');
str_lfp = [];
% All channels
ind_keep = ones(length(l),1);
for i=1:length(l)
    str_lfp = [str_lfp;{l(i).UserData.Name}];
end
% Manual selection
% ind_keep=zeros(length(l),1);
% for i=1:length(l)
%     if ~isempty(l(i).UserData.Name)
%         if ~isempty(strfind(l(i).UserData.Name,'LFP'))||~isempty(strfind(l(i).UserData.Name,'lfp'))||~isempty(strfind(l(i).UserData.Name,'ACCEL/'))
%             ind_keep(i)=1;
%             str_lfp = [str_lfp;{l(i).UserData.Name}];
%         end
%     end
% end

l = l(ind_keep==1);
if isempty(l)
    errordlg('Missing LFP traces. Use Load Function.');
    %return;
else
    [ind_lfp,v] = listdlg('Name','LFP Selection','PromptString','Select LFP channels to display',...
        'SelectionMode','multiple','ListString',str_lfp,'InitialValue',[],'ListSize',[300 500]);
    if v==0 
        fprintf('No LFP channel selected .\n');
        return;
    else
        l = l(ind_lfp);
        str_lfp =  str_lfp(ind_lfp);
    end
end


% Finding EMG and ACCEL and put them on top
ind_top =zeros(size(l));
for i=1:length(l)
    if ~isempty(strfind(l(i).UserData.Name,'ACCEL/'))
        ind_top(i)=1;
    end
end
l=flipud([l(ind_top==1);l(ind_top==0)]);
str_lfp =  flipud([str_lfp(ind_top==1);str_lfp(ind_top==0)]);


% Building t matrix
b = datenum(handles.TimeDisplay.UserData);
t = (b-floor(b))*24*3600;

% Building figure
f = figure('Name','fUS-EEG Recording - Burst',...
    'Units','normalized',...
    'Position',[.1 .1 .6 .4],...
    'Colormap',handles.MainFigure.Colormap,...
    'KeyPressFcn',{@f_keypress_fcn},...   
    'MenuBar','none',...
    'Toolbar','none');
f.UserData.flag = 1;
f.UserData.t_video = t_video;
u0 = uicontrol(f,'Units','normalized',...
    'Style','text',...
    'String','',...
    'TooltipString','Time',...
    'Position',[.91 .85 .08 .05]);
u1 = uicontrol(f,'Units','normalized',...
    'Style','text',...
    'String','',...
    'TooltipString','# Image',...
    'Position',[.91 .8 .08 .05]);
u2 = uicontrol(f,'Units','normalized',...
    'Style','text',...
    'String','',...
    'TooltipString','# Burst',...
    'Position',[.91 .75 .08 .05]);
u7 = uicontrol(f,'Units','normalized',...
    'Style','text',...
    'TooltipString','Scale',...
    'String','',...
    'BackgroundColor','k',...
    'Position',[.05 .05 .45 .005]);
u8 = uicontrol(f,'Units','normalized',...
    'Style','text',...
    'String','1s',...
    'Position',[.05 .055 .4 .045]);

ax_im = axes('Position',[.15 .1 .35 .8],...
    'Parent',f,...
    'CLimMode',handles.CenterAxes.CLimMode,...
    'CLim',handles.CenterAxes.CLim);
str= strtrim(handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:));
uicontrol(f,'Units','normalized',...
    'Parent',f,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'FontSize',14,...
    'String',sprintf('%s (%s)',FILES(CUR_FILE).recording,str),...
    'Position',[.02 .92 .9 .05]);

cb1 = uicontrol(f,'Units','normalized',...
    'Style','Checkbox',...
    'TooltipString','CLim mode Selection',...
    'Position',[.01 .01 .1 .05]);
e1 = uicontrol(f,'Units','normalized',...
    'Style','edit',...
    'String',handles.CenterAxes.CLim(1),...
    'Visible','off',...
    'TooltipString','CLim min',...
    'Position',[.005 .06 .04 .05]);
e2 = uicontrol(f,'Units','normalized',...
    'Style','edit',...
    'String',handles.CenterAxes.CLim(2),...
    'Visible','off',...
    'TooltipString','CLim max',...
    'Position',[.005 .11 .04 .05]);
if strcmp(clim_default,'manual')
    cb1.Value = 0;
    cb1.String = 'auto';
    e1.Visible = 'on';
    e2.Visible = 'on';
else
    cb1.Value = 1;
    cb1.String = 'manual';
end

ax_track = axes('Position',[.05 .1 .05 .8],'Parent',f);
ax_track.XTick = [0 .2];
ax_track.XTickLabel={'0','.2'};
ax_track.XLabel.String = 'X(m)';
ax_track.YTick=[0 2.4];
ax_track.YTickLabel={'0','2.4'};
ax_track.YLabel.String = 'Y(m)';
ax_track.XLim =[0 .2];
ax_track.YLim =[0 2.4];

margin = .01;
L = length(l);
all_axes = [];

for i=1:L
    ax = axes('Position',[.55 .1+(i-1)*.8/L+margin .35 .8/L-2*margin],'Parent',f,'XTickLabel','');
    grid(ax,'on');
    scale = uicontrol(f,'Units','normalized',...
        'Style','text',...
        'TooltipString','Scale',...
        'String','',...
        'BackgroundColor','k',...
        'Position',[.905 .1+(i-1)*.8/L+margin .001 .8/L-margin]);
    ax.Tag = sprintf('Ax%d',i);
    ax.XAxis.Visible = 'off';
    %ax.XTickLabel={'-5';'-4';'-3';'-2';'-1';'0';'1';'2';'3';'4';'5'};
    ax.YLabel.String = char(str_lfp(i));
    
    % Plotting line
    X = l(i).UserData.X;
    Y = l(i).UserData.Y;
    delta = X(2)-X(1);
    line('XData',X,'YData',Y,'Parent',ax);
    try
        s = Y(floor(t(START_IM)/delta):floor(t(END_IM)/delta),1);
    catch
        s = Y(1,floor(t(START_IM)/delta):floor(t(END_IM)/delta));
    end
    lim_inf = mean(s,'omitnan')-3*std(s,[],'omitnan');
    lim_sup = mean(s,'omitnan')+3*std(s,[],'omitnan');
    ax.YLim = [lim_inf, lim_sup];
    ax.XLim = [t(START_IM);t(END_IM)];
    % Adjusting scale bar
    length_scale = (.8/L-margin)*100/(lim_sup-lim_inf);
    scale.Position(2) = .1 + i*.8/L- margin - .4/L;
    scale.Position(4) = length_scale;
    
    % Plotting Cursor
    c = line([NaN NaN],[-10000 10000],'Parent',ax,'LineWidth',1,'Color',[.5 .5 .5]);
    c.Tag = sprintf('Cursor%d',i);
    
    % Storing data
    %ax.UserData.X = X;
    all_axes = [all_axes;ax];
    ax.UserData.Y = Y;
    ax.UserData.delta = delta;
end

im = imagesc(IM(:,:,START_IM),'Parent',ax_im);
set(ax_im,'XTickLabel','','XTick','','YTick','','YTickLabel','');    
c = colorbar(ax_im,'Parent',f);
c.Position=[.93 .1 .015 .4];
ax_im.CLim = handles.CenterAxes.CLim;
u7.Position = [.9-.35/(2*t_lfp) .05 .35/(2*t_lfp) .005];
u8.Position = [.9-.35/(2*t_lfp) .055 .35/(2*t_lfp) .045];

% Copy AlphaData
im.AlphaData = handles.MainImage.AlphaData;
atlasmask = findobj(handles.CenterAxes,'Tag','AtlasMask');
copyobj(atlasmask,ax_im);

%for i = 1:START_IM:END_IM
i=START_IM;
while i>=START_IM && i<=END_IM
    if ishandle(f)
        u0.String = sprintf('%s',datestr(t(i)/(24*3600),'HH:MM:SS.FFF'));
        u1.String = sprintf('%d/%d',i,END_IM);
        %imagesc(IM(:,:,i),'Parent',ax_im);
        im.CData = IM(:,:,i);
        if cb1.Value
            ax_im.CLimMode = 'auto';
            cb1.String = 'auto';
            e1.Visible = 'off';
            e2.Visible = 'off';
        else
            ax_im.CLimMode = 'manual';
            cb1.String = 'manual';
            ax_im.CLim = [str2double(e1.String),str2double(e2.String)];
            e1.Visible = 'on';
            e2.Visible = 'on';
        end
        
        % Update LFP
        for j=1:length(all_axes)
            ax = all_axes(j);
            Y = ax.UserData.Y;
            delta = ax.UserData.delta;
            cla(ax);
            ind_0 = floor(t(i)/delta);
            Y0 = Y(floor(ind_0-t_lfp/delta):floor(ind_0+t_lfp/delta));
            line(1:length(Y0),Y0,'Parent',ax,'LineWidth',1,'Color','k');
            line([.5+.5*length(Y0) .5+.5*length(Y0)],[-10000 10000],'Parent',ax,'LineWidth',1,'Color',[.5 .5 .5]);
            ax.XLim = [1,length(Y0)];
        end
        
        % Displaying corresponding time tags
        %u2.String = sprintf('TRIAL %d/%d',ceil(i/length_burst),n_burst);
        if flag_tag ==1
            str = tt_cell((TimeTags_images(:,1)-i).*(TimeTags_images(:,2)-i)<=0);
            if isempty(str)
                u2.String = '';
                u2.FontWeight = 'normal';
                u2.BackgroundColor ='w';
                u2.ForegroundColor='k';
            else
                u2.String = str;
                u2.FontWeight = 'bold';
                u2.BackgroundColor ='k';
                u2.ForegroundColor='w';
            end
        end
        
        % Update ax_track
        ind = i+floor(i/length_burst);
        %ind = floor(t(i)/delta);
        ind = i;
        cla(ax_track);
        line(Y_m(1:ind),X_m(1:ind),'Parent',ax_track,'LineWidth',1,'Color',[.5 .5 .5]);
        line(Y_m(ind),X_m(ind),'Marker','.','Parent',ax_track,'MarkerSize',25,'Color','k');

        if i==START_IM
            count = t_start;
            while count>0
                u0.String = count;
                count = count-1;
                %drawnow;
                pause(1);
            end
        else
            pause(f.UserData.t_video);
        end
        
        % Save frame
        load('Preferences.mat','GTraces');
        pic_name = sprintf('Frame_%06d',i);
        savedir = fullfile('C:\Users\Antoine\Desktop\Movie_Normalized');
        workingDir = fullfile(savedir,FILES(CUR_FILE).nlab);
        if ~exist(workingDir,'dir')
            mkdir(workingDir);
        end
        saveas(f,fullfile(workingDir,pic_name),GTraces.ImageSaveFormat);
        fprintf('Image saved at %s.\n',fullfile(workingDir,pic_name));
        
        % Iterate i depending on f.UserData value
        switch f.UserData.flag
            case 1
                if i~=END_IM
                    i=i+1;
                end
            case -1
                if i~=START_IM
                    i=i-1;
                end
            case -100
                close(f);
                return;
            case 10
                i = min(i+100,END_IM);
                f.UserData.flag = 1;
            case -10
                i = max(i-100,START_IM);
                f.UserData.flag = 1;
        end
        
    else
        return;
    end
    
end

% Save Video
save_video(workingDir,savedir,FILES(CUR_FILE).nlab);
close(f);

end

function f_keypress_fcn(hObj,evnt)

%hObj.UserData.flag
%evnt.Key
switch evnt.Key
    case 'uparrow'
        hObj.UserData.flag=10;
    case 'downarrow'
        hObj.UserData.flag=-10;
    case 'rightarrow'
        hObj.UserData.flag=1;
    case 'leftarrow'
        hObj.UserData.flag=-1;
    case 'space'      
        hObj.UserData.flag =(hObj.UserData.flag-1)^2;
    case 'q'
        hObj.UserData.flag =-100;
    case 'm'
        hObj.UserData.t_video = 2*hObj.UserData.t_video;
    case 'p'
        hObj.UserData.t_video = hObj.UserData.t_video/2;
end

end