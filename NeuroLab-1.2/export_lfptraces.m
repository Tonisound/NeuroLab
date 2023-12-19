function success = export_lfptraces(handles,F,val)

success = false;

global DIR_SAVE;
load('Preferences.mat','GImport','GFilt');
dir_save = fullfile(DIR_SAVE,F.nlab);

flag_write_dat = false; % Copy dat file in DATA/_lfp folder
flag_write_txt = false; % Copy txt file in DATA/_lfp folder
flag_write_direct = true; % Copy dat file in specified folder

% Manual mode val = 1; batch mode val =0
if nargin<3
    val=1;
end

fprintf('Loading LFP data ...');
path_to_lfp = '';
switch GImport.LFP_exporting
    case 'ns1'
        if contains(F.ns1,'ns1')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns1));
        elseif contains(F.ns1,'sk1')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns1),'-mat');
        else
            errordlg('No file with NS1 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
        path_to_lfp = fullfile(F.fullpath,F.dir_lfp,F.ns1);
    case 'ns2'
        if contains(F.ns2,'ns2')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns2));
        elseif contains(F.ns2,'sk2')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns2),'-mat');
        else
            errordlg('No file with NS2 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
        path_to_lfp = fullfile(F.fullpath,F.dir_lfp,F.ns2);
    case 'ns3'
        if contains(F.ns3,'ns3')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns3));
        elseif contains(F.ns3,'sk3')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns3),'-mat');
        else
            errordlg('No file with NS3 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
        path_to_lfp = fullfile(F.fullpath,F.dir_lfp,F.ns3);
    case 'ns4'
        if contains(F.ns4,'ns4')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns4));
        elseif contains(F.ns4,'sk4')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns4),'-mat');
        else
            errordlg('No file with NS4 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
        path_to_lfp = fullfile(F.fullpath,F.dir_lfp,F.ns4);
    case 'ns5'
        if contains(F.ns5,'ns5')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns5));
        elseif contains(F.ns5,'sk5')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns5),'-mat');
        else
            errordlg('No file with NS5 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
        path_to_lfp = fullfile(F.fullpath,F.dir_lfp,F.ns5);
    case 'ns6'
        if contains(F.ns6,'ns6')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns6));
        elseif contains(F.ns6,'sk6')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns6),'-mat');
        else
            errordlg('No file with NS6 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
        path_to_lfp = fullfile(F.fullpath,F.dir_lfp,F.ns6);
    otherwise
        data_ns = openNSx('read');
        path_to_lfp = '';
end
fprintf(' done.\n');
fprintf('LFP data loaded [%s].\n',path_to_lfp);


% Sorting filename
temp = regexp(path_to_lfp,filesep,'split');
lfp_filename = char(temp(end));
% dat_filename = sprintf('%s[%s].dat',strrep(lfp_filename,'.','-'),datestr(now));
% meta_filename = sprintf('%s[%s].txt',strrep(lfp_filename,'.','-'),datestr(now));
dat_filename = sprintf('%s].dat',strrep(lfp_filename,'.','['));
meta_filename = sprintf('%s].txt',strrep(lfp_filename,'.','['));

% Looking for NConfig file
if exist(fullfile(DIR_SAVE,F.nlab,'Nconfig.mat'),'file')
    % load from ncf file
    d_ncf = load(fullfile(DIR_SAVE,F.nlab,'Nconfig.mat'),...
        'ind_channel','ind_channel_diff','channel_id','channel_list','channel_type');
else
    d_ncf = [];
end

% Exporting RawData
MetaData = data_ns.MetaTags;
RawData = data_ns.Data;

% Filtering
n_channels = MetaData.ChannelCount;
f_samp = MetaData.SamplingFreq;
% Pass-band filtering
f1 = 48;
f2 = 52;
f3 = 250;
[B,A]  = butter(1,[f1 f2]/(f_samp/2),'stop');
[D,C]  = butter(1,f3/(f_samp/2),'low');
FilteredData = [];
for i=1:n_channels
    Y=RawData(i,:);
    Y_temp = int16(filtfilt(B,A,double(Y)));
    Y_temp = int16(filtfilt(D,C,double(Y_temp)));
    FilteredData = [FilteredData ; Y_temp];
end
% Writing to vector
RawData_vect = FilteredData(:);
% RawData_vect = RawData(:);

% Writing file .dat
if flag_write_dat
    fprintf('Exporting LFP data ...');
    fileID = fopen(fullfile(F.fullpath,F.dir_lfp,dat_filename),'w');
    fwrite(fileID,RawData_vect,'int16');
    fclose(fileID);
    fprintf(' done.\n');
    fprintf('LFP data exported [%s].\n',dat_filename);
end

% Direct exportation to specified folder
if flag_write_direct
    temp = regexp(dat_filename,'_','split');
    temp1 = sprintf('Rat-%s',char(temp(2)));
    temp2 = strrep(dat_filename,'.dat','');
    temp3 = strrep(DIR_SAVE,strcat('NEUROLAB',filesep,'NLab_DATA'),'EphysFiltered');
    new_folder = fullfile(temp3,temp1,temp2);
%     new_folder = strrep(DIR_SAVE,strcat('NEUROLAB',filesep,'NLab_DATA'),'EphysRepo');
    
    fprintf('Exporting LFP data ...');
    fileID = fopen(fullfile(new_folder,dat_filename),'w');
    fwrite(fileID,RawData_vect,'int16');
    fclose(fileID);
    fprintf(' done.\n');
    fprintf('LFP data exported [%s].\n',dat_filename);
    
    fid_info = fopen(fullfile(new_folder,meta_filename),'w');
    % Ubuntu bug fix
    try
        fwrite(fid_info,sprintf('FileTypeIDMetaData : %s \n',MetaData.FileTypeID));
    catch
        fwrite(fid_info,sprintf('FileTypeIDMetaData : %s \n',MetaData.FileTypeIDMetaData));
    end
    fwrite(fid_info,sprintf('SamplingLabel : %s \n',MetaData.SamplingLabel));
    fwrite(fid_info,sprintf('ChannelCount : %d \n',MetaData.ChannelCount));
    fwrite(fid_info,sprintf('SamplingFreq : %.2f \n',MetaData.SamplingFreq));
    fwrite(fid_info,sprintf('TimeRes : %.d \n',MetaData.TimeRes));
    %fwrite(fid_info,sprintf('ChannelID : %.d \n',MetaData.ChannelID));
    fwrite(fid_info,sprintf('DateTime : %s \n',MetaData.DateTime));
    %fwrite(fid_info,sprintf('DateTimeRaw : %s \n',MetaData.DateTimeRaw));
    fwrite(fid_info,sprintf('DataPoints : %d \n',MetaData.DataPoints));
    fwrite(fid_info,sprintf('DataDurationSec : %d \n',MetaData.DataDurationSec));
    fwrite(fid_info,sprintf('DataPointsSec : %d \n',MetaData.DataPointsSec));
    fwrite(fid_info,sprintf('Filename : %s \n',MetaData.Filename));
    fwrite(fid_info,sprintf('FilePath : %s \n',MetaData.FilePath));
    fwrite(fid_info,sprintf('FileExt : %s \n',MetaData.FileExt));
    fwrite(fid_info,newline);
    
    if isempty(d_ncf)
        fwrite(fid_info,sprintf('NConfig File : %s \n','none'));
    else
        fwrite(fid_info,sprintf('NConfig File : %s \n',fullfile(DIR_SAVE,F.nlab,'Nconfig.mat')));
        fwrite(fid_info,sprintf('id \t type \t name \n'));
        for i =1:length(d_ncf.ind_channel)
            fwrite(fid_info,sprintf('%d \t %s \t %s \n',d_ncf.ind_channel(i),char(d_ncf.channel_type(i)),char(d_ncf.channel_id(i))));
        end
    end
    
    fclose(fid_info);
    fprintf('Metadata exported [%s].\n',meta_filename);
end

% Writing metadata .txt
if flag_write_txt
    fid_info = fopen(fullfile(F.fullpath,F.dir_lfp,meta_filename),'w');
    % Ubuntu bug fix
    try
        fwrite(fid_info,sprintf('FileTypeIDMetaData : %s \n',MetaData.FileTypeID));
    catch
        fwrite(fid_info,sprintf('FileTypeIDMetaData : %s \n',MetaData.FileTypeIDMetaData));
    end
    fwrite(fid_info,sprintf('SamplingLabel : %s \n',MetaData.SamplingLabel));
    fwrite(fid_info,sprintf('ChannelCount : %d \n',MetaData.ChannelCount));
    fwrite(fid_info,sprintf('SamplingFreq : %.2f \n',MetaData.SamplingFreq));
    fwrite(fid_info,sprintf('TimeRes : %.d \n',MetaData.TimeRes));
    %fwrite(fid_info,sprintf('ChannelID : %.d \n',MetaData.ChannelID));
    fwrite(fid_info,sprintf('DateTime : %s \n',MetaData.DateTime));
    %fwrite(fid_info,sprintf('DateTimeRaw : %s \n',MetaData.DateTimeRaw));
    fwrite(fid_info,sprintf('DataPoints : %d \n',MetaData.DataPoints));
    fwrite(fid_info,sprintf('DataDurationSec : %d \n',MetaData.DataDurationSec));
    fwrite(fid_info,sprintf('DataPointsSec : %d \n',MetaData.DataPointsSec));
    fwrite(fid_info,sprintf('Filename : %s \n',MetaData.Filename));
    fwrite(fid_info,sprintf('FilePath : %s \n',MetaData.FilePath));
    fwrite(fid_info,sprintf('FileExt : %s \n',MetaData.FileExt));
    fwrite(fid_info,newline);
    
    if isempty(d_ncf)
        fwrite(fid_info,sprintf('NConfig File : %s \n','none'));
    else
        fwrite(fid_info,sprintf('NConfig File : %s \n',fullfile(DIR_SAVE,F.nlab,'Nconfig.mat')));
        fwrite(fid_info,sprintf('id \t type \t name \n'));
        for i =1:length(d_ncf.ind_channel)
            fwrite(fid_info,sprintf('%d \t %s \t %s \n',d_ncf.ind_channel(i),char(d_ncf.channel_type(i)),char(d_ncf.channel_id(i))));
        end
    end
    
    fclose(fid_info);
    fprintf('Metadata exported [%s].\n',meta_filename);
end

success = true;

end