function Trials = read_trialcodes(session_date,code_trial_start)
if ismac
    [~,eventfile] = get_files('/Volumes/bichanw/SpikeSorting/EventMat/all_events',['*' session_date '*']);
else
    [~,eventfile] = get_files('~/SpikeSorting/EventMat/all_events',['*' session_date '*']);
end
load(eventfile{1});

% initiation
NCodes = numel(eventmatT.times);
NTrials = 0;
Trials.code = zeros(1e3,6);
Trials.time = zeros(1e3,6);
code_trial_start = [1 14 35 48];

% read codes
for iCode = 1:NCodes

	code = eventmatT.code(iCode);
	time = int64(eventmatT.times(iCode)*1000);

	% trial onset with fixation
	if ismember(code,code_trial_start)
		NTrials = NTrials + 1;
		iCode_in_trial = 1;
	% other events
	else
		iCode_in_trial = iCode_in_trial + 1;
	end

	Trials.code(NTrials,iCode_in_trial) = code;
	Trials.time(NTrials,iCode_in_trial) = time;

end

% clear extra trials
Trials.code(NTrials+1:end,:) = [];
Trials.time(NTrials+1:end,:) = [];

% label the trials
Trials = label_trials(Trials);