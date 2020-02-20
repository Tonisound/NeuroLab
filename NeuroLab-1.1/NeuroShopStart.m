function success = NeuroShopStart(savedir,file_recording,handles,val)
% Script written by Thomas Deffieux
% Edited by Antoine Bergel to run on NeuroLab
% 16/09/2018

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
success = false;
if nargin < 4
    val=1;
end

setappdata(0,'UseNativeSystemDialogs',0);
% global variables
clear global NeuroShop
global NeuroShop;
set(0,'DefaultLineLineSmoothing','on')
set(0,'DefaultPatchLineSmoothing','on')

% Position = [563 742 800 600];
Position = [400 100 800 600];
H = 750;

% Figure creation
fig = figure('units', 'pixels', ...
    'Position', Position, ...
    'name', 'NeuroShop', ...
    'menubar','none',...
    'Color',[0.9 0.9 1],...
    'NumberTitle','off');
%fig.UserData.success = false;
fig.UserData.val = val;

% Trying to load Neuroshop
if exist(fullfile(savedir,'Atlas.mat'),'file')
    d = load(fullfile(savedir,'Atlas.mat'));
    fprintf('Loading existing mask [%s].\n',fullfile(savedir,'Atlas.mat'));
else
    d=[];
end

if ~isempty(d) && isfield(d,'xyfig')
    
    NeuroShop.AtlasType = d.AtlasType;
    NeuroShop.AtlasName = d.AtlasName;
    NeuroShop.AtlasOn = d.AtlasOn;
    NeuroShop.BregmaXY = d.BregmaXY;
    NeuroShop.BregmaZ = d.BregmaZ;
    NeuroShop.scaleX = d.scaleX;
    NeuroShop.scaleY = d.scaleY;
    NeuroShop.scaleZ = d.scaleZ;
    NeuroShop.theta = d.theta;
    NeuroShop.phi = d.phi;
    NeuroShop.xyfig = d.xyfig;
    NeuroShop.PatchCorner = d.PatchCorner;
else
    NeuroShop.AtlasType = 1;      % 1 = rat coronal ; 2 = rat sagital ; 3 =  souris coronal ; 4 = souris sagital
    NeuroShop.AtlasName = 'RatAtlasCor';
    NeuroShop.AtlasOn = 1;
end

NeuroShop.JustMoved = 0;
NeuroShop.fig = fig;
NeuroShop.CustomROIs.Nb = 0;
NeuroShop.MaskType = 0;
NeuroShop.MaskErodeSize = 0;  % mm
NeuroShop.MaskDiskNx = 15;
NeuroShop.MaskDiskNz = 10;
NeuroShop.MaskDiskWidth = 14; % mm
NeuroShop.MaskDiskDepth = 10; % mm

% ceci est un test
% Text buttons creation
figure(fig);
hold on;
NeuroShop.axText=axes('Position',[0 0 1 1],'TickDir','out');
NeuroShop.hmsg = text(100,H/3,'[Loading Atlas data...]','Units','Pixels','FontSize',16,'Color',[0.6 0.6 0.6]);

f = uimenu('Label','File');
uimenu(f,'Label','Load Doppler data','Callback',{@NeuroShop_LoadImage,savedir});
uimenu(f,'Label','Save Doppler with Masks','Callback',@NeuroShop_SaveImageDoppler);
uimenu(f,'Label','Quit','Callback',@NeuroShop_Quit);

a = uimenu('Label','Atlas');
uimenu(a,'Label','Rat - coronal','Callback',{@NeuroShop_LoadAtlas,1});
uimenu(a,'Label','Rat - sagittal','Callback',{@NeuroShop_LoadAtlas,2});
uimenu(a,'Label','Mouse - coronal','Callback',{@NeuroShop_LoadAtlas,3},'Separator','on');
uimenu(a,'Label','Mouse - sagittal','Callback',{@NeuroShop_LoadAtlas,4});
uimenu(a,'Label','Mouse - coronal - Allen','Callback',{@NeuroShop_LoadAtlas,5},'Separator','on');
uimenu(a,'Label','Toggle Atlas','Callback',{@NeuroShop_LoadAtlas,6},'Separator','on','Accelerator','b');
uimenu(a,'Label','Atlas Settings','Callback',@NeuroShop_AtlasSett);

