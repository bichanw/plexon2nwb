function nwb = read_spkc(nwb,pl2_path)

Units_plexon = read_spikes(pl2_path.raw);
NUnits = numel(Units_plexon.channel);

[spike_times_vector, spike_times_index] = util.create_indexed_column(Units_plexon.spike_time, '/units/spike_times');

% create nwb 
nwb.units = types.core.Units( ...
    'colnames', {'spike_times', 'waveform_mean', 'electrodes'}, ...
    'description', 'units table', ...
    'id', types.hdmf_common.ElementIdentifiers('data', int64(0:(NUnits-1))));

% full list of available attributes
% colnames			The names of the columns in this table. This should be used to specify an order to the columns. 
% description		Description of what is in this dynamic table. 
% electrode_group	Electrode group that each spike unit came from. 
% electrodes		Electrode that each spike unit came from, specified using a DynamicTableRegion. 
% electrodes_index	Index into electrodes. 
% id				Array of unique identifiers for the rows of this dynamic table. 
% obs_intervals		Observation intervals for each unit. 
% obs_intervals_index	Index into the obs_intervals dataset. 
% spike_times		Spike times for each unit. 
% spike_times_index	Index into the spike_times dataset. 
% vectordata		Vector columns of this dynamic table. 
% vectorindex		Indices for the vector columns of this dynamic table. 
% waveform_mean		Spike waveform mean for each spike unit. 
% waveform_sd		Spike waveform standard deviation for each spike unit. 


% spike time
nwb.units.spike_times = spike_times_vector;
nwb.units.spike_times_index = spike_times_index;


% electrode
% generate objectview of the multielectrodes recording
electrodes_object_view = types.untyped.ObjectView('/general/extracellular_ephys/electrodes');
% reference units to electrodes
nwb.units.electrodes = types.hdmf_common.DynamicTableRegion('table', electrodes_object_view,'description', 'single electrodes','data', int64(Units_plexon.channel - 1));

% waveform
waveform_mean = types.hdmf_common.VectorData('data', vertcat(Units_plexon.wave{:})','description', 'mean of waveform');
nwb.units.waveform_mean = waveform_mean;

end


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
	            wave{iunit+1,ich} = PL2Waves(OpenedFileName,ich,iunit);
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
				Units.spike_time{NNeurons} = int64(allts{iunit,ich} * 1000)'; % s to ms
				Units.wave{NNeurons} = mean(wave{iunit,ich}.Waves,1);
			end
		end
	end

	[Units.channel,I] = sort(Units.channel);
	Units.spike_time = Units.spike_time(I);
	Units.wave 	 	 = Units.wave(I);
end