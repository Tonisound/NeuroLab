function [trigger,reference,padding,offset,delay_lfp_video] = read_trigger_txt(filepath_txt)

fid_txt = fopen(filepath_txt,'r');
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