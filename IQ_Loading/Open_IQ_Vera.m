function IQ_flat = Open_IQ_Vera()

[Seq] = openSharedFile(['run.bseq'],defineSeq());
[scanIQ] = openSharedFile(['scan.biq'],defineIQ(Seq.Data.sizeIQ));
n_block2load = Seq.Data.nbBloc * Seq.Data.Accumulation_block_Doppler;

%Initialisation de la matrice des IQ
IQ_flat = zeros(size(scanIQ.Data(1).real,1),size(scanIQ.Data(1).real,2),size(scanIQ.Data(1).real,3),n_block2load,'single');

% Construction de la matrice des IQ 
b=waitbar(0,'Construction of IQ array');
for i = 1:n_block2load
    IQ_flat(:,:,:,i) = complex(scanIQ.Data(i).real,scanIQ.Data(i).imag);
    waitbar(i/n_block2load)
end
close (b)

%reshape
IQ_flat = reshape(IQ_flat,size(IQ_flat,1),size(IQ_flat,2),size(IQ_flat,3),Seq.Data.Accumulation_block_Doppler,Seq.Data.nbBloc);
IQ_flat = squeeze(IQ_flat);

clear  scanIQ Seq