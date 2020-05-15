% manually input experiment info
% this part cannot be done by automization

% plexon data file path
pl2_path.raw = '/Users/bichanwu/Desktop/nwb workshop/Remy_RP_03082019_UA.pl2';
pl2_path.spkc = '/Users/bichanwu/Desktop/nwb workshop/Remy_RP_03082019_UA.pl2';


% session 
session_info.session_description  = '.';
session_info.identifier			 = '.';
session_info.session_start_time   = datetime(2000,1,1,1,1,1);
session_info.general_experimenter = {'input later'};
session_info.general_experiment_description = '.';
session_info.general_session_id   = '.';
session_info.general_institution  = '.';


% subject
subject_info.subject_id	 = '.';
subject_info.age 		 = '.';
subject_info.description = '.';
subject_info.species 	 = '.';
subject_info.sex 		 = '.';

% full list of available input
% age; % Age of subject. Can be supplied instead of 'date_of_birth'.
% date_of_birth; % Date of birth of subject. Can be supplied instead of 'age'.
% description; % Description of subject and where subject came from (e.g., breeder, if animal).
% genotype; % Genetic strain. If absent, assume Wild Type (WT).
% sex; % Gender of subject.
% species; % Species of subject.
% subject_id; % ID of animal/person used/participating in experiment (lab convention).
% weight; % Weight at time of experiment, at time of surgery and at other important times.


% recording device
device_info.description  = '32 channel linear array';
device_info.manufacturer = 'Plexon';


% electrodes
electrode_info.nprobes = 4;
electrode_info.nchannels_per_probe = 32;
% electrode_info.RegionNames = {'SC','.','.'}; 
electrode_info.RegionNames = {'V4','LIP','mdPul','entorhinal'}; 
% make sure region names match nshansk
if numel(electrode_info.RegionNames)~= electrode_info.nprobes
	error('Region number must match shank number.');
end
% !!! need to add an option of electrode table here


% optional, name events
% event_info = []; % leave empty if do not wish to name events
event_info.names = {'fix','bar','cue','tar','resp','reward'};
