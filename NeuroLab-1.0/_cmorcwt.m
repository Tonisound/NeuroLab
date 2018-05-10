function coefs = cmorcwt(EEG,scales,Fb,Fc)

signal = EEG';

LB = -8;
UB = 8;
N = 2000;

[psi,xval] = cmorwavf(LB,UB,N,Fb,Fc);

step = xval(2)-xval(1);
psi_integ = cumsum(psi)*step;
psi_integ = conj(psi_integ);

xval                  = xval-min(xval);
dxval                 = xval(2);
xmax                  = xval(length(xval));
len                   = length(signal);
coefs                 = zeros(length(scales),len);
ind                   = 1;

for a = scales
   
    j = [1+floor([0:a*xmax]/(a*dxval))];
    if length(j)==1 , j = [1 1]; end
    f            = fliplr(psi_integ(j));
    coefs(ind,:) = -sqrt(a)*wkeep(diff(conv(signal,f)),len);
    ind          = ind+1;
  
end

