function traces = read_binary_file(dir_spiko,S,time_ref,n_burst,lengthburst)

% Using Middle Trigger as Time Reference
global FILES CUR_FILE;

% Replacing / by : in filename
container = regexprep(S.container,'/',':');
filename = fullfile(dir_spiko,container,S.filename);
nb_samples = eval(S.nb_samples);
format = S.Format;

X = S.packet_duration.*reshape(1:nb_samples,nb_samples,1);
fid = fopen(filename,'r');
try
    Y = fread(fid,format,'b');
catch
    warning('Format unknown. Trying int16.\n');
    Y = fread(fid,'int16','l');
end
%Y = fread(fid,nb_samples,format)
%Y =zeros(nb_samples,1);
% for i = 1:nb_samples
%     Y(i) = fread(fid,1,format)
% end
fclose(fid);

while X(end) < time_ref.Y(end)
    X = [X;X+X(end)];
    Y = [Y;NaN(size(Y))];
end

% Regular Code
ind = round(time_ref.Y/S.packet_duration);
X_ind = reshape(1:length(ind),size(ind));
X_ind = [reshape(X_ind,[lengthburst,n_burst]);NaN(1,n_burst)];
X_ind = X_ind(:);
X_im = X(ind);
X_im = [reshape(X_im,[lengthburst,n_burst]);NaN(1,n_burst)];
X_im = X_im(:);
Y_im = Y(ind);
Y_im = [reshape(Y_im,[lengthburst,n_burst]);NaN(1,n_burst)];
Y_im = Y_im(:);

% For truncated files
% ind = round(time_ref.Y/S.packet_duration);
% %ind = ind(1:10000);
% X_ind = reshape(1:length(ind),size(ind));
% X_ind = [reshape(X_ind,[lengthburst,n_burst]);NaN(1,n_burst)];
% %X_ind = [X_ind;NaN];
% X_ind = X_ind(:);
% %X_im = X(ind);
% X_im = NaN(size(ind));
% temp = X(ind<length(X));
% X_im(1:length(temp)) = temp ;
% X_im = [reshape(X_im,[lengthburst,n_burst]);NaN(1,n_burst)];
% %X_im = [X_im;NaN];
% X_im = X_im(:);
% %Y_im = Y(ind);
% Y_im = NaN(size(ind));
% temp = Y(ind<length(Y));
% Y_im(1:length(temp)) = temp ;
% Y_im = [reshape(Y_im,[lengthburst,n_burst]);NaN(1,n_burst)];
% %Y_im = [Y_im;NaN];
% Y_im = Y_im(:);

% Modifying shortname and fullname
t1 = S.container;
t2 = S.Label;
t1 = regexprep(t1,strcat('_',FILES(CUR_FILE).eeg),'');
t2 = regexprep(t2,'_extra','');

traces.shortname = t2;
traces.fullname = strcat(t1(1:min(30,end)),'/',t2);
traces.parent = S.container;
traces.unit = S.Unit;
traces.nb_samples = nb_samples;
traces.X = X;
traces.Y = Y;
traces.X_ind = X_ind;
traces.X_im = X_im;
traces.Y_im = Y_im;

end