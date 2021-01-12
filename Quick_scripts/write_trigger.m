file_txt = fullfile('trigger.txt');
fid_txt = fopen(file_txt,'wt');
fprintf(fid_txt,'%s',sprintf('<REF>%s</REF>\n','manual'));
fprintf(fid_txt,'%s',sprintf('<PAD>%s</PAD>\n','exact'));
fprintf(fid_txt,'%s',sprintf('<OFFSET>%.3f</OFFSET>\n',0));
fprintf(fid_txt,'%s',sprintf('<DELAY>%.3f</DELAY>\n',0));
fprintf(fid_txt,'%s',sprintf('<TRIG>\n'));
%fprintf(fid_txt,'%s',sprintf('n=%d \n',length(trigger)));
for k = 1:length(trigger)
    fprintf(fid_txt,'%s',sprintf('%.3f\n',trigger(k)));
end
fprintf(fid_txt,'%s',sprintf('</TRIG>'));
fclose(fid_txt);
fprintf('File trigger.txt saved at %s.\n',file_txt);
