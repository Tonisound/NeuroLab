seed = '/Users/tonio/Documents/Antoine-fUSDataset/DATA/';
all_parents = [{'fUS-POGONA/20190730_Pogona1_MySession/20190730_P1-003_E/20190730_P1-003_ext'};...
    {'fUS-POGONA/20190730_Pogona1_MySession/20190730_P1-004_E/20190730_P1-004_ext'};...
    {'fUS-POGONA/20190930_Pogona3_MySession/20190930_P3-020_E/20190930_P3-020_ext'};...
    {'fUS-POGONA2/20200715_Pogona5_MySession/20200715_P5-033_E/20200715_P5-033_ext'};...
    {'fUS-POGONA2/20200716_Pogona5_MySession/20200716_P5-038_E/20200716_P5-038_ext'};...
    {'fUS-POGONA2/20200718_Pogona6_MySession/20200718_P6-045_E/20200718_P6-045_ext'}];
all_files = [{'Essai3-Breath_EM.mat'};...
    {'Essai4-Breath_EM.mat'};...
    {'Essai20-Breath_EM.mat'};...
    {'Essai33-Breath_EM.mat'};...
    {'Essai38-Breath_EM.mat'};...
    {'Essai45-Breath_EM.mat'}];


for i =1:length(all_files)
    cur_parent = char(all_parents(i));
    cur_file = char(all_files(i));
    data = load(fullfile(seed,cur_parent,cur_file));
    fprintf('Data Loaded [%s].\n',cur_file);

    file_ext = 'BR-Raw.ext';
    X = data.Breathing.Raw.Time;
    Y = data.Breathing.Raw.Data;
    quick_export_ext(X,Y,fullfile(seed,cur_parent,file_ext));
    fprintf('Data Exported [%s].\n',fullfile(cur_parent,file_ext));

    file_ext = 'BR-Rate.ext';
    X = data.Breathing.Rate.TimeSec;
    Y = data.Breathing.Rate.DataBPM;
    quick_export_ext(X,Y,fullfile(seed,cur_parent,file_ext));
    fprintf('Data Exported [%s].\n',fullfile(cur_parent,file_ext));

    file_ext = 'BR-Smooth.ext';
    X = data.Breathing.Resamp.Time;
    Y = data.Breathing.Resamp.SmoothData;
    quick_export_ext(X,Y,fullfile(seed,cur_parent,file_ext));
    fprintf('Data Exported [%s].\n',fullfile(cur_parent,file_ext));

    file_ext = 'EM-Raw.ext';
    X = data.EyeMvt.Raw.Time;
    Y = data.EyeMvt.Raw.Data;
    quick_export_ext(X,Y,fullfile(seed,cur_parent,file_ext));
    fprintf('Data Exported [%s].\n',fullfile(cur_parent,file_ext));

    file_ext = 'EM-Smooth.ext';
    X = data.EyeMvt.Resamp.Time;
    Y = data.EyeMvt.Resamp.SmoothData;
    quick_export_ext(X,Y,fullfile(seed,cur_parent,file_ext));
    fprintf('Data Exported [%s].\n',fullfile(cur_parent,file_ext));

    % Events
    X = 0:.01:data.Breathing.Raw.Time(end);
    n_step_evt = 5; 

    file_ext = 'BR-Evt-In.ext';
    Y = zeros(size(X));
    t_events = [data.Breathing.Events.TimeSecInspiration(:)];
    for k =1:length(t_events)
        cur_t_event = t_events(k);
        [~,ind_event] = min((X-cur_t_event).^2);
        if (ind_event~=1) && (ind_event~=length(X))
            Y(max(ind_event-n_step_evt,1):min(ind_event+n_step_evt,length(X)))=1;
        end
    end 
    quick_export_ext(X,Y,fullfile(seed,cur_parent,file_ext));
    fprintf('Data Exported [%s].\n',fullfile(cur_parent,file_ext));

    file_ext = 'BR-Evt-Exp.ext';
    Y = zeros(size(X));
    t_events = [data.Breathing.Events.TimeSecExpiration(:)];
    for k =1:length(t_events)
        cur_t_event = t_events(k);
        [~,ind_event] = min((X-cur_t_event).^2);
        if (ind_event~=1) && (ind_event~=length(X))
            Y(max(ind_event-n_step_evt,1):min(ind_event+n_step_evt,length(X)))=1;
        end
    end 
    quick_export_ext(X,Y,fullfile(seed,cur_parent,file_ext));
    fprintf('Data Exported [%s].\n',fullfile(cur_parent,file_ext));

    file_ext = 'BR-Evt-All.ext';
    Y = zeros(size(X));
    t_events = [data.Breathing.Events.TimeSecInspiration(:);data.Breathing.Events.TimeSecExpiration(:)];
    for k =1:length(t_events)
        cur_t_event = t_events(k);
        [~,ind_event] = min((X-cur_t_event).^2);
        if (ind_event~=1) && (ind_event~=length(X))
            Y(max(ind_event-n_step_evt,1):min(ind_event+n_step_evt,length(X)))=1;
        end
    end 
    quick_export_ext(X,Y,fullfile(seed,cur_parent,file_ext));
    fprintf('Data Exported [%s].\n',fullfile(cur_parent,file_ext));

    file_ext = 'EM-Evt-All.ext';
    Y = zeros(size(X));
    t_events = [data.EyeMvt.Events(:)];
    for k =1:length(t_events)
        cur_t_event = t_events(k);
        [~,ind_event] = min((X-cur_t_event).^2);
        if (ind_event~=1) && (ind_event~=length(X))
            Y(max(ind_event-n_step_evt,1):min(ind_event+n_step_evt,length(X)))=1;
        end
    end 
    quick_export_ext(X,Y,fullfile(seed,cur_parent,file_ext));
    fprintf('Data Exported [%s].\n',fullfile(cur_parent,file_ext));
    
end