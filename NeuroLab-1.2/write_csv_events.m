function write_csv_events(output_file,R,EventHeader,MetaData)
% Write array to csv file
% Text separator = ',';

if nargin < 4
    MetaData=[];
end
if nargin < 3
    EventHeader=[];
end

mlines = size(MetaData,1);
elines = size(R,1);

fid = fopen(output_file,'w');
fwrite(fid,sprintf('MetadataLines,%d',mlines));
fwrite(fid,newline);
fwrite(fid,sprintf('NumEvents,%d',elines));

% Metadata
for k=1:mlines
    fwrite(fid,newline);
    fwrite(fid,sprintf('%s',char(MetaData(k,:))));
end
% Event Header
if ~isempty(EventHeader)
    ehline = [];
    for j=1:length(EventHeader)
        ehline = strcat(ehline,sprintf('%s',char(EventHeader(j))),',');
    end
    ehline=ehline(1:end-1);
    fwrite(fid,newline);
    fwrite(fid,ehline);
end
% Events
for i=1:size(R,1)
    hline = [];
    for j=1:size(R,2)
        hline = strcat(hline,sprintf('%.4f',R(i,j)),',');
    end
    hline=hline(1:end-1);
    fwrite(fid,newline);
    fwrite(fid,hline);
end
fclose(fid);

end