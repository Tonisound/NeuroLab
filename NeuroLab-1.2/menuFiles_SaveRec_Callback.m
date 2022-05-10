function  menuFiles_SaveRec_Callback(~,~,handles)
% Save Recording as txt file

global FILES SEED_SWL CUR_FILE DIR_SAVE STR_SAVE SEED;

% asking for filename
%filename = 'rec_list.txt';
filter = {'*.txt'};
title = 'Save recording list';
defname = fullfile(SEED_SWL,strcat(FILES(CUR_FILE).parent,'.txt'));
[file,path]  = uiputfile(filter,title,defname);

% Extracting FileName
if file == 0
    return;
else
    % Nlab list
    filename = fullfile(path,file);
    fid = fopen(filename, 'wt' );
    for i=1:length(FILES)
        % Saving nlab files
        %fprintf(fid,'%s',sprintf('%s',fullfile(DIR_SAVE,FILES(i).nlab)));
        
        fprintf(fid,'%s',sprintf('%s',fullfile(strrep(DIR_SAVE,STR_SAVE,'NEUROLAB'),FILES(i).nlab)));
        fprintf(fid,'%s',newline);
    end
    fclose(fid);
    
    % Source list
%     if ispc
%         path_source = fullfile(SEED_SWL,'Source_pc');
%     elseif ismac
%         path_source = fullfile(SEED_SWL,'Source_mac');
%     else
%         path_source = fullfile(SEED_SWL,'Source_undefinied');
%     end
    % creating if dir is missing
    path_source = fullfile(SEED_SWL,'Source');
    if ~exist(path_source,'dir')
        mkdir(path_source);
    end
    filename = fullfile(path_source,strcat(file(1:end-4),'_S',file(end-3:end)));
    % filename = fullfile(path,strcat(file(1:end-4),'_S',file(end-3:end)));
    fid = fopen(filename, 'wt' );
    for i=1:length(FILES)
        % Saving seed files
        %fprintf(fid,'%s',sprintf('%s',FILES(i).fullpath));
        fprintf(fid,'%s',sprintf('%s',strrep(FILES(i).fullpath,SEED,'DATA')));
        fprintf(fid,'%s',newline);
    end
    fclose(fid);
    fprintf('Recording list saved %s.\n',filename);
end

end