t = uimenu('Label','ROI');
uimenu(t,'Label','Draw ROIs','Callback',@DrawROIs);
uimenu(t,'Label','Remove ROI','Callback',@RemoveROI);
uimenu(t,'Label','Edit ROI','Callback',@EditROI);
%uimenu(t,'Label','Select ROIs','Callback',@SelectROIs);
uimenu(t,'Label','Load ROIs','Callback',@NeuroShop_LoadROIsDef,'Separator','on');
uimenu(t,'Label','Save ROIs','Callback',@NeuroShop_SaveROIsDef);
uimenu(t,'Label','Mirror + reorder','Callback',{@AutoSymmetryROIs,1},'Separator','on');
uimenu(t,'Label','Mirror + reorder, cortex first','Callback',{@AutoSymmetryROIs,2});
uimenu(t,'Label','Reorder ROIs','Callback',@ClickToOrder,'Separator','on');

m = uimenu('Label','Mask');
uimenu(m,'Label','View Doppler','Callback',{@CreateMask,0});
uimenu(m,'Label','Atlas based Mask','Callback',{@CreateMask,1},'Separator','on');
uimenu(m,'Label','ROI based Mask','Callback',{@CreateMask,3});
uimenu(m,'Label','Unsupervised Mask','Callback',{@CreateMask,2});
uimenu(m,'Label','Export Mask','Callback',{@NeuroShop_ExportMask,savedir,file_recording,handles},'Separator','on');
uimenu(m,'Label','Config','Callback',@NeuroShop_ConfigMask);

tr = uimenu('Label','Processing');
uimenu(tr,'Label','Correlation Matrix - no filtering','Callback',{@Processing,1});
uimenu(tr,'Label','Correlation Matrix - filtering','Callback',{@Processing_filt,1});
uimenu(tr,'Label','Correlation Matrix - filtering - without GSM1','Callback',{@Processing_GSM1,1});
uimenu(tr,'Label','Lag','Callback',{@Lag,1});
uimenu(tr,'Label','Running Window Correlation Matrix','Callback',{@Running_Window_Processing,1});
uimenu(tr,'Label','Correlation Matrix movie','Callback',{@Corrmat_movie,1});
uimenu(tr,'Label','Export Correlation Matrix','Callback',@NeuroShop_ExportCorrMat);
uimenu(tr,'Label','Do All','Callback',@NeuroShop_DoAll,'Separator','on');
uimenu(tr,'Label','Run All','Callback',@NeuroShop_RunAll);

drawnow;
% default Atlas loading
NeuroShop_LoadAtlas([],[],NeuroShop.AtlasType);

% Image loading
NeuroShop_LoadImage([],[],savedir);

% Wait for figure closing
waitfor(fig);
%NeuroShop.fig.UserData.success = true;
success = true;


end

function NeuroShop_Quit(obj,event)
choice = questdlg('Quit NeuroShop ? ','Quit', 'Yes','Cancel','Cancel');
% Handle response
switch choice
    case 'Yes'
        close all;
end
end

function NeuroShop_ExportMask(obj,event,savedir,file_recording,handles)

global NeuroShop FILES CUR_FILE;

% Loading Config.mat
data_config = load(fullfile(savedir,'Config.mat'));

%[filename,pathname] = uiputfile(fullfile(pathname,'Atlas.mat'),'Save last mask');
filename = 'Atlas.mat';

Mask = NeuroShop.Data.Mask(1:4:end,1:4:end,:);
AtlasType = NeuroShop.AtlasType;
AtlasOn = NeuroShop.AtlasOn;
AtlasName = NeuroShop.AtlasName;
scaleX = NeuroShop.scaleX;
scaleY = NeuroShop.scaleY;
scaleZ = NeuroShop.scaleZ;
FigName = NeuroShop.xyfig;
xyfig = NeuroShop.xyfig;
PatchCorner = NeuroShop.PatchCorner;
BregmaXY = NeuroShop.BregmaXY;
BregmaZ = NeuroShop.BregmaZ;
theta = NeuroShop.theta;
phi = NeuroShop.phi;

% Saving ROIS
[line_x,line_z]=rot(NeuroShop.Atlas.Fig{NeuroShop.xyfig}.XY*NeuroShop.scaleX,...
    NeuroShop.Atlas.Fig{NeuroShop.xyfig}.Z*NeuroShop.scaleZ,NeuroShop.theta);
