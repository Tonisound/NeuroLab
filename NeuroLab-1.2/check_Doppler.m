function [ind_rm_final,thresh_out,tag] = check_Doppler(Doppler_film,ind_rm_initial,thresh_in)

global CUR_IM;

ind_rm_final = [];
thresh_out = [];
tag = [];

% Check fUS
% Removing data points where variance is too high
t = (1:size(Doppler_film,3))';
test = permute(mean(mean(Doppler_film,2,'omitnan'),1,'omitnan'),[3,1,2]);
test(test<0)=0.0001;
%test = rescale(test,1,max(test));

% Checking arguments depending on importation type
if nargin == 1
    thresh = mean(test,'omitnan')+3*std(test,[],'omitnan');
    ind_remove = test>thresh;
    ind_keep = test<=thresh;
    status = 'off';
else
    ind_remove = ind_rm_initial;
    ind_keep = ~ind_rm_initial;
    thresh = thresh_in;
    status = 'on';
end

f = figure('Name','CheckDoppler','Units','normalized','Position',[.1 .3 .8 .4]);
ax1 = axes('Visible','off','Parent',f);
im  = imagesc(Doppler_film(:,:,1),'Parent',ax1);
ax1.Visible = 'off';
%colormap(ax1,'gray');

text1 = uicontrol('Style','text','Units','normalized',...
    'BackgroundColor','w','String','','Parent',f);
text1.String = sprintf('%d/%d',CUR_IM,size(Doppler_film,3));
text2 = uicontrol('Style','text','Units','normalized',...
    'BackgroundColor','w','String','','Parent',f);
text2.String = sprintf('Discarded: %d/%d (%.1f %%)',...
    sum(ind_remove),length(ind_remove),100*sum(ind_remove)/length(ind_remove));
text3 = uicontrol('Style','text','Units','normalized','String','','Parent',f,...
	'String','Drag/drop cursor and threshold.Arrows to move cursor. Press enter to discard/include cursor frame');
text4 = uicontrol('Style','text','Units','normalized',...
    'BackgroundColor','w','String','','Parent',f);

ax2 = axes('Parent',f);
ax2.XLim = [.5,size(Doppler_film,3)+5];
delta = max(test)-min(test);
ax2.YLim = [min(test)-.1*delta,max(test)+.1*delta];
ax2.UserData = [];
%ax2.YScale = 'log';

line('XData',t,'YData',test,'Color','k','LineWidth',1,'Parent',ax2);
l_thresh = line('XData',[.5,size(Doppler_film,3)+5],'YData',[thresh,thresh],...
    'Color',[.5 .5 .5],'LineWidth',3,'Parent',ax2,'HitTest','on');
l_cursor = line('XData',[CUR_IM CUR_IM],'YData',[1 1e6],...
    'Color',[.5 .5 .5],'LineWidth',1,'Parent',ax2,'HitTest','on');
l_keep = line('XData',t(ind_keep==1),'YData',test(ind_keep==1),...
    'Color','b','LineStyle','none','Marker','o','Parent',ax2,'HitTest','on');
l_rm = line('XData',t(ind_remove==1),'YData',test(ind_remove==1),...
    'Color','r','LineStyle','none','Marker','o','Parent',ax2,'HitTest','on');

cb1 = uicontrol('Style','checkbox','Units','normalized',...
    'String','linear','TooltipString','Log/linear scale','Tag','Checkbox1','Parent',f);
tagButton = uicontrol('Style','pushbutton','Units','normalized',...
    'String','Tag','TooltipString','Set baseline','Tag','InvertButton','Parent',f);
invertButton = uicontrol('Style','pushbutton','Units','normalized',...
    'String','Invert','Tag','InvertButton','Parent',f);
okButton = uicontrol('Style','pushbutton','Units','normalized',...
    'String','OK','Tag','okButton','Parent',f);
skipButton = uicontrol('Style','pushbutton','Units','normalized',...
    'String','Skip','Tag','cancelButton','Parent',f);
cancelButton = uicontrol('Style','pushbutton','Units','normalized',...
    'String','Cancel','Tag','cancelButton','Parent',f);
cancelButton.Enable = status;


%Positions
ax1.Position = [.025 .1 .2 .8];
ax2.Position = [.25 .1 .65 .8];
text1.Position = [.92 .8 .06 .05];
text2.Position = [.92 .71 .06 .08];
text3.Position = [.1 .925 .8 .04];
text4.Position = [.92 .61 .06 .08];

cb1.Position = [.92 .86 .06 .04];
tagButton.Position = [.92 .5 .06 .1];
invertButton.Position = [.92 .4 .06 .1];
okButton.Position = [.92 .3 .06 .1];
cancelButton.Position = [.92 .2 .06 .1];
skipButton.Position = [.92 .1 .06 .1];

