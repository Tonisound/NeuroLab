function success = segregate_ripple_events(savedir,val)
% Load csv event file and generates subgroups stored in csv files

success = false;

% Select event file
folder_events = fullfile(savedir,'Events');
d_events = dir(fullfile(folder_events,'*All.csv'));
d_events = d_events(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_events));
if isempty(d_events)
    warning('Event files not found [%s].',folder_events);
    return;
end

for k=1:length(d_events)
    
    % Read csv event file
    event_name = char(d_events(k).name);
    event_file = fullfile(folder_events,event_name);
    [events,EventHeader,MetaData] = read_csv_events(event_file);
    n_events = size(events,1);

    % Sanity Check
    if isempty(events)
        warning('Empty file [File: %s]',event_file);
        continue;
    end

    % Event Parameters
%     mean_dur = mean(events(:,4),1,'omitnan');
%     mean_freq = mean(events(:,5),1,'omitnan');
%     mean_p2p = mean(events(:,6),1,'omitnan');
    % Restricting events
    [~,ind_sorted_occurence] = sort(events(:,2),'ascend');
    [~,ind_sorted_duration] = sort(events(:,4),'descend');
    [~,ind_sorted_frequency] = sort(events(:,5),'descend');
    [~,ind_sorted_amplitude] = sort(events(:,6),'descend');
    % % Keeping fixed ratio
    % ratio_keep = .1;
    % n_keep = round(ratio_keep*n_events)
    % Keeping fixed amount
    n_fixed = 50;
    n_keep = min(n_events,n_fixed);
    ind_keep_duration = ind_sorted_duration(1:n_keep);
    ind_keep_frequency = ind_sorted_frequency(1:n_keep);
    ind_keep_amplitude = ind_sorted_amplitude(1:n_keep);

    output_name = strrep(event_name,'All','Long');
    write_csv_events(fullfile(folder_events,output_name),events(ind_keep_duration,:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Fast');
     write_csv_events(fullfile(folder_events,output_name),events(ind_keep_frequency,:),EventHeader,MetaData);
    output_name = strrep(event_name,'All','Strong');
     write_csv_events(fullfile(folder_events,output_name),events(ind_keep_amplitude,:),EventHeader,MetaData);
%     output_file = strrep(event_name,'All','Short');
%     output_file = strrep(event_name,'All','Slow');
%     output_file = strrep(event_name,'All','Weak');

    % Sorting events
    
%     ind_duet = (diff(t_events)) < thresh_coupled;
%     ind_keep_duet = ([false;ind_duet]+[ind_duet;false])>0;
    events = events(ind_sorted_occurence,:);
    t_events = events(:,2);
    
    all_thresholds = [1,2,5];
    for j=1:length(all_thresholds)
        
        thresh_coupled = all_thresholds(j);
        counter = 1;
        events_isolated = [];
        events_grouped = [];
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
                events_isolated = [events_isolated;events(counter_start,1:3)];
                events_merged = [events_merged;events(counter_start,1:3)];
            else
                % coupled
                t_mid = (events(counter_start,1)+events(counter_stop,3))/2;
                events_grouped = [events_grouped;[events(counter_start,1),t_mid,events(counter_stop,3)]];
                events_merged = [events_merged;[events(counter_start,1),t_mid,events(counter_stop,3)]];
            end
            counter = counter+1;
            if counter==n_events
                % last isolated ripple
                events_isolated = [events_isolated;events(counter_start,1:3)];
            end
        end

        output_name = strrep(event_name,'All',sprintf('Isolated[%.2fsec]',thresh_coupled));
        write_csv_events(fullfile(folder_events,output_name),events_isolated,EventHeader,MetaData);
        output_name = strrep(event_name,'All',sprintf('Grouped[%.2fsec]',thresh_coupled));
        write_csv_events(fullfile(folder_events,output_name),events_grouped,EventHeader,MetaData);
        output_name = strrep(event_name,'All',sprintf('Merged[%.2fsec]',thresh_coupled));
        write_csv_events(fullfile(folder_events,output_name),events_merged,EventHeader,MetaData);
    end

end

success = true;

end