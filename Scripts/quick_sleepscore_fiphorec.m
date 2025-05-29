% Script used to sleep score fUS-fiber-photometry recordings
% Sleep score based only on Body Speed
% Detects active wake by thresholding body speed (two thresholds)
% Adds quiet wake bouts for XX seconds after active wake 
% Adds nrem bouts in all remaining spots 


global DIR_SAVE FILES CUR_FILE;


% Parameters
t_smooth = 5;           % seconds
thresh1 = .15;          % m/s
thresh2 = .2;           % m/s
length_qw_bout = 20;    % seconds


% Loading Time Reference
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file')
    data_tr = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),...
        'time_ref','length_burst','n_burst','rec_mode');
    time_ref = data_tr.time_ref;
else
    warning('Missing File [%s]',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
    return;
end

% Loading Time Tags
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'file')
    data_tt = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'));
else
    warning(sprintf('Missing Time_Tags file [%s].',FILES(CUR_FILE).nlab));
    data_tt = [];
end

% Loading Body Speed
file_ext = fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).dir_ext,'BodySpeed.ext');
if isfile(file_ext)
    [X,Y,format,nb_samples,parent,shortname,fullname] = read_ext_file(file_ext);
else
    warning('Absent BodySpeed.ext File [%s]',FILES(CUR_FILE).dir_ext);
    return;
end
% Gaussian smoothing
f_filt = 1/median(diff(X));
n = max(round(t_smooth*f_filt),1);
Y_smooth = conv(Y,gausswin(n)/n,'same');
% Thresholding
Y_thresh1 = NaN(size(Y,1),size(Y,2));
index1 = Y_smooth>thresh1;
Y_thresh1(index1) = Y_smooth(index1);
Y_thresh2 = NaN(size(Y,1),size(Y,2));
index2 = Y_smooth>thresh2;
Y_thresh2(index2) = Y_smooth(index2);


f = figure;
ax = axes('Parent',f);
% l1 = line('XData',X,'YData',Y,'Color',[.5 .5 .5],'Parent',ax);
l2 = line('XData',X,'YData',Y_smooth,'Color','b','Parent',ax);
l3 = line('XData',X,'YData',Y_thresh1,'Color','g','Parent',ax);
l4 = line('XData',X,'YData',Y_thresh2,'Color','r','Parent',ax);
% l5 = line('XData',X,'YData',index1+index2,'Color','k','Parent',ax);
ax.XLim = [data_tr.time_ref.Y(1) data_tr.time_ref.Y(end)];

t_start = [];
t_end = [];
all_times_aw = [];
flag_crossed = false;
i = 1;
while i <= length(Y)
    
    if ~flag_crossed
        % detecting start
        
        if index1(i)==1 && isempty(t_start)
            t_start = X(i);
        elseif index1(i)==0
            t_start = [];
        end
        
        if index2(i)==1
            flag_crossed = true;
        end
        
    else
        % detecting end
        
        if index1(i)==0 && isempty(t_end)
            t_end = X(i-1);
            flag_crossed = false;
            all_times_aw = [all_times_aw;t_start t_end];
            t_start = [];
            t_end = [];
        end
        
    end

    i = i+1;
end

if ~isempty(t_start) && isempty(t_end)
    all_times_aw = [all_times_aw;t_start X(end)];
end


all_times_qw = [];
all_times_nrem = [];


for j=1:size(all_times_aw,1)-1
    
    t_start_qw = all_times_aw(j,2);
    if all_times_aw(j+1,1) < t_start_qw+length_qw_bout
        t_end_qw = all_times_aw(j+1,1);
       
    else
        t_end_qw = t_start_qw+length_qw_bout;
        all_times_nrem = [all_times_nrem;t_end_qw all_times_aw(j+1,1)];
    end
    all_times_qw = [all_times_qw;t_start_qw t_end_qw];

end


str_tag_aw = cell(size(all_times_aw,1),1);
for j=1:size(all_times_aw,1)  
    line('XData',[all_times_aw(j,1) all_times_aw(j,2)],'YData',[thresh1 thresh1],...
        'Linewidth',5,'Color','k','Parent',ax);
    str_tag_aw{j} = sprintf('AW-%03d',j);
end
t_str_aw1 = datestr(all_times_aw(:,1)/(24*3600),'HH:MM:SS.FFF');
t_str_aw2 = datestr(all_times_aw(:,2)/(24*3600),'HH:MM:SS.FFF');
 
str_tag_qw = cell(size(all_times_qw,1),1);
for j=1:size(all_times_qw,1)
    line('XData',[all_times_qw(j,1) all_times_qw(j,2)],'YData',[thresh1 thresh1],...
        'Linewidth',5,'Color',[.5 .5 .5],'Parent',ax);
    str_tag_qw{j} = sprintf('QW-%03d',j);
end
t_str_qw1 = datestr(all_times_qw(:,1)/(24*3600),'HH:MM:SS.FFF');
t_str_qw2 = datestr(all_times_qw(:,2)/(24*3600),'HH:MM:SS.FFF');


str_tag_nrem = cell(size(all_times_nrem,1),1);
for j=1:size(all_times_nrem,1)
    line('XData',[all_times_nrem(j,1) all_times_nrem(j,2)],'YData',[thresh1 thresh1],...
        'Linewidth',2,'Color','r','Parent',ax);
    str_tag_nrem{j} = sprintf('NREM-%03d',j);
end
t_str_nrem1 = datestr(all_times_nrem(:,1)/(24*3600),'HH:MM:SS.FFF');
t_str_nrem2 = datestr(all_times_nrem(:,2)/(24*3600),'HH:MM:SS.FFF');


% Merging 
[all_times,index_sort] = sort([all_times_aw;all_times_qw;all_times_nrem]);
index_sort = index_sort(:,1);
t_str_all1 = [t_str_aw1;t_str_qw1;t_str_nrem1];
t_str_all1 = t_str_all1(index_sort,:);
t_str_all2 = [t_str_aw2;t_str_qw2;t_str_nrem2];
t_str_all2 = t_str_all2(index_sort,:);
str_tag_all = [str_tag_aw;str_tag_qw;str_tag_nrem];
str_tag_all = str_tag_all(index_sort);


% Building TimeTags from all_times
n = size(all_times,1);
% TimeTags_strings & TimeTags_images
TimeTags_strings = [];
TimeTags_images = zeros(n,2);
for k=1:n
    TimeTags_strings = [TimeTags_strings;[{t_str_all1(k,:)},{t_str_all2(k,:)}]];
    [~, ind_min_time] = min(abs(data_tr.time_ref.Y-all_times(k,1)));
    [~, ind_max_time] = min(abs(data_tr.time_ref.Y-all_times(k,2)));
    TimeTags_images(k,:) = [ind_min_time,ind_max_time];
end
tts1 = datenum(TimeTags_strings(:,1));
tts2 = datenum(TimeTags_strings(:,2));
TimeTags_seconds = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;
%TimeTags_seconds = all_times;
TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');
% TimeTags_cell & TimeTags
TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
TimeTags_cell = cell(n+1,6);
TimeTags_cell(1,:) = {'Episode','Tag','Onset','Duration','Reference','Tokens'};
for k=1:n
    TimeTags(k,1).Episode = '';
    TimeTags(k,1).Tag = char(str_tag_all(k));
    TimeTags(k,1).Onset = char(t_str_all1(k,:));
    TimeTags(k,1).Duration = char(TimeTags_dur(k,:));
    TimeTags(k,1).Reference = char(t_str_all1(k,:));
    TimeTags(k,1).Tokens = '';
    TimeTags_cell(k+1,:) = {'',TimeTags(k,1).Tag,TimeTags(k,1).Onset,TimeTags(k,1).Duration,TimeTags(k,1).Reference,''};
end

% Append
TimeTags_strings = [data_tt.TimeTags_strings;TimeTags_strings];
TimeTags_images = [data_tt.TimeTags_images;TimeTags_images];
TimeTags_cell = [data_tt.TimeTags_cell;TimeTags_cell(2:end,:)];
TimeTags = [data_tt.TimeTags;TimeTags];
save(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),...
    'TimeTags_strings','TimeTags_images','TimeTags_cell','TimeTags','-v7.3');
fprintf('File Time_Tags.mat Saved [%s].\n',FILES(CUR_FILE).nlab);
