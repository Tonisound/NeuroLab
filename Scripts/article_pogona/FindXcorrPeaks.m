function XCorr=FindXcorrPeaks(tLag,MeanXcorr,MinProminence,AutoCorrOn,dispOn)

%this function detect the negtative and positive peak from Xcorr and autocorr
%tlag is a time vector in sec
%MeanXcorr is a vector with the xcorr amplitude for each lag
%min prominence is the minimum Prominence used to detect the peak (default 0.01)
%AutoCorrOn is 1 if autocorrelation and 1 of Xcorr
%dispOn = 1 to display the peaks and value on the current axis 

if nargin==4
    dispOn=0;
end

[Locpos,P] = islocalmax(MeanXcorr,'SamplePoints',tLag,'MinProminence',MinProminence);

%% detect positive peak
Amp=MeanXcorr(Locpos);
LocPosidx=find(Locpos==1);
Loc=tLag(Locpos);
P=P(Locpos);
MidId=ceil(length(MeanXcorr)/2);

if isempty(Loc)==0
    
    if AutoCorrOn==1   %autocorrelation     
        LocMax=find(Loc>0,1,'first');
        [MinXCorr,minId]=min(MeanXcorr(MidId:LocPosidx(LocMax)));
        if isempty(minId)
            MinXCorr=NaN;
            MinLag=NaN;
        else
            MinLag=tLag(minId+MidId);
        end
        
    elseif AutoCorrOn==0 %crosscorrelation

        
        %the highest prominence
        [~,LocMax]=max(P);
        
    end
else
    LocMax=[];
end

%% detect the negative peak if a positive has been detected
    
if isempty(LocMax)==0
    XCorr.tLag=tLag;
    XCorr.MeanXcorr=MeanXcorr;
    XCorr.XcorrPeak=[Loc(LocMax) Amp(LocMax)];
   
    if dispOn==1
        hold on;
        plot(XCorr.XcorrPeak(1),XCorr.XcorrPeak(2),'ok');
    end
    
     if AutoCorrOn==1   %autocorrelation     
        XCorr.XcorrPeakNeg=[MinLag MinXCorr];
         if dispOn==1
            plot(XCorr.XcorrPeakNeg(1),XCorr.XcorrPeakNeg(2),'sk');
         end
     elseif AutoCorrOn==0
         XCorr.XcorrPeakNeg=[NaN NaN];
     end

else
    XCorr.tLag=NaN(1,length(MeanXcorr));
    XCorr.MeanXcorr=NaN(1,length(MeanXcorr));
    XCorr.XcorrPeak=[NaN NaN];
    XCorr.XcorrPeakNeg=[NaN NaN];

 end