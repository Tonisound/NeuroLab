function F = menuImportfile_Callback(~,~,handles,flag)
% File Importation
% Searches for EEG, fUS and video files

global SEED SEED_SWL DIR_SAVE;
global CUR_IM START_IM END_IM LAST_IM;

% Initialization
F = struct('session',{},'recording',{},'parent',{},'fullpath',{},...
    'info',{},'video',{},'dir_lfp',{},'dir_fus',{},'acq',{},'dop',{},'biq',{},...
    'ns1',{},'ns2',{},'ns3',{},'ns4',{},'ns5',{},'ns6',{},...
    'nev',{},'ccf',{},'rcf',{},'ncf',{},'nlab',{},'type',{});


if flag == 1
    % Manual Import
    FileName = uigetdir(SEED,'Select file');
    if FileName==0
        return;
    else
        FileList = {FileName};
    end
    
else
    % Recording list Import
    rec_list = dir(fullfile(SEED_SWL,'*.txt'));
    s = listdlg('PromptString','Select a recording list:',...
        'SelectionMode','single','ListString',{rec_list(:).name}','ListSize',[300 500]);
    if isempty(s)
        return;
    else
        % Loading Separators
        load('Preferences.mat','GParams');
        sep_swl_1 = GParams.sep_swl_1;
        sep_swl_2 = GParams.sep_swl_2;
        % Extracting FileName
        fid = fopen(fullfile(SEED_SWL,char(rec_list(s).name)),'r');
        raw_list = fread(fid,'*char')';
        index1 = strfind(raw_list,sep_swl_1);
        index2 = strfind(raw_list,sep_swl_2);
        n_files = length(index1);
        FileList = [];
        for i = 1:n_files
            line_ex = raw_list(index1(i)+length(sep_swl_1):index2(i)-1);
            FileList = [FileList;{line_ex}];
        end    
    end
end

% Convert FileList in format parent/session/recording
FileList_converted = [];
for i = 1:length(FileList)
    FileName = char(FileList(i));
    FileName_split = regexp(FileName,'/|\','split');
    if contains(FileName_split(end),'_pre') || contains(FileName_split(end),'_per')...
            || contains(FileName_split(end),'_post') || contains(FileName_split(end),'_nlab') || contains(FileName_split(end),'_E')
        % Direct importation
        FileList_converted = [FileList_converted;{FileName}];
    elseif contains(FileName_split(end),'_MySession')
        % Searches recording
        d = [dir(fullfile(FileName,'*_pre'));dir(fullfile(FileName,'*_per'));dir(fullfile(FileName,'*_post'));dir(fullfile(FileName,'*_E'))];
        if isempty(d)
            warning('File skipped [No recording in session] %s.\n',FileName);
        else
            all_files = cell(length(d),1);
            for j=1:length(d)
                all_files(j) = {fullfile(FileName,filesep,char(d(j).name))};
            end
            %all_files = strcat(FileName,filesep,{d(:).name}');
            FileList_converted = [FileList_converted;all_files];
        end
    else
        warning('File skipped [Incorrect path] %s.\n',FileName);
    end
end
FileList = FileList_converted;
%fprintf('%d recording detected. Proceed.\n',length(FileList));

for i = 1:length(FileList)
    % Extracting FileName
    ind_file = i;
    FileName = char(FileList(ind_file));
    % Extracting session name
    FileName_split = regexp(FileName,'/|\','split');
    index_session = contains(FileName_split,'_MySession');
    
    if contains(FileName_split(end),'_nlab')
        l = load(fullfile(FileName,'Config.mat'),'File');
        F(ind_file) = l.File;
        continue;
    elseif index_session(end-1)==1 && contains(FileName_split(end),["pre","per","post","E"])
        session = char(FileName_split(end-1));
        % Extracting parent
        temp = regexp(FileName,session,'split');
        parent = strrep(char(temp(1)),SEED,'');
        parent = parent(1:end-1);
        % Extracting recording
        recording = char(FileName_split(end));
    else
        % Return if incorrect path
        errordlg('Please select a file path with _MySession');
        return;
    end
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
    d = [dir(fullfile(FileName,'*.mpg'));dir(fullfile(FileName,'*.avi'))];
    if ~isempty(d)
        str = char(d(1).name);
        F(ind_file).video = str;
    end
    
    % Looking for fUS
    d = dir(fullfile(FileName,'*_fus'));
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
    
    % Looking for LFP
    d = dir(fullfile(FileName,'*_lfp'));
    
    if ~isempty(d)
        dir_lfp = char(d(1).name);
        F(ind_file).dir_lfp = dir_lfp;
        
        dd = dir(fullfile(FileName,dir_lfp,'*.ns1'));
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns1 = str;
        end
        dd = dir(fullfile(FileName,dir_lfp,'*.ns2'));
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns2 = str;
        end
        dd = dir(fullfile(FileName,dir_lfp,'*.ns3'));
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns3 = str;
        end
        dd = dir(fullfile(FileName,dir_lfp,'*.ns4'));
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns4 = str;
        end
        dd = dir(fullfile(FileName,dir_lfp,'*.ns5'));
        if ~isempty(dd)
            str = char(dd(1).name);
            F(ind_file).ns5 = str;
        end
        dd = dir(fullfile(FileName,dir_lfp,'*.ns6'));
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
    
    % Looking for NLab File
    d = dir(fullfile(DIR_SAVE,strcat('*',recording,'*')));
    if ~isempty(d)
        str = char(d(1).name);
        F(ind_file).nlab = str;
    else
        %F(ind_file).nlab = regexprep(session,'_MySession','_nlab');
        F(ind_file).nlab = strcat(recording,'_nlab');
        % ask confirmation before importation   
        str_quest = strcat(fieldnames(F(ind_file)),sprintf(' : '),struct2cell(F(ind_file)));
        button = questdlg(str_quest,'New Importation','OK','Cancel','OK');
        
        % Creating nlab file if confirmation and
        if isempty(button) || strcmp(button,'Cancel')
            return;
        else
            %try
                mkdir(fullfile(DIR_SAVE,F(ind_file).nlab));
                fprintf('Nlab directory created : %s.\n',F(ind_file).nlab);
                
                % Import fUS Movie and Save Config.mat
                [Doppler_film,tag] = import_DopplerFilm(F(ind_file),handles,0);
                
                % Detect trigger
                import_reference_time(F(ind_file),Doppler_film,handles);
                
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
%             catch
%                 rmdir(fullfile(DIR_SAVE,F(ind_file).nlab),'s');
%                 fprintf('Nlab directory deleted : %s.\n',F(ind_file).nlab);
%                 F(ind_file).nlab = '';
%             end
        end
    end
end

end