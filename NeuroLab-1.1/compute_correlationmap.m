function [C_map,P_val] = compute_correlationmap(im,xdat,lags,Time_indices,str1,str2)
% Compute Correlation Map between all pixel in image im 
% and ref_series with different time lags specified in lags

global DIR_SAVE FILES CUR_FILE;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
catch
    warning('Missing File %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
    length_burst = size(IM,3);
    n_burst =1;
end

if nargin<5
    str1 = 'Pearson';
    str2 = 'both';
end

% Reshaping xdat 
xdat = reshape(xdat,[length_burst+1,n_burst]);
xdat = reshape(xdat(1:end-1,:),[length_burst*n_burst,1]);
xdat(Time_indices==0) = NaN;

% Reshape im as time_series
ydat = reshape(permute(im,[3,1,2]),[size(im,3) size(im,1)*size(im,2)]);
ydat(Time_indices==0,:) = NaN;

% Adding NaN Values between each burst
Xdat = [reshape(xdat,[length_burst,n_burst]);NaN(length(lags),n_burst)];
Xdat = Xdat(:);
Ydat = [reshape(ydat,[length_burst,n_burst*size(ydat,2)]);NaN(length(lags),n_burst*size(ydat,2))];
Ydat = reshape(Ydat,[(length_burst+length(lags))*n_burst, size(ydat,2)]);

% Computing Correlation Map
fprintf('Computing Correlation map (%s,%s) \nLags: %s...',str1,str2,mat2str(lags));
count=0;
C_map = NaN(size(im,1),size(im,2),length(lags));
P_val = NaN(size(im,1),size(im,2),length(lags));
for k=1:length(lags)
    t = lags(k);
    count=count+1;
    i = max(1,1+t);
    j = min(length(Xdat),length(Xdat)+t);
    i_ref = max(1,1-t);
    j_ref = min(length(Xdat),length(Xdat)-t);
    Y_sub = double(Ydat(i:j,:));
    X_sub = Xdat(i_ref:j_ref);
    [c,p] = corr(Y_sub,X_sub,'rows','pairwise','type',str1,'tail',str2);
    c = reshape(c,[size(im,1),size(im,2)]);
    p = reshape(p,[size(im,1),size(im,2)]);
    C_map(:,:,count)=c;
    P_val(:,:,count)=p;
end
fprintf('... Done.\n');
end