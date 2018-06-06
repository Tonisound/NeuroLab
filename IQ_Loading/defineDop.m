function templateDop=defineDop(sizeIQ)
    templateDop.data=zeros([sizeIQ(1) sizeIQ(2)]);                         % image Doppler
    templateDop.ID=0;                                                      % numéro de l'image Doppler (du bloc IQ)
    templateDop.time=0;                                                    % date d'acquisition de l'imageIQ(du bloc)
    %templateDop.isReady=0; % pas utilisé
    templateDop.pos=[0 0 0 0 0];                                           % position de la caméra lors de la prise d'image IQ
    templateDop.wasRead=0;                                                 % permet de savoir si la structure a été lu (pour l'affichage en stream)
    templateDop.time_acq=0;                                                % fin du temps du buffer utilisé pour faire la carte Doppler
end