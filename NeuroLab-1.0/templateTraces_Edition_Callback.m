function templateTraces_Edition_Callback(hObj,~,ax)
% Trace Edition Callback
% Allows Traces Edition

load('Preferences.mat','GDisp');
W = 110;
H = 50;
ftsize = 10;

f2 = dialog('Units','characters',...
    'Position',[30 30 W H],...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Name',sprintf('%s Edition (Parent : %s)',ax.Tag,ax.Parent.Tag));

visibleButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/2 3 W/4 2],...
    'String','All Visible',...
    'Parent',f2);
invisibleButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/4 3 W/4 2],...
    'String','All Invisible',...
    'Parent',f2);
okButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/4 1 W/4 2],...
    'String','OK',...
    'Parent',f2);
cancelButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/2 1 W/4 2],...
    'String','Cancel',...
    'Parent',f2);

set(okButton,'Callback',@okButton_callback);
set(cancelButton,'Callback', @cancelButton_callback);
set(visibleButton,'Callback',@visibleButton_callback);
set(invisibleButton,'Callback',@invisibleButton_callback);

mainPanel = uipanel('FontSize',ftsize,...
    'Units','characters',...
    'Position',[0 6 W H-6],...
    'Parent',f2);
pos = get(mainPanel,'Position');


% Lines Array
m = findobj(ax,'Tag','Trace_Mean');
l = flipud(findobj(ax,'Type','line','-not','Tag','Cursor','-not','Tag','Trace_Cerep','-not','Tag','Trace_Mean'));
t = flipud(findobj(ax,'Tag','Trace_Cerep'));
lines = [m;l;t];

% UiTable Data
D = [];
stack_pos = get_stackposition(lines,ax);
for i =1:length(lines)
    D=[D;{lines(i).UserData.Name, lines(i).Tag, rgb2char(lines(i).Color),lines(i).LineStyle,sprintf('%.2f',lines(i).LineWidth),lines(i).Visible,sprintf('%d',stack_pos(i))}];
end

% UiTable
ui_T = uitable('ColumnName',{'Name','Tag','Color','Linestyle','LineWidth','Visible'},...
    'ColumnFormat',{'char','char','char','char','char','char'},...
    'ColumnEditable',[true,false,true,true,true,true],...
    'ColumnWidth',{260 70 80 70 70 70},...
    'Data',D,...
    'Tag','Trace_uitable',...
    'Units','characters',...
    'Position',[0 0 pos(3) pos(4)],...
    'RowStriping','on',...
    'CellEditCallback',@trace_uitable_edit,...
    'CellSelectionCallback',@uitable_select,...
    'Parent',mainPanel);

    function trace_uitable_edit(hObj,evnt)
        
        r = evnt.Indices(1);
        c = evnt.Indices(2);
        switch c
            case 3,
                hObj.Data{r,c} = rgb2char(char2rgb(evnt.EditData));
                if isempty(hObj.Data{r,c}) && ismember(evnt.EditData,GDisp.colors_info)
                    [~,b] = ismember(evnt.EditData,GDisp.colors_info);
                    hObj.Data{r,c} = char(GDisp.colors(b));
                end
                
            case 4,
                if ~ismember(hObj.Data{r,c},GDisp.linestyle)
                    hObj.Data{r,c} = evnt.PreviousData;
                end
            case 5,
                if ~isnumeric(eval(hObj.Data{r,c})) || eval(hObj.Data{r,c})<0
                    hObj.Data{r,c} = evnt.PreviousData;
                end
            case 6,
                if ~ismember(hObj.Data{r,c},['on','off'])
                    hObj.Data{r,c} = evnt.PreviousData;
                end
        end
    end

    function uitable_select(hObj,evnt)
        if ~isempty(evnt.Indices)
            hObj.UserData.Selection = evnt.Indices;
            r = evnt.Indices(1);
            c = evnt.Indices(2);
            switch c
                case 6,
                    if strcmp(hObj.Data{r,c},'on')
                        hObj.Data{r,c} = 'off';
                    else
                        hObj.Data{r,c} = 'on';
                    end
            end
        end
    end

    function cancelButton_callback(~,~)
        close(f2);
    end

    function okButton_callback(~,~)
        D = get(ui_T,'Data');
        
        for j =1:size(D,1)
            
            % Update Name
            lines(j).UserData.Name = char(D(j,1));
            
            % Update Colors
            set(lines(j),'Color',char2rgb(char(D(j,3))));
            switch lines(j).Tag
                case 'Trace_Pixel'
                    lines(j).UserData.Graphic.MarkerFaceColor = char2rgb(char(D(j,3)));
                case {'Trace_Box','Trace_Region'}
                    lines(j).UserData.Graphic.FaceColor = char2rgb(char(D(j,3)));
            end
            
            % Update LineStyle and LineWidth
            lines(j).LineStyle = char(D(j,4));
            lines(j).LineWidth = str2double(cell2mat(D(j,5)));
            
            % Update Visible
            lines(j).Visible = char(D(j,6));
            if strcmp(char(D(j,6)),'on')
                status ='on';
            else
                status = 'off';
            end
            switch lines(j).Tag
                case {'Trace_Pixel','Trace_Box','Trace_Region'}
                    lines(j).UserData.Graphic.Visible = char(D(j,6));
            end 
        end
        close(f2);
    end

    function visibleButton_callback(~,~)
        
        if ~isempty(ui_T.UserData)
            selection = ui_T.UserData.Selection;
            ind = (2:size(ui_T.Data,1))';
            ind_rm = ind(ismember(ind,unique(selection(:,1))));
            for k =1:length(ind_rm)
                ui_T.Data(ind_rm(k),6)={'on'};
            end
        else
            % Turn everything on if no selection
            for k = 1:size(ui_T.Data,1)
                ui_T.Data(k,6)={'on'};
            end
        end
    end

    function invisibleButton_callback(~,~)
        if ~isempty(ui_T.UserData)
            selection = ui_T.UserData.Selection;
            ind = (2:size(ui_T.Data,1))';
            ind_rm = ind(ismember(ind,unique(selection(:,1))));
            for k =1:length(ind_rm)
                ui_T.Data(ind_rm(k),6)={'off'};
            end
        else
            % Turn everything off if no selection
            for k = 1:size(ui_T.Data,1)
                ui_T.Data(k,6)={'off'};
            end
        end
    end

end