% rescaling
Doppler=NeuroShop.Data.DopplerView;
Z=(((1:size(Doppler,1))-1)-NeuroShop.BregmaZ)*NeuroShop.Data.drz;
X=(((1:size(Doppler,2))-1)-NeuroShop.BregmaXY)*NeuroShop.Data.dr;

%     line_x = rescale(line_x,0,data_config.Y);
%     line_z = rescale(line_z,0,data_config.X);
line_x = ((line_x-X(1))/(X(end)-X(1)))*data_config.Y;
line_z = ((line_z-Z(1))/(Z(end)-Z(1)))*data_config.X;

% Saving Atlas.mat
if exist(fullfile(savedir,filename),'file')
    delete(fullfile(savedir,filename));
    fprintf('File Atlas.mat updated.\n==> [%s].\n',fullfile(savedir,filename));
else
    fprintf('File Atlas.mat created via Neuroshop.\n==> [%s].\n',fullfile(savedir,filename));
end
save(fullfile(savedir,filename),'Mask','AtlasType','AtlasOn','AtlasName',...
    'scaleX','scaleY','scaleZ','xyfig','FigName','PatchCorner',...
    'BregmaXY','BregmaZ','theta','phi','line_x','line_z');

atlas_type = AtlasType;
if strcmp(AtlasType,'RatAtlasCor')
    atlas_type = 'Coronal';
end
if strcmp(AtlasType,'RatAtlasSag')
    atlas_type = 'Sagittal';
end
% updating config.mat
data_c = load(fullfile(savedir,'Config.mat'),'File');
File = data_c.File;
File.atlas_type = atlas_type;
File.bregma_xy = BregmaXY;
File.bregma_z = BregmaZ;
FILES(CUR_FILE)=File;
save(fullfile(savedir,'Config.mat'),'File','-append');
fprintf('File Config.mat updated [%s].\n',fullfile(savedir,'Config.mat'));

%Exporting Mask atlas
linewidth = 1;
atlascolor = 'w';
transparency = 1;
delete(findobj(handles.CenterAxes,'Tag','AtlasMask'));
l = line('XData',line_x,'YData',line_z,'Tag','AtlasMask',...
    'LineWidth',linewidth,'Color',atlascolor,'Parent',handles.CenterAxes);
l.Color(4) = transparency;
boxAtlas_Callback(handles.AtlasBox,[],handles.CenterAxes);

% if NeuroShop.fig.UserData.val == 1
%     close(NeuroShop.fig);
% end 
close(NeuroShop.fig);
% Converting masks in binary files
convert_neuroshop_masks(savedir,file_recording,handles);

end

function NeuroShop_LoadImage(obj,event,savedir)

global NeuroShop;
filename = 'Doppler.mat';

NeuroShop.dopplerfile = filename(1:end-4);
%a=load([pathname filename],'-mat');
a=load(fullfile(savedir,filename),'-mat');
f=fieldnames(a);
for i=1:length(f)
    tmp=squeeze(getfield(a,f{i}));
    if ndims(tmp)==3
        % Doppler_dB
        %image = 20*log10(abs(tmp(:,:,CUR_IM))/max(max(abs(tmp(:,:,1)))));
        %NeuroShop.Data.DopplerView=image;
        NeuroShop.Data.DopplerView=(mean((tmp(:,:,1)),3));
        NeuroShop.Data.DopplerFilm=tmp;
    end
    %         if ndims(tmp)==2
    %             NeuroShop.Data.DopplerView=sqrt((abs(tmp)));
    %         end
end

if ~isfield(NeuroShop.Data,'dr')
    NeuroShop.Data.dr=0.08;
    NeuroShop.Data.drz=0.1;
end

%     prompt = {'dx (mm) :','dz (mm)'};
%     dlg_title = 'Image Setup';
%     num_lines = 1;
%     def = {num2str(NeuroShop.Data.dr),num2str(NeuroShop.Data.drz)};
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
%     if ~isempty(answer)
%         NeuroShop.Data.dr=str2num(answer{1});
%         NeuroShop.Data.drz=str2num(answer{2});
%     end

NeuroShop.MaskVisibility=0;
UpdateView();

end

