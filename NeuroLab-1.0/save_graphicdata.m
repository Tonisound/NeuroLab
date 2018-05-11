function save_graphicdata(savedir,handles)

% Saving Current file information 
% Loaded when file is reopened
    global IM START_IM CUR_IM END_IM LAST_IM;
    load('Preferences.mat','GTraces');
    
    % Pointer Watch
    set(handles.MainFigure, 'pointer', 'watch');
    drawnow;
    tic;
    
    UiValues.CenterPanelPopup = handles.CenterPanelPopup.Value;
    UiValues.ProcessListPopup = handles.ProcessListPopup.Value;
    UiValues.FigureListPopup = handles.FigureListPopup.Value;
    UiValues.RightPanelPopup = handles.RightPanelPopup.Value;
    UiValues.TagSelection = handles.TagButton.UserData;
    UiValues.LabelBox = handles.LabelBox.Value;
    UiValues.PatchBox = handles.PatchBox.Value;
    UiValues.MaskBox = handles.MaskBox.Value;
    Current_Image = IM(:,:,CUR_IM);
    
    if isdir(savedir)
        save(fullfile(savedir,'Config.mat'),'Current_Image','START_IM','CUR_IM','END_IM','LAST_IM','UiValues','-append');
        %fprintf('Configuration Saved %s.\n',fullfile(savedir,'Config.mat'))
    else
        warning('%s is not a directory.\n',savedir);
    end
    
    save_fmt = GTraces.GraphicSaveFormat;
    % Skip saving if format == skip
    if strcmp(save_fmt,'skip')
        fprintf('Skipping saving graphic data.\n');
        return;
    end
    
    % Generate graphic objects        
    f = figure('Visible','off');
    h = gobjects(2,1);
    ax1 = subplot(121,'Parent',f);
    ax2 = subplot(122,'Parent',f);  
    switch save_fmt
        case 'Graphic_objects.mat'
            % copy non LFP lines
            copy_graphicdata(handles.RightAxes,ax1,ax2,'saving',savedir,1);
            traces = generate_traces_data(ax2);
            h(1) = ax1;
            h(2) = ax2;
            % Saving
            fprintf('Saving Graphic Data ...\n');
            save(fullfile(savedir,'Trace_light.mat'),'h','traces','-v7.3');
            fprintf('Graphic Data Saved %s.\n',fullfile(savedir,'Trace_light.mat'));
        
        case 'Graphic_objects_full.mat'
            % copy non LFP lines
            copy_graphicdata(handles.RightAxes,ax1,ax2,'saving',savedir,1);
            traces = generate_traces_data(ax2);
            h(1) = ax1;
            h(2) = ax2;
            % Saving
            fprintf('Saving Graphic Data ...\n');
            save(fullfile(savedir,'Trace_light.mat'),'h','traces','-v7.3');
            fprintf('Graphic Data Saved %s.\n',fullfile(savedir,'Trace_light.mat'));
            
            delete(ax1.Children);
            delete(ax2.Children);
            % copy LFP lines
            copy_graphicdata(handles.RightAxes,ax1,ax2,'saving',savedir,2);
            traces = generate_traces_data(ax2);
            h(1) = ax1;
            h(2) = ax2;
            % Saving
            %fprintf('Saving Graphic Data ...\n');
            if ~isempty(traces)
                save(fullfile(savedir,'Trace_LFP.mat'),'h','traces','-v7.3');
                fprintf('Graphic Data Saved %s.\n',fullfile(savedir,'Trace_LFP.mat'));
            else
                warning('No LFP traces to save in full file format.\n');
            end
    end
    close(f);
    
    % Delete previous file format
    if exist(fullfile(savedir,'Graphic_objects_full.mat'),'file')
        delete(fullfile(savedir,'Graphic_objects_full.mat'));
    end
    if exist(fullfile(savedir,'Graphic_objects.mat'),'file')
        delete(fullfile(savedir,'Graphic_objects.mat'));
    end
    % Delete previous Config.fig
    if exist(fullfile(savedir,'Config.fig'),'file')
        delete(fullfile(savedir,'Config.fig'));
    end
    
    toc;
    set(handles.MainFigure, 'pointer', 'arrow');
end

function traces = generate_traces_data(ax)
    % Saving lines name
    % Lines Array
    m = findobj(ax,'Tag','Trace_Mean');
    l1 = flipud(findobj(ax,'Tag','Trace_Region'));
    l2 = flipud(findobj(ax,'Tag','Trace_Pixel'));
    l3 = flipud(findobj(ax,'Tag','Trace_Box'));
    l = [l1;l2;l3];
    t = flipud(findobj(ax,'Tag','Trace_Spiko'));
    lines = [m;l;t];

    % Table Data
    D = [];
    stack_pos = get_stackposition(lines,ax);
    for i =1:length(lines)
        D=[D;{lines(i).UserData.Name, lines(i).Tag, rgb2char(lines(i).Color),lines(i).LineStyle,sprintf('%.2f',lines(i).LineWidth),lines(i).Visible,sprintf('%d',stack_pos(i))}];
    end
    traces = D;
end