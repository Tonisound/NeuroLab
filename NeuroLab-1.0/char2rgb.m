function rgbvec = char2rgb(charcolor)
%converts a character color (one of 'r','g','b','c','m','y','k','w') to a 3
%value RGB vector

switch lower(charcolor)
    case {'r','red'}
        rgbvec = [1 0 0];
    case {'g','green'}
        rgbvec = [0 1 0];
    case {'b','blue'}
        rgbvec = [0 0 1];
    case {'c','cyan'}
        rgbvec = [0 1 1];
    case {'m','magenta'}
        rgbvec = [1 0 1];
    case {'y','yellow'}
        rgbvec = [1 1 0];
    case {'w','white'}
        rgbvec = [1 1 1];
    case {'k','black'}
        rgbvec = [0 0 0];
    case {'rand'}
        rgbvec = rand(1,3);
    otherwise
        rgbvec = str2num(charcolor);
        if isempty(rgbvec) || size(rgbvec,1)~=1 || size(rgbvec,2)~=3 || sum(rgbvec<=1)~=3 || sum(rgbvec>=0)~=3
            rgbvec = '';
        end
end
end