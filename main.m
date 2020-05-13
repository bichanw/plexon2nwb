
% input experiment info manually
info_manual;

% session
eval(['nwb = NwbFile(' list_fields(session_info,'session_info') ');'])

% subject
eval(['subject = types.core.Subject(' list_fields(subject_info,'subject_info') ');'])
nwb.general_subject = subject;

% test write
nwbExport(nwb, '/Users/bichanwu/Desktop/nwb workshop/nwb/ecephys_tutorial1.nwb');

% trial
% skip trials at this moment, add from manoj's data later

% 