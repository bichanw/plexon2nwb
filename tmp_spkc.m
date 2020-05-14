

Units_plexon = read_spikes(pl2_path.raw);
[spike_times_vector, spike_times_index] = util.create_indexed_column(Units.spike_time, '/units/spike_times');



nwb.units = types.core.Units( ...
    'colnames', {'spike_times', 'waveform_mean', 'electrodes'}, ...
    'description', 'units table', ...
    'id', types.hdmf_common.ElementIdentifiers('data', int64(0:(numel(Units_plexon.spike_time-1)))));


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
electrode_table_region = types.hdmf_common.DynamicTableRegion('table', electrodes_object_view, 'description', 'all electrodes', 'data', [0 height(tbl)-1]');
% reference units to electrodes
[electrodes, electrodes_index] = util.create_indexed_column( ...
    num2cell(Units_plexon.channel - 1), '/units/electrodes', [], [], ...
    electrodes_object_view);

nwb.units.electrodes = Units_plexon.channel - 1; % 0 index match electrode group


% waveform
waveform_mean = types.hdmf_common.VectorData('data', vertcat(Units_plexon.wave{:})','description', 'mean of waveform');
nwb.units.waveform_mean = waveform_mean;