function [C_map,P_val] = compute_correlogramm(series,lags)
% Compute Correlogramm between all vectors in series 
% with different time lags specified in lags

fprintf('Computing Correlogram with delays %s...',mat2str(lags));

C_map = NaN(size(series,2),size(series,2),length(lags));
P_val = NaN(size(series,2),size(series,2),length(lags));

for k=1:size(series,2)
    count=0;
    ref_series = series(:,k);
    for t=lags
        count=count+1;
        i = max(1,1+t);
        j = min(length(ref_series),length(ref_series)+t);
        i_ref = max(1,1-t);
        j_ref = min(length(ref_series),length(ref_series)-t);
        series_sub = series(i:j,:);
        ref_series_sub = ref_series(i_ref:j_ref);
        [c,p] = corr(series_sub,ref_series_sub,'rows','complete');
        C_map(k,:,count)=c';
        P_val(k,:,count)=p';
    end
end
fprintf('... Done.\n');
end