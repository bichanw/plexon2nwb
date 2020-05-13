% initiation
clear;clc;addpath(genpath(pwd));

% input experiment info manually
info_manual;

% get pl2 info
pl2_raw = PL2GetFileIndex(pl2_path.raw);

% session
eval(['nwb = NwbFile(' list_fields(session_info,'session_info') ');'])

% subject
eval(['nwb.general_subject = types.core.Subject(' list_fields(subject_info,'subject_info') ');'])

% test write
nwbExport(nwb, '/Users/bichanwu/Desktop/nwb workshop/nwb/ecephys_tutorial1.nwb');

% trial
% skip trials at this moment, add from manoj's data later

% electrodes
nwb = plexon2nwb.gen_electrode_table(nwb,electrode_info,device_info);

% read voltage info
nwb = plexon2nwb.read_ad(nwb,electrode_info,pl2_raw);