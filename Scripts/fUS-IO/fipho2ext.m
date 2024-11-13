function fipho2ext()
% Converts Processed FiPho to .ext files

path = '/media/hobbes/HD USB ND/Antonio/Processed-FiPho/Preprocessed';

d = dir(fullfile(path,'*.csv'));
for i = 1:length(d)
    cur_file = d(i).name;
    
    new_folder = strrep(fullfile(path,cur_file),'.csv','');
    if ~isfolder(new_folder)
        mkdir(new_folder);
    end
    
    fid = fopen(fullfile(path,cur_file),'r');
    header = regexp(fgetl(fid),',','split');
    
    Y=[];
    
    while ~feof(fid)
        hline = regexp(fgetl(fid),',','split');
        v=[];
        for j=1:length(header)
            v=[v,str2double(hline(j))];
        end
        Y = [Y;v];
    end
    
    fclose(fid);
    
    t = Y(:,1);
    for k =1:length(header)-1
        y = Y(:,k+1);
        str = char(header(k+1));
        index_quotes = strfind(str,'"');
        fullname = str(index_quotes(1)+1:index_quotes(2)-1);
        switch fullname
            case 'AIn_1_Dem_AOut_1'
                shortname = 'Raw-405';
            case 'AIn_1_Dem_AOut_2'
                shortname = 'Raw-465';
            case 'smoothed_fluo_405'
                shortname = 'Smoothed-405';
            case 'smoothed_fluo_465'
                shortname = 'Smoothed-465';
            case 'fluo_465_corrected'
                shortname = 'Corrected-465';
            otherwise
                shortname = fullname;
        end
        parent = fullfile(path,cur_file);
        file_ext = fullfile(new_folder,[shortname,'.ext']);
        write_ext_file(t,y,file_ext,parent,shortname,fullname);
        fprintf('Ext file saved [%s].\n',file_ext);
    end
end
end