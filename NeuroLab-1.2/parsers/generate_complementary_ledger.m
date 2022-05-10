function generate_complementary_ledger(list_regions)
% generate_complementary_ledger() generates a new region ledger txt for 'ambiguous' regions
% searches actual ledger to attribute a group to ambiguous regions


if nargin==0
    list_regions1 = generate_lists('DisplayObj','regions','DisplayMode','unilateral');
    list_regions2 = generate_lists('DisplayObj','regions','DisplayMode','bilateral');
    list_regions3 = generate_lists('DisplayObj','regions','DisplayMode','unilateral','AtlasType','ratsagittal');
    list_regions4 = generate_lists('DisplayObj','regions','DisplayMode','bilateral','AtlasType','ratsagittal');
    list_regions = [list_regions1;list_regions2;list_regions3;list_regions4];
end

% Keeping only ! elements
list_regions = list_regions(contains(list_regions,'!'));

% Main Parameters
% AtlasType = 'ratcoronal';
% list_plates = 'all';
% DisplayObj = 'regions';
% DisplayMode = 'unilateral';
dir_txt = strrep(which('generate_complementary_ledger.m'),strcat(filesep,'generate_complementary_ledger.m'),'');
ledger_txt_in =  fullfile(dir_txt,'LedgerDir','RegionLedger.txt');
ledger_txt_out =  fullfile(dir_txt,'LedgerDir','RegionLedger2.txt');

% Reading ledger file
all_c1 = [];
all_c4 = [];
if exist(ledger_txt_in,'file')
    fileID_in = fopen(ledger_txt_in);
    %header
    fgetl(fileID_in);
    while ~feof(fileID_in)
        hline = fgetl(fileID_in);
        cline = regexp(hline,'\t','split');
        c1 = strtrim(cline(1));
        all_c1 = [all_c1 ;c1];
        % c2 = strtrim(cline(2));
        % c3 = strtrim(cline(3));
        c4 = strtrim(cline(4));
        all_c4 = [all_c4 ;c4]; 
    end
    fclose(fileID_in);
end

% Browsing regions
all_groups = [];
all_scores = [];
all_regions = [];

for i=1:length(list_regions)
    this_regions = regexp(char(list_regions(i)),'!','split')';
    score_c1 = zeros(size(all_c1));
    for j=1:length(this_regions)
        ind_keep = find(contains(all_c4,this_regions(j)));
        if ~isempty(ind_keep)
            % found region
            for k=1:length(ind_keep)
                all_subregions = regexp(char(all_c4(ind_keep(k))),' ','split')';
                if sum(strcmp(all_subregions,this_regions(j)))>0
                    % found proper region
                    all_c1(ind_keep(k));
                    score_c1(ind_keep(k)) = score_c1(ind_keep(k))+1;
                end
            end
        end
    end
    % finding highest score
    [S, ind_max] = max(score_c1);
    if S>0
        max_group = all_c1(ind_max(1));
        all_groups = [all_groups;max_group];
        all_scores = [all_scores;S];
        all_regions = [all_regions;list_regions(i)];
    end
end

% Removing duplicates
% Sorting 
[all_groups,ind_sorted] = sort(all_groups);
all_scores = all_scores(ind_sorted);
all_regions = all_regions(ind_sorted);

% Writing new ledger file
fileID_out = fopen(ledger_txt_out,'w');		
fwrite(fileID_out,sprintf('%s \t %s \t %s \t %s','Group_name','Atlas_name','Plates','Region'));
fwrite(fileID_out,newline);
for i=1:length(all_regions)
    fwrite(fileID_out,sprintf('%s \t %s \t %s \t %s',char(all_groups(i)),'-','-',char(all_regions(i))));
    fwrite(fileID_out,newline);
end
fclose(fileID_out);
fprintf('Complementary Ledger succesfully written [%s].\n',ledger_txt_out);

end