% close all;
global IM;

im_sequence_1 = 2000:1:2049;
im_sequence_2 = 4831:60:5400;
im_sequence_3 = 12031:60:12600;
im_sequence_4 = 5934:10:6033;
im_sequence = [im_sequence_1,im_sequence_2,im_sequence_3];
im_sequence = im_sequence_4;

n_colums = 5;
n_rows = ceil(length(im_sequence)/n_colums);

f=figure;
colormap(f,'hot');

counter=0;
for i = im_sequence
    counter=counter+1;
    ax = subplot(n_rows,n_colums,counter,'Parent',f);
    imagesc(IM(:,:,i));
    ax.Title.String = myhandles.TimeDisplay.UserData(i,1:end);
    ax.CLim = [-20 40];
    set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
    ax.XLim = [40 120];
    grid(ax,'off');
    if i==im_sequence(end)
        colorbar(ax,'southoutside');
    end
end