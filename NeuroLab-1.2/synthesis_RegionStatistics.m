function f2 = synthesis_RegionStatistics()
% Time Tag Selection Callback

global FILES;

f2 = figure('Units','normalized',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Position',[.1 .1 .8 .6],...
    'Name','Region Correlation Synthesis');
clrmenu(f2);
colormap(f2,'jet');

iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 .1],...
    'Tag','InfoPanel',...
    'Parent',f2);

% Texts and Edits
uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String','fUS_Correlation','Tag','Text1','Position',[.01 .6 .18 .3]);
uicontrol('Units','normalized','Style','popup','HorizontalAlignment','left','Parent',iP,...
    'String','REM|RUN','Tag','Popup2','Position',[.21 .65 .19 .3]);
uicontrol('Units','normalized','Style','popup','HorizontalAlignment','left','Parent',iP,...
    'String','Reference|File|Region','Tag','Popup1','Position',[0 0 .4 .5]);
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String','2','TooltipString','Panel Number','Tag','Edit1','Position',[.4 .2 .04 .6]);
uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'Value',0,'TooltipString','Merge left/right','Tag','Checkbox1','Position',[.45 .2 .02 .6]);
uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'Value',1,'TooltipString','Legend','Tag','Checkbox2','Position',[.47 .2 .02 .6]);

% Radio Button
bg = uibuttongroup('Visible','off',...
    'Parent',iP,...
    'Units','normalized',...
    'Tag','ButtonGroup',...
    'Position',[.5 0 .1 1]);

% Create two radio buttons in the button group.
uicontrol(bg,'Style','radiobutton',...
    'Units','normalized',...
    'Tag','Option1',...
    'String','Regions',...
    'Position',[0 .55 1 .4],...
    'HandleVisibility','off');
uicontrol(bg,'Style','radiobutton',...
    'Units','normalized',...
    'Tag','Option2',...
    'String','Files',...
    'Position',[0 .05 1 .4],...
    'HandleVisibility','off');
              
% Make the uibuttongroup visible after creating child objects. 
bg.Visible = 'on';       

% Buttons 
uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Display','Tag','ButtonDisplay','Position',[.8 .5 .1 .5]);
uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute','Position',[.9 .5 .1 .5]);
uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save','Tag','ButtonSave','Position',[.8 0 .1 .5]);
uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Batch Save','Tag','ButtonBatch','Position',[.9 0 .1 .5]);

% Creating uitabgroup
mP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 .1 1 .9],...
    'Parent',f2);
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',mP,...
    'Tag','TabGroup');

% First Tab
tab1 = uitab('Parent',tabgp,...
    'Title','Files',...
    'Tag','FirstTab');
filePanel = uipanel('Parent',tab1,...
    'Units','normalized',...
    'Position',[0 0 .25 1],...
    'Title','Files',...
    'Tag','FilePanel');
refPanel = uipanel('Parent',tab1,...
    'Units','normalized',...
    'Position',[.25 0 .25 1],...
    'Title','Reference',...
    'Tag','RefPanel');
regionPanel = uipanel('Parent',tab1,...
    'Units','normalized',...
    'Position',[.5 0 .25 1],...
    'Title','Regions',...
    'Tag','RegionPanel');
paramPanel = uipanel('Parent',tab1,...
    'Units','normalized',...
    'Position',[.75 0 .25 1],...
    'Title','Params',...
    'Tag','RegionPanel');
tabgp.SelectedTab = tab1;


% UiTable FileTable
uitable('ColumnName',{'Parent','file'},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{100 100},...
    'Data',{FILES.parent;FILES.nlab}',...
    'Tag','FileTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'RowStriping','on',...
    'Parent',filePanel);

% UiTable Reference Table
uitable('ColumnName',{'Reference','Count'},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{150 50},...
    'Data','',...
    'Tag','RefTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'RowStriping','on',...
    'Parent',refPanel);

% UiTable Region Table
uitable('ColumnName',{'Region','Count'},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{100 100},...
    'Data','',...
    'Tag','RegionTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'RowStriping','on',...
    'Parent',regionPanel);

% UiTable Param Table
uitable('ColumnName',{'Parameter','Count'},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{100 100},...
    'Data','',...
    'Tag','ParamTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'CellSelectionCallback',@uitable_select,...
    'RowStriping','on',...
    'Parent',paramPanel);

