% Filtrage directionnel
figure;imagesc(IM(:,:,1))
IMFFT = fftn(IM);
figure;imagesc(abs(IMFFT(:,:,1)))
IM2 = IM; IM2(isnan(IM))= 0;
IMFFT = fftn(IM2);
figure;imagesc(abs(IMFFT(:,:,1)))
figure;imagesc(abs(IMFFT(:,:,10)))
%IMFFT(:,1:50,:) = 0;
IMFFT(:,1:64,:) = 0;
IM3 = ifftn(IMFFT);
IM3 = ifftn(IMFFT,'symmetric');
figure;imagesc((IM3(:,:,10)))
figure;imagesc((IM(:,:,10)))
IM = IM3;