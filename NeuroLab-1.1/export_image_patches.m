function success = export_image_patches(handles,foldername,val)

success = false;
%global DIR_SAVE FILES CUR_FILE 
%global START_IM END_IM IM CUR_IM;

if exist(fullfile(foldername,'Config.mat'),'file')
    data_config = load(fullfile(foldername,'Config.mat'));
else
    errordlg('Missing file Config.mat [%s].',foldername);
    return;
end

% Default status_visible on (figure visible)
status_visible ='off';
if nargin <3
    % user mode
    val = 1;
    status_visible ='on';
end

folder = fullfile(foldername,'patches');
flag_save = true; % if flag_save save all patches in folder patches
flag_merge = true; % if flag_merge save also merged patches 

if val==1
    % asks confirmation in user mode
    prompt = [{'Export whole region'};{'Save Patches as images'};{'Saving Folder'}];
    dlg_title = 'Export Options';
    num_lines = 1;
    def = [{sprintf('%d',flag_merge)};{sprintf('%d',flag_save)};{sprintf('%s',folder)}];
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    if ~isempty(answer)
        flag_merge = str2num(answer{1});
        flag_save = str2num(answer{2});
        folder = char(answer{3});
    else
        fprintf('Image patches exportation cancelled [%s].\n',foldername);
        return;
    end
end

f = figure('Name','Patch Export','Visible',status_visible);
colormap(f,'gray');
clrmenu(f);
%colormap(f,'jet');
ax = copyobj(handles.CenterAxes,f);
ax.Tag = 'AxExport';
ax.TickLength = [0 0];
ax.XTickLabel = '';
ax.YTickLabel = '';
ax.XLabel.String ='';
ax.YLabel.String ='';
%ax.Title.String = sprintf('Image %d (time %s)',CUR_IM,handles.TimeDisplay.UserData(CUR_IM,:));
ax.Title.String = 'Export Image Patches';
axis(ax,'off');

% Changing main image
% main_im = mean(IM(:,:,START_IM:END_IM),3);
% main_im = IM(:,:,CUR_IM);
main_im = data_config.Current_Image;
im = findobj(ax,'Tag','MainImage');
im.CData = main_im;

% Intialization
all_mask = zeros(size(im.CData));
flag_mask=false;
im.AlphaData = ones(size(main_im));

% Searching patches
% patches = findobj(ax,'Tag','Region');
patches = findobj(ax,'Tag','Region','-or','Tag','RegionGroup');
patches_S = struct('Name',[],'XData',[],'YData',[],'Mask',[]);
%patches = findobj(ax,'Tag','Region','-and','Visible','on');
for i = 1:length(patches)
    flag_mask=true;
    patches(i).Visible = 'on';
    patches(i).EdgeColor = patches(i).FaceColor;
    patches(i).FaceColor ='none';
    patches(i).LineWidth = 1;
    %patches(i).FaceAlpha = 0;
    all_mask = all_mask + patches(i).UserData.UserData.Mask;
    
    patches_S(i).Name = patches(i).UserData.UserData.Name;
    patches_S(i).Mask = patches(i).UserData.UserData.Mask;
    patches_S(i).XData = patches(i).XData;
    patches_S(i).YData = patches(i).YData;
end

% if patches are found create whole patch
im.AlphaData = ones(size(main_im));
if flag_mask 
    all_mask = sign(all_mask);
    %im.AlphaData = bwconvhull(all_mask);
    % Creating patch whole
    [x,y]= find(all_mask'==1);
    hull = convhull(x,y);
    patch_x = x(hull);
    patch_y = y(hull);
    patch(patch_x,patch_y,[0 0 0],'FaceAlpha',0,...
        'EdgeColor',[.5 .5 .5],'LineWidth',1,...
        'Tag','Region','Parent',ax);
end

% Axis CLim
%data = im.CData(:).*im.AlphaData(:);
%ax.CLim = [min(data,[],'omitnan'),max(data,[],'omitnan')];

ax.CLim = handles.CenterAxes.CLim;
%colorbar(ax,'eastoutside');

load('Preferences.mat','GTraces');
if flag_save
    %folder = 'patches';
    if exist(folder,'dir')
        rmdir(folder,'s');
    end
    mkdir(folder);
    f2=figure(100);
    ax = axes('Parent',f2);
    ax.YDir = 'reverse';
    ax.Box = 'on';
    %ax.BackgroundColor = [0 0 0];
    ax.XTickLabel = '';
    ax.YTickLabel = '';
    ax.TickLength = [0 0];
    ax.Position = [0 0 1 1];
    ax.XColor = 'none';
    ax.YColor = 'none';
    
    for i = 1:length(patches)
        p = copy(patches(i),ax);
        p.FaceColor = 'none';
        p.FaceAlpha = 1;
        %p.EdgeColor = 'none';
        %p.LineStyle = 'none';
        p.EdgeColor = [0.5 0.5 0.5];
        p.LineStyle = '-';
        p.LineWidth = 2;
        ax.XLim = handles.CenterAxes.XLim;
        ax.YLim = handles.CenterAxes.YLim;
        %pic_name = sprintf('Mask_%03d',i);
        pic_name = sprintf('Mask_%s',p.UserData.UserData.Name);
         
        saveas(f2,fullfile(folder,pic_name),GTraces.ImageSaveFormat);
        fprintf('Image saved at %s.\n',fullfile(folder,pic_name));
        delete(p);
    end
    save(fullfile(folder,'Patches.mat'),'patches_S');
    
    %Merge patches
    if flag_merge
        sorted=unique(regexprep({patches_S(:).Name}','-L|-R',''));
        for i = 1:length(sorted)
            pattern = sorted(i);
            ind = contains({patches_S(:).Name}',pattern);
            retained = patches_S(ind);
            if length(retained)>1
                for j=1:length(retained)
                    p = patch('XData',retained(j).XData,'YData',retained(j).YData,'Parent',ax);
                    p.FaceColor = 'none';
                    p.FaceAlpha = 1;
                    p.EdgeColor = [0.5 0.5 0.5];
                    %p.LineStyle = 'none';
                    p.LineStyle = '-';
                    p.LineWidth = 2;
                end
                pic_name = sprintf('Mask_%s',char(pattern));
                saveas(f2,fullfile(folder,pic_name),GTraces.ImageSaveFormat);
                fprintf('Image saved at %s.\n',fullfile(folder,pic_name));
                delete(findobj(ax,'Type','Patch'));
            end
        end
    end
    
    close(f);
    close(f2);
end

success = true;

end