set(tagButton,'Callback',{@tagButton_callback});
set(invertButton,'Callback',{@invertButton_callback});
set(okButton,'Callback',{@okButton_callback});
set(skipButton,'Callback',{@skipButton_callback});
set(cancelButton,'Callback',{@cancelButton_callback});

% Interactive control
set(cb1,'Callback',{@cb1_Callback});
set(ax2,'ButtonDownFcn',{@axes_clickFcn});
set(l_cursor,'ButtonDownFcn',{@click_l_cursor});
set(l_thresh,'ButtonDownFcn',{@click_l_thresh});
set(l_rm,'ButtonDownFcn',{@click_l_keeprm});
set(l_keep,'ButtonDownFcn',{@click_l_keeprm});
set(f,'KeyPressFcn',{@key_pressFcn});

    function cb1_Callback(hObj,~)
        switch hObj.String
            case 'linear'
                hObj.String = 'log';
                ax2.YScale = 'log';
                %l_cursor.YData = ax2.YLim
            case 'log'
                hObj.String = 'linear';
                ax2.YScale = 'linear';
                %l_cursor.YData = ax2.YLim
        end 
    end

    function invertButton_callback(~,~)
        i1 = max(1,round(ax2.XLim(1)));
        i2 = min(round(ax2.XLim(2)),size(Doppler_film,3));
        
        ind_remove(i1:i2) = ~ind_remove(i1:i2);
        ind_keep(i1:i2) = ~ind_keep(i1:i2);
        l_keep.XData = t(ind_keep==1);
        l_keep.YData = test(ind_keep==1);
        l_rm.XData = t(ind_remove==1);
        l_rm.YData = test(ind_remove==1);
        text2.String = sprintf('Discarded: %d/%d (%.1f %%)',...
            sum(ind_remove),length(ind_remove),100*sum(ind_remove)/length(ind_remove));
    end

    function tagButton_callback(~,~)
        i1 = max(1,ceil(ax2.XLim(1)));
        i2 = min(floor(ax2.XLim(2)),size(Doppler_film,3));
        tag.im1 = i1;
        tag.im2 = i2;  
        text4.String = sprintf('Baseline [%03d-%03d]',i1,i2);
    end
    
    function okButton_callback(~,~)
        ind_rm_final = ind_remove;
        thresh_out = thresh;
        close(f);
    end

    function skipButton_callback(~,~)
        ind_rm_final = false(size(Doppler_film,3),1);
        thresh_out = thresh;
        close(f);
    end

    function cancelButton_callback(~,~)
        close(f);
    end

    function click_l_cursor(hObj,~)
        ax = hObj.Parent;
        %f=hObj.Parent.Parent
        ax.UserData = 1;
        %pt_rp = ax.CurrentPoint;
        f.Pointer = 'hand';
        set(f,'WindowButtonMotionFcn', {@figure_motionFcn});
        set(f,'WindowButtonUpFcn', {@unclickFcn});
    end

    function click_l_thresh(hObj,~)
        ax = hObj.Parent;
        ax.UserData = 2;
        %pt_rp = hObj.Parent.CurrentPoint;
        f.Pointer = 'hand';
        set(f,'WindowButtonMotionFcn', {@figure_motionFcn});
        set(f,'WindowButtonUpFcn', {@unclickFcn});
    end

    function click_l_keeprm(~,~)
        pt_rp = ax2.CurrentPoint;
        xdata = round(pt_rp(1,1));
        
        ind_remove(xdata)= ~ind_remove(xdata);
        ind_keep(xdata)= ~ind_keep(xdata);
        %Updating lines
        l_thresh.YData = [thresh, thresh];
        l_keep.XData = t(ind_keep==1);
        l_keep.YData = test(ind_keep==1);
        l_rm.XData = t(ind_remove==1);
        l_rm.YData = test(ind_remove==1);
        text2.String = sprintf('Discarded: %d/%d (%.1f %%)',...
            sum(ind_remove),length(ind_remove),100*sum(ind_remove)/length(ind_remove));
    end

    function figure_motionFcn(~,~)     
        pt_rp = ax2.CurrentPoint;
        Xlim = ax2.XLim;
        Ylim = ax2.YLim;
        switch ax2.UserData
            case 1
                %Move Cursor
                if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
                    l_cursor.XData = [round(pt_rp(1,1)) round(pt_rp(1,1))];
