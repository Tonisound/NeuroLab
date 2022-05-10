function [success,Doppler_film,F] = import_reference_time(F,handles,flag)
% Import reference time - Detects NEV channel and extracts trigger from it
% Adds one trigger if discrepancy between fus data and trigger number
% flag 0 - first import
% flag 1 - reimport

if nargin == 2
    flag = 1;
end

success = false;

%global LAST_IM IM CUR_IM  FILES CUR_FILE;
global SEED CUR_IM DIR_SAVE FILES CUR_FILE;
    
load('Preferences.mat','GImport');
dir_save = fullfile(DIR_SAVE,F.nlab);
file_acq = fullfile(SEED,F.parent,F.session,F.recording,F.dir_fus,F.acq);
Doppler_film = [];

% % Loading n_frames
% if exist(fullfile(dir_save,'Config.mat'),'file')
%     data_c = load(fullfile(dir_save,'Config.mat'),'n_frames');
%     n_frames = data_c.n_frames;
% else
%     errordlg(sprintf('Missing file [%s]',fullfile(dir_save,'Config.mat')));
%     return;
% end

% test if trigger.txt does not exist and creates it
if ~exist(fullfile(F.fullpath,F.dir_fus,'trigger.txt'),'file')
    
    % Loading n_frames
    if exist(fullfile(dir_save,'Config.mat'),'file')
        fprintf('Loading n_frames [%s] ...',fullfile(dir_save,'Config.mat'));
        data_c = load(fullfile(dir_save,'Config.mat'),'n_frames');
        fprintf(' done.\n');
        n_frames = data_c.n_frames;
    elseif contains(F.acq,'.acq')
        % case file_acq ends .acq (Verasonics)
        fprintf('Loading Doppler_film and n_frames [%s] ...',F.acq);
        data_acq = load(file_acq,'-mat');
        fprintf(' done.\n');
        Doppler_film = permute(data_acq.Acquisition.Data,[3,1,4,2]);
        n_frames = size(Doppler_film,3);
    elseif contains(F.acq,'.mat')
        % case file_acq ends .mat (Aixplorer)
        fprintf('Loading Doppler_film and n_frames [%s] ...',F.acq);
        data_acq = load(file_acq,'Doppler_film');
        fprintf(' done.\n');
        Doppler_film = data_acq.Doppler_film;
        n_frames = size(Doppler_film,3);
    else
        errordlg(sprintf('Unable to import reference time - Missing acq file [%s]',file_acq));
        return;
    end
    
    % Trigger Importation
    switch GImport.Trigger_loading
        
        % ns5 priority
        case 'ns5'
            if exist(fullfile(F.fullpath,F.dir_lfp,F.ns5),'file') && ~isempty(F.ns5)
                % Trigger extraction from NS5 file
                [trigger,reference,padding] = extract_trigger_ns5(F,n_frames);
                
            elseif exist(fullfile(F.fullpath,F.dir_lfp,F.nev),'file') && ~isempty(F.nev)
                % Trigger extraction from NEV file
                [trigger,reference,padding] = extract_trigger_nev(F,n_frames);
                
            else
                % Missing NEV : template trigger
                warning('Missing NEV file.\n');
                [trigger,reference,padding] = extract_trigger_void(F,n_frames);
                %return;
            end
            
        % nev priority
        case 'nev'
            if exist(fullfile(F.fullpath,F.dir_lfp,F.nev),'file') && ~isempty(F.nev)
                % Trigger extraction from NEV file
                [trigger,reference,padding] = extract_trigger_nev(F,n_frames);
                
            elseif exist(fullfile(F.fullpath,F.dir_lfp,F.ns5),'file') && ~isempty(F.ns5)
                % Trigger extraction from NS5 file
                [trigger,reference,padding] = extract_trigger_ns5(F,n_frames);
                
            else
                % Missing NEV : template trigger
                warning('Missing NEV file.\n');
                [trigger,reference,padding] = extract_trigger_void(F,n_frames);
                %return;
            end
            
        % default priority
        otherwise
            errordlg('Unrecognized Trigger Importation format')
            return;
    end
    
    % Trigger Offset (Default: 0)
    offset = 0;
    
    % LFP-VIDEO Delay (Default: 0)
    delay_lfp_video = 0;
    
    % Trigger Exportation
    file_txt = fullfile(F.fullpath,F.dir_fus,'trigger.txt');
    fid_txt = fopen(file_txt,'wt');
    fprintf(fid_txt,'%s',sprintf('<REF>%s</REF>\n',reference));
    fprintf(fid_txt,'%s',sprintf('<PAD>%s</PAD>\n',padding));
    fprintf(fid_txt,'%s',sprintf('<OFFSET>%.3f</OFFSET>\n',offset));
    fprintf(fid_txt,'%s',sprintf('<DELAY>%.3f</DELAY>\n',delay_lfp_video));
    fprintf(fid_txt,'%s',sprintf('<TRIG>\n'));
    %fprintf(fid_txt,'%s',sprintf('n=%d \n',length(trigger)));
    for k = 1:length(trigger)
        fprintf(fid_txt,'%s',sprintf('%.3f\n',trigger(k)));
    end
    fprintf(fid_txt,'%s',sprintf('</TRIG>'));
    fclose(fid_txt);
    fprintf('File trigger.txt saved at %s.\n',file_txt);

