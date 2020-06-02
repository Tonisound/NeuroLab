function [F_out,S_out] = interpolate_Doppler(F,handles,S)
% Interpolate Doppler film if trigger is not regular

global SEED DIR_SAVE;
F_out = F;
S_out = S;
load('Preferences.mat','GImport');

% Loading Doppler_film
if ~isfield(S,'Doppler_film') || isempty(S.Doppler_film)
    if ~isempty(F.acq)
        file_acq = fullfile(SEED,F.parent,F.session,F.recording,F.dir_fus,F.acq);
        fprintf('Loading Doppler_film [%s] ...',F.acq);
        if contains(F.acq,'.acq')
            % case file_acq ends .acq (Verasonics)
            data_acq = load(file_acq,'-mat');
            Doppler_film = permute(data_acq.Acquisition.Data,[3,1,4,2]);
        elseif contains(F.acq,'.mat')
            % case file_acq ends .mat (Aixplorer)
            data_acq = load(file_acq,'Doppler_film');
            Doppler_film = data_acq.Doppler_film;
        end
        fprintf(' done.\n');
    else
        errordlg(sprintf('Missing Doppler file [%s].',F.nlab));
        return;
    end
else
    % unpacking structure
    Doppler_film = S.Doppler_film;
end
    
% Loading Time Reference
if ~isfield(S,'trigger') || isempty(S.trigger)
    if exist(fullfile(DIR_SAVE,F.nlab,'Time_Reference.mat'),'file')
        data_tr = load(fullfile(DIR_SAVE,F.nlab,'Time_Reference.mat'));
        trigger = data_tr.time_ref.Y;
        reference = data_tr.reference;
        padding = data_tr.padding;
        rec_mode = data_tr.rec_mode;
        offset = data_tr.offset;
        delay_lfp_video = data_tr.delay_lfp_video;
        file_txt = fullfile(DIR_SAVE,F.nlab,'Time_Reference.mat');
    else
        errordlg(sprintf('Missing Time Reference file [%s].',F.nlab));
        return;
    end
else
    % unpacking structure
    trigger = S.trigger;
    reference = S.reference;
    padding = S.padding;
    rec_mode = S.rec_mode;
    offset = S.offset;
    delay_lfp_video = S.delay_lfp_video;
    file_txt = 'trigger.txt';
end


%v_ratio = v.Height/v.Width;
f = figure('Name',sprintf('Doppler Interpolation [%s]',F.acq),...
    'NumberTitle','off',...
    'Units','normalized',...
    'Tag','InterpolateFigure',...
    'Position',[.1 .1 .4 .4]);
f.UserData.F = F;
f.UserData.trigger = trigger;
% f.UserData.Doppler_film = Doppler_film;
f.UserData.reference = reference;
f.UserData.padding = padding;
f.UserData.rec_mode = rec_mode;
colormap(f,'gray');

% Video Axis
ax1 = axes('Parent',f,'Tag','Ax1','Title','',...
    'Position',[.05 .7 .9 .25]);
ax2 = axes('Parent',f,'Tag','Ax2','Title','',...
    'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','',...
    'Position',[.05 .4 .9 .25]);
ax3 = axes('Parent',f,'Tag','Ax3',...
    'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','',...
    'Position',[.75 .05 .2 .3]);

% Filling axes
line('XData',trigger,'YData',[0;diff(trigger)],'Parent',ax1,...
    'Tag','DiffTrigger','Color','k','LineStyle','none',...
    'Marker','o','MarkerSize',3);
ax1.YLabel.String = 'Inter-frame interval';
ax1.XLim = [trigger(1)-.5 trigger(end)+.5]; 
ax1.YLim = [min(diff(trigger)) max(diff(trigger))]; 

X = trigger;
Y = squeeze(mean(mean(Doppler_film,1,'omitnan'),2,'omitnan'));
line('XData',X,'YData',Y,'Parent',ax2,...
    'Tag','TriggerIn','Color','b','LineStyle','none',...
    'Marker','o','MarkerSize',3);
ax2.XLim = [X(1)-.5 X(end)+.5]; 
ax2.YLim = [min(Y,[],'omitnan') max(Y,[],'omitnan')]; 
ax2.YLabel.String = 'Trigger';
ax2.YScale = 'log';

hist(diff(trigger),100,'Parent',ax3);
ax3.Tag = 'Ax3';
%ax3.YScale = 'log';

linkaxes([ax1;ax2],'x');

%buttons
autosetButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','Autoset',...
    'Tag','okButton',...
    'Parent',f);
okButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','OK',...
    'Tag','okButton',...
    'Parent',f);
cancelButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','Cancel',...
    'Tag','cancelButton',...
    'Parent',f);

% Interpolation Step
% step_interp = 0.4;
if contains(rec_mode,'BURST')
    step_interp = GImport.resamp_burst;
elseif contains(rec_mode,'CONTINUOUS')
    step_interp = GImport.resamp_cont;
end

e1 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String',datestr(datenum(step_interp/(24*3600)),'HH:MM:SS.FFF'),...
    'TooltipString','Interpolation Step (s)',...
    'Tag','Edit1',...
    'Parent',f);
%e1.UserData.f_interp = step_interp;
t_interp = trigger(1):step_interp:trigger(end);

sl1 = uicontrol('Style','slider',... 
    'Min',.1,'Max',3,...
    'Value',step_interp,...
    'Units','normalized',...
    'Tag','Slider1',...
    'Parent',f);
sl1.SliderStep = [.01/(sl1.Max-sl1.Min) .1/(sl1.Max-sl1.Min)];
sl1.Value = step_interp;

% Text1
s1 = sprintf('Input File: %s',file_txt);
s2 = sprintf('Recording Mode: %s',rec_mode);
s3 = sprintf('Reference: %s - Padding: %s',reference,padding);
s4 = sprintf('Total Frames: %d - Mean Interval: %.4f s',length(trigger),mean(diff(trigger)));
t1 = cellstr([{s1};{s2};{s3};{s4}]);
text1 = uicontrol('Style','text',... 
    'Units','normalized',...
    'String','',...
    'BackgroundColor','w',...
    'HorizontalAlignment','left',...
    'Tag','Text1',...
    'String',t1,...
    'Parent',f);

% Text2
% s0 = 'Video Information';
s1 = sprintf('Output Folder: %s',strrep(F.dir_fus,'_fus','_fusint'));
s2 = sprintf('Time Interval: %s - %s',datestr(datenum(trigger(1)/(24*3600)),'HH:MM:SS.FFF'),datestr(datenum(trigger(end)/(24*3600)),'HH:MM:SS.FFF'));
s3 = sprintf('Total Frames: %d',length(t_interp));
esize = 4*(size(Doppler_film,1)*size(Doppler_film,2)*length(t_interp)/1e6);
s4 = sprintf('Expected Size: %.1f Mb',esize);
t2 = cellstr([{s1};{s2};{s3};{s4}]);
text2 = uicontrol('Style','text',... 
    'Units','normalized',...
    'String','',...
    'BackgroundColor','w',...
    'HorizontalAlignment','left',...
    'Tag','Text2',...
    'String',t2,...
    'Parent',f);


e1.Position = [.05 .3 .2 .05];
sl1.Position = [.05 .25 .2 .05];
autosetButton.Position = [.05 .15 .2 .05];
okButton.Position = [.05 .1 .2 .05];
cancelButton.Position = [.05 .05 .2 .05];
text1.Position = [.275 .2 .45 .145];
text2.Position = [.275 .05 .45 .145];

% Interactive Control
handles = guihandles(f);

set(e1,'Callback',{@e1_callback,handles});
set(sl1,'Callback',{@sl1_callback,handles});
set(autosetButton,'Callback',{@autosetButton_callback,handles});
set(okButton,'Callback',{@okButton_callback,handles});
set(cancelButton,'Callback',{@cancelButton_callback,handles});

% Set thresholds
e1_callback(e1,[],handles);

