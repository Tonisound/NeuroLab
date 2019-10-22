function script_display_scan(subfolder)
% Example of execution: script_display_scan('scan_coro_100')
% scan_coro_100 must be in the folder specified under 'folder' variable

%folder = fullfile('F:\DATA\ATLAS_NLAB\20190228_SD025_scan',subfolder);
%folder = fullfile('F:\DATA\ATLAS_NLAB\20190307_SD025_scan',subfolder);
folder = fullfile('F:\DATA\ATLAS_NLAB\20190307_SD025_tomo',subfolder);

d = dir(fullfile(folder,'*.acq'));
load(fullfile(folder,char(d.name)),'-mat');

%tomo
Doppler_film= permute(squeeze(Acquisition.Data),[3 1 2 4]);
Doppler_film= Doppler_film(:,:,:,10);
%Doppler_film = squeeze(permute(Acquisition.Data,[3,1,4,2]));

%scan
%Doppler_film= permute(squeeze(Acquisition.Data),[3 1 2]);

% bug fix accumulation
% Doppler_film=permute(Acquisition.Data,[3 1 4 2]);
% Doppler_film = Doppler_film(:,:,1:4:end);

% slider display
f = figure('Units','normalized');
colormap(f,'gray');
ax= axes('Parent',f,'Position',[.1 .2 .8 .7]);
sld = uicontrol('Style', 'slider',...
        'Min',1,'Max',size(Doppler_film,3),'Value',1,...
        'Units','normalized',...
        'Callback', {@surfzlim,ax});
sld.SliderStep = [1/(size(Doppler_film,3)-1) .1];
sld.Position = [.1 .05 .8 .05];
sld.UserData.Doppler_film = Doppler_film;
surfzlim(sld,[],ax);

% full display
f = figure('Units','normalized');
colormap(f,'gray')
margin_w=.01;
margin_h=.01;

n_columns = 10;
n_rows = ceil(size(Doppler_film,3)/n_columns)-1;
for i = 1:n_rows
    for j = 1:n_columns
        index = (i-1)*n_columns+j;
        if index>size(Doppler_film,3)
            return;
        end
        x = mod(index-1,n_columns)/n_columns;
        % y = (floor((index-1)/n_columns))/n_rows;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax = axes('Parent',f);
        imagesc(log10(Doppler_film(:,:,index)),'Parent',ax);
        ax.Visible='off';
        ax.Position= [x+margin_w y+.2*margin_h (1/n_columns)-2*margin_w (1/n_rows)-2*margin_h];
        ax.Title.String = sprintf('%3d/%d',index,size(Doppler_film,3));
        ax.Title.Visible = 'on';
    end
end

end


function surfzlim(hObj,~,ax)

val = hObj.Value;
Doppler_film = hObj.UserData.Doppler_film;

imagesc(log10(Doppler_film(:,:,val)),'Parent',ax);
colorbar(ax);
ax.Title.String = sprintf('Plane %3d/%d',val,size(Doppler_film,3));

end