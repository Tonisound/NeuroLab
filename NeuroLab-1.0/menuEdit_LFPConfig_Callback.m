function success = menuEdit_LFPConfig_Callback(folder_name,handles)
% Channel Configuration Edition

success = false;

% Loading Channel Config
if exist(fullfile(folder_name,'Nconfig.mat'),'file')
    d_ncf = load(fullfile(folder_name,'Nconfig.mat'),...
        'ind_channel','channel_id','channel_list','channel_type');
    ind_channel = d_ncf.ind_channel;
    channel_id = d_ncf.channel_id(:);
    channel_type = d_ncf.channel_type(:);
    channel_list = d_ncf.channel_list(:);
    D = [channel_id,channel_type,channel_list];
else
    D=cell(39,3);
    for j=1:32
        D(j,:)={sprintf('%d',j),'LFP',sprintf('LFP-%03d',j)};
    end
    for j=33:35
        D(j,:)={sprintf('%d',j),'ACC',sprintf('ACC-%03d',j)};
    end
    D(36,:)={sprintf('%d',36),'TEMP',sprintf('TEMP-%03d',36)};
    for j=37:39
        D(j,:)={sprintf('%d',j),'GYR',sprintf('GYR-%03d',j)};
    end
    
end

ftsize = 12;
f2 = dialog('Units','characters',...
    'Position',[30 30 120 40],...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Name','LFP Configuration Edition');

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
t1 = uitable('ColumnName',{'ID','Type','Name'},...
    'ColumnFormat',{'char','char','char'},...
    'ColumnEditable',[true,true,true],...
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
        
        channel_id = t1.Data(:,1);
        channel_type = t1.Data(:,2);
        ind_channel = str2double(channel_id);
        for i =1:length(ind_channel)
            channel_list(i) = {sprintf('%s/%03d',char(channel_type(i)),ind_channel(i))};
        end
        
        % Saving
        if isempty(channel_id)
            delete(fullfile(folder_name,'Nconfig.mat'));
            fprintf('Removed configuration %s.\n',fullfile(folder_name,'Nconfig.mat'));
        else
            save(fullfile(folder_name,'Nconfig.mat'),...
                'ind_channel','channel_id','channel_list','channel_type');
            fprintf('===> Channel Configuration saved at %s.\n',fullfile(folder_name,'Nconfig.mat'));
        end
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