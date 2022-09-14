function boxEvent_Callback(hObj,~,all_axes)

% load('Preferences.mat','GColors');

for k=1:length(all_axes)
    ax = all_axes(k);
    
    if hObj.Value
        % Creation
        all_events = hObj.UserData.all_events;
        S = hObj.UserData.S;
        for index=1:length(all_events)
            xdata = S(index).xdata;
%             ydata = S(index).ydata;
            ydata = [repmat(ax.YLim,[length(xdata)/3,1]),NaN(length(xdata)/3,1)]';
            line('XData',xdata(:),'YData',ydata(:),...'LineWidth',1,'LineStyle','-','Color',GColors.TimeGroups(index).Color,...
                'LineWidth',.1,'LineStyle','-','Color',[.5 .5 .5],...
                'Parent',ax,'Tag','EventBar','HitTest','off');
        end
    else
        % Destruction
        delete(findobj(ax,'Tag','EventBar'))
    end
    
end

end