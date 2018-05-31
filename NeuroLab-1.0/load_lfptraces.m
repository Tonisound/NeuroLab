function success = load_lfptraces(folder_name,handles)

%global FILES CUR_FILE DIR_SAVE CUR_IM;
%folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);
success = false;

load('Preferences.mat','GDisp','GTraces');
if exist(fullfile(folder_name,'Cereplex_Traces.mat'),'file')
    load(fullfile(folder_name,'Cereplex_Traces.mat'),'traces','MetaData');
else
    errordlg(sprintf('Missing File %s',fullfile(folder_name,'Cereplex_Traces.mat')));
    return;
end

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

set(handles.MainFigure, 'pointer', 'arrow');
[ind_traces,ok] = listdlg('PromptString','Select Traces','SelectionMode','multiple','ListString',{traces.fullname},'ListSize',[400 500]);
g_colors = get(groot,'defaultAxesColorOrder');

if ~ok || isempty(ind_traces)
    return;
end

for i=1:length(ind_traces)
    str = lower(char(traces(ind_traces(i)).fullname));
    if strfind(str,'CA1')
        color = 'r';
    elseif strfind(str,'CA2')
        color = 'y';
    elseif strfind(str,'CA3')
        color = 'g';
    elseif strfind(str,'DG')
        color = 'b';
    elseif strfind(str,'thal')
        color = 'c';
    elseif strfind(str,'cortex')
        color = 'm';
    elseif strfind(str,'behavior')
        color = 'k';
    elseif strfind(str,'accel')
        color = [.5 .5 .5];
    elseif strfind(str,'theta_power')
        color = 'r';
    elseif strfind(str,'gamma_low_power')
        color = g_colors(1,:);
    elseif strfind(str,'gamma_mid_power')
        color = g_colors(2,:);
    elseif strfind(str,'gamma_high_power')
        color = g_colors(3,:);
    elseif strfind(str,'theta_background_')
        color = g_colors(4,:);
    elseif strfind(str,'gamma_mid_background_')
        color = g_colors(5,:);
    elseif strfind(str,'gamma_high_background_')
        color = g_colors(6,:);
    else
        color = rand(1,3);
    end
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
    
    % Updating UserData
    t = traces(ind_traces(i)).fullname;
    p = traces(ind_traces(i)).parent;
    %BEHAVIOR
    if strcmp(p,'BEHAVIOR_0_Position_continuous_estimate__Body_position_X_(m)_B0_B0')
        t = regexprep(t,'BEHAVIOR_0_Position_continuous','X(m)');
    elseif strcmp(p,'BEHAVIOR_0_Position_continuous_estimate__Body_position_Y_(m)_B0_B0')
        t = regexprep(t,'BEHAVIOR_0_Position_continuous','Y(m)');
    else
        t = regexprep(t,'BEHAVIOR_0_Position_continuous','SPEED');
    end
    t = regexprep(t,'/B0','');
    
    %LFP
    t = regexprep(t,'Source_filtered_for_thet','LFP-theta');
    t = regexprep(t,'background_pow|background_po','up');
    t = regexprep(t,'LFP_0_|_power|_po','');
    t = regexprep(t,'FUS_1_Region_continuous_estima','fUS');
    t = regexprep(t,'Source_filtered_for_back','LFP');
    
    % ACCEL
    t = regexprep(t,'Accelerometer_LFP_','');
    t = regexprep(t,'ACCELEROMETER_0_Posture','ACCEL_POWER');
    t = regexprep(t,'ACCELEROMETER_0_Source_filtere','ACCEL');
    
    % EMG
    t = regexprep(t,'MUA_LFP_','');
    t = regexprep(t,'MUA_0_Source_filtered_for_mult','EMG');
    t = regexprep(t,'MUA_0_Multiunit_frequency__Fas|MUA_0_Multiunit_frequency__Slo','EMG_POWER');
    
    s.Name = regexprep(t,'_','-');
    s.X = traces(ind_traces(i)).X;
    s.Y = traces(ind_traces(i)).Y;
    hl.UserData = s;
    
end
fprintf('Cereplex Trace successfully loaded (%s)\n',traces(ind_traces).fullname);
success = true;

end