function success = import_lfptraces(dir_eeg,dir_save)

success = false;
try
    load(fullfile(dir_save,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
catch
    errordlg(sprintf('Missing File %s',fullfile(dir_save,'Time_Reference.mat')));
    return;
end

dir_traces = dir(fullfile(dir_spiko,'*_export'));
count = 0;

[ind_traces,ok] = listdlg('PromptString','Select Regions','SelectionMode','multiple','ListString',{dir_traces.name},'ListSize',[800 500]);

if ~ok || isempty(ind_traces)
    return;
end

% %Direct Importation - Useful for Batch Processing
%temp = {dir_traces.name};
% ind_1 = ~(cellfun('isempty',strfind(temp,'MUA_0_Multiunit_frequency')));
% ind_1 = ~(cellfun('isempty',strfind(temp,'Posture_power')));
% ind_2 = ~(cellfun('isempty',strfind(temp,'over_episode')));
% ind_3 = ~(cellfun('isempty',strfind(temp,'LFP_0_Gamma_low_power')));
% ind_4 = ~(cellfun('isempty',strfind(temp,'LFP_0_Gamma_mid_power')));
% ind_5 = ~(cellfun('isempty',strfind(temp,'LFP_0_Gamma_mid_background_power')));
% ind_6 = ~(cellfun('isempty',strfind(temp,'LFP_0_Gamma_high_power')));
% ind_7 = ~(cellfun('isempty',strfind(temp,'LFP_0_Gamma_high_background_power')));
% ind_8 = ~(cellfun('isempty',strfind(temp,'LFP_0_Theta_power')));
% ind_traces = find(ind_1|ind_2|ind_3|ind_4|ind_5|ind_6|ind_7|ind_8==1); traces = struct('parent',{},'fullname',{},'shortname',{},'unit',{},'nb_samples',{},'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{});

for i=1:length(ind_traces)
    %dir_traces(ind_traces(i)).name
    text_file = dir(fullfile(dir_spiko,dir_traces(ind_traces(i)).name,'*.txt'));
    switch length(text_file)
        case 0,
            ed = errordlg(sprintf('Missing Text file in %s - Proceed.\n', dir_traces(ind_traces(i)).name));
            waitfor(ed);
            continue;
        case 1
            ind_text=1;
        otherwise
            fprintf('Multiple Text file found in %s.', dir_traces(ind_traces(i)).name);
            ind_text = listdlg('PromptString','Select a unique File','SelectionMode','single','ListString',{text_file.name},'ListSize',[300 500]);
    end
    
    filename = fullfile(dir_spiko,dir_traces(ind_traces(i)).name,text_file(ind_text).name);
    switch text_file(ind_text).name
        
        case '_descriptor.txt'
            % Getting Information from Binary descriptor
            S = read_binary_descriptor(filename);
            
            % Opening Binary File & saving it to Traces
            for j=1:length(S)
                count = count+1;
                T = read_binary_file(dir_spiko,S(j),time_ref,n_burst,length_burst);
                traces(count).shortname = T.shortname;
                traces(count).fullname = T.fullname;
                traces(count).parent =  T.parent;
                traces(count).X = T.X;
                traces(count).Y = T.Y;
                traces(count).X_ind = T.X_ind;
                traces(count).X_im = T.X_im;
                traces(count).Y_im = T.Y_im;
                traces(count).nb_samples =  T.nb_samples;
                traces(count).unit = T.unit;
            end

        otherwise
            % Direct Importation
            fileID = fopen(filename,'r');
            hline1 = fgetl(fileID);
            hline_1 = regexp(hline1,'(\t+)','split');
            hline2 = fgetl(fileID);
            hline_2 = regexp(hline2,'(\t+)','split');
             
            % Reading line-by-line Testing for End of file
            tline = fgetl(fileID);
            %T = regexp(tline,'(\t+)','split');
            T = str2num(tline);
            while ischar(tline)
                try
                tline = fgetl(fileID);
                %T = [T;regexp(tline,'(\t+)','split')];
                T = [T;str2num(tline)];
                catch
                    fprintf('(Warning) Importation stoped at line %d\n (File : %s)',size(T,1)+1,filename);
                end
            end
            fclose(fileID);
            for k=2:size(T,2)
                count = count+1;
                traces(count).shortname = char(hline_2(k));
                traces(count).parent = char(dir_traces(ind_traces(i)).name);
                traces(count).fullname = strcat(char(dir_traces(ind_traces(i)).name(1:30)),'/',char(hline_2(k)));
                traces(count).X = T(:,1);
                traces(count).Y = T(:,k);
                traces(count).X_ind = T(:,1);
                traces(count).X_im = T(:,1);
                traces(count).Y_im = T(:,k);
                traces(count).nb_samples = length(T(:,k));
            end
    end
    fprintf('Succesful Importation (File %s /Folder %s).\n', text_file(ind_text).name,dir_traces(ind_traces(i)).name);
            
end

% Save dans SpikoscopeTraces.mat
if  ~isempty(traces)
    save(fullfile(dir_save,'Spikoscope_Traces.mat'),'traces','-v7.3');
end
fprintf('===> Saved at %s.mat\n',fullfile(dir_save,'Spikoscope_Traces.mat'));

success = true;
end
