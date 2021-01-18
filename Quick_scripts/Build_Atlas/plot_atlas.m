function plot_atlas(list_regions,value_regions,AtlasType)
% Plot Atlas

%close all;

if nargin <1
    list_regions = [];
end
if nargin <2
    value_regions = ones(size(list_regions));
end
% if nargin < 3
%     AtlasType = 'RatCoronal';
% end

% Main Parameters
AtlasType = 'RatCoronal';
% AtlasType = 'RatSagittal';
% DisplayObj = 'Regions';
DisplayObj = 'Groups';

% Loading Atlas
% Seed directory where atlas correspondances (txt files) are located
% Plotable Atlas will be saved there
global SEED_ATLAS
dir_atlas = SEED_ATLAS;
%dir_txt = '/Users/tonio/Documents/NEUROLAB/Nlab_Files/NAtlas';
switch AtlasType
    case 'RatCoronal'
        plate_name = 'RatCoronalPaxinos';
    case 'RatSagittal'
        plate_name = 'RatSagittalPaxinos';
end

% Setting Parameters
f = figure;
f.Units = 'normalized';
f.Position = [0.4423    1.0905    0.8399    0.8229];
clrmenu(f);
fName = 'PlotAtlas';
f.Name = fName;
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
colormap(f,'jet');
f_colormap = f.Colormap;
f_colors = f.Colormap(round(1:64/length(list_regions):64),:);

% Choosing plates to show
plate_step = 3;
plate_1 = 15;
plate_2 = 80;
list_plates = plate_1:plate_step:plate_2;
n_plates = length(list_plates);
n_columns = 6;

% Setting up axes
margin_w = .01;
margin_h = .02;
n_rows = ceil(n_plates/n_columns);
tick_width =.5;
thresh_average = .5;
all_markers = {'none';'none';'none'};
all_linestyles = {'--';':';'-'};
patch_alpha = .1;

% Creating axes
all_axes = [];
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        
        if index>n_plates
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax = axes('Parent',f);
        ax.Position= [x+2*margin_w y+margin_h (1/n_columns)-3*margin_w (1/n_rows)-3*margin_h];
        ax.XAxisLocation ='origin';
        ax.Title.String = sprintf('Ax-%02d',index);
        
        ax.Title.Visible = 'on';
        all_axes = [all_axes;ax];
    end
end

% Creating checkboxes
cb1 = uicontrol('Style','checkbox','Units','normalized','Value',0,...
    'TooltipString','Display Sticker','Tag','Checkbox1','Parent',f);
cb2 = uicontrol('Style','checkbox','Units','normalized','Value',0,...
    'TooltipString','Display Colorbar','Tag','Checkbox2','Parent',f);
cb1.Position = [0 .98 .02 .02];
cb2.Position = [0 .96 .02 .02];
set(cb1,'Callback',{@cb1_Callback});
set(cb2,'Callback',{@cb2_Callback});

