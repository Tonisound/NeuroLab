function [bar_data,ebar_data] = compute_cfc_episode(phase_signal,power_signal,t1,t2,bins)
% Computes phase frequency coupling for episode starting at t1 ending at t2
% (seconds)
%bins = 0:10:720;

f_samp = phase_signal.nb_samples/phase_signal.X(end);
X = phase_signal.X(ceil(f_samp*t1):min(phase_signal.nb_samples,round(f_samp*t2)));
Y = phase_signal.Y(ceil(f_samp*t1):min(phase_signal.nb_samples,round(f_samp*t2)));

% Extracting ascending zeros
temp = Y(1);
zero_phase_ascend = [];
zero_phase_descend = [];
count = 1;
while count<length(Y)
    count=count+1;
    while temp*Y(count)>0 && count<length(Y)
        count=count+1;
    end
    if count~=length(Y)
        temp = Y(count);
        if temp>0
            zero_phase_ascend = [zero_phase_ascend;X(count)];
        else
            zero_phase_descend = [zero_phase_descend;X(count)];
        end
    end
end

% Computing CFC
f_samp = power_signal.nb_samples/power_signal.X(end);
X = power_signal.X(ceil(f_samp*t1):min(power_signal.nb_samples,round(f_samp*t2)));
Y = power_signal.Y(ceil(f_samp*t1):min(power_signal.nb_samples,round(f_samp*t2)));

Y_phase = NaN(size(Y));
a = repmat(X,1,length(zero_phase_ascend)) - repmat(zero_phase_ascend',size(X,1),1);
[~,zero_phase_ascend_index] = min(a.^2);
delta = diff(zero_phase_ascend_index);
for i=1:length(delta)
    switch mod(i,2)
        case 0,
            Y_phase(zero_phase_ascend_index(i):zero_phase_ascend_index(i)+delta(i)-1) = 0:1/delta(i):.9999;
        case 1,
            Y_phase(zero_phase_ascend_index(i):zero_phase_ascend_index(i)+delta(i)-1) = -1:1/delta(i):-.0001;
    end
end
Y_phase = Y_phase*360;
% Realigning phase to set 0 as theta-trough
Y_phase = mod(Y_phase+360+90,720);

% Extracting Histogram
A = repmat(bins(1:end-1),length(Y_phase),1);
B = repmat(bins(2:end),length(Y_phase),1);
Y_phase_mat = repmat(Y_phase,1,length(bins)-1);
index_bins_1 = Y_phase_mat-A>=0;
index_bins_2 = Y_phase_mat-B<0;
index_bins = (index_bins_1+index_bins_2)==2;
Y_mat = repmat(Y,1,length(bins)-1);
Y_mat = Y_mat.*index_bins;
Y_mat(Y_mat==0)=NaN;

bar_data = mean(Y_mat,1,'omitnan');
ebar_data = std(Y_mat,1,'omitnan');
bar_data = [bar_data,bar_data(1)];
ebar_data = [ebar_data,ebar_data(1)];

end