function [centroids_struct] = detect_centroids(fileName,t)
% Author : Marta Matei
% Modified 30/05/18
% Detect centroids in video file

v = VideoReader(fileName);
frame_start = 1;
frame_end = v.Duration*v.FrameRate-2;
frame_step = 1;

if nargin<2
    %definir t car il n'a pas ete donne par l'utilisateur
    t = frame_start:frame_step:frame_end;
end

centroids = [];
index_frames = [];
speed = [];


% mask creation
v.CurrentTime = round(v.Duration*0.10); % on choisi une frame à 10% de la video pour eviter les erreurs
image = readFrame(v);
image_gray= rgb2gray(image);
figure;
imshow(image_gray);

xdata = [];
ydata = [];
[x,y,button]=ginput(1);

while button==1
    % marker
    line(x,y,'Tag','Marker','Marker','o','MarkerSize',5,...
        'MarkerFaceColor','none','MarkerEdgeColor','w');
    % line
    if ~isempty(xdata)
        line([x,xdata(end)],[y,ydata(end)],'Tag','Line',...
            'LineWidth',1,'Color','w');
    end
    xdata = [xdata;x];
    ydata = [ydata;y];
    [x,y,button] = ginput(1);    
end

if length(xdata)>1
    line([xdata(1),xdata(end)],[ydata(1),ydata(end)],'Tag','Line',...
        'LineWidth',1,'Color','w');
end

mask = poly2mask(xdata,ydata,size(image,1),size(image,2));
image_masked = image_gray;
image_masked(~mask) = 0;  % alt + N pour le tilt
figure;
imshow(image_masked);
% pixel_value = impixel;


hist_fig = figure;
hist_axes_line = axes('Parent',hist_fig);
imhist(image_masked);
set(hist_axes_line, 'YScale', 'log');
hist_axes_line.XLim = [-5 255];
% hist_axes_line.YScale = 'log';
[xthresh,ythresh, button]=ginput(1);

while button==1
    
    cla(hist_axes_line) % clear those axes
    
    imhist(image_masked);
    set(hist_axes_line, 'YScale', 'log');
    hist_axes_line.XLim = [-5 255];
%     hist_axes_line.YScale = 'log';    
    
    t_line = line([xthresh xthresh],[hist_axes_line.YLim],'LineWidth',1,'Color','r','Parent', hist_axes_line)
    drawnow;
        

    [xthresh,ythresh, button]=ginput(1);  
    
end

thresh = round(xthresh/255,2);
v.CurrentTime =0; % on remet le currentTime Ã  sa valeur initiale

h = waitbar(0,'Computing centroids. Please wait ...');



tic
for i=t(1):t(end)%v.Duration*v.FrameRate
    
    %Update waitbar
    x = (i-t(1))/(t(end)-t(1));
    waitbar(x,h,'Computing centroids. Please wait ...');
    %     v.CurrentTime = i/v.FrameRate;
    try
        image = readFrame(v);
    catch
        v.CurrentTime
    end
    image_gray= rgb2gray(image);
    image_masked = image_gray;
    image_masked(~mask) = 0;
    bw_image = imbinarize(image_masked, thresh);
    
    s = regionprops(bw_image,'centroid');
    s_cat = cat(1,s.Centroid);
    
    centroids = cat(1,centroids,s_cat);
    index_frames = cat(1,index_frames,repmat(i,[size(s_cat,1),1]));
    
end
toc

delete(h);
save('centroids.mat', 'centroids')
save('index.mat', 'index_frames')

delay_centroids = 1/v.FrameRate;
vitesse_instant = [];
tic
for i=t(1):t(end)-1
    
    try
        vitesse_instant(i,1) = (centroids(index_frames==i+1,1)-centroids(index_frames==i,1))/delay_centroids;
        vitesse_instant(i,2) = (centroids(index_frames==i+1,2)-centroids(index_frames==i,2))/delay_centroids;
    catch
        vitesse_instant(i,1)=NaN;
        vitesse_instant(i,2)=NaN;
    end
    
    speed(i) = sqrt((vitesse_instant(i,1).^2)+(vitesse_instant(i,2).^2));
    
end
toc

centroids_struct = struct('centroids', centroids, 'index_frames', index_frames, 'speed', speed);

end

