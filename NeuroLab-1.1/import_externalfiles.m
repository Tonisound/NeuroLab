function import_externalfiles(dir_recording,dir_save)

success = false;

% Loading Config.mat
if exist(fullfile(dir_save,'Config.mat'),'file')
    data_c = load(fullfile(dir_save,'Config.mat'),'File');
    F = data_c.File;
else
    errordlg('Missing file Config.mat [%s]',dir_save);
    return;
end
% Loading Time reference
if exist(fullfile(dir_save,'Time_Reference.mat'),'file')
    data_t = load(fullfile(dir_save,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
else
    errordlg(sprintf('Missing File %s',fullfile(dir_save,'Time_Reference.mat')));
    return;
end


%Filling F.dir_ext if empty
if isempty(F.dir_ext)
    d = dir(fullfile(dir_recording,'*_ext'));
    if ~isempty(d)
        F.dir_ext = char(d(1).name);
        File = F;
        save(fullfile(dir_save,'Config.mat'),'File','-append');
        fprintf('File Config.mat appended [%s]',dir_save);
    else
        errordlg('Missing file Config.mat [%s]',dir_save);
        return;
    end
end

% Searchind directory
d = dir(fullfile(dir_recording,F.dir_ext,'*.ext'));
% Removing hidden files
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
if isempty(d)
    errordlg('Empty Directory [%s]',fullfile(dir_recording,F.dir_ext));
    return;
else
    [ind_ext,ok] = listdlg('PromptString','Select Files',...
        'SelectionMode','multiple','ListString',{d.name},'ListSize',[300 500]);
    if ~ok || isempty(ind_ext)
        return;
    end
end


% Converting to traces
traces = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});
all_files = {d(ind_ext).name}';
for i=1:length(all_files)
    filename = char(all_files(i));
    file_ext = fullfile(dir_recording,F.dir_ext,filename);
    
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
    ind_keep = contains(header,'parent');
    header_keep = char(header(ind_keep));
    parent = strrep(header_keep,'parent=','');
    ind_keep = contains(header,'shortname');
    header_keep = char(header(ind_keep));
    shortname = strrep(header_keep,'shortname=','');
    ind_keep = contains(header,'fullname');
    header_keep = char(header(ind_keep));
    fullname = strrep(header_keep,'fullname=','');
    
    X = NaN(nb_samples,1);
    Y = NaN(nb_samples,1);
    for k = 1:nb_samples
        X(k) = fread(fid_ext,1,format);
        Y(k) = fread(fid_ext,1,format);
    end
    fclose(fid_ext);
    fprintf('Binary File loaded at %s.\n',file_ext);

    % Storing data in traces
    %duration = X(end);
    %f_samp = 1:(X(2)-X(1));
    traces(i).ID = sprintf('%03d',i);
    traces(i).shortname = shortname;
    traces(i).parent = parent;
    traces(i).fullname = fullname;
    traces(i).X = X;
    traces(i).Y = Y;
    traces(i).X_ind = data_t.time_ref.X;
    traces(i).X_im = data_t.time_ref.Y;
    traces(i).Y_im = interp1(traces(i).X,traces(i).Y,traces(i).X_im);
    traces(i).nb_samples = nb_samples;
    fprintf('Succesful Importation %s [Parent %s].\n',traces(i).fullname,traces(i).parent);
end


% Save dans SpikoscopeTraces.mat
if ~isempty(traces)
    save(fullfile(dir_save,'Cereplex_Traces.mat'),'traces','MetaData','-v7.3');
end
fprintf('===> Saved at %s.mat\n',fullfile(dir_save,'Cereplex_Traces.mat'));

success = true;

end