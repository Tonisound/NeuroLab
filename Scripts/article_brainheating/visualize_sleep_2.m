function visualize_sleep_2()
%clear all;
close all;

% DATA = load('DATA.mat');
% DATA = DATA.DATA;

DATA = load('DATA2.mat');
DATA = DATA.DATA2;
% for i=1:length(DATA)
%     DATA(i).Condition = strcat(DATA(i).Condition,DATA(i).ON_OFF);
% end

f = figure;
panel1 = uipanel('Parent',f,'Position',[0 .1 1 .9]);
panel2 = uipanel('Parent',f,'Position',[0 0 1 .1]);
list_conditions = flipud(unique({DATA.Condition}'));
n_cond = length(list_conditions);
all_axes = gobjects(n_cond,1);

% Parameters
margin_w = .1;
margin_h = .02;
color_aw = [0 0 1];
color_qw = [0 1 0];
color_rem = [1 0 0];
color_nrem = [1 1 0];
ep_color = 'none';

cb1 = uicontrol('Style','checkbox','Units','normalized','Value',1,...
    'BackgroundColor',color_aw,'Position',[.1 .25 .15 .5],...
    'String','AW','Tag','Checkbox1','Parent',panel2);
cb2 = uicontrol('Style','checkbox','Units','normalized','Value',1,...
    'BackgroundColor',color_qw,'Position',[.3 .25 .15 .5],...,...
    'String','QW','Tag','Checkbox2','Parent',panel2);
cb3 = uicontrol('Style','checkbox','Units','normalized','Value',1,...
    'BackgroundColor',color_nrem,'Position',[.5 .25 .15 .5],...,...
    'String','NREM','Tag','Checkbox3','Parent',panel2);
cb4 = uicontrol('Style','checkbox','Units','normalized','Value',1,...
    'BackgroundColor',color_rem,'Position',[.7 .25 .15 .5],...,...
    'String','REM','Tag','Checkbox4','Parent',panel2);

% Creating callbacks
cb1.Callback = {@cb_Callback,'AW'};
cb2.Callback = {@cb_Callback,'QW'};
cb3.Callback = {@cb_Callback,'NREM'};
cb4.Callback = {@cb_Callback,'REM'};

% Creating axes
for i =1:n_cond
    str_condition = char(list_conditions(i));
    ax = axes('Parent',panel1,'Position',[margin_w (i-1)/n_cond+margin_h 1-2*margin_w 1/n_cond-2*margin_h]);
    ax.Title.String = str_condition;
    ax.YDir = 'reverse';
    all_axes(i) = ax;
end

% Filling axes 
for i = 1:n_cond
    
    ax = all_axes(i);
    str_condition = char(list_conditions(i));
    index_keep = strcmp({DATA.Condition}',str_condition);
    SUBDATA = DATA(index_keep==1);
    n_rec = length(SUBDATA);
    
    all_dates = cell(n_rec,1);
    for j = 1:n_rec
        all_dates(j) = {SUBDATA(j).FileInfo.Date};
    end
    all_dates = unique(all_dates);
    n_all_dates = length(all_dates);
    
    all_files = cell(n_all_dates,1);
    all_tot_images = zeros(n_rec,1);
    
    % stats
    stats_a = zeros(n_all_dates,1); % total rem bouts
    stats_b = zeros(n_all_dates,1); % total rem duration
    stats_c = zeros(n_all_dates,1); % total nrem duration
    
    % Browsing recordings
    for j = 1:n_rec
        index_date = find(strcmp(all_dates,SUBDATA(j).FileInfo.Date)==1);
        cur_date = all_dates(index_date);
        % cur_file = SUBDATA(j).File;
        % all_files{j} = cur_file;
        all_files{index_date} = char(cur_date);
        all_tot_images(j) = SUBDATA(j).TimingInfo.TotalImages;
        
        t_start_ep = (datenum(SUBDATA(j).TimingInfo.Start)-floor(datenum(SUBDATA(j).TimingInfo.Start)))*24;
        t_end_ep = (datenum(SUBDATA(j).TimingInfo.End)-floor(datenum(SUBDATA(j).TimingInfo.End)))*24;
        line('XData',[t_start_ep t_start_ep],'YData',[index_date-1 index_date],...
            'LineWidth',1,'Color',ep_color,'Tag','START','Parent',ax)
        line('XData',[t_end_ep t_end_ep],'YData',[index_date-1 index_date],...
            'LineWidth',1,'Color',ep_color,'Tag','END','Parent',ax)
        
        % QW
        if isfield(SUBDATA(j).Times,'QW')
            n_ep = size(SUBDATA(j).Times.QW,1);
            temp2 = datenum(SUBDATA(j).Times.QW);
            t_ep = t_start_ep+(temp2-floor(temp2))*24;
            for k= 1:n_ep
                patch('XData',[t_ep(k,1) t_ep(k,2) t_ep(k,2) t_ep(k,1)],...
                    'YData',[index_date-1 index_date-1 index_date index_date],...
                    'FaceColor',color_qw,'FaceAlpha',.5,'EdgeColor','none',...
                    'Tag','QW','Parent',ax);
            end
        end
        % AW
        if isfield(SUBDATA(j).Times,'AW')
            n_ep = size(SUBDATA(j).Times.AW,1);
            temp2 = datenum(SUBDATA(j).Times.AW);
            t_ep = t_start_ep+(temp2-floor(temp2))*24;
            for k= 1:n_ep
                patch('XData',[t_ep(k,1) t_ep(k,2) t_ep(k,2) t_ep(k,1)],...
                    'YData',[index_date-1 index_date-1 index_date index_date],...
                    'FaceColor',color_aw,'FaceAlpha',.5,'EdgeColor','none',...
                    'Tag','AW','Parent',ax);
            end
        end
        % NREM
        if isfield(SUBDATA(j).Times,'NREM')
            n_ep = size(SUBDATA(j).Times.NREM,1);
            temp2 = datenum(SUBDATA(j).Times.NREM);
            t_ep = t_start_ep+(temp2-floor(temp2))*24;
            for k= 1:n_ep
                patch('XData',[t_ep(k,1) t_ep(k,2) t_ep(k,2) t_ep(k,1)],...
                    'YData',[index_date-1 index_date-1 index_date index_date],...
                    'FaceColor',color_nrem,'FaceAlpha',.5,'EdgeColor','none',...
                    'Tag','NREM','Parent',ax);
                stats_c(index_date) = stats_c(index_date)+3600*(t_ep(k,2)-t_ep(k,1));
            end
        end
        % REM
        if isfield(SUBDATA(j).Times,'REM')
            n_ep = size(SUBDATA(j).Times.REM,1);
            temp2 = datenum(SUBDATA(j).Times.REM);
            t_ep = t_start_ep+(temp2-floor(temp2))*24;
            for k= 1:n_ep
                patch('XData',[t_ep(k,1) t_ep(k,2) t_ep(k,2) t_ep(k,1)],...
                    'YData',[index_date-1 index_date-1 index_date index_date],...
                    'FaceColor',color_rem,'FaceAlpha',.5,'EdgeColor','none',...
                    'Tag','REM','Parent',ax);
                stats_a(index_date) = stats_a(index_date)+1;
                stats_b(index_date) = stats_b(index_date)+3600*(t_ep(k,2)-t_ep(k,1));
            end
        end
        
    end
    
    ax.YTick = (1:n_rec)-.5;
    ax.YTickLabel = all_files;
    ax.YLim = [0 length(all_files)];
    ax.XLim = [8 24];
    ax.XTick = 8:4:24;
    ax.XTickLabel = {'08:00' '12:00' '16:00' '20:00' '00:00'};
    ax.TickLength=[0 0];
    ax.FontSize=8;
    
    % Print stats
    text(8.5,-.5,'Mean REM dur (s)','Parent',ax,'FontWeight','bold');
    for kk=1:n_all_dates
        text(8.5,kk-.5,sprintf('%.2f',stats_b(kk)/stats_a(kk)),'Parent',ax);
    end
    text(8.5,n_all_dates+.5,sprintf('%.2f +/- %.2f',mean(stats_b./stats_a),std(stats_b./stats_a)/sqrt(n_all_dates)),'Parent',ax,'FontWeight','bold');
    text(23,-.5,'% REM/SLEEP','Parent',ax,'FontWeight','bold');
    for kk=1:n_all_dates
        text(23,kk-.5,sprintf('%.2f',(100*stats_b(kk))/(stats_b(kk)+stats_c(kk))),'Parent',ax);
    end
    text(23,n_all_dates+.5,sprintf('%.2f +/- %.2f',mean(100*stats_b./(stats_b+stats_c)),std(100*stats_b./(stats_b+stats_c))/sqrt(n_all_dates)),'Parent',ax,'FontWeight','bold');
end

linkaxes(all_axes,'x');
end

function cb_Callback(hObj,~,str)

all_patches = findobj(hObj.Parent.Parent,'Tag',str);
if hObj.Value
    status = 'on';
else
    status = 'off';
end
for i=1:length(all_patches)
    all_patches(i).Visible = status;
end
end