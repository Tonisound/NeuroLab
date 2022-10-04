function fUStemp = fUStempScript_AB()
% Script written by M. Matei
% Synthesis to compute REM duration, times, across conditions (ON/OFF)

global FILES DIR_SAVE

fUStemp = struct('File',[],'FileInfo',struct,'Parameters',struct,...
    'TimingInfo',struct,'Times',struct,'Durations',struct,'Indices',struct,...
    'Percentages',struct,'REMstats',struct,'Temperature',struct);

for file = 1:size(FILES,2)
    
%  file info    
    fUStemp(file).File = FILES(file).recording;
    C = strsplit(fUStemp(file).File,'_');
    fUStemp(file).FileInfo.Date = C{1,1};
    fUStemp(file).FileInfo.Animal = C{1,2};
    fUStemp(file).FileInfo.Rec = C{1,3};
    tg = load(fullfile(DIR_SAVE,FILES(file).nlab,'Time_Groups.mat'));
    
    
%  parameters    
    % define the ON/OFF condition
    if strcmp(FILES(file).type,'EEG-VIDEO')
        fUStemp(file).Parameters.ON_OFF = 'OFF';
    else
        fUStemp(file).Parameters.ON_OFF = 'ON';
    end
    
    % define the plane
    Pdefault = '-3.5 mm'; Pfront = '0 mm'; Pback = '-5 mm';
    Pfront_sessions = {'20210119_SD123_MySession';'20210123_SD123_MySession';'20210124_SD122_MySession';'20210125_SD121_MySession';'20210126_SD121_MySession';'20210128_SD121_MySession_';'20210224_SD132_MySession'};
    Pback_sessions = {'20210120_SD121_MySession';'20210121_SD121_MySession';'20210122_SD121_MySession';'20210129_SD122_MySession';'20210219_SD131_MySession';'20210220_SD132_MySession';'20210222_SD132_MySession';'20210223_SD132_MySession'};
    
    if sum(strcmp(FILES(file).session,Pfront_sessions)) == 1
        fUStemp(file).Parameters.Plane = Pfront;
    elseif sum(strcmp(FILES(file).session,Pback_sessions)) == 1
        fUStemp(file).Parameters.Plane = Pback;
    else
        fUStemp(file).Parameters.Plane = Pdefault;
    end    
    
    % define the voltage applied
    Vdefault = '15 V'; Vhigh = '25 V'; Vlow = '8 V';
    Vlow_sessions = {'20201209_SD113_MySession';'20201210_SD113_MySession';'20201211_SD111_MySession';'20201213_SD111_MySession';'20201215_SD111_MySession';'20201217_SD113_MySession';'20210216_SD132_MySession';'20210216_SD131_MySession';'20210217_SD131_MySession';'20210218_SD132_MySession';'20210218_SD131_MySession';'20210219_SD132_MySession'};
    Vhigh_sessions = {'20201207_SD113_MySession';'20201208_SD113_MySession';'20201212_SD111_MySession';'20201214_SD111_MySession';'20201216_SD113_MySession';'20201218_SD111_MySession';'20210212_SD132_MySession';'20210212_SD131_MySession';'20210214_SD131_MySession';'20210214_SD132_MySession';'20210215_SD131_MySession';'20210215_SD132_MySession'};
    
    if sum(strcmp(FILES(file).session,Vlow_sessions)) == 1
        fUStemp(file).Parameters.Voltage = Vlow;
    elseif sum(strcmp(FILES(file).session,Vhigh_sessions)) == 1
        fUStemp(file).Parameters.Voltage = Vhigh;
    else
        fUStemp(file).Parameters.Voltage = Vdefault;
    end
    
