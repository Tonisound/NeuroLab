function [psi,X] = cmorwavff(LB,UB,N,vart,Fc) 
% Compute values of the Complex Morlet wavelet. 
X = linspace(LB,UB,N);  % wavelet support. 
% psi = ((pi*vart)^(-1/2))*exp(2i*pi*Fc*X).*exp(-(X.*X)/vart); %Samir
psi = ((pi*vart)^(-0.5))*exp(2*1i*pi*Fc*X).*exp(-(X.*X)/vart);%le bon
% psi = ((pi*vart)^(-1/4))*exp(-2i*pi*Fc*X).*exp(-(X.*X)/(2*vart));%Samir2
% psi = ((pi*vart)^(-1/4))*exp(2i*pi*Fc*X).*exp(-(X.*X)/(2*vart));%Jéremie 


