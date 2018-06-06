function templateRF=defineRF(sizeRF)                                       % informations correspondant à un bloc I
    templateRF.RF=zeros(sizeRF,'single');                                % images
    templateRF.ID=0;                                                       % numéro de l'image IQ (du bloc)
    templateRF.time=0;                                                     % date d'acquisition de l'imageIQ(du bloc)
    templateRF.key=0;                                                      % utilisé lors du scan pour vérifier qu'on est bien sur la bonne séquence
    templateRF.pos=[0 0 0 0 0];                                            % position de la sonde lors de l'acquisition du bloc !!!a aucun moment on ne sauvegarde la position de la sonde dans la structureIQ
    templateRF.wasRead=0;                                                  % permet de savoir si la structure a été lu (pour le passage vers doppler)
end
