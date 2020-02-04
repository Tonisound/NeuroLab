function boxAtlas_Callback(src,~,handles)
% 404 -- Callback Atlas CheckBox

%global DIR_SAVE FILES CUR_FILE;
atlasmask = findobj(handles.CenterAxes,'Tag','AtlasMask');

for i=1:length(atlasmask)
    if src.Value
        atlasmask(i).Visible = 'on';
    else
        atlasmask(i).Visible = 'off';
    end
end

end