function NeuroShop_LoadAtlas(obj,event,type)
global NeuroShop
switch type
    case 1
        %load('./Atlas/Rat/AtlasCor.mat');
        load('AtlasCor.mat');
        NeuroShop.AtlasName='RatAtlasCor';
        NeuroShop.Atlas=AtlasCor;
        for fig=1:length(NeuroShop.Atlas.Fig);
            for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id);
                NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.x;
            end;
        end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.X;
        NeuroShop.Atlas.V=NeuroShop.Atlas.Y;
    case 2
        %load('./Atlas/Rat/AtlasSag.mat');
        load('AtlasSag.mat');
        NeuroShop.AtlasName='RatAtlasSag';
        NeuroShop.Atlas=AtlasSag;
        for fig=1:length(NeuroShop.Atlas.Fig);for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id);NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.y;end;end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.Y;
        NeuroShop.Atlas.V=NeuroShop.Atlas.X;
    case 3
        %load('./Atlas/Mouse/MouseAtlasCor.mat');
        load('MouseAtlasCor.mat');
        NeuroShop.AtlasName='MouseAtlasCor';
        NeuroShop.Atlas=AtlasCor;
        for fig=1:length(NeuroShop.Atlas.Fig);for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id);NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.x;end;end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.X;
        NeuroShop.Atlas.V=NeuroShop.Atlas.Y;
    case 4
        %load('./Atlas/Mouse/MouseAtlasSag.mat');
        load('MouseAtlasSag.mat');
        NeuroShop.AtlasName='MouseAtlasSag';
        NeuroShop.Atlas=AtlasSag;
        for fig=1:length(NeuroShop.Atlas.Fig);for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id);NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.y;end;end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.Y;
        NeuroShop.Atlas.V=NeuroShop.Atlas.X;
    case 5
        %load('./Atlas/Mouse/MouseAtlasCorAllen.mat');
        load('MouseAtlasCorAllen.mat');
        NeuroShop.AtlasName='MouseAtlasCorAllen';
        NeuroShop.Atlas=AtlasCor;
        for fig=1:length(NeuroShop.Atlas.Fig);for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id);NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.x;end;end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.X;
        NeuroShop.Atlas.V=NeuroShop.Atlas.Y;
    case 6
        NeuroShop.AtlasOn = ~NeuroShop.AtlasOn;
        type = NeuroShop.AtlasType;
end
NeuroShop.AtlasType=type;

if ~isempty(obj)
    UpdateView();
end
end

function NeuroShop_AtlasSett(obj,event)
global NeuroShop

