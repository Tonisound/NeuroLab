% path = '/Users/tonio/Documents/Antoine-fUSDataset/NEUROLAB/NLab_DATA/20190930_P3-020_E_nlab';
path = '/Users/tonio/Library/CloudStorage/OneDrive-McGillUniversity/Documents/MATLAB/NeuroLab';
filename = '20190930_Essai20.mat';
d = load(fullfile(path,filename));

close all;
f= figure;
all_axes=[];
indexes=1:11;
% indexes=[5,6,7,8,9,10,11];
counter = 0;
for i = indexes
    counter = counter+1;
    ax = subplot(length(indexes),1,counter,'Parent',f);
    plot(d.Time,d.Data(i,:));
    ax.YLabel.String = char(d.Info.ChLabel(i));
    all_axes=[all_axes;ax];
end
linkaxes(all_axes,'x');