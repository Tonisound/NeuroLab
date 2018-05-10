function success = load_regions(folder_name,handles)

%global FILES CUR_FILE DIR_SAVE IM LAST_IM CUR_IM;
%folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).gfus);
global IM LAST_IM CUR_IM;
success = false;
load('Preferences.mat','GDisp','GTraces');

try
    load(fullfile(folder_name,'Spikoscope_Regions.mat'),'regions');
catch
    errordlg(sprintf('Missing File %s',fullfile(folder_name,'Spikoscope_Regions.mat')));
    return;
end
try
    load(fullfile(folder_name,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
catch
    errordlg(sprintf('Missing File %s',fullfile(folder_name,'Time_Reference.mat')));
    return;
end

[ind_regions,ok] = listdlg('PromptString','Select Regions','SelectionMode','multiple','ListString',{regions.name},'ListSize',[300 500]);
lines = findobj(handles.RightAxes,'Tag','Trace_Region');
count=length(lines);

if ~ok || isempty(ind_regions)
    return;
end

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

for i=1:length(ind_regions)
    
    str = lower(char(regions(ind_regions(i)).name));
    fprintf('Importing Region %s (%d/%d) ...\n',str,i,length(ind_regions));
    
    if ~isempty(strfind(str,'hpc'))||...
            ~isempty(strfind(str,'ca1'))||...
            ~isempty(strfind(str,'ca2'))||...
            ~isempty(strfind(str,'ca3'))||...
            ~isempty(strfind(str,'dg'))||...
            ~isempty(strfind(str,'subic'))||...
            ~isempty(strfind(str,'lent-'))
        delta =10;
    elseif ~isempty(strfind(str,'thal'))||...
            ~isempty(strfind(str,'vpm-'))||...
            ~isempty(strfind(str,'po-'))||...
            ~isempty(strfind(str,'cpu-'))||...
            ~isempty(strfind(str,'gp-'))||...
            ~isempty(strfind(str,'septal'))
        delta =20;
    elseif ~isempty(strfind(str,'cortex'))||...
            ~isempty(strfind(str,'rs-'))||...
            ~isempty(strfind(str,'ac-'))||...
            ~isempty(strfind(str,'s1'))||...
            ~isempty(strfind(str,'lpta'))||...
            ~isempty(strfind(str,'m12'))||...
            ~isempty(strfind(str,'v1'))||...
            ~isempty(strfind(str,'v2'))||...
            ~isempty(strfind(str,'cg-'))||...
            ~isempty(strfind(str,'cx-'))||...
            ~isempty(strfind(str,'ptp'))
        delta =0;
    else
        delta =30;
    end
    
    count = count+1;
    ind_color = min(delta+count,length(handles.MainFigure.Colormap));
    color = handles.MainFigure.Colormap(ind_color,:);
    fprintf('i = %d, ind_color %d, color [%.2f %.2f %.2f]\n',i,ind_color,...
        handles.MainFigure.Colormap(ind_color,1),handles.MainFigure.Colormap(ind_color,2),handles.MainFigure.Colormap(ind_color,3));
    
    % Checking if region name is whole
    l_width = 1;
    if ~isempty(strfind(str,'whole'))
        color = [.5 .5 .5];
        l_width = 2;
    end
    
    hq = patch(regions(ind_regions(i)).patch_x,regions(ind_regions(i)).patch_y,color,...
        'EdgeColor','k',...
        'Tag','Region',...
        'FaceAlpha',.5,...
        'LineWidth',.5,...
        'ButtonDownFcn',{@click_RegionFcn,handles},...
        'Visible','off',...
        'Parent',handles.CenterAxes);
    
    X = [reshape(1:LAST_IM,[length_burst,n_burst]);NaN(1,n_burst)];
    im_mask = regions(ind_regions(i)).mask;
    im_mask(im_mask==0)=NaN;
    im_mask = IM.*repmat(im_mask,1,1,size(IM,3));
    %im_mask = IM(:,:,:).*repmat(regions(ind_regions(i)).mask,1,1,size(IM,3));
    %im_mask(im_mask==0)=NaN;
    Y = mean(mean(im_mask,2,'omitnan'),1,'omitnan');
    Y = [reshape(Y,[length_burst,n_burst]);NaN(1,n_burst)];
    
    hl = line('XData',X(:),...
        'YData',Y(:),...
        'Color',color,...
        'Tag','Trace_Region',...
        'HitTest','off',...
        'Visible','off',...
        'LineWidth',l_width,...
        'Parent',handles.RightAxes);
    
    if handles.RightPanelPopup.Value ==3
        %set([hq;hl],'Visible','on');
        set(hl,'Visible','on');
    end
    boxLabel_Callback(handles.LabelBox,[],handles);
    boxPatch_Callback(handles.PatchBox,[],handles);
    
    % Updating UserData
    s.Name = regions(ind_regions(i)).name;
    s.Mask = regions(ind_regions(i)).mask;
    s.Graphic = hq;
    hq.UserData = hl;
    hl.UserData = s;
    
    fprintf('Region %s Successfully Imported (%d/%d).\n',str,i,length(ind_regions));
end

actualize_plot(handles);
fprintf('Spikoscope Region successfully loaded (%s)\n',regions(ind_regions).name);
set(handles.MainFigure, 'pointer', 'arrow');
success = true;

end