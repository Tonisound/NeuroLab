 function success = export_time_tags(dir_tags,dir_save) 
 
success = false;
temp = regexp(dir_save,filesep,'split');
filename = char(temp(end));
file_txt = fullfile(dir_tags,strcat(filename,sprintf('(%s)',datetime),'_tags.txt')); 


% Loading Time Tags
if exist(fullfile(dir_save,'Time_Tags.mat'),'file')
    tdata = load(fullfile(dir_save,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    temp = datenum(tdata.TimeTags_strings(:,1));
    t_start = (temp-floor(temp))*24*3600;
    temp = datenum(tdata.TimeTags_strings(:,2));
    t_end= (temp-floor(temp))*24*3600;
    
else
    errordlg('Missing file Time_Tags.mat [%s]',dir_save);
    return;
end


% file export
fid_w = fopen(file_txt,'w');
fwrite(fid_w,sprintf('<Tag> \t <start> \t <end>'));
fwrite(fid_w,newline);
for i=1:size(tdata.TimeTags,1)
    fwrite(fid_w,sprintf('%s \t %.3f \t %.3f ',tdata.TimeTags(i).Tag,t_start(i),t_end(i)));
    fwrite(fid_w,newline);
end
fclose(fid_w);
fprintf('Time Tags Exportation successful [%s].\n',file_txt);

success = true;

end
