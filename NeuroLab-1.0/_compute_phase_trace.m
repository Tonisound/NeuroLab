function [Ydata_phase_ascend,Ydata_phase_descend,all_Ydata_ascend,all_Ydata_descend] = compute_phase_trace(Xdata,Ydata,X_phase,Y_phase,l)
% Compute phase-rescaled data from phase signal (X_phase,Y_phase)
% Input data (Xdata,Ydata) must be same length
% Output data size defined from bins

Ydata = Ydata(:)';
% Extracting ascending zeros
temp = Y_phase(1);
ind_ascend = [];
ind_descend = [];
count = 1;
while count<length(Y_phase)
    count=count+1;
    while temp*Y_phase(count)>0 && count<length(Y_phase)
        count=count+1;
    end
    if count~=length(Y_phase)
        temp = Y_phase(count);
        if temp>0
            [~,i_a] = min((Xdata-X_phase(count)).^2);
            ind_ascend = [ind_ascend;i_a];
        else
            [~,i_d] = min((Xdata-X_phase(count)).^2);
            ind_descend = [ind_descend;i_d];
        end
    end
end

% Clearing ind_ascend ind_descend
ind_descend(diff(ind_descend)==1)=[];
ind_ascend(diff(ind_ascend)==1)=[];

% Skipping 1 out of 2
ind_descend = ind_descend(1:2:end);
ind_ascend = ind_ascend(1:2:end);

all_Ydata_ascend = zeros(length(ind_ascend)-3,l);
%f = figure;
for i=1:length(ind_ascend)-3
    temp = Ydata(ind_ascend(i):ind_ascend(i+3));
    r = resample(temp,3*l,length(temp));
    all_Ydata_ascend(i,:)=r(l+1:2*l);
end
%close(f)
Ydata_phase_ascend = mean(all_Ydata_ascend,1);

all_Ydata_descend = zeros(length(ind_descend)-3,l);
for i=1:length(ind_descend)-3
    temp = Ydata(ind_descend(i):ind_descend(i+3));
    r = resample(temp,3*l,length(temp));
    all_Ydata_descend(i,:)=r(l+1:2*l);
end
Ydata_phase_descend = mean(all_Ydata_descend,1);

end