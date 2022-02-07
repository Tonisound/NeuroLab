function visualize_sleep_1()
% clear all;
% close all;

DATA = load('DATA.mat');
DATA = DATA.DATA;

f = figure;
panel1 = uipanel('Parent',f,'Position',[0 .1 1 .9]);
panel2 = uipanel('Parent',f,'Position',[0 0 1 .1]);
list_conditions = flipud(unique({DATA.Condition}'));
n_cond = length(list_conditions);
all_axes = gobjects(n_cond,1);

% Parameters
margin_w = .1;
margin_h = .05;
color_aw = [0 0 1];
color_qw = [0 1 0];
color_rem = [1 0 0];
color_nrem = [1 1 0];

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
    
    all_files = cell(n_rec,1);
    all_tot_images = zeros(n_rec,1);
    for j = 1:n_rec
        cur_file = SUBDATA(j).File;
        all_tot_images(j) = SUBDATA(j).TimingInfo.TotalImages;
        all_files{j} = cur_file;
        
        % QW
        if isfield(SUBDATA(j).Images,'QW')
            n_ep = size(SUBDATA(j).Images.QW,1);
            for k= 1:n_ep    
                patch('XData',[SUBDATA(j).Images.QW(k,1) SUBDATA(j).Images.QW(k,2) SUBDATA(j).Images.QW(k,2) SUBDATA(j).Images.QW(k,1)],...
                    'YData',[j-1 j-1 j j],...
                    'FaceColor',color_qw,'FaceAlpha',.5,'EdgeColor','none',...
                    'Tag','QW','Parent',ax);
            end
        end
        % AW
        if isfield(SUBDATA(j).Images,'AW')
            n_ep = size(SUBDATA(j).Images.AW,1);
            for k= 1:n_ep    
                patch('XData',[SUBDATA(j).Images.AW(k,1) SUBDATA(j).Images.AW(k,2) SUBDATA(j).Images.AW(k,2) SUBDATA(j).Images.AW(k,1)],...
                    'YData',[j-1 j-1 j j],...
                    'FaceColor',color_aw,'FaceAlpha',.5,'EdgeColor','none',...
                    'Tag','AW','Parent',ax);
            end
        end
        % NREM
        if isfield(SUBDATA(j).Images,'NREM')
            n_ep = size(SUBDATA(j).Images.NREM,1);
            for k= 1:n_ep    
                patch('XData',[SUBDATA(j).Images.NREM(k,1) SUBDATA(j).Images.NREM(k,2) SUBDATA(j).Images.NREM(k,2) SUBDATA(j).Images.NREM(k,1)],...
                    'YData',[j-1 j-1 j j],...
                    'FaceColor',color_nrem,'FaceAlpha',.5,'EdgeColor','none',...
                    'Tag','NREM','Parent',ax);
            end
        end
        % REM
        if isfield(SUBDATA(j).Images,'REM')
            n_ep = size(SUBDATA(j).Images.REM,1);
            for k= 1:n_ep    
                patch('XData',[SUBDATA(j).Images.REM(k,1) SUBDATA(j).Images.REM(k,2) SUBDATA(j).Images.REM(k,2) SUBDATA(j).Images.REM(k,1)],...
                    'YData',[j-1 j-1 j j],...
                    'FaceColor',color_rem,'FaceAlpha',.5,'EdgeColor','none',...
                    'Tag','REM','Parent',ax);
            end
        end
    end
    
    ax.YTick = (1:n_rec)-.5;
    ax.YTickLabel = all_files;
    ax.YLim = [0 n_rec];
    ax.XLim = [0 max(all_tot_images)];
    ax.TickLength=[0 0];
    ax.FontSize=8;
end
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