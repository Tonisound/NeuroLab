function charcolor = rgb2char(rgbvec)
%converts a 3 value RGB vector to a character color 
%(one of 'r','g','b','c','m','y','k','w')
if isnumeric(rgbvec) && size(rgbvec,1)==1 && size(rgbvec,2)==3 && sum(rgbvec<=1)==3 && sum(rgbvec>=0)==3
    %charcolor = mat2str(rgbvec,2);
    switch mat2str(rgbvec,2);
        case '[1 0 0]'
            charcolor = 'red';
        case '[0 1 0]'
            charcolor = 'green';
        case '[0 0 1]'
            charcolor = 'blue';
        case '[0 1 1]'
            charcolor = 'cyan';
        case '[1 0 1]'
            charcolor = 'magenta';
        case '[1 1 0]'
            charcolor = 'yellow';
        case '[1 1 1]'
            charcolor = 'white';
        case '[0 0 0]'
            charcolor = 'black';
        otherwise
            charcolor = sprintf('[%0.2f %0.2f %0.2f]',rgbvec(1,1),rgbvec(1,2),rgbvec(1,3));
    end
else
    charcolor = '';
end

end