function f = interactive_plot_Fig2C

data = load('RevisedFigure2\RevisedFig2C_ALL-GROUPS.mat','S');
S = data.S;
f = figure;

ax1 = subplot(131,'Parent',f,'Tag','Ax1');
ax2 = subplot(132,'Parent',f,'Tag','Ax2');
ax3 = subplot(133,'Parent',f,'Tag','Ax3');
ax1.Position = [.025 .05 .3 .8];
ax2.Position = [.35 .05 .3 .8];
ax3.Position = [.675 .05 .3 .8];

list1 = [];
list2 = [];
for i=1:length(S)
    list1 = [list1 ; S(i,1).recording];
    list2 = [list2 ; strcat(repmat(S(i,1).recording,length(S(i,1).episode),1),'---',S(i,1).episode)];
end

pu1 = uicontrol('Units','normalized','Parent',f,'Style','popup','String',list1);
pu2 = uicontrol('Units','normalized','Parent',f,'Style','popup','String',list2);
pu1.Position = [.05 .95 .4 .05];
pu2.Position = [.55 .95 .4 .05];

handles = guihandles(f);
pu1.Callback = {@pu1_Callback,handles,S};
pu2.Callback = {@pu2_Callback,handles,S};

f.Units = 'normalized';
f.Position = [0.0380    0.5065    0.8662    0.3981];
pu1_Callback(pu1,[],handles,S);

end

function pu1_Callback(hObj,~,handles,S)

color_atlas = 'r';
linewidth_atlas = .5;

str_file = strtrim(hObj.String(hObj.Value,:));
all_recordings = [];
for i=1:length(S)
    all_recordings = [all_recordings ; S(i,1).recording];
end
index_rec = find(strcmp(all_recordings,str_file)==1);

ax1 = handles.Ax1;
ax2 = handles.Ax2;
ax3 = handles.Ax3;

cur_file = S(index_rec,1).recording;

cla(ax1);
imagesc(S(index_rec,1).Doppler_rec,'Parent',ax1);
hold(ax1,'on');
plot(S(index_rec,1).line_x,S(index_rec,1).line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax1);
ax1.Title.String = S(index_rec,1).group;
ax1.CLim = [0,1];
ax1.XTick = [];
ax1.XTickLabel = '';
ax1.YTick = [];
ax1.YTickLabel = '';
colorbar(ax1);

cla(ax2);
imagesc(S(index_rec,2).Doppler_rec,'Parent',ax2);
hold(ax2,'on');
plot(S(index_rec,2).line_x,S(index_rec,2).line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax2);
ax2.Title.String = S(index_rec,2).group;
ax2.CLim = [0,1];
ax2.XTick = [];
ax2.XTickLabel = '';
ax2.YTick = [];
ax2.YTickLabel = '';
colorbar(ax2);

cla(ax3);
imagesc(S(index_rec,2).Doppler_rec-S(index_rec,1).Doppler_rec,'Parent',ax3);
hold(ax3,'on');
plot(S(index_rec,2).line_x,S(index_rec,2).line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax3);
ax3.Title.String = 'DIFF';
ax3.CLim = [0,1];
ax3.XTick = [];
ax3.XTickLabel = '';
ax3.YTick = [];
ax3.YTickLabel = '';
colorbar(ax3);

drawnow;

end

function pu2_Callback(hObj,~,handles,S)

color_atlas = 'r';
linewidth_atlas = .5;

str_file = strtrim(hObj.String(hObj.Value,:));
temp = regexp(char(str_file),'---','split');
cur_file = char(temp(1));
cur_ep = char(temp(end));

all_recordings = [];
for i=1:length(S)
    all_recordings = [all_recordings ; S(i,1).recording];
end
index_rec = find(strcmp(all_recordings,cur_file)==1);
index_ep = find(strcmp(S(index_rec,1).episode,cur_ep)==1);

ax1 = handles.Ax1;
ax2 = handles.Ax2;
ax3 = handles.Ax3;


cla(ax1);
imagesc(S(index_rec,1).Doppler_ep(:,:,index_ep),'Parent',ax1);
hold(ax1,'on');
plot(S(index_rec,1).line_x,S(index_rec,1).line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax1);
ax1.Title.String = S(index_rec,1).group;
ax1.CLim = [0,1];
ax1.XTick = [];
ax1.XTickLabel = '';
ax1.YTick = [];
ax1.YTickLabel = '';
colorbar(ax1);

cla(ax2);
imagesc(S(index_rec,2).Doppler_ep(:,:,index_ep),'Parent',ax2);
hold(ax2,'on');
plot(S(index_rec,2).line_x,S(index_rec,2).line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax2);
ax2.Title.String = S(index_rec,2).group;
ax2.CLim = [0,1];
ax2.XTick = [];
ax2.XTickLabel = '';
ax2.YTick = [];
ax2.YTickLabel = '';
colorbar(ax2);

cla(ax3);
imagesc(S(index_rec,2).Doppler_ep(:,:,index_ep)-S(index_rec,1).Doppler_ep(:,:,index_ep),'Parent',ax3);
hold(ax3,'on');
plot(S(index_rec,2).line_x,S(index_rec,2).line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax3);
ax3.Title.String = 'DIFF';
ax3.CLim = [0,1];
ax3.XTick = [];
ax3.XTickLabel = '';
ax3.YTick = [];
ax3.YTickLabel = '';
colorbar(ax3);

drawnow;

end