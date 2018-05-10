function [Doppler_film, infoTime_film] = convert_imo2mat(dir_name,imo_file)
% Generation d'un fichier Doppler.mat a partir d'un autre fichier .imo
% Possibilite de controler la resolution et le type de filtrage

imofid = fopen(sprintf('%s/%s',dir_name,imo_file),'rb');

nz = fread(imofid,1,'int32');       % height (pixel)
nx = fread(imofid,1,'int32');       % width (pixel)
pixel = fread(imofid,1,'uint16');   % pixel representation 0=SGL, 1=DBL
format = fread(imofid,1,'int32');   % structure of GLOBAL and IMAGE

% GLOBAL
if (format == 0)
    
    myIMO_type = fread(imofid,1,'int32');               % 0=fUS, 1=bmode
    myIMO_triggerNumPulse = fread(imofid,1,'int32');    % number of synchro pulses before first image
    myIMO_pulseDuration = fread(imofid,1,'double');     % duration of each pulse (s)
    myIMO_triggerBegin = fread(imofid,1,'double');      % trigger begin (s)
    myIMO_triggerEnd = fread(imofid,1,'double');        % trigger end (s)
    myIMO_nt = fread(imofid,1,'int32');                 % #image in file (if known)
    
    pulseID = fread(imofid,1,'int32');     % pulse ID
    infoTime_film = fread(imofid,1,'double');  % pulse time (s)
    Doppler_film = fread(imofid,[nz nx],'single');   % #image   
    
    while ~feof(imofid)
        pulseID = fread(imofid,1,'int32');     % pulse ID
        infoTime = fread(imofid,1,'double');  % pulse time (s)
        Doppler = fread(imofid,[nz nx],'single');   % #image
        
        if ~isempty(pulseID)
%        % Adding Zero Image if time between two pulses is greater than 10s
%             if abs(infoTime-infoTime_film(end))>.0001
%                 Doppler_film = cat(3,Doppler_film,zeros(size(Doppler)));
%                 infoTime_film = cat(2,infoTime_film,0);
%             end
            Doppler_film = cat(3,Doppler_film,Doppler);
            infoTime_film = cat(2,infoTime_film,infoTime);
        end
    end
else
    errordlg(sprintf('Problem readind IMO file (format =1) : %s \n.',fullfile(dir_name,imo_file)));
end

fclose(imofid);

end