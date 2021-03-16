function export_video_SlipAnalysis()
% Export Video to be read in Slip Analysis

% Loading data from .exp file
Info=loadEXP([],'no');
t_start = Info.BinFiles.TStart;

% Selecting fUS Data folder (_E)
global SEED;
if exist(SEED,'dir')
    folder_name = uigetdir(SEED,'Select Destination Folder');
else
    folder_name = uigetdir('Select Destination Folder');
end
temp = regexp(folder_name,filesep,'split');
recording = char(temp(end));
dir_fus = strrep(recording,'_E','_fus');

% Export in Video folder
%dir_slip = strrep(recording,'_E','_slip');
dir_slip = fullfile(Info.FilesDir,'Video');
if ~exist(dir_slip,'dir')
    mkdir(dir_slip);
    fprintf('Directory created [%s].\n',dir_slip);
end

% Copying Doppler_normalized
d = dir(fullfile(folder_name,dir_fus,'*.acq'));    
dop_name = strrep(d(1).name,'.acq','.mat');

% Shear copy
% copyfile(fullfile(folder_name,dir_fus,d(1).name),fullfile(dir_slip,dop_name));

% Transform Doppler
fprintf('Copying Doppler file ...');
data = load(fullfile(folder_name,dir_fus,d(1).name),'-mat');
fprintf(' done.\n');
Doppler_film = permute(data.Acquisition.Data,[3,1,4,2]);
% Normalizing Doppler_film
fprintf('Normalizing Doppler ...');
im_mean = mean(Doppler_film,3,'omitnan');
M = repmat(im_mean,1,1,size(Doppler_film,3));
Doppler_film = 100*(Doppler_film-M)./M;
fprintf(' done.\n');
fprintf('Saving Doppler file ...');
save(fullfile(dir_slip,dop_name),'Doppler_film','-v7.3');

fprintf(' done.\n');
fprintf('=> [%s].\n',fullfile(dir_slip,dop_name));

% Opening trigger.txt
file_txt = fullfile(folder_name,dir_fus,'trigger.txt');
S = read_trigger(file_txt);
%reference = S.reference;
%padding = S.padding;
%offset = S.offset;
trigger = S.trigger;

% Writing time stamps
dop_txt = strcat(dop_name,'_Timers.txt');
file_txt = fullfile(dir_slip,dop_txt);
fid_txt = fopen(file_txt,'w');

fprintf(fid_txt,'%s',sprintf('%s\t','AviCnt'));
fprintf(fid_txt,'%s',sprintf('%s\t','ImageBuff'));
fprintf(fid_txt,'%s',sprintf('%s\t','Image_TimeStamp'));
fprintf(fid_txt,'%s',sprintf('%s\t','Timer_Timestamp'));
fprintf(fid_txt,'%s',sprintf('%s\t','Error_Cam'));
fprintf(fid_txt,'%s',newline);
for k = 1:length(trigger)
    fprintf(fid_txt,'%s',sprintf('%d\t',k));
    fprintf(fid_txt,'%s',sprintf('%d\t',k));
    
    delay_k = t_start+(trigger(k)/(24*3600));
    t_k = datestr(delay_k,'yyyy-mm-dd_HH-MM-SS-FFF');
    
    fprintf(fid_txt,'%s',sprintf('%s\t',t_k));
    fprintf(fid_txt,'%s',sprintf('%s\t',t_k));
    fprintf(fid_txt,'%s',sprintf('%d\t',0));
    fprintf(fid_txt,'%s',newline);
end
fclose(fid_txt);
fprintf('File trigger.txt saved at %s.\n',file_txt);

end

function S = read_trigger(file_txt)

reference = 'default';
padding = 'none';
offset = 0; % default
trigger = [];

%file_txt = fullfile(folder_txt,'trigger.txt');
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
% TRIG
B = regexp(A,'<TRIG>|</TRIG>','split');
C = char(B(2));
D = textscan(C,'%f');
trigger = D{1,1};

S.reference = reference;
S.padding = padding;
S.offset = offset;
S.trigger = trigger;

end