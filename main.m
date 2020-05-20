% initiation
clear;clc;addpath(genpath(pwd));

% input experiment info manually
info_manual;

% session
eval(['nwb = NwbFile(' list_fields(session_info,'session_info') ');'])

% subject
eval(['nwb.general_subject = types.core.Subject(' list_fields(subject_info,'subject_info') ');'])

% electrodes
nwb = read_plexon.gen_electrode_table(nwb,electrode_info,device_info);

% read voltage info
nwb = read_plexon.read_ad(nwb,electrode_info,pl2_path);

% spike
nwb = read_plexon.read_spkc(nwb,pl2_path);

% events
nwb = read_plexon.read_events(nwb,pl2_path,event_info);

% LFP
nwb = read_plexon.read_LFP(nwb,pl2_path,electrode_info,LFP_info);


% test write
nwbExport(nwb, '/Users/bichanwu/Desktop/nwb workshop/nwb/ecephys_tutorial.nwb');