all_files = dir('*.ext');

for i=1:length(all_files)
    filename = char(all_files(i).name);
    %file_ext = fullfile(folder_ext,filename);
    file_ext = filename;
    
    fid_ext = fopen(file_ext,'r');
    %fprintf(fid_ext,'%s',sprintf('<HEADER>\tformat=%s\tnb_samples=%d\tunit=%s</HEADER>\n',T.format,T.nb_samples,T.unit));
    header = fgetl(fid_ext);
    header = regexp(header,'\t+','split');
    
    % Format readout
    ind_keep = contains(header,'format');
    header_keep = char(header(ind_keep));
    format = strrep(header_keep,'format=','');
    ind_keep = contains(header,'nb_samples');
    header_keep = char(header(ind_keep));
    nb_samples = eval(strrep(header_keep,'nb_samples=',''));
    
    X = NaN(nb_samples,1);
    Y = NaN(nb_samples,1);
    for k = 1:nb_samples
        X(k) = fread(fid_ext,1,format);
        Y(k) = fread(fid_ext,1,format);
    end
    fclose(fid_ext);
    fprintf('Binary File saved at %s.\n',file_ext);
    
end

