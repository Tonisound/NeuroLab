  % Article RUN
% Figure 1A
close all;

global DIR_SAVE FILES CUR_FILE LAST_IM;

% Loading Time Reference
data_t = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
% Loading Episodes
data_e = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Spikoscope_Episodes.mat'));
% Loading Time Tags
data_tt = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'));

l  = findobj(myhandles.RightAxes,'Tag','Trace_Cerep');
l_name = [];
for i = 1:length(l)
    l_name = [l_name; {l(i).UserData.Name}];
end

% Gaussian smoothing
t_gauss = 1;
delta =  data_t.time_ref.Y(2)-data_t.time_ref.Y(1);
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);
% parameters
color1 = [.5 .5 .5];
color2 = 'r';
color_patch = 'r';
l_width1 = 1;
l_width2 = 1;
marker2 = 'none';
flag_patch = 'true';
alpha_value = .3;

% lines
ind_x = contains(l_name,'X(m)');
l_x = l(ind_x);
ind_y = contains(l_name,'Y(m)');
l_y = l(ind_y);
ind_s = contains(l_name,'SPEED');
l_s = l(ind_s);

% Length corrections
if length(l_x.UserData.X)~=length(l_x.UserData.Y)
    lmin = min(length(l_x.UserData.X),length(l_x.UserData.Y));
    l_x.UserData.X =l_x.UserData.X(1:lmin);
    l_x.UserData.Y =l_x.UserData.Y(1:lmin);
end
if length(l_y.UserData.X)~=length(l_y.UserData.Y)
    lmin = min(length(l_y.UserData.X),length(l_y.UserData.Y));
    l_y.UserData.X =l_y.UserData.X(1:lmin);
    l_y.UserData.Y =l_y.UserData.Y(1:lmin);
end
if length(l_s.UserData.X)~=length(l_s.UserData.Y)
    lmin = min(length(l_s.UserData.X),length(l_s.UserData.Y));
    l_s.UserData.X =l_s.UserData.X(1:lmin);
    l_s.UserData.Y =l_s.UserData.Y(1:lmin);
end

% Trajectories
f = figure;
ax1 = subplot(411,'Parent',f);
%plot(l_x.UserData.X,l_x.UserData.Y(1:end-1));
y_conv = nanconv(l_x.UserData.Y,w,'same');
plot(l_x.UserData.X,y_conv,'Color',color1,'LineWidth',l_width1);
ax1.XLabel.String = 'Time (s)';
ax1.YLabel.String = 'Position (m)';
ax1.XLim = [l_x.UserData.X(1) l_x.UserData.X(end)];
ax1.YLim = [0 2.5];

% adding burst
hold on;
if ~isempty(data_t.ind_bursts)
    ind_start = [1;data_t.ind_bursts];
    ind_stop = [data_t.ind_bursts-1;LAST_IM];  
    for i =1:length(ind_start)
        x_burst = data_t.time_ref.Y(ind_start(i):ind_stop(i));
        y_burst = interp1(l_x.UserData.X,y_conv,x_burst);
        plot(x_burst,y_burst,'Color',color2,...
            'LineStyle','-','Marker',marker2,'MarkerSize',1,'LineWidth',l_width2);
        if flag_patch
            patch('XData',[x_burst(1) x_burst(end) x_burst(end) x_burst(1)],...
                'YData',[ax1.YLim(1) ax1.YLim(1) ax1.YLim(2) ax1.YLim(2)],...
                'FaceColor',color_patch,'FaceAlpha',alpha_value,'EdgeColor','none')
        end
    end
end

ax2 = subplot(412,'Parent',f);
% plot(l_s.UserData.X,l_s.UserData.Y,'Color',color1,'LineWidth',l_width1);
y_conv = nanconv(l_s.UserData.Y,w,'same');
plot(l_s.UserData.X,y_conv,'Color',color1,'LineWidth',l_width1);
ax2.XLabel.String = 'Time (s)';
ax2.YLabel.String = 'Speed (m/s)';
ax2.XLim = [l_x.UserData.X(1) l_x.UserData.X(end)];
ax2.YLim = [0 1.1];

% adding burst
hold on;
if ~isempty(data_t.ind_bursts)
    ind_start = [1;data_t.ind_bursts];
    ind_stop = [data_t.ind_bursts-1;LAST_IM];  
    for i =1:length(ind_start)
        x_burst = data_t.time_ref.Y(ind_start(i):ind_stop(i));
        y_burst = interp1(l_s.UserData.X,y_conv,x_burst);
        plot(x_burst,y_burst,'Color',color2,...
            'LineStyle','-','Marker',marker2,'MarkerSize',1,'LineWidth',l_width2);
        
        if flag_patch
            patch('XData',[x_burst(1) x_burst(end) x_burst(end) x_burst(1)],...
                'YData',[ax2.YLim(1) ax2.YLim(1) ax2.YLim(2) ax2.YLim(2)],...
                'FaceColor',color_patch,'FaceAlpha',alpha_value,'EdgeColor','none')
        end
    end
