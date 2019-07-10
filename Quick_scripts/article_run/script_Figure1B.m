% Article RUN
% Figure 1B
% Creates and saves all individual runs 
%close all;

function script_Figure1B(myhandles)

% paper mode
% matlab.graphics.internal.setPrintPreferences('DefaultPaperPositionMode','manual');
% set(groot,'defaultFigurePaperPositionMode','manual');

%baseline
global DIR_SAVE FILES CUR_FILE IM;
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Doppler.mat'),'Doppler_film');
% Loading Time Tags
data_t = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'));

ind_base = contains({data_t.TimeTags(:).Tag}','BASELINE');
if isempty(data_t.TimeTags_images(ind_base))
        warning('No Tag baseline defined.\n')
        ind_keep = ones(size(IM,3),1);
else
    temp = data_t.TimeTags_images(ind_base,:);
    for i=1:size(temp,1)
        ind_keep(temp(i,1):temp(i,2))=1;
    end
end
Doppler_baseline = Doppler_film(:,:,ind_keep==1);
im_baseline = mean(Doppler_baseline,3,'omitnan');
im_baseline = 20*log10(abs(im_baseline)/max(max(abs(im_baseline))));

% Selecting Time tags
all_tags = {data_t.TimeTags(:).Tag}';
ind_tag = find(contains(all_tags,'fUSBurst')==1);
for i=1:length(ind_tag)
    flag_save= true;
    %tag_name = sprintf('fUSBurst-%03d',i-1);
    tag_name = char(all_tags(ind_tag(i)));
    script_Figure1B_f(tag_name,myhandles,im_baseline,flag_save);
end

end

function script_Figure1B_f(tag_name,myhandles,im_baseline,flag_save)

% Loading Time Reference
global DIR_SAVE FILES CUR_FILE IM;
data_r = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
% Loading Time Tags
data_t = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'));
% Loading Episodes
data_e = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Spikoscope_Episodes.mat'));

% tags
%tag_name = 'fUSBurst-018';
all_tags = {data_t.TimeTags(:).Tag}';
ind_tag = find(strcmp(all_tags,tag_name)==1);
im_start = data_t.TimeTags_images(ind_tag,1);
im_end = data_t.TimeTags_images(ind_tag,2);
im_sequence= im_start:5:im_end;

%Episodes
all_episodes = {data_e.episodes(:).shortname}';
t_start = data_r.time_ref.Y(im_start);
t_end = data_r.time_ref.Y(im_end);
%ep1
episode_name1 = 'AfterA_(s)';
ind_episode = find(strcmp(all_episodes,episode_name1)==1);
if length(ind_episode)>1
    ind_episode=ind_episode(1);
end
episode1 = data_e.episodes(ind_episode);
ind_e1 = find(((episode1.Y-t_start).*(t_end-episode1.Y))>0);
if isempty(ind_e1)
    [~,ind_e1] = min((episode1.Y-data_r.time_ref.Y(im_start)).^2);
elseif length(ind_e1)>1
    ind_e1=ind_e1(1);
end
t_e1 = episode1.Y(ind_e1);
t_from_e1 = data_r.time_ref.Y-t_e1;
[~,ind_im_e1] = min((data_r.time_ref.Y-t_e1).^2);
t_im_e1 = data_r.time_ref.Y(ind_im_e1);

%ep2
episode_name2 = 'Cross level_(s)';
ind_episode = find(strcmp(all_episodes,episode_name2)==1);
if length(ind_episode)>1
    ind_episode=ind_episode(1);
end
episode2 = data_e.episodes(ind_episode);
ind_e2 = find(((episode2.Y-t_start).*(t_end-episode2.Y))>0);
if isempty(ind_e2)
    [~,ind_e2] = min((episode2.Y-data_r.time_ref.Y(im_start)).^2);
elseif length(ind_e2)>1
    ind_e2=ind_e2(1);
end
t_e2 = episode2.Y(ind_e2);
t_from_e2 = data_r.time_ref.Y-t_e2;
[~,ind_im_e2] = min((data_r.time_ref.Y-t_e2).^2);
t_im_e2 = data_r.time_ref.Y(ind_im_e2);

%ep3
episode_name3 = 'BeforeB_(s)';
ind_episode = find(strcmp(all_episodes,episode_name3)==1);
if length(ind_episode)>1
    ind_episode=ind_episode(1);
end
episode3 = data_e.episodes(ind_episode);
ind_e3 = find(((episode3.Y-t_start).*(t_end-episode3.Y))>0);
if isempty(ind_e3)
    [~,ind_e3] = min((episode3.Y-data_r.time_ref.Y(im_start)).^2);
elseif length(ind_e3)>1
    ind_e3=ind_e3(1);
end
t_e3 = episode3.Y(ind_e3);
t_from_e3 = data_r.time_ref.Y-t_e3;
[~,ind_im_e3] = min((data_r.time_ref.Y-t_e3).^2);
t_im_e3 = data_r.time_ref.Y(ind_im_e3);

% region
l  = findobj(myhandles.RightAxes,'Tag','Trace_Region');
l_name = [];
for i = 1:length(l)
    l_name = [l_name; {l(i).UserData.Name}];
end
ind_whole = contains(l_name,'Whole');
l_whole = l(ind_whole);
if isempty(l_whole)
    mask_whole =  ones(size(IM,1),size(IM,2));
else
    mask_whole =  l_whole.UserData.Mask;
end

% lines
l  = findobj(myhandles.RightAxes,'Tag','Trace_Cerep');
l_name = [];
for i = 1:length(l)
    l_name = [l_name; {l(i).UserData.Name}];
end
ind_x = contains(l_name,'X(m)');
l_x = l(ind_x);
ind_y = contains(l_name,'Y(m)');
l_y = l(ind_y);
ind_s = contains(l_name,'SPEED');
l_s = l(ind_s);

% Gaussian smoothing
t_gauss = 1;
delta =  data_r.time_ref.Y(2)-data_r.time_ref.Y(1);
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);
% parameters
color1 = 'k';
color2 = 'r';
color_patch = 'r';
l_width1 = 1;
l_width2 = 1;
marker2 = 'none';
flag_patch = 'true';
alpha_value = .3;