% Second Tab
tab2 = uitab('Parent',tabgp,...
    'Title','Data',...
    'Tag','SecondTab');
secondPanel = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','SecondPanel',...
    'Title','Data',...
    'Parent',tab2);
uitable('ColumnName','',...
    'Data','',...
    'Tag','SecondTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'RowStriping','on',...
    'Parent',secondPanel);

handles2 = guihandles(f2);
handles2.FileTable.CellSelectionCallback = {@fileuitable_select,handles2};
handles2.RefTable.CellSelectionCallback = {@refuitable_select,handles2};
handles2.RegionTable.CellSelectionCallback = {@regionuitable_select,handles2};

handles2.ButtonCompute.Callback = {@compute_Callback,handles2};
handles2.ButtonDisplay.Callback = {@display_Callback,handles2};
handles2.Popup1.Callback = {@update_popup1,handles2};

end

function update_popup1(hObj,~,handles)
switch strtrim(hObj.String(hObj.Value,:))
    case 'File',
        handles.Option1.String='Regions';
        handles.Option2.String='References';
    case 'Reference',
        handles.Option1.String='Regions';
        handles.Option2.String='Files';
    case 'Region',
        handles.Option1.String='References';
        handles.Option2.String='Files';
end
end

function uitable_select(hObj,evnt)
if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
end
% Exclude NaN from selection
A = strfind((hObj.Data(hObj.UserData.Selection,:)),'NaN');
ind = cellfun('isempty',A);
hObj.UserData.Selection(sum(ind,2)<size(ind,2))=[];

end

function fileuitable_select(hObj,evnt,handles)

global DIR_STATS; 

if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
end

% Exclude NaN from selection
A = strfind((hObj.Data(hObj.UserData.Selection,:)),'NaN');
ind = cellfun('isempty',A);
hObj.UserData.Selection(sum(ind,2)<size(ind,2))=[];

temp={};
files = hObj.Data(hObj.UserData.Selection,2);
str_dir = handles.Text1.String;
for i=1:length(files)
    d = dir(fullfile(DIR_STATS,str_dir,char(files(i))));
    for k = 1:length(d)
        if ~strcmp(char(d(k).name),'.') && ~strcmp(char(d(k).name),'..') && ~strcmp(char(d(k).name),'.DS_Store')
            temp = [temp;d(k).name];
        end
    end
end

%n = {};
n = [];
n_cell = {};
utemp  = unique(temp);
for i =1:length(utemp)
    n = [n;sum(ismember(temp,utemp(i)))];
    n_cell = [n_cell;{sprintf('%d',sum(ismember(temp,utemp(i))))}];
end
%handles.RefTable.Data = [utemp,n_cell];

[~,i]=sort(n);
handles.RefTable.Data = [utemp(flipud(i)),n_cell(flipud(i))];

end

function refuitable_select(hObj,evnt,handles)

global DIR_STATS;

if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
end
% Exclude NaN from selection
A = strfind((hObj.Data(hObj.UserData.Selection,:)),'NaN');
ind = cellfun('isempty',A);
hObj.UserData.Selection(sum(ind,2)<size(ind,2))=[];

temp={};
files = handles.FileTable.Data(handles.FileTable.UserData.Selection,2);
refs = hObj.Data(hObj.UserData.Selection,1);
str_dir = handles.Text1.String;
str_dir_2 = strcat(strtrim(handles.Popup2.String(handles.Popup2.Value,:)),'/Regions');

for i=1:length(files)
    for j=1:length(refs)
        d = dir(fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(j)),str_dir_2));
        for k = 1:length(d)
            if ~strcmp(char(d(k).name),'.') && ~strcmp(char(d(k).name),'..') && ~strcmp(char(d(k).name),'.DS_Store')
                temp = [temp;d(k).name];
            end
        end
    end
end

%utemp  = unique(temp);
utemp  = regexprep(unique(temp),'.mat','')';
if handles.Checkbox1.Value 
    utemp  = regexprep(utemp,'-L','')';
    utemp  = regexprep(utemp,'-R','')';
    utemp  = unique(utemp);
end
n = [];
n_cell = {};

