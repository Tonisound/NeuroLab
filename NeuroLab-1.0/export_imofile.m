function success = export_imofile(foldername,dir_save,file_session)
% Export Doppler_movie to IMO file for Spikoscope readout

success = false;

if ~exist(dir_save,'dir')
    mkdir(dir_save);
end

if exist(fullfile(foldername,'Time_Reference.mat'),'file')
    data_t = load(fullfile(foldername,'Time_Reference.mat'),'time_ref','time_str');
end

if exist(fullfile(foldername,'Config.mat'),'file')
    data_c = load(fullfile(foldername,'Config.mat'),'X','Y','Current_Image');
end

% Loading Doppler_film
fprintf('Loading Doppler_film ...\n');
data_d = load(fullfile(foldername,'Doppler.mat'),'Doppler_film');
fprintf('===> Doppler_film loaded from %s.\n',fullfile(foldername,'Doppler.mat'));

name_imo = strrep(file_session,'_MySession','_E');
name_US = strrep(file_session,'_MySession','_US');

% Copying template file
if ~exist(fullfile(dir_save,name_imo),'dir')
    copyfile(fullfile(dir_save,'template_E','*'),fullfile(dir_save,name_imo));
    movefile(fullfile(dir_save,name_imo,'template_US'),fullfile(dir_save,name_imo,name_US));
    fprintf('Template spiko file cloned at %s.\n',fullfile(dir_save,name_imo));
else 
    warning('File already exists [%s]. Delete if needed.',fullfile(dir_save,name_imo));
    return;
end

%S = read_imofile();
%nz = S.nz;
%nx = S.nx;
nz = data_c.X;
nx = data_c.Y;

% Modifying us_param.txt
file_txt = fullfile(dir_save,name_imo,name_US,'us_param.txt');
fid_txt = fopen(file_txt,'r');
file_txt2 = fullfile(dir_save,name_imo,name_US,'us_param2.txt');
fid_txt2 = fopen(file_txt2,'w');
while ~feof(fid_txt)
    hline = fgetl(fid_txt);
    if strcmp(hline(1),'X')
        hline = sprintf('X=%d',nx);
    elseif strcmp(hline(1),'Z')
        hline = sprintf('Z=%d',nz);
    end
    fwrite(fid_txt2,hline,'char');
    fwrite(fid_txt2,newline,'char');
end
fclose(fid_txt);
fclose(fid_txt2);
movefile(file_txt2,file_txt);
fprintf('US_params.txt file updated at %s.\n',file_txt2);


% Opening  IMO file
file_imo = fullfile(dir_save,name_imo,name_US,'DopplerSVD_001.imo');
fid_imo = fopen(file_imo,'w');

% Header Parameters
pixel = 0;
format = 0;
ind_start = 1;
ind_stop = 11;
%n_images = ind_stop-ind_start+1;
infoTime = datenum(data_t.time_str(ind_start:ind_stop));

%Header
fwrite(fid_imo,nz,'int32');         % height (pixel)
fwrite(fid_imo,nx,'int32');         % width (pixel)
fwrite(fid_imo,pixel,'uint16');         % pixel representation 0=SGL, 1=DBL
fwrite(fid_imo,format,'int32');          % structure of GLOBAL and IMAGE

%Metadata
myIMO_type = 0;                     % 0=fUS, 1=bmode
myIMO_triggerNumPulse = 0;          % number of synchro pulses before first image
myIMO_pulseDuration = 0.0020;           % duration of each pulse (s)
myIMO_triggerBegin = 0;             % trigger begin (s)
myIMO_triggerEnd = 0;              % trigger end (s)
myIMO_nt = 200;                      % #image in file (if known)

fwrite(fid_imo,myIMO_type,'int32');
fwrite(fid_imo,myIMO_triggerNumPulse,'int32');
fwrite(fid_imo,myIMO_pulseDuration,'double');
fwrite(fid_imo,myIMO_triggerBegin,'double');
fwrite(fid_imo,myIMO_triggerEnd,'double');
fwrite(fid_imo,myIMO_nt,'int32');

for i= ind_start:ind_stop
    myIMO_pulseID = i;                         % pulse ID
    %myIMO_infoTime = data_t.time_ref.Y(i);    % pulse time (s)
    myIMO_infoTime = infoTime(i);              % pulse time (s)
    %Doppler = IM(:,:,i);                      % #image
    Doppler = data_d.Doppler_film(:,:,i);
    
    fwrite(fid_imo,myIMO_pulseID,'int32');     % pulse ID
    fwrite(fid_imo,myIMO_infoTime,'double');   % pulse time (s)
    fwrite(fid_imo,Doppler,'single');          % image
    %fwrite(fid_imo,S.Doppler_film(:,:,i),'single');          % image
        
end

fclose(fid_imo);
fprintf('Doppler film converted to IMO file : %s.\n',file_imo);
success = true;

end