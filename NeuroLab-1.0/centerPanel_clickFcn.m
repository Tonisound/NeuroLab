function centerPanel_clickFcn(hObj,~,handles)
% Called when user clicks into CenterAxes for pixel selection

global IM LAST_IM DIR_SAVE FILES CUR_FILE;
load('Preferences.mat','GDisp','GTraces');

pt_cp = round(get(hObj,'CurrentPoint'));
Xlim = get(hObj,'XLim');
Ylim = get(hObj,'YLim');
n_pixels = length(findobj(handles.CenterAxes,'Tag','Pixel'));
n_boxes = length(findobj(handles.CenterAxes,'Tag','Box'));

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
catch
    warning('Missing File %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
    length_burst = size(IM,3);
    n_burst =1;
end

if pt_cp(1,1)>Xlim(1) && pt_cp(1,1)<Xlim(2) && pt_cp(1,2)>Ylim(1) && pt_cp(1,2)<Ylim(2)
    set(handles.MainFigure,'Pointer','crosshair');            
    switch strtrim(handles.RightPanelPopup.String(handles.RightPanelPopup.Value,:))
        case 'Pixel Dynamics'
            % User click in RightAxes for Pixel Selection
            if (n_pixels<GTraces.NPix_max)
                %Pixel
                hp = line('XData',pt_cp(1,1),...
                    'YData',pt_cp(1,2),...
                    'Marker','s',...
                    'MarkerSize',10,...
                    'LineWidth',1,...
                    'MarkerFaceColor',char2rgb(GDisp.colors{n_pixels+1}),...
                    'MarkerEdgeColor','k',...
                    'Tag','Movable_Pixel',...
                    'Parent', handles.CenterAxes);
                %Trace
                X = [reshape(1:LAST_IM,[length_burst,n_burst]);NaN(1,n_burst)];
                Y = [reshape(IM(pt_cp(1,2),pt_cp(1,1),:),[length_burst,n_burst]);NaN(1,n_burst)];
                hl = line('XData',X(:),...
                    'YData',Y(:),...
                    'Color',char2rgb(GDisp.colors{n_pixels+1}),...
                    'Tag','Movable_Trace_Pixel',...
                    'Parent', handles.RightAxes);
                %UserData
                s.Graphic = hp;
                s.Name = sprintf('Pixel-%d',n_pixels+1);
                hp.UserData = hl;
                hl.UserData = s;
            else
                errordlg(sprintf('Maximum Number of Pixels Reached : %d \n Consider changing Preferences.',n_pixels));
            end
        case 'Box Dynamics'
            % User click in RightAxes for Box Selection
            if (n_boxes<GTraces.NReg_max)
                x = [pt_cp(1,1),pt_cp(1,1),pt_cp(1,1),pt_cp(1,1)];
                y = [pt_cp(1,2),pt_cp(1,2),pt_cp(1,2),pt_cp(1,2)];
                %Patch
                hq = patch(x,y,char2rgb(GDisp.colors{n_boxes+1}),...
                    'EdgeColor','k',...
                    'Tag','Movable_Box',...
                    'FaceAlpha',.5,...
                    'LineWidth',.5,...
                    'Parent',handles.CenterAxes);
                X = [reshape(1:LAST_IM,[length_burst,n_burst]);NaN(1,n_burst)];
                Y = [reshape(IM(pt_cp(1,2),pt_cp(1,1),:),[length_burst,n_burst]);NaN(1,n_burst)];
                %Trace
                hr = line('XData',X(:),...
                    'YData',Y(:),...
                    'Color',char2rgb(GDisp.colors{n_boxes+1}),...
                    'Tag','Movable_Trace_Box',...
                    'Parent', handles.RightAxes);
                %UserData
                s.Graphic = hq;
                s.Name = sprintf('Box-%d',n_boxes+1);
                hq.UserData = hr;
                hr.UserData = s;
            else
                errordlg(sprintf('Maximum Number of Boxs Reached : %d \n Consider changing Preferences.',n_pixels));
            end
    end
    set(handles.MainFigure,'WindowButtonMotionFcn', {@centerPanel_motionFcn,handles});
    set(handles.MainFigure,'WindowButtonUpFcn',{@centerPanel_unclickFcn,handles});
end

end