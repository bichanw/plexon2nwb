function nwb = read_LFP(nwb,pl2_path,electrode_info)

electrodes_object_view = types.untyped.ObjectView('/general/extracellular_ephys/electrodes');
ecephys_module = types.core.ProcessingModule(...
    'description', 'extracellular electrophysiology');



for iProbe = 1:electrode_info.nprobes

	% channels number in region
    channelIDs = (1:electrode_info.nchannels_per_probe)+(iProbe-1)*electrode_info.nchannels_per_probe;
    
    % load LFP data from .pl2 file
    [data,freq] = load_LFP(pl2_path,channelIDs,LFP_info);

    % convert to nwb
    % reference to electrode table
    electrode_table_region = types.hdmf_common.DynamicTableRegion( ...
						    'table', electrodes_object_view, ...
						    'description', electrode_info.RegionNames{iProbe}, ...
						    'data', (channelIDs-1)');

    % create electrical series from LFP
	electrical_series = types.core.ElectricalSeries( ...
	    'starting_time_rate', freq, ... % Hz
	    'data', data, ...
	    'electrodes', electrode_table_region, ...
	    'data_unit', 'millivolts',...
	    'description',sprintf('LFP filtered by %f - %f frequency',LFP_info.filterfreq));

	ecephys_module.nwbdatainterface.set(['LFP from probe' num2str(iProbe)], types.core.LFP( ...
    		'ElectricalSeries', electrical_series));


end

% save to nwb
nwb.processing.set('ecephys', ecephys_module);

end

function [data,freq] = load_LFP(pl2_path,channelIDs,LFP_info)


	for iChannel = 1:numel(channelIDs)

		% read raw data
	    ad = PL2Ad(pl2_path.LFP,sprintf('FP%03d',iChannel));

	    % filtering
	    LFP = notchfilt(filloutliers(filter1('bp',ad.Values,'fs',ad.ADFreq,'fc',LFP_info.filterfreq),'linear','ThresholdFactor', 5),ad.ADFreq);

	    % allocate space 
		if iChannel == 1
			data = nan(numel(LFP),numel(channelIDs));
		end

		% save data to big mat
		data(:,iChannel) = LFP;

	end

	freq = ad.ADFreq;

end