if handles.Checkbox1.Value
    for i =1:length(utemp)
        i1 = sum(ismember(temp,strcat(utemp(i),'-L.mat')));
        i2 = sum(ismember(temp,strcat(utemp(i),'-R.mat')));
        i3 = sum(ismember(temp,strcat(utemp(i),'.mat')));
        add = i1+i2+i3;
        n = [n;add];
        n_cell = [n_cell;{sprintf('%d       (%d-%d-%d)',add,i1,i2,i3)}];
    end
else
    for i =1:length(utemp)
        add = sum(ismember(temp,strcat(utemp(i),'.mat')));
        n = [n;add];
        n_cell = [n_cell;{sprintf('%d',add)}];
    end
end

[~,i]=sort(n);
%handles.RegionTable.Data = [utemp(flipud(i)),num2cell(n(flipud(i)))];
handles.RegionTable.Data = [utemp(flipud(i))',n_cell(flipud(i))];

end

function regionuitable_select(hObj,evnt,handles)

global DIR_STATS;

if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
end
% Exclude NaN from selection
A = strfind((hObj.Data(hObj.UserData.Selection,:)),'NaN');
ind = cellfun('isempty',A);
hObj.UserData.Selection(sum(ind,2)<size(ind,2))=[];

temp={};
files = handles.FileTable.Data(handles.FileTable.UserData.Selection,2);
refs = handles.RefTable.Data(handles.RefTable.UserData.Selection,1);
regions = hObj.Data(hObj.UserData.Selection,1);
str_dir = handles.Text1.String;
str_dir_2 = strcat(strtrim(handles.Popup2.String(handles.Popup2.Value,:)),'/Regions');

for i=1:length(files)
    for j=1:length(refs)
        for k = 1:length(regions)
            if handles.Checkbox1.Value
                if exist(fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(j)),str_dir_2,strcat(char(regions(k)),'-L.mat')),'file')>0;
                    str_file = fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(j)),str_dir_2,strcat(char(regions(k)),'-L.mat'));
                    vars = whos('-file',str_file);
                    temp =[temp;{vars.name}'];
                end
                if exist(fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(j)),str_dir_2,strcat(char(regions(k)),'-R.mat')),'file')>0;
                    str_file = fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(j)),str_dir_2,strcat(char(regions(k)),'-R.mat'));
                    vars = whos('-file',str_file);
                    temp =[temp;{vars.name}'];
                end
                if exist(fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(j)),str_dir_2,strcat(char(regions(k)),'.mat')),'file')>0;
                    str_file = fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(j)),str_dir_2,strcat(char(regions(k)),'.mat'));
                    vars = whos('-file',str_file);
                    temp =[temp;{vars.name}'];
                end
            else
                if exist(fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(j)),str_dir_2,strcat(char(regions(k)),'.mat')),'file')>0;
                    str_file = fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(j)),str_dir_2,strcat(char(regions(k)),'.mat'));
                    vars = whos('-file',str_file);
                    temp =[temp;{vars.name}'];
                end
            end
        end
    end
end

n_cell = {};
n = [];
utemp  = unique(temp);
for i =1:length(utemp)
    n_cell = [n_cell;{sprintf('%d',sum(ismember(temp,utemp(i))))}];
    n = [n;sum(ismember(temp,utemp(i)))];
end
[~,i]=sort(n);
handles.ParamTable.Data = [utemp(flipud(i)),n_cell(flipud(i))];
%handles.ParamTable.Data = [utemp(flipud(i)),num2cell(n(flipud(i)))];

end

function compute_Callback(~,~,handles)

global DIR_STATS;

if isempty(handles.ParamTable.UserData)
    errordlg('Please Select Parameters');
    return;
else
    params = handles.ParamTable.Data(handles.ParamTable.UserData.Selection,:);
end

handles.MainFigure.Pointer = 'watch';
drawnow;

handles.SecondTable.ColumnName = [{'parent'},params(:,1)'];
handles.SecondTable.ColumnEditable = (false(1,size(params,1)+1)==1);
handles.SecondTable.ColumnFormat = cellstr(repmat('char',size(params,1)+1,1))';
handles.SecondTable.ColumnWidth = num2cell(100*[7,ones(1,size(params,1))]);
%handles.SecondTable.ColumnWidth = 'auto';

files = handles.FileTable.Data(handles.FileTable.UserData.Selection,2);
refs = handles.RefTable.Data(handles.RefTable.UserData.Selection,1);
regions = handles.RegionTable.Data(handles.RegionTable.UserData.Selection,1);
params = handles.ParamTable.Data(handles.ParamTable.UserData.Selection,1);
str_dir = handles.Text1.String;
str_dir_2 = strcat(strtrim(handles.Popup2.String(handles.Popup2.Value,:)),'/Regions');

lparams = handles.ParamTable.Data(handles.ParamTable.UserData.Selection,2);
m = 0;
for i=1:size(lparams,1)
    m = max(eval(cell2mat(lparams(i,1))),m);
end
temp=cell(m,size(params,1)+1);
S = NaN(length(files),length(regions),length(refs),length(params));

% Building temp matrix
% Storing values in S array
count=0;
if handles.Checkbox1.Value
    % Merging L-R
    for j = 1:length(regions)
        for k=1:length(refs)
            for i=1:length(files)
                % Case 1 : *.mat exists
                S_temp=NaN(3,length(params));
                if exist(fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(k)),str_dir_2,strcat(char(regions(j)),'.mat')),'file')>0;
                    str_file = fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(k)),str_dir_2,strcat(char(regions(j)),'.mat'));
                    vars = whos('-file',str_file);
                    count = count+1;
                    temp(count,1) = {str_file};
                    for l=1:length(params)
                        if ismember(params(l),{vars.name});
                            load(str_file,char(params(l)));
                            temp(count,l+1) = {eval(char(params(l)))};
                            %S(i,j,k,l)=eval(char(params(l)));
                            S_temp(1,l) = eval(char(params(l)));
                        end
                    end
                end
                % Case 2 : *-L. exists
                if exist(fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(k)),str_dir_2,strcat(char(regions(j)),'-L.mat')),'file')>0;
                    str_file = fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(k)),str_dir_2,strcat(char(regions(j)),'-L.mat'));
                    vars = whos('-file',str_file);
                    count = count+1;
                    temp(count,1) = {str_file};
                    for l=1:length(params)
                        if ismember(params(l),{vars.name});
                            load(str_file,char(params(l)));
                            temp(count,l+1) = {eval(char(params(l)))};
                            %S(i,j,k,l)=eval(char(params(l)));
                            S_temp(2,l) = eval(char(params(l)));
                        end
                    end
                end
                % Case 3 : *-R. exists
                if exist(fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(k)),str_dir_2,strcat(char(regions(j)),'-R.mat')),'file')>0;
                    str_file = fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(k)),str_dir_2,strcat(char(regions(j)),'-R.mat'));
                    vars = whos('-file',str_file);
                    count = count+1;
                    temp(count,1) = {str_file};
                    for l=1:length(params)
                        if ismember(params(l),{vars.name});
                            load(str_file,char(params(l)));
                            temp(count,l+1) = {eval(char(params(l)))};
                            %S(i,j,k,l)=eval(char(params(l)));
                            S_temp(3,l) = eval(char(params(l)));
                        end
                    end
                end
                % Storing Mean in S
                S_mean=mean(S_temp,1,'omitnan');
                for l=1:length(params)
                    S(i,j,k,l)=S_mean(l);
                end
                
            end
        end
    end
