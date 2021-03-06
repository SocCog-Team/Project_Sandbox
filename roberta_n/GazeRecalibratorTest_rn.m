function [ output_args ] = GazeRecalibratorTest( input_args )
%GAZERECALIBRATORTEST Summary of this function goes here
%   Detailed explanation goes here


%fileID='20190729T154225.A_Elmo.B_None.SCP_01.';
data_root_str = '/';
% network!
data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data');
% local
data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data');

data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190729', '20190729T154225.A_Elmo.B_None.SCP_01.sessiondir');



% common parameters
velocity_threshold_pixels_per_sample = 0.05;
saccade_allowance_time_ms = 200;
acceptable_radius_pix = 10;
%transformationType = 'affine';
transformationType = 'polynomial'; % 'affine', 'polynomial', 'pwl', 'lwm'
polynomial_degree = 3;	% degree 3 requires at least 10 control points
tracker_type = 'eyelink';

% lwm needs sensibly spaced control points, does not work yet
if strcmp(transformationType, 'lwm')
	polynomial_degree = 10;
end


% %% EyeLink decent HV9 eyelink calibration/validation, little distortions
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190729', '20190729T154225.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190729T154225.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% fn_gaze_recalibrator_sm(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree);


% % still decent eyelink calibration
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190705', '20190705T113230.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190705T113230.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% fn_gaze_recalibrator_sm(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree);

% % human HV9 calibration without validation, data from NHP heavy shearing
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190312', '20190312T071737.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190312T071737.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% fn_gaze_recalibrator_sm(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree);

% %EyeLink HV9 eyelink calibration/validation after the removal of the calibration files
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190805', '20190805T122130.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190805T122130.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% fn_gaze_recalibrator_sm(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree);


%EyeLink HV9 eyelink calibration/validation with 17 target positions
data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190816', '20190816T124444.A_Elmo.B_None.SCP_01.sessiondir');
gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190816T124444.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
fn_gaze_recalibrator_sm(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree);


% %%Pupillabs test
% tracker_type = 'pupillabs';
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190419', '20190419T161006.A_190419ID111S1.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190419T161006.A_190419ID111S1.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
% fn_gaze_recalibrator_sm(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, acceptable_radius_pix, transformationType, polynomial_degree);

end

