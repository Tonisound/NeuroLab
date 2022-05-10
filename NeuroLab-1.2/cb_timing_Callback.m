function cb_timing_Callback(hObj,~,f)

htext = findobj(f,'Type','text');
if hObj.Value
    for i =1:length(htext)
        htext(i).Visible = 'on';
    end
else
    for i =1:length(htext)
        htext(i).Visible = 'off';
    end
end

end