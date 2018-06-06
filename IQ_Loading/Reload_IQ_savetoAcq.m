% %Adding path if necessary
% addpath(genpath(fullfile('G:','IQ_Loading')))

function Reload_IQ_savetoAcq()
% Based on script IQ2DOP (Julien)
% execute in fus folder: opens biq file, executes SVD and forms doppler
% film


% Part Loading
[Seq] = openSharedFile(['run.bseq'],defineSeq());
[scanIQ] = openSharedFile(['scan.biq'],defineIQ(Seq.Data.sizeIQ));
n_block2load = Seq.Data.nbBloc * Seq.Data.Accumulation_block_Doppler;
ncut = input('SVD threshold : ');

% Defining block length to load IQ
block_size = 100;
ind_steps = 1:block_size:n_block2load;
% folder = 'IQ_flat';
% if ~exist(folder,'dir')
%     mkdir(folder);
% end

%multiWaitbar('IQ loading',0);
multiWaitbar('SVD completion',0);
multiWaitbar('Overall progress',0);
Doppler_film = [];

for i =1:length(ind_steps)
    % Part loading of IQ array 
    n_imstart = ind_steps(i);
    n_imstop = min(ind_steps(i)+block_size-1,n_block2load);
    IQ_Flat = Open_IQ_Vera_range(n_imstart,n_imstop);
%     filename = fullfile(folder,sprintf('IQ_flat[%06d-%06d]',n_imstart,n_imstop));
%     fprintf('Saving IQ array [Block %d - %d]...',n_imstart,n_imstop);
%     save(filename,'IQ_flat','-v7.3');
%     fprintf(' done.\n');
    
h = waitbar(0,'Please wait...');
for ii = 1:size(IQ_Flat,4)
    
    %waitbars
    x = ii/size(IQ_Flat,4);
    y = (ind_steps(i)+ii-1)/n_block2load;
    waitbar(x,h,sprintf('%.1f %% to complete SVD [Block %d/%d]',100*x,ind_steps(i)+ii-1,n_block2load));
    multiWaitbar('SVD completion','Value',x);
    multiWaitbar('Overall progress',y);
    
    %SVD
    IQ_signal = squeeze(IQ_Flat(:,:,:,ii));
    [nz, nx, nt] = size(IQ_signal);
    IQ_signal = double(reshape(IQ_signal, [nz*nx, nt]));
    cov_matrix = IQ_signal'*IQ_signal;
    [Eig_vect, Eig_val]= eig(cov_matrix);
    Eig_vect=fliplr(Eig_vect);
    Eig_val=rot90(Eig_val,2);
    M_ACP = IQ_signal*Eig_vect;    % on obtient les lambda*u
    % Removing eigenvalues
    skipped_eig_val =[1:ncut 190:200];
    
    IQF_tissu = M_ACP(:,skipped_eig_val)*Eig_vect(:,skipped_eig_val)';
    IQF_tissu = reshape(IQF_tissu, [nz, nx, nt]);
    IQ_signal = reshape(IQ_signal, [nz, nx, nt]);
    IQF_corrected = IQ_signal-IQF_tissu;
    Doppler_image = mean(sqrt(abs(IQF_corrected.^2)),3);
    Doppler_film = cat(3,Doppler_film,Doppler_image);
    
end
close(h);
end
multiWaitbar('closeall');

% saving acq file
Name = dir('*.acq');
Beta = char(Name.name);
load(Beta,'-mat');
Acquisition.Data = permute(Doppler_film,[2 4 1 3]);
%Acquisition.Data = Doppler;
fprintf('Saving acq file %s...',Beta);
save(Beta,'Acquisition','-append');
fprintf(' done.\n');

end