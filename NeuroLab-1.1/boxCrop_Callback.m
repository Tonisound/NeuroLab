function boxCrop_Callback(hObj,~,ax,folder_name)
% 402 -- Callback Label CropBox

global DIR_SAVE FILES CUR_FILE;
if nargin == 3
    % if folder_name not precises used global variables
    folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);
end

% Find main image
im = findobj(ax,'Tag','MainImage');

if hObj.Value
    % Find mask
    if exist(fullfile(folder_name,'Sources_fUS','Whole-reg.mat'),'file')
        d = load(fullfile(folder_name,'Sources_fUS','Whole-reg.mat'));
        mask = d.mask;
    else
        warning('Whole-reg.mat not found [%s].',folder_name);
        mask = ones(size(im.CData));
    end
    % Applying mask
    im.AlphaData = mask;
else
    % Removing mask
    im.AlphaData = 1;
end

end