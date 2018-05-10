function response = isuicontrol(handle)
        % ISUICONTROL returns true if the handle(s) are uicontrols.  Too awkward to
        % evaluate infinitely for cell arrays.
        % tries to convert the cell array
        if iscell(handle)
            % tries
            try
                % changes it
                newHandle = cell2mat(handle);
                % if it worked
                if all(size(newHandle) == size(handle))
                    % save it
                    handle = newHandle;
                else
                    % error on purpose
                    error('Cannot convert cell array.')
                end
            catch
            end
        end
        
        % checks if it is a handle, and that the type is uicontrol
        response = ishandle(handle);
        
        % only go any further if the input is still not a cell array
        if ~iscell(response)
            % check the type of those which are handles
            response(response) = strcmp(get(handle(response), 'Type'), 'uicontrol');
        end
end
