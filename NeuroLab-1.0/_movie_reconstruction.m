function h = movie_reconstruction(Doppler_film,Doppler_1,Doppler_2,title1,title2,title3,X,Y)
% Process : Compute normalized Movie

if nargin<5
    X = NaN(size(Doppler_film,3),1);
    Y = NaN(size(Doppler_film,3),1);
end

global DIR_SAVE FILES CUR_FILE
load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Reference.mat'),'time_ref','length_burst','n_burst');

f = figure('Name','ICA & PCA Reconstruction','Units','characters','Position',[30 30 150 20],'MenuBar','none','Toolbar','none');
u = uicontrol(f,'Units','normalized','Style','text','String','0','Position',[.005 .01 .1 .05]);
u2 = uicontrol(f,'Units','normalized','Style','text','String','0','Position',[.005 .06 .1 .05]);
ax1 = axes('Position',[.1 .1 .28 .8],'Parent',f,'XTick','','XTickLabel','','YTick','','YTickLabel','');
ax2 = axes('Position',[.4 .1 .28 .8],'Parent',f,'XTick','','XTickLabel','','YTick','','YTickLabel','');
ax3 = axes('Position',[.7 .1 .28 .8],'Parent',f,'XTick','','XTickLabel','','YTick','','YTickLabel','');
ax4 = axes('Position',[.025 .17 .05 .75],'Parent',f,...
    'XTick',[0 .2],'XTickLabel',{'0','.2'},...
    'YTick',[0 2.4],'YTickLabel',{'0','2.4'});
%ax4.XLabel.String='X(m)';
%ax4.YLabel.String='Y(m)';
ax4.XLim =[0 .2];
ax4.YLim =[0 2.4];
colormap(gray);

for i = 1:size(Doppler_film,3)
    if ishandle(f)
        u.String = sprintf('%d/ %d',i,size(Doppler_film,3));
        u2.String = sprintf('Burst %d/ %d',ceil(i/length_burst),n_burst);
        imagesc(Doppler_film(:,:,i),'Parent',ax1);
        title(ax1,title1);
        imagesc(Doppler_1(:,:,i),'Parent',ax2);
        title(ax2,title2);
        imagesc(Doppler_2(:,:,i),'Parent',ax3);
        title(ax3,title3);
        ind = i+floor(i/length_burst);
        cla(ax4);
        line(Y(1:ind),X(1:ind),'Parent',ax4,'LineWidth',1,'Color',[.5 .5 .5]);
        line(Y(ind),X(ind),'Marker','.','Parent',ax4,'MarkerSize',25,'Color','k');
        if i==1
            pause(20);
        else
            pause(.001);
        end
        pause(.001)
    else
        return;
    end
    
end
close(f);
end
