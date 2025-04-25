function success = segregate_ripple_events(savedir,val)
% Load csv event file and generates subgroups stored in csv files

success = false;

% Select event file
folder_events = fullfile(savedir,'Events');
pattern_event = {'[NREM]Ripples-Merged-All'};

for i=1:length(pattern_event)
    
    cur_pattern_event_csv = strcat(pattern_event{i},'.csv');
    d_events = dir(fullfile(folder_events,cur_pattern_event_csv));
    if isempty(d_events)
        warning('Event files not found [%s].',folder_events);
        continue;
    elseif length(d_events)>1
        warning('Multiple Event files found [%s]. Taking first.',folder_events);
        d_events = d_events(1);
    end
    
    % Read csv event file
    event_name = char(d_events.name);
    event_file = fullfile(folder_events,event_name);
    [events,EventHeader,MetaData] = read_csv_events(event_file);
    n_events = size(events,1);
    
    % Sanity Check
    if isempty(events)
        warning('Empty file [File: %s]',event_file);
        continue;
    elseif n_events<4
        warning('Too few events (%d): Cannot segregate in quartiles. [File: %s]',n_events,event_file);
        continue;
    end
    
    % Event Parameters
    mean_dur = mean(events(:,4),1,'omitnan');
    mean_freq = mean(events(:,5),1,'omitnan');
    mean_p2p = mean(events(:,6),1,'omitnan');
    fprintf('Loaded event file [%s] - Mean Parameters [%.2fsec - %.2fHz - %.2fuV].\n',event_name,mean_dur,mean_freq,mean_p2p);
    
    % Restricting events
    index_q1_start = 1;
    index_q1_end = round(n_events/4);
    index_q2_start = index_q1_end+1;
    index_q2_end = round(n_events/2);
    index_q3_start = index_q2_end+1;
    index_q3_end = round(3*n_events/4);   
    index_q4_start = index_q3_end+1;
    index_q4_end = n_events;

    [~,ind_sorted_occurence] = sort(events(:,2),'ascend');
    [~,ind_sorted_duration] = sort(events(:,4),'descend');
    [~,ind_sorted_frequency] = sort(events(:,5),'descend');
    [~,ind_sorted_amplitude] = sort(events(:,6),'descend');

    % Quartiles Occurence
    ind_segreg = ind_sorted_occurence;
    output_name = strrep(event_name,'All','Occurence-Q1');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q1_start:index_q1_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Occurence-Q2');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q2_start:index_q2_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Occurence-Q3');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q3_start:index_q3_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Occurence-Q4');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q4_start:index_q4_end),:),EventHeader,MetaData);
    % Quartiles Duration
    ind_segreg = ind_sorted_duration;
    output_name = strrep(event_name,'All','Duration-Q1');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q1_start:index_q1_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Duration-Q2');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q2_start:index_q2_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Duration-Q3');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q3_start:index_q3_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Duration-Q4');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q4_start:index_q4_end),:),EventHeader,MetaData);
    % Quartiles Frequency
    ind_segreg = ind_sorted_frequency;
    output_name = strrep(event_name,'All','Frequency-Q1');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q1_start:index_q1_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Frequency-Q2');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q2_start:index_q2_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Frequency-Q3');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q3_start:index_q3_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Frequency-Q4');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q4_start:index_q4_end),:),EventHeader,MetaData);
    % Quartiles Amplitude
    ind_segreg = ind_sorted_amplitude;
    output_name = strrep(event_name,'All','Amplitude-Q1');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q1_start:index_q1_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Amplitude-Q2');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q2_start:index_q2_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Amplitude-Q3');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q3_start:index_q3_end),:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Amplitude-Q4');
    write_csv_events(fullfile(folder_events,output_name),events(ind_segreg(index_q4_start:index_q4_end),:),EventHeader,MetaData);
    
    
    % % Keeping fixed ratio
    % ratio_keep = .1;
    % n_keep = round(ratio_keep*n_events)
    % Keeping fixed amount
    n_fixed = 50;
    n_keep = min(n_events,n_fixed);
    
    ind_keep_duration = ind_sorted_duration(1:n_keep);
    ind_keep_frequency = ind_sorted_frequency(1:n_keep);
    ind_keep_amplitude = ind_sorted_amplitude(1:n_keep);
    
    output_name = strrep(event_name,'All',sprintf('Duration[Top%d]',n_fixed));
    write_csv_events(fullfile(folder_events,output_name),events(ind_keep_duration,:),EventHeader,MetaData);
    output_name = strrep(event_name,'All',sprintf('Frequency[Top%d]',n_fixed));
    write_csv_events(fullfile(folder_events,output_name),events(ind_keep_frequency,:),EventHeader,MetaData);
    output_name = strrep(event_name,'All',sprintf('Amplitude[Top%d]',n_fixed));
    write_csv_events(fullfile(folder_events,output_name),events(ind_keep_amplitude,:),EventHeader,MetaData);
    
    % Sorting events
    %     ind_duet = (diff(t_events)) < thresh_coupled;
    %     ind_keep_duet = ([false;ind_duet]+[ind_duet;false])>0;
    events = events(ind_sorted_occurence,:);
    t_events = events(:,2);
    
    all_thresholds = 1;   % [1,2,5]; % threshold in seconds
    for j=1:length(all_thresholds)
        
        thresh_coupled = all_thresholds(j);
        counter = 1;
        events_single = [];
        % events_grouped = [];
        events_duet = [];
        events_triplet = [];
        events_more = [];
        events_merged = [];
        
        while counter<n_events
            counter_start = counter;
            while (counter<n_events) && ((t_events(counter+1)-t_events(counter)) < thresh_coupled)
                counter = counter+1;
            end
            counter_stop = counter;
            % Assigning isolated or grouped
            if counter_start == counter_stop
                % isolated
                events_single = [events_single;events(counter_start,:)];
                events_merged = [events_merged;events(counter_start,:)];
            else
                t_start = events(counter_start,1);
                t_mid = (events(counter_start,1)+events(counter_stop,3))/2;
                t_end = events(counter_stop,3);
                mean_dur = mean(events(counter_start:counter_stop,4));
                mean_freq = mean(events(counter_start:counter_stop,5));
                mean_p2p = mean(events(counter_start:counter_stop,6));
                events_merged = [events_merged;[t_start,t_mid,t_end,mean_dur,mean_freq,mean_p2p]];
                if (counter_stop-counter_start) == 1
                    % duet
                    events_duet = [events_duet;[t_start,t_mid,t_end,mean_dur,mean_freq,mean_p2p]];              
                elseif (counter_stop-counter_start) == 2
                    % triplet
                    events_triplet = [events_triplet;[t_start,t_mid,t_end,mean_dur,mean_freq,mean_p2p]];
                else
                    % more
                    events_more = [events_more;[t_start,t_mid,t_end,mean_dur,mean_freq,mean_p2p]];                
                end
            end
            counter=counter+1;
        end
        
        output_name = strrep(event_name,'All',sprintf('Burst-Single[%.2fsec]',thresh_coupled));
        write_csv_events(fullfile(folder_events,output_name),events_single,EventHeader,MetaData);
        output_name = strrep(event_name,'All',sprintf('Burst-Duet[%.2fsec]',thresh_coupled));
        write_csv_events(fullfile(folder_events,output_name),events_duet,EventHeader,MetaData);
        output_name = strrep(event_name,'All',sprintf('Burst-Triplet[%.2fsec]',thresh_coupled));
        write_csv_events(fullfile(folder_events,output_name),events_triplet,EventHeader,MetaData);
        output_name = strrep(event_name,'All',sprintf('Burst-Quadruplet[%.2fsec]',thresh_coupled));
        write_csv_events(fullfile(folder_events,output_name),events_more,EventHeader,MetaData);
        output_name = strrep(event_name,'All',sprintf('Burst-All[%.2fsec]',thresh_coupled));
        write_csv_events(fullfile(folder_events,output_name),events_merged,EventHeader,MetaData);
        
    end
end

success = true;

end