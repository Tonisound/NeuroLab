function menuEdit_Delete_SourcesLFP(foldername,handles)

if exist(fullfile(foldername,'Sources_LFP'),'dir')
    delete(findobj(handles.RightAxes,'Tag','Trace_Cerep'));          
    rmdir(fullfile(foldername,'Sources_LFP'),'s');
    fprintf('LFP directory cleared [%s].\n',fullfile(foldername,'Sources_LFP'));
else
    Warning('LFP directory missing [%s].',fullfile(foldername,'Sources_LFP'));
end

end