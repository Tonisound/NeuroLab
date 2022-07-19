function f = interactive_plot_Fig3A

data = load('Figure3\Fig3_ALL-GROUPS.mat','R','L');
R = data.R;
L = data.L;
f = figure;
clrmenu(f);
colormap(f,'jet')

list_ref = L.list_ref;
list_files = L.list_files;

ax1 = subplot(131,'Parent',f,'Tag','Ax1');
ax2 = subplot(132,'Parent',f,'Tag','Ax2');
ax3 = subplot(133,'Parent',f,'Tag','Ax3');
ax1.Position = [.025 .05 .3 .8];
ax2.Position = [.35 .05 .3 .8];
ax3.Position = [.675 .05 .3 .8];

pu1 = uicontrol('Units','normalized','Parent',f,'Style','popup','String',list_files,'Tag','Popup0');
pu1.Position = [.05 .95 .4 .05];
pu2 = uicontrol('Units','normalized','Parent',f,'Style','popup','Value',1,'String',list_ref,'Tag','Popup1');
pu2.Position = [.55 .95 .2 .05];
pu3 = uicontrol('Units','normalized','Parent',f,'Style','popup','Value',2,'String',list_ref,'Tag','Popup2');
pu3.Position = [.75 .95 .2 .05];
cb1 = uicontrol('Units','normalized','Parent',f,'Style','checkbox','ToolTipString','Atlas on/off','Tag','Checkbox1','Value',0);
cb1.Position = [0 .95 .05 .05];

handles = guihandles(f);
pu1.Callback = {@pu1_Callback,handles,R,L};
pu2.Callback = {@pu1_Callback,handles,R,L};
pu3.Callback = {@pu1_Callback,handles,R,L};
cb1.Callback = {@cb1_Callback,handles};

f.Units = 'normalized';
f.Position = [0.0380    0.5065    0.8662    0.3981];
pu1_Callback([],[],handles,R,L);

end

function cb1_Callback(hObj,~,handles)

all_axes = [handles.Ax1; handles.Ax2; handles.Ax3];
all_atlas = findobj(all_axes,'Tag','Atlas');
    
if hObj.Value
    status = 'on';
else
    status = 'off';
end
for i = 1:length(all_atlas)
    all_atlas(i).Visible = status;
end

end

function pu1_Callback(~,~,handles,R,L)

dir_save = 'F:\Antoine\OneDrive - McGill University\Antoine-fUSDataset\NEUROLAB\NLab_DATA';

color_atlas = 'k';
linewidth_atlas = .5;

hObj = handles.Popup0;
pu1 = handles.Popup1;
pu2 = handles.Popup2;
all_recordings = hObj.String;
cur_file = char(strtrim(hObj.String(hObj.Value,:)));

fprintf('Loading Atlas [File: %s] ... ',cur_file);
data_atlas = load(fullfile(dir_save,cur_file,'Atlas.mat'));
fprintf('done.\n');

% Loading alphamap
data_mask = [];
if exist(fullfile(dir_save,cur_file,'Sources_fUS','Whole-reg.mat'),'file')
    data_mask = load(fullfile(dir_save,cur_file,'Sources_fUS','Whole-reg.mat'));
    data_mask.mask(data_mask.mask==0)=NaN;
end

ref1 = char(strtrim(pu1.String(pu1.Value,:)));
ref2 = char(strtrim(pu2.String(pu2.Value,:)));

index_ref1 = find(strcmp(L.list_ref,ref1)==1);
index_ref2 = find(strcmp(L.list_ref,ref2)==1);
index_rec = find(strcmp(all_recordings,cur_file)==1);

ax1 = handles.Ax1;
ax2 = handles.Ax2;
ax3 = handles.Ax3;

if handles.Checkbox1.Value
    status = 'on';
else
    status = 'off';
end

cla(ax1);
im1 = imagesc(R(index_rec,index_ref1).Rmax_map,'Parent',ax1);
hold(ax1,'on');
plot(data_atlas.line_x,data_atlas.line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax1,'Tag','Atlas','Visible',status);
ax1.Title.String = ref1;
ax1.CLim = [-.4,.8];
ax1.XTick = [];
ax1.XTickLabel = '';
ax1.YTick = [];
ax1.YTickLabel = '';
colorbar(ax1);

cla(ax2);
im2 = imagesc(R(index_rec,index_ref2).Rmax_map,'Parent',ax2);
hold(ax2,'on');
plot(data_atlas.line_x,data_atlas.line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax2,'Tag','Atlas','Visible',status);
ax2.Title.String = ref2;
ax2.CLim = [-.4,.8];
ax2.XTick = [];
ax2.XTickLabel = '';
ax2.YTick = [];
ax2.YTickLabel = '';
colorbar(ax2);

cla(ax3);
im3 = imagesc(R(index_rec,index_ref1).Rmax_map-R(index_rec,index_ref2).Rmax_map,'Parent',ax3);
hold(ax3,'on');
plot(data_atlas.line_x,data_atlas.line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax3,'Tag','Atlas','Visible',status);
ax3.Title.String = sprintf('%s - %s',ref1,ref2);
ax3.CLim = [-.4,.4];
ax3.XTick = [];
ax3.XTickLabel = '';
ax3.YTick = [];
ax3.YTickLabel = '';
colorbar(ax3);

if ~isempty(data_mask)
    im1.CData = im1.CData .* data_mask.mask;
    im2.CData = im2.CData .* data_mask.mask;
    im3.CData = im3.CData .* data_mask.mask;
end

drawnow;

end
