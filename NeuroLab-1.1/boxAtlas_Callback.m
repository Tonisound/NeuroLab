function boxAtlas_Callback(src,~,ax)
% 404 -- Callback Atlas CheckBox

load('Preferences.mat','GColors');
atlasmask = findobj(ax,'Tag','AtlasMask');

% update line aspect

for i=1:length(atlasmask)
    
    if src.Value
        atlasmask(i).LineWidth = GColors.atlas_width;
        atlasmask(i).Color = GColors.atlas_color;
        atlasmask(i).Color(4) = GColors.atlas_transparency;
        atlasmask(i).Visible = 'on';
    else
        atlasmask(i).Visible = 'off';
    end
end

end