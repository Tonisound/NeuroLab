%Loading Doppler_film
folder = fullfile('E:','20180403_SD011_B');
filename = '20180403_SD011_B.mat';
fprintf('loading file %s ...',fullfile(folder,filename));
load(fullfile(folder,filename),'Acquisition');
fprintf(' done.\n');

%reshaping
Doppler_film = permute(Acquisition.Data,[3,1,4,2]);
% scaling
im_mean = mean(Doppler_film,3,'omitnan');
M = repmat(im_mean,1,1,size(Doppler_film,3));
Doppler_normalized = (Doppler_film-M)./M;

f = figure();
ax = axes('Parent',f);
colormap(f,'parula');
for i=1:size(Doppler_normalized,3)
    imagesc(Doppler_normalized(:,:,i),'Parent',ax);
    ax.Title.String = sprintf('Image %3d',i);
    pause(.05)
    drawnow
end
close(f);