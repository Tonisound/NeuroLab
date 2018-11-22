function S = read_imofile()
% Read Doppler_movie from IMO file for Spikoscope readout

% if exist(fullfile(foldername,'Time_Reference.mat'),'file')
%     data_c = load(fullfile(foldername,'Time_Reference.mat'),'time_ref');
% end

dir_save = '/Users/tonio/Documents/NEUROLAB/Nlab_Files/NRegions/template_E/template_US';
file_imo = 'DopplerSVD_001.imo';
imofid = fopen(fullfile(dir_save,file_imo),'r');

%Header
nz = fread(imofid,1,'int32');       % height (pixel)
nx = fread(imofid,1,'int32');       % width (pixel)
pixel = fread(imofid,1,'uint16');   % pixel representation 0=SGL, 1=DBL
format = fread(imofid,1,'int32');   % structure of GLOBAL and IMAGE


%Metadata
myIMO_type = fread(imofid,1,'int32');                   % 0=fUS, 1=bmode
myIMO_triggerNumPulse = fread(imofid,1,'int32');        % number of synchro pulses before first image
myIMO_pulseDuration = fread(imofid,1,'double');         % duration of each pulse (s)
myIMO_triggerBegin = fread(imofid,1,'double');          % trigger begin (s)
myIMO_triggerEnd = fread(imofid,1,'double');            % trigger end (s)
myIMO_nt = fread(imofid,1,'int32');                     % #image in file (if known)


% Reading images
myIMO_pulseID = [];
myIMO_infoTime = [];
Doppler_film = [];
while ~feof(imofid)
    myIMO_pulseID = [myIMO_pulseID,fread(imofid,1,'int32')];     % pulse ID
    myIMO_infoTime = [myIMO_infoTime,fread(imofid,1,'double')];   % pulse time (s)
    Doppler_film = cat(3,Doppler_film,fread(imofid,[nz nx],'single'));      % #image  
end


%Storing
S.nx = nx;
S.nz = nz;
S.pixel = pixel;
S.format = format;
S.myIMO_type = myIMO_type;
S.myIMO_triggerNumPulse = myIMO_triggerNumPulse;
S.myIMO_pulseDuration = myIMO_pulseDuration;
S.myIMO_triggerBegin = myIMO_triggerBegin;
S.myIMO_triggerEnd = myIMO_triggerEnd;
S.myIMO_nt = myIMO_nt;
S.myIMO_pulseID = myIMO_pulseID;
S.myIMO_infoTime = myIMO_infoTime;
S.Doppler_film = Doppler_film;


fclose(imofid);
fprintf('IMO file read converted to struct : %s.\n',file_imo);

end