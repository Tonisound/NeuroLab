function [Zdata,Zdata_norm] = compute_crossfreq(handles,Time_indices,bins,ind_events)

% Building Zdata
% Extracting CFC channels
traces = handles.CFCPanel.UserData.traces;
ind_crossfreq = handles.CFCTable.UserData.Selection;
CFC_Selection = handles.CFCTable.Data(ind_crossfreq,:);
Zdata = NaN(length(ind_events),length(bins),length(ind_crossfreq));

for i=1:length(ind_crossfreq)
    temp = {traces.fullname};
    str = char(CFC_Selection(i,1));
    str = regexprep(str,'(','');
    str = regexprep(str,')','');
    ind_1 = ~(cellfun('isempty',strfind(temp,str(1:end-1))));
    ind_2 = ~(cellfun('isempty',strfind(temp,char(CFC_Selection(i,2)))));
    ind_3 = ~(cellfun('isempty',strfind(temp,'Source_filtered_for_thet')));
    if isempty(find(ind_3==1))
        errordlg('Missing Phase Signal. Import Spikoscope Traces.');
        return;
    end
    ind_power = find(ind_1&ind_2==1);
    ind_phase = find(ind_3&ind_2==1);
    switch length(ind_power)
        case 0,
            disp('Something wrong.');
        case 1
            phase_signal = traces(ind_phase).fullname;
            power_signal = traces(ind_power).fullname;           
        otherwise
            l=[];
            for k=1:length(ind_power)
                l = [l;length(traces(ind_power(k)).shortname)];
            end
            [~,ind]=min(l);
            ind_power = ind_power(ind);
            ind_phase = ind_phase(ind);
            phase_signal = traces(ind_phase).fullname;
            power_signal = traces(ind_power).fullname;
    end
    
    % Computing CFC for each episode
    for k=1:size(Time_indices,1)
        fprintf('Computing CFC %s %s - time [%d,%d]\n',phase_signal,power_signal,Time_indices(k,1),Time_indices(k,4));
        bar_data = compute_cfc_episode(traces(ind_phase),traces(ind_power),Time_indices(k,1),Time_indices(k,4),bins);
        Zdata(k,:,i) = bar_data;
    end
end
% Normalized Zdata
S  = sum(Zdata,2);
A = repmat(S,[1,size(Zdata,2),1]);
Zdata_norm = Zdata./A;
end