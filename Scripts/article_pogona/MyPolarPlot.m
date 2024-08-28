function [MeanRho,MeanAmp,pvalue]=MyPolarPlot(hax,PhaseBin,PhaseOffset,Data,Color,Alpha,Title,MEANandSEM,VectorsOn,StatOn,PlotHalfDisk)%PA Libourel 04/04/2024 plot mean and SEM shading of circular data

%hax handles of the current polar axis
%PhaseBin vector with the phase bin in rad 
%PhaseOffset add an offset in rad t to the phase
%Data [n,m] matrix with the n repetition of m phase value
%Color [r g b] or hex
%Alpha transparence value [0 1]
%Title of the axe
%if MEANandSEM is provided Data should be empty
%MEANandSEM has 2 lines with [MEAN;SEM]
%computed with a rayleight test base on the mdistribution of the phase angles.
%PlotHalfDisk =1 could disply half a disk in grey between -pi and 0
if isempty(hax)==1
    hax=polaraxes;
end
if nargin==5
    Alpha=0.5;
    Title='';
    MEANandSEM=[];
    VectorsOn=1;
    StatOn=1;
    PlotHalfDisk=1;
end
if nargin==6
    Title='';
    MEANandSEM=[];
    VectorsOn=1;
    StatOn=1;
    PlotHalfDisk=1;

end
if nargin==7
    MEANandSEM=[];
    VectorsOn=1;
    StatOn=1;
    PlotHalfDisk=1;

end
if nargin==8
    VectorsOn=1;
    StatOn=1;
    PlotHalfDisk=1;

end
if nargin==9
    StatOn=1;
    PlotHalfDisk=1;
end
if nargin==10
    PlotHalfDisk=1;
end

if isempty(MEANandSEM)
    idnotnan=~isnan(Data(:,1));
else
    idnotnan=~isnan(MEANandSEM(1,:));
end



if ischar(Color)==1
    Color=hex2rgb(Color);
end

if sum(idnotnan)~=0
    
    if isempty(MEANandSEM)
        DataOk=Data(idnotnan,:);
        MEAN=nanmean(Data,1);
        SEM=nanstd(Data,1)./sqrt(sum(~isnan(Data(:,1))));
    else% discretize the signal
        MEAN=MEANandSEM(1,:);
        SEM=MEANandSEM(2,:);
    end


    BinSize=mean(diff(PhaseBin));

    MEAN=[MEAN MEAN(1)];
    SEM=[SEM SEM(1)];
    PhaseBin=[PhaseBin PhaseBin(1)];


    polarplot(hax,PhaseBin+PhaseOffset,MEAN,'color',Color);
    set(hax,'rticklabel',{},'rlim',[0 1],'ThetaTick',[0:30:360],'ThetaTickLabel',{'0°' '' '' '90°' '' '' '180°' '' '' '270°' '' ''});
    hold on,

    
    ax_cart = axes();
    ax_cart.Position = hax.Position;
    if PlotHalfDisk==1
        X=linspace(-pi,0,100);
        
        [xl,yl] = pol2cart([X],[zeros(1,100)]);
        [xh,yh] = pol2cart(fliplr(X),[ones(1,100)]);
        fill([xl,xh],[yl,yh],'k','FaceAlpha',0.05,'EdgeAlpha',0);
        hold on;
    end
    
    if isempty(SEM)==0

        rlow = MEAN-SEM;
        rhigh = MEAN+SEM;

        
        [xl,yl] = pol2cart(PhaseBin+PhaseOffset,rlow);
        [xh,yh] = pol2cart(fliplr(PhaseBin+PhaseOffset),fliplr(rhigh));
        fill([xl,xh],[yl,yh],Color,'FaceAlpha',Alpha,'EdgeAlpha',0);
        xlim(ax_cart,[-max(get(hax,'RLim')),max(get(hax,'RLim'))]); 
        ylim(ax_cart,[-max(get(hax,'RLim')),max(get(hax,'RLim'))]);

    end


    %indiv MVL
    x2=[];
    y2=[];
    hold on;

   

    if isempty(MEANandSEM)
        ColorQuiver=[0.4 0.4 0.4];
        for nvect=1:size(DataOk,1)
             [xtmp,ytmp] = pol2cart(PhaseBin(1:end-1)+PhaseOffset,DataOk(nvect,:)*2);
             x2(nvect)=mean(xtmp);
             y2(nvect)=mean(ytmp);
             if VectorsOn==1
                l2=quiver(ax_cart,0, 0, x2(nvect), y2(nvect),'color',ColorQuiver,'linewidth',1);
             end
        end
    else
        [xtmp,ytmp] = pol2cart(PhaseBin(1:end-1)+PhaseOffset,MEAN(1:end-1));
        x2=mean(xtmp);
        y2=mean(ytmp);
        
    end

    [plv,mvl]=cart2pol(x2,y2);
    
    
   
    %Rayleigh Test with on the PLV angle (not ponderated with the MVL)
    [pvalue]= circ_rtest(plv);
    xM=mean(x2);
    yM=mean(y2);
    

     
    [MeanRho,MeanAmp] = cart2pol(xM,yM);
    [xM,yM] = pol2cart(MeanRho,MeanAmp*2);

    
        quiver(ax_cart,0, 0, xM, yM,'color',Color,'linewidth',2,'MaxHeadSize',2);
        axis square; set(ax_cart,'visible','off');
    if StatOn==1
        if pvalue<=0.001
            text(hax,0.66*pi, 0.96,sprintf('*** p = %05.4f',pvalue),'color',Color,'fontweight','bold')
        elseif pvalue>0.001 && pvalue<=0.01
            text(hax,0.66*pi, 0.96,sprintf(' ** p = %05.4f',pvalue),'color',Color,'fontweight','bold')
        elseif pvalue>0.01 && pvalue<=0.05
            text(hax,0.66*pi, 0.96,sprintf('  * p = %05.4f',pvalue),'color',Color,'fontweight','bold')
        else
            text(hax,0.66*pi, 0.96,sprintf('    p = %05.4f',pvalue),'color',Color)
        end
    end
else
    MeanRho=NaN;
    MeanAmp=NaN;
    pvalue=NaN;
end

if isempty(Title)==0
    title(hax,Title);
end
        