% Updating Axes
for index=1:n_plates
    ax =  all_axes(index);
    hold(ax,'on');
    
    xyfig = list_plates(index);
    % Loading Plate
    try
        data_plate = load(fullfile(dir_atlas,'PlotableAtlas',plate_name,sprintf('%s-%03d.mat',plate_name,xyfig)));
    catch
        warningdlg('Missing file [%s]',sprintf('%s-%03d.mat',plate_name,xyfig));
        continue;
    end
    
    fprintf('Plotting Atlas Plate Bregma %.2f mm [%d/%d]...',data_plate.AP,index,n_plates);
    %     line_x = data_plate.line_x;
    %     line_z = data_plate.line_z;
    %     AP = data_plate.AP;
    %     list_groups = data_plate.list_groups;
    %     list_regions = data_plate.list_regions;
    %     mask_groups = data_plate.mask_groups;
    %     mask_regions = data_plate.mask_regions;
    
    % Plot objects
    switch DisplayObj
        case 'Regions'
            for i =1:length(list_regions)
                ind_region = find(strcmp(data_plate.list_regions,list_regions(i))==1);
                if ~isempty(ind_region)
                    for j=1:length(ind_region)
                        %cur_index = data_plate.index_regions(ind_region(j));
                        cur_mask = data_plate.mask_regions(:,:,ind_region(j));
                        coeff = value_regions(i);
                        im=imagesc(coeff*cur_mask,'Parent',ax);
                        im.AlphaData = double(cur_mask);
                        
                        % Display Name
                        cur_region = data_plate.list_regions(ind_region(j));
                        [X,Y]=meshgrid(1:size(cur_mask,2),1:size(cur_mask,1));
                        temp_X = X.*cur_mask;
                        temp_X(temp_X==0)=NaN;
                        x = mean(mean(temp_X,'omitnan'),'omitnan');
                        temp_Y = Y.*cur_mask;
                        temp_Y(temp_Y==0)=NaN;
                        y = mean(mean(temp_Y,'omitnan'),'omitnan');
                        t = text(x,y,cur_region,'Parent',ax,'Color','r',...
                            'Visible','off','Tag','Sticker','Parent',ax);
                    end
                end
            end
            
        case 'Groups'
            for i =1:length(list_regions)
                ind_group = find(strcmp(data_plate.list_groups,list_regions(i))==1);
                if ~isempty(ind_group)
                    for j=1:length(ind_group)
                        cur_mask = data_plate.mask_groups(:,:,ind_group(j));
                        coeff = value_regions(i);
                        im=imagesc(coeff*cur_mask,'Parent',ax);
                        im.AlphaData = double(cur_mask);
                        
                        % Display Name
                        cur_group = data_plate.list_groups(ind_group(j));
                        [X,Y]=meshgrid(1:size(cur_mask,2),1:size(cur_mask,1));
                        temp_X = X.*cur_mask;
                        temp_X(temp_X==0)=NaN;
                        x = mean(mean(temp_X,'omitnan'),'omitnan');
                        temp_Y = Y.*cur_mask;
                        temp_Y(temp_Y==0)=NaN;
                        y = mean(mean(temp_Y,'omitnan'),'omitnan');
                        t = text(x,y,cur_group,'Parent',ax,'Color','r',...
                            'Visible','off','Tag','Sticker','Parent',ax);
                    end
                end
            end
    end
    
    % Ploting Atlas
    line('XData',data_plate.line_x,'YData',data_plate.line_z,'Color',[.5 .5 .5],'Linewidth',.5,'Parent',ax);
    ax.Title.String = sprintf('Bregma %.2f mm',data_plate.AP);
    ax.YDir = 'reverse';
    ax.XDir = 'reverse';
    
    % Axes Limits
    ax.XLim = [min(data_plate.line_x) max(data_plate.line_x)];
    ax.YLim = [min(data_plate.line_z) max(data_plate.line_z)];
    ax.Visible = 'off';
    ax.Title.Visible='on';
    
    % Colorbar
    %c = colorbar(ax,'Tag','Colorbar','Visible','off','Location','southoutside');
    fprintf(' done.\n');
end

fullname = fullfile(strcat(fName,'.pdf'));
saveas(f,fullname);

end

function cb1_Callback(hObj,~)

all_axes = findobj(hObj.Parent,'Type','axes');
all_obj = findobj(all_axes,'Tag','Sticker');
if hObj.Value
    for i = 1:length(all_obj)
        all_obj(i).Visible = 'on';
        uistack(all_obj(i),'top');
    end
else
    for i = 1:length(all_obj)
        all_obj(i).Visible = 'off';
    end
end

end

function cb2_Callback(hObj,~)

all_axes = findobj(hObj.Parent,'Type','axes');
all_obj = findobj(hObj.Parent,'Tag','Colorbar');
delete(all_obj);
    
if hObj.Value
    for i = 1:length(all_axes)
        colorbar(all_axes(i),'Tag','Colorbar','Visible','on','Location','southoutside');
    end
end

end