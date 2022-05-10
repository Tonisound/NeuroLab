function boxPatch_Callback(src,~,handles)
% 402 -- Callback Label CheckBox

% load('Preferences.mat','GColors');
% % Find all visible patches
% hm1 = findobj(handles.CenterAxes,'Type','Patch','-and','Tag','Region');
% hm2 = findobj(handles.CenterAxes,'Type','Patch','-and','Tag','RegionGroup');
% hm = [hm1;hm2];
% 
% for i=1:length(hm)
%     if src.Value
%         hm(i).FaceAlpha = GColors.patch_transparency;
%         hm(i).EdgeColor = GColors.patch_color;
%         hm(i).LineWidth = GColors.patch_width;
%         hm(i).Visible ='on';  
%     else
%         hm(i).Visible = 'off'; 
%     end
% end

load('Preferences.mat','GColors');
% Find all visible traces
hm = findobj(handles.RightAxes,'Tag','Trace_Region',...
    '-or','Tag','Trace_RegionGroup',...
    '-or','Tag','Trace_Pixel',...
    '-or','Tag','Trace_Box');

for i=1:length(hm)
    p = hm(i).UserData.Graphic;
    if src.Value  && strcmp(hm(i).Visible,'on')
        p.Visible ='on';
        if strcmp(p.Tag,'Region') || strcmp(p.Tag,'RegionGroup')
            p.FaceAlpha = GColors.patch_transparency;
            p.EdgeColor = GColors.patch_color;
            p.LineWidth = GColors.patch_width;
        end
    else
        %hm(i).Visible = 'off';
        p.Visible = 'off';
    end
end

end