else
    % Trigger Readout
    reference = 'default';
    padding = 'none';
    offset = 0; % default
    delay_lfp_video = 0; % default
    trigger = [];
    
    file_txt = fullfile(F.fullpath,F.dir_fus,'trigger.txt');
    fid_txt = fopen(file_txt,'r');
    A = fread(fid_txt,'*char')';
    fclose(fid_txt);

    % REF
    delim1 = '<REF>';
    delim2 = '</REF>';
    if strfind(A,delim1)
        %B = regexp(A,'<REF>|<\REF>','split');
        B = A(strfind(A,delim1)+length(delim1):strfind(A,delim2)-1);
        C = regexp(B,'\t|\n|\r','split');
        D = C(~cellfun('isempty',C));
        reference = char(D);
    end
    % PAD
    delim1 = '<PAD>';
    delim2 = '</PAD>';
    if strfind(A,delim1)
        B = A(strfind(A,delim1)+length(delim1):strfind(A,delim2)-1);
        C = regexp(B,'\t|\n|\r','split');
        D = C(~cellfun('isempty',C));
        padding = char(D);
    end
    % OFFSET
    delim1 = '<OFFSET>';
    delim2 = '</OFFSET>';
    if strfind(A,delim1)
        B = regexp(A,'<OFFSET>|</OFFSET>','split');
        C = char(B(2));
        D = textscan(C,'%f');
        offset = D{1,1};
    end
    % DELAY
    delim1 = '<DELAY>';
    delim2 = '</DELAY>';
    if strfind(A,delim1)
        B = regexp(A,'<DELAY>|</DELAY>','split');
        C = char(B(2));
        D = textscan(C,'%f');
        delay_lfp_video = D{1,1};
    end
    % TRIG
    B = regexp(A,'<TRIG>|</TRIG>','split');
    C = char(B(2));
    D = textscan(C,'%f');
    trigger = D{1,1};
end


% Trigger Importation  
n_images = length(trigger);
time_ref.X = (1:n_images)';
time_ref.Y = trigger+offset;
time_ref.nb_images = length(trigger);


% Detecting burst and jumps
ind_bursts = find([0;diff(trigger(:))]>GImport.burst_thresh);
ind_jumps = find([0;0;abs(diff(diff(trigger(:))))]>GImport.jump_thresh);

if length(unique(diff(ind_bursts)))==1
    rec_mode = 'BURST';
    n_burst = 1+length(ind_bursts);
    length_burst = unique(diff(ind_bursts));
%     n_burst = 1;
%     length_burst = length(trigger); 
elseif ~isempty(ind_bursts)
    rec_mode = 'BURST-IRREGULAR';
    n_burst = 1;
    length_burst = length(trigger); 
elseif ~isempty(ind_jumps) && (length(ind_jumps)/length(trigger))>GImport.jump_proportion
    rec_mode = 'CONTINUOUS-IRREGULAR';
    n_burst = 1;
    length_burst = length(trigger); 
else
    rec_mode = 'CONTINUOUS';
    n_burst = 1;
    length_burst = length(trigger); 
end