% Setting clim
temp = mean(mean(IM,'omitnan'),'omitnan');
clim1 = round(min(temp),-1);
clim2 = round(4*max(temp),-1);
thresh = clim1+.4*(clim2-clim1);
thresh=5;
clim2 = 40;

% Figure
f2 = figure('Name',tag_name);
%colormap(f2,'gray');
n_rows = 3 ;
n_columns = 4;
margin_w=.01;
margin_h=.02;
alpha_value = .75;
color_s = 'g';
marker_s = 'o';
color_p = 'b';
marker_p = 'o';
color_e = 'r';
marker_e = 'o';
marker_size = 3;

for i = 1:n_rows
    for j = 1:n_columns
        index = (i-1)*n_columns+j;
        if index>length(im_sequence)
            return;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax = axes('Parent',f2);
        colormap(ax,'gray')
        ax2 = axes('Parent',f2);
        colormap(ax2,'parula')
        %background
        im = imagesc(im_baseline,'Parent',ax);
        im.AlphaData = alpha_value*mask_whole;
        if ~isempty(l_whole)
            p = copyobj(l_whole.UserData.Graphic,ax);
            p.Visible = 'on';
            p.FaceColor= 'none';
            p.EdgeColor= 'k';
            p.LineWidth = 1;
        end
        ax.Visible='off';
        ax.Title.String = sprintf('t = %.1f',t_from_e1(im_sequence(index)));
        % ax.Title.String = sprintf('X=%.1f [t=%.1f / %.1f / %.1f s]',l_x.YData(im_sequence(index)),t_from_e1(im_sequence(index)),t_from_e2(im_sequence(index)),t_from_e3(im_sequence(index)));
        ax.Title.Visible = 'on';
        % image
        cdat = IM(:,:,im_sequence(index));
        cdat = imgaussfilt(cdat,[.75 .75]);
        im = imagesc(cdat,'Parent',ax2);
        % im.AlphaData = mask_whole;
        im.AlphaData = mask_whole.*(cdat>thresh);
        ax2.Visible='off';
        % CLim
        % ax2.CLim = [0 50];
        ax2.CLim = [0 clim2];
        c = colorbar(ax2);
        if j==1
            c.Visible ='on';
        else
            c.Visible='off';
        end

        % Positions on track
        ax3 = axes('Parent',f2);
        plot(l_x.YData(im_start:im_end),l_y.YData(im_start:im_end),'Color',color1,'Parent',ax3);
        line('XData',l_x.YData(ind_im_e1),'YData',l_y.YData(ind_im_e1),...
            'Marker',marker_s,'MarkerSize',marker_size,'MarkerEdgeColor','none','MarkerFaceColor',color_s,...
            'LineStyle','none','Parent',ax3);
        line('XData',l_x.YData(ind_im_e2),'YData',l_y.YData(ind_im_e2),...
            'Marker',marker_p,'MarkerSize',marker_size,'MarkerEdgeColor','none','MarkerFaceColor',color_p,...
            'LineStyle','none','Parent',ax3);
        line('XData',l_x.YData(ind_im_e3),'YData',l_y.YData(ind_im_e3),...
            'Marker',marker_e,'MarkerSize',marker_size,'MarkerEdgeColor','none','MarkerFaceColor',color_e,...
            'LineStyle','none','Parent',ax3);
