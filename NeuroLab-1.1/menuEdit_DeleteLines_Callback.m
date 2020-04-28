function menuEdit_DeleteLines_Callback(~,~,handles,val)

switch val
    case 1
        l = findobj(handles.RightAxes,'Tag','Trace_Pixel','-or','Tag','Trace_Box');
        for i = 1:length(l)
            delete(l(i).UserData.Graphic);
            delete(l(i));
        end
    case 2
        l = findobj(handles.RightAxes,'Tag','Trace_Region');
        for i = 1:length(l)
            delete(l(i).UserData.Graphic);
            delete(l(i));
        end
    case 3
        l = findobj(handles.RightAxes,'Tag','Trace_RegionGroup');
        for i = 1:length(l)
            delete(l(i).UserData.Graphic);
            delete(l(i));
        end
    case 4
        l = findobj(handles.RightAxes,'Tag','Trace_Cerep');
        for i = 1:length(l)
            delete(l(i));
        end
end

end