%                     im.CData = Doppler_film(:,:,round(pt_rp(1,1)));
                    im.CData = Doppler_film(:,:,round(pt_rp(1,1)))*ind_keep(round(pt_rp(1,1)));
                    text1.String = sprintf('%d/%d',round(pt_rp(1,1)),size(Doppler_film,3));
                end
            case 2
                % Move thresh
                if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
                    
                    i1 = max(1,round(Xlim(1)));
                    i2 = min(round(Xlim(2)),size(Doppler_film,3));     
                    thresh = pt_rp(1,2);
                    ind_remove_temp = test>thresh;
                    ind_keep_temp = test<=thresh;
                    
                    ind_remove(i1:i2) = ind_remove_temp(i1:i2);
                    ind_keep(i1:i2) = ind_keep_temp(i1:i2);
                    %Updating lines
                    l_thresh.YData = [thresh, thresh];
                    l_keep.XData = t(ind_keep==1);
                    l_keep.YData = test(ind_keep==1);
                    l_rm.XData = t(ind_remove==1);
                    l_rm.YData = test(ind_remove==1);
                    text2.String = sprintf('Discarded: %d/%d (%.1f %%)',...
                        sum(ind_remove),length(ind_remove),100*sum(ind_remove)/length(ind_remove));
                end
        end
    end

    function axes_clickFcn(~,~)
        
        pt_rp = ax2.CurrentPoint;
        Xlim = ax2.XLim;
        Ylim = ax2.YLim;
        %Move Cursor
        if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
            l_cursor.XData = [round(pt_rp(1,1)) round(pt_rp(1,1))];
%             im.CData = Doppler_film(:,:,round(pt_rp(1,1)));
            im.CData = Doppler_film(:,:,round(pt_rp(1,1)))*ind_keep(round(pt_rp(1,1)));
            text1.String = sprintf('%d/%d',round(pt_rp(1,1)),size(Doppler_film,3));
        end
    end

    function unclickFcn(~,~)
        set(f,'WindowButtonMotionFcn','');
        set(f,'WindowButtonUpFcn', '');
        ax2.UserData = [];
        f.Pointer = 'arrow';
    end

    function key_pressFcn(~,evnt)
        %evnt.Key
        switch evnt.Key
            case 'leftarrow'
                if l_cursor.XData(1)>1
                    l_cursor.XData = l_cursor.XData-1;
%                     im.CData = Doppler_film(:,:,l_cursor.XData(1));
                    im.CData = Doppler_film(:,:,l_cursor.XData(1))*ind_keep(l_cursor.XData(1));
                    text1.String = sprintf('%d/%d',l_cursor.XData(1),size(Doppler_film,3));
                end
            case 'rightarrow'
                if l_cursor.XData(1)<size(Doppler_film,3)
                    l_cursor.XData = l_cursor.XData+1;
%                     im.CData = Doppler_film(:,:,l_cursor.XData(1));
                    im.CData = Doppler_film(:,:,l_cursor.XData(1))*ind_keep(l_cursor.XData(1));
                    text1.String = sprintf('%d/%d',l_cursor.XData(1),size(Doppler_film,3));
                end
            case 'downarrow'
                if l_cursor.XData(1)>1
                    l_cursor.XData = l_cursor.XData-10;
%                     im.CData = Doppler_film(:,:,l_cursor.XData(1));
                    im.CData = Doppler_film(:,:,l_cursor.XData(1))*ind_keep(l_cursor.XData(1));
                    text1.String = sprintf('%d/%d',l_cursor.XData(1),size(Doppler_film,3));
                end
            case 'uparrow'
                if l_cursor.XData(1)<size(Doppler_film,3)
                    l_cursor.XData = l_cursor.XData+10;
%                     im.CData = Doppler_film(:,:,l_cursor.XData(1));
                    im.CData = Doppler_film(:,:,l_cursor.XData(1))*ind_keep(l_cursor.XData(1));
                    text1.String = sprintf('%d/%d',l_cursor.XData(1),size(Doppler_film,3));
                end
            case 'space'
                xdata = l_cursor.XData(1);
                ind_remove(xdata)= ~ind_remove(xdata);
                ind_keep(xdata)= ~ind_keep(xdata);
                %Updating lines
                l_thresh.YData = [thresh, thresh];
                l_keep.XData = t(ind_keep==1);
                l_keep.YData = test(ind_keep==1);
                l_rm.XData = t(ind_remove==1);
                l_rm.YData = test(ind_remove==1);
                text2.String = sprintf('Discarded: %d/%d (%.1f %%)',...
                    sum(ind_remove),length(ind_remove),100*sum(ind_remove)/length(ind_remove));
        end
    end

% Comment for batch
waitfor(f);
return;
% %Comment for not batch
% okButton_callback();

end