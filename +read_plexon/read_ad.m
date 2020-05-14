function nwb = read_ad(nwb,electrode_info,pl2)

electrodes_object_view = types.untyped.ObjectView('/general/extracellular_ephys/electrodes');

for iShank = 1:electrode_info.nshanks

	% channels number in region
    channelIDs = (1:electrode_info.nchannels_per_shank)+(iShank-1)*electrode_info.nchannels_per_shank;
    
    % reference to electrode table
    electrode_table_region = types.hdmf_common.DynamicTableRegion( ...
						    'table', electrodes_object_view, ...
						    'description', electrode_info.RegionNames{iShank}, ...
						    'data', (channelIDs-1)');

    % load data
    data = load_raw(pl2.FilePath,channelIDs);

    % convert to nwb
	electrical_series = types.core.ElectricalSeries( ...
	    'starting_time_rate', pl2.AnalogChannels{1}.SamplesPerSecond, ... % Hz
	    'data', data, ...
	    'electrodes', electrode_table_region, ...
	    'data_unit', 'V');

	nwb.acquisition.set(['shank' num2str(iShank)], electrical_series);

end

end


function rawData = load_raw(filename,channelIDs)

    [tscounts, wfcounts, evcounts, slowcounts] = plx_info(filename,1);
    [u,nslowchannels] = size( slowcounts );
    if ( nslowchannels > 0 )
        % 4 regions
        channels_with_data=find(slowcounts>0);
        channels_with_data=channels_with_data-1; %subtract 1 because channel counting starts for 0
        
        for ich = channelIDs
            [adfreq, n, ts, fn, adv] = plx_ad_v(filename,channels_with_data(ich));
            
            %preallocate on the first round
            if find(ich==channelIDs)==1
                rawData=zeros(numel(adv),numel(channelIDs),'int16');
            end

            rawData(:,ich==channelIDs) = int16(adv*1e3);

        end

    end

end