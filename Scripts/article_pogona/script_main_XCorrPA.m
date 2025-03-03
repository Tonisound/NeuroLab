function script_main_XCorrPA(flag_recompute,flag_savefig,flag_perstate,to_compute)
% Script written by AB
% Article Pogona
% November 2024
% Browses NLab files
% Computes dynamics XCorr and AutoCorr for LFP channels and fUS regions
% Plots dynamics XCorr and AutoCorr
% Plots mean XCorr and AutoCorr per state

if nargin<1
    flag_recompute = true;     % if True (re)computes dynamic xcorr
end
if nargin<2
    flag_savefig = true;       % if True plots and saves dynamic xcorr
end
if nargin<3
    flag_perstate = true;      % if True (re)computes xcorr per state
end
if nargin<4
    to_compute = {'Pogona';'Mouse';'Rat'};      % if True (re)computes xcorr per state
end

load('Preferences.mat','GColors');

InfoFilePogo =[{'20190730_P1-003_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20190730_P1-004_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20190731_P1-005_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20190927_P3-016_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20190927_P3-017_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20190927_P3-018_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20190927_P3-019_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20190930_P3-020_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20190930_P3-021_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20190930_P3-022_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20191003_P3-027_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20191003_P3-028_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20191003_P3-029_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200715_P5-033_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200716_P5-034_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200716_P5-036_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200716_P5-037_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200716_P5-038_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200716_P5-039_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200717_P5-040_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200717_P6-041_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200717_P6-042_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200717_P6-043_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200718_P6-044_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200718_P6-045_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200719_P5-046_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200719_P5-047_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200720_P5-048_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200720_P5-049_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200721_P5-050_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200721_P5-051_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200722_P6-052_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200722_P6-053_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200723_P6-054_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200723_P6-055_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200724_P6-056_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200725_P5-058_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200726_P5-060_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};...
    {'20200726_P5-061_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'}];


InfoFileMouse =[{'20240812_K1653_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240812_K1653_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240812_K1654_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240812_K1654_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240813_K1653_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240813_K1653_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240813_K1654_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240813_K1654_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240814_K1653_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240814_K1653_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240814_K1654_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240814_K1654_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240820_K1656_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240820_K1656_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240820_K1657_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240820_K1657_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240822_K1656_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240822_K1656_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240822_K1657_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240822_K1657_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240826_K1656_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240826_K1656_003_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240826_K1657_001_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'};
    {'20240826_K1657_002_E_nlab'},{'Power-beta_999'},{'Power-theta_999'},{'Power-delta_999'}];


InfoFileRat =[{'20190226_SD025_P401_R_nlab'},{'Power-beta_023'},{'Power-theta_023'};...
    {'20190226_SD025_P402_R_nlab'},{'Power-beta_023'},{'Power-theta_023'};...
    {'20190416_SD032_P101_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P102_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P103_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P201_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P202_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P203_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P301_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P302_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P303_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P401_R_nlab'},{'Power-beta_005'},{'Power-theta_005'};...
    {'20190416_SD032_P402_R_nlab'},{'Power-beta_005'},{'Power-theta_005'}];


all_states = {'NREM','REM','AW','QW'};
seed_path = '/Volumes/DataMOBs203/';
% seed_path = '/media/hobbes/DataMOBs203';

% Default Parameters
ParamsDefault.all_states = all_states;  % States (must be Time Groups)
ParamsDefault.GColors = GColors;        % Display Colors
ParamsDefault.nCol = 8;                 % Number Max Columns
ParamsDefault.seed_nlab = fullfile(seed_path,'NEUROLAB','NLab_DATA');                       % File location
% ParamsDefault.seed_save = fullfile(seed_path,'XCorr');                                      % Save location
% ParamsDefault.pattern_compute_channel = {'Power-beta';'Power-theta';'Power-delta'};         % Channels to compute
% ParamsDefault.pattern_compute_region = {'*'};                                               % Regions to compute
% ParamsDefault.pattern_display_channel = {'Power-beta'};                                     % Channels to display
% ParamsDefault.pattern_display_region = {'Whole_reg'};                                       % Regions to display


% Specific Parameters
ParamsPogo = ParamsDefault;
ParamsPogo.Fs = 1;
ParamsPogo.WinSec = 300;
ParamsPogo.StepSec = 10;
ParamsPogo.MaxLagSec = 300;
ParamsPogo.NormWinMin = 3;
ParamsPogo.MinGroupDurSec = 300;
ParamsPogo.WinGroupSec = 300;
ParamsPogo.batchname = 'Pogona';
ParamsPogo.t_smooth = 20;
ParamsPogo.seed_save = fullfile(seed_path,'XCorr','XCorrPogo');
ParamsPogo.pattern_compute_channel = {'Power-beta_999';'Power-theta_999';'Power-delta_999'};
ParamsPogo.pattern_compute_region = {'Whole_reg';'dTel'};
ParamsPogo.pattern_display_channel = {'Power-beta_999';'Power-theta_999';'Power-delta_999'};
ParamsPogo.pattern_display_region = {'Whole_reg'};
ParamsPogo.all_states = {'SLEEP','WAKE'};
AllParamsPogo = ParamsPogo;

% % Batch Parameters
% ParamsPogo1 = ParamsPogo;
% ParamsPogo1.t_smooth = 30;
% ParamsPogo1.batchname = 'Pogona-30s';
% ParamsPogo1.seed_save = fullfile(seed_path,'XCorr','XCorrPogo[30s]');
% ParamsPogo2 = ParamsPogo;
% ParamsPogo2.t_smooth = 20;
% ParamsPogo2.batchname = 'Pogona-20s';
% ParamsPogo2.seed_save = fullfile(seed_path,'XCorr','XCorrPogo[20s]');
% ParamsPogo3 = ParamsPogo;
% ParamsPogo3.batchname = 'Pogona-10s';
% ParamsPogo3.t_smooth = 10;
% ParamsPogo3.seed_save = fullfile(seed_path,'XCorr','XCorrPogo[10s]');
% AllParamsPogo = [ParamsPogo1;ParamsPogo2;ParamsPogo3];


ParamsMouse= ParamsDefault;
ParamsMouse.Fs = 1;
ParamsMouse.WinSec = 180;
ParamsMouse.StepSec = 5;
ParamsMouse.MaxLagSec = 150;
ParamsMouse.NormWinMin = 3;
ParamsMouse.MinGroupDurSec = 100;
ParamsMouse.WinGroupSec = 100;
ParamsMouse.batchname = 'Mouse';
ParamsMouse.t_smooth = 10;
ParamsMouse.seed_save = fullfile(seed_path,'XCorr','XCorrMouse');
ParamsMouse.pattern_compute_channel = {'Power-beta_999';'Power-theta_999';'Power-delta_999'};
ParamsMouse.pattern_compute_region = {'Whole-reg'}; % ;'HPC';'CTX';'THAL'
ParamsMouse.pattern_display_channel = {'Power-beta_999';'Power-theta_999';'Power-delta_999'};
ParamsMouse.pattern_display_region = {'Whole-reg'}; % ;'HPC';'CTX';'THAL'
ParamsMouse.all_states = {'NREM','REM','WAKE'};
% ParamsMouse.all_states = {'NREM','REM','AW','QW','SLEEP','WAKE'};
AllParamsMouse = ParamsMouse;


% % Batch Parameters
% ParamsMouse1 = ParamsMouse;
% ParamsMouse1.batchname = 'Mouse-20s';
% ParamsMouse1.t_smooth = 20;
% ParamsMouse1.seed_save = fullfile(seed_path,'XCorr','XCorrMouse[20s]');
% ParamsMouse2 = ParamsMouse;
% ParamsMouse2.batchname = 'Mouse-10s';
% ParamsMouse2.t_smooth = 10;
% ParamsMouse2.seed_save = fullfile(seed_path,'XCorr','XCorrMouse[10s]');
% ParamsMouse3 = ParamsMouse;
% ParamsMouse3.batchname = 'Mouse-5s';
% ParamsMouse3.t_smooth = 5;
% ParamsMouse3.seed_save = fullfile(seed_path,'XCorr','XCorrMouse[5s]');
% ParamsMouse4 = ParamsMouse;
% ParamsMouse4.batchname = 'Mouse-Norm=3';
% ParamsMouse4.NormWinMin = 3;
% ParamsMouse4.seed_save = fullfile(seed_path,'XCorr','XCorrMouse[Norm=3]');
% ParamsMouse5 = ParamsMouse;
% ParamsMouse5.batchname = 'Mouse-Norm=5';
% ParamsMouse5.NormWinMin = 5;
% ParamsMouse5.seed_save =  fullfile(seed_path,'XCorr','XCorrMouse[Norm=5]');
% ParamsMouse6 = ParamsMouse;
% ParamsMouse6.batchname = 'WinSec=120';
% ParamsMouse6.NormWinMin = 2;
% ParamsMouse.WinSec = 120;
% ParamsMouse6.seed_save =  fullfile(seed_path,'XCorr','XCorrMouse[Norm=2.5]');
% AllParamsMouse = ParamsMouse6;
% AllParamsMouse = [ParamsMouse1;ParamsMouse2;ParamsMouse3;ParamsMouse4;ParamsMouse5];


ParamsRat = ParamsMouse;
ParamsRat.seed_save = fullfile(seed_path,'XCorr','XCorrRat');
ParamsRat.batchname = 'Rat';
ParamsRat.pattern_display_channel = {'Power-beta'};
ParamsRat.pattern_display_region = {'[SR]'};
ParamsRat.all_states = {'NREM','REM','AW','QW'};


% Main Loop
for i = 1:length(to_compute)

    switch char(to_compute(i))
        case 'Pogona'
            AllParams = AllParamsPogo;
            InfoFile = InfoFilePogo;
        case 'Mouse'
            AllParams = AllParamsMouse;
            InfoFile = InfoFileMouse;
        case 'Rat'
            AllParams = ParamsRat;
            InfoFile = InfoFileRat;
        otherwise
            warning('Unrecognized Species to compute [%s]',char(to_compute(i)));
            continue;
    end

    fprintf('============================== START (%s) ==============================\n',char(to_compute(i)));

    for j=1: length(AllParams)
        Params = AllParams(j);
        % Compute and Plot Dynamic Xcorr Mouse
        if flag_recompute
            compute_dynamic_xcorr(Params,InfoFile(:,1));
            for k = 2%:size(InfoFile,2)
                compute_dynamic_xcorr(Params,InfoFile(:,1),InfoFile(:,k));
            end
        end
        if flag_savefig
            plot_dynamic_xcorr(Params,InfoFile(:,1));
            for k = 2%:size(InfoFile,2)
                plot_dynamic_xcorr(Params,InfoFile(:,1),InfoFile(:,k));
            end
        end
        if flag_perstate
            plot_autocorr_per_group(Params,InfoFile(:,1));
            for k = 2%:size(InfoFile,2)
                plot_autocorr_per_group(Params,InfoFile(:,1),InfoFile(:,k));
            end
        end
    end
    fprintf('============================== END (%s) ==============================\n',char(to_compute(i)));
end

end


function compute_dynamic_xcorr(Params,all_files,all_refs)

if nargin < 3 || isempty(all_refs)
    flag_crosscorr = false;
else
    flag_crosscorr = true;
end

% Parameters
Fs = Params.Fs;
t_smooth = Params.t_smooth;
WinSec = Params.WinSec;
StepSec = Params.StepSec;
MaxLagSec = Params.MaxLagSec;
NormWinMin = Params.NormWinMin;
seed_save = Params.seed_save;
seed_nlab = Params.seed_nlab;

% Gaussian window
w = gausswin(round(2*Fs*t_smooth));
w = (w/sum(w))';

for k=1:length(all_files)

    % Getting file info
    cur_file = char(all_files(k));
    filepath = fullfile(seed_nlab,cur_file);
    temp = regexp(cur_file,'_','split');
    temp2 = regexp(char(temp(2)),'-','split');
    cur_animal = char(temp2(1));
    folder_save = fullfile(seed_save,cur_animal,'_mat');

    % Getting time
    data_t = load(fullfile(filepath,'Time_Reference.mat'));
    t_start = round(data_t.time_ref.Y(1));
    t_end = round(data_t.time_ref.Y(end));
    TimeData = t_start:1/Fs:t_end;

    % Selecting channels
    % pattern_channel = {'Power-beta';'Power-theta'};
    pattern_channel = Params.pattern_compute_channel;
    if sum(contains(pattern_channel,{'*'}))>0
        d_channels = dir(fullfile(filepath,'Sources_LFP','*.mat'));
    else
        d_channels = [];
        for i=1:length(pattern_channel)
            cur_pattern = char(pattern_channel(i));
            d_channels = [d_channels;dir(fullfile(filepath,'Sources_LFP',sprintf('*%s*.mat',cur_pattern)))];
        end
    end
    d_channels = d_channels(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_channels));
    all_channels = unique({d_channels(:).name}');
    nChannels = size(all_channels,1);

    % Selecting regions
    % pattern_region = {'*'};         % select all regions
    pattern_region = Params.pattern_compute_region;
    if sum(contains(pattern_region,{'*'}))>0
        d_regions = dir(fullfile(filepath,'Sources_fUS','*.mat'));
    else
        d_regions = [];
        for i=1:length(pattern_region)
            cur_pattern = char(pattern_region(i));
            d_regions = [d_regions;dir(fullfile(filepath,'Sources_fUS',sprintf('*%s*.mat',cur_pattern)))];
        end
    end
    d_regions = d_regions(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_regions));
    all_regions = unique({d_regions(:).name}');
    nRegions = size(all_regions,1);
    nTot = nChannels+nRegions;

    % Building DataRef
    if flag_crosscorr
        reference = char(all_refs(k));
        d_ref = dir(fullfile(filepath,'Sources_LFP',[reference,'.mat']));
        % Loading reference for xcorr
        if length(d_ref)==1
            data_ref = load(fullfile(d_ref.folder,d_ref.name));
            v = data_ref.Y(:)';
            x = data_ref.x_start:data_ref.f:data_ref.x_end;
            DataRef = interp1(x,v,TimeData);
            % Smoothing
            DataRef = nanconv(DataRef,w,'same');
        else
            warning('Missing reference channel [%s][%s]',cur_file,reference);
            continue;
        end
    else
        DataRef = [];
        reference = [];
    end


    % Computing xcorr
    % XCorrMat_Channels = NaN(length(TWin),length(2*WinSec+1),nChannels);
    XCorrMat_Channels = [];
    thisPos_Channels = [];
    thisNeg_Channels = [];
    XCorrPeak_Channels = struct('MeanXcorr',[],'Pos',[],'Neg',[]);
    Data_Channels = NaN(nChannels,size(TimeData,2));

    for i=1:nChannels

        % Loading Channel
        channel = char(all_channels(i));
        data_channel = load(fullfile(filepath,'Sources_LFP',channel));
        v = data_channel.Y(:)';
        x = data_channel.x_start:data_channel.f:data_channel.x_end;
        Data = interp1(x,v,TimeData);
        % Smoothing
        DataSmooth = nanconv(Data,w,'same');
        Data2 = [DataSmooth;DataRef];

        [TLag,TWin,XCorrMat,XCorrPeak,thisPos,thisNeg]=XCorrPA(Data2,Fs,WinSec,StepSec,MaxLagSec,NormWinMin);
        if ~flag_crosscorr
            fprintf('AutoCorrelation computed for channel [%s].\n',channel);
        else
            fprintf('Cross-Correlation computed for channel [%s].\n',channel);
        end

        % XCorrMat_Channels(:,:,i) = XCorrMat;
        XCorrMat_Channels = cat(3,XCorrMat_Channels,XCorrMat);
        thisPos_Channels = cat(3,thisPos_Channels,thisPos);
        thisNeg_Channels = cat(3,thisNeg_Channels,thisNeg);
        XCorrPeak_Channels(i) = XCorrPeak;
        Data_Channels(i,:) = DataSmooth;
    end

    % XCorrMat_Regions = NaN(length(TWin),length(2*WinSec+1),nRegions);
    XCorrMat_Regions = [];
    thisPos_Regions = [];
    thisNeg_Regions = [];
    XCorrPeak_Regions = struct('MeanXcorr',[],'Pos',[],'Neg',[]);
    Data_Regions = NaN(nRegions,size(TimeData,2));

    for i=1:nRegions

        % Loading Region
        region=char(all_regions(i));
        data_region = load(fullfile(filepath,'Sources_fUS',region));
        v = data_region.Y(:)';
        x = data_region.X(:)';
        Data = interp1(x,v,TimeData);
        % Smoothing
        DataSmooth = nanconv(Data,w,'same');
        Data2 = [DataSmooth;DataRef];

        [TLag,TWin,XCorrMat,XCorrPeak,thisPos,thisNeg]=XCorrPA(Data2,Fs,WinSec,StepSec,MaxLagSec,NormWinMin);
        if ~flag_crosscorr
            fprintf('AutoCorrelation computed for channel [%s].\n',region);
        else
            fprintf('Cross-Correlation computed for channel [%s].\n',region);
        end

        % XCorrMat_Regions(:,:,nRegions+i) = XCorrMat;
        XCorrMat_Regions = cat(3,XCorrMat_Regions,XCorrMat);
        thisPos_Regions = cat(3,thisPos_Regions,thisPos);
        thisNeg_Regions = cat(3,thisNeg_Regions,thisNeg);
        XCorrPeak_Regions(i)=XCorrPeak;
        Data_Regions(i,:) = DataSmooth;
    end

    % Saving Data
    if ~isfolder(folder_save)
        mkdir(folder_save)
    end
    Params.TLag = TLag;
    Params.TWin = TWin;

    XCorrMat_ydata = (TWin+WinSec/2+TimeData(1));
    XCorrMat_xdata = TLag;

    if ~flag_crosscorr
        mat_name = strcat('[ACorr]',cur_file,'.mat');
    else
        mat_name = strcat('[XCorr]',cur_file,sprintf('[%s].mat',reference));
    end
    fprintf('Saving data [%s]...',fullfile(folder_save,mat_name));
    save(fullfile(folder_save,mat_name),'Params','all_regions','all_channels','reference',...,
        'XCorrMat_Regions','XCorrPeak_Regions','XCorrMat_Channels','XCorrPeak_Channels',...
        'XCorrMat_xdata','XCorrMat_ydata',...
        'thisPos_Channels','thisNeg_Channels','thisPos_Regions','thisNeg_Regions',...
        'TimeData','Data_Channels','Data_Regions','DataRef','-v7.3');
    fprintf(' done.\n');
end

end


function plot_dynamic_xcorr(Params,all_files,all_refs)

if nargin < 3 || isempty(all_refs)
    flag_crosscorr = false;
else
    flag_crosscorr = true;
end

% Parameters
all_states = Params.all_states;
GColors = Params.GColors;
Fs = Params.Fs;
WinSec = Params.WinSec;
StepSec = Params.StepSec;
% MaxLagSec = Params.MaxLagSec;
NormWinMin = Params.NormWinMin;
WinGroupSec = Params.WinGroupSec;
MinGroupDurSec = Params.MinGroupDurSec;

seed_save = Params.seed_save;
seed_nlab = Params.seed_nlab;
nCol = Params.nCol; % Number Max Columns
pattern_channel = Params.pattern_display_channel;
pattern_region  = Params.pattern_display_region ;


for k=1:length(all_files)

    % Getting file info
    cur_file = char(all_files(k));
    filepath = fullfile(seed_nlab,cur_file);
    temp = regexp(cur_file,'_','split');
    temp2 = regexp(char(temp(2)),'-','split');
    cur_animal = char(temp2(1));
    folder_save = fullfile(seed_save,cur_animal);
    folder_save_mat = fullfile(seed_save,cur_animal,'_mat');

    % Getting time
    data_t = load(fullfile(filepath,'Time_Reference.mat'));
    t_start = round(data_t.time_ref.Y(1));
    t_end = round(data_t.time_ref.Y(end));
    TimeData = t_start:1/Fs:t_end;

    % Getting time groups
    data_tg = load(fullfile(filepath,'Time_Groups.mat'));


    % Selecting channels
    if sum(contains(pattern_channel,{'*'}))>0
        d_channels = dir(fullfile(filepath,'Sources_LFP','*.mat'));
    else
        d_channels = [];
        for i=1:length(pattern_channel)
            cur_pattern = char(pattern_channel(i));
            d_channels = [d_channels;dir(fullfile(filepath,'Sources_LFP',sprintf('*%s*.mat',cur_pattern)))];
        end
    end
    d_channels = d_channels(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_channels));
    ind_channels = 1:length(d_channels);
    %     ind_channels = (1:4);
    all_channels = unique({d_channels(ind_channels).name}');
    nChannels = size(all_channels,1);

    % Selecting regions
    if sum(contains(pattern_region,{'*'}))>0
        d_regions = dir(fullfile(filepath,'Sources_fUS','*.mat'));
    else
        d_regions = [];
        for i=1:length(pattern_region)
            cur_pattern = char(pattern_region(i));
            d_regions = [d_regions;dir(fullfile(filepath,'Sources_fUS',sprintf('*%s*.mat',cur_pattern)))];
        end
    end
    d_regions = d_regions(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_regions));
    ind_regions = 1:length(d_regions);
    % ind_channels = (1:4);
    all_regions = unique({d_regions(ind_regions).name}');
    nRegions = size(all_regions,1);
    nTot = nChannels+nRegions;

    % Selecting reference
    if flag_crosscorr
        reference = char(all_refs(k));
        d_ref = dir(fullfile(filepath,'Sources_LFP',[reference,'.mat']));
        % Loading reference for xcorr
        if length(d_ref)==1
            data_ref = load(fullfile(filepath,'Sources_LFP',d_ref.name));
            v = data_ref.Y(:)';
            x = data_ref.x_start:data_ref.f:data_ref.x_end;
            DataRef = interp1(x,v,TimeData);
        else
            warning('Missing reference channel [%s]',filepath);
            continue;
        end
    else
        DataRef = [];
        reference = [];
    end

    % Saving Figure
    % Locating Data
    if ~flag_crosscorr
        mat_name = strcat('[ACorr]',cur_file,'.mat');
    else
        mat_name = strcat('[XCorr]',cur_file,sprintf('[%s].mat',reference));
    end

    % Continue if mat_name not found
    if ~isfile(fullfile(folder_save_mat,mat_name))
        warning('Missing data file [%s]',fullfile(folder_save_mat,mat_name));
        continue;
    end

    % Loading file
    fprintf('Loading data [%s]...',fullfile(folder_save_mat,mat_name));
    data_mat = load(fullfile(folder_save_mat,mat_name));

    Params = data_mat.Params;
    TLag=Params.TLag;
    TWin=Params.TWin;

    XCorrMat_all = rand(length(TWin),length(TLag),nTot);
    thisPos_all = rand(length(TWin),2,nTot);
    thisNeg_all = rand(length(TWin),2,nTot);
    XCorrPeak_all = struct('MeanXcorr',[],'Pos',[],'Neg',[]);
    Data_Channels = rand(nChannels,length(TimeData));
    for j=1:length(all_channels)
        index_channel = find(strcmp(data_mat.all_channels,all_channels(j))==1);
        XCorrMat_all(:,:,j) = data_mat.XCorrMat_Channels(:,:,index_channel);
        XCorrPeak_all(j) = data_mat.XCorrPeak_Channels(index_channel);
        Data_Channels(j,:) = data_mat.Data_Channels(index_channel,:);
        thisPos_all(:,:,j) = data_mat.thisPos_Channels(:,:,index_channel);
        thisNeg_all(:,:,j) = data_mat.thisNeg_Channels(:,:,index_channel);
    end
    Data_Regions = NaN(nChannels,length(TimeData));
    for j=1:length(all_regions)
        index_region = find(strcmp(data_mat.all_regions,all_regions(j))==1);
        if isempty(index_region)
            warning('Region not found [%s - %s]',char(all_regions(j)),cur_file);
            XCorrPeak_all(nChannels+j).MeanXcorr = rand(1,size(data_mat.XCorrPeak_Regions(1).MeanXcorr,2));
            XCorrPeak_all(nChannels+j).Pos = rand(1,2);
            XCorrPeak_all(nChannels+j).Neg = XCorrPeak_all(nChannels+j).Pos-0.5;
        else
            XCorrMat_all(:,:,nChannels+j) = data_mat.XCorrMat_Regions(:,:,index_region);
            XCorrPeak_all(nChannels+j) = data_mat.XCorrPeak_Regions(index_region);
            Data_Regions(j,:) = data_mat.Data_Regions(index_region,:);
            thisPos_all(:,:,nChannels+j) = data_mat.thisPos_Regions(:,:,index_region);
            thisNeg_all(:,:,nChannels+j) = data_mat.thisNeg_Regions(:,:,index_region);
        end
    end

    Data_all = [Data_Channels;Data_Regions];
    fprintf(' done.\n');
    TimeData = data_mat.TimeData;

    all_labels = [];
    for i=1:nChannels
        channel=char(all_channels(i));
        label = regexprep(channel,'.mat','');
        label = regexprep(label,'_','-');
        all_labels = [all_labels;{label}];
    end
    for i=1:nRegions
        region=char(all_regions(i));
        label = regexprep(region,'.mat','');
        label = regexprep(label,'_','-');
        all_labels = [all_labels;{label}];
    end

    % Saving figure
    if ~isfolder(folder_save)
        mkdir(folder_save)
    end

    % Plotting only if flag_savefig is True
    % Prepare plot
    nFigs = ceil(nTot/nCol);
    all_f = gobjects(nFigs);
    all_ax = gobjects(4,nTot);

    % Figures
    for index_fig = 1:nFigs
        all_f(index_fig) = figure;
        if ~flag_crosscorr
            all_f(index_fig).Name = sprintf('[ACorr]%s-%03d',cur_file,index_fig);
        else
            all_f(index_fig).Name = sprintf('[XCorr][%s]%s-%03d',reference,cur_file,index_fig);
        end
    end
    count = 1;
    eps = .01;
    % Axes
    for i=1:nTot
        framepos = [(count-1)/nCol+2*eps  .025  1/nCol-eps  .95];
        all_ax(1,i) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)  framepos(2)+.25  0.75*framepos(3)   .7]);
        all_ax(2,i) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+0.75*framepos(3)  framepos(2)+.25  0.25*framepos(3)   .7]);
        all_ax(3,i) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)  framepos(2)+.125  0.75*framepos(3)   .1]);
        all_ax(4,i) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)  framepos(2)  0.75*framepos(3)   .1]);
        count=mod(count,nCol)+1;
    end

    % plot  map and mean xcorr with peaks
    for i=1:nTot
        label=char(all_labels(i));
        XCorrMat = XCorrMat_all(:,:,i);
        XCorrPeak = XCorrPeak_all(i);
        time_ticks = (900:900:TimeData(end))';
        time_ticks_label = datestr(time_ticks/(24*3600),'HH:MM');

        ax1=all_ax(1,i);
        % p = pcolor(TLag,TWin,XCorrMat,'Parent',ax1);
        % shading(ax1,'flat');
        YTime = (TWin+WinSec/2+TimeData(1));
        imagesc('XData',TLag,'YData',YTime,'CData',XCorrMat,'Parent',ax1);
        % Adding peaks
        line('XData',thisPos_all(:,1,i),'YData',YTime,'LineStyle','none','Parent',ax1,...
            'Marker','o','MarkerSize',3,'MarkerFaceColor','r','MarkerEdgeColor','none');
        line('XData',thisNeg_all(:,1,i),'YData',YTime,'LineStyle','none','Parent',ax1,...
            'Marker','o','MarkerSize',3,'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor','none');

        % ax1.YLim = [YTime(1),YTime(end)];
        ax1.YLim = [TimeData(1),TimeData(end)];
        ax1.CLim = [-.5 1];
        ax1.YDir = 'reverse';
        set(ax1,'YTick',time_ticks,'YTickLabel',time_ticks_label);
        ax1.XLim = [TLag(1),TLag(end)];
        ax1.Title.String = label;

        ax2=all_ax(2,i);
        line('XData',Data_all(i,:),'YData',TimeData,'Color','k','Parent',ax2);
        % Display normalized data
        if ~isempty(NormWinMin)
            NormData = (Data_all(i,:)-movmean(Data_all(i,:),NormWinMin*60*Fs))./movstd(Data_all(i,:),NormWinMin*60*Fs);
            NormDataScale = rescale(NormData,min(Data_all(i,:),[],'omitnan'),max(Data_all(i,:),[],'omitnan'));
            line('XData',NormDataScale,'YData',TimeData,'Color','r','Parent',ax2);
        end

        if sum(~isnan(Data_all(i,:)))>0
            ax2.XLim = [mean(Data_all(i,:),'omitnan')-2.5*std(Data_all(i,:),[],'omitnan') mean(Data_all(i,:),'omitnan')+15*std(Data_all(i,:),[],'omitnan')];
        else
            ax2.XLim = [-1,1];
        end
        ax2.YLim = [TimeData(1),TimeData(end)];
        ax2.YDir = 'reverse';
        set(ax2,'YTick',time_ticks,'YTickLabel','');

        % Time Patches
        for index = 1:length(GColors.TimeGroups)
            name = char(GColors.TimeGroups(index).Name);
            if sum(strcmp(all_states,name))>0 && sum(strcmp(data_tg.TimeGroups_name,name))>0
                %create patch
                index_group = find(strcmp(data_tg.TimeGroups_name,name)==1);
                a = datenum(data_tg.TimeGroups_S(index_group).TimeTags_strings(:,1));
                b = datenum(data_tg.TimeGroups_S(index_group).TimeTags_strings(:,2));
                ydata = [(a-floor(a))*24*3600,(b-floor(b))*24*3600];
                for j = 1:size(ydata,1)
                    p = patch('XData',[ax2.XLim(1) ax2.XLim(1) ax2.XLim(2) ax2.XLim(2)],...
                        'YData',[ydata(j,1) ydata(j,2) ydata(j,2) ydata(j,1)],...
                        'Parent',ax2,'Tag','TimePatch');
                    p.EdgeColor = 'none';
                    p.FaceColor = GColors.TimeGroups(index).Color;
                    p.FaceAlpha = GColors.TimeGroups(index).Transparency;
                end
            end
        end

        % Mean Autocorr
        ax3 = all_ax(3,i);
        grid(ax3,'on');
        ax3.YLim = [-.5 1];
        ax3.XLim = [TLag(1) TLag(end)];

        % Scatter Plot
        ax4 = all_ax(4,i);
        grid(ax4,'on');
        ax4.XLim = [TLag(1) TLag(end)];
        ax4.XLabel.String = 'Lag';
        ax4.YLabel.String = 'XCorr Amp';
        if ~flag_crosscorr
            ax4.YLim = [0 1.5];
        else
            ax4.YLim = [0 1];
        end
        hold(ax4,'on');

        flag_plot_mean = false;
        if flag_plot_mean
            % if True mean across states

            line('XData',TLag,'YData',XCorrPeak.MeanXcorr,'Parent',ax3);
            line('XData',XCorrPeak.Pos(1),'YData',XCorrPeak.Pos(2),'Marker','o','Color','r','Parent',ax3);
            line('XData',XCorrPeak.Neg(1),'YData',XCorrPeak.Neg(2),'Marker','x','Color','r','Parent',ax3);
            text(-MaxLagSec,ax3.YLim(2)-.25,sprintf('Amp=%.2f',XCorrPeak.Pos(2)-XCorrPeak.Neg(2)),'Parent',ax3);
            text(-MaxLagSec,ax3.YLim(2)-.1,sprintf('Lag=%dsec',XCorrPeak.Pos(1)),'Parent',ax3);

            if ~flag_crosscorr
                line('XData',thisPos_all(:,1,i),'YData',thisPos_all(:,2,i)-thisNeg_all(:,2,i),'Parent',ax4,...
                    'LineStyle','none','MarkerFaceColor','k','MarkerEdgeColor','none','Marker','o','MarkerSize',2);
            else
                line('XData',thisPos_all(:,1,i),'YData',thisPos_all(:,2,i),'Parent',ax4,...
                    'LineStyle','none','MarkerFaceColor','k','MarkerEdgeColor','none','Marker','o','MarkerSize',2);
            end

        else
            % else mean per state

            all_lines = [];
            count_leg = 0 ;
            for j=1:length(all_states)

                cur_state = char(all_states(j));
                index_group = find(strcmp(data_tg.TimeGroups_name,cur_state)==1);

                if isempty(index_group)
                    continue;
                end

                index_color = find(strcmp({GColors.TimeGroups(:).Name}',cur_state)==1);
                cur_color = GColors.TimeGroups(index_color).Color;

                % Converting times
                a = datenum(data_tg.TimeGroups_S(index_group).TimeTags_strings(:,1));
                b = datenum(data_tg.TimeGroups_S(index_group).TimeTags_strings(:,2));
                Time_indices = [(a-floor(a))*24*3600,(b-floor(b))*24*3600];

                % Keeping only long bouts
                all_times = [];
                ind_long_bouts = find(((Time_indices(:,2)-Time_indices(:,1))>= MinGroupDurSec)==1);

                for l = 1:length(ind_long_bouts)
                    times_keep = Time_indices(ind_long_bouts(l),1)+WinGroupSec/2 : WinGroupSec : Time_indices(ind_long_bouts(l),2);
                    all_times = [all_times;times_keep(:)];
                end
                index_keep_nt = [];
                for l = 1:length(all_times)
                    cur_time = all_times(l);
                    [~,index_nearest_time] = min(abs(YTime - cur_time));
                    nearest_time = YTime(index_nearest_time);
                    if abs(nearest_time-cur_time) <= StepSec/2
                        index_keep_nt = [index_keep_nt;index_nearest_time];
                    end
                end

                if ~isempty(index_keep_nt)
                    nKeep = length(index_keep_nt);

                    % Plotting correlogram per state
                    ACorr_mean = mean(XCorrMat(index_keep_nt,:),1,'omitnan');
                    ACorr_std = std(XCorrMat(index_keep_nt,:),[],1,'omitnan');
                    ACorr_sem = ACorr_std/sqrt(nKeep);

                    l = line('XData',TLag,'YData',ACorr_mean,'Color',cur_color,'Parent',ax3,...
                        'DisplayName',sprintf('%s(%d)',cur_state,nKeep));
                    px_data = [TLag,fliplr(TLag)];
                    py_data = [ACorr_mean+ACorr_sem,fliplr(ACorr_mean-ACorr_sem)];
                    patch('XData',px_data,'YData',py_data,'FaceColor',cur_color,'EdgeColor','none',...
                        'Parent',ax3,'Visible','on','FaceAlpha',.5);
                    %                     for l=1:nKeep
                    %                         line('XData',TLag,'YData',XCorrMat(index_keep_nt(l),:),'Color',cur_color,'Parent',ax3);
                    %                     end
                    all_lines = [all_lines;l];

                    % Plotting peaks per state
                    if ~flag_crosscorr

                        scatter(thisPos_all(index_keep_nt,1,i),thisPos_all(index_keep_nt,2,i)-thisNeg_all(index_keep_nt,2,i),'Parent',ax4,...
                            'MarkerFaceColor',cur_color,'MarkerEdgeColor','none','Marker','o','MarkerFaceAlpha',.5,...
                            'DisplayName',sprintf('%s(%d)',cur_state,nKeep));
                        l2 = line('XData',mean(thisPos_all(index_keep_nt,1,i),1,'omitnan'),'YData',mean(thisPos_all(index_keep_nt,2,i)-thisNeg_all(index_keep_nt,2,i),1,'omitnan'),'Parent',ax4,...
                            'LineWidth',1,'MarkerEdgeColor',cur_color,'Marker','+','MarkerSize',30);
                    else

                        scatter(thisPos_all(index_keep_nt,1,i),thisPos_all(index_keep_nt,2,i),'Parent',ax4,...
                            'MarkerFaceColor',cur_color,'MarkerEdgeColor','none','Marker','o','MarkerFaceAlpha',.5,...
                            'DisplayName',sprintf('%s(%d)]',cur_state,nKeep));
                        l2 = line('XData',mean(thisPos_all(index_keep_nt,1,i),1,'omitnan'),'YData',mean(thisPos_all(index_keep_nt,2,i),1,'omitnan'),'Parent',ax4,...
                            'LineWidth',1,'MarkerEdgeColor',cur_color,'Marker','+','MarkerSize',30);

                    end
                    count_leg = count_leg+1;
                    text(ax4.XLim(1)+.05*(ax4.XLim(2)-ax4.XLim(1)),ax4.YLim(2)-.15*count_leg,sprintf('%s (%.1f; %.2f)',cur_state,l2.XData,l2.YData),'Parent',ax4,'FontSize',9); %'Color',cur_color,

                end

            end
            legend(ax3,all_lines,'Location','northwest','FontSize',7,'Box','off');
        end

        count = count+1;
    end

    % Saving figure
    for index_fig = 1:nFigs
        f = all_f(index_fig);
        f.Units='normalized';
        f.OuterPosition = [0 0 1 1];
        pic_name = strcat(f.Name,'.pdf');
        fprintf('Saving figure [%s]...',fullfile(folder_save,pic_name));
        % Mac
        f.PaperPositionMode = 'manual';
        exportgraphics(f,fullfile(folder_save,pic_name),'ContentType','vector');
        % Ubuntu
        % saveas(f,fullfile(folder_save,pic_name),'pdf');
        fprintf(' done.\n');
        close(f);
    end

end

end


function S = plot_autocorr_per_group(Params,all_files,all_refs)

if nargin < 3 || isempty(all_refs)
    flag_crosscorr = false;
else
    flag_crosscorr = true;
end

% Parameters
% GColors = Params.GColors;
% Fs = Params.Fs;
batchname = Params.batchname;
nCol = Params.nCol;
% WinSec = Params.WinSec;
% StepSec = Params.StepSec;
% MaxLagSec = Params.MaxLagSec;
% NormWinMin = Params.NormWinMin;
MinGroupDurSec = Params.MinGroupDurSec;
WinGroupSec = Params.WinGroupSec;
seed_save = Params.seed_save;
seed_nlab = Params.seed_nlab;
pattern_region = Params.pattern_display_region;
pattern_channel = Params.pattern_display_channel;
all_states = Params.all_states;
nStates = length(all_states);


% Buidling Time_selection
TS = struct('all_times',[],'state',[],'animal',[],'acorr',[]);

for k=1:length(all_files)

    % Getting file info
    cur_file = char(all_files(k));
    filepath = fullfile(seed_nlab,cur_file);
    temp = regexp(cur_file,'_','split');
    temp2 = regexp(char(temp(2)),'-','split');
    cur_animal = char(temp2(1));

    % Getting time groups
    data_tg = load(fullfile(filepath,'Time_Groups.mat'));
    for j=1:length(all_states)
        cur_state = char(all_states(j));
        index_group = find(strcmp(data_tg.TimeGroups_name,cur_state)==1);

        if ~isempty(index_group)
            % Converting times
            a = datenum(data_tg.TimeGroups_S(index_group).TimeTags_strings(:,1));
            b = datenum(data_tg.TimeGroups_S(index_group).TimeTags_strings(:,2));
            Time_indices = [(a-floor(a))*24*3600,(b-floor(b))*24*3600];

            % Keeping only long bouts
            all_times = [];
            ind_long_bouts = find(((Time_indices(:,2)-Time_indices(:,1))>= MinGroupDurSec)==1);
            for l = 1:length(ind_long_bouts)
                times_keep = Time_indices(ind_long_bouts(l),1)+WinGroupSec/2 : WinGroupSec : Time_indices(ind_long_bouts(l),2);
                all_times = [all_times;times_keep(:)];
            end

            TS.all_times = [TS.all_times;all_times];
            TS.state = [TS.state;repmat({cur_state},[size(all_times,1),1])];
            TS.animal = [TS.animal;repmat({cur_animal},[size(all_times,1),1])];
            if ~flag_crosscorr
                mat_name_acorr = strcat('[ACorr]',cur_file,'.mat');
            else
                reference = char(all_refs(k));
                mat_name_acorr = strcat('[XCorr]',cur_file,sprintf('[%s].mat',reference));
            end

            TS.acorr = [TS.acorr;repmat({fullfile(seed_save,cur_animal,'_mat',mat_name_acorr)},[size(all_times,1),1])];
        end
    end
end


all_animals = unique(TS.animal);
% all_regions = {'Whole.mat'};

S = struct('ACorr',[],'ACorr_Lag',[],'ACorr_Amp',[],...
    'parentFile',[],'parentFolder',[],'target_time',[],'nearest_time',[],...
    'region',[],'channel',[],'trace',[],'state',[],'animal',[]);


prev_acorr = '';
nSelectedTimes = 0;
nSelectedSamples = 0;
csv_lines = [];

for k=1:length(TS.all_times)

    cur_time = TS.all_times(k);
    cur_state = char(TS.state(k));
    cur_animal = char(TS.animal(k));
    cur_acorr = char(TS.acorr(k));
    [parentFolder,parentFile,~] = fileparts(cur_acorr);

    % Loading autocorrelation
    if ~isfile(cur_acorr)
        warning('Impossible to load file [%s].',data_acorr);
        continue;
    else
        if ~strcmp(cur_acorr,prev_acorr)
            data_acorr = load(cur_acorr,...
                'all_regions','all_channels','XCorrMat_ydata','Params',...
                'XCorrMat_Regions','thisPos_Regions','thisNeg_Regions',...
                'XCorrMat_Channels','thisPos_Channels','thisNeg_Channels');
            if ~flag_crosscorr
                fprintf('Auto-correlation file loaded [%s].\n',cur_acorr);
            else
                fprintf('Cross-Correlation file loaded [%s].\n',cur_acorr);
            end
            prev_acorr = cur_acorr;
        end
    end

    % Selecting regions
    if sum(contains(pattern_region,{'*'}))>0
        index_regions = 1:length(data_acorr.all_regions);
    else
        index_regions = [];
        for i =1:length(pattern_region)
            cur_pattern = char(pattern_region(i));
            index_regions = [index_regions;find(contains(data_acorr.all_regions,cur_pattern)==1)];
        end
        index_regions = unique(index_regions);
    end
    % Selecting channels
    if sum(contains(pattern_channel,{'*'}))>0
        index_channels = 1:length(data_acorr.all_channels);
    else
        index_channels = [];
        for i =1:length(pattern_channel)
            cur_pattern = char(pattern_channel(i));
            index_channels = [index_channels;find(contains(data_acorr.all_channels,cur_pattern)==1)];
        end
        index_channels = unique(index_channels);
    end
    nChannels = length(index_channels);
    nRegions = length(index_regions);
    nTot = nChannels+nRegions;


    % Finding row
    [~,index_nearest_time] = min(abs(data_acorr.XCorrMat_ydata - cur_time));
    nearest_time = data_acorr.XCorrMat_ydata(index_nearest_time);

    if abs(nearest_time-cur_time) <= data_acorr.Params.StepSec/2

        % AutoCorr Region
        for i =1:nRegions
            ACorr = data_acorr.XCorrMat_Regions(index_nearest_time,:,index_regions(i));
            if ~flag_crosscorr
                ACorr_Lag = data_acorr.thisPos_Regions(index_nearest_time,1,index_regions(i));
                ACorr_Amp = data_acorr.thisPos_Regions(index_nearest_time,2,index_regions(i))-data_acorr.thisNeg_Regions(index_nearest_time,2,index_regions(i));
            else
                ACorr_Lag = data_acorr.thisPos_Regions(index_nearest_time,1,index_regions(i));
                ACorr_Amp = data_acorr.thisPos_Regions(index_nearest_time,2,index_regions(i));
            end

            % Storing
            S.ACorr = [S.ACorr;ACorr];
            S.ACorr_Lag = [S.ACorr_Lag;ACorr_Lag];
            S.ACorr_Amp = [S.ACorr_Amp;ACorr_Amp];
            S.state = [S.state;{cur_state}];
            S.animal = [S.animal;{cur_animal}];
            cur_trace = data_acorr.all_regions(index_regions(i));
            S.trace = [S.trace;cur_trace];
            S.region = [S.region;cur_trace];
            % S.channel = [S.channel;{''}];
            S.parentFile = [S.parentFile;{parentFile}];
            S.parentFolder = [S.parentFolder;{parentFolder}];
            S.target_time = [S.target_time;cur_time];
            S.nearest_time = [S.nearest_time;nearest_time];
            % csv_lines = [csv_lines;{sprintf('%s,%s,%s,%s,%s,%.3f,%.3f\n',parentFolder,parentFile,cur_state,cur_animal,cur_trace,cur_time,nearest_time)}];
        end
        nSelectedSamples = nSelectedSamples+nRegions;

        % AutoCorr Channel
        for i =1:nChannels
            ACorr = data_acorr.XCorrMat_Channels(index_nearest_time,:,index_channels(i));
            if ~flag_crosscorr
                ACorr_Lag = data_acorr.thisPos_Channels(index_nearest_time,1,index_channels(i));
                ACorr_Amp = data_acorr.thisPos_Channels(index_nearest_time,2,index_channels(i))-data_acorr.thisNeg_Channels(index_nearest_time,2,index_channels(i));
            else
                ACorr_Lag = data_acorr.thisPos_Channels(index_nearest_time,1,index_channels(i));
                ACorr_Amp = data_acorr.thisPos_Channels(index_nearest_time,2,index_channels(i));
            end

            % Storing
            S.ACorr = [S.ACorr;ACorr];
            S.ACorr_Lag = [S.ACorr_Lag;ACorr_Lag];
            S.ACorr_Amp = [S.ACorr_Amp;ACorr_Amp];
            S.state = [S.state;{cur_state}];
            S.animal = [S.animal;{cur_animal}];
            cur_trace = data_acorr.all_channels(index_channels(i));
            S.trace = [S.trace;cur_trace];
            % S.region = [S.region;{''}];
            S.channel = [S.channel;cur_trace];
            [parentFolder,parentFile,~] = fileparts(cur_acorr);
            S.parentFile = [S.parentFile;{parentFile}];
            S.parentFolder = [S.parentFolder;{parentFolder}];
            S.target_time = [S.target_time;cur_time];
            S.nearest_time = [S.nearest_time;nearest_time];
        end
        nSelectedSamples = nSelectedSamples+nChannels;
        % csv_lines = [csv_lines;{sprintf('%s,%s,%s,%s,%s,%.3f,%.3f\n',parentFolder,parentFile,cur_state,cur_animal,cur_trace,cur_time,nearest_time)}];
        
        nSelectedTimes = nSelectedTimes+1;
        csv_lines = [csv_lines;{sprintf('%s,%s,%s,%s,%.3f,%.3f\n',parentFolder,parentFile,cur_state,cur_animal,cur_time,nearest_time)}];
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Writing csv file
if ~flag_crosscorr
    filepath_csv = fullfile(seed_save,'_csv',sprintf('[%s]ACorr-per-state.csv',batchname));
else
    filepath_csv = fullfile(seed_save,'_csv',sprintf('[%s]XCorr-per-state[%s].csv',batchname,reference));
end
if ~isfolder(fullfile(seed_save,'_csv'))
    mkdir(fullfile(seed_save,'_csv'));
end
fid_csv = fopen(filepath_csv,'w');
fprintf(fid_csv,'%s',sprintf('ParentFolder,ParentName,State,Animal,TargetTime,NearestTime\n'));
for i = 1:length(csv_lines)
    fprintf(fid_csv,'%s',char(csv_lines(i)));
end
fclose(fid_csv);
fprintf('CSV File Saved [%s].\n',filepath_csv);


% all_traces = unique(S.trace);
all_traces = [unique(S.channel);unique(S.region)];
nTraces = length(all_traces);
all_animals = unique(TS.animal);
nAnimals = length(all_animals);
g_colors = get(groot,'defaultAxesColorOrder');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Writing txt file
meanMat = NaN(nStates,nAnimals,nTraces,2);
stdMat = NaN(nStates,nAnimals,nTraces,2);
semMat = NaN(nStates,nAnimals,nTraces,2);
nSamplesMat = NaN(nStates,nAnimals,nTraces,2);

for i=1:nStates
    cur_state = char(all_states(i));
    for j=1:nAnimals
        cur_animal = char(all_animals(j));
        for k=1:nTraces
            cur_trace = char(all_traces(k));

            index_keep = find((strcmp(S.state,cur_state).*strcmp(S.animal,cur_animal)).*strcmp(S.trace,cur_trace)==1);
            % Lags
            data = S.ACorr_Lag(index_keep);
            meanMat(i,j,k,1) = mean(data(:),'omitnan');
            nSamplesMat(i,j,k,1) = sum(~(isnan(data(:))));
            stdMat(i,j,k,1) = std(data(:),[],'omitnan');
            semMat(i,j,k,1) = stdMat(i,j,k,1)/sqrt(nSamplesMat(i,j,k,1));
            % XCorrAmp
            data = S.ACorr_Amp(index_keep);
            meanMat(i,j,k,2) = mean(data(:),'omitnan');
            nSamplesMat(i,j,k,2) = sum(~(isnan(data(:))));
            stdMat(i,j,k,2) = std(data(:),[],'omitnan');
            semMat(i,j,k,2) = stdMat(i,j,k,2)/sqrt(nSamplesMat(i,j,k,2));

        end
    end
end

% Writing Lags.txt
if ~flag_crosscorr
    filepath_txt = fullfile(seed_save,'_txt',sprintf('[%s]ACorr-Stats[Lags].txt',batchname));
else
    filepath_txt = fullfile(seed_save,'_txt',sprintf('[%s]XCorr-Stats[%s][Lags].txt',batchname,reference));
end
if ~isfolder(fullfile(seed_save,'_txt'))
    mkdir(fullfile(seed_save,'_txt'));
end
fid_txt = fopen(filepath_txt,'w');
for k=1:nTraces
    cur_trace = char(all_traces(k));
    fwrite(fid_txt,sprintf('%s \t', cur_trace));
    fwrite(fid_txt,newline);

    fwrite(fid_txt,sprintf('%s \t', 'Mean +- sem (s)'));
    for j=1:nAnimals
        cur_animal = char(all_animals(j));
        fwrite(fid_txt,sprintf('%s \t', cur_animal));
    end
    fwrite(fid_txt,newline);
    for i=1:nStates
        cur_state = char(all_states(i));
        fwrite(fid_txt,sprintf('%s \t',cur_state));
        for j=1:nAnimals
            fwrite(fid_txt,sprintf('%.3f +- %.3f (n=%d)\t',meanMat(i,j,k,1),semMat(i,j,k,1),nSamplesMat(i,j,k,1)));
        end
        fwrite(fid_txt,newline);
    end
    fwrite(fid_txt,newline);
end
fclose(fid_txt);
fprintf('TXT File Saved [%s].\n',filepath_txt);


% Writing XCorrAmp.txt
if ~flag_crosscorr
    filepath_txt = fullfile(seed_save,'_txt',sprintf('[%s]ACorr-Stats[Amp].txt',batchname));
else
    filepath_txt = fullfile(seed_save,'_txt',sprintf('[%s]XCorr-Stats[%s][Amp].txt',batchname,reference));
end
if ~isfolder(fullfile(seed_save,'_txt'))
    mkdir(fullfile(seed_save,'_txt'));
end
fid_txt = fopen(filepath_txt,'w');
for k=1:nTraces
    cur_trace = char(all_traces(k));
    fwrite(fid_txt,sprintf('%s \t', cur_trace));
    fwrite(fid_txt,newline);

    fwrite(fid_txt,sprintf('%s \t', 'Mean +- sem (s)'));
    for j=1:nAnimals
        cur_animal = char(all_animals(j));
        fwrite(fid_txt,sprintf('%s \t', cur_animal));
    end
    fwrite(fid_txt,newline);
    for i=1:nStates
        cur_state = char(all_states(i));
        fwrite(fid_txt,sprintf('%s \t',cur_state));
        for j=1:nAnimals
            % cur_animal = char(all_animals(j));
            fwrite(fid_txt,sprintf('%.3f +- %.3f (n=%d)\t',meanMat(i,j,k,2),semMat(i,j,k,2),nSamplesMat(i,j,k,2)));
        end
        fwrite(fid_txt,newline);
    end
    fwrite(fid_txt,newline);

    % Statistics
    for i1 = 1:nStates
        state1 = char(all_states(i1));
        for i2 = i1+1:nStates
            state2 = char(all_states(i2));
            fwrite(fid_txt,sprintf('PValues[%s]vs[%s] \t',state1,state2));
            for j=1:nAnimals
                cur_animal = char(all_animals(j));
                index_keep1 = find((strcmp(S.state,state1).*strcmp(S.animal,cur_animal)).*strcmp(S.trace,cur_trace)==1);
                index_keep2 = find((strcmp(S.state,state2).*strcmp(S.animal,cur_animal)).*strcmp(S.trace,cur_trace)==1);
                data1 = S.ACorr_Amp(index_keep1);
                data2 = S.ACorr_Amp(index_keep2);
                data1 = data1(~isnan(data1));
                data2 = data2(~isnan(data2));
                if isempty(data1) || isempty(data2)
                    P = NaN;
                else
                    P = ranksum(data1,data2);
                end
                fwrite(fid_txt,sprintf('%.6f \t',P));
            end
            fwrite(fid_txt,newline);
        end
    end
    fwrite(fid_txt,newline);   

end
fclose(fid_txt);
fprintf('TXT File Saved [%s].\n',filepath_txt);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting per state - Grouping by animals
nFigs = ceil(nTraces/nCol);
all_f = gobjects(nFigs);
all_ax = gobjects(nTraces,nStates,4);

eps1 = .02;
eps2 = .02;

if nFigs>1
    % Multiple Figures
    for index_fig = 1:nFigs
        all_f(index_fig) = figure;
        if ~flag_crosscorr
            all_f(index_fig).Name = sprintf('[%s]ACorr-per-state_%02d',batchname,index_fig);
        else
            reference_preffix = largest_preffix(all_refs);
            all_f(index_fig).Name = sprintf('[%s]XCorr-per-state[%s]%02d',batchname,reference_preffix,index_fig);
        end
    end
    count = 1;
    % Axes
    for i=1:nTraces
        for j=1:nStates
            framepos = [(count-1)/nCol+eps1  ((nStates-j)/nStates)+eps1  1/nCol-eps1  (1/nStates)-2*eps1];
%             all_ax(i,j,1) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,1) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+.5*framepos(4)+eps2  ramepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,2) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,3) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+.5*framepos(3)+eps2  framepos(2)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
%             all_ax(i,j,4) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+.5*framepos(3)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,4) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+1000*framepos(3)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            
        end
        count=mod(count,nCol)+1;
    end
