function F = menuImportfile_Callback(~,~,handles,flag)
% File Importation
% Searches for EEG, fUS and video files

global SEED STR_SAVE SEED_SWL DIR_SAVE;

% Initialization
F = struct('session',{},'recording',{},'parent',{},'fullpath',{},'info',{},...
    'video',{},'dir_lfp',{},'dir_fus',{},'dir_ext',{},'dir_dat',{},'dat',{},'acq',{},'dop',{},'biq',{},...
    'ns1',{},'ns2',{},'ns3',{},'ns4',{},'ns5',{},'ns6',{},'nev',{},'ccf',{},'rcf',{},'ncf',{},...
    'mainlfp',{},'mainemg',{},'mainacc',{},'atlas_name',{},'atlas_plate',{},'atlas_coordinate',{},'nlab',{},'type',{});

if flag == 1
    % Manual Import
    %     FileName = uigetdir(SEED,'Select file');
    %     if FileName==0
    %         return;
    %     else
    %         FileList = {FileName};
    %     end
    FileList = uigetdir2(SEED,'Select file');
    if isempty(FileList)
        return;
    end
    
else
    % Recording list Import
    rec_list = dir(fullfile(SEED_SWL,'*.txt'));
    %     ind_rm = ~(cellfun('isempty',strfind({rec_list(:).name(1)}','.')));
    ind_rm = zeros(size(rec_list));
    for j=1:length(ind_rm)
        temp = char(rec_list(j).name);
        if strcmp(temp(1),'.')
            ind_rm(j)=1;
        else
            ind_rm(j)=0;
        end
    end
    rec_list(ind_rm==1) = [];
    
    s = listdlg('PromptString','Select a recording list:',...
        'SelectionMode','single','ListString',{rec_list(:).name}','ListSize',[300 500]);
    if isempty(s)
        return;
    else
        
        % Extracting FileName
        fid = fopen(fullfile(SEED_SWL,char(rec_list(s).name)),'r');
        FileList = [];
        while ~feof(fid)
            line_ex = fgetl(fid);
            if strcmp(line_ex(1:8),'NEUROLAB')
                line_ex = strrep(line_ex,'NEUROLAB',STR_SAVE);
            elseif strcmp(line_ex(1:4),'DATA')
                line_ex = strrep(line_ex,'DATA',SEED);
            end
            line_ex = strrep(line_ex,'/',filesep);
            line_ex = strrep(line_ex,'\',filesep);
            FileList = [FileList;{line_ex}];
        end
        fclose(fid);
    end
end


% If FileList contains full session name
% Convert FileList in format parent/session/recording
FileList_converted = [];
for i = 1:length(FileList)
    FileName = char(FileList(i));
    FileName_split = regexp(FileName,'/|\','split');
    if contains(FileName_split(end),'_pre') || contains(FileName_split(end),'_per')...
            || contains(FileName_split(end),'_post') || contains(FileName_split(end),'_nlab')...
            || contains(FileName_split(end),'_E') || contains(FileName_split(end),'_R')
        % Direct importation
        FileList_converted = [FileList_converted;{FileName}];
    elseif contains(FileName_split(end),'_MySession')
        % Searches recording
        d = [dir(fullfile(FileName,'*_pre'));dir(fullfile(FileName,'*_per'));dir(fullfile(FileName,'*_post'));dir(fullfile(FileName,'*_E'));dir(fullfile(FileName,'*_R'))];
        if isempty(d)
            warning('File skipped [No recording in session] %s.',FileName);
        else
            all_files = cell(length(d),1);
            for j=1:length(d)
                all_files(j) = {fullfile(FileName,filesep,char(d(j).name))};
            end
            %all_files = strcat(FileName,filesep,{d(:).name}');
            FileList_converted = [FileList_converted;all_files];
        end
    else
        warning('File skipped [Incorrect path] %s.',FileName);
    end
end
FileList = FileList_converted;


% Recording Importation
ind_failed = [];
for ind_file = 1:length(FileList)
    
    % Allocate empty fields in F
    F(ind_file).recording = '';
    
    FileName = char(FileList(ind_file));
    FileName_split = regexp(FileName,'/|\','split');
    index_session = contains(FileName_split,'_MySession');
    
    if contains(FileName_split(end),'_nlab')
        % Direct Importation from nlab file if specified in FileName
        if isfile(fullfile(FileName,'Config.mat'))
            l = load(fullfile(FileName,'Config.mat'),'File');
            F(ind_file) = l.File;
            fprintf('File Imported [%s]\n',FileName);
        else
            warning('Importation aborted - Incorrect file path [%s].',FileName);
            ind_failed = [ind_failed;ind_file];
        end
        continue;
        
    elseif index_session(end-1)==1 && contains(FileName_split(end),["pre","per","post","E","R"])
        % Extracting parent, session and recording
        session = char(FileName_split(end-1));
        temp = regexp(FileName,session,'split');
        parent = strrep(char(temp(1)),SEED,'');
        parent = strip(parent,filesep);
        recording = char(FileName_split(end));
        
    else
        % Continue if incorrect path and issue warning
        warning('Importation aborted - Incorrect file path [%s].',FileName);
        ind_failed = [ind_failed;ind_file];
        continue;
    end
    
    % Direct Importation from nlab file if exists
    if isdir(fullfile(DIR_SAVE,strcat(recording,'_nlab')))
        l = load(fullfile(DIR_SAVE,strcat(recording,'_nlab'),'Config.mat'),'File');
        F(ind_file) = l.File;
        fprintf('File Imported [%s]\n',fullfile(DIR_SAVE,strcat(recording,'_nlab')));
        continue;
    end
    
    % Assigning parent, session and recording
    fprintf('Importing File [%s]...',FileName);
    F(ind_file).session = session;
    F(ind_file).recording = recording;
    F(ind_file).parent = parent;
    F(ind_file).fullpath = fullfile(SEED,parent,session,recording);
    
    % Looking for info file
    d = dir(fullfile(SEED,parent,session,'*.txt'));
    if ~isempty(d)
        str = char(d(1).name);
        F(ind_file).info = str;
    end
    % Looking for video file
    d = [dir(fullfile(FileName,'*.mpg'));dir(fullfile(FileName,'*.mp4'));dir(fullfile(FileName,'*.avi'))];
    % Remove hidden files
    d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
    if ~isempty(d)
        str = char(d(1).name);
        F(ind_file).video = str;
    end
    
    % Looking for fUS
    d1 = dir(fullfile(FileName,'*_fusint'));
    d2 = dir(fullfile(FileName,'*_fus'));
    d = [d1;d2];
    if ~isempty(d)
        dir_fus = char(d(1).name);
        F(ind_file).dir_fus = dir_fus;
        
        dd = [dir(fullfile(FileName,dir_fus,'*.acq'));dir(fullfile(FileName,dir_fus,'Doppler.mat'))];
        if ~isempty(dd)
            acq = char(dd(1).name);
            F(ind_file).acq = acq;
            if contains(acq,'.acq')
                F(ind_file).dop = 'Verasonics';
            elseif contains(acq,'.mat')
                F(ind_file).dop = 'Aixplorer';
            else
                F(ind_file).dop = 'unknown';
            end
        end
        
        dd = dir(fullfile(FileName,dir_fus,'*.biq'));
        if ~isempty(dd)
            biq = char(dd(1).name);
            F(ind_file).biq = biq;
        end
    end
    
    % Looking for external folder
    d = dir(fullfile(FileName,'*_ext'));
    if ~isempty(d)
        dir_ext = char(d(1).name);
        F(ind_file).dir_ext = dir_ext;
    end
    
    % Looking for LFP
    d = dir(fullfile(FileName,'*_lfp'));
    if ~isempty(d)
        dir_lfp = char(d(1).name);
        F(ind_file).dir_lfp = dir_lfp;
        
        dd = [dir(fullfile(FileName,dir_lfp,'*.ns1'));dir(fullfile(FileName,dir_lfp,'*.sk1'))];
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns1 = str;
        end
        dd = [dir(fullfile(FileName,dir_lfp,'*.ns2'));dir(fullfile(FileName,dir_lfp,'*.sk2'));dir(fullfile(FileName,dir_lfp,'*.rhd2'))];
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns2 = str;
        end
        dd = [dir(fullfile(FileName,dir_lfp,'*.ns3'));dir(fullfile(FileName,dir_lfp,'*.sk3'))];
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns3 = str;
        end
        dd = [dir(fullfile(FileName,dir_lfp,'*.ns4'));dir(fullfile(FileName,dir_lfp,'*.sk4'))];
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns4 = str;
        end
        dd = [dir(fullfile(FileName,dir_lfp,'*.ns5'));dir(fullfile(FileName,dir_lfp,'*.sk5'))];
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns5 = str;
        end
        dd = [dir(fullfile(FileName,dir_lfp,'*.ns6'));dir(fullfile(FileName,dir_lfp,'*.sk6'))];
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns6 = str;
        end
        dd = dir(fullfile(FileName,dir_lfp,'*.nev'));
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).nev = str;
        end
        dd = dir(fullfile(FileName,dir_lfp,'*.ccf'));
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ccf = str;
        end
        dd = dir(fullfile(FileName,dir_lfp,'*.rcf'));
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).rcf = str;
        end
    end
    
    % File type
    if isempty(F(ind_file).acq)
        if isempty(F(ind_file).ns1)&&isempty(F(ind_file).ns2)...
                &&isempty(F(ind_file).ns3)&&isempty(F(ind_file).ns4)...
                &&isempty(F(ind_file).ns5)&&isempty(F(ind_file).ns6)...
                && ~isempty(F(ind_file).video)
            F(ind_file).type = 'VIDEO';
        elseif ~isempty(F(ind_file).video)
            F(ind_file).type = 'EEG-VIDEO';
            F(ind_file).dop = 'Dummy';
            
            % Creating Dummy dir_fus
            dir_fus = strrep(F(ind_file).dir_lfp,'_lfp','_fus');
            if ~exist(fullfile(FileName,dir_fus),'dir')
                mkdir(fullfile(FileName,dir_fus));
            end
            F(ind_file).dir_fus = dir_fus;
            
            % Creating Dummy Doppler
            load('Preferences.mat','GImport');
            def_frames = round(1800/GImport.f_def);
            Doppler_film = rand(10,10,def_frames);
            save(fullfile(FileName,dir_fus,'Doppler.mat'),'Doppler_film','-v7.3');
            F(ind_file).acq = 'Doppler.mat';
            
        end
    else
        if isempty(F(ind_file).ns1)&&isempty(F(ind_file).ns2)...
                &&isempty(F(ind_file).ns3)&&isempty(F(ind_file).ns4)...
                &&isempty(F(ind_file).ns5)&&isempty(F(ind_file).ns6)...
                && ~isempty(F(ind_file).video)
            F(ind_file).type = 'fUS-VIDEO';
        elseif ~isempty(F(ind_file).video)
            F(ind_file).type = 'EEG-fUS-VIDEO';
        else
            F(ind_file).type = 'fUS';
        end
    end
    fprintf(' done.\n');
    
    % Creating NLab File
    % ask confirmation before importation
    F(ind_file).nlab = strcat('~',recording,'_nlab');
    
    % Comment in batch mode
    str_quest = strcat(fieldnames(F(ind_file)),sprintf(' : '),struct2cell(F(ind_file)));
    button = questdlg(str_quest,'New Importation','OK','Cancel','OK');
    % %Comment in user mode
    % button = 'ok';
    
    % Creating nlab file if confirmation and
    if isempty(button) || strcmp(button,'Cancel')
        ind_failed = [ind_failed;ind_file];
        continue;
    else
        mkdir(fullfile(DIR_SAVE,F(ind_file).nlab));
        fprintf('Nlab directory created : %s.\n',F(ind_file).nlab);
        
        % Detect trigger
        [~,Doppler_film,F_out] = import_reference_time(F(ind_file),handles,0);
        F(ind_file) = F_out;
        
        % Import fUS Movie and Save Config.mat
        tag = import_DopplerFilm(F(ind_file),handles,0,Doppler_film);
        
        % Import/Crop Video
        import_crop_video(F(ind_file),handles,0);
        
        % Save UF Params
        saving_UFParams(fullfile(F(ind_file).fullpath,F(ind_file).dir_fus),fullfile(DIR_SAVE,F(ind_file).nlab));
        
        % save TimeTags.mat (whole episode)
        data_t = load(fullfile(DIR_SAVE,F(ind_file).nlab,'Time_Reference.mat'),'time_ref');
        TimeTags_images = [data_t.time_ref.X(1),data_t.time_ref.X(end)];
        TimeTags_strings = [{handles.TimeDisplay.UserData(1,:)},{handles.TimeDisplay.UserData(end,:)}];
        TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
        TimeTags(1,1).Episode = '';
        TimeTags(1,1).Tag = 'Whole-fUS';
        TimeTags(1,1).Onset = handles.TimeDisplay.UserData(1,:);
        TimeTags(1,1).Duration = handles.TimeDisplay.UserData(end,:);
        TimeTags(1,1).Reference = handles.TimeDisplay.UserData(1,:);
        TimeTags(1,1).Tokens = '';
        TimeTags_cell(1,:) = {'Episode','Tag','Onset','Duration','Reference','Tokens'};
        TimeTags_cell(2,:) = {'',TimeTags(1).Tag,TimeTags(1).Onset,TimeTags(1).Duration,TimeTags(1).Reference,''};
        
        if ~isempty(tag)
            TimeTags_images(2,:) = [data_t.time_ref.X(tag.im1),data_t.time_ref.X(tag.im2)];
            dur = data_t.time_ref.Y(tag.im2) - data_t.time_ref.Y(tag.im1);
            str_dur = datestr(dur/(24*3600),'HH:MM:SS.FFF');
            TimeTags_strings(2,:) = [{handles.TimeDisplay.UserData(tag.im1,:)},{handles.TimeDisplay.UserData(tag.im2,:)}];
            TimeTags(2,1).Episode = '';
            TimeTags(2,1).Tag = 'BASELINE';
            TimeTags(2,1).Onset = handles.TimeDisplay.UserData(tag.im1,:);
            TimeTags(2,1).Duration = str_dur;
            TimeTags(2,1).Reference = handles.TimeDisplay.UserData(tag.im1,:);
            TimeTags(2,1).Tokens = '';
            TimeTags_cell(3,:) = {'',TimeTags(2).Tag,TimeTags(2).Onset,TimeTags(2).Duration,TimeTags(2).Reference,''};
        end
        save(fullfile(DIR_SAVE,F(ind_file).nlab,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images'); 
        
        % Renaming folder and nlab file
        movefile(fullfile(DIR_SAVE,F(ind_file).nlab),fullfile(DIR_SAVE,strrep(F(ind_file).nlab,'~','')));
        % Updating nlab field
        F(ind_file).nlab = strrep(F(ind_file).nlab,'~','');
        fprintf('Nlab directory renamed : %s.\n',F(ind_file).nlab);
        % Updating Config.mat
        dd = load(fullfile(DIR_SAVE,F(ind_file).nlab,'Config.mat'),'File');
        File = dd.File;
        File.nlab = F(ind_file).nlab;
        save(fullfile(DIR_SAVE,F(ind_file).nlab,'Config.mat'),'File','-append');
        
    end
end

% Removing failed recordings
F(ind_failed) = [];

end