function menuFiles_Prev_Callback(~,~,handles)

val = handles.FileSelectPopup.Value;
if val>1
    handles.FileSelectPopup.Value = val-1;
    fileSelectionPopup_Callback(handles.FileSelectPopup,[],handles);
end

end