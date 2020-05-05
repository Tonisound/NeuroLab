function boxMask_Callback(src,~,handles)
% 402 -- Callback Label CheckBox

% load('Preferences.mat','GColors');
% % Find all visible patches
% hm1 = findobj(handles.CenterAxes,'Type','Patch','-and','Tag','Region');
% hm2 = findobj(handles.CenterAxes,'Type','Patch','-and','Tag','RegionGroup');
% hm = [hm1;hm2];
% im = findobj(handles.CenterAxes,'Tag','MainImage');
% 
% for i =1:length(hm)
%     if src.Value
%         hold(handles.CenterAxes,'on');
%         color = hm(i).FaceColor;
%         %color_mask = cat(3, color(1)*ones(size(im.CData)),color(2)*ones(size(im.CData)),color(3)*ones(size(im.CData)));
%         mask = hm(i).UserData.UserData.Mask;
%         %bw = edge(mask,'canny');
%         % Extract boundaries
%         B = bwboundaries(mask);
%         for j=1:length(B)
%             boundary = B{j};
%             line('XData',boundary(:,2),'YData',boundary(:,1),...
%                 'Color',color,...
%                 'Parent',handles.CenterAxes,...
%                 'Tag','Mask',...
%                 'Hittest','off');
%             %         image('CData',color_mask,...
%             %             'Parent',handles.CenterAxes,...
%             %             'Tag','Mask',...
%             %             'Hittest','off',...
%             %             'AlphaData',edge(mask,'canny'));
%         end
%         hold(handles.CenterAxes,'off');
%     else
%         delete(findobj(handles.CenterAxes,'Tag','Mask'));
%     end
% end

% Find all visible traces
hm = findobj(handles.RightAxes,'Tag','Trace_Region',...
    '-or','Tag','Trace_RegionGroup');

% delete all masks
delete(findobj(handles.CenterAxes,'Tag','Mask'));
if src.Value
    hold(handles.CenterAxes,'on');
    for i=1:length(hm)
        if strcmp(hm(i).Visible,'on')
            color = hm(i).UserData.Graphic.FaceColor;
            mask = hm(i).UserData.Mask;
            % Extract boundaries
            B = bwboundaries(mask);
            for j=1:length(B)
                boundary = B{j};
                line('XData',boundary(:,2),'YData',boundary(:,1),...
                    'Color',color,...
                    'Parent',handles.CenterAxes,...
                    'Tag','Mask',...
                    'Hittest','off');
            end
        end
    end
    hold(handles.CenterAxes,'off');
end

end