else
    % Single Figure
    all_f(1) = figure;
    if ~flag_crosscorr
        all_f(1).Name = sprintf('[%s]ACorr-per-state',batchname);
    else
        reference_preffix = largest_preffix(all_refs);
        all_f(1).Name = sprintf('[%s]XCorr-per-state[%s]',batchname,reference_preffix);
    end
    for i=1:nTraces
        for j=1:nStates
            framepos = [(i-1)/nTraces+eps1  ((nStates-j)/nStates)+eps1  1/nTraces-2*eps1  (1/nStates)-2*eps1];
%             all_ax(i,j,1) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,1) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+.5*framepos(4)+eps2  framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,2) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,3) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+.5*framepos(3)+eps2  framepos(2)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
%             all_ax(i,j,4) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+.5*framepos(3)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,4) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+1000*framepos(3)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            
        end
    end
end


TLag = data_acorr.Params.TLag;
for i = 1:nTraces

    cur_trace = char(all_traces(i));
    cur_trace_label = strrep(cur_trace,'.mat','');
    cur_trace_label = strrep(cur_trace_label,'_','-');

    for j=1:nStates

        cur_state = char(all_states(j));

        ax1 = all_ax(i,j,1);
        ax1.YLabel.String = cur_state;
        if ~flag_crosscorr
            ax1.Title.String = sprintf('AutoCorr [%s]',cur_trace_label);
        else
            ax1.Title.String = sprintf('CrossCorr [%s]',cur_trace_label);
        end
        ax1.XLim = [TLag(1) TLag(end)];
        ax1.YLim = [-1 1];
        hold(ax1,'on');
        grid(ax1,'on');

        ax2 = all_ax(i,j,2);
        grid(ax2,"on");
        ax2.XTick = 1:nAnimals;
        ax2.XTickLabel = all_animals;
        ax2.XLim = [.5,nAnimals+.5];
        if ~flag_crosscorr
            ax2.YLim = [0,TLag(end)];
        else
            ax2.YLim = [TLag(1),TLag(end)]/5;
        end
        ax2.YLabel.String = 'Lag(s)';
        hold(ax2,'on');

        ax3 = all_ax(i,j,3);
        grid(ax3,"on");
        ax3.XTick = 1:nAnimals;
        ax3.XTickLabel = all_animals;
        ax3.XLim = [.5,nAnimals+.5];
        ax3.YLim = [0,1.5];
        if ~flag_crosscorr
            ax3.YLabel.String = 'ACorr Amp';
        else
            ax3.YLabel.String = 'XCorr Amp';
        end
        hold(ax3,'on');

        ax4 = all_ax(i,j,4);
        grid(ax4,"on");
        if ~flag_crosscorr
            ax4.XLim = [0,TLag(end)];
            ax4.YLabel.String = 'ACorr Amp';
        else
            ax4.XLim = [TLag(1),TLag(end)]/5;
            ax4.YLabel.String = 'XCorr Amp';
        end
        ax4.YLim = [0,1.5];
        hold(ax4,'on');

        alpha_value = .5;
        linewidth = 2;
        s_markers = {'o';'+';'.'};

        all_lines =[];
        for k = 1:nAnimals
            cur_animal = char(all_animals(k));

            % Selecting data
            index_keep = find((strcmp(S.state,cur_state).*strcmp(S.animal,cur_animal)).*strcmp(S.trace,cur_trace)==1);
            % Mean AutoCorr
            ACorr_mean = mean(S.ACorr(index_keep,:),1,'omitnan');
            ACorr_std = std(S.ACorr(index_keep,:),[],1,'omitnan');
            nSamples = sum(~isnan(S.ACorr(index_keep,:)),1);
            ACorr_sem = ACorr_std./sqrt(nSamples);
            % Lags
            ACorr_Lag = S.ACorr_Lag(index_keep);
            % XCorrAmp
            ACorr_Amp = S.ACorr_Amp(index_keep);

            % Display Ax1
            px_data = [TLag,fliplr(TLag)];
            py_data = [ACorr_mean+ACorr_sem,fliplr(ACorr_mean-ACorr_sem)];
            patch('XData',px_data,'YData',py_data,'FaceColor',g_colors(k,:),'EdgeColor','none',...
                'Parent',ax1,'Visible','on','FaceAlpha',alpha_value);
            line('XData',TLag,'YData',ACorr_mean,'Parent',ax1,'Color',g_colors(k,:),'Linewidth',linewidth,'DisplayName',sprintf('%s[N=%d]',cur_animal,median(nSamples)));


            % Display Ax2
            ydata1 = ACorr_Lag(:);
            xdata = k*ones(size(ydata1));%+rand(size(ydata1))/5;
            % line('XData',xdata(:),'YData',ydata1(:),'Color',g_colors(k,:),'LineStyle','none','Parent',ax2,...
            %     'Marker','o','MarkerEdgeColor',g_colors(k,:),'MarkerFaceColor',g_colors(k,:),'MarkerSize',5);
            swarmchart(xdata(:),ydata1(:),'Color',g_colors(k,:),'Parent',ax2,...
                'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',g_colors(k,:),'MarkerFaceAlpha',.5,...
                'XJitterWidth',.5,'SizeData',15);

            n_samples1 = sum(~isnan(ydata1));
            m1 = mean(ydata1,'omitnan');
            line('Xdata',k,'YData',m1,'Parent',ax2,'LineStyle','none','LineWidth',1,...
                'Marker','+','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
            line('Xdata',[k,k],'YData',[m1-std(ydata1,[],'omitnan')/sqrt(n_samples1),m1+std(ydata1,[],'omitnan')/sqrt(n_samples1)],'Parent',ax2,...
                'LineStyle','-','LineWidth',2,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',1);
            text(k-.25,ax2.YLim(1)+.9*(ax2.YLim(2)-ax2.YLim(1)),sprintf('%.2f',m1),'Parent',ax2);

            % Display Ax3
            ydata2 = ACorr_Amp(:);
            xdata = k*ones(size(ydata2));%+rand(size(ydata2))/5;
            % line('XData',xdata(:),'YData',ydata2(:),'Color',g_colors(k,:),'LineStyle','none','Parent',ax3,...
            %     'Marker','o','MarkerEdgeColor',g_colors(k,:),'MarkerFaceColor',g_colors(k,:),'MarkerSize',5);
            swarmchart(xdata(:),ydata2(:),'Color',g_colors(k,:),'Parent',ax3,...
                'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',g_colors(k,:),'MarkerFaceAlpha',.5,...
                'XJitterWidth',.5,'SizeData',15);

            n_samples2 = sum(~isnan(ydata2));
            m2 = mean(ydata2,'omitnan');
            line('Xdata',k,'YData',m2,'Parent',ax3,'LineStyle','none','LineWidth',1,...
                'Marker','+','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
            line('Xdata',[k,k],'YData',[m2-std(ydata2,[],'omitnan')/sqrt(n_samples2),m2+std(ydata2,[],'omitnan')/sqrt(n_samples2)],'Parent',ax3,...
                'LineStyle','-','LineWidth',2,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',1);
            text(k-.25,ax3.YLim(1)+.9*(ax3.YLim(2)-ax3.YLim(1)),sprintf('%.2f',m2),'Parent',ax3);

            % Display Ax4
            l = scatter(ydata1,ydata2,4,'Color',g_colors(k,:),'Parent',ax4,...
                'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',g_colors(k,:),'MarkerFaceAlpha',.5,...
                'DisplayName',sprintf('%s[N=%d]',cur_animal,median(nSamples)));
            line('Xdata',[m1,m1],'YData',[m2-std(ydata2,[],'omitnan')/sqrt(n_samples2),m2+std(ydata2,[],'omitnan')/sqrt(n_samples2)],'Parent',ax4,...
                'LineStyle','-','LineWidth',1.5,'Color',g_colors(k,:),'Marker','o','MarkerEdgeColor',g_colors(k,:),'MarkerFaceColor',g_colors(k,:),'MarkerSize',1);
            line('Xdata',[m1-std(ydata1,[],'omitnan')/sqrt(n_samples1),m1+std(ydata1,[],'omitnan')/sqrt(n_samples1)],'YData',[m2,m2],'Parent',ax4,...
                'LineStyle','-','LineWidth',1.5,'Color',g_colors(k,:),'Marker','o','MarkerEdgeColor',g_colors(k,:),'MarkerFaceColor',g_colors(k,:),'MarkerSize',1);
            all_lines = [all_lines;l];

        end
        legend(ax4,all_lines,'Location','northeast','FontSize',7,'Box','off');
    end
end

% Saving figure
for index_fig = 1:nFigs
    f = all_f(index_fig);
    f.Units='normalized';
    f.OuterPosition = [0 0 1 1];
    pic_name = strcat(f.Name,'.pdf');
    fprintf('Saving figure [%s]...',fullfile(seed_save,pic_name));
    % Mac
    f.PaperPositionMode = 'manual';
    exportgraphics(f,fullfile(seed_save,pic_name),'ContentType','vector');
    % Ubuntu
    % saveas(f,fullfile(seed_save,pic_name),'pdf');
    fprintf(' done.\n');
    close(f);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting per animal - Grouping by state
nFigs = ceil(nTraces/nCol);
all_f = gobjects(nFigs);
all_ax = gobjects(nTraces,nAnimals,4);

eps1 = .02;
eps2 = .02;

if nFigs>1
    % Multiple Figures
    for index_fig = 1:nFigs
        all_f(index_fig) = figure;
        if ~flag_crosscorr
            all_f(index_fig).Name = sprintf('[%s]ACorr-per-animal_%02d',batchname,index_fig);
        else
            all_f(index_fig).Name = sprintf('[%s]XCorr-per-animal[%s]%02d',batchname,reference,index_fig);
        end
    end
    count = 1;
    % Axes
    for i=1:nTraces
        for j=1:nAnimals
            framepos = [(count-1)/nCol+eps1  ((nAnimals-j)/nAnimals)+eps1  1/nCol-eps1  (1/nAnimals)-2*eps1];
%             all_ax(i,j,1) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,1) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+.5*framepos(4)+eps2  framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,2) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,3) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+.5*framepos(3)+eps2  framepos(2)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
%             all_ax(i,j,4) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+.5*framepos(3)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,4) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+1000*framepos(3)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            
        end
        count=mod(count,nCol)+1;
    end
