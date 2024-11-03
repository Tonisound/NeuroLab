function [outputArg1] = main_scan2acq(inputArg1)
% Converts scan files to .acq and .mat file readable in MATLAB
% Requires openScan.p
% Will trim fUS to 64 channels
% Stores .acq and .mat files in fUS native folder
% Skips if .acq and .mat files are already present
%
% Example of use:
% d = dir(fullfile('/media/hobbes/DataMOBs206/Raw-fUS','FUS-REPLAY','*','*','*','*.scan'));
% all_files = fullfile({d(:).folder}',{d(:).name}');
% main_scan2acq(all_files);

outputArg1=false;

if nargin == 0
    
    % Manual selection
    [filename, pathname] = uigetfile('*.scan', 'Pick a Iconeus scan file','/media/hobbes/Toni_HD2/','MultiSelect', 'on');
    all_scan_files = [];
    
    if ischar(filename)
        all_scan_files = {fullfile(pathname,filename)};
    else
        for i=1:length(filename)
            all_scan_files = [all_scan_files ;{fullfile(pathname,char(filename(i)))}];
        end
    end
else
    
    % File list
    all_scan_files = inputArg1;

end

for i =1:size(all_scan_files,1)
    
    filename_scan = char(all_scan_files(i));
    
    if ~strcmp(filename_scan(end-4:end),'.scan')
        warning('Not a .scan file [%s]',filename_scan);
        return;
    end
    
    temp = regexp(filename_scan,filesep,'split');
    filename_scan_short = char(temp(end));
    
    filename_acq = strrep(filename_scan,'.scan','.acq');
    filename_mat = strrep(filename_scan,'.scan','.mat');
    
    if isfile(filename_acq) && isfile(filename_mat)
        fprintf('File (%d/%d) [%s] already exported.\n',i,size(all_scan_files,1),filename_mat);
        continue;
    end
    
    temp = regexp(filename_acq,filesep,'split');
    filename_acq_short = char(temp(end));
    
    Acquisition = openScan(filename_scan);
     x = size(Acquisition.Data,1);
     z = size(Acquisition.Data,3);
     nFrames = size(Acquisition.Data,4);
    
    % Restricting to meaningful frames
    Data1 = Acquisition.Data(1:64,:,:,:);
    Data2 = Acquisition.Data(65:128,:,:,:);
    
    % ratio_1 = sum(Data1(:)~=0)/length(Data1(:));
    ratio_2 = sum(Data2(:)~=0)/length(Data2(:));
    if ratio_2<.1
        Acquisition.Data = Data1;
        fprintf('Acquisition cropped to first 64 channels [%s].\n',filename_scan_short);
        x = 64;
    end
    
    % Saving acq format
    save(filename_acq,'Acquisition','x','z','nFrames','-v7.3');
    fprintf('File [%s] exported.\n',filename_acq_short);
    
    % Saving mat format
    temp = regexp(filename_mat,filesep,'split');
    filename_mat_short = char(temp(end));
    Doppler_film = permute(Acquisition.Data,[3,1,4,2]);
    save(filename_mat,'Doppler_film','x','z','nFrames','-v7.3');
    fprintf('File (%d/%d) [%s] exported.\n',i,size(all_scan_files,1),filename_mat_short);
end

outputArg1=true;

end
