% Article RUN
% Figure 1C
% aggregates left and right runs 
%close all;

function script_Figure1C(myhandles)

global DIR_SAVE FILES CUR_FILE IM;
folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);

%baseline
load(fullfile(folder_name,'Doppler.mat'),'Doppler_film');

% Loading Time Tags
data_t = load(fullfile(folder_name,'Time_Tags.mat'));

% Baseline Image
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

% Auxuliary function to plot
flag_save= true;
%group_name = 'LEFT_RUNS';
script_Figure1C_f('LEFT_RUNS',myhandles,im_baseline,flag_save);
script_Figure1C_f('RIGHT_RUNS',myhandles,im_baseline,flag_save);

end

function script_Figure1C_f(group_name,myhandles,im_baseline,flag_save)

% Loading Time Reference
global DIR_SAVE FILES CUR_FILE IM;
data_r = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
% Loading Time Tags
data_t = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'));
% Loading Episodes
data_e = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Spikoscope_Episodes.mat'));
% Loading Time Groups
data_g = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'));

% Parameters
t_gauss = 1;
delta =  data_r.time_ref.Y(2)-data_r.time_ref.Y(1);
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);
color1 = 'k';
color2 = 'r';
color_patch = 'r';
l_width1 = 1;
l_width2 = 1;
marker2 = 'none';
flag_patch = 'true';
alpha_value = .3;
temp = mean(mean(IM,'omitnan'),'omitnan');
clim1 = round(min(temp),-1);
clim2 = round(4*max(temp),-1);
thresh = clim1+.4*(clim2-clim1);
thresh = 5;
clim2 = 30;

% region
l  = findobj(myhandles.RightAxes,'Tag','Trace_Region');
l_name = [];
for i = 1:length(l)
    l_name = [l_name; {l(i).UserData.Name}];
end
ind_whole = contains(l_name,'Whole');
l_whole = l(ind_whole);
if ~isempty(l_whole)
    mask_whole =  l_whole.UserData.Mask;
else
    mask_whole = ones(size(im_baseline));
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


% Selecting Left Runs
ind_left = find(strcmp(data_g.TimeGroups_name,group_name)>0);
left_tags = data_g.TimeGroups_S(ind_left).Name;
% tags
all_tags = {data_t.TimeTags(:).Tag}';
ind_left_tags = find(contains(all_tags,left_tags)==1);