% Interpolate if trigger is not regular
if strcmp(rec_mode,'BURST-IRREGULAR') || strcmp(rec_mode,'CONTINUOUS-IRREGULAR') %|| flag==1
    fprintf('Irregular Timing Detected [%s]: Launching Interpolation.\nFile [%s]\n',rec_mode,file_txt)
    S.Doppler_film = Doppler_film;
    S.trigger = trigger;
    S.reference = reference;
    S.padding = padding;
    S.rec_mode = rec_mode;
    S.offset = offset;
    S.delay_lfp_video = delay_lfp_video;
    S.file_txt = file_txt;
    
    % Interpolate Doppler
    [F,S] = interpolate_Doppler(F,handles,S);
    
    % unpacking
    Doppler_film = S.Doppler_film;
    trigger = S.trigger;
    reference = S.reference;
    padding = S.padding;
    rec_mode = S.rec_mode;
    offset = S.offset;
    delay_lfp_video = S.delay_lfp_video;       
    
    % Trigger Importation
    n_images = length(trigger);
    time_ref.X = (1:n_images)';
    time_ref.Y = trigger+offset;
    time_ref.nb_images = length(trigger);
    % Burst/Jump Information
    ind_bursts = find([0;diff(trigger(:))]>GImport.burst_thresh);
    ind_jumps = find([0;0;abs(diff(diff(trigger(:))))]>GImport.jump_thresh);
    if strcmp(rec_mode,'BURST')
        n_burst = 1+length(ind_bursts);
        length_burst = unique(diff(ind_bursts));
    else
        n_burst = 1;
        length_burst = length(trigger);
    end
    
    % Save Config.mat if exist
    FILES(CUR_FILE) = F;
    if exist(fullfile(dir_save,'Config.mat'),'file')
        File = F;
        save(fullfile(dir_save,'Config.mat'),'File','-append');
    end
end

% Save ReferenceTime.mat
time_str = cellstr(datestr((time_ref.Y)/(24*3600),'HH:MM:SS.FFF'));
handles.TimeDisplay.UserData = char(time_str);
try
    handles.TimeDisplay.String = char(time_str(CUR_IM));
catch
    handles.TimeDisplay.String = char(time_str(1));
