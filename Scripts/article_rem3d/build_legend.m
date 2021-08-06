close all
f = figure;
f.PaperPositionMode='manual';
f.Units = 'normalized';
f.Position = [.1 .1 .2 .8];

ax = axes('Parent',f);
f.PaperType = 'A4';
L = get_lists('ALL','GROUPS');
list_regions = L.list_regions;
f_colors = f.Colormap(round(1:64/length(list_regions):64),:);

inverted = true;
if inverted
    list_regions = flipud(L.list_regions);
    f_colors = flipud(f_colors);
end

hold(ax,'on');
for i=1:length(list_regions)
    b = bar(i,1,'Parent',ax);
    b.FaceColor = f_colors(i,:);
end
ax.XLim =[.5 length(list_regions)+.5];
%bar(diag(ones(length(list_regions),1)),'Parent',ax);
leg = legend(ax,list_regions);
leg.Location = 'eastoutside';
