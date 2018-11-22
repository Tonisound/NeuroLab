function boxLabel_Callback(src,~,handles)
% 402 -- Callback Box Label

if src.Value
    labels = handles.RightAxes.XTickLabel;
    new_labels = [];
    for i=1:length(labels)
        val = str2double(char(labels(i,:)));
        str = handles.TimeDisplay.UserData(val,:);
        A = (datenum(str)-floor(datenum(str)))*24*3600;
        new_labels = [new_labels;{sprintf('%.1f',A)}];
    end
    handles.RightAxes.XTickLabel = new_labels;
    handles.RightAxes.XLabel.String = 'Time (s)';
else
    %handles.RightAxes.XTickLabel = handles.RightAxes.XTick;
    handles.RightAxes.XTickLabelMode='auto';
    handles.RightAxes.XLabel.String = '# Image';
end

end