else
    % No merging L-R
    for j = 1:length(regions)
        for k=1:length(refs)
            for i=1:length(files)
                if exist(fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(k)),str_dir_2,strcat(char(regions(j)),'.mat')),'file')>0;
                    str_file = fullfile(DIR_STATS,str_dir,char(files(i)),char(refs(k)),str_dir_2,strcat(char(regions(j)),'.mat'));
                    vars = whos('-file',str_file);
                    count = count+1;
                    temp(count,1) = {str_file};
                    for l=1:length(params)
                        if ismember(params(l),{vars.name});
                            load(str_file,char(params(l)));
                            temp(count,l+1) = {eval(char(params(l)))};
                            S(i,j,k,l)=eval(char(params(l)));
                        end
                    end
                end
            end
        end
    end
end
handles.SecondTable.Data = temp;
handles.SecondTable.UserData.temp = temp;
handles.SecondTable.UserData.S = S;
%handles.TabGroup.SelectedTab = handles.SecondTab;

display_Callback([],[],handles);
handles.MainFigure.Pointer = 'arrow';

end

function display_Callback(~,~,handles)
% Display Graph & Values

S = handles.SecondTable.UserData.S;
files = handles.FileTable.Data(handles.FileTable.UserData.Selection,2);
regions = handles.RegionTable.Data(handles.RegionTable.UserData.Selection,1);
refs = handles.RefTable.Data(handles.RefTable.UserData.Selection,1);
params = handles.ParamTable.Data(handles.ParamTable.UserData.Selection,1);

