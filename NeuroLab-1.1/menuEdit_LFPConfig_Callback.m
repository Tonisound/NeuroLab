function success = menuEdit_LFPConfig_Callback(folder_name,handles,val)
% Channel Configuration Edition

global FILES CUR_FILE;
success = false;

if nargin<3
    % user mode 
    val =1;
end

% loading Config.mat
data_config = load(fullfile(folder_name,'Config.mat'));

% Loading Channel Config
if exist(fullfile(folder_name,'Nconfig.mat'),'file')
    d_ncf = load(fullfile(folder_name,'Nconfig.mat'),...
        'ind_channel','channel_id','channel_list','channel_type');
    ind_channel = d_ncf.ind_channel(:);
    channel_id = d_ncf.channel_id(:);
    channel_type = d_ncf.channel_type(:);
    channel_list = d_ncf.channel_list(:);
    D = [num2cell(ind_channel),channel_id,channel_type,channel_list];
else
    D=cell(39,3);
    for j=1:32
        D(j,:)={sprintf('%d',j),sprintf('%d',j),'LFP',sprintf('LFP-%03d',j)};
    end
    for j=33:35
        D(j,:)={sprintf('%d',j),sprintf('%d',j),'ACC',sprintf('ACC-%03d',j)};
    end
    D(36,:)={sprintf('%d',j),sprintf('%d',36),'TEMP',sprintf('TEMP-%03d',36)};
    for j=37:39
        D(j,:)={sprintf('%d',j),sprintf('%d',j),'GYR',sprintf('GYR-%03d',j)};
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

% LFP Main channel
d_lfp = dir(fullfile(folder_name,'Sources_LFP','LFP_*.mat'));
lfp_str = regexprep({d_lfp(:).name}','.mat','');
lfp_str = regexprep(lfp_str,'LFP_','');
lfp_str = [{''};lfp_str];
uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[.05 .1 .15 .05],...
    'String','LFP main channel',...
    'Parent',f2);
pu_lfp = uicontrol('Style','popupmenu',...
    'Units','normalized',...
    'Position',[.2 .105 .15 .05],...
    'String',lfp_str,...
    'Parent',f2);
%picking channel
ind_mainlfp = find(strcmp(lfp_str,data_config.File.mainlfp)==1);
if ~isempty(ind_mainlfp)
    pu_lfp.Value = ind_mainlfp;
end

% EMG Main channel
d_emg = dir(fullfile(folder_name,'Sources_LFP','EMG_*.mat'));
emg_str = regexprep({d_emg(:).name}','.mat','');
emg_str = regexprep(emg_str,'EMG_','');
emg_str = [{''};emg_str];
uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[.35 .1 .15 .05],...
    'String','EMG main channel',...
    'Parent',f2);
pu_emg = uicontrol('Style','popupmenu',...
    'Units','normalized',...
    'Position',[.5 .105 .15 .05],...
    'String',emg_str,...
    'Parent',f2);
%picking channel
ind_mainemg = find(strcmp(emg_str,data_config.File.mainemg)==1);
if ~isempty(ind_mainemg)
    pu_emg.Value = ind_mainemg;
end

% ACC Main channel
d_acc = dir(fullfile(folder_name,'Sources_LFP','ACC_*.mat'));
acc_str = regexprep({d_acc(:).name}','.mat','');
acc_str = regexprep(acc_str,'ACC_','');
acc_str = [{''};acc_str];
uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[.65 .1 .15 .05],...
    'String','ACC main channel',...
    'Parent',f2);
pu_acc = uicontrol('Style','popupmenu',...
    'Units','normalized',...
    'Position',[.8 .105 .15 .05],...
    'String',acc_str,...
    'Parent',f2);
%picking channel
ind_mainacc = find(strcmp(acc_str,data_config.File.mainacc)==1);
if ~isempty(ind_mainacc)
    pu_acc.Value = ind_mainacc;
end


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
    'Position',[0 .175 1 .825],...
    'Parent',f2);

% UiTable 
t1 = uitable('ColumnName',{'index','ID','Type','Name'},...
    'ColumnFormat',{'char','char','char','char'},...
    'ColumnEditable',[false,true,true,false],...
    'ColumnWidth',{90 150 150 150},...
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
        if isempty(t1.UserData)
            t1.Data(1:size(t1.Data,1),:)=[];
        else
            selection = t1.UserData.Selection;
            t1.Data(selection,:)=[];
        end
    end

    function okButton_callback(~,~)
        
        ind_channel = cell2mat(t1.Data(:,1));
        channel_id = t1.Data(:,2);
        channel_type = t1.Data(:,3);
        channel_list = cell(size(channel_id));
        for i =1:length(channel_id)
            channel_list(i) = {sprintf('%s/%s',char(channel_type(i)),char(channel_id(i)))};
        end
        
        % Saving
        if isempty(channel_id)
            delete(fullfile(folder_name,'Nconfig.mat'));
            fprintf('Removed configuration %s.\n',fullfile(folder_name,'Nconfig.mat'));
            FILES(CUR_FILE).ncf = '';
            save('Files.mat','FILES','-append');
            fprintf('Files.mat updated.\n');
        else
            save(fullfile(folder_name,'Nconfig.mat'),...
                'ind_channel','channel_id','channel_list','channel_type','-append');
            fprintf('===> Channel Configuration saved at %s.\n',fullfile(folder_name,'Nconfig.mat'));
        end
        
        % Saving LFP EMG main channel
        data_config.File.mainlfp = char(pu_lfp.String(pu_lfp.Value,:));
        data_config.File.mainemg = char(pu_emg.String(pu_emg.Value,:));
        data_config.File.mainacc = char(pu_acc.String(pu_acc.Value,:));
        File = data_config.File;
        FILES(CUR_FILE)=File;
        save(fullfile(folder_name,'Config.mat'),'File','-append');
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