%   timing info
    % adding the temporal information on each recording
    folder = 'F:\Antoine\OneDrive - McGill University\Antoine-fUSDataset\DATA';
    try
    % start time
    FileInfo = dir(fullfile(folder,FILES(file).parent,FILES(file).session,FILES(file).recording,FILES(file).dir_lfp,'*.ccf'));
    test = regexp(FileInfo.date,' ','split');
    fUStemp(file).TimingInfo.Start = test{1,2};
    catch
        disp(['no start time available in file ',fUStemp(file).File])
    end
    % end time
    try
    FileInfo = dir(fullfile(folder,FILES(file).session,FILES(file).recording,FILES(file).dir_lfp,'*.ns5'));
    test = regexp(FileInfo.date,' ','split');
    fUStemp(file).TimingInfo.End = test{1,2};
    catch
        disp(['no end time available in file ',fUStemp(file).File])
    end
    
    % length rec images
    maxbuf = [];
    for h = 1:size(tg.TimeGroups_S,1)
        maxbuf(h) = max(tg.TimeGroups_S(h).TimeTags_images(:,2));
    end
    lengthREC = max(maxbuf);
    fUStemp(file).TimingInfo.TotalImages = lengthREC;
    
%   AW 
    ind = find(strcmp(tg.TimeGroups_name,'AW'));
    fUStemp(file).Indices.AW = zeros(1,lengthREC);
    if ind
        for i = 1:size(tg.TimeGroups_S(ind).TimeTags_strings,1)
            txt1 = tg.TimeGroups_S(ind).TimeTags_strings{i,1}; splitStr1 = regexp(txt1,':','split');
            txt2 = tg.TimeGroups_S(ind).TimeTags_strings{i,2}; splitStr2 = regexp(txt2,':','split');
            X1 = [str2num(cell2mat(splitStr1(1))) str2num(cell2mat(splitStr1(2))) str2num(cell2mat(splitStr1(3)))];
            X2 = [str2num(cell2mat(splitStr2(1))) str2num(cell2mat(splitStr2(2))) str2num(cell2mat(splitStr2(3)))];
            fUStemp(file).Times.AW(i,1) = duration(X1,'Format','hh:mm:ss');
            fUStemp(file).Times.AW(i,2) = duration(X2,'Format','hh:mm:ss');
            
            fUStemp(file).Indices.AW(1,tg.TimeGroups_S(ind).TimeTags_images(i,1):tg.TimeGroups_S(ind).TimeTags_images(i,2)) = 1;
            
        end
        for j = 1:size(fUStemp(file).Times.AW,1)
            fUStemp(file).Durations.AW(j,1) = fUStemp(file).Times.AW(j,2)-fUStemp(file).Times.AW(j,1);
        end
        fUStemp(file).Durations.TotalAW = sum(fUStemp(file).Durations.AW);
    else
        disp(['no AW in file ',fUStemp(file).File])
        fUStemp(file).Durations.TotalAW = duration([0 0 0],'Format','hh:mm:ss');
    end
    
%   QW
    ind = find(strcmp(tg.TimeGroups_name,'QW'));
    fUStemp(file).Indices.QW = zeros(1,lengthREC);
    if ind
        for i = 1:size(tg.TimeGroups_S(ind).TimeTags_strings,1)
            txt1 = tg.TimeGroups_S(ind).TimeTags_strings{i,1}; splitStr1 = regexp(txt1,':','split');
            txt2 = tg.TimeGroups_S(ind).TimeTags_strings{i,2}; splitStr2 = regexp(txt2,':','split');
            X1 = [str2num(cell2mat(splitStr1(1))) str2num(cell2mat(splitStr1(2))) str2num(cell2mat(splitStr1(3)))];
            X2 = [str2num(cell2mat(splitStr2(1))) str2num(cell2mat(splitStr2(2))) str2num(cell2mat(splitStr2(3)))];
            fUStemp(file).Times.QW(i,1) = duration(X1,'Format','hh:mm:ss');
            fUStemp(file).Times.QW(i,2) = duration(X2,'Format','hh:mm:ss');
            
            fUStemp(file).Indices.QW(1,tg.TimeGroups_S(ind).TimeTags_images(i,1):tg.TimeGroups_S(ind).TimeTags_images(i,2)) = 1;
            
        end
        for j = 1:size(fUStemp(file).Times.QW,1)
            fUStemp(file).Durations.QW(j,1) = fUStemp(file).Times.QW(j,2)-fUStemp(file).Times.QW(j,1);
        end
        fUStemp(file).Durations.TotalQW = sum(fUStemp(file).Durations.QW);
    else
        disp(['no QW in file ',fUStemp(file).File])
        fUStemp(file).Durations.TotalQW = duration([0 0 0],'Format','hh:mm:ss');
    end
    
