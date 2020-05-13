function nwb = gen_electrode_table(nwb,electrode_info,device_info)

  % electrode groups
  nshanks = electrode_info.nshanks;
  nchannels_per_shank = electrode_info.nchannels_per_shank;

  variables = {'x', 'y', 'z', 'imp', 'location', 'filtering', 'group', 'label'};
  tbl = cell2table(cell(0, length(variables)), 'VariableNames', variables);
  eval(['device = types.core.Device('  list_fields(device_info,'device_info') ');'])
  device_name = 'array';
  nwb.general_devices.set(device_name, device);
  device_link = types.untyped.SoftLink(['/general/devices/' device_name]);

  for ishank = 1:nshanks
      group_name = ['shank' num2str(ishank)];

      nwb.general_extracellular_ephys.set(group_name, ...
          types.core.ElectrodeGroup( ...
              'description', ['electrode group for shank' num2str(ishank)], ...
     	        'location', electrode_info.RegionNames{ishank}, ...
     	        'device', device_link));
      group_object_view = types.untyped.ObjectView( ...
         	['/general/extracellular_ephys/' group_name]);

      for iChannel = 1:nchannels_per_shank
          tbl = [tbl; {-1, -1, -1, NaN, 'unknown', 'unknown', ...
              group_object_view, [group_name 'elec' num2str(iChannel)]}];
      end

  end
  tbl
  electrode_table = util.table2nwb(tbl, 'all electrodes');
  nwb.general_extracellular_ephys_electrodes = electrode_table;

end