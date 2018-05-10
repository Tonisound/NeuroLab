function success = import_episodes(dir_spiko,dir_save)

success = false;
dir_episodes = dir(fullfile(dir_spiko,'*_export'));
ind_keep = zeros(size(dir_episodes,1),1);
for i =1:length(dir_episodes)
    dir_files = dir(fullfile(dir_spiko,dir_episodes(i).name,'*.txt'));
    for k=1:length(dir_files)
        if ~strcmp(dir_files(k).name,'_descriptor.txt')&&(length(dir_files)==1)
            ind_keep(i)=1;
        end
    end
end
list_keep = {dir_episodes(ind_keep>0).name};
if isempty(list_keep)
    warning('Missing episode files (%s)',dir_spiko);
    return;
end
[ind_episodes,ok] = listdlg('PromptString','Select Episodes','SelectionMode','multiple','ListString',list_keep,'ListSize',[400 500]);
episodes = struct('parent',{},'fullname',{},'shortname',{},'unit',{},'nb_samples',{},'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{});
count = 0;

if ~ok || isempty(ind_episodes)
    return;
end

for i=ind_episodes
    dirname = char(list_keep(i));
    text_file = dir(fullfile(dir_spiko,dirname,'*.txt'));
    filename = fullfile(dir_spiko,dirname,text_file(1).name);
    
    % Direct Importation
    fileID = fopen(filename,'r');
    hline1 = fgetl(fileID);
    hline_1 = regexp(hline1,'(\t+)','split');
    hline2 = fgetl(fileID);
    hline_2 = regexp(hline2,'(\t+)','split');
    
    % Reading line-by-line Testing for End of file
    tline = fgetl(fileID);
    %T = regexp(tline,'(\t+)','split');
    T = str2num(tline);
    while ischar(tline)
        try
            tline = fgetl(fileID);
            %T = [T;regexp(tline,'(\t+)','split')];
            T = [T;str2num(tline)];
        catch
            fprintf('(Warning) Importation stoped at line %d\n (File : %s)',size(T,1)+1,filename);
        end
    end
    fclose(fileID);
    for k=2:size(T,2)
        count = count+1;
        episodes(count).shortname = char(hline_2(k));
        episodes(count).parent = char(dirname);
        episodes(count).fullname = strcat(char(dirname),'/',char(hline_2(k)));
        episodes(count).X = T(:,1);
        episodes(count).Y = T(:,k);
        episodes(count).X_ind = T(:,1);
        episodes(count).X_im = T(:,1);
        episodes(count).Y_im = T(:,k);
        episodes(count).nb_samples = length(T(:,k));
    end
    fprintf('Succesful Importation (File %s /Folder %s).\n', text_file(1).name,dirname);
    
end

% Save dans SpikoscopeEpisodes.mat
fprintf('===> Saved at %s.mat\n',fullfile(dir_save,'Spikoscope_Episodes.mat'));
save(fullfile(dir_save,'Spikoscope_Episodes.mat'),'episodes','-v7.3');
success = true;

end
