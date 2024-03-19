function quick_export_ext(X,Y,file_ext)
% Export trace in .ext format

% Modify if needed
if nargin <3
    file_ext = 'myfile.ext';
end
T.format = 'float32';
T.nb_samples = length(X);
T.unit = 'mV';

temp = regexp(file_ext,filesep,'split');
shortname = strrep(char(temp(end)),'.ext','');
parent_folder = strrep(file_ext,strcat(filesep,char(temp(end))),'');
T.shortname = shortname;
T.fullname = shortname;
T.parent = parent_folder;

% export
fid_ext = fopen(file_ext,'w');
fprintf(fid_ext,'%s',sprintf('<HEADER>\tformat=%s\tnb_samples=%d\tunit=%s',T.format,T.nb_samples,T.unit));
fprintf(fid_ext,'%s',sprintf('shortname=%s\tfullname=%s\tparent=%s\t</HEADER>\n',T.shortname,T.fullname,T.parent));
for k = 1:T.nb_samples
    fwrite(fid_ext,X(k),T.format);
    fwrite(fid_ext,Y(k),T.format);
end
fprintf('External File exported at %s.\n',file_ext);

end