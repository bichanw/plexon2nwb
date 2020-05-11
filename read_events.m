function eventmatT = read_events(OpenedFileName)
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