%   NREM
    ind = find(strcmp(tg.TimeGroups_name,'NREM'));
    fUStemp(file).Indices.NREM = zeros(1,lengthREC);
    if ind
        for i = 1:size(tg.TimeGroups_S(ind).TimeTags_strings,1)
            txt1 = tg.TimeGroups_S(ind).TimeTags_strings{i,1}; splitStr1 = regexp(txt1,':','split');
            txt2 = tg.TimeGroups_S(ind).TimeTags_strings{i,2}; splitStr2 = regexp(txt2,':','split');
            X1 = [str2num(cell2mat(splitStr1(1))) str2num(cell2mat(splitStr1(2))) str2num(cell2mat(splitStr1(3)))];
            X2 = [str2num(cell2mat(splitStr2(1))) str2num(cell2mat(splitStr2(2))) str2num(cell2mat(splitStr2(3)))];
            fUStemp(file).Times.NREM(i,1) = duration(X1,'Format','hh:mm:ss');
            fUStemp(file).Times.NREM(i,2) = duration(X2,'Format','hh:mm:ss');
            
            fUStemp(file).Indices.NREM(1,tg.TimeGroups_S(ind).TimeTags_images(i,1):tg.TimeGroups_S(ind).TimeTags_images(i,2)) = 1;
 
        end
        for j = 1:size(fUStemp(file).Times.NREM,1)
            fUStemp(file).Durations.NREM(j,1) = fUStemp(file).Times.NREM(j,2)-fUStemp(file).Times.NREM(j,1);
        end
        fUStemp(file).Durations.TotalNREM = sum(fUStemp(file).Durations.NREM);
        
    else
        disp(['no NREM in file ',fUStemp(file).File])
        fUStemp(file).Durations.TotalNREM = duration([0 0 0],'Format','hh:mm:ss');
    end
    
%   REM
    ind = find(strcmp(tg.TimeGroups_name,'REM'));
    fUStemp(file).Indices.REM = zeros(1,lengthREC);
    if ind
        for i = 1:size(tg.TimeGroups_S(ind).TimeTags_strings,1)
            txt1 = tg.TimeGroups_S(ind).TimeTags_strings{i,1}; splitStr1 = regexp(txt1,':','split');
            txt2 = tg.TimeGroups_S(ind).TimeTags_strings{i,2}; splitStr2 = regexp(txt2,':','split');
            X1 = [str2num(cell2mat(splitStr1(1))) str2num(cell2mat(splitStr1(2))) str2num(cell2mat(splitStr1(3)))];
            X2 = [str2num(cell2mat(splitStr2(1))) str2num(cell2mat(splitStr2(2))) str2num(cell2mat(splitStr2(3)))];
            fUStemp(file).Times.REM(i,1) = duration(X1,'Format','hh:mm:ss');
            fUStemp(file).Times.REM(i,2) = duration(X2,'Format','hh:mm:ss');
            fUStemp(file).REMstats.Images(i,1) = tg.TimeGroups_S(ind).TimeTags_images(i,1);
            fUStemp(file).REMstats.Images(i,2) = tg.TimeGroups_S(ind).TimeTags_images(i,2);
            
            fUStemp(file).Indices.REM(1,fUStemp(file).REMstats.Images(i,1):fUStemp(file).REMstats.Images(i,2)) = 1;
        end
                
        for j = 1:size(fUStemp(file).Times.REM,1)
            fUStemp(file).Durations.REM(j,1) = fUStemp(file).Times.REM(j,2)-fUStemp(file).Times.REM(j,1);
        end
        fUStemp(file).Durations.TotalREM = sum(fUStemp(file).Durations.REM);
        
        fUStemp(file).REMstats.MeanDuration = mean(fUStemp(file).Durations.REM,'omitnan');
        fUStemp(file).REMstats.Number = size(fUStemp(file).Durations.REM,1);
        
        if size(tg.TimeGroups_S(ind).TimeTags_strings,1) > 1
            for k = 1:size(fUStemp(file).Times.REM,1)-1
                fUStemp(file).REMstats.InterDurations(k) = fUStemp(file).Times.REM(k+1,1) - fUStemp(file).Times.REM(k,2);
            end
            fUStemp(file).REMstats.MeanInterDurations = mean(fUStemp(file).REMstats.InterDurations);
        else
            fUStemp(file).REMstats.InterDurations = NaN;
        end
        
    else
        disp(['no REM in file ',fUStemp(file).File])
        fUStemp(file).Durations.TotalREM = duration([0 0 0],'Format','hh:mm:ss');
    end
    
    test = load(fullfile('F:\Antoine\OneDrive - McGill University\Antoine-fUSDataset\NEUROLAB\NLab_DATA',FILES(file).nlab,'Trace_light.mat'));
    ind = [];
    for k = 1 : size(test.traces,1)
        if strcmp('Index-REM',test.traces{k,1})
            ind = k;
        end
    end
    
    