prompt = {'Figure #:','BregmaXY:','BregmaZ:','Theta:','Scale:'};
dlg_title = 'Atlas Settings';
num_lines = 1;
def = {num2str(NeuroShop.xyfig),num2str(NeuroShop.BregmaXY),num2str(NeuroShop.BregmaZ),num2str(NeuroShop.theta),num2str(NeuroShop.scaleX)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if ~isempty(answer)
    NeuroShop.xyfig=str2num(answer{1});
    NeuroShop.BregmaXY=str2num(answer{2});
    NeuroShop.BregmaZ=str2num(answer{3});
    NeuroShop.theta=str2num(answer{4});
    NeuroShop.scaleX=str2num(answer{5});
    NeuroShop.scaleY=str2num(answer{5});
    NeuroShop.scaleZ=str2num(answer{5});
    UpdateView();
end
end

function NeuroShop_ConfigMask(obj,event)
global NeuroShop


prompt = {'Atlas ROI Erosion (mm) :','Unsupervized disk Nx :','Unsupervized disk Nz :'};
dlg_title = 'Mask Setup';
num_lines = 1;
def = {num2str(NeuroShop.MaskErodeSize),num2str(NeuroShop.MaskDiskNx),num2str(NeuroShop.MaskDiskNz)};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if ~isempty(answer)
    e=str2num(answer{1});
    nx=str2num(answer{2});
    nz=str2num(answer{3});
    
    if NeuroShop.MaskErodeSize~=e
        MaskType=1;
    elseif NeuroShop.MaskDiskNx~=nx | NeuroShop.MaskDiskNz~=nz
        MaskType=2;
    end
    NeuroShop.MaskErodeSize=e;
    NeuroShop.MaskDiskNx=nx;
    NeuroShop.MaskDiskNz=nz;
    
    CreateMask([],[],MaskType);
end

end

function NeuroShop_LoadROIsDef(obj,event)
global NeuroShop
NeuroShop.CustomROIs=[];
[filename,pathname] = uigetfile('ROIs.mat','Load ROIs definition');
if filename~=0
    load([pathname filename],'CustomROIs');
    
    %compatibility fix
    if isfield(CustomROIs.Ids{1},'x')
        for k=1:length(CustomROIs.Ids)
            CustomROIs.Ids{k}.xy=CustomROIs.Ids{k}.x;
            CustomROIs.Ids{k}.z=CustomROIs.Ids{k}.y;
            CustomROIs.Ids{k}.Sym=1;
            CustomROIs.Ids{k}=rmfield(CustomROIs.Ids{k},{'y','x'});
        end
    end
    
    NeuroShop.CustomROIs=CustomROIs;
end
UpdateView();
end

function NeuroShop_SaveROIsDef(obj,event)
global NeuroShop
[filename,pathname] = uiputfile('ROIs.mat','Save ROIs definition');
if filename~=0
    CustomROIs=NeuroShop.CustomROIs;
    save([pathname filename],'CustomROIs');
end
end

function NeuroShop_ExportCorrMat(obj,event)
global NeuroShop
[filename,pathname] = uiputfile('Corr_mat.mat','Export Last Correlation Matrix');
if filename~=0
    Corr_mat=NeuroShop.corr_mat;
    save([pathname filename],'Corr_mat');
end
end

function [u,v]=rot(x,y,angle)
Mrot=[cos(angle) -sin(angle); sin(angle) cos(angle)];
uv=Mrot'*[x;y];
u=uv(1,:);
v=uv(2,:);
end

function NeuroShop_SaveImageDoppler(obj,event)
global NeuroShop
[filename,pathname] = uiputfile('Name.png','Save Doppler with Masks');
if filename~=0
    saveas(gcf,[pathname filename]);
end
end

function NeuroShop_DoAll(obj,event)
global NeuroShop

% print settings
%     disp(NeuroShop.BregmaXY);
%     disp(NeuroShop.BregmaZ);
%     disp(NeuroShop.xyfig);
%     disp(NeuroShop.theta);
%     disp(NeuroShop.scaleX);

% generate data
CreateMask(obj,event,3);
Processing(obj,event,1);

% save all
f = NeuroShop.fig;
filename = ['Resting_state_results/Images/' NeuroShop.dopplerfile ' - image.png'];
saveas(f,filename);

Mask=NeuroShop.Data.Mask(1:4:end,1:4:end,:);
save(['Resting_state_results/Masks/' NeuroShop.dopplerfile ' - masks'],'Mask');

Corr_mat=NeuroShop.corr_mat;
norm_data=NeuroShop.roi_signal_norm;
save(['Resting_state_results/Matrices/' NeuroShop.dopplerfile ' - correlation data'],'Corr_mat','norm_data');

f = figure(2);
set(f,'PaperUnits','inches','PaperSize',[5.6,4.2],'PaperPosition',[0 0 5.6 4.2])
filename = ['Resting_state_results/Matrices/' NeuroShop.dopplerfile ' - correlation image'];
print(f,'-dpng','-r100',filename)

close(2)
end

function NeuroShop_RunAll(obj,event)
global NeuroShop

% Run all files
pathname = 'Resting_state_processed_data/';
table = readtable('Resting_state_results/AtlasData.xls');
list = dir(pathname);

disp(0)
num = length(list)-2;
for i = 42:num
    %load new data
    filename = list(i+2).name;
    NeuroShop.dopplerfile = filename(1:end-4);
    a=load([pathname filename],'-mat');
    f=fieldnames(a);
    tmp=squeeze(getfield(a,f{1}));
    NeuroShop.Data.DopplerView=sqrt(mean(abs(tmp),3));
    NeuroShop.Data.DopplerFilm=tmp;
    
    %set atlas properties
    NeuroShop.xyfig=table{i,2};
    NeuroShop.BregmaXY=table{i,3};
    NeuroShop.BregmaZ=table{i,4};
    NeuroShop.theta=table{i,5};
    NeuroShop.scaleX=table{i,6};
    NeuroShop.scaleY=table{i,6};
    NeuroShop.scaleZ=table{i,6};
    UpdateView();
    
    %run
    NeuroShop_DoAll(obj,event);
    disp(i/num*100);
    
end
end