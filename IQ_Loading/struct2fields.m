function [Fields,Bytes]=struct2fields(struct)

%si structure pas défini ou pas une structure faire qqch
fieldsNames=fieldnames(struct);
Bytes=0;

sizeFieldsNames = length(fieldsNames);
%alloue l'espace
Fields = cell(sizeFieldsNames, 3);

for i=1:sizeFieldsNames    
    Fields{i,1}=class(struct.(fieldsNames{i}));
    Fields{i,2}=size(struct.(fieldsNames{i}));
    Fields{i,3}=fieldsNames{i};
    
    Bytes=Bytes+getBytes(struct.(fieldsNames{i}));
end

end

function B=getBytes(toto)
s = whos('toto');
B=s.bytes;
end