%IQ to Doppler
% Script by Julien 
addpath(genpath(fullfile('X:','IQ_Loading')))
ncut = input('SVD threshold : ');
IQ_Flat = Open_IQ_Vera;

h = waitbar(0,'Please wait...');
for ii = 1:size(IQ_Flat,4)
    
    %ii
    x = ii/size(IQ_Flat,4);
    waitbar(x,h,sprintf('%.1f %% to complete (%d/%d)',100*x,ii,size(IQ_Flat,4)));
    
    IQ_signal = squeeze(IQ_Flat(:,:,:,ii));
    [nz, nx, nt] = size(IQ_signal);
    IQ_signal = double(reshape(IQ_signal, [nz*nx, nt]));
    cov_matrix = IQ_signal'*IQ_signal;
    [Eig_vect, Eig_val]= eig(cov_matrix);
    Eig_vect=fliplr(Eig_vect);
    Eig_val=rot90(Eig_val,2);
    M_ACP = IQ_signal*Eig_vect;    % on obtient les lambda*u
    
    skipped_eig_val =[1:ncut 190:200];
    
    IQF_tissu = M_ACP(:,skipped_eig_val)*Eig_vect(:,skipped_eig_val)';
    IQF_tissu = reshape(IQF_tissu, [nz, nx, nt]);
    IQ_signal = reshape(IQ_signal, [nz, nx, nt]);
    IQF_corrected = IQ_signal-IQF_tissu;
    
    Doppler(:,:,ii)=mean(sqrt(abs(IQF_corrected.^2)),3);
    
end
close(h);

Name = dir('*.acq');
Beta = char(Name.name);
load(Beta,'-mat');
Acquisition.Data = permute(Doppler,[2 4 1 3]);
%Acquisition.Data = Doppler;
save(Beta,'Acquisition','-append');