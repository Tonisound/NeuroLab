folder_out = 'D:\NEUROLAB\NLab_DATA';
folder_in = 'D:\NEUROLAB\~NLab_DATA';

d_in = dir(fullfile(folder_in,'*nlab'));
ind_keep = [];
for i =1:length(d_in)
    if exist(fullfile(folder_in,char(d_in(i).name),'Atlas.mat'),'file') && exist(fullfile(folder_out,char(d_in(i).name)),'dir')
        
        % Skip in Atlas.mat format not right
        data_atlas = load(fullfile(folder_in,char(d_in(i).name),'Atlas.mat'));
        if ~isfield(data_atlas,'AtlasName')
            continue;
        end
        
        ind_keep = [ind_keep;i];
        fprintf('Copying [%s] -> [%s].\n',fullfile(folder_in,char(d_in(i).name),'Atlas.mat'),fullfile(folder_out,char(d_in(i).name)));
        copyfile(fullfile(folder_in,char(d_in(i).name),'Atlas.mat'),fullfile(folder_out,char(d_in(i).name)));

    end
end