%         line('XData',l_x.YData(im_sequence(index)),'YData',l_y.YData(im_sequence(index)),...
%             'Marker','o','MarkerSize',5,'MarkerEdgeColor','none','MarkerFaceColor',color2,'Parent',ax3);
       
        ax3.XTick = [];
        ax3.YTick = [];
        ax3.XTickLabel = '';
        ax3.YTickLabel = '';
        %ax3.XLim = [0 2.5];
        %ax3.YLim = [0 .2];
        try
            ax3.XLim = [0 1.2*max(l_x.YData(im_sequence),[],'omitnan')];
            ax3.YLim = [0 1.2*max(l_y.YData(im_sequence),[],'omitnan')];
        catch
            ax3.XLim = [0 1];
            ax3.YLim = [0 1];
        end
        % Arrow
        try
            ha = annotation('arrow');
            ha.Parent = ax3;
            arrow_step = 1;
            x_arrow = [l_x.YData(im_sequence(index)) l_x.YData(min(im_sequence(index)+arrow_step,end))];
            y_arrow = [l_y.YData(im_sequence(index)) l_y.YData(min(im_sequence(index)+arrow_step,end))];
            % x_arrow = [l_x.YData(im_sequence(index)) l_x.YData(min(im_sequence(index)+1,end))]/ax3.XLim(2);
            % y_arrow = [l_y.YData(im_sequence(index)) l_y.YData(min(im_sequence(index)+1,end))]/ax3.YLim(2);
            ha.X = x_arrow;
            ha.Y = y_arrow;
            ha.Color = color2;
        catch
        end
        
        ax4 = axes('Parent',f2);
        plot(data_r.time_ref.Y(im_start:im_end),l_s.YData(im_start:im_end),'Color',color1,'Parent',ax4);
        line('XData',data_r.time_ref.Y(ind_im_e1),'YData',l_s.YData(ind_im_e1),...
            'Marker',marker_s,'MarkerSize',marker_size,'MarkerEdgeColor','none','MarkerFaceColor',color_s,...
            'LineStyle','none','Parent',ax4);
        line('XData',data_r.time_ref.Y(ind_im_e2),'YData',l_s.YData(ind_im_e2),...
            'Marker',marker_p,'MarkerSize',marker_size,'MarkerEdgeColor','none','MarkerFaceColor',color_p,...
            'LineStyle','none','Parent',ax4);
        line('XData',data_r.time_ref.Y(ind_im_e3),'YData',l_s.YData(ind_im_e3),...
            'Marker',marker_e,'MarkerSize',marker_size,'MarkerEdgeColor','none','MarkerFaceColor',color_e,...
            'LineStyle','none','Parent',ax4);
        line('XData',[data_r.time_ref.Y(im_sequence(index)) data_r.time_ref.Y(im_sequence(index))],...
            'YData',[0 1.2*max(l_s.YData(im_sequence))],'Color',color2,'Parent',ax4);
        
        ax4.XTick = [];
        ax4.YTick = [];
        ax4.XTickLabel = '';
        ax4.YTickLabel = '';
        ax4.XLim = [data_r.time_ref.Y(im_start) data_r.time_ref.Y(im_end)];
        try
            ax4.YLim = [0 1.2*max(l_s.YData(im_sequence),[],'omitnan')];
        catch
            ax4.YLim = [0 1];
        end
        % Positions
        ax.Position = [x+margin_w y+.2*margin_h (1/n_columns)-2*margin_w (1/n_rows)-6*margin_h];
        ax2.Position = ax.Position;
        c.Position = [ax.Position(1)+ax.Position(3) ax.Position(2) margin_w ax.Position(4)];
        ax3.Position = [ax.Position(1) ax.Position(2)+ax.Position(4)+.5*margin_h ax.Position(3)/2-margin_w 2.5*margin_h];
        ax4.Position = [ax3.Position(1)+ax3.Position(3)+margin_w ax3.Position(2) ax3.Position(3) ax3.Position(4)];
        %ax.Title.Position = [ax.Position(1) ax3.Position(2)+ax3.Position(4) ax.Position(3)  2*margin_h];
        ax.Title.Position(2)= ax.Title.Position(2)-(n_rows*10);        
        ax.Title.FontSize=9;
        
    end
end

%left/right turns
if l_x.YData(im_sequence(1))<1.1
    turn = 'left';
else
    turn = 'right';
end

if flag_save
    f2.Units = 'normalized';
    f2.Position = [0.05    0.3    0.55    0.58];
    %save(fullfile('/Users/tonio/Desktop',sprintf('%s.png',f2.Name)));
    folder = fullfile('C:\Users\Antoine\Desktop\fUS-Burst',FILES(CUR_FILE).nlab);
    if ~exist(folder,'dir')
        mkdir(folder);
    end
    
    saveas(f2,fullfile(folder,sprintf('%s_%s.pdf',turn,f2.Name)));
    fprintf('Image saved [%s].\n',fullfile(folder,sprintf('%s_%s.pdf',turn,f2.Name)));
    close(f2);
end

end