%   total duration    
    fUStemp(file).TimingInfo.TotalDuration = sum(fUStemp(file).Durations.TotalAW)+sum(fUStemp(file).Durations.TotalQW)+sum(fUStemp(file).Durations.TotalNREM)+sum(fUStemp(file).Durations.TotalREM);
    
%   percentages
    fUStemp(file).Percentages.AW   = fUStemp(file).Durations.TotalAW   * 100 / fUStemp(file).TimingInfo.TotalDuration;
    fUStemp(file).Percentages.QW   = fUStemp(file).Durations.TotalQW   * 100 / fUStemp(file).TimingInfo.TotalDuration;
    fUStemp(file).Percentages.NREM = fUStemp(file).Durations.TotalNREM * 100 / fUStemp(file).TimingInfo.TotalDuration;
    fUStemp(file).Percentages.REM  = fUStemp(file).Durations.TotalREM  * 100 / fUStemp(file).TimingInfo.TotalDuration;
    
    fUStemp(file).Percentages.AWwake    = fUStemp(file).Durations.TotalAW   * 100 / (fUStemp(file).Durations.TotalAW   + fUStemp(file).Durations.TotalQW);
    fUStemp(file).Percentages.QWwake    = fUStemp(file).Durations.TotalQW   * 100 / (fUStemp(file).Durations.TotalAW   + fUStemp(file).Durations.TotalQW);
    fUStemp(file).Percentages.NREMsleep = fUStemp(file).Durations.TotalNREM * 100 / (fUStemp(file).Durations.TotalNREM + fUStemp(file).Durations.TotalREM);
    fUStemp(file).Percentages.REMsleep  = fUStemp(file).Durations.TotalREM  * 100 / (fUStemp(file).Durations.TotalNREM + fUStemp(file).Durations.TotalREM);
    
    fUStemp(file).Percentages.SLEEP = (fUStemp(file).Durations.TotalNREM + fUStemp(file).Durations.TotalREM) *100/ fUStemp(file).TimingInfo.TotalDuration;
    
    
    
%   temperature
    % adding the necessary information for thermistance analysis
    sleepscoring_dir = 'F:\Antoine\OneDrive - McGill University\Antoine-fUSDataset\NEUROLAB\NLab_Statistics\Sleep_Scoring\';
    nlab_dir = 'F:\Antoine\OneDrive - McGill University\Antoine-fUSDataset\NEUROLAB\NLab_DATA\';
    nlab_dir_bis = '_nlab\Sources_LFP';
    listing_ther = dir(fullfile(nlab_dir,[fUStemp(file).File,'_nlab\Sources_LFP']));
    for i=1:size(listing_ther,1)
        if contains(listing_ther(i).name,'THER')
            THER = listing_ther(i).name;
            fUStemp(file).Temperature.THER = load(fullfile(nlab_dir,[fUStemp(file).File,'_nlab\Sources_LFP'],THER));
        end
    end
    
end

%  corrections on/off
for file = [188,190,192,194,197,199,200,202,205,207,209,211,213,216,218,220,222,224,226,228,230,231,233,235,237,239,240]
    fUStemp(file).Parameters.ON_OFF = 'OFF';
end

folder_save = 'F:\Antoine\OneDrive - McGill University\Documents\MATLAB\NeuroLab\Scripts\article_brainheating';
save(fullfile(folder_save,'fUStemp.mat'),'fUStemp','-v7.3');
fprintf('File saved [%s].\n',fullfile(folder_save,'fUStemp.mat'));

end




























