function struct1 = fill_fields_from_struct(struct1,struct2)        
% Fills struct1 fields with corresponding field values from struct2
% Works even if structures are dissimilar

if length(fieldnames(struct1)) == length(fieldnames(struct2))
    % Similar structures
    struct1 = struct2;

else
    % Dissimilar structures - Looping over fields
    this_fields = fieldnames(struct2);
    for idx = 1:length(this_fields)
        aField = struct2.(this_fields{idx});
        ind_field = find(strcmp(fieldnames(struct1),this_fields{idx})==1);
        if length(ind_field)==1
            struct1.(this_fields{idx}) = aField;
        end
    end
end

end