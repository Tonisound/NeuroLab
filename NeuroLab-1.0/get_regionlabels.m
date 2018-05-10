function labels = get_regionlabels

global FILES CUR_FILE DIR_SAVE IM;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Spikoscope_Regions.mat'),'regions');
catch
    errordlg(sprintf('Missing File %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Spikoscope_Regions.mat')));
    return;
end

labels = cell(size(IM,1),size(IM,2));
n_pixels = zeros(length(regions),1);
for k=1:length(regions)
n_pixels(k) = sum(regions(k).mask(:));
end

[~,ind]=sort(n_pixels,'descend');
regions = regions(ind);

for k=1:length(regions)
name = regions(k).name;
labels(regions(k).mask==1)={name};
end

labels(cellfun(@isempty,labels))={'unknown'};

end