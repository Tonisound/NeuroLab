function boxMask_Callback(src,~,handles)
% 402 -- Callback Label CheckBox

if get(src,'Value') == 1
    
    % Find all visible patches
    hm = findobj(handles.CenterAxes,'Type','Patch','-and','Tag','Region');
    im = findobj(handles.CenterAxes,'Tag','MainImage');
    
    hold(handles.CenterAxes,'on');
    for i =1:length(hm)
        %if strcmp(hm(i).UserData.Trace.Visible,'on')
            color = hm(i).FaceColor;
            color_mask = cat(3, color(1)*ones(size(im.CData)),color(2)*ones(size(im.CData)),color(3)*ones(size(im.CData)));
            mask = hm(i).UserData.UserData.Mask;
            image('CData',color_mask,...
                'Parent',handles.CenterAxes,...
                'Tag','Mask',...
                'Hittest','off',...
                'AlphaData',edge(mask,'canny'));
        %end
    end
    hold(handles.CenterAxes,'off');
    
else
    delete(findobj(handles.CenterAxes,'Tag','Mask'));
end

end