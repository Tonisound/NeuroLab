function [ind_rm_final,thresh_out] = check_Doppler(Doppler_film,ind_rm_initial,thresh_in)

global CUR_IM;

ind_rm_final = [];
thresh_out = [];

% Check fUS
% Removing data points where variance is too high
t = (1:size(Doppler_film,3))';
test = permute(mean(mean(Doppler_film,2,'omitnan'),1,'omitnan'),[3,1,2]);


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
clrmenu(f);
ax1 = axes('Position',[.025 .2 .2 .75],'Visible','off','Parent',f);
im  = imagesc(Doppler_film(:,:,1),'Parent',ax1);
ax1.Visible = 'off';
%colormap(ax1,'gray');

text1 = uicontrol('Style','text','Units','normalized','String','','Position',[.025 .1 .2 .075],'Parent',f);
text1.String = sprintf('Frame %d/%d',CUR_IM,size(Doppler_film,3));
text2 = uicontrol('Style','text','Units','normalized','String','','Position',[.025 .025 .2 .075],'Parent',f);
text2.String = sprintf('Discarded frames %d/%d (%.1f %%)',...
    sum(ind_remove),length(ind_remove),100*sum(ind_remove)/length(ind_remove));
text3 = uicontrol('Style','text','Units','normalized','String','','Position',[.1 .95 .8 .04],'Parent',f);
text3.String = 'Drag/drop cursor and threshold.Arrows to move cursor. Press enter to discard/include cursor frame';


ax2 = axes('Position',[.25 .2 .7 .75],'Parent',f);
ax2.XLim = [.5,size(Doppler_film,3)+5];
ax2.YLim = [min(test),max(test)];
ax2.UserData = [];

line('XData',t,'YData',test,'Color','k','LineWidth',1,'Parent',ax2);
l_thresh = line('XData',[.5,size(Doppler_film,3)+5],'YData',[thresh,thresh],...
    'Color',[.5 .5 .5],'LineWidth',3,'Parent',ax2,'HitTest','on');
l_cursor = line('XData',[CUR_IM CUR_IM],'YData',[min(test),max(test)],...
    'Color',[.5 .5 .5],'LineWidth',1,'Parent',ax2,'HitTest','on');
l_keep = line('XData',t(ind_keep==1),'YData',test(ind_keep==1),...
    'Color','b','LineStyle','none','Marker','o','Parent',ax2,'HitTest','on');
l_rm = line('XData',t(ind_remove==1),'YData',test(ind_remove==1),...
    'Color','r','LineStyle','none','Marker','o','Parent',ax2,'HitTest','on');

okButton = uicontrol('Style','pushbutton','Units','normalized',...
    'Position',[.2 .025 .2 .1],'String','OK',...
    'Tag','okButton','Parent',f);
skipButton = uicontrol('Style','pushbutton','Units','normalized',...
    'Position',[.4 .025 .2 .1],'String','Skip',...
    'Tag','cancelButton','Parent',f);
cancelButton = uicontrol('Style','pushbutton','Units','normalized',...
    'Position',[.6 .025 .2 .1],'String','Cancel',...
    'Tag','cancelButton','Parent',f);
cancelButton.Enable = status;

set(okButton,'Callback',{@okButton_callback});
set(skipButton,'Callback',{@skipButton_callback});
set(cancelButton,'Callback',{@cancelButton_callback});

% Interactive control
set(ax2,'ButtonDownFcn',{@axes_clickFcn});
set(l_cursor,'ButtonDownFcn',{@click_l_cursor});
set(l_thresh,'ButtonDownFcn',{@click_l_thresh});
set(l_rm,'ButtonDownFcn',{@click_l_keeprm});
set(l_keep,'ButtonDownFcn',{@click_l_keeprm});
set(f,'KeyPressFcn',{@key_pressFcn});

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
        text2.String = sprintf('Discarded frames %d/%d (%.1f %%)',...
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
                    im.CData = Doppler_film(:,:,round(pt_rp(1,1)));
                    text1.String = sprintf('%d/%d',round(pt_rp(1,1)),size(Doppler_film,3));
                end
            case 2
                % Move thresh
                if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
                    thresh = pt_rp(1,2);
                    ind_remove = test>thresh;
                    ind_keep = test<=thresh;
                    %Updating lines
                    l_thresh.YData = [thresh, thresh];
                    l_keep.XData = t(ind_keep==1);
                    l_keep.YData = test(ind_keep==1);
                    l_rm.XData = t(ind_remove==1);
                    l_rm.YData = test(ind_remove==1);
                    text2.String = sprintf('Discarded frames %d/%d (%.1f %%)',...
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
            im.CData = Doppler_film(:,:,round(pt_rp(1,1)));
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
                    im.CData = Doppler_film(:,:,l_cursor.XData(1));
                    text1.String = sprintf('%d/%d',l_cursor.XData(1),size(Doppler_film,3));
                end
            case 'rightarrow'
                if l_cursor.XData(1)<size(Doppler_film,3)
                    l_cursor.XData = l_cursor.XData+1;
                    im.CData = Doppler_film(:,:,l_cursor.XData(1));
                    text1.String = sprintf('%d/%d',l_cursor.XData(1),size(Doppler_film,3));
                end
            case 'downarrow'
                if l_cursor.XData(1)>1
                    l_cursor.XData = l_cursor.XData-10;
                    im.CData = Doppler_film(:,:,l_cursor.XData(1));
                    text1.String = sprintf('%d/%d',l_cursor.XData(1),size(Doppler_film,3));
                end
            case 'uparrow'
                if l_cursor.XData(1)<size(Doppler_film,3)
                    l_cursor.XData = l_cursor.XData+10;
                    im.CData = Doppler_film(:,:,l_cursor.XData(1));
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
                text2.String = sprintf('Discarded frames %d/%d (%.1f %%)',...
                    sum(ind_remove),length(ind_remove),100*sum(ind_remove)/length(ind_remove));
        end
    end

waitfor(f);
return;

end