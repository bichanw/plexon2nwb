function Units = read_spikes(OpenedFileName)
% Read spike data from .pl2 file, output a structure containing
% which channel each unit belongs to and the spike time stamps
% 
% Inputs:
% - OpenedFileName: path to Plexon PL2 data file on filesystem
%
% Outputs:
% - Units.channel: 	  1 x N units of channel numbers (in seconds)
% - Units.spike_time: 1 x N units of cells, each contain time stamps
% 					  of all spikes belonging to the corresponding unit
%

%% Plexon sample code, read spikes from .pl2 file into a big cell
% get some counts
[tscounts, wfcounts, evcounts, slowcounts] = plx_info(OpenedFileName,1);

% tscounts, wfcounts are indexed by (unit+1,channel+1)
% tscounts(:,ch+1) is the per-unit counts for channel ch
% sum( tscounts(:,ch+1) ) is the total wfs for channel ch (all units)
% [nunits, nchannels] = size( tscounts )
% To get number of nonzero units/channels, use nnz() function

% gives actual number of units (including unsorted) and actual number of
% channels plus 1
[nunits1, nchannels1] = size( tscounts );   

% we will read in the timestamps of all units,channels into a two-dim cell
% array named allts, with each cell containing the timestamps for a unit,channel.
% Note that allts second dim is indexed by the 1-based channel number.
% preallocate for speed
allts = cell(nunits1, nchannels1);
% wave  = allts;
for iunit = 0:nunits1-1   % starting with unit 0 (unsorted) 
    for ich = 1:nchannels1-1
        if ( tscounts( iunit+1 , ich+1 ) > 0 )
            % get the timestamps for this channel and unit 
            [nts, allts{iunit+1,ich}] = plx_ts(OpenedFileName, ich , iunit );
            % wave{iunit+1,ich} = PL2Waves(OpenedFileName,ich,iunit);
         end
    end
end


%% convert to Units
NNeurons = 0;
for iunit = 1:nunits1
	% for ich = 1:nchannels1-1
	for ich = 1:nchannels1-1
		if ~isempty(allts{iunit,ich})
			NNeurons = NNeurons + 1;
			Units.channel(NNeurons) = ich;
			Units.spike_time{NNeurons} = round(allts{iunit,ich} * 1000); % s to ms
			% Units.wave{NNeurons} = mean(wave{iunit,ich}.Waves,1);
		end
	end
end

[Units.channel,I] = sort(Units.channel);
Units.spike_time = Units.spike_time(I);
% Units.wave 	 	 = Units.wave(I);
