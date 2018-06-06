function templateIQ=defineIQ(sizeIQ)                                       % informations correspondant � un bloc IQ
    templateIQ.real=zeros(sizeIQ,'single');                                % images x*y*nbIQ
    templateIQ.imag=zeros(sizeIQ,'single');                                % images
    templateIQ.ID=0;                                                       % num�ro de l'image IQ (du bloc)
    templateIQ.time=0;                                                     % date d'acquisition de l'imageIQ(du bloc)
    templateIQ.key=0;                                                      % utilis� lors du scan pour v�rifier qu'on est bien sur la bonne s�quence
    templateIQ.pos=[0 0 0 0 0];                                            % position de la sonde lors de l'acquisition du bloc !!!a aucun moment on ne sauvegarde la position de la sonde dans la structureIQ
    templateIQ.wasRead=0;                                                  % permet de savoir si la structure a �t� lu (pour le passage vers doppler)
end
