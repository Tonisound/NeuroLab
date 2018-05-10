function movie_deformation(Doppler_film,Doppler_defx,Doppler_defy)

global DIR_SAVE FILES CUR_FILE
load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Reference.mat'),'time_ref','length_burst','n_burst');

f = figure('Name','Compute deformation field','Units','characters','Position',[10 10 120 40],'MenuBar','none','Toolbar','none');
u = uicontrol(f,'Units','normalized','Style','text','String','0','Position',[.005 .01 .1 .05]);
u2 = uicontrol(f,'Units','normalized','Style','text','String','0','Position',[.005 .06 .1 .05]);
ax1 = subplot(2,2,1,'Parent',f);
ax2 = subplot(2,2,2,'Parent',f);
ax3 = subplot(2,2,3,'Parent',f);
ax4 = subplot(2,2,4,'Parent',f);
colormap('gray');

for i = 1:size(Doppler_film,3)
    if ishandle(f)
        u.String = sprintf('%d/ %d',i,size(Doppler_film,3));
        u2.String = sprintf('Burst %d/ %d',ceil(i/length_burst),n_burst);
        imagesc(Doppler_film(:,:,i),'Parent',ax1);
        title(ax1,'Raw Movie');
        imagesc(Doppler_film(:,:,i)-Doppler_film(:,:,1),'Parent',ax2);
        title(ax2,'Difference Movie');
        imagesc(Doppler_defy(:,:,i),'Parent',ax3);
        title(ax3,'Vertical Deformation');
        colorbar(ax3,'south');
        imagesc(Doppler_defx(:,:,i),'Parent',ax4);
        title(ax4,'Horizontal Deformation');
        colorbar(ax4,'south');
        
        pause(.001);    
    else
        return;
    end
    
end
close(f);

end
