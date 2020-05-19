function nwb = read_events(nwb,pl2_path,event_info)
% read all events, convert from binary to base 10
eventmat = read_pl2_events(pl2_path.raw);

% convert all time points to a trial-structured matrix
trialmat = codes2trials(eventmat,event_info.trial_start_code);
trialmat.time = double(trialmat.time) / 1000;

% trial start and stop
start_time = trialmat.time(:,1);
stop_time  = max(trialmat.time,[],2);
colnames = {'start_time','stop_time'};

% initial trial 
trials = types.core.TimeIntervals(...
	'description', 'trial data and properties',...
	'id',types.hdmf_common.ElementIdentifiers('data', 0:size(trialmat.code,1)-1),...
	'start_time',types.hdmf_common.VectorData('data',start_time,'description','start time of each trial'),...
	'stop_time', types.hdmf_common.VectorData('data',stop_time,'description','stop time of each trial'));


%% full matrix
% because event coding is vastly different for experiment, I'm using generic terms here, loop column
% we should expect similar type of events (cue / target) to be in the same column of trialmat
% hence marked as different event 
% 
% inevitably there will be mistakes (e.g. if animal breaks mid-trial, the column that usually says
% target would say break instead)
% 

for iEvent = 1:size(trialmat.code,2)
	if isempty(event_info.names)
		name_time = ['event' num2str(iEvent) '_time'];
		name_code = ['event' num2str(iEvent) '_code'];
	else
		name_time = [event_info.names{iEvent} '_time'];
		name_code = [event_info.names{iEvent} '_code'];
	end
	colnames = [colnames {name_time,name_code}];

	trials.vectordata.set(name_time,types.hdmf_common.VectorData('data',trialmat.time(:,iEvent),'description','.'));
	trials.vectordata.set(name_code,types.hdmf_common.VectorData('data',trialmat.code(:,iEvent),'description','.'));
end

trials.colnames = colnames;
nwb.intervals_trials = trials;
end


function Trials = codes2trials(eventmatT,code_trial_start)
% convert all time points to a trial-structured matrix
% each row represent a trial
% 

    % if start code not defined, treat every event as an individual trial
	if nargin<2 || isempty(code_trial_start)
		Trials.time = eventmatT.times;
        Trials.code = eventmatT.code;
        return
	end

	% initiation
	NCodes = numel(eventmatT.times);
	NTrials = 0;
	Trials.code = nan(1e3,100);
	Trials.time = nan(1e3,100);


	% read codes
	for iCode = 1:NCodes

		code = eventmatT.code(iCode);
		time = int64(eventmatT.times(iCode));

        
		% trial onset with fixation
		if ismember(code,code_trial_start)
			NTrials = NTrials + 1;
			% allocate more space
            if NTrials > size(Trials.code,1)
                Trials.code = [Trials.code; nan(1e3,100)];
                Trials.time = [Trials.time; nan(1e3,100)];
            end
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

	% clear extra events
	n_events_max = find(sum(~isnan(Trials.code),1)>0,1,'last');
	Trials.code(:,n_events_max+1:end) = [];
	Trials.time(:,n_events_max+1:end) = [];

end


function eventmatT = read_pl2_events(OpenedFileName)
% Read all event times and corresponding event codes stored as a binary 
% variable across Plexon EVT event variables in a Plexon PL2 file
%
% Inputs:
% - OpenedFileName: path to Plexon PL2 data file on filesystem
%
% Outputs:
% - eventmatT.eventTimes: 1 x N array of event times (in seconds)
% - eventmatT.eventCodes: 1 x N array of event codes (in base 10) associated with
%               		  each event time
%

    % read header information of PL2 file
    dataInfo = PL2GetFileIndex(OpenedFileName);

    % access and store event times for each event variable in PL2 file (has
    % format EVTxx) where xx is 01, 02, ...
    nEventCh = 1;
    % fprintf('Found event variables: ');
    for i = 1:numel(dataInfo.EventChannels)    
        if strcmp(dataInfo.EventChannels{i}.Name, sprintf('EVT%02d', nEventCh))

            ts = PL2EventTs(OpenedFileName, dataInfo.EventChannels{i}.Name);
            D.events{nEventCh} = ts.Ts;
            nEventCh = nEventCh + 1;
        end
    end
    % fprintf('\n');

    % get all event times (assumes that an event that triggers different event
    % variables have the EXACT same time)
    eventTimes = unique(cat(1, D.events{:}));

    nEvent = numel(eventTimes);
    eventCodes = nan(nEvent, 1);
    for i = 1:nEvent
        timeMatches = cellfun(@(x) any(eventTimes(i) == x), D.events(numel(D.events):-1:1)); % reverse event order to get proper binary code (EVT1 is rightmost)
        eventCodes(i) = bin2dec(num2str(timeMatches, '%d')); % convert from logical to decimal (00001110 to 14)
    end
    eventmatT.code=eventCodes;
    eventmatT.times=int64(eventTimes*1000);
    assert(~any(isnan(eventCodes)) && ~any(eventCodes == 0));

end
