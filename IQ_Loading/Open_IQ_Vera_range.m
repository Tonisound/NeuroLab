function IQ_flat = Open_IQ_Vera_range(n_imstart,n_imstop)
% function Open_IQ_Vera_range (Thomas)
% Part loading of IQ matrices to form IQ_flat

[Seq] = openSharedFile(['run.bseq'],defineSeq());
[scanIQ] = openSharedFile(['scan.biq'],defineIQ(Seq.Data.sizeIQ));

n_block2load = n_imstop-n_imstart+1;
%Seq.Data.nbBloc * Seq.Data.Accumulation_block_Doppler;
%Initialisation de la matrice des IQ
IQ_flat = zeros(size(scanIQ.Data(1).real,1),size(scanIQ.Data(1).real,2),size(scanIQ.Data(1).real,3),n_block2load,'single');

%% Construction de la matrice des IQ 

% b=waitbar(0,'Construction of IQ array');
% for i = 1:n_block2load
%     IQ_flat(:,:,:,i) = complex(scanIQ.Data(i).real,scanIQ.Data(i).imag);
%     waitbar(i/n_block2load)
% end
% close (b)

b=waitbar(0,sprintf('Construction of IQ array [Block %d - %d]',n_imstart,n_imstop));
k=0;
for i = n_imstart:n_imstop
    k=k+1;
    IQ_flat(:,:,:,k) = complex(scanIQ.Data(i).real,scanIQ.Data(i).imag);
    waitbar(k/n_block2load)
end
close (b)

% IQ_flat = reshape(IQ_flat,size(IQ_flat,1),size(IQ_flat,2),size(IQ_flat,3),Seq.Data.Accumulation_block_Doppler,Seq.Data.nbBloc);
IQ_flat = squeeze(IQ_flat);
clear  scanIQ Seq;

% % Check SVD script
% for i = 1:size(IQ_flat,4)
% [Dop0,IQF_corrected0,IQF_tissu0]=filter_SVD(IQ_flat(:,:,:,i),60);
% imagesc(Dop0);drawnow
% end

end




