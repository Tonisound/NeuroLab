function templateRF=defineRF(sizeRF)                                       % informations correspondant � un bloc I
    templateRF.RF=zeros(sizeRF,'single');                                % images
    templateRF.ID=0;                                                       % num�ro de l'image IQ (du bloc)
    templateRF.time=0;                                                     % date d'acquisition de l'imageIQ(du bloc)
    templateRF.key=0;                                                      % utilis� lors du scan pour v�rifier qu'on est bien sur la bonne s�quence
    templateRF.pos=[0 0 0 0 0];                                            % position de la sonde lors de l'acquisition du bloc !!!a aucun moment on ne sauvegarde la position de la sonde dans la structureIQ
    templateRF.wasRead=0;                                                  % permet de savoir si la structure a �t� lu (pour le passage vers doppler)
end
