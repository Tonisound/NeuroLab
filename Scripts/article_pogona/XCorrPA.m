function [TLag,TWin,XCorrMat,XCorrPeak,thisPos,thisNeg]=XCorrPA(Data,Fs,WinSec,StepSec,MaxLagSec,NormWinMin)
%PA libourel 14/11/2024
%modified by A Bergel 25/11/2024
% 
%this function compute the Xcorr (Auto or Xcorr) and returne the XCorrMat with the mean peak amp and lag
%Data is one (autoCorr) or two lines (Xcorr) matrix
%Fs: sampling rate
%Winsec : size of the windows in sec
%StepSec: step for trhe xcorr in sec
%MaxLagSec: max lag in sec
%NormWinMin: size of the zscore sliding win in minutes could be empty of no zscore norm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%zscore normalization
if isempty(NormWinMin)==0
     NormS=(Data(1,:)-movmean(Data(1,:),NormWinMin*60*Fs))./movstd(Data(1,:),NormWinMin*60*Fs);
     
     if size(Data,1)==2
        NormS2=(Data(2,:)-movmean(Data(2,:),NormWinMin*60*Fs))./movstd(Data(2,:),NormWinMin*60*Fs);
        Normtype=2;

     else
        Normtype=1;
        NormS2=NormS;
     end
else  %no zscore normalization
    if size(Data,1)==1
        NormS=Data(1,:);
        NormS2=Data(1,:);
    elseif size(Data,1)==2
        NormS=Data(1,:);
        NormS2=Data(2,:);

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Xcorr normalization  type
if size(Data,1)==1 %autocorr
    Normtype=1; % normalize from the zeros lag value
elseif size(Data,1)==2  %xcorr
    Normtype=2; % biased normalisation
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute xcorr map
[TLag,TWin,XCorrMat]=timewindow_xcorr(NormS,NormS2,Fs,WinSec,StepSec,MaxLagSec,Normtype);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute mean xcorr
% if size(Data,1)==1
%     %smooth with a 10 sample window
%     MeanXcorr=movmean(nanmean(XCorrMat,1),10);
% elseif size(Data,1)==2
%     MeanXcorr=nanmean(XCorrMat,1);
% end
MeanXcorr=nanmean(XCorrMat,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%detect positive peak
[Locpos,P] = islocalmax(MeanXcorr,'SamplePoints',TLag,'MinProminence',0.05);
% Locpos=Locpos & MeanXcorr>0;
Amp=MeanXcorr(Locpos);
LocPosidx=find(Locpos==1);
Loc=TLag(Locpos);
P=P(Locpos);
MidId=ceil(length(MeanXcorr)/2);


if isempty(Loc)==0
    
    if size(Data,1)==1   %autocorrelation     
        LocMax=find(Loc>(StepSec*2),1,'first');
        [MinXCorr,minId]=min(MeanXcorr(MidId:LocPosidx(LocMax)));
        if isempty(minId)
            MinXCorr=NaN;
            MinLag=NaN;
        else
            MinLag=TLag(minId+MidId);
        end
        
    else %crosscorrelation

        %the highest prominence
        [~,LocMax]=max(P);
        
    end
else
    LocMax=[];
end

XCorrPeak.MeanXcorr=MeanXcorr;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% detect negative peak  
if isempty(LocMax)==0
    XCorrPeak.Pos=[Loc(LocMax) Amp(LocMax)];
  
    if size(Data,1)==1   %autocorrelation     
         XCorrPeak.Neg=[MinLag MinXCorr];
    else  %xcorr
        XCorrPeak.Neg=[NaN NaN];
    end

else
    XCorrPeak.Pos=[NaN NaN];
    XCorrPeak.Neg=[NaN NaN];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Repeat for each XCorrMat row
thisPos = NaN(size(XCorrMat,1),2);
thisNeg = NaN(size(XCorrMat,1),2);

for i = 1: size(XCorrMat,1)
    
    thisXcorr = XCorrMat(i,:);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %detect positive peak
    [Locpos,P] = islocalmax(thisXcorr,'SamplePoints',TLag,'MinProminence',0.05);
    % Locpos=Locpos & MeanXcorr>0;
    Amp=thisXcorr(Locpos);
    LocPosidx=find(Locpos==1);
    Loc=TLag(Locpos);
    P=P(Locpos);
    MidId=ceil(length(thisXcorr)/2);


    if isempty(Loc)==0
        if size(Data,1)==1   %autocorrelation
            LocMax=find(Loc>(StepSec*2),1,'first');
            [MinXCorr,minId]=min(thisXcorr(MidId:LocPosidx(LocMax)));
            if isempty(minId)
                MinXCorr=NaN;
                MinLag=NaN;
            else
                MinLag=TLag(minId+MidId);
            end
        else %crosscorrelation
            %the highest prominence
            [~,LocMax]=max(P);
        end
    else
        LocMax=[];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % detect negative peak
    if isempty(LocMax)==0
        thisPos(i,:)=[Loc(LocMax) Amp(LocMax)];

        if size(Data,1)==1   %autocorrelation
            thisNeg(i,:)=[MinLag MinXCorr];
        else  %xcorr
            thisNeg(i,:)=[NaN NaN];
        end

    else
        thisPos(i,:)=[NaN NaN];
        thisNeg(i,:)=[NaN NaN];
    end
end

end
