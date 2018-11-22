function success = saving_UFParams(folder_fus,folder_save)
% Save acquisition parameters in Config.mat
 
%global DIR_SAVE FILES CUR_FILE;
%folder_fus = fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).dir_fus);
%folder_save = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);

success  = false;

d_seq = fullfile(folder_fus,'run.bseq');
if exist(d_seq,'file')
    Seq = openSharedFile(d_seq,defineSeq ());
else
    Seq = [];
    warning('File not found %s.\n',d_seq);
end


d_sequf = fullfile(folder_fus,'SeqUF.bseq');
if exist(d_sequf,'file')
    SeqUF = openSharedFile(d_sequf,defineSeqUF());
else
    SeqUF = [];
    warning('File not found %s.\n',d_sequf);
end


fprintf('Saving acquisition parameters in %s...',folder_save);
save(fullfile(folder_save,'Config.mat'),'Seq','SeqUF','-append');
fprintf(' done.\n');

success  = true;

end