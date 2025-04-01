function success = compute_body_speed(folder_ext,~)

load('Preferences.mat','GFilt');

success = false;
% folder_ext = fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).dir_ext);

% Reading ext
d_x = dir(fullfile(folder_ext,'Xposition.ext'));
if ~isempty(d_x)
    file_ext = fullfile(d_x.folder,d_x.name);
    [X,Xpos,format,nb_samples,parent,shortname,fullname] = read_ext_file(file_ext);
else
    warning('File not found [%s].',fullfile(folder_ext,'Xposition.ext'));
    return;
end

d_y = dir(fullfile(folder_ext,'Yposition.ext'));
if ~isempty(d_y)
    file_ext = fullfile(d_y.folder,d_y.name);
    [X,Ypos,format,nb_samples,parent,shortname,fullname] = read_ext_file(file_ext);
else
    warning('File not found [%s].',fullfile(folder_ext,'Yposition.ext'));
    return;
end

% Interpolation
V = sqrt(diff(Xpos).^2+diff(Ypos).^2);
V_norm = V./diff(X);
X2 = X(1:end-1)+diff(X)/2;
V_interp = interp1(X2,V_norm,X);

% Gaussian smoothing
f = 1/median(diff(X));
t_smooth = GFilt.acc_smooth;
n = max(round(t_smooth*f),1);
V_smooth = conv(V_interp,gausswin(n)/n,'same');

% Saving
file_ext = fullfile(folder_ext,'BodySpeed.ext');
fullname = 'BodySpeed';
write_ext_file(X,V_smooth,file_ext,parent,shortname,fullname);
fprintf('File BodySpeed.ext saved at [%s].\n',folder_ext);

success = true;

end