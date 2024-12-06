function success = duplicate_main_channel(F,handles,val)
% Filter LFP channels into bands defined in Gfilt (Preferences.mat)
% Compute and smooth LFP power envelopes
% User can select bands and channels manually
% Selects only main channel (if specified) in batch mode

success = false;
load('Preferences.mat','GTraces');

global DIR_SAVE;

% if val undefined, set val = 1 (default) user can select which channels to export
if nargin <3
    val = 1;
end

% Loading Nconfig.mat
file_mainlfp = fullfile(DIR_SAVE,F.nlab,'Sources_LFP',sprintf('LFP_%s.mat',F.mainlfp));
alias_mainlfp = fullfile(DIR_SAVE,F.nlab,'Sources_LFP',sprintf('LFP_%s.mat',GTraces.AliasMainLFP));

if isempty(F.mainlfp) 
    warning('Main Channel not Defined [%s]',F.nlab);
    return;
elseif ~isfile(file_mainlfp)
    warning('Missing Main Channel in Sources_LFP [%s]',F.nlab);
    return;
else
    copyfile(file_mainlfp,alias_mainlfp);
    fprintf('Main LFP Channel [%s] duplicated as [%s]. [File:%s].\n',F.mainlfp,GTraces.AliasMainLFP,F.nlab);
end

success = true;

end