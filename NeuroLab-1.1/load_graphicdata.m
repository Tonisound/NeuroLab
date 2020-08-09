function success = load_graphicdata(savedir,handles)
% Load graphic Objects
% If Graphic_objects.mat exists
% Else Use Config.fig

load('Preferences.mat','GTraces');
load_fmt = GTraces.GraphicLoadFormat;
success = false;
tic;

fprintf('Loading Graphic Data ...\n');
if exist(fullfile(savedir,'Trace_light.mat'),'file')
    switch load_fmt
        case 'Graphic_objects.mat'
            data = load(fullfile(savedir,'Trace_light.mat'),'h');
            copy_graphicdata(data.h(2),handles.CenterAxes,handles.RightAxes,'loading',savedir);
            fprintf('Graphic Data loaded %s.\n',fullfile(savedir,'Trace_light.mat'));
        case 'Graphic_objects_full.mat'
            data1 = load(fullfile(savedir,'Trace_light.mat'),'h');
            fprintf('Graphic Data loaded %s.\n',fullfile(savedir,'Trace_light.mat')); 
            try
                data2 = load(fullfile(savedir,'Trace_LFP.mat'),'h');
                fprintf('Graphic Data loaded %s.\n',fullfile(savedir,'Trace_LFP.mat'));
                copy_graphicdata([data1.h(2);data2.h(2)],handles.CenterAxes,handles.RightAxes,'loading',savedir);
            catch
                copy_graphicdata(data1.h(2),handles.CenterAxes,handles.RightAxes,'loading',savedir);
            end       
    end
else
    warning('No Graphic Format detected.\n');
    return;
end

hp= findobj(handles.CenterAxes,'Tag','Pixel');
set(hp,'ButtonDownFcn',{@click_PixelFcn,handles});
hq= findobj(handles.CenterAxes,'Tag','Box');
set(hq,'ButtonDownFcn',{@click_PatchFcn,handles});
hr= findobj(handles.CenterAxes,'Tag','Region','-or','Tag','RegionGroup');
set(hr,'ButtonDownFcn',{@click_RegionFcn,handles});

% To ensure HitTest property
all_lines = findobj(handles.RightAxes,'Type','Line','-not','Tag','Cursor');
for i=1:length(all_lines)
    all_lines(i).HitTest='on';
    all_lines(i).ButtonDownFcn={@click_lineFcn,handles};
end


% Bring cursor on top
cursor = findobj(handles.RightAxes,'Tag','Cursor');
uistack(cursor,'top');

%Update Box Patches
boxPatch_Callback(handles.PatchBox,[],handles);
%Update Box Mask
boxMask_Callback(handles.MaskBox,[],handles);
%Update Box Atlas
boxAtlas_Callback(handles.AtlasBox,[],handles.CenterAxes);
%Update Box TimePatch
boxTimePatch_Callback(handles.TimePatchBox,[],handles.RightAxes);
%Update Box Crop
boxCrop_Callback(handles.CropBox,[],handles.CenterAxes,savedir);

% Loading Atlas.mat
if exist(fullfile(savedir,'Atlas.mat'),'file')
    try
        delete(findobj(handles.CenterAxes,'Tag','AtlasMask'));
        data_a = load(fullfile(savedir,'Atlas.mat'),'line_x','line_z');
        line('XData',data_a.line_x,'YData',data_a.line_z,'Tag','AtlasMask','Parent',handles.CenterAxes);
        boxAtlas_Callback(handles.AtlasBox,[],handles.CenterAxes);
    catch
        warning('Impossible to display Atlas [%s].\n',fullfile(savedir,'Atlas.mat'));
    end
end

success = true;
toc;

end