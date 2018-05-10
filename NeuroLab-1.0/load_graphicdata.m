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
            data2 = load(fullfile(savedir,'Trace_LFP.mat'),'h');
            copy_graphicdata([data1.h(2);data2.h(2)],handles.CenterAxes,handles.RightAxes,'loading',savedir);
            fprintf('Graphic Data loaded %s.\n',fullfile(savedir,'Trace_light.mat'));
            fprintf('Graphic Data loaded %s.\n',fullfile(savedir,'Trace_LFP.mat'));
    end
else
    warning('No Graphic Format detected.\n');
    return;
end

hp= findobj(handles.CenterAxes,'Tag','Pixel');
set(hp,'ButtonDownFcn',{@click_PixelFcn,handles});
hq= findobj(handles.CenterAxes,'Tag','Box');
set(hq,'ButtonDownFcn',{@click_PatchFcn,handles});
hr= findobj(handles.CenterAxes,'Tag','Region');
set(hr,'ButtonDownFcn',{@click_RegionFcn,handles});

% Bring cursor on top
cursor = findobj(handles.RightAxes,'Tag','Cursor');
uistack(cursor,'top');

boxPatch_Callback(handles.PatchBox,[],handles);
success = true;
toc;

end