function compute_deformationfield(folder_name,handles)

global IM LAST_IM;
%global DIR_SAVE FILES CUR_FILE IM LAST_IM
handles.MainFigure.Pointer = 'watch';
drawnow;

fprintf('Loading Doppler_film ...\n');
load(fullfile(folder_name,'Doppler.mat'),'Doppler_film');
fprintf('Doppler film loaded from %s.\n',fullfile(folder_name,'Doppler.mat'));

Nburst = size(Doppler_film,3)/60;
Doppler_defx = nan(size(Doppler_film));
Doppler_defy = nan(size(Doppler_film));

for i=1:Nburst
    fixed = Doppler_film(:,:,1+60*(i-1));
    for j = 1:59
        moving = Doppler_film(:,:,j+60*(i-1));
        [Doppler_def,Doppler_defx(:,:,j+60*(i-1)),Doppler_defy(:,:,j+60*(i-1))] = iterate_deformationfield(fixed,moving,5,5);
        fprintf('Deformation field between image %d and %d.\n',1+60*(i-1),j+1+60*(i-1));
    end
    fprintf('Deformation field computed for Burst %d\n',i);
end

save(fullfile(folder_name,'Doppler_deformation.mat'),'Doppler_def','Doppler_defx','Doppler_defy');
fprintf('Saving Deformation Field %s \n',fullfile(folder_name,'Doppler_deformation.mat'));

str = strtrim(handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:));
if strcmp(str,'Deformation Field X')
    %Display directly Doppler_defx
    IM = Doppler_defx;
    LAST_IM = size(Doppler_defx,3);
    actualize_traces(handles);
    actualize_plot(handles);
elseif strcmp(str,'Deformation Field Y')
    %Display directly Doppler_defy
    IM = Doppler_defy;
    LAST_IM = size(Doppler_defy,3);
    actualize_traces(handles);
    actualize_plot(handles);
end

handles.MainFigure.Pointer = 'arrow';

end
        

function [def,def_h,def_v] = iterate_deformationfield(fixed,moving,k,l)

if isequal(size(fixed),size(moving))
    K = 2*k;
    L = 2*l;
    A = -K:K;
    A = repmat(A,length(A),1);
    B = -L:L;
    B = repmat(B,length(B),1);
    B = B';
    def_h = zeros(size(fixed));
    def_v = zeros(size(fixed));
    def = zeros(2*K+1,2*L+1,length(fixed(:)));
    count=0;
    for i = 1+k:size(fixed,1)-k
        for j = 1+l:size(fixed,2)-l
            count=count+1;
            def_flat = xcorr2(fixed(i-k:i+k,j-l:j+l),moving(i-k:i+k,j-l:j+l));
            def_flat = def_flat/sum(sum(def_flat,1),2);
            def(:,:,count) = def_flat/sum(sum(def_flat,1),2);
            x=sum(sum(def_flat.*A,1),2);
            y=sum(sum(def_flat.*B,1),2);
            def_h(i,j) = x;
            def_v(i,j) = y;
        end
    end
else
    errordlg('Non matching images.\n Impossible to compute deformation field.');
    return;
end
end

