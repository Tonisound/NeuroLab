f = figure;
colormap(f,'hot');
l_reg = flipud(findobj(myhandles.RightAxes,'Tag','Trace_Region'));
bin_size = 1200;

for i =1:length(l_reg)
    ax = subplot(1,length(l_reg),i);
    temp= l_reg(i).YData(1:end-1)';
    temp2 = reshape(temp,[bin_size,length(temp)/bin_size]);
    imagesc(temp2','Parent',ax);
    ax.CLim = [-10 150];
    ax.Title.String = l_reg(i).UserData.Name;
    colorbar(ax,'southoutside');

    if i==1
        indexes= 1:bin_size:length(temp);
        ax.YTick = 1:length(indexes);
        ax.YTickLabel = myhandles.TimeDisplay.UserData(indexes,:);
    end
end