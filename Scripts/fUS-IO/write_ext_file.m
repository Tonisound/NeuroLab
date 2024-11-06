function write_ext_file(X,Y,file_ext,parent,shortname,fullname)
% Export trace in .ext format

% Default Parameters
format = 'float32';
nb_samples = length(X);
unit = 'mV';
if nargin <6
    fullname='';
end
if nargin <5
    shortname='';
end
if nargin <4
    parent='';
end

% export
fid_ext = fopen(file_ext,'w');
fprintf(fid_ext,'%s',sprintf('<HEADER>\tformat=%s\tnb_samples=%d\tunit=%s',format,nb_samples,unit));
fprintf(fid_ext,'%s',sprintf('shortname=%s\tfullname=%s\tparent=%s\t</HEADER>\n',shortname,fullname,parent));
for k = 1:nb_samples
    fwrite(fid_ext,X(k),format);
    fwrite(fid_ext,Y(k),format);
end
% fprintf('External File exported at %s.\n',file_ext);

end