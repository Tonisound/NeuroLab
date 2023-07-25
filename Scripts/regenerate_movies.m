% Script regenerating moving from frames
% Requires workingDir (frames) and original video .avi)

folder_video = '/Volumes/DataMOBs171/Antoine-fUSDataset/NEUROLAB/NLab_Figures/Movie_Normalized[V3]';
d = dir(fullfile(folder_video,'*','*.avi'));

video_quality = 25;

for i=2%:length(d)
    tic
    % Looking for workingDir
    dd = dir(fullfile(d(i).folder,'*Frames'));
    if isempty(dd)
        warning('Working Directory not found [%s]',d(i).name);
        continue;
    elseif length(dd)>1
        warning('Multiple Working Directory found [%s] selecting first [%s]',d(i).name,dd(1).name);
    end
    workingDir = fullfile(dd(1).folder,dd(1).name);
    savedir = dd(1).folder;
    video_name = strrep(d(i).name,'.avi','');

    save_video(workingDir,savedir,video_name,video_quality);
    toc;
end
