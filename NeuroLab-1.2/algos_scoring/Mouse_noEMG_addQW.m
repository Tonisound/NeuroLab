function t_sleepscored = Mouse_noEMG_addQW(t_source,index_acc,index_emg,index_ratio1,index_ratio2)

%t_sleepscored = 1+double(index_acc+index_emg+index_ratio1);
index_emg = index_acc;
t_sleepscored = NaN(size(index_acc));
ind_sleepscored = 1000*index_emg+100*index_acc+10*index_ratio1+index_ratio2;

all_values = [1111,1110,1101,1100,...
    1011,1010,1001,1000,...
    0111,0110,0101,0100,...
    0011,0010,0001,0000];
all_outputs = [1,1,1,1,...
    2,2,2,2,...
    1,1,1,1,...
    4,4,3,3];
% 1 - AW 
% 2 - QW
% 3 - NREM
% 4 - REM

for i =1:length(all_values)
    val = all_values(i);
    output  = all_outputs(i);
    t_sleepscored(ind_sleepscored==val) = output;
end

% Detecting AW bouts
cur_state = 0;
all_times = [];
index_times = [];
for i=1:length(t_sleepscored)
    if t_sleepscored(i)==1 && cur_state ~= 1
        t_start = t_source(i);
        index_start = i;
        cur_state = t_sleepscored(i);
    elseif t_sleepscored(i)~=1 && cur_state == 1
        t_end = t_source(i);
        index_end = i;
        cur_state = t_sleepscored(i);
        index_times = [index_times;index_start,index_end];
        all_times = [all_times;t_start,t_end];
    end
end

% Keeping long bouts
LongBoutSec = 20; % mouse
% LongBoutSec = 30; % pogo
ind_keep = find(all_times(:,2)-all_times(:,1)>=LongBoutSec);
index_endlongbouts = index_times(ind_keep,2);
% t_endlongbouts = all_times(ind_keep,2);

% Adding new bouts at the end
AddBoutSec = 120; % mouse
% AddBoutSec = 1200; % pogo
AddBoutLength = round(AddBoutSec/median(diff(t_source)));
t_addbout = zeros(size(t_source));
for i =1:length(index_endlongbouts)
    t_addbout(index_endlongbouts(i):index_endlongbouts(i)+AddBoutLength)=1;
end
t_addbout = t_addbout(1:length(t_source));

% Adding state2 (QW) if not in state 1 (AW)
t_sleepscored(t_addbout==1) = min(t_sleepscored(t_addbout==1),2);

end