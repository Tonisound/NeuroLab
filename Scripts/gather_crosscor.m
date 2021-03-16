d = dir(fullfile('I:\NEUROLAB\NLab_Statistics\Cross_Correlation\*','*RUN.mat'));
dd = dir(fullfile('I:\NEUROLAB\NLab_Statistics\Cross_Correlation\*','*WHOLE.mat'));
ddd = [];

for i = 1:length(FILES)
    %ind_keep = contains({d(:).name}',strcat('_',FILES(i).mainchannel,'_')).*contains({d(:).name}',FILES(i).recording);
    ind_keep = find((contains({d(:).name}',strcat('_',FILES(i).mainchannel,'_')).*contains({d(:).name}',FILES(i).recording))==1);
    if ~isempty(ind_keep)
        ddd = [ddd ;{d(ind_keep).name}];
        continue;
    end
    
    %ind_keep = contains({dd(:).name}',strcat('_',FILES(i).mainchannel,'_')).*contains({dd(:).name}',FILES(i).recording);
    ind_keep = find((contains({dd(:).name}',strcat('_',FILES(i).mainchannel,'_')).*contains({dd(:).name}',FILES(i).recording))==1);
    
    if ~isempty(ind_keep)
        %i
        %find(ind_keep)==1
        ddd = [ddd ;{dd(ind_keep).name}];
        continue;
    end
end