end
%datestr(time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF');
save(fullfile(dir_save,'Time_Reference.mat'),'time_str','time_ref',...
    'reference','padding','offset','delay_lfp_video',...
    'rec_mode','ind_jumps','ind_bursts','length_burst','n_burst','-v7.3');
fprintf('Succesful Reference Time Importation [%s,%d,%d]\n',rec_mode,n_burst,length_burst);
fprintf('===> Saved at %s.mat\n',fullfile(dir_save,'Time_Reference.mat'));

success = true;

end

function [trigger,reference,padding] = extract_trigger_ns5(F,n_frames)

fprintf('Loading NS5 file...');
data_ns5 = openNSx(fullfile(F.fullpath,F.dir_lfp,F.ns5));
fprintf(' done.\n');

f_trig = 30000;
if size(data_ns5.Data,1)==1
    t = data_ns5.Data';
    reference = sprintf('Channel %d [ns5]',data_ns5.ElectrodesInfo.ElectrodeID);
else
    warning('NS5 Data file contains several channels.');
    return;
end

f = figure;
ax = axes('Parent',f);
plot(t,'Parent',ax);
answer = char(inputdlg('Enter threshold value.'));
close(f);
t_thresh = t>eval(answer);
index = find(diff(t_thresh)>0);
trigger_raw = index/f_trig;

n_images = n_frames;
% Test if trigger matches n_images
if n_images~= length(trigger_raw)
    if length(trigger_raw) < n_images
        
        warning('Trigger (%d) and IM size (%d) do not match [Missing end trig]. -> Adding end trig',length(trigger_raw),n_images);
        discrepant = n_images-length(trigger_raw);
%         padding = sprintf('missing[%d][%s]',discrepant,'extend');
%         % extend trigger using delta_trig
%         delta_trig = trigger_raw(2)-trigger_raw(1);
%         additional_trigs = (1:discrepant)'*delta_trig;
%         trigger = [trigger_raw; trigger_raw(end)+additional_trigs];
        
        % asking user which trigs to keep
        answer = questdlg(sprintf('Discrepant Trigger [%d] and Doppler Size [%d].\n Where do you want to add trigs ?',length(trigger_raw),n_images), ...
            'Trigger Importation',...
            'Add trigs at start','Add trigs to end','Cancel');
        % Handle response
        switch answer
            case 'Add trigs at start'
                % insert trigger using delta_trig
                padding = sprintf('missing[%d][%s]',discrepant,'insert');
                delta_trig = trigger_raw(2)-trigger_raw(1);
                additional_trigs = (1:discrepant)'*delta_trig;
                trigger = [trigger_raw(1)-flipud(additional_trigs);trigger_raw];     
            case 'Add trigs to end'
                % extend trigger using delta_trig
                padding = sprintf('missing[%d][%s]',discrepant,'extend');
                delta_trig = trigger_raw(2)-trigger_raw(1);
                additional_trigs = (1:discrepant)'*delta_trig;
                trigger = [trigger_raw; trigger_raw(end)+additional_trigs];
            otherwise
                % insert trigger using delta_trig
                padding = sprintf('missing[%d][%s]',discrepant,'insert');
                delta_trig = trigger_raw(2)-trigger_raw(1);
                additional_trigs = (1:discrepant)'*delta_trig;
                trigger = [trigger_raw(1)-flipud(additional_trigs);trigger_raw];     
        end
        
        
    elseif length(trigger_raw) > n_images
        
        warning('Trigger (%d) and IM size (%d) do not match [Excess trigs]. -> Discarding end trigs',length(trigger_raw),n_images);
        discrepant = n_images-length(trigger_raw);
%         % padding = sprintf('excess[%d][%s]',-discrepant,'first'); 
%         padding = sprintf('excess[%d][%s]',-discrepant,'last'); 
%         % keep only first triggers
%         trigger = trigger_raw(end-n_images+1:end);
%         % trigger = trigger_raw(1:n_images);
        
        % asking user which trigs to keep
        answer = questdlg(sprintf('Discrepant Trigger [%d] and Doppler Size [%d].\n What triggers to you want to keep ?',length(trigger_raw),n_images), ...
            'Trigger Importation',...
            'Keep first trigs','Keep last trigs','Cancel');
        % Handle response
        switch answer
            case 'Keep first trigs'
                padding = sprintf('excess[%d][%s]',-discrepant,'first');
                trigger = trigger_raw(1:n_images);      
            case 'Keep last trigs'
                padding = sprintf('excess[%d][%s]',-discrepant,'last');
                trigger = trigger_raw(end-n_images+1:end);
            otherwise
                %default
                padding = sprintf('excess[%d][%s]',-discrepant,'first');
                trigger = trigger_raw(1:n_images);  
        end
            
    end
else
    discrepant = 0;
    padding = 'exact';
    trigger = trigger_raw;
    %time_stamp = time_stamp_raw;
end

end

function [trigger,reference,padding] = extract_trigger_nev(F,n_frames)

fprintf('Importing Neural-Event data...');
data_nev = openNEV(fullfile(F.fullpath,F.dir_lfp,F.nev),'nosave','nomat');
fprintf(' done.\n');

% Asks User to pick trigger chanel if two or more channels detected
trig_list  = unique(data_nev.Data.Spikes.Electrode);
switch length(trig_list) 
    case 0
        % Missing NEV : template trigger
        warning('No trigger channel found: using template trigger.\n');
        [trigger,reference,padding] = extract_trigger_void(F,n_frames);
        return;
        
    case 1
        ind_trig = 1;
        reference = sprintf('Channel %d [nev]',trig_list(ind_trig));
        fprintf('Trigger channel detected : %d.\n',reference);

    otherwise 
       
        if sum(trig_list==97)>0
            % channel 97 by default
            ind_trig = find(trig_list==97);
            v = true;
        else
            % manual selection
            trig_list_name =[];
            for i=1:length(trig_list)
                trig_list_name =[trig_list_name;sprintf('Channel %3d',trig_list(i))];
            end
            [ind_trig,v] = listdlg('Name','Tag Selection','PromptString','Select Trigger',...
                'SelectionMode','single','ListString',trig_list_name,'InitialValue',1,'ListSize',[300 500]);
        end
        
        if v==0
            return;
        elseif isempty(ind_trig)
            return;
        else
            %trigger = trig_list(ind_trig);
            reference = sprintf('Channel %d [nev]',trig_list(ind_trig));
            fprintf('Trigger channel selected : %d.\n',reference)
        end
end

% Extracting_timing
f_trig = 30000;
time_stamp_raw = data_nev.Data.Spikes.TimeStamp(data_nev.Data.Spikes.Electrode==trig_list(ind_trig))';
trigger_raw = double(time_stamp_raw)/f_trig;
n_images = n_frames;

% Test if trigger matches n_images
if n_images~= length(trigger_raw)
    if length(trigger_raw) < n_images
        
        warning('Trigger (%d) and IM size (%d) do not match [Missing end trig]. -> Adding end trig',length(trigger_raw),n_images);
        discrepant = n_images-length(trigger_raw);
%         padding = sprintf('missing[%d][%s]',discrepant,'extend');
%         % extend trigger using delta_trig
%         delta_trig = trigger_raw(2)-trigger_raw(1);
%         additional_trigs = (1:discrepant)'*delta_trig;
%         trigger = [trigger_raw; trigger_raw(end)+additional_trigs];
%         %time_stamp = [time_stamp_raw; time_stamp_raw(end)+time_stamp_raw(2)-time_stamp_raw(1)];
        
                % asking user which trigs to keep
        answer = questdlg(sprintf('Discrepant Trigger [%d] and Doppler Size [%d].\n Where do you want to add trigs ?',length(trigger_raw),n_images), ...
            'Trigger Importation',...
            'Add trigs at start','Add trigs to end','Cancel');
        % Handle response
        switch answer
            case 'Add trigs at start'
                % insert trigger using delta_trig
                padding = sprintf('missing[%d][%s]',discrepant,'insert');
                delta_trig = trigger_raw(2)-trigger_raw(1);
                additional_trigs = (1:discrepant)'*delta_trig;
                trigger = [trigger_raw(1)-flipud(additional_trigs);trigger_raw];     
            case 'Add trigs to end'
                % extend trigger using delta_trig
                padding = sprintf('missing[%d][%s]',discrepant,'extend');
                delta_trig = trigger_raw(2)-trigger_raw(1);
                additional_trigs = (1:discrepant)'*delta_trig;
                trigger = [trigger_raw; trigger_raw(end)+additional_trigs];
            otherwise
                % insert trigger using delta_trig
                padding = sprintf('missing[%d][%s]',discrepant,'insert');
                delta_trig = trigger_raw(2)-trigger_raw(1);
                additional_trigs = (1:discrepant)'*delta_trig;
                trigger = [trigger_raw(1)-flipud(additional_trigs);trigger_raw];  
        end
        
    elseif length(trigger_raw) > n_images
        
        warning('Trigger (%d) and IM size (%d) do not match [Excess trigs]. -> Discarding end trigs',length(trigger_raw),n_images);
        discrepant = n_images-length(trigger_raw);
%         % padding = sprintf('excess[%d][%s]',-discrepant,'first'); 
%         padding = sprintf('excess[%d][%s]',-discrepant,'last'); 
%         % keep only first triggers
%         trigger = trigger_raw(end-n_images+1:end);
%         %trigger = trigger_raw(1:n_images);
%         %time_stamp = time_stamp_raw(1:n_images);
                
        % asking user which trigs to keep
        answer = questdlg(sprintf('Discrepant Trigger [%d] and Doppler Size [%d].\n What triggers to you want to keep ?',length(trigger_raw),n_images), ...
            'Trigger Importation','Keep first trigs','Keep last trigs','Cancel');
        % Handle response
        switch answer
            case 'Keep first trigs'
                padding = sprintf('excess[%d][%s]',-discrepant,'first');
                trigger = trigger_raw(1:n_images);      
            case 'Keep last trigs'
                padding = sprintf('excess[%d][%s]',-discrepant,'last');
                trigger = trigger_raw(end-n_images+1:end);
            otherwise
                %default
                padding = sprintf('excess[%d][%s]',-discrepant,'first');
                trigger = trigger_raw(1:n_images);
        end
            
    end
else
    discrepant = 0;
    padding = 'exact';
    trigger = trigger_raw;
    %time_stamp = time_stamp_raw;
end

end

function [trigger,reference,padding] = extract_trigger_void(F,n_frames)

load('Preferences.mat','GImport');
reference = 'default';
padding = 'none';
f_def = GImport.f_def;

% loading .acq
if exist(fullfile(F.fullpath,F.dir_fus,F.acq),'file')
    data_acq = load(fullfile(F.fullpath,F.dir_fus,F.acq),'Acquisition','-mat');
    try
        f_acq = 1/median(diff(data_acq.Acquisition.T));
        % Bug fix if Acquisition.T corrupt
        if f_acq>10 || length(data_acq.Acquisition.T)==1
            f_acq = f_def;
        end
    catch
        % if Acquisition.T not found
        f_acq = f_def;
    end
else
    warning('Impossible to load acq file [%s].',fullfile(F.fullpath,F.dir_fus,F.acq));
    f_acq = f_def;
end

trigger = (0:n_frames-1)'/f_acq;

end