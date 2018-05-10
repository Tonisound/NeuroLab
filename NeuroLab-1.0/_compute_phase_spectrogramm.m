function [Cdata_phase_ascend,Cdata_phase_descend] = compute_phase_spectrogramm(Cdata,X_temp,X_phase,Y_phase,bins)
% Compute phase-spectrogram from phase signal (X_phase,Y_phase)
% Input Spectrogramm (X_temp,Cdata) must be same length
% Output spectrogramm size defined from bins

% Extracting ascending zeros
temp = Y_phase(1);
ind_ascend = [];
ind_descend = [];
%zero_phase_ascend = [];
%zero_phase_descend = [];
count = 1;
while count<length(Y_phase)
    count=count+1;
    while temp*Y_phase(count)>0 && count<length(Y_phase)
        count=count+1;
    end
    if count~=length(Y_phase)
        temp = Y_phase(count);
        if temp>0
            [~,i_a] = min((X_temp-X_phase(count)).^2);
            ind_ascend = [ind_ascend;i_a];
            %zero_phase_ascend = [zero_phase_ascend;X_phase(count)];
        else
            [~,i_d] = min((X_temp-X_phase(count)).^2);
            ind_descend = [ind_descend;i_d];
            %zero_phase_descend = [zero_phase_descend;X_phase(count)];
        end
    end
end

% Clearing ind_ascend ind_descend
ind_descend(diff(ind_descend)==1)=[];
%zero_phase_descend(diff(ind_descend)==1)=[];
ind_ascend(diff(ind_ascend)==1)=[];
%zero_phase_ascend(diff(ind_ascend)==1)=[];

all_Cdata = zeros(size(Cdata,1),length(bins)-1,length(ind_ascend)-1);
for i=1:length(ind_ascend)-1
    temp = Cdata(:,ind_ascend(i):ind_ascend(i+1)-1);
    step=(size(temp,2)-1)/(length(bins)-2);
    [subx,suby] = meshgrid(1:step:size(temp,2),1:size(temp,1));
    %im=interp2(temp,subx,suby);
    all_Cdata(:,:,i)=interp2(temp,subx,suby);
end
Cdata_phase_ascend = mean(all_Cdata,3);
all_Cdata = zeros(size(Cdata,1),length(bins)-1,length(ind_descend)-1);
for i=1:length(ind_descend)-1
    temp = Cdata(:,ind_descend(i):ind_descend(i+1)-1);
    step=(size(temp,2)-1)/(length(bins)-2);
    [subx,suby] = meshgrid(1:step:size(temp,2),1:size(temp,1));
    %im=interp2(temp,subx,suby);
    all_Cdata(:,:,i)=interp2(temp,subx,suby);
end
Cdata_phase_descend = mean(all_Cdata,3);

end