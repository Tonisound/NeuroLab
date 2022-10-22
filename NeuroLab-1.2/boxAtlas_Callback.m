function boxAtlas_Callback(src,~,ax)
% 404 -- Callback Atlas CheckBox

global FILES CUR_FILE;

load('Preferences.mat','GColors');
atlasmask = findobj(ax,'Tag','AtlasMask');
if ~isempty(atlasmask)
    atlasmask.PickableParts = 'none';
end

if strcmp(FILES(CUR_FILE).atlas_name,'Rat Coronal Paxinos') || strcmp(FILES(CUR_FILE).atlas_name,'Mouse Coronal Paxinos')
    atlas_string = sprintf('Coronal AP = %.2f mm',FILES(CUR_FILE).atlas_coordinate);
elseif strcmp(FILES(CUR_FILE).atlas_name,'Rat Sagittal Paxinos') || strcmp(FILES(CUR_FILE).atlas_name,'Mouse Sagittal Paxinos')
    atlas_string = sprintf('Sagittal ML = %.2f mm',FILES(CUR_FILE).atlas_coordinate);
else
    atlas_string = [];
end
 

% update line aspect
for i=1:length(atlasmask)
    
    if src.Value
        atlasmask(i).LineWidth = GColors.atlas_width;
        atlasmask(i).Color = GColors.atlas_color;
        atlasmask(i).Color(4) = GColors.atlas_transparency;
        atlasmask(i).Visible = 'on';
        ax.Title.String = atlas_string;
    else
        atlasmask(i).Visible = 'off';
        ax.Title.String = [];
    end
end

end