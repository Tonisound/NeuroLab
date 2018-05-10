function increment_decrement(hObj,evnt)

vs = round(str2double(get(hObj,'String')));
switch evnt.Key
    case 'rightarrow',
        hObj.String = vs+1;
    case 'leftarrow',
        hObj.String = vs-1;
    case 'uparrow',
        hObj.String = vs+10;
    case 'downarrow',
        hObj.String = vs-10;
end
end