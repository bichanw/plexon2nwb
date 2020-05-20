function nwb = read_ad(nwb,electrode_info,pl2_path)

electrodes_object_view = types.untyped.ObjectView('/general/extracellular_ephys/electrodes');

for iProbe = 1:electrode_info.nprobes

	% channels number in region
    channelIDs = (1:electrode_info.nchannels_per_probe)+(iProbe-1)*electrode_info.nchannels_per_probe;
    
    % reference to electrode table
    electrode_table_region = types.hdmf_common.DynamicTableRegion( ...
						    'table', electrodes_object_view, ...
						    'description', electrode_info.RegionNames{iProbe}, ...
						    'data', (channelIDs-1)');

    % load data
    [data,freq] = load_raw(pl2_path.raw,channelIDs);

    % convert to nwb
	electrical_series = types.core.ElectricalSeries( ...
	    'starting_time_rate', freq, ... % Hz
	    'data', data, ...
	    'electrodes', electrode_table_region, ...
	    'data_unit', 'millivolts');

	nwb.acquisition.set(['probe' num2str(iProbe)], electrical_series);

end

end


function [rawData,freq] = load_raw(filename,channelIDs)

    [tscounts, wfcounts, evcounts, slowcounts] = plx_info(filename,1);
    [u,nslowchannels] = size( slowcounts );
    if ( nslowchannels > 0 )
        % 4 regions
        channels_with_data=find(slowcounts>0);
        
        for ich = channelIDs
            ad  = PL2Ad(filename,channels_with_data(ich));
            adv = ad.Values;
            
            %preallocate on the first round
            if find(ich==channelIDs)==1
                rawData=zeros(numel(adv),numel(channelIDs),'double');
            end
            
            
            % save data to big mat
            rawData(:,ich==channelIDs) = adv;

        end
        
        % save sampling frequency
        freq = ad.ADFreq;

    end

end