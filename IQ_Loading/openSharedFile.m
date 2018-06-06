function [Map]=openSharedFile(filename,struct)

% disp(['Waiting for Shared ' filename ])    
% found = 0;
% while found==0
%    found=(exist(filename,'file')~=0);
%    pause(0.1);
% end
    
Fields=struct2fields(struct);

Map = memmapfile(filename,...
    'Writable',true,...
    'Format',Fields);

end