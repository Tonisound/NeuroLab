% close all;
global IM;

im_sequence_1 = 1231:60:1800;
im_sequence_2 = 4831:60:5400;
im_sequence_3 = 12031:60:12600;
im_sequence_4 = 12481:10:12600;
im_sequence = [im_sequence_1,im_sequence_2,im_sequence_3];
im_sequence = im_sequence_4;

n_colums = 6;
n_rows = ceil(length(im_sequence)/n_colums);

f=figure;
colormap(f,'gray');

counter=0;
for i = im_sequence
    counter=counter+1;
    ax = subplot(n_rows,n_colums,counter,'Parent',f);
    imagesc(IM(:,:,i));
    ax.Title.String = myhandles.TimeDisplay.UserData(i,1:end-4);
    ax.CLim = [-10 150];
    set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
    ax.XLim = [40 120];
    grid(ax,'off');
end