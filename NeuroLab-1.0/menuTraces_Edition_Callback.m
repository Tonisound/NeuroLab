function success = menuTraces_Edition_Callback(~,~,ax,handles)
% Trace Edition Callback
% Allows Traces Edition

load('Preferences.mat','GDisp');
success = false;

if nargin<4
    handles =[];
end

W = 185;
H = 65;
ftsize = 10;

f2 = dialog('Units','characters',...
    'Position',[30 10 W H],...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Name',sprintf('%s Edition (Parent : %s)',ax.Tag,ax.Parent.Tag));

sortButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[0 6 W/8 2],...
    'String','Sort',...
    'Parent',f2);
revButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[0 4 W/8 2],...
    'String','Reverse',...
    'Parent',f2);

topButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/4 6 W/8 2],...
    'String','Top',...
    'Parent',f2);
upButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[3*W/8 6 W/8 2],...
    'String','Up',...
    'Parent',f2);
downButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/2 6 W/8 2],...
    'String','Down',...
    'Parent',f2);
bottomButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[5*W/8 6 W/8 2],...
    'String','Bottom',...
    'Parent',f2);

invisibleButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/4 4 W/4 2],...
    'String','All Invisible',...
    'Parent',f2);
visibleButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/2 4 W/4 2],...
    'String','All Visible',...
    'Parent',f2);

resetButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/4 2 W/4 2],...
    'String','Reset',...
    'Parent',f2);
deleteButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/2 2 W/4 2],...
    'String','Delete',...
    'Parent',f2);
okButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/4 0 W/4 2],...
    'String','OK',...
    'Parent',f2);
cancelButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/2 0 W/4 2],...
    'String','Cancel',...
    'Parent',f2);

set(okButton,'Callback',@okButton_callback);
set(cancelButton,'Callback', @cancelButton_callback);
set(resetButton,'Callback',@resetButton_callback);
set(deleteButton,'Callback',@deleteButton_callback);
set(visibleButton,'Callback',@visibleButton_callback);
set(invisibleButton,'Callback',@invisibleButton_callback);
set(upButton,'Callback',@upButton_callback);
set(downButton,'Callback',@downButton_callback);
set(topButton,'Callback',@topButton_callback);
set(bottomButton,'Callback',@bottomButton_callback);
set(sortButton,'Callback',@sortButton_callback);
set(revButton,'Callback',@revButton_callback);

mainPanel = uipanel('FontSize',ftsize,...
    'Units','characters',...
    'Position',[0 8 W H-8],...
    'Parent',f2);
pos = get(mainPanel,'Position');

% Lines Array
m = findobj(ax,'Tag','Trace_Mean');
%l = flipud(findobj(ax,'Type','line','-not','Tag','Cursor','-not','Tag','Trace_Cerep','-not','Tag','Trace_Mean'));
l1 = flipud(findobj(ax,'Tag','Trace_Region'));
l2 = flipud(findobj(ax,'Tag','Trace_Pixel'));
l3 = flipud(findobj(ax,'Tag','Trace_Box'));
l = [l1;l2;l3];
t = flipud(findobj(ax,'Tag','Trace_Cerep'));
lines = [m;l;t];

% Table Data
D = [];
stack_pos = get_stackposition(lines,ax);
for i =1:length(lines)
    D=[D;{lines(i).UserData.Name, lines(i).Tag, rgb2char(lines(i).Color),lines(i).LineStyle,sprintf('%.2f',lines(i).LineWidth),lines(i).Visible,sprintf('%d',stack_pos(i))}];
end


