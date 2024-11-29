function t_sleepscored = Rat_noEMG_ACC(t_source,index_acc,index_emg,index_ratio1,index_ratio2)

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
% 3 - REM
% 4 - REM

for i =1:length(all_values)
    val = all_values(i);
    output  = all_outputs(i);
    t_sleepscored(ind_sleepscored==val) = output;
end

end