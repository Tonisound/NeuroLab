function templateSeqUF=defineSeqUF()

    % paramètres pour acquisition ultrason
    templateSeqUF.Depth = [0 0];                                           % imaging depth
    templateSeqUF.FlatAngles = zeros(1,100);                               % values of angles, in rad
    templateSeqUF.N_FlatAngles = 0;
    templateSeqUF.NAccum = 0;                                              % number of averaging for each TX
    templateSeqUF.TwFreq = 0;                                              % emission frequency [MHz]  %5.208 for L7-4 or SL10-2, 15.625 for LA-16 or SUCRE;
    templateSeqUF.NbHalfCycle = 0;                                         % Nb of Half cycle in emission
    templateSeqUF.DutyCycle = 0;                                           % duty cycle emission
    templateSeqUF.Trans_id = 0;                                            % 'L7-4'(1); 'LA-16'(2) ;'SUCRE'(3),'SL10-2','custom','DOMINO'
    templateSeqUF.ImagingVoltage = 0;                                      % imaging voltage [V]
    templateSeqUF.Beamforming_file_id = 0;                                 % external Processing for beamforming
    templateSeqUF.FrameRate = 0;                                           % Nb of frame per seconde [Hz]
    templateSeqUF.TimeOfBlocs = 0;                                         % time between 2 blocs,in second (1 bloc each n s), set to 0 for having continuous data acquisition
    templateSeqUF.NbOfFrames = 0;                                          % Number of frames after compound per bloc
    templateSeqUF.samplesPerWave = 0;                                      % Sampling 
    templateSeqUF.nbBuffers = 0;                                           % Nb of buffer for ping-pong
    templateSeqUF.Hadamard = 0;                                            % is hadamard plane wave emission
    templateSeqUF.Hadamard_dead_time = 0;                                  % time between two hadamard transmit (number of half cycle)
    templateSeqUF.NbOfBlocs = 0;                                           % # of blocs of acquisition,must be multiple of nb of buffer  /!\  memory 
    
    % paramètre pour beamforming 
    templateSeqUF.Beam_fNumber = 0;                                        % fd in the beamforming
    templateSeqUF.Beam_linenumber = 0;                                     % number of beamformed pixel per line
    templateSeqUF.Beam_Gamma = 0 ;                                         % angle for parallepipède image
    templateSeqUF.Beam_interpRF = 0;                                       % is interpolation of the RF on in the beamforming
    templateSeqUF.TGC = [0,0,0,0,0,0,0,0];                                 % adjust TGC Time gain control 8 values, integer, [0 1023]  
    
end