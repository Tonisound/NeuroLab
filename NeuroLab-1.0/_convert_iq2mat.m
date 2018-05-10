function [mat_file,n_burst] = convert_iq2mat(dir_name,IQ)
% Generation d'un fichier Doppler.mat a partir des matrices IQ
% Possibilite de controler la resolution et le type de filtrage
    
    load(fullfile(dir_name,'UF.mat'));
    NbFrames = UF.NbFrames;
    TotalFrames = UF.TotalFrames;
    resolution = 100;  %Resolution of HD movie in ms
    hd_frames = round(UF.FrameRateUF*resolution/1000);
    fcut = 60; % Hz
    count=1;
    mat_file ='Doppler_HD.mat';

    temp = dir(dir_name);
    n_burst = 0;
    
    disp(sprintf('IQ ====> MAT : %s ',dir_name));
    %burst_list = [];
    for i=1: length(temp)
        a = temp(i).name;
        if (length(a)>10 && strcmp(a(1:10),'IQandMore_'))
            %burst_list = [burst_list;str2num(a(11:13)),str2num(a(15:17))];
            n_burst = n_burst+1;
            burst_list(n_burst).name = a;
            burst_list(n_burst).plane = str2num(a(11:13));
            burst_list(n_burst).number = str2num(a(15:17));
        end
    end

   
    n_image=0;
    for i=1:n_burst
        load(sprintf('%s/IQandMore_%03d_%03d.mat',dir_name,burst_list(i).plane,burst_list(i).number));
        
        for k=1:hd_frames:TotalFrames-NbFrames+1 %30 blocs de 200 images pour utiliser les 6000 images dispo

            IQ_flat = IQ(:,:,k:k+NbFrames-1);
            Doppler_HD = filter_SVD(IQ_flat,fcut);
            Doppler_film_HD(:,:,count) = [Doppler_HD];
            n_image = n_image +1;
            count=count+1;
            m=log10(min(Doppler_HD(find(~isnan(Doppler_HD) & Doppler_HD~=0))));
            M=log10(max(Doppler_HD(find(~isnan(Doppler_HD) & Doppler_HD~=0))));

            imodop_HD=squeeze(Doppler_HD(:,:));

            figure(1);
            title(dir_name);
            imagesc(log10(imodop_HD));
            colormap hot;
            colorbar;
            title(sprintf('SVD HD - Burst %d Image %d (from IQ image %d to IQ image%d)',i,n_image,k,k+NbFrames-1));
            caxis([m M]);
            drawnow;
            
        end
        disp(sprintf('Burst %d : OK',i))
        Doppler_film_HD(:,:,count) = zeros(size(Doppler_HD,1),size(Doppler_HD,2));
        count=count+1;
        n_image=0;
    end
    
    if exist('Doppler_film_HD','var')>0
        save([dir_name,'/',mat_file],'Doppler_film_HD','burst_list');
        fprintf('File .mat saved @ %s',[dir_name,'/',mat_file]);
    else
        fprintf('Impossible to create MAT File : Missing IQ files\n');
    end

end