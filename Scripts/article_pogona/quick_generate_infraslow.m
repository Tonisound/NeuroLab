function quick_generate_infraslow()

global DIR_SAVE FILES CUR_FILE;

n_std = .5;
t_gauss = 30;
t_step = .01;

d_whole = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS','Whole-reg.mat'));
d_dvrr = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS','DVR-R.mat'));
d_dvrl = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS','DVR-L.mat'));
d_dvr = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS','DVR.mat'));
d = d_whole;

if ~isempty(d)
    data = load(fullfile(d.folder,d.name));
    X = data.X(:);
    Y = data.Y(:);
else
    errordlg(sprintf('Unable to find region Whole [%s].',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS')));
    return;
end

% Gaussian window
delta =  median(diff(X));
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);
Yfiltered = nanconv(Y,w,'same');

% Interpolation
Xq = (X(1):.01:X(end))';
Yq = interp1(X,Yfiltered,Xq);

m = nanmean(Yfiltered);
s = nanstd(Yfiltered);
thresh = m+n_std*s;

figure;
% line('XData',X,'YData',Y,'Color','r');
% line('XData',X,'YData',Yfiltered,'Color','r');
line('XData',Xq,'YData',Yq,'Color','r');
line('XData',[X(1),X(end)],'YData',[thresh thresh]);

% Y_above = Xq(Yq>m+n_std*s);
% X_below = Xq(Yq<=m+n_std*s);


X_above = Xq(Yq>thresh);
Y_above = Yq(Yq>thresh);
% X_below = Xq(Yq<=m+n_std*s);
% X_above_diff = diff(X_above);
% X_below_diff = diff(X_below);

line('XData',X_above,'YData',Y_above,'Color','b','Marker','o','LineStyle','none');

index_found = find((diff(X_above))>(2*t_step));
t_start = [X_above(1);X_above(index_found+1)];
t_end = [X_above(index_found);X_above(end)];


% output_file = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Events','Test.csv');
output_file = 'Infraslow.csv';
R = [t_start,t_end];
write_csv_events(output_file,R)

end