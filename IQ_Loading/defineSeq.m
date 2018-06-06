function templateSEQ=defineSeq()                                           %Définit tout les paramêtre nécessaire au bon d"roulement d'une séquence d'acquisition ou de stream d'image IQ et  Doppler

% paramêtres de la sequence à initialiser
    templateSEQ.isReady=0;                                                 % Permet de savoir si on a lancé tout les MatLab(ultrasound_engine, live_doppler... ) et si les paramètres ont été calculés (US seq, taille IQ....) (si tout est pret pour que l'on puisse lancé une séquence).
    templateSEQ.isMemoReady=0;                                             % Memory map file pour l'acquisition sont créés et alloués
    
    templateSEQ.Acquisition_type=0;                                        % type of acquisition 1: 2D single Frame, 2: 2D fUS, 3:3D scanning.
    templateSEQ.isRunning=0;                                               % Permet de savoir si tout les fichiers de sauvegarde ont été créés et permet de savoir si la séquence est en cours d'utilisation(en train de Streamer ou de Scanner).
    templateSEQ.isStreaming=0;                                             % Permet de savoir si on veut lancer le mode Stream et de savoir si on est en train de streamer (IQ et Doppler).
    templateSEQ.isScanning=0;                                              % Permet de savoir si on veut lancer le mode Scan et de savoir si on est en train de scanner (IQ et Doppler). pas utilisé pour le moment
    templateSEQ.convertIQ=0;                                               % Permet de savoir si on veut et si on est en train de convertir les images IQ en images Doppler.
    templateSEQ.sizeIQ=[0 0 0];                                            % Permet de connaitre la taille d'un block d'image IQ (largeurIQ*hauteurIQ*nbIQperBlock).
    templateSEQ.nbBloc=0;                                                  % Permet de connaitre le nombre de bloc d'image IQ total pour la séquence.
    templateSEQ.nbBlocPerPosition=0;                                       % Permet de connaitre le nombre de bloc d'image IQ à prendre pour chaque position de sonde.
    templateSEQ.isFrozen=0;                                                % freeze acquisition when on
    templateSEQ.LastAcquIQPos=0;                                           % Permet de savoir où est le dernier IQ acquis enregistrer dans la mmf des IQ
    templateSEQ.LastAcquDopPos=0;                                          % Permet de savoir où est le dernier Dop traité enregistrer dans la mmf  scanDop
    templateSEQ.triggerOut=0;                                              % send a 1µs trig at the beginning of each IQ acquisition start  (5V-> 0V edge)
    templateSEQ.triggerIn = 0;                                             % wait for a trig in (rising trig 1)at the beginning of the acquisition
    templateSEQ.waitingForTriggin=0;
    templateSEQ.isUS_Seq_compiled=0;
    templateSEQ.nbDopProcessed=0;                                          % Permet de connaître le nombre d'image Doppler scanné (une par bloc IQ).
    templateSEQ.IQacquisitionStarted=0;                                    % Permet de savoir si on commence l'acquisition d'un nouveau block IQ.                                                                       
    templateSEQ.IQacquisitionCompleted=0;                                  % Permet de savoir si on a finit d'acquérir un bloc IQ.                                                                          % à renommer en IQacquisitionCompleted
    templateSEQ.saveIQ=0;                                                  % Permet de savoir si on veut archiver les images IQ du scan (de base les images Doppler sont archivées quoiqu'il en soit)
    templateSEQ.key=0;                                                     % clé "unique" pour différencier une séquence d'une autre(le problème vient lorsque l'on supprime l'espace sur le disque via la ligne de commande 'del'..., on dit juste au système que l'on peut réutiliser cet espace mémoire , on ne néttoie pas les variables.)
    
    templateSEQ.SimulationAcquisition = 0;                                 % Simulation de l'acquisition avec une matrice IQ déja acquise
    % ultraousound acquisition parameter
    templateSEQ.N_FlatAngles = 0;                                          % nombre d'angles -> nécessaire pour allouer la mémoire de SeqUF
    templateSEQ.isStreamingRF = 0;                                         % save le dernier buffer RF -> !!!! RF sont en single
    templateSEQ.sizeRF = [0 0 0];                                          % taille des RF
    % control parameter
    templateSEQ.EffectiveTimePerBlocOK = 0;                                 % check if the acquisition/beamforming time is ok
    templateSEQ.ProcessingTimeBeamforming = zeros(1,10);
    templateSEQ.NtreadCascade = 0;                                         % number of treads launch using cascade
    templateSEQ.VeraConnector=0;
    templateSEQ.Accumulation_block_Doppler=0;                              % number of UF block Doppler image to average to compute an image
    
    %     templateSEQ.depth=0; % ?
    %     templateSEQ.nbAngle=0; % ?
    %     à vérifier car pas utilisé opur le moment. 
    %    templateSEQ.Angle=[0 0 0 0 0]; % Permet de connaitre la position
    %    actuelle de la sonde x*y*z + rotation  + précision en x. pas utilisé
    %    pour l'instant
    %    templateSEQ.NbFrames=0; % ? pas utilisé
    %    templateSEQ.isRamOk = 1; % Permet de savoir si on a suffisament de memoire RAM pour continuer les opérations, si cette valeur tombe à 0 on doit tuer tout les process
end

