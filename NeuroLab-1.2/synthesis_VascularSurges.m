function [T,S] = synthesis_VascularSurges()
% Synthesis Vascular Surges
% manuscript NCOMMS revision aug 2018
% Creates table to show surge variability

global FILES DIR_SAVE;

% D = [{'20141030_171821_E_nlab'},    {'mika_12'};
%     {'20150618_152536_E_nlab'},    {'dan_13' };
%     {'20150715_185020_E_nlab'},    {'luke_2' };
%     {'20150716_133328_E_nlab'},    {'luke_2' };
%     {'20150717_141703_E_nlab'},    {'luke_2' };
%     {'20150718_143603_E_nlab'},    {'luke_2' };
%     {'20150722_125909_E_nlab'},    {'luke_2' };
%     {'20150723_132153_E_nlab'},    {'luke_2' };
%     {'20150725_133626_E_nlab'},    {'luke_2' };
% %     {'20151130_114741_E_nlab'},    {'luke_18'};
% %     {'20151201_151333_E_nlab'},    {'luke_18'};
%     {'20151202_114014_E_nlab'},    {'luke_18'};
% %     {'20151203_120906_E_nlab'},    {'luke_18'};
% %     {'20151203_155249_E_nlab'},    {'luke_18'};
%     {'20151204_114214_E_nlab'},    {'luke_18'};
%     {'20151204_150225_E_nlab'},    {'luke_18'};
%     {'20160620_180313_E_nlab'},    {'will_4' };
%     {'20160620_180314_E_nlab'},    {'will_4' };
%     {'20160620_180315_E_nlab'},    {'will_4' };
%     {'20160620_180316_E_nlab'},    {'will_4' };
%     {'20160621_153455_E_nlab'},    {'will_2' };
%     {'20160622_195651_E_nlab'},    {'will_4' };
%     {'20160623_171034_E_nlab'},    {'will_2' };
%     {'20160624_123908_E_nlab'},    {'will_4' };
%     {'20160625_121854_E_nlab'},    {'will_3' };
%     {'20160625_170401_E_nlab'},    {'will_4' };
%     {'20160627_150403_E_nlab'},    {'will_4' };
%     {'20160627_150404_E_nlab'},    {'will_4' };
%     {'20160627_150405_E_nlab'},    {'will_4' };
%     {'20160628_134142_E_nlab'},    {'will_1' };
%     {'20160628_154305_E_nlab'},    {'will_1' };
%     {'20160629_141947_E_nlab'},    {'will_2' };
%     {'20160629_212804_E_nlab'},    {'will_1' };
%     {'20160630_121743_E_nlab'},    {'will_2' };
%     {'20160701_140759_E_nlab'},    {'will_1' }];
D = [{'20150716_133328_E_nlab'},    {'luke_2' };
    {'20150717_141703_E_nlab'},    {'luke_2' }];
rec_list = D(:,1);
animals = D(:,2);

ALL_SURGES = [];
for i=1:length(rec_list)
    data = load(fullfile(DIR_SAVE,char(rec_list(i)),'Time_Surges.mat'),'S_surges','n_phasic');
    fprintf('Loading file %s.\n',fullfile(DIR_SAVE,FILES(i).nlab,'Time_Surges.mat'));
    
    if data.n_phasic ==0
        continue;
    end
    
    % inserting animal name
    ind_animal = contains(rec_list,{data.S_surges.recording});
    for j =1:length(data.S_surges)
        data.S_surges(j).animal = animals(ind_animal);
    end
    ALL_SURGES = [ALL_SURGES,data.S_surges];
end

% Converting to table 
% T = struct2table(ALL_SURGES);
T = ALL_SURGES;

% Grouping
S  = struct('animal',[],'n_surges',[],'n_episodes',[],'surge',[],...
    'duration_m',[],'duration_std',[],'duration_list',[],...
    'mean_intensity_m',[],'mean_intensity_std',[],'mean_intensity_list',[],...
    'max_intensity_m',[],'max_intensity_std',[],'max_intensity_list',[],...
    'mean_ratio_m',[],'mean_ratio_std',[],'mean_ratio_list',[],...
    'max_ratio_m',[],'max_ratio_std',[],'max_ratio_list',[]);

%all_animals = unique([T.animal]');
all_animals = [T.animal]';
for i =1:length(all_animals)
    pattern = all_animals(i);
    ind_keep = find(contains([T(:).animal]',pattern)==1);
    data = T(ind_keep);
    
    S(i).animal = char(pattern);
    S(i).n_surges = length(data);
    S(i).n_episodes = length(unique(join([{data(:).recording}',{data(:).episode}'])));
    S(i).surge = [{data(:).recording}',{data(:).name}'];
    %duration
    S(i).duration_list = [data(:).duration]';
    S(i).duration_m = mean(S(i).duration_list,'omitnan');
    S(i).duration_std = std(S(i).duration_list,[],'omitnan');
    %mean_intensity
    S(i).mean_intensity_list = [data(:).mean_intensity]';
    S(i).mean_intensity_m = mean(S(i).mean_intensity_list,'omitnan');
    S(i).mean_intensity_std = std(S(i).mean_intensity_list,[],'omitnan');
    %max_intensity
    S(i).max_intensity_list = [data(:).max_intensity]';
    S(i).max_intensity_m = mean(S(i).max_intensity_list,'omitnan');
    S(i).max_intensity_std = std(S(i).max_intensity_list,[],'omitnan');
    %mean_ratio
    S(i).max_ratio_list = [data(:).max_ratio]';
    S(i).max_ratio_m = mean(S(i).max_ratio_list,'omitnan');
    S(i).max_ratio_std = std(S(i).max_ratio_list,[],'omitnan');
    %max_ratio
    S(i).mean_ratio_list = [data(:).mean_ratio]';
    S(i).mean_ratio_m = mean(S(i).mean_ratio_list,'omitnan');
    S(i).mean_ratio_std = std(S(i).mean_ratio_list,[],'omitnan');
end

S = S([2,3,5,6,8]);
S = struct2table(S);

end