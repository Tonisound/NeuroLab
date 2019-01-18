function [Xdata,Ydata,ind_start,ind_end,ref_time,f_samp]= compute_channels(handles,Time_indices,ind_events,f_int)

% Getting Data from uiconntrols
time_ref = handles.ButtonCompute.UserData.time_ref;
lines_channels = handles.ButtonCompute.UserData.lines_channels;

% Parameters
ind_channels = handles.fUSTable.UserData.Selection;
fUS_Selection = handles.fUSTable.Data(ind_channels,:);
lines_channels = lines_channels(ind_channels);

% Building XData
[longest,~] = max(Time_indices(:,4)-Time_indices(:,1));
ref_time = 0:1/f_int:longest;
Xdata = NaN(length(ind_events),length(ref_time));
for i=1:length(ind_events)
    temp = (Time_indices(i,1):1/f_int:Time_indices(i,4));
    Xdata(i,1:length(temp))=temp;
end
[~,ind_start] = min((Xdata-repmat(Time_indices(:,2),1,length(ref_time))).^2,[],2);
[~,ind_end] = min((Xdata-repmat(Time_indices(:,3),1,length(ref_time))).^2,[],2);

% Building YData
Ydata = NaN(length(ind_events),length(ref_time),length(ind_channels));
f_samp = NaN(length(ind_channels),1);
for k = 1:length(ind_channels)
    switch char(fUS_Selection(k,2))
        % Trace_Cerep
        case {'Trace_Cerep'}
            X = lines_channels(k).UserData.X;
            Y = lines_channels(k).UserData.Y;
            f_samp(k) = length(lines_channels(k).UserData.X)/(lines_channels(k).UserData.X(end));
            % Other Traces
        otherwise
            X = time_ref.Y;
            Y = (lines_channels(k).YData(~isnan(lines_channels(k).YData)))';
            f_samp(k) = 1./(X(2)-X(1));
    end   
    % Extracting data
    for i=1:length(ind_events)
        ind_keep = ((X-Time_indices(i,1)).*(X-Time_indices(i,4)))<0;
        x = X(ind_keep);
        y = Y(ind_keep);
        if ~isempty(y)
            [~,ind_first] = min((Xdata(i,:)-x(1)).^2);
            [~,ind_last] = min((Xdata(i,:)-x(end)).^2);
            y_resamp = resample(y,round(100*f_int),round(100*f_samp(k)));
            l = min(ind_last-ind_first+1,length(y_resamp));
            Ydata(i,ind_first:ind_first+l-1,k) = y_resamp(1:l);
        end
    end
end

% Gaussian Smoothing
t_gauss = str2double(handles.Edit5.String);
if t_gauss>0

%     l = hObj.UserData.lines_channels_0;
%     t = hObj.UserData.lines_electrodes_0;
%     for i=1:length(l)
%         x = l(i).XData;
%         y = l(i).YData;
%         delta = x(2)-x(1);
%         l(i).YData = imgaussfilt(y,round(t_gauss/delta));
%     end
%     for i=1:length(t)
%         x = t(i).UserData.X;
%         y = t(i).UserData.Y;
%         delta = x(2)-x(1);
%         t(i).UserData.Y = imgaussfilt(y,round(t_gauss/delta));
%     end
    delta = 1/f_int;
    Ydata_smooth = imgaussfilt3(Ydata,[1,round(t_gauss/delta),1],'FilterDomain','spatial');

%     % Feeding Data to Button Compute
%     hObj.UserData.lines_channels = l;
%     hObj.UserData.lines_electrodes = t;
%     % Passing Data to popup
%     handles.Popup1.UserData.lines_channels = hObj.UserData.lines_channels;
%     handles.Popup2.UserData.lines_electrodes = hObj.UserData.lines_electrodes;
    fprintf('Gaussian smoothing [Kernel = %.1f s].\n',t_gauss);
else
    fprintf('No smoothing.\n');
    Ydata_smooth = Ydata;
%     hObj.UserData.lines_channels = hObj.UserData.lines_channels_0;
%     hObj.UserData.lines_electrodes = hObj.UserData.lines_electrodes_0;
%     % Passing Data to popup
%     handles.Popup1.UserData.lines_channels = hObj.UserData.lines_channels;
%     handles.Popup2.UserData.lines_electrodes = hObj.UserData.lines_electrodes;
end


end