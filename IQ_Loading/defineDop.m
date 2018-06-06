function templateDop=defineDop(sizeIQ)
    templateDop.data=zeros([sizeIQ(1) sizeIQ(2)]);                         % image Doppler
    templateDop.ID=0;                                                      % num�ro de l'image Doppler (du bloc IQ)
    templateDop.time=0;                                                    % date d'acquisition de l'imageIQ(du bloc)
    %templateDop.isReady=0; % pas utilis�
    templateDop.pos=[0 0 0 0 0];                                           % position de la cam�ra lors de la prise d'image IQ
    templateDop.wasRead=0;                                                 % permet de savoir si la structure a �t� lu (pour l'affichage en stream)
    templateDop.time_acq=0;                                                % fin du temps du buffer utilis� pour faire la carte Doppler
end