tit_tab = handles.TabGroup.SelectedTab.Title;
delete(findobj(handles.TabGroup,'Tag','GraphTab'));
delete(findobj(handles.TabGroup,'Tag','DataTab'));
margin = .04;

% Creating labels
regions_short = cell(size(regions));
for j=1:size(regions,1)
    t = char(regions(j,1));
    if handles.Checkbox1.Value
        regions_short(j) = {t(1:min(end,5))};
    else
        regions_short(j) = {strcat(t(1:min(end,4)),t(end-1:end))};
    end
end
%refs_short = cell(size(refs));
% for j=1:size(refs,1)
%     t = char(refs(j,1));
%     refs_short(j) = {t(1:5)};
% end
refs_shorts = regexprep(refs,'Ref-','');
refs_shorts = regexprep(refs_shorts,'-Doppler_normalized','');
refs_shorts = regexprep(refs_shorts,'-Doppler_reconstructed_PCA','P');
refs_shorts = regexprep(refs_shorts,'Gamma-high-','Ghigh');
refs_shorts = regexprep(refs_shorts,'Gamma-low-','Glow');
refs_shorts = regexprep(refs_shorts,'Gamma-mid-','Gmid');
refs_short = regexprep(refs_shorts,'Theta--','Thet-');


files_short = cell(size(files));
for j=1:size(files,1)
    t = char(files(j,1));
    files_short(j) = {t(10:15)};
end

% Formatting labels
switch strtrim(handles.Popup1.String(handles.Popup1.Value,:))
    case 'Reference'
        switch handles.ButtonGroup.SelectedObject.String
            case 'Regions'
                labels = regions;
                labs = regions_short;
                grouped = files;
                groups = files_short;
            case 'Files'
                labels = files;
                labs= files_short;
                grouped = regions;
                groups = regions_short;
        end
    case 'File'
        switch handles.ButtonGroup.SelectedObject.String
            case 'Regions'
                labels = regions;
                labs = regions_short;
                grouped = refs;
                groups = refs_short;
            case 'References'
                labels = refs;
                labs= refs_short;
                grouped = regions;
                groups = regions_short;
        end
    case 'Region'
        switch handles.ButtonGroup.SelectedObject.String
            case 'References'
                labels = refs;
                labs = refs_short;
                grouped = files;
                groups = files_short;
            case 'Files'
                labels = files;
                labs= files_short;
                grouped = refs;
                groups = refs_short;
        end
end

