function actualize_line_aspect(lines)

load('Preferences.mat','GColors','GDisp');
coeff_increase = GDisp.coeff_increase;

for i = 1:length(lines)
    l = lines(i);
    fprintf('Selected Object: [%s - %s].\n',l.UserData.Name,l.Tag)
    switch l.Tag
        case {'Trace_Box','Movable_Trace_Box'}
            % patch
            if l.UserData.Selected == 1
                l.UserData.Graphic.EdgeColor = char2rgb('w');
                %l.LineWidth = 2;
                l.LineWidth=coeff_increase*l.LineWidth;
                uistack(l,'top');
                
            else
                l.UserData.Graphic.EdgeColor = char2rgb('k');
                %l.LineWidth = 1;
                l.LineWidth=l.LineWidth/coeff_increase;
            end
            
        case {'Trace_Pixel','Movable_Trace_Pixel'}
            % pixel
            if l.UserData.Selected == 1
                l.UserData.Graphic.MarkerEdgeColor = char2rgb('w');
                %l.LineWidth = 2;
                l.LineWidth=coeff_increase*l.LineWidth;
                uistack(l,'top');
                
            else
                l.UserData.Graphic.MarkerEdgeColor = char2rgb('k');
                %l.LineWidth = 1;
                l.LineWidth=l.LineWidth/coeff_increase;
            end
            
        case {'Trace_Region';'Trace_RegionGroup'}
            % region
            if l.UserData.Selected == 1
                l.UserData.Graphic.EdgeColor = char2rgb('w');
                l.UserData.Graphic.LineWidth = 2*GColors.patch_width;
                l.UserData.Graphic.FaceAlpha = 2*GColors.patch_transparency;
                l.LineWidth=l.LineWidth*coeff_increase;
            else
                l.UserData.Graphic.EdgeColor = GColors.patch_color;
                l.UserData.Graphic.LineWidth = GColors.patch_width;
                l.UserData.Graphic.FaceAlpha = GColors.patch_transparency;
                l.LineWidth=l.LineWidth/coeff_increase;
            end
        case {'Trace_Cerep';'Trace_Mean'}
            % Trace_Cerep, Trace_Mean
            if l.UserData.Selected == 1
                l.LineWidth=coeff_increase*l.LineWidth;
%                uistack(hObj.UserData,'top');
            else
                l.LineWidth=l.LineWidth/coeff_increase;
            end
    end

end


end