% Wait for d to close before running to completion
uiwait(f);

    function okButton_callback(~,~,handles)
        f = handles.InterpolateFigure;
        
        % interpolate Doppler
        fprintf('Interpolating Doppler_film %d frames -> %d frames ...',length(trigger),length(t_interp));
        [x,y,z] = meshgrid(1:size(Doppler_film,2),1:size(Doppler_film,1),trigger);
        [xq,yq,zq] = meshgrid(1:size(Doppler_film,2),1:size(Doppler_film,1),t_interp);
        Doppler_int = interp3(x,y,z,Doppler_film,xq,yq,zq);
        fprintf(' done.\n');
        
        % Save New Doppler
        F_out = F;
        F_out.dir_fus = strrep(F.dir_fus,'_fus','_fusint');
        F_out.acq = 'Doppler.mat';
        Doppler_film = Doppler_int;
        folder_out = fullfile(F_out.fullpath,F_out.dir_fus);
        file_out = fullfile(folder_out,F_out.acq);
        if exist(folder_out,'dir')
            rmdir(folder_out,'s');
        end
        mkdir(folder_out);
        fprintf('Saving Doppler Interpolated [%s] ...',file_out);
        save(file_out,'Doppler_film','-v7.3');
        fprintf(' done.\n');
        
        % Save trigger
        reference = strcat(reference,sprintf('[Interp %.2f sec]',step_interp));
        trigger = t_interp;
        
        % Trigger Exportation
        file_txt_out = fullfile(folder_out,'trigger.txt');
        fid_txt = fopen(file_txt_out,'wt');
        fprintf(fid_txt,'%s',sprintf('<REF>%s</REF>\n',reference));
        fprintf(fid_txt,'%s',sprintf('<PAD>%s</PAD>\n',padding));
        fprintf(fid_txt,'%s',sprintf('<OFFSET>%.3f</OFFSET>\n',offset));
        fprintf(fid_txt,'%s',sprintf('<DELAY>%.3f</DELAY>\n',delay_lfp_video));
        fprintf(fid_txt,'%s',sprintf('<TRIG>\n'));
        %fprintf(fid_txt,'%s',sprintf('n=%d \n',length(trigger)));
        for k = 1:length(trigger)
            fprintf(fid_txt,'%s',sprintf('%.3f\n',trigger(k)));
        end
        fprintf(fid_txt,'%s',sprintf('</TRIG>'));
        fclose(fid_txt);
        fprintf('File trigger.txt saved at %s.\n',file_txt_out);
        
        % Return F and S
        S_out = S;
        S_out.Doppler_film = Doppler_film;
        S_out.trigger = trigger;
        S_out.reference = reference;
        S_out.rec_mode = strrep(rec_mode,'-IRREGULAR','');
        S_out.file_txt = file_txt_out;
        close(f);
    end

    function cancelButton_callback(~,~,handles)
        close(f);
    end

    function e1_callback(hObj,~,handles)
        f = handles.InterpolateFigure;
        t2 = findobj(f,'Tag','Text2');
        
        % Update t_interp
        temp = datenum(hObj.String);
        step_interp = (temp-floor(temp))*24*3600;
        
        % rounding
        step_interp = round(100*step_interp)/100;
        hObj.String = datestr(datenum(step_interp/(24*3600)),'HH:MM:SS.FFF');
        sl1.Value = step_interp;
        
        t_interp = trigger(1):step_interp:trigger(end);
        
        % Update text2
        t2.String{2} = sprintf('Time Interval: %s - %s',datestr(datenum(t_interp(1)/(24*3600)),'HH:MM:SS.FFF'),datestr(datenum(t_interp(end)/(24*3600)),'HH:MM:SS.FFF'));
        t2.String{3} = sprintf('Total Frames: %d',length(t_interp));
        esize = 4*(size(Doppler_film,1)*size(Doppler_film,2)*length(t_interp)/1e6);
        t2.String{4} = sprintf('Expected Size: %.1f Mb',esize);
        
        % Update ax1
        delete(findobj(ax1,'Tag','Threshold1'));
        line('XData',ax1.XLim,'YData',[step_interp step_interp],'Parent',ax1,...
            'Tag','Threshold1','Color','r','LineStyle','-');
        
        % Update ax2
        delete(findobj(ax2,'Tag','Interp2'));
        Y_interp = interp1(X,Y,t_interp);
        line('XData',t_interp,'YData',Y_interp,'Parent',ax2,...
            'Tag','Interp2','Color','r','LineStyle','-','LineWidth',2);
%         line('XData',t_interp,'YData',Y_interp,'Parent',ax2,...
%             'Tag','Interp2','Color','r','LineStyle','none',...
%             'Marker','x','MarkerSize',3);
        
        % Update ax3
        delete(findobj(ax3,'Tag','Threshold3'));
        line('XData',[step_interp step_interp],'YData',ax3.YLim,'Parent',ax3,...
            'Tag','Threshold3','Color','r','LineStyle','-');    
    end

    function sl1_callback(hObj,~,handles)
        step_interp = hObj.Value;
        e1.String = datestr(datenum(step_interp/(24*3600)),'HH:MM:SS.FFF');
        e1_callback(e1,[],handles);
    end

    function autosetButton_callback(hObj,~,handles)
        step_interp = mean(diff(trigger));
        e1.String = datestr(datenum(step_interp/(24*3600)),'HH:MM:SS.FFF');
        e1_callback(e1,[],handles);
    end

end