else
    % Single Figure
    all_f(1) = figure;
    if ~flag_crosscorr
        all_f(1).Name = sprintf('[%s]ACorr-per-animal',batchname);
    else
        all_f(1).Name = sprintf('[%s]XCorr-per-animal[%s]',batchname,reference);
    end
    for i=1:nTraces
        for j=1:nAnimals
            framepos = [(i-1)/nTraces+eps1  ((nAnimals-j)/nAnimals)+eps1  1/nTraces-2*eps1  (1/nAnimals)-2*eps1];
%             all_ax(i,j,1) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,1) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+.5*framepos(4)+eps2  framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,2) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+eps2  framepos(2)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,3) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+.5*framepos(3)+eps2  framepos(2)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
%             all_ax(i,j,4) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+.5*framepos(3)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            all_ax(i,j,4) = axes('Parent',all_f(ceil(i/nCol)),'Position',[framepos(1)+1000*framepos(3)+eps2  framepos(2)+.5*framepos(4)+eps2  .5*framepos(3)-eps2   .5*framepos(4)-eps2]);
            
        end
    end
end


TLag = data_acorr.Params.TLag;
for i = 1:nTraces

    cur_trace = char(all_traces(i));
    cur_trace_label = strrep(cur_trace,'.mat','');
    cur_trace_label = strrep(cur_trace_label,'_','-');

    for j=1:nAnimals

        cur_animal = char(all_animals(j));

        ax1 = all_ax(i,j,1);
        ax1.YLabel.String = cur_animal;
        ax1.YLabel.String = cur_animal;

        if ~flag_crosscorr
            ax1.Title.String = sprintf('AutoCorr [%s]',cur_trace_label);
        else
            ax1.Title.String = sprintf('CrossCorr [%s]',cur_trace_label);
        end

        ax1.XLim = [TLag(1) TLag(end)];
        ax1.YLim = [-1 1];
        hold(ax1,'on');
        grid(ax1,'on');

        ax2 = all_ax(i,j,2);
        grid(ax2,"on");
        ax2.XTick = 1:nStates;
        ax2.XTickLabel = all_states;
        ax2.XLim = [.5,nStates+.5];
        if ~flag_crosscorr
            ax2.YLim = [0,TLag(end)];
        else
            ax2.YLim = [TLag(1),TLag(end)]/5;
        end
        ax2.YLabel.String = 'Lag(s)';
        hold(ax2,'on');

        ax3 = all_ax(i,j,3);
        grid(ax3,"on");
        ax3.XTick = 1:nStates;
        ax3.XTickLabel = all_states;
        ax3.XLim = [.5,nStates+.5];
        ax3.YLim = [0,1.5];
        if ~flag_crosscorr
            ax3.YLabel.String = 'ACorr Amp';
        else
            ax3.YLabel.String = 'XCorr Amp';
        end
        hold(ax3,'on');

        ax4 = all_ax(i,j,4);
        grid(ax4,"on");
        if ~flag_crosscorr
            ax4.XLim = [0,TLag(end)];
            ax4.YLabel.String = 'ACorr Amp';
        else
            ax4.XLim = [TLag(1),TLag(end)]/5;
            ax4.YLabel.String = 'XCorr Amp';
        end
        ax4.YLim = [0,1.5];
        hold(ax4,'on');

        alpha_value = .5;
        linewidth = 2;
        s_markers = {'o';'+';'.'};

        all_lines =[];
        for k = 1:nStates
            cur_state = char(all_states(k));

            % Selecting data
            index_keep = find((strcmp(S.state,cur_state).*strcmp(S.animal,cur_animal)).*strcmp(S.trace,cur_trace)==1);
            % Mean AutoCorr
            ACorr_mean = mean(S.ACorr(index_keep,:),1,'omitnan');
            ACorr_std = std(S.ACorr(index_keep,:),[],1,'omitnan');
            nSamples = sum(~isnan(S.ACorr(index_keep,:)),1);
            ACorr_sem = ACorr_std./sqrt(nSamples);
            % Lags
            ACorr_Lag = S.ACorr_Lag(index_keep);
            % XCorrAmp
            ACorr_Amp = S.ACorr_Amp(index_keep);

            % Display Ax1
            px_data = [TLag,fliplr(TLag)];
            py_data = [ACorr_mean+ACorr_sem,fliplr(ACorr_mean-ACorr_sem)];
            patch('XData',px_data,'YData',py_data,'FaceColor',g_colors(k,:),'EdgeColor','none',...
                'Parent',ax1,'Visible','on','FaceAlpha',alpha_value);
            line('XData',TLag,'YData',ACorr_mean,'Parent',ax1,'Color',g_colors(k,:),'Linewidth',linewidth,'DisplayName',sprintf('%s[N=%d]',cur_state,median(nSamples)));
            
            % Display Ax2
            ydata1 = ACorr_Lag(:);
            xdata = k*ones(size(ydata1));%+rand(size(ydata1))/5;
            % line('XData',xdata(:),'YData',ydata1(:),'Color',g_colors(k,:),'LineStyle','none','Parent',ax2,...
            %     'Marker','o','MarkerEdgeColor',g_colors(k,:),'MarkerFaceColor',g_colors(k,:),'MarkerSize',5);
            swarmchart(xdata(:),ydata1(:),'Color',g_colors(k,:),'Parent',ax2,...
                'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',g_colors(k,:),'MarkerFaceAlpha',.5,...
                'XJitterWidth',.5,'SizeData',15);

            n_samples1 = sum(~isnan(ydata1));
            m1 = mean(ydata1,'omitnan');
            line('Xdata',k,'YData',m1,'Parent',ax2,'LineStyle','none','LineWidth',1,...
                'Marker','+','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
            line('Xdata',[k,k],'YData',[m1-std(ydata1,[],'omitnan')/sqrt(n_samples1),m1+std(ydata1,[],'omitnan')/sqrt(n_samples1)],'Parent',ax2,...
                'LineStyle','-','LineWidth',2,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',1);
            text(k-.25,ax2.YLim(1)+.9*(ax2.YLim(2)-ax2.YLim(1)),sprintf('%.2f',m1),'Parent',ax2);

            % Display Ax3
            ydata2 = ACorr_Amp(:);
            xdata = k*ones(size(ydata2));%+rand(size(ydata2))/5;
            % line('XData',xdata(:),'YData',ydata2(:),'Color',g_colors(k,:),'LineStyle','none','Parent',ax3,...
            %     'Marker','o','MarkerEdgeColor',g_colors(k,:),'MarkerFaceColor',g_colors(k,:),'MarkerSize',5);
            swarmchart(xdata(:),ydata2(:),'Color',g_colors(k,:),'Parent',ax3,...
                'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',g_colors(k,:),'MarkerFaceAlpha',.5,...
                'XJitterWidth',.5,'SizeData',15);

            n_samples2 = sum(~isnan(ydata2));
            m2 = mean(ydata2,'omitnan');
            line('Xdata',k,'YData',m2,'Parent',ax3,'LineStyle','none','LineWidth',1,...
                'Marker','+','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
            line('Xdata',[k,k],'YData',[m2-std(ydata2,[],'omitnan')/sqrt(n_samples2),m2+std(ydata2,[],'omitnan')/sqrt(n_samples2)],'Parent',ax3,...
                'LineStyle','-','LineWidth',2,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',1);
            text(k-.25,ax3.YLim(1)+.9*(ax3.YLim(2)-ax3.YLim(1)),sprintf('%.2f',m2),'Parent',ax3);

            % Display Ax4
            l = scatter(ydata1,ydata2,4,'Color',g_colors(k,:),'Parent',ax4,...
                'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',g_colors(k,:),'MarkerFaceAlpha',.5,...
                'DisplayName',sprintf('%s[N=%d]',cur_state,median(nSamples)));
            line('Xdata',[m1,m1],'YData',[m2-std(ydata2,[],'omitnan')/sqrt(n_samples2),m2+std(ydata2,[],'omitnan')/sqrt(n_samples2)],'Parent',ax4,...
                'LineStyle','-','LineWidth',1.5,'Color',g_colors(k,:),'Marker','o','MarkerEdgeColor',g_colors(k,:),'MarkerFaceColor',g_colors(k,:),'MarkerSize',1);
            line('Xdata',[m1-std(ydata1,[],'omitnan')/sqrt(n_samples1),m1+std(ydata1,[],'omitnan')/sqrt(n_samples1)],'YData',[m2,m2],'Parent',ax4,...
                'LineStyle','-','LineWidth',1.5,'Color',g_colors(k,:),'Marker','o','MarkerEdgeColor',g_colors(k,:),'MarkerFaceColor',g_colors(k,:),'MarkerSize',1);
            all_lines =[all_lines;l];

        end
        legend(ax4,all_lines,'Location','northeast','FontSize',7,'Box','off');
    end
end

% Saving figure
for index_fig = 1:nFigs
    f = all_f(index_fig);
    f.Units='normalized';
    f.OuterPosition = [0 0 1 1];
    pic_name = strcat(f.Name,'.pdf');
    fprintf('Saving figure [%s]...',fullfile(seed_save,pic_name));
    % Mac
    f.PaperPositionMode = 'manual';
    exportgraphics(f,fullfile(seed_save,pic_name),'ContentType','vector');
    % Ubuntu
    % saveas(f,fullfile(seed_save,pic_name),'pdf');
    fprintf(' done.\n');
    close(f);
end

end
