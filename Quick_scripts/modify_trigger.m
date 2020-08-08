function modify_trigger(folder_txt,file_out)
% last update 20/02/19 by Antoine
% opens and import parameters from trigger file 
% folder_txt: path to folder
% Update Modification section if needed

if nargin == 0
    folder_txt = char(uigetdir('Select fUS directory'));
    file_out = fullfile(folder_txt,'trigger_modified.txt');
end

if nargin == 1
    file_out = fullfile(folder_txt,'trigger_modified.txt');
end

%% Trigger Importation
% default values
reference = 'default';
padding = 'none';
offset = 0; % default
trigger = [];

file_txt = fullfile(folder_txt,'trigger.txt');
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


%% Trigger Modification
delta_t = trigger(2)-trigger(1);
factor_interp = 40;
trigger = trigger(1):delta_t/factor_interp:trigger(end);
reference = folder_txt;
padding = sprintf('Interpolation[%d][%d]',factor_interp,length(trigger));
% offset = '';



%% Trigger Exportation
fid_txt = fopen(file_out,'wt');
fprintf(fid_txt,'%s',sprintf('<REF>%s</REF>\n',reference));
fprintf(fid_txt,'%s',sprintf('<PAD>%s</PAD>\n',padding));
fprintf(fid_txt,'%s',sprintf('<OFFSET>%.3f</OFFSET>\n',offset));
fprintf(fid_txt,'%s',sprintf('<TRIG>\n'));
%fprintf(fid_txt,'%s',sprintf('n=%d \n',length(trigger)));
for k = 1:length(trigger)
    fprintf(fid_txt,'%s',sprintf('%.3f\n',trigger(k)));
end
fprintf(fid_txt,'%s',sprintf('</TRIG>'));
fclose(fid_txt);
fprintf('File trigger.txt saved at %s.\n',file_out);

end