function S_ledger = parse_ledger(ledger_txt,all_regions,files_regions)
% Parse function to generate S_ledger
% Input argument: path to ledger.txt file
% Output argument: structure S_ledger

main_sep = '\t';                                                % ledger file separator
empty_c2 = '-';                                                 % empty atlas symbol 
empty_c3 = '-';                                                 % empty plate symbol 
region_sep = ' ';                                               % empty plate symbol 
case_sensitive = false;                                         % Case sensitivity 

if ~exist(ledger_txt,'file')
    errordlg(sprintf('Missing Ledger File [%s]',ledger_txt));
    return;
else
    % Getting Region Name
    counter = 0;
    S_ledger = struct('name','','atlas','','plates',[],'regions',{},'filenames',{},'flag_filenames',{},'flag_found',false);
    fileID = fopen(ledger_txt,'r');
    % header
    fgetl(fileID);
    while ~feof(fileID)
        counter = counter +1;
        hline = fgetl(fileID);
        cline = regexp(hline,main_sep,'split'); 
        % name
        c1 = char(strtrim(cline(1)));
        S_ledger(counter).name = c1;
        % atlas
        c2 = char(strtrim(cline(2)));
        if strcmp(c2,empty_c2)
            c2 = strrep(c2,empty_c2,'');
        end
        S_ledger(counter).atlas = c2;
        % plates
        c3 = char(strtrim(cline(3)));
        if ~strcmp(c3,empty_c3)
            temp3 = regexp(c3,empty_c3,'split');
            plate1 = str2double(char(temp3(1)));
            plate2 = str2double(char(temp3(2)));
            S_ledger(counter).plates = [plate1,plate2];
        else
            S_ledger(counter).plates = [];
        end
        % regions
        c4 = char(strtrim(cline(4)));
        temp4 = regexp(c4,region_sep,'split');
        S_ledger(counter).regions = temp4';
        % filenames
        filenames = cell(length(temp4),1);
        flag_filenames = zeros(length(temp4),1);
        for i=1:length(temp4)
            if case_sensitive
                index_region = find(strcmp(all_regions,char(temp4(i)))==1);
            else
                index_region = find(strcmpi(all_regions,char(temp4(i)))==1);
            end
            
            flag_found = false;
            if ~isempty(index_region)
                filenames(i) = {files_regions(index_region).name};
                flag_filenames(i) = 1;
                flag_found = true;
            else
                filenames(i) = {''};
            end
        end
        S_ledger(counter).filenames = filenames;
        S_ledger(counter).flag_filenames = flag_filenames;
        S_ledger(counter).flag_found = flag_found;
    end
    fclose(fileID);
end
end