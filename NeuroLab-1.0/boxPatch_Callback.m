function boxPatch_Callback(src,~,handles)
% 402 -- Callback Label CheckBox

% Find all visible patches
hm = findobj(handles.CenterAxes,'Type','Patch','-and','Tag','Region');

if get(src,'Value') == 1
    for i=1:length(hm)
       %hm(i).Visible = hm(i).UserData.Trace.Visible;
       hm(i).Visible ='on';
    end
    
else
    for i=1:length(hm)
        hm(i).Visible = 'off';
    end
end

end