% UiTable 
ui_T = uitable('ColumnName',{'Name','Tag','Color','Linestyle','LineWidth','Visible','Position'},...
    'ColumnFormat',{'char','char','char','char','char','char','numeric'},...
    'ColumnEditable',[true,false,true,true,true,true,false],...
    'ColumnWidth',{200 120 120 100 100 100 100},...
    'Data',D,...
    'Tag','Trace_uitable',...
    'Units','characters',...
    'FontSize',13,...
    'Position',[0 0 pos(3) pos(4)],...
    'RowStriping','on',...
    'CellEditCallback',@trace_uitable_edit,...
    'CellSelectionCallback',@uitable_select,...
    'Parent',mainPanel); 

    function trace_uitable_edit(hObj,evnt)
        
        r = evnt.Indices(1);
        c = evnt.Indices(2);
        switch c
            case 3
                hObj.Data{r,c} = rgb2char(char2rgb(evnt.EditData));
                if isempty(hObj.Data{r,c}) && ismember(evnt.EditData,GDisp.colors_info)
                   [~,b] = ismember(evnt.EditData,GDisp.colors_info);
                   hObj.Data{r,c} = char(GDisp.colors(b));
                end
                
            case 4
                if ~ismember(hObj.Data{r,c},GDisp.linestyle)
                    hObj.Data{r,c} = evnt.PreviousData;
                end
            case 5
                if ~isnumeric(eval(hObj.Data{r,c})) || eval(hObj.Data{r,c})<0
                    hObj.Data{r,c} = evnt.PreviousData;
                end
            case 6
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
        
        % Restacking patches, pixels and boxes according to lines position
        [~,ind_sorted]=sort(get_stackposition(lines,ax),'ascend');
        lines_s = lines(ind_sorted);
        for j =length(lines_s):-1:1
            if strcmp(lines_s(j).Tag,'Trace_Region')||strcmp(lines_s(j).Tag,'Trace_Pixel')||strcmp(lines_s(j).Tag,'Trace_Box')
                uistack(lines_s(j).UserData.Graphic,'top');
            end
        end
        
        for j =1:size(D,1)
            % Delete empty lines
            switch(char(D(j,2)))
                case '.'
                    delete(lines(j).UserData.Graphic);
                    delete(lines(j));
                case '..'
                    delete(lines(j));
                
                otherwise
                    % Update Name
                    lines(j).UserData.Name = char(D(j,1));
                    
                    % Update Colors
                    lines(j).Color = char2rgb(char(D(j,3)));
                    switch lines(j).Tag
                        case 'Trace_Pixel'
                            lines(j).UserData.Graphic.MarkerFaceColor = char2rgb(char(D(j,3)));
                        case {'Trace_Box','Trace_Region'}
                            lines(j).UserData.Graphic.FaceColor = char2rgb(char(D(j,3)));
                    end
                    
                    % Update LineStyle and LineWidth
                    lines(j).LineStyle = char(D(j,4));
                    lines(j).LineWidth = str2num(cell2mat(D(j,5)));
                    
                    % Update Visible
                    lines(j).Visible = char(D(j,6));
                    switch lines(j).Tag
                        case {'Trace_Pixel','Trace_Box','Trace_Region'}
                            lines(j).UserData.Graphic.Visible = char(D(j,6));
                    end
            end
        end

        if ~isempty(handles)
           boxPatch_Callback(handles.PatchBox,[],handles);
        end
        
        % Putting Cursor on top
        cursor = findobj(ax,'Tag','Cursor');
        uistack(cursor,'top');
        
        close(f2);
    end

    function resetButton_callback(~,~)
        
        if ~isempty(ui_T.UserData)
            indices = ui_T.UserData.Selection;
            
            % Using temp matrix to reset values
            arg2 =1;
            temp  = ui_T.Data;
            status = {'off';'off';'off';'off'};
            status(arg2)={'on'};
            
            ind = find(strcmp(D(:,2),'Trace_Mean'));
            for k=ind
                temp(ind,:)={'','Trace_Mean','black','-','0.5','on'};
            end
            
            ind = find(strcmp(D(:,2),'Trace_Pixel'));
            for k =1:length(ind)
                temp(ind(k),:) = {sprintf('Pixel_%d',k),'Trace_Pixel',GDisp.colors_info{k},'-','0.5',char(status(1))};
            end
            
            ind = find(strcmp(D(:,2),'Trace_Box'));
            for k =1:length(ind)
                temp(ind(k),:) = {sprintf('Box_%d',k),'Trace_Box',GDisp.colors_info{k},'-','0.5',char(status(2))};
            end
            
            ind = find(strcmp(D(:,2),'Trace_Region'));
            for k =1:length(ind)
                temp(ind(k),:) = {sprintf('SpikoRegion_%d',k),'Trace_Region',rgb2char(rand(1,3)),'-','0.5',char(status(3))};
            end
            
            ind = find(strcmp(D(:,2),'Trace_Cerep'));
            for k =1:length(ind)
                temp(ind(k),:) = {sprintf('SpikoTrace_%d',k),'Trace_Cerep',rgb2char(rand(1,3)),'-','0.5',char(status(4))};
            end
            
            for ii=1:length(indices)
                ui_T.Data(indices(ii,1),indices(ii,2)) = temp(indices(ii,1),indices(ii,2));
            end
        end
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
            % Turn everything if no selection
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
            for k = 1:size(ui_T.Data,1)
                ui_T.Data(k,6)={'off'};
            end
        end
    end

    function deleteButton_callback(~,~) 
        if ~isempty(ui_T.UserData)
            selection = ui_T.UserData.Selection;
            ind = (2:size(ui_T.Data,1))';
            ind_rm = ind(ismember(ind,unique(selection(:,1))));
            %ind_keep = [1;ind(~ismember(ind,unique(selection(:,1))))];
            %ui_T.Data = ui_T.Data(ind_keep,:);
            for k =1:length(ind_rm)
                switch lines(ind_rm(k)).Tag
                    case {'Trace_Pixel','Trace_Box','Trace_Region'}
                        ui_T.Data(ind_rm(k),:) = {'','.','','','','',''};
                    case 'Trace_Cerep'
                        ui_T.Data(ind_rm(k),:) = {'','..','','','','',''};
                end
            end
        end  
    end

    function upButton_callback(~,~) 
        if ~isempty(ui_T.UserData)
            selection = unique(ui_T.UserData.Selection(:,1));
            for k=1:length(selection)
                uistack(lines(selection),'up');
            end
        end
        ui_T.Data(:,7)=num2cell(get_stackposition(lines,ax));
        
    end

    function topButton_callback(~,~)
        if ~isempty(ui_T.UserData)
            selection = unique(ui_T.UserData.Selection(:,1));
            for k=1:length(selection)
                uistack(lines(selection),'top');
            end
        end
        ui_T.Data(:,7)=num2cell(get_stackposition(lines,ax));
    end

    function downButton_callback(~,~) 
        if ~isempty(ui_T.UserData)
            selection = unique(ui_T.UserData.Selection(:,1));
            for k=1:length(selection)
                uistack(lines(selection),'down');
            end
        end
        ui_T.Data(:,7)=num2cell(get_stackposition(lines,ax));      

    end

    function bottomButton_callback(~,~) 
        if ~isempty(ui_T.UserData)
            selection = unique(ui_T.UserData.Selection(:,1));
            for k=1:length(selection)
                uistack(lines(selection),'bottom');
            end
        end
        ui_T.Data(:,7)=num2cell(get_stackposition(lines,ax));
    end

    function sortButton_callback(~,~)
        % Reordering lines and table data
        [~,ind_sorted]=sort(get_stackposition(lines,ax),'ascend');
        lines = lines(ind_sorted);
        ui_T.Data = ui_T.Data(ind_sorted,:);
    end

    function revButton_callback(~,~)
        
        % Getting Selection
        selection = 1:length(lines);
        if ~isempty(ui_T.UserData)
            selection = unique(ui_T.UserData.Selection(:,1));
        end
        % Reordering lines and table data
        lines_s = lines(selection);
        [~,ind_sorted]=sort(get_stackposition(lines(selection),ax),'ascend');
        lines_s = lines_s(ind_sorted);
        for ii=1:length(lines_s)
            uistack(lines_s(ii),'top');
        end
        ui_T.Data(:,7)=num2cell(get_stackposition(lines,ax));
    end

waitfor(f2);
success = true;

end