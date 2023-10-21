function [X,Y]=quick_generate_event(S,length_event,t_sampling)

% S = data.EyeMvt;
if nargin <3
    t_sampling = .1;
end
if nargin <2
    length_event = 1;
end

% X = S.Raw.Time;
X = S.Raw.Time(1):t_sampling:S.Raw.Time(end);
Y = zeros(size(X));
for i=1:length(S.Events)
%     cur_event = S.Events(i);
    event_start = S.Events(i)-length_event/2;
    event_end = S.Events(i)+length_event/2;
    [~,ind_start] = min(abs(X-event_start));
    [~,ind_end] = min(abs(X-event_end));
    if ind_start~=ind_end
%         Y(ind_start:ind_end) = 1;
        L = gausswin(ind_end-ind_start+1);
        Y(ind_start:ind_end) = L;
    end
end
end