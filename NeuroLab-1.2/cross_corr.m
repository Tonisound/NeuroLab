function [r,lags] = cross_corr(X,Y,max_step,step_size)
% Computes cross_correlation function between time-series X and Y
% max_step = 10 (default): window size
% step_size = 1 (default): step size

r=[];
lags=[];
X=X(:);
Y=Y(:);

if size(X,1)~=size(Y,1)
    errordlg('Input must be vector arrays of same size.');
    return;
end
    
if nargin <4
    step_size=1;
end
if nargin <3
    max_step=10;
end

lags=-max_step:step_size:max_step;
B = NaN(size(X,1),length(lags));

for index_kk = 1:length(lags)
    kk=lags(index_kk);
    if kk<0
        temp = X(abs(kk)+1:end);
        B(1:length(temp),index_kk) = temp;
    elseif kk>0
        temp = X(1:end-kk);
        B(kk+1:end,index_kk) = temp;
    else
        B(:,index_kk) = X;
    end
end

r = corr(B,Y,'rows','complete');

end