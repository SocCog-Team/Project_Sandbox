function [ output_args ] = GazeRecalibratorTest( input_args )
%GAZERECALIBRATORTEST Summary of this function goes here
%   Detailed explanation goes here


%fileID='20190729T154225.A_Elmo.B_None.SCP_01.';
	data_root_str = '/';
	% network!
	data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data');
	data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2020', '200605', '20200605T123825.A_20200605ID014S1.B_None.SCP_01.sessiondir');
	
if ~exist('EyeLinkfilenameA', 'var')
	gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190729T154225.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog.txt.gz');
	gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190729T154225.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
end







velocity_threshold_pixels_per_sample = 0.05;
acceptable_radius_pix = 10;
transformationType = 'affine';
tracker_type = 'eyelink';


%% EyeLink decent HV9 eyelink calibration/validation, little distortions
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190729', '20190729T154225.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190729T154225.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% fn_gaze_recalibrator(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, acceptable_radius_pix, transformationType);


% % still decent eyelink calibration
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190705', '20190705T113230.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190705T113230.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% fn_gaze_recalibrator(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, acceptable_radius_pix, transformationType);

% 
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190312', '20190312T071737.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190312T071737.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% fn_gaze_recalibrator(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, acceptable_radius_pix, transformationType);

% %EyeLink HV9 eyelink calibration/validation after the removal of the
% %calibration files
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190805', '20190805T122130.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190805T122130.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% fn_gaze_recalibrator(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, acceptable_radius_pix, transformationType);

%%Pupillabs test
tracker_type = 'pupillabs';
<<<<<<< HEAD
data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2020', '200605', '20200605T123825.A_20200605ID014S1.B_None.SCP_01.sessiondir');
gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20200605T123825.A_20200605ID014S1.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
=======
data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190419', '20190419T161006.A_190419ID111S1.B_None.SCP_01.sessiondir');
gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190419T161006.A_190419ID111S1.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
>>>>>>> 662a8b8495d12b71ec43dacab2794df217299304
fn_gaze_recalibrator(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, acceptable_radius_pix, transformationType);

end

