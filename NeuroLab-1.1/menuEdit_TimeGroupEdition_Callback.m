function success = menuEdit_TimeGroupEdition_Callback(folder_name,handles)
% Time Group Edition

%global DIR_SAVE FILES CUR_FILE;
%folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab;
success =false;

% Loading Time Tags
if ~exist(fullfile(folder_name,'Time_Tags.mat'),'file')
    errordlg(sprintf('Missing File Time_Tags.mat %s',folder_name));
    return;
else
    load(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_images','TimeTags_strings');
end

% Loading Time Groups
if ~exist(fullfile(folder_name,'Time_Groups.mat'),'file')
    TimeGroups_name=[];
    TimeGroups_frames=[];
    TimeGroups_duration=[];
    TimeGroups_S=[];
else
    load(fullfile(folder_name,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
end

ftsize = 12;
f2 = dialog('Units','characters',...
    'Position',[30 30 180 40],...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Name','Time Group Edition');

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
    'Position',[0 .1 .33 .9],...
    'Parent',f2);
panel2 = uipanel('FontSize',ftsize,...
    'Title','Time Groups',...
    'Units','normalized',...
    'Position',[.335 .1 .33 .9],...
    'Parent',f2);
panel3 = uipanel('FontSize',ftsize,...
    'Title','Content',...
    'Units','normalized',...
    'Position',[.67 .1 .33 .9],...
    'Parent',f2);

% UiTable 
t1 = uitable('ColumnName',{'Name','Tag','Duration'},...
    'ColumnFormat',{'char','char','char'},...
    'ColumnEditable',[false,false,false],...
    'ColumnWidth',{100 100 100},...
    'Tag','Tag_Table',...
    'Units','normalized',...
    'FontSize',ftsize,...
    'Position',[0 0 1 1],...
    'RowStriping','on',...
    'CellSelectionCallback',@uitable_select,...
    'Parent',panel1);
t1.Data = TimeTags_cell(2:end,2:4);

t2 = uitable('ColumnName',{'Group','# Frames','Duration'},...
    'ColumnFormat',{'char','char','char'},...
    'ColumnEditable',[false,false,false],...
    'ColumnWidth',{100 100 100},...
    'Tag','Group_Table',...
    'Units','normalized',...
    'FontSize',ftsize,...
    'Data',[],...
    'Position',[0 0 1 1],...
    'RowStriping','on',...
    'Parent',panel2);
if ~isempty(TimeGroups_name)
    t2.Data = [TimeGroups_name,TimeGroups_frames,TimeGroups_duration];
end
t2.UserData.S = TimeGroups_S;

t3 = uitable('ColumnName',{'Name','Tag','Duration'},...
    'ColumnFormat',{'char','char','char'},...
    'ColumnEditable',[false,false,false],...
    'ColumnWidth',{100 100 100},...
    'Tag','Display_Table',...
    'Units','normalized',...
    'FontSize',ftsize,...
    'Position',[0 0 1 1],...
    'RowStriping','on',...
    'CellSelectionCallback',@uitable_select,...
    'Parent',panel3);
t3.Data = '';
t2.CellSelectionCallback = {@trace_uitable2_select,t1,t3};
    

    function cancelButton_callback(~,~)
        close(f2);
    end

    function addButton_callback(~,~)
        
        if isempty(t1.UserData)||isempty(t1.UserData.Selection)
            return;
        end
            
        prompt={'Group Recording Name'};
        name = 'Name';
        % finding longest common prefix
        lls = t1.Data(t1.UserData.Selection);
        pattern = char(lls(1));
        ind=0;
        while sum(~(cellfun('isempty',strfind(lls,pattern(1:min(ind+1,end))))))==size(lls,1) && ind<length(pattern)
            ind = ind+1;
        end
        %defaultans = {'TEST'};
        if ind>0
            defaultans = {pattern(1:ind)};
        else
            defaultans = {''};
        end
        
        answer = inputdlg(prompt,name,[1 40],defaultans);
        if ~isempty(answer)
            group_name= char(answer);
        else
            return;
        end
        
        indices = t1.UserData.Selection;
        % Filling table 2
        n_frames = sum(TimeTags_images(indices,2)+1-TimeTags_images(indices,1));
        duration_s=sum(datenum(TimeTags_strings(indices,2))-datenum(TimeTags_strings(indices,1)));
        duration = datestr(duration_s,'HH:MM:SS.FFF');
        t2.Data = [t2.Data;{group_name,sprintf('%d',n_frames),duration}];
        
        %t2.UserData.Selected = size(t2.Data,1);
        S.Name = t1.Data(indices,1);
        S.Selected = indices;
        S.TimeTags_strings = TimeTags_strings(indices,:);
        S.TimeTags_images = TimeTags_images(indices,:);
        t2.UserData.S = [t2.UserData.S;S];
        
        % Filling table 3
        data = t1.Data(indices,:);
        t3.Data = [strcat(sprintf('(%s)',group_name),data(:,1)),data(:,2:3)];
        
    end

    function okButton_callback(~,~)
        TimeGroups_name = t2.Data(:,1);
        TimeGroups_frames = t2.Data(:,2);
        TimeGroups_duration = t2.Data(:,3);
        TimeGroups_S = t2.UserData.S;
        
        %Saving
        save(fullfile(folder_name,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
        fprintf('Time_Groups.mat saved at %s.mat\n',fullfile(folder_name,'Time_Groups.mat'));
        
        close(f2);
    end

    function removeButton_callback(~,~)
        if isempty(t2.UserData)||isempty(t2.UserData.Selection)
            return
        end
        indices = t2.UserData.Selection;
        t2.UserData.Selection=[];
        t2.Data(indices,:)=[];
        t2.UserData.S(indices)=[];
        t3.Data=[];
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

function trace_uitable2_select(hObj,evnt,t1,t3)

if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
end
indices = hObj.UserData.Selection;

S = hObj.UserData.S;
t3.Data = [];
for i=1:length(indices)
    k = indices(i);
    group_name = char(hObj.Data(k,1));
    ind_selected= S(k).Selected;
    data = t1.Data(ind_selected,:);
    t3.Data = [t3.Data;strcat(sprintf('(%s)',group_name),data(:,1)),data(:,2:3)];
end

end