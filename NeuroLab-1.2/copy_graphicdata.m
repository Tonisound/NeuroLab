function copy_graphicdata(RightAxes,ax1,ax2,mode,save_dir,val)
% Copy graphic objects in Right Axes in ax2
% Copy children in Userdata children in ax1

data_t = load(fullfile(save_dir,'Time_Reference.mat'),'n_burst','length_burst','time_ref');
% n_burst = data_t.n_burst;
% length_burst = data_t.length_burst;
n_burst = 1;
length_burst = data_t.length_burst*data_t.n_burst;
time_ref = data_t.time_ref;

if nargin <6
    val =0;
end

% Clear destination axes to avoid multiple copies of graphic objects
delete(findobj(ax1,'Type','Line','-not','Tag','Cursor','-or','Type','Patch'));
delete(findobj(ax2,'Type','Line','-not','Tag','Cursor','-or','Type','Text'));

all_lines = findobj(RightAxes,'Type','Line','-not','Tag','Cursor');
% % temporary to be able to load data
% all_lines = findobj(RightAxes,'Type','Line','-not','Tag','Cursor','-not','Tag','Trace_Region','-not','Tag','Trace_RegionGroup');
lines_other = findobj(all_lines,'Tag','Trace_Pixel','-or','Tag','Trace_Box','-or','Tag','Trace_Region','-or','Tag','Trace_RegionGroup','-or','Tag','Trace_Mean');
lines_spiko = findobj(all_lines,'Tag','Trace_Cerep');

ind_keep = ones(length(lines_spiko),1);
for i =1:length(lines_spiko)
    if ~isempty(strfind(lines_spiko(i).UserData.Name,'LFP/'))||...
            ~isempty(strfind(lines_spiko(i).UserData.Name,'LFP-delta/'))||...
            ~isempty(strfind(lines_spiko(i).UserData.Name,'LFP-theta/'))||...
            ~isempty(strfind(lines_spiko(i).UserData.Name,'LFP-gammalow/'))||...
            ~isempty(strfind(lines_spiko(i).UserData.Name,'LFP-gammamid/'))||...
            ~isempty(strfind(lines_spiko(i).UserData.Name,'LFP-gammamidup/'))||...
            ~isempty(strfind(lines_spiko(i).UserData.Name,'LFP-gammahigh/'))||...
            ~isempty(strfind(lines_spiko(i).UserData.Name,'LFP-gammahighup/'))||...
            ~isempty(strfind(lines_spiko(i).UserData.Name,'LFP-ripple/'))||...
            ~isempty(strfind(lines_spiko(i).UserData.Name,'EMG/'))
        ind_keep(i) = 0;
    end
end

switch val
    case 0
        % Val = 0 : copy all lines
        lines = all_lines;
    case 1
        % Val = 1 : copy all but LFP lines
        lines = [lines_other; lines_spiko(ind_keep==1)];
    case 2
        % Val = 2 : copy only LFP lines
        lines = lines_spiko(ind_keep==0);
end

% Copying lines
h_line = copyobj(lines,ax2);

