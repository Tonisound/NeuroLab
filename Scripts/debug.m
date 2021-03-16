function debug

    seed = '/Volumes/Zeno_Antoine/DATA/EEG-fUS-VIDEO/';
    file_list = dir([seed,'*_E']);

    for i = 1:length(file_list)

        burst_list = dir([seed,file_list(i).name,'/*_6BMU']);
        if length(burst_list) == 0
            fprintf('No burst data in file %s.\n',file_list(i).name);
        elseif length(burst_list) == 1
            fprintf('File %s : Processing Burst file : %s\n',file_list(i).name, burst_list(1).name);
            reprocess_IQ(file_list(i).name,burst_list(1).name);

        elseif length(burst_list) == 2
            fprintf('File %s : 2 files found : %s %s\n',file_list(i).name,burst_list(1).name,burst_list(2).name);
        else
            disp('File %s : Error More than 3 burst files',file_list(i).name);
            return;
        end
    fprintf('\n');
    end
end

function reprocess_IQ(file_E,file_6BMU)
    
    path_in = [file_E,'/',file_6BMU,'/'];
    path_out = [path_in(1:end-6),'_R',path_in(end-5:end)];
    mkdir(path_out);
    fprintf('Folder %s created\n',path_out);
    bursts = dir([path_in,'IQ*.mat']);
    %
    for i=1:length(bursts)
        load([path_in,bursts(i).name]);
        index = mod(RetroAcqKStart-1,30)*200;
        IQ = cat(3,IQ(:,:,index+1:6000),IQ(:,:,1:index));
        fprintf('Burst %d : Reframing IQ from index %d \n',i,index);
        test=[path_out,bursts(i).name];
        save(test,'fileCount','IQstatus', 'IQ','UF','StartSequenceTime', 'RetroAcqClickTime', 'RetroAcqClickBloc', 'RetroAcqActualStartBloc', 'TimingFromFirstTrig','TimeAfterLast', 'RetroAcqKStart', 'RetroAcqKiStart', '-v6')
        fprintf('Saving IQ @ %s \n',test);
    end
    load([path_in,'us_param.mat']);
    save([path_out,'us_param.mat'],'imgt','BurstMatVersion','UF','BlocRate', 'NblocsMax', 'Tblocs', 'Tpast', 'NBlocsRamMax', 'NBlocsPast', 'showDoppler', '-v6');
    fprintf('Saving US params @ %s \n',[path_out,'us_param.mat']);
end


% for i = 1:length(file_list)
%     
%     if exist(file_list(i).name)==7
%         
%     else mkdir(file_list(i).name)
%     end
%     
%     if file_list(i).isdir
%         burst_list = dir([seed,file,'/',file_list(i).name,'/','IQ*.mat']);
%     end
%     
% end