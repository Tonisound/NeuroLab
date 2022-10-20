function boxTimePatch_Callback(hObj,~,all_axes)

load('Preferences.mat','GColors');
for k=1:length(all_axes)
    ax = all_axes(k);
    all_patches = findobj(ax,'Tag','TimePatch');
    
    for i =1:length(all_patches)
        cur_patch = all_patches(i);
        cur_patch.PickableParts = 'none';
        ind_group = find(strcmp({GColors.TimeGroups(:).Name}',cur_patch.UserData.Name)==1);
        if hObj.Value
            if ~isempty(ind_group)
                cur_patch.FaceColor = GColors.TimeGroups(ind_group).Color;
                cur_patch.EdgeColor = 'none';
                cur_patch.FaceAlpha = GColors.TimeGroups(ind_group).Transparency;
                cur_patch.YData = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            end
            if GColors.TimeGroups(ind_group).Visible
                cur_patch.Visible='on';
            else
                cur_patch.Visible='off';
            end
        else
            cur_patch.Visible='off';
        end
    end
end

end