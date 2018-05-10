function menuFiles_Next_Callback(~,~,handles)

val = handles.FileSelectPopup.Value;
if val<size(handles.FileSelectPopup.String,1)
    handles.FileSelectPopup.Value = val+1;
    fileSelectionPopup_Callback(handles.FileSelectPopup,[],handles);
end

end