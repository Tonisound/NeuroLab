function success = import_nlab_events(dir_events,dir_save,handles)

success = false;

%Loading Time Ref
if exist(fullfile(dir_save,'Time_Reference.mat'),'file')
    data_t = load(fullfile(dir_save,'Time_Reference.mat'),'time_ref');
    x_start = data_t.time_ref.Y(1);
    x_end = data_t.time_ref.Y(end);
    im_start = data_t.time_ref.X(1);
    im_end = data_t.time_ref.X(end);
else
    errordlg('File Time_Reference.mat not found.');
    return;
end

dir_time = dir(fullfile(dir_events,'*events.txt'));
% Removing hidden files
dir_time = dir_time(arrayfun(@(x) ~strcmp(x.name(1),'.'),dir_time));

switch length(dir_time)
    case 0
        errordlg(sprintf('Missing NLab Events File *events.txt (Dir %s)',dir_events));
        return;
    case 1
        ind_events = 1;
    otherwise
        [ind_events,ok] = listdlg('PromptString','Select NLab Events to import',...
            'SelectionMode','multiple','ListString',{dir_time.name},'ListSize',[300 500]);
        if isempty(ind_events) || ~ok
            return;
        end
end

% Finding episode names
events = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});
count = 0;
all_parents = [];

for i=1:length(ind_events)
    filename = fullfile(dir_events,dir_time(ind_events(i)).name);
    
    % Direct Importation
    fileID = fopen(filename,'r');
    hline = fgetl(fileID);
    hline = regexp(hline,'(\t+)','split');
    all_events = hline';
    
    % Reading line-by-line Testing for End of file
    D = [];
    while ~feof(fileID)
        tline = fgetl(fileID);
        if ~isempty(tline)
            temp = regexp(tline,'(\t+)','split');
            X = [];
            for j=1:length(temp)
                X = [X,str2double(char(temp(j)))];
            end
            D = [D;X];
        end
    end
    fclose(fileID);
    
    for j=1:length(all_events)
        count = count + 1;
        n_ep = size(D,1);
        all_parents = [all_parents ;{dir_time(ind_events).name}];
        events(count).shortname = char(all_events(j));
        events(count).parent = dir_time(ind_events).name;
        events(count).fullname = strcat(events(count).parent,'/',events(count).shortname);
        events(count).X = (1:n_ep)';
        events(count).Y = D(:,j);
        events(count).X_ind = events(count).X;
        events(count).X_im = events(count).X;
        % Rescaling
        min_event = min(events(count).Y);
        delta_min = (min_event-x_start)/(x_end-x_start);
        im_min = im_start+delta_min*(im_end-im_start);
        max_event = max(events(count).Y);
        delta_max = (max_event-x_start)/(x_end-x_start);
        im_max = im_start+delta_max*(im_end-im_start);
        events(count).Y_im = rescale(events(count).Y,im_min,im_max);
        events(count).nb_samples = n_ep;
    end  
end

% Show Events
% load('Preferences.mat','GColors');
delete(findobj(handles.RightAxes,'Tag','Event'));

S = struct('xdata',[],'ydata',[]);
for index=1:length(all_events)
    Y = events(index).Y_im;
    xdata = [Y,Y,NaN(size(Y))]';
    ydata = [repmat(handles.RightAxes.YLim,[size(Y,1),1]),NaN(size(Y))]';
%     line('XData',xdata(:),'YData',ydata(:),...'LineWidth',1,'LineStyle','-','Color',GColors.TimeGroups(index).Color,...
%         'LineWidth',.1,'LineStyle','-','Color',[.5 .5 .5],...
%         'Parent',handles.RightAxes,'Tag','Event','HitTest','off');
    S(index).xdata = xdata(:);
    S(index).ydata = ydata(:);
end
handles.EventBox.UserData.all_events = all_events;
handles.EventBox.UserData.all_parents = all_parents;
handles.EventBox.UserData.S = S;
boxEvent_Callback(handles.EventBox,[],handles.RightAxes);

% Save NeuroLab_Events.mat
fprintf('===> NeuroLab_Events saved at %s.mat\n',fullfile(dir_save,'NeuroLab_Events.mat'));
save(fullfile(dir_save,'NeuroLab_Events.mat'),'events','all_events','all_parents','-v7.3');

% Updating success
success = true;

end