% Loop on all left tags
for k =1:length(ind_left_tags)
    
    ind_tag = ind_left_tags(k);
    tag_name = char(all_tags(ind_tag));
    im_start = data_t.TimeTags_images(ind_tag,1);
    im_end = data_t.TimeTags_images(ind_tag,2);
    
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
    
    % Setting image sequence
    im_sequence= ind_im_e1:5:im_end;

    % Figure
    if k==1
        f2 = figure('Name',strrep(group_name,'_','-'));
        n_rows = 3 ;
        n_columns = 4;
        margin_w=.01;
        margin_h=.02;
        alpha_value = .75;
        
        % axes creation
        all_axes1 = gobjects(12,1);
        all_axes2 = gobjects(12,1);
        all_axes3 = gobjects(12,1);
        all_axes4 = gobjects(12,1);
        
        for i = 1:n_rows
            for j = 1:n_columns
                index = (i-1)*n_columns+j;
                %             if index>length(im_sequence)
                %                 return;
                %             end
                x = mod(index-1,n_columns)/n_columns;
                y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
                ax = axes('Parent',f2);
                colormap(ax,'gray')
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
                %ax.Title.String = sprintf('t = %.1f',t_from_e1(im_sequence(index)));
                ax.Title.Visible = 'on';
                
                ax2 = axes('Parent',f2);
                ax2.YDir = 'reverse';
                colormap(ax2,'jet')
                
                if j==1 && i==1
                    c = colorbar(ax2);
                    c.Visible ='on';
                    %c.Position = [ax.Position(1)+ax.Position(3) ax.Position(2) margin_w ax.Position(4)];
                end
                
                % Positions on trask
                ax3 = axes('Parent',f2);
                ax4 = axes('Parent',f2);
                ax.Position = [x+margin_w y+.2*margin_h (1/n_columns)-2*margin_w (1/n_rows)-6*margin_h];
                ax2.Position = ax.Position;
                ax3.Position = [ax.Position(1) ax.Position(2)+ax.Position(4)+.5*margin_h ax.Position(3)/2-margin_w 2.5*margin_h];
                ax4.Position = [ax3.Position(1)+ax3.Position(3)+margin_w ax3.Position(2) ax3.Position(3) ax3.Position(4)];
                ax.Title.Position(2)= ax.Title.Position(2)-(n_rows*10);
                ax.Title.FontSize=9;
                if j==1 && i==1
                    c.Position = [ax.Position(1)+ax.Position(3) ax.Position(2) margin_w ax.Position(4)];
                end
                
                all_axes1(index) = ax;
                all_axes2(index) = ax2;
                all_axes3(index) = ax3;
                all_axes4(index) = ax4;
                hold(ax,'on');
                hold(ax2,'on');
                hold(ax3,'on');
                hold(ax4,'on');
            end
        end
    end
    
    % Plot on axes
    for i = 1:n_rows
        for j = 1:n_columns
            index = (i-1)*n_columns+j;
            if index>length(im_sequence)
                continue;
            else
                %ax = all_axes1(index);
                ax2 = all_axes2(index,1);
                ax3 = all_axes3(index,1);
                ax4 = all_axes4(index,1);
            end
            
            % image
            cdat = IM(:,:,im_sequence(index));
            cdat = imgaussfilt(cdat,[.75 .75]);
            im = imagesc(cdat,'Parent',ax2,'Tag','im_cdat');
            % im.AlphaData = mask_whole;
            im.AlphaData = mask_whole.*(cdat>thresh);
            ax2.Visible='off';
            % CLim
            % ax2.CLim = [0 50];
            ax2.CLim = [0 clim2];
            
            % Positions on trask
            plot(l_x.YData(im_start:im_end),l_y.YData(im_start:im_end),'Color',color1,'Parent',ax3);
            line('XData',l_x.YData(ind_im_e1),'YData',l_y.YData(ind_im_e1),...
                'Marker','o','MarkerSize',3,'MarkerEdgeColor','none','MarkerFaceColor',[.5 .5 .5],...
                'LineStyle','none','Parent',ax3);
            line('XData',l_x.YData(ind_im_e2),'YData',l_y.YData(ind_im_e2),...
                'Marker','o','MarkerSize',3,'MarkerEdgeColor','none','MarkerFaceColor',[.5 .5 .5],...
                'LineStyle','none','Parent',ax3);
            line('XData',l_x.YData(ind_im_e3),'YData',l_y.YData(ind_im_e3),...
                'Marker','o','MarkerSize',3,'MarkerEdgeColor','none','MarkerFaceColor',[.5 .5 .5],...
                'LineStyle','none','Parent',ax3);  
            ax3.XTick = [];
            ax3.YTick = [];
            ax3.XTickLabel = '';
            ax3.YTickLabel = '';
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
                arrow_step = 2;
                x_arrow = [l_x.YData(im_sequence(index)) l_x.YData(min(im_sequence(index)+arrow_step,end))];
                y_arrow = [l_y.YData(im_sequence(index)) l_y.YData(min(im_sequence(index)+arrow_step,end))];
                ha.X = x_arrow;
                ha.Y = y_arrow;
                ha.Color = color2;
            catch
            end
            
            plot(data_r.time_ref.Y(im_start:im_end)-t_start,l_s.YData(im_start:im_end),'Color',color1,'Parent',ax4);
            line('XData',data_r.time_ref.Y(ind_im_e1)-t_start,'YData',l_s.YData(ind_im_e1),...
                'Marker','o','MarkerSize',3,'MarkerEdgeColor','none','MarkerFaceColor',[.5 .5 .5],...
                'LineStyle','none','Parent',ax4);
            line('XData',data_r.time_ref.Y(ind_im_e2)-t_start,'YData',l_s.YData(ind_im_e2),...
                'Marker','o','MarkerSize',3,'MarkerEdgeColor','none','MarkerFaceColor',[.5 .5 .5],...
                'LineStyle','none','Parent',ax4);
            line('XData',data_r.time_ref.Y(ind_im_e3)-t_start,'YData',l_s.YData(ind_im_e3),...
                'Marker','o','MarkerSize',3,'MarkerEdgeColor','none','MarkerFaceColor',[.5 .5 .5],...
                'LineStyle','none','Parent',ax4);
            line('XData',[data_r.time_ref.Y(im_sequence(index)) data_r.time_ref.Y(im_sequence(index))]-t_start,...
                'YData',[0 1.2*max(l_s.YData(im_sequence))],'Color',color2,'Parent',ax4);
            
            ax4.XTick = [];
            ax4.YTick = [];
            ax4.XTickLabel = '';
            ax4.YTickLabel = '';
            ax4.XLim = [data_r.time_ref.Y(im_start) data_r.time_ref.Y(im_end)]-t_start;
            try
                ax4.YLim = [0 1.2*max(l_s.YData(im_sequence),[],'omitnan')];
            catch
                ax4.YLim = [0 1];
            end  
        end
    end
end

S = struct('CData','','n_images','','mean_im','');
for i =1:length(all_axes2)
    cdat = [];
    ax2 = all_axes2(i,1);
    all_im = findobj(ax2,'Tag','im_cdat');
    for j =1:length(all_im)
        cdat = cat(3,cdat,all_im(j).CData);
    end
    S(i).CData = cdat;
    S(i).n_images = length(all_im);
    S(i).mean_im = mean(cdat,3,'omitnan');
    
    % update
    delete(all_im)
    cdat = mean(cdat,3,'omitnan');
    im = imagesc(cdat,'Parent',ax2,'Tag','im_cdat');
    im.AlphaData = mask_whole.*(cdat>thresh);
    ax2.Visible='off';
    ax2.CLim = [0 clim2];        
end

if flag_save
    f2.Units = 'normalized';
    f2.Position = [0.05    0.3    0.55    0.58];
    %save(fullfile('/Users/tonio/Desktop',sprintf('%s.png',f2.Name)));
    folder = fullfile('C:\Users\Antoine\Desktop\fUS-Burst');
    if ~exist(folder,'dir')
        mkdir(folder);
    end
    saveas(f2,fullfile(folder,sprintf('%s_%s.pdf',FILES(CUR_FILE).nlab,f2.Name)));
    fprintf('Image saved [%s].\n',fullfile(folder,sprintf('%s_%s.pdf',FILES(CUR_FILE).nlab,f2.Name)));
    close(f2);
end

end