N = str2double(handles.Edit1.String);
for l=1:length(params)
    tab = uitab('Parent',handles.TabGroup,...
        'Title',char(params(l)),...
        'Tag','GraphTab');
    tab2 = uitab('Parent',handles.TabGroup,...
        'Title',strcat(char(params(l)),'(dat)'),...
        'Tag','DataTab');

    for k=1:N
        axPanel = uipanel('FontSize',12,...
            'Units','normalized',...
            'Position',[0 (k-1)/N 1 1/N],...
            'Tag','GraphPanel',...
            'Parent',tab);
        ax = axes('Parent',axPanel,...
            'Tag','Ax1',...
            'Position',[margin 2.5*margin .7-2*margin 1-3*margin]);
        ax2 = axes('Parent',axPanel,...
            'Tag','Ax2',...
            'Position',[.7 2.5*margin .3-margin 1-3*margin]);
        linkaxes([ax,ax2],'xy');
        popup = uicontrol('Units','normalized',...
            'Style','popup',...
            'Tag',sprintf('popup%d',k),...
            'Position',[0 .9 .02 .1],...
            'Parent',axPanel);
        
        % Display Data
        % Display Values
        dataPanel = uipanel('FontSize',12,...
            'Units','normalized',...
            'Position',[0 (k-1)/N 1 1/N],...
            'Tag','DataPanel',...
            'Parent',tab2);
        t1 = uitable('Units','normalized',...
            'Position',[margin/5 margin/5 .7-2*margin/5 1-2*margin/5],...
            'Tag','Table1',...
            'RowStriping','on',...
            'Parent',dataPanel);
        t2 = uitable('ColumnName',{'Mean','Variance'},...
            'Units','normalized',...
            'Position',[.7 margin/5 .3-margin/5 1-2*margin/5],...
            'Tag','Table2',...
            'RowStriping','on',...
            'Parent',dataPanel);
        
        switch strtrim(handles.Popup1.String(handles.Popup1.Value,:))
            case 'Reference'
                popup.String = refs;
                switch handles.ButtonGroup.SelectedObject.String
                    case 'Regions'
                        %nothing
                    case 'Files'
                        S = permute(handles.SecondTable.UserData.S,[2,1,3,4]);
                end
            case 'File'
                popup.String = files;
                switch handles.ButtonGroup.SelectedObject.String
                    case 'Regions'
                        S = permute(handles.SecondTable.UserData.S,[3,2,1,4]);
                    case 'References'
                        S = permute(handles.SecondTable.UserData.S,[2,3,1,4]);
                end
                
            case 'Region'
                popup.String = regions;
                switch handles.ButtonGroup.SelectedObject.String
                    case 'References'
                        S = permute(handles.SecondTable.UserData.S,[1,3,2,4]);
                    case 'Files'
                        S = permute(handles.SecondTable.UserData.S,[3,1,2,4]);
                end
        end
        
        popup.Value = k;
        popup.UserData.S = S(:,:,:,l);
        popup.UserData.labels = labels;
        popup.UserData.labs = labs;
        popup.UserData.grouped = grouped;
        popup.UserData.groups = groups;
        popup.Callback={@popup_Callback,ax,ax2,dataPanel,t1,t2};
        b = popup_Callback(popup,[],ax,ax2,dataPanel,t1,t2);
    end
end

tab = findobj(handles.MainFigure,'Title',tit_tab);
if ~isempty(tab)
    handles.TabGroup.SelectedTab = tab;
end

l=legend(b,groups);
handles.Checkbox2.Callback = {@update_checkbox2,l};
update_checkbox2(handles.Checkbox2,[],l);

end

function update_checkbox2(hObj,~,l)
if hObj.Value
    l.Visible = 'on';
else
    l.Visible = 'off';
end
end

function b=popup_Callback(hObj,~,ax,ax2,dataPanel,t1,t2)

% Changing Title
tit = strtrim(hObj.String(hObj.Value,:));
hObj.Parent.Title = regexprep(tit,'_','-');
dataPanel.Title = regexprep(tit,'_','-');
cla(ax);
cla(ax2);

S = hObj.UserData.S;
labels = hObj.UserData.labels;
labs = hObj.UserData.labs;
grouped = hObj.UserData.grouped;
groups = hObj.UserData.groups;
k = hObj.Value;
%files = handles.FileTable.Data(handles.FileTable.UserData.Selection,2);
%regions = handles.RegionTable.Data(handles.RegionTable.UserData.Selection,1);

% Display Graph
b=bar(S(:,:,k)','Parent',ax);
bar_data = mean(S(:,:,k),1,'omitnan');
ebar_data = std(S(:,:,k),0,1,'omitnan');
hold(ax2,'on');
bar(bar_data,'Parent',ax2);
errorbar(bar_data,ebar_data,...
    'Color','k',...
    'Parent',ax2,...
    'LineStyle','none',...
    'MarkerSize',3,...
    'LineWidth',.5);
%e.LData = zeros(size(e.UData));
hold(ax2,'off');

ax.XLim = [.5 length(labels)+.5];
ax.XTick = 1:length(labels);
ax.XTickLabel = labs;
%ax.XTickLabelRotation = 45;
ax2.XLim = [.5 length(labels)+.5];
ax2.XTick = 1:length(labels);
ax2.XTickLabel = labs;
%ax2.XTickLabelRotation = 45;

% Display Data Table
t1.ColumnEditable = false(1,size(grouped,1))==1;
t1.ColumnName = groups;
t1.RowName = labs;
t1.Data = S(:,:,k)';
t1.ColumnWidth = num2cell(80*ones(1,size(grouped,1)));

t2.RowName = labels;
t2.Data = [mean(S(:,:,k)',2,'omitnan'),std(S(:,:,k)',0,2,'omitnan')];

end