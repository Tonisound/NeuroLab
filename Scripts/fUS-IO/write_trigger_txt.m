function write_trigger_txt(filepath_txt,trigger,reference,padding,offset,delay_lfp_video)

if nargin <4
    padding = 'none';
end
if nargin <5
    offset = 0;
end
if nargin <6
    delay_lfp_video = 0;
end

fid_txt = fopen(filepath_txt,'wt');
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
% fprintf('File trigger.txt saved at %s.\n',file_txt);

end