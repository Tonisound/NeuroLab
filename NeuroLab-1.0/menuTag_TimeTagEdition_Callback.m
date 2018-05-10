function success = menuTag_TimeTagEdition_Callback(folder_name,handles)
% Time Tag Edition

success =false;

% Loading Time Tags
if exist(fullfile(folder_name,'Time_Tags.mat'),'file')
    tdata = load(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    D = [tdata.TimeTags_cell(2:end,2),tdata.TimeTags_strings,tdata.TimeTags_cell(2:end,1)];
else
    D=[];
end

ftsize = 12;
f2 = dialog('Units','characters',...
    'Position',[30 30 120 40],...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Name','Time Tag Edition');

addButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.25 .05 .25 .05],...
    'String','Add',...
    'Parent',f2);
removeButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.5 .05 .25 .05],...
    'String','Remove',...
    'Parent',f2);
okButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.25 0 .25 .05],...
    'String','OK',...
    'Parent',f2);
cancelButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.5 0 .25 .05],...
    'String','Cancel',...
    'Parent',f2);

set(okButton,'Callback',@okButton_callback);
set(cancelButton,'Callback', @cancelButton_callback);
set(addButton,'Callback',@addButton_callback);
set(removeButton,'Callback',@removeButton_callback);

panel1 = uipanel('FontSize',ftsize,...
    'Title','Current Tags',...
    'Units','normalized',...
    'Position',[0 .1 1 .9],...
    'Parent',f2);

% UiTable 
t1 = uitable('ColumnName',{'Name','Start','End','Handle'},...
    'ColumnFormat',{'char','char','char','char'},...
    'ColumnEditable',[true,true,true,false],...
    'ColumnWidth',{180 180 180 90},...
    'Tag','Tag_Table',...
    'Units','normalized',...
    'FontSize',ftsize,...
    'Position',[0 0 1 1],...
    'RowStriping','on',...
    'CellSelectionCallback',@uitable_select,...
    'Parent',panel1);
t1.Data = D;
    

    function cancelButton_callback(~,~)
        close(f2);
    end

    function addButton_callback(~,~)
        selection = size(t1.Data,1);
        if ~isempty(t1.UserData)
            selection = t1.UserData.Selection;
        end
        index = max(selection);
        t1.Data = [t1.Data(1:index,:);t1.Data(index,:);t1.Data(index+1:end,:)];
    end

    function removeButton_callback(~,~)
        selection = t1.UserData.Selection;
        t1.Data(selection,:)=[];
    end

    function okButton_callback(~,~)
        
        n = size(t1.Data,1);
        %TimeTags_strings
        TimeTags_strings = t1.Data(:,2:3);
        tts1 = datenum(TimeTags_strings(:,1));
        tts2 = datenum(TimeTags_strings(:,2));
        TimeTags_seconds = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;
        TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');
        
        % TimeTags_cell & TimeTags
        TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
        TimeTags_cell = cell(n+1,6);
        TimeTags_cell(1,:) = {'Episode','Tag','Onset','Duration','Reference','Tokens'};
        
        for k=1:n
            TimeTags_cell(k+1,:) = {'',char(t1.Data(k,1)),char(t1.Data(k,2)),char(TimeTags_dur(k,:)),char(t1.Data(k,2)),''};
            TimeTags(k,1).Episode = '';
            TimeTags(k,1).Tag = char(t1.Data(k,1));
            TimeTags(k,1).Onset = char(t1.Data(k,2));
            TimeTags(k,1).Duration = char(TimeTags_dur(k,:));
            TimeTags(k,1).Reference = char(t1.Data(k,2));
            TimeTags(k,1).Tokens = '';
        end
        
        % TimeTags_images
        TimeTags_images = zeros(n,2);
        tts = datenum(handles.TimeDisplay.UserData);
        for k=1:size(TimeTags_strings,1)
            min_time = tts1(k);
            max_time = tts2(k);
            [~, ind_min_time] = min(abs(tts-datenum(min_time)));
            [~, ind_max_time] = min(abs(tts-datenum(max_time)));
            %TimeTags_strings(k,:) = {min_time,max_time};
            TimeTags_images(k,:) = [ind_min_time,ind_max_time];
        end
        
        % Saving
        save(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
        fprintf('===> Saved at %s.mat\n',fullfile(folder_name,'Time_Tags.mat'));
        close(f2);
    end

waitfor(f2);
success =true;

end

function uitable_select(hObj,evnt)
if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
else
    hObj.UserData.Selection = [];
end
end