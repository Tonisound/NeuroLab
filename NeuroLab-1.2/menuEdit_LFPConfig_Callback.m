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
    
%     d_ncf = load(fullfile(folder_name,'Nconfig.mat'),...
%         'ind_channel','ind_channel_diff','channel_id','channel_list','channel_type',...
%         'channel_noise','channel_sharp_wave','channel_ripple');
    d_ncf = load(fullfile(folder_name,'Nconfig.mat'));
    ind_channel = d_ncf.ind_channel(:);
    ind_channel_diff = d_ncf.ind_channel_diff(:);
    temp = [];
    for k =1:length(ind_channel)
        temp = [temp;{sprintf('%d-%d',ind_channel(k),ind_channel_diff(k))}];    
    end
    temp = strrep(temp,'-NaN','');
    temp = strrep(temp,'NaN','');
    channel_id = d_ncf.channel_id(:);
    channel_type = d_ncf.channel_type(:);
    channel_list = d_ncf.channel_list(:);
    % D = [num2cell(ind_channel),channel_id,channel_type,channel_list];
    D = [temp,channel_id,channel_type,channel_list];
else

    % default NConfig
    d_ncf = [];
    D=cell(39,4);
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


% Building lfp_str, emg_str, acc_str
lfp_str = [{''};D(strcmp(D(:,3),'LFP'),2)];
emg_str = [{''};D(strcmp(D(:,3),'EMG'),2)];
acc_str = [{''};D(strcmp(D(:,3),'ACC'),2)];


ftsize = 12;
f2 = dialog('Units','characters',...
    'Position',[30 30 120 50],...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Name','LFP Configuration Edition');

% LFP Dir Dat
uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[.05 .14 .15 .05],...
    'String','LFP Dat Directory',...
    'Parent',f2);
e1 = uicontrol('Style','Edit',...
    'Units','normalized',...
    'Position',[.2 .16 .75 .04],...
    'String',data_config.File.dir_dat,...
    'Callback',{@checkdir_callback,data_config.File.dir_dat,'Dir Dat'},...
    'Parent',f2);


% LFP Main channel
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
% picking channel
ind_mainlfp = find(strcmp(lfp_str,data_config.File.mainlfp)==1);
if ~isempty(ind_mainlfp)
    pu_lfp.Value = ind_mainlfp;
end

% EMG Main channel
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
% picking channel
ind_mainemg = find(strcmp(emg_str,data_config.File.mainemg)==1);
if ~isempty(ind_mainemg)
    pu_emg.Value = ind_mainemg;
end

% ACC Main channel
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


% Ripple channel
uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[.05 .07 .15 .05],...
    'String','Channel Ripple',...
    'Parent',f2);
pu_ripple = uicontrol('Style','popupmenu',...
    'Units','normalized',...
    'Position',[.2 .075 .15 .05],...
    'String',lfp_str,...
    'Parent',f2);
% picking channel
if isfield(d_ncf,'channel_ripple')
    pu_ripple.Value = find(strcmp(lfp_str,d_ncf.channel_ripple)==1);
end

% Noise channel
uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[.35 .07 .15 .05],...
    'String','Channel Noise',...
    'Parent',f2);
pu_noise = uicontrol('Style','popupmenu',...
    'Units','normalized',...
    'Position',[.5 .075 .15 .05],...
    'String',lfp_str,...
    'Parent',f2);
% picking channel
if isfield(d_ncf,'channel_noise')
    pu_noise.Value = find(strcmp(lfp_str,d_ncf.channel_noise)==1);
end


% Sharp-wave channel
uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[.65 .07 .15 .05],...
    'String','Channel Sharp-Wave',...
    'Parent',f2);
pu_sharp_wave = uicontrol('Style','popupmenu',...
    'Units','normalized',...
    'Position',[.8 .075 .15 .05],...
    'String',lfp_str,...
    'Parent',f2);
% picking channel
if isfield(d_ncf,'channel_sharp_wave')
    pu_sharp_wave.Value = find(strcmp(lfp_str,d_ncf.channel_sharp_wave)==1);
end


addButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.25 .04 .25 .04],...
    'String','Add',...
    'Parent',f2);
removeButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.5 .04 .25 .04],...
    'String','Remove',...
    'Parent',f2);
okButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.25 0 .25 .04],...
    'String','OK',...
    'Parent',f2);
cancelButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.5 0 .25 .04],...
    'String','Cancel',...
    'Parent',f2);

set(okButton,'Callback',@okButton_callback);
set(cancelButton,'Callback', @cancelButton_callback);
set(addButton,'Callback',@addButton_callback);
set(removeButton,'Callback',@removeButton_callback);

panel1 = uipanel('FontSize',ftsize,...
    'Title','',...
    'Units','normalized',...
    'Position',[0 .2 1 .8],...
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
        
        %ind_channel = cell2mat(t1.Data(:,1));
        ind_channel_ = NaN(size(t1.Data(:,1)));
        ind_channel_diff_ = NaN(size(t1.Data(:,1)));
        for l=1:size(t1.Data(:,1),1)
            if contains(t1.Data(l,1),'-')
                temp2 = regexp(char(t1.Data(l,1)),'-','split');
                ind_channel_(l) = str2double(char(temp2(1)));
                ind_channel_diff_(l) = str2double(char(temp2(2)));
            else
                ind_channel_(l) = str2double(char(t1.Data(l,1)));
            end
        end
        ind_channel = ind_channel_;
        ind_channel_diff = ind_channel_diff_;
        
        channel_id = t1.Data(:,2);
        channel_type = t1.Data(:,3);
        channel_list = cell(size(channel_id));
        for i =1:length(channel_id)
            channel_list(i) = {sprintf('%s/%s',char(channel_type(i)),char(channel_id(i)))};
        end
        
        % Adding File struct in NConfig.mat
%         data_config.File.mainlfp = char(pu_lfp.String(pu_lfp.Value,:));
%         data_config.File.mainemg = char(pu_emg.String(pu_emg.Value,:));
%         data_config.File.mainacc = char(pu_acc.String(pu_acc.Value,:));
%         data_config.File.dir_dat = e1.String;
        if isempty(char(pu_lfp.String(pu_lfp.Value,:)))
            data_config.File.mainlfp = [];
        else
            data_config.File.mainlfp = char(pu_lfp.String(pu_lfp.Value,:));
        end
        if isempty(char(pu_emg.String(pu_emg.Value,:)))
            data_config.File.mainemg = [];
        else
            data_config.File.mainemg = char(pu_emg.String(pu_emg.Value,:));
        end
        if isempty(char(pu_acc.String(pu_acc.Value,:)))
            data_config.File.mainacc = [];
        else
            data_config.File.mainacc = char(pu_acc.String(pu_acc.Value,:));
        end
        if isempty(e1.String)
            data_config.File.dir_dat = [];
        else
            data_config.File.dir_dat = e1.String;
        end
        File = data_config.File;

        channel_ripple = char(pu_ripple.String(pu_ripple.Value,:));
        channel_noise = char(pu_noise.String(pu_noise.Value,:));
        channel_sharp_wave = char(pu_sharp_wave.String(pu_sharp_wave.Value,:));
        
        % Saving
        if isempty(channel_id)
            delete(fullfile(folder_name,'Nconfig.mat'));
            fprintf('Removed configuration %s.\n',fullfile(folder_name,'Nconfig.mat'));
            FILES(CUR_FILE).ncf = '';
            save('Files.mat','FILES','-append');
            fprintf('Files.mat updated.\n');
        else
            if isfile(fullfile(folder_name,'Nconfig.mat'))
                save(fullfile(folder_name,'Nconfig.mat'),...
                    'ind_channel','ind_channel_diff','channel_id','channel_list','channel_type',...
                    'channel_ripple','channel_noise','channel_sharp_wave','-append');
            else
                save(fullfile(folder_name,'Nconfig.mat'),...
                    'ind_channel','ind_channel_diff','channel_id','channel_list','channel_type',...
                    'channel_ripple','channel_noise','channel_sharp_wave','-v7.3');
            end
            fprintf('===> Channel Configuration saved at %s.\n',fullfile(folder_name,'Nconfig.mat'));
        end
        
        % Saving File to Config.mat
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

function checkdir_callback(hObj,~,var,label)

StrValue = get(hObj,'String');

if ~isfolder(StrValue) && ~isempty(StrValue)
    errordlg(sprintf('%s must be a directory.',label),'Directory Not found','modal');
    set(hObj,'String',var);
    return;
end

end