function success = import_time_tags(dir_spiko,dir_save,handles)

success = false;
dir_time = dir(fullfile(dir_spiko,'*tags.txt'));

switch length(dir_time)
    case 0
        errordlg(sprintf('Missing Time Tags File *tags.txt (Dir %s)',dir_spiko));
        return;
    case 1
        ind_time=1;
    case 2
        ind_time = listdlg('PromptString','Select Reference Time File','SelectionMode','single','ListString',{dir_time.name},'ListSize',[300 500]);
end

handles.MainFigure.Pointer = 'watch';
drawnow;
filename = fullfile(dir_spiko,dir_time(ind_time).name);

% Direct Importation
fileID = fopen(filename,'r');
hline = fgetl(fileID);
hline = regexp(hline,'(\t+)','split');

% Reading line-by-line Testing for End of file
tline = fgetl(fileID);
T = regexp(tline,'(\t+)','split');
while ischar(tline)
    try
        tline = fgetl(fileID);
        T = [T;regexp(tline,'(\t+)','split')];
    catch
        fprintf('(Warning) Importation stoped at line %d\n (File : %s)',size(T,1)+1,filename);
    end
end
fclose(fileID);

% Importing Time Reference for Middle Trigger
TimeTags = cell2struct(T', hline(:));
TimeTags_cell = [hline;T];

% Save dans ReferenceTime.mat
if  isempty(TimeTags)
    errordlg('Empty File Time Tags %s\n',dir_spiko);
    return;
end

% Extracting min_time & max_tim for each tag
n = size(TimeTags,1);
TimeTags_strings = cell(n,2);
TimeTags_images = zeros(n,2);
tts = datenum(handles.TimeDisplay.UserData);
for k=1:n
    min_time = char(TimeTags_cell(k+1,3));
    max_time_on = char(TimeTags_cell(k+1,3));
    max_time_dur = char(TimeTags_cell(k+1,4));
    max_time = datestr(datenum(max_time_on)+datenum(max_time_dur),'HH:MM:SS.FFF');
    [~, ind_min_time] = min(abs(tts-datenum(min_time)));
    [~, ind_max_time] = min(abs(tts-datenum(max_time)));
    TimeTags_strings(k,:) = {min_time,max_time};
    TimeTags_images(k,:) = [ind_min_time,ind_max_time];
end
    
% Concatenate existing and imported data
% Loading if existing TimeTags file
if exist(fullfile(dir_save,'Time_Tags.mat'),'file')
    data = load(fullfile(dir_save,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    TimeTags = [data.TimeTags;TimeTags];
    TimeTags_cell = [data.TimeTags_cell;TimeTags_cell(2:end,:)];
    TimeTags_strings = [data.TimeTags_strings;TimeTags_strings];
    TimeTags_images = [data.TimeTags_images;TimeTags_images];
end

% Saving
save(fullfile(dir_save,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
fprintf('Succesful Time Tags Importation (File %s).\n',filename);
fprintf('===> Saved at %s.mat\n',fullfile(dir_save,'Time_Tags.mat'));
handles.MainFigure.Pointer = 'arrow';
success = true;

end
