% Batch Moving fUS files
% Creates fus folder

cur_path = '/media/hobbes/DataMOBs206/Raw-fUS';
cur_parent = 'FUS-EPI';
d_fus = dir(fullfile(cur_path,cur_parent,'*','*','*','*.acq'));

new_path = '/media/hobbes/DataMOBs204/DATA';
new_parent = cur_parent;
% if ~isfolder()
% end


for i = 1:length(d_fus)
    cur_folder = (d_fus(i).folder);
    cur_file = (d_fus(i).name);

    basename = strrep(cur_file,'_fus2D.source.acq','_E');
    
    %session_name = strrep(basename,'_E','_MySession');
    temp = regexp(cur_folder,filesep,'split');
    session_name = strcat(char(temp(end)),'_',char(temp(end-1)),'_MySession');
    session_name = strrep(session_name,'ses-Session_','');
    
    fus_name = strrep(basename,'_E','_fus');
    
    new_folder = fullfile(new_path,new_parent,session_name,basename,fus_name);   
    new_file = strrep(cur_file,'.source.acq','.acq');
    
    if ~isfolder(new_folder)
        mkdir(new_folder);
    end
    if ~isfile(fullfile(new_folder,new_file))
        copyfile(fullfile(cur_folder,cur_file),fullfile(new_folder,new_file));
        fprintf('File %d/%d [%s] moved to [%s].\n',i,length(d_fus),cur_file,new_folder);
    else
        fprintf('File %d/%d [%s] already exported.\n',i,length(d_fus),cur_file);
    end

end