function f =  display_stats(handles)

f = figure

ax = subplot(2,1,1,'Parent',f)
hold on;
b = bar(r_max(2:end))
labels
ax.XTickLabel=labels
ax.XTick=1:length(labels)
ax.XTickLabelRotation=90
ax.XTick=2:length(labels)
ax.XTick=0:length(labels)
ax.XTickLabel=labels(2:end)
ax.XTick=1:length(labels)
ax.Title.String = char(labels(1))
ax.YLim = [0,1]

ax = subplot(2,1,'Parent',f)
hold on;
imagesc(handles.Ax1)
end