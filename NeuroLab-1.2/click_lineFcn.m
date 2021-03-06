function click_lineFcn(hObj,~,handles)
% Interactive Callback when user clicks on line

% Changing the Selected Property
hObj.UserData.Selected = 1-hObj.UserData.Selected;
actualize_line_aspect(hObj);

switch hObj.Tag
    case {'Trace_Region';'Trace_RegionGroup'}
        %disp('region');
        click_RegionFcn(hObj.UserData.Graphic,[],handles);
        
    case 'Trace_Box'
        %disp('box')
        click_PatchFcn(hObj.UserData.Graphic,[],handles);
        
    case 'Trace_Pixel'
       %disp('pixel')
       click_PixelFcn(hObj.UserData.Graphic,[],handles);
       
    otherwise
        %disp('other')
end

end