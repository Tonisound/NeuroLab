function success = import_externalfiles(dir_recording,dir_save,handles,val)

success = false;

% Manual mode val = 1; batch mode val =0
if nargin<4
    val = 1;
end

% Loading Config.mat
if exist(fullfile(dir_save,'Config.mat'),'file')
    data_c = load(fullfile(dir_save,'Config.mat'),'File');
    F = data_c.File;
else
    errordlg('Missing file Config.mat [%s]',dir_save);
    return;
end
% Loading Time reference
if exist(fullfile(dir_save,'Time_Reference.mat'),'file')
    data_t = load(fullfile(dir_save,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
else
    errordlg(sprintf('Missing File %s',fullfile(dir_save,'Time_Reference.mat')));
    return;
end


%Filling F.dir_ext if empty
if isempty(F.dir_ext)
    d = dir(fullfile(dir_recording,'*_ext'));
    if ~isempty(d)
        F.dir_ext = char(d(1).name);
        File = F;
        save(fullfile(dir_save,'Config.mat'),'File','-append');
        fprintf('File Config.mat appended [%s].\n',dir_save);
    else
        errordlg(sprintf('Empty/Missing External Directory [%s]',dir_recording));
        return;
    end
end

% Searchind directory
d = dir(fullfile(dir_recording,F.dir_ext,'*.ext'));
% Removing hidden files
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
if isempty(d)
    errordlg('Empty Directory [%s]',fullfile(dir_recording,F.dir_ext));
    return;
else
    if val ==1
        [ind_ext,ok] = listdlg('PromptString','Select Files',...
            'SelectionMode','multiple','ListString',{d.name}','ListSize',[300 500]);
    else
        % batch mode
        pattern_list = {'ACCELEROMETER_0_Posture_power';'Body_position_X_(m)';'Body_position_Y_(m)';'Body_speed_(m_s)'};
        ind_ext = find(contains({d.name}',pattern_list)==1);
        ok = true;
    end
    if ~ok || isempty(ind_ext)
        return;
    end
end


% Converting to traces
traces = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});
all_files = {d(ind_ext).name}';
for i=1:length(all_files)
    filename = char(all_files(i));
    file_ext = fullfile(dir_recording,F.dir_ext,filename);
    
    fid_ext = fopen(file_ext,'r');
    header = fgetl(fid_ext);
    header = regexp(header,'\t+','split');
    
    % Format readout
    ind_keep = contains(header,'format');
    header_keep = char(header(ind_keep));
    format = strrep(header_keep,'format=','');
    ind_keep = contains(header,'nb_samples');
    header_keep = char(header(ind_keep));
    nb_samples = eval(strrep(header_keep,'nb_samples=',''));
    ind_keep = contains(header,'parent');
    header_keep = char(header(ind_keep));
    parent = strrep(header_keep,'parent=','');
    ind_keep = contains(header,'shortname');
    header_keep = char(header(ind_keep));
    shortname = strrep(header_keep,'shortname=','');
    ind_keep = contains(header,'fullname');
    header_keep = char(header(ind_keep));
    fullname = strrep(header_keep,'fullname=','');
    
    X = NaN(nb_samples,1);
    Y = NaN(nb_samples,1);
    for k = 1:nb_samples
        X(k) = fread(fid_ext,1,format);
        Y(k) = fread(fid_ext,1,format);
    end
    fclose(fid_ext);
    fprintf('External File loaded at %s.\n',file_ext);

    % Storing data in traces
    %duration = X(end);
    %f_samp = 1:(X(2)-X(1));
    traces(i).ID = sprintf('%03d',i);
    traces(i).shortname = shortname;
    traces(i).parent = parent;
    traces(i).fullname = fullname;
    traces(i).X = X;
    traces(i).Y = Y;
    traces(i).X_ind = data_t.time_ref.X;
    traces(i).X_im = data_t.time_ref.Y;
    traces(i).Y_im = interp1(traces(i).X,traces(i).Y,traces(i).X_im);
    traces(i).nb_samples = nb_samples;
    %fprintf('Succesful Importation %s [Parent %s].\n',traces(i).fullname,traces(i).parent);
end


% Direct Trace Loading
ind_traces = 1:length(traces);
% getting lines name
lines = findobj(handles.RightAxes,'Tag','Trace_Cerep');
lines_name = cell(length(lines),1);
for i =1:length(lines)
    lines_name{i} = lines(i).UserData.Name;
end


for i=1:length(ind_traces)
    
    % Updating UserData
    t = traces(ind_traces(i)).fullname;
    %p = traces(ind_traces(i)).parent;
    %BEHAVIOR
    t = strrep(t,'BEHAVIOR_0_Position_continuous_estimate__Body_position_X_(m)_B0_B0[B0]','X(m)');
    t = strrep(t,'BEHAVIOR_0_Position_continuous_estimate__Body_position_Y_(m)_B0_B0[B0]','Y(m)');
    t = strrep(t,'BEHAVIOR_0_Position_continuous_estimate__Body_speed_(m/s)_B0_B0[B0]','SPEED');
    %t = regexprep(t,'[B0]','');
    % ACCEL
    %t = regexprep(t,'Accelerometer_LFP_','');
    t = strrep(t,'ACCELEROMETER_0_Posture_power','ACCEL_POWER');
    t = strrep(t,'ACCELEROMETER_0_Source_filtered_for_posture','ACCEL');
    % EMG
    %t = regexprep(t,'MUA_LFP_','');
    %t = regexprep(t,'MUA_0_Source_filtered_for_mult','EMG');
    %t = regexprep(t,'MUA_0_Multiunit_frequency__Fas|MUA_0_Multiunit_frequency__Slo','EMG_POWER');
    % LFP
    t = strrep(t,'LFP_0_Phasic_theta_power','Phasic_theta');
    t = strrep(t,'LFP_0_Theta_power','Theta');
    t = regexprep(t,'_','-');
    
    if sum(strcmp(t,lines_name))>0
        %line already exists overwrite
        ind_overwrite = find(strcmp(t,lines_name)==1);
        lines(ind_overwrite).UserData.Y = traces(ind_traces(i)).Y;
        lines(ind_overwrite).YData = traces(ind_traces(i)).Y_im;
        fprintf('External Trace successfully updated (%s)\n',traces(ind_traces(i)).fullname);
    else
        %line creation
        %str = lower(char(traces(ind_traces(i)).fullname));
        color = rand(1,3);
        hl = line('XData',traces(ind_traces(i)).X_ind,...
            'YData',traces(ind_traces(i)).Y_im,...
            'Color',color,...
            'Tag','Trace_Cerep',...
            'Visible','off',...
            'HitTest','off',...
            'Parent', handles.RightAxes);
        
        if handles.RightPanelPopup.Value==4
            set(hl,'Visible','on');
        end
        % Line creation
        s.Name = t;
        s.X = traces(ind_traces(i)).X;
        s.Y = traces(ind_traces(i)).Y;
        hl.UserData = s;
        fprintf('External Trace successfully loaded (%s)\n',traces(ind_traces(i)).fullname);
    end
    
end

success = true;

end