end

ax3 = subplot(413,'Parent',f);
% plot(l_x.UserData.Y,l_y.UserData.Y,'Color',color1,'LineWidth',l_width1);
y_conv1= nanconv(l_x.UserData.Y,w,'same');
y_conv2= nanconv(l_y.UserData.Y,w,'same');
plot(y_conv1,y_conv2,'Color',color1,'LineWidth',l_width1);
ax3.XLabel.String = 'X (m)';
ax3.YLabel.String = 'Y(m)';
%ax3.XLim = [l_x.UserData.Y(1) l_x.UserData.Y(end)];

% adding burst
hold on;
if ~isempty(data_t.ind_bursts)
    ind_start = [1;data_t.ind_bursts];
    ind_stop = [data_t.ind_bursts-1;LAST_IM];  
    all_y_burst1=[];
    all_y_burst2=[];
    for i =1:length(ind_start)
        x_burst = data_t.time_ref.Y(ind_start(i):ind_stop(i));
        y_burst1 = interp1(l_x.UserData.X,y_conv1,x_burst);
        y_burst2 = interp1(l_y.UserData.X,y_conv2,x_burst);
        plot(y_burst1,y_burst2,'Color',color2,...
            'LineStyle','none','Marker','o','MarkerSize',2,'LineWidth',l_width1);
%         plot(y_burst1,y_burst2,'Color',color2,...
%             'LineStyle','-','Marker','none','MarkerSize',2,'LineWidth',l_width2);
        all_y_burst1=[all_y_burst1;y_burst1];
        all_y_burst2=[all_y_burst2;y_burst2];
    end
end

% histograms
ax4 = subplot(427,'Parent',f);
b = bar(hist(y_conv1,0:.01:2.5),'Parent',ax4);
b.FaceColor=color1;
b.EdgeColor='none';
hold on;
b = bar(hist(all_y_burst1,0:.01:2.5),'Parent',ax4);
b.FaceColor=color2;
b.EdgeColor='none';
ax4.YScale = 'log';
ax4.XTick = 0:50:250;
ax4.XTickLabel = {'0';'0.5';'1';'1.5';'2';'2.5'};

% left/right turns
ax5 = subplot(428,'Parent',f);

% episode1
all_episodes = {data_e.episodes(:).shortname}';
%episode_name1 = 'AfterA_(s)';
episode_name1 = 'Cross level_(s)';
ind_episode = find(strcmp(all_episodes,episode_name1)==1);
if length(ind_episode)>1
    ind_episode=ind_episode(1);
end
episode1 = data_e.episodes(ind_episode);
%timetags
temp = datenum(data_tt.TimeTags_strings(:,1));
tts_1 = (temp-floor(temp))*24*3600;
temp = datenum(data_tt.TimeTags_strings(:,2));
tts_2 = (temp-floor(temp))*24*3600;

flag_burst = false(size(episode1.Y));
all_turns = [];
for i =1:length(episode1.Y)
    t_e1 = episode1.Y(i);
    ind_burst = find(((tts_1-t_e1).*(tts_2-t_e1))<=0);
    if ~isempty(ind_burst)
        flag_burst(i) = true;
    end
    [~,ind_e1] = min((l_x.UserData.X-(t_e1-2)).^2);
    [~,ind_e2] = min((l_x.UserData.X-(t_e1+2)).^2);
    if sum(diff(l_x.UserData.Y(ind_e1:ind_e2)))>0
        all_turns = [all_turns;{'left'}];
    else
        all_turns = [all_turns;{'right'}];
    end
end

n_left = sum(strcmp(all_turns,'left'));
n_right = sum(strcmp(all_turns,'right'));
n_left_burst = sum(strcmp(all_turns(flag_burst),'left'));
n_right_burst = sum(strcmp(all_turns(flag_burst),'right'));

b=bar([n_left,n_left_burst;n_right,n_right_burst],'grouped','Parent',ax5);
b(1).FaceColor=color1;
b(1).EdgeColor='k';
b(2).FaceColor=color2;
b(2).EdgeColor='k';
ax5.XLim = [.6 2.4];
ax5.XTickLabel = {'left';'right'};
% ind_left_turns = (diff(l_x.UserData.Y))>.02;
% l_x_left = diff(l_x.UserData.Y).*ind_left_turns;
% ind_right_turns = (diff(l_x.UserData.Y))<-.02;
% l_x_right = abs(diff(l_x.UserData.Y).*ind_right_turns);
% plot(l_x_left);
% p_l = findpeaks(l_x_left);
% hold on
% plot(l_x_right);
% p_2 = findpeaks(l_x_right);