for i=length(h_line):-1:1
    s = struct('Name',[]);
    % Adding field Selected to s
    if isfield(h_line(i).UserData,'Selected')
        s.Selected = h_line(i).UserData.Selected;
    end
    
    switch h_line(i).Tag
        % Copying items one-by-one
        case {'Trace_Mean'}
            s.Name = h_line(i).UserData.Name;
            h_line(i).UserData = s;
        
        case {'Trace_Cerep'}
            s.Name = h_line(i).UserData.Name;
            dir_save = fullfile(save_dir,'Sources_LFP');
            name = regexprep(s.Name,'/|\','_');
                    
            switch mode
                case 'loading'
                    name = regexprep(s.Name,'/','_');
                    try
                        data_l = load(fullfile(dir_save,strcat(name,'.mat')),'Y','f','x_start','x_end');
                        %fprintf('[X,Y] data loaded at %s.\n',fullfile(dir_save,strcat(name,'.mat')));
                        %f = data_l.f;
                        % bug fix irregular sampling rate
                        f = (data_l.x_end-data_l.x_start)/(length(data_l.Y)-1);
                        s.X = data_l.x_start:f:data_l.x_end;
                        s.Y = data_l.Y;
                    catch
                        warning('Unable to find trace [%s]. Loading dummy trace.',name);
                        s.X = data_t.time_ref.Y;
                        s.Y = NaN(size(s.X));
                    end
                    
                 case 'saving'
%                     if ~exist(dir_save,'dir')
%                         mkdir(dir_save);
%                     end
%                     X = h_line(i).UserData.X;
%                     Y = h_line(i).UserData.Y;
%                     f = X(2)-X(1);
%                     x_start = X(1);
%                     x_end = X(end);
%                     save(fullfile(dir_save,strcat(name,'.mat')),'Y','f','x_start','x_end','-v7.3');
%                     fprintf('[X,Y] data saved at %s.\n',fullfile(dir_save,strcat(name,'.mat')));
            end
            h_line(i).UserData = s;
            
        case {'Trace_Region';'Trace_RegionGroup'}
            dir_save = fullfile(save_dir,'Sources_fUS');
                    
            switch mode
                case 'loading'
                    hp = copyobj(h_line(i).UserData.Graphic,ax1);
                    hp.UserData = h_line(i);
                    h_line(i).UserData.Graphic = hp;
                    % loading mask
                    name = regexprep(h_line(i).UserData.Name,'/','_');
                    % name = strrep(name,'|','&');
                    data_l = load(fullfile(dir_save,strcat(name,'.mat')),'mask');
                    %fprintf('[X,Y] data loaded at %s.\n',fullfile(dir_save,strcat(name,'.mat')));
                    h_line(i).UserData.Mask = data_l.mask;
                    
                case 'saving'
                    hp = copyobj(h_line(i).UserData.Graphic,ax1);
                    s.Name = h_line(i).UserData.Name;
                    s.Graphic = hp;
                    %s.Mask = hp.UserData.Mask;
                    mask = h_line(i).UserData.Mask;
                    h_line(i).UserData = s;
                    hp.UserData = h_line(i);
                    
                    %saving dir
                    name = regexprep(s.Name,'/','_');
                    if ~exist(dir_save,'dir')
                        mkdir(dir_save);
                    end
                    % Reshaping Y and saving
                    ydat = reshape(h_line(i).YData(:),[length_burst+1,n_burst]);
                    Y = reshape(ydat(1:end-1,:),[length_burst*n_burst,1]);
                    X = time_ref.Y;
                    save(fullfile(dir_save,strcat(name,'.mat')),'X','Y','mask','-v7.3');
                    %fprintf('[X,Y] data saved at %s.\n',fullfile(dir_save,strcat(name,'.mat')));

            end
        case {'Trace_Pixel','Trace_Box'}
            switch mode
                case 'loading'
                    hp = copyobj(h_line(i).UserData.Graphic,ax1);
                    hp.UserData = h_line(i);
                    h_line(i).UserData.Graphic = hp;
                    
                case 'saving'
                    hp = copyobj(h_line(i).UserData.Graphic,ax1);
                    s.Name = h_line(i).UserData.Name;
                    s.Graphic = hp;
                    h_line(i).UserData = s;
                    hp.UserData = h_line(i);
            end
        otherwise
            warning('Unidentified Trace Format.\n')
    end
    % Adding Selected Field if not existent in loading mode
    if ~isfield(h_line(i).UserData,'Selected') && strcmp(mode,'loading')
        h_line(i).UserData.Selected = 0;
    end

end



% Copying Time Patches
delete(findobj(ax2,'Tag','TimePatch'));
time_patches = findobj(RightAxes,'Tag','TimePatch');
copyobj(time_patches,ax2);

end