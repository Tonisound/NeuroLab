function [T,X,Y] = quick_import_ext(file_ext)

fid_ext = fopen(file_ext,'r');
header = fgetl(fid_ext);
header = regexp(header,'\t+','split');

% Format readout
ind_keep = contains(header,'format');
header_keep = char(header(ind_keep));
format = strrep(header_keep,'format=','');

ind_keep = contains(header,'nb_samples');
header_keep = char(header(ind_keep));
nb_samples = eval(strrep(header_keep,'nb_samples=',''));

ind_keep = contains(header,'unit');
header_keep = char(header(ind_keep));
unit = strrep(header_keep,'unit=','');

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

% Buiding T
T.format = format;
T.nb_samples = nb_samples;
T.unit = unit;
T.shortname = shortname;
T.fullname = fullname;
T.parent = parent;

fprintf('External File loaded at %s.\n',file_ext);

end

