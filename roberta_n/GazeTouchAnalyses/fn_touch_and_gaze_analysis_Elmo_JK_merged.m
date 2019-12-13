function [] = fn_touch_and_gaze_analysis_Elmo_JK_merged(fileID, gazereg_name)

timestamps.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);

exclude_saccade_samples = 1;
use_velocity_fixation_detector = 1;
merged_heights = 1;

if ~exist('fileID', 'var') || isempty(fileID)
	fileID = '20190320T095244.A_Elmo.B_JK.SCP_01';
end

if ~exist('gazereg_name', 'var') || isempty(gazereg_name)
	gazereg_name = 'GAZEREG.SID_20190320T092435.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat';
end

close_figures_on_return = 1;

year_string = fileID(1:4);
date_string = fileID(3:8);

if (ispc)
	saving_dir='C:\taskcontroller\SCP_DATA\ANALYSES\GazeAnalyses';
	data_root_str = fullfile('C:', 'SCP');
	data_base_dir = fullfile('Y:');
else
	data_root_str = '/';
	data_base_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ');
	% network!
	data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data', 'taskcontroller');
end

data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, [fileID, '.sessiondir']);


output_dir = pwd;

gazereg_FQN = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, gazereg_name);

maintask_datastruct = fnParseEventIDEReportSCPv06(fullfile(data_dir, [fileID, '.triallog']));
EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_EyeLinkProxyTrackerA.trackerlog']);
data_struct_extract = fnParseEventIDETrackerLog_v01 (EyeLinkfilenameA, ';', [], []);

PQtrackerfilenameA = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_PQLabTrackerA.trackerlog']);
touchtracker_datastructA = fnParseEventIDETrackerLog_v01 (PQtrackerfilenameA, ';', [], []);

PQtrackerfilenameB = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_SecondaryPQLabTrackerB.trackerlog']);
touchtracker_datastructB = fnParseEventIDETrackerLog_v01 (PQtrackerfilenameB, ';', [], []);

sessionID_list = {'20190320T095244.A_Elmo.B_JK.SCP_01',...
	'20190321T083454.A_Elmo.B_JK.SCP_01',...
	'20190322T083726.A_Elmo.B_JK.SCP_01',...
	'20190329T112049.A_Elmo.B_SM.SCP_01',...
	'20190403T090741.A_Elmo.B_JK.SCP_01',...
	'20190404T090735.A_Elmo.B_JK.SCP_01'};

gazereg_list = {'GAZEREG.SID_20190320T092435.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190321T072108.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190322T071957.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190329T111602.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190403T073047.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190404T083605.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat'};

[maintask_datastruct, data_struct_extract, touchtracker_datastructA, touchtracker_datastructB, recalibration_struct] = fn_merging_session(sessionID_list,gazereg_list);
%saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN', 'Elmo_JK_merged_2_sessions');
%saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN', 'Single_Session');
if ~merged_heights
	saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN', 'Elmo_JK_merged_all');
else
	saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN', 'Elmo_JK_merged_all', 'Merged Heights plots');
end

nrows_eyetracker = 0;
ncols_eyetracker = 0;
[nrows_eyetracker, ncols_eyetracker] = size(data_struct_extract.data);

nrows_maintask = 0;
ncols_maintask = 0;
[nrows_maintask, ncols_maintask] = size(maintask_datastruct.report_struct.data);


eyelink_oob_value = -32768;

invalid_datapoints = find(data_struct_extract.data (:, data_struct_extract.cn.Gaze_X) == eyelink_oob_value); %% Removing invalid data pts as defined by eyelink/eventide
%data_struct_extract.data(invalid_datapoints,2:3) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Gaze_X) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Gaze_Y) = NaN;

invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data(:, data_struct_extract.cn.Right_Eye_Raw_X) == eyelink_oob_value));
invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data(:, data_struct_extract.cn.Right_Eye_Raw_Y) == eyelink_oob_value));
invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data(:, data_struct_extract.cn.Left_Eye_Raw_X) == eyelink_oob_value));
invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data(:, data_struct_extract.cn.Left_Eye_Raw_Y) == eyelink_oob_value));

% also get invalid points from recalibration struct
invalid_datapoints = union(invalid_datapoints, find(recalibration_struct.data(:, recalibration_struct.cn.Left_Eye_x) > 1920 |  recalibration_struct.data(:, recalibration_struct.cn.Left_Eye_x) < 0 ));
invalid_datapoints = union(invalid_datapoints, find(recalibration_struct.data(:, recalibration_struct.cn.Left_Eye_y) > 1080 |  recalibration_struct.data(:, recalibration_struct.cn.Left_Eye_y) < 0 ));
invalid_datapoints = union(invalid_datapoints, find(recalibration_struct.data(:, recalibration_struct.cn.Right_Eye_x) > 1920 |  recalibration_struct.data(:, recalibration_struct.cn.Right_Eye_x) < 0 ));
invalid_datapoints = union(invalid_datapoints, find(recalibration_struct.data(:, recalibration_struct.cn.Right_Eye_y) > 1080 |  recalibration_struct.data(:, recalibration_struct.cn.Right_Eye_y) < 0 ));



data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Right_Eye_Raw_X) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Right_Eye_Raw_Y) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Left_Eye_Raw_X) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Left_Eye_Raw_Y) = NaN;

recalibration_struct.data(invalid_datapoints, recalibration_struct.cn.Left_Eye_x)= NaN;
recalibration_struct.data(invalid_datapoints, recalibration_struct.cn.Left_Eye_y)= NaN;
recalibration_struct.data(invalid_datapoints, recalibration_struct.cn.Right_Eye_x)= NaN;
recalibration_struct.data(invalid_datapoints, recalibration_struct.cn.Right_Eye_y)= NaN;



%trialnum_tracker = tn_trialnumber(maintask_datastruct, data_struct_extract);

trial_start_ts_col = maintask_datastruct.report_struct.cn.A_InitialFixationReleaseTime_ms;
trial_start_offset_ms = -500;
trial_end_ts_col = maintask_datastruct.report_struct.cn.A_TargetOffsetTime_ms;
trial_end_offset_ms = 0;

trialnumber_by_tracker_sample_list = fn_assign_trialnum2samples_by_range(maintask_datastruct.report_struct, data_struct_extract, trial_start_ts_col, trial_start_offset_ms, trial_end_ts_col, trial_end_offset_ms);

trialnum_tracker = trialnumber_by_tracker_sample_list;

% parsing and removing invalid touch points. Tells each timepoints to which trial
% belongs
[validUnique_touchpointsA, trialnum_tracker_touchpointsA] = fn_PQtrackerdata(touchtracker_datastructA, maintask_datastruct, trial_start_ts_col, trial_start_offset_ms, trial_end_ts_col, trial_end_offset_ms);
[validUnique_touchpointsB, trialnum_tracker_touchpointsB] = fn_PQtrackerdata(touchtracker_datastructB, maintask_datastruct, trial_start_ts_col, trial_start_offset_ms, trial_end_ts_col, trial_end_offset_ms);

% find the touch gaze consensus trial set
unique_gaze_trials = unique(trialnum_tracker);
unique_touchA_trials = unique(trialnum_tracker_touchpointsA);
unique_touchB_trials = unique(trialnum_tracker_touchpointsB);
unique_gaze_touchA_touchB_trials = intersect(intersect(unique_gaze_trials, unique_touchA_trials), unique_touchB_trials);
% get the non-consensus trials
trials_to_exclude_idx = setdiff((1:1:size(maintask_datastruct.report_struct.data, 1)), unique_gaze_touchA_touchB_trials);
% remove trial marking for non-consensus trials samples
trialnum_tracker(ismember(trialnum_tracker, trials_to_exclude_idx)) = 0;
trialnum_tracker_touchpointsA(ismember(trialnum_tracker_touchpointsA, trials_to_exclude_idx)) = 0;
trialnum_tracker_touchpointsB(ismember(trialnum_tracker_touchpointsB, trials_to_exclude_idx)) = 0;

% Segregation of trials
ModifiedTrialSets = rn_segregateTrialData_monkey_pair( maintask_datastruct);

%tmp_ModifiedTrialSets = rn_segregateTrialData_attempt(maintask_datastruct);

registered_left_eye_gaze_samples = recalibration_struct.data(:,recalibration_struct.cn.Left_Eye_x: recalibration_struct.cn.Left_Eye_y);
registered_right_eye_gaze_samples = recalibration_struct.data(:,recalibration_struct.cn.Right_Eye_x: recalibration_struct.cn.Right_Eye_y);

bin_width = 2;
Xedges = (600:bin_width:(1920-600));
Yedges = (100:bin_width:750);
title_string = 'Gaze samples histogram right eye including NaNs';
cur_fh = figure('Name', ['Gaze histogram right eye (', title_string, ')']);
histogram2(registered_right_eye_gaze_samples (:, 1),registered_right_eye_gaze_samples (:, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
title (['Gaze histogram right eye trials (', title_string, ')']);
axis equal;
colorbar;
set(gca(), 'YDir', 'reverse');
write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram right eye including NaNs.pdf'));

title_string = 'Gaze samples histogram left eye including NaNs';
cur_fh = figure('Name', ['Gaze histogram left eye (', title_string, ')']);
histogram2(registered_left_eye_gaze_samples (:, 1),registered_left_eye_gaze_samples (:, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
title (['Gaze histogram left eye trials (', title_string, ')']);
axis equal;
colorbar;
set(gca(), 'YDir', 'reverse');
write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram left eye including NaNs.pdf'));



Xedges = (0:1920);
Yedges = (0:1080);
values = histcounts2(registered_left_eye_gaze_samples (:, 1), registered_left_eye_gaze_samples (:,2), Xedges, Yedges, 'Normalization','probability');
norm_values = values / max(values(:));
figure;
imagesc(norm_values');
imwrite(norm_values','Gaze samples histogram left eye including NaN.jpg')


registered_left_eye_gaze_samples_orig = registered_left_eye_gaze_samples;
registered_right_eye_gaze_samples_orig = registered_right_eye_gaze_samples;
% registered_left_eye_gaze_samples_affine_orig = registered_left_eye_gaze_samples_affine;
% registered_right_eye_gaze_samples_affine_orig = registered_right_eye_gaze_samples_affine;



if (exclude_saccade_samples)
	%convert to DVA
	[right_x_position_list_deg, right_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_right_eye_gaze_samples(:,1),registered_right_eye_gaze_samples(:,2),...
		960, 341.2698, 1920/1209.4, 1080/680.4, 300);
	
	[left_x_position_list_deg, left_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_left_eye_gaze_samples(:,1),registered_left_eye_gaze_samples(:,2),...
		960, 341.2698, 1920/1209.4, 1080/680.4, 300);
	
	% detection saccades(Igor's toolbox)
	% neg_timestamp_idx = find(data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp) < 0);
	% first_good_sample_idx = neg_timestamp_idx(end) + 1;
	% fgs_idx = first_good_sample_idx;
	
	negative_time_offset = abs(data_struct_extract.data(1,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)) + 1;
	timestamps_4_saccade_detector = data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp) + negative_time_offset;
	
	
	% calculate the pixel displacement between consecutive samples
	%for the right eye
	displacement_x_list_right = diff(registered_right_eye_gaze_samples_orig(:, 1));
	displacement_x_list_right(end+1) = NaN;	% we want the displacement for all samples so thatr all indices match
	
	displacement_y_list_right = diff(registered_left_eye_gaze_samples_orig(:, 2));
	displacement_y_list_right(end+1) = NaN;	% we want the displacement for all samples so thatr all indices match
	
	%for the left eye
	displacement_x_list_left = diff(registered_right_eye_gaze_samples_orig(:, 1));
	displacement_x_list_left(end+1) = NaN;	% we want the displacement for all samples so thatr all indices match
	
	displacement_y_list_left = diff(registered_right_eye_gaze_samples_orig(:, 2));
	displacement_y_list_left(end+1) = NaN;	% we want the displacement for all samples so thatr all indices match
	
	
	
	
	% now calculate the total displacement as euclidean distance in 2D
	% for any fixed sampling rate this velocity in pixels/sample correlates
	% strongly with the instantaneous velocity in pixel/time
	per_sample_euclidean_displacement_pix_list_right = sqrt((((displacement_x_list_right).^2) + ((displacement_y_list_right).^2)));
	per_sample_euclidean_displacement_pix_list_left = sqrt((((displacement_x_list_left).^2) + ((displacement_y_list_left).^2)));
	
	
	% this is the "real" velocity in per time units
	sample_period_ms = unique(diff(data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)));
	velocity_pix_ms_right = per_sample_euclidean_displacement_pix_list_right / (sample_period_ms);
	velocity_pix_ms_left = per_sample_euclidean_displacement_pix_list_left / (sample_period_ms);
	
	%velocity_threshold_pixels_per_sample = 0.25;
	%velocity_threshold_pixels_per_sample = 0.5;
	%velocity_threshold_pixels_per_sample = 1;
	velocity_threshold_pixels_per_sample = 5;
	
	% index samples with instantaneous volicity below and above the threshold
	low_velocity_samples_idx_right = find(per_sample_euclidean_displacement_pix_list_right <= velocity_threshold_pixels_per_sample);
	high_velocity_samples_idx_right = find(per_sample_euclidean_displacement_pix_list_right > velocity_threshold_pixels_per_sample);
	
	low_velocity_samples_idx_left = find(per_sample_euclidean_displacement_pix_list_left <= velocity_threshold_pixels_per_sample);
	high_velocity_samples_idx_left = find(per_sample_euclidean_displacement_pix_list_left > velocity_threshold_pixels_per_sample);
	
	% find consecutive samples with below velocity_threshold_pixels_per_sample
	% changes
	fixation_points_idx_diff_right = diff(low_velocity_samples_idx_right);
	fixation_points_idx_diff_right(end+1) = 10; % the value does not matter as long as it is >1 for the next line
	tmp_lidx_right = fixation_points_idx_diff_right <= 1;
	
	fixation_points_idx_diff_left = diff(low_velocity_samples_idx_left);
	fixation_points_idx_diff_left(end+1) = 10; % the value does not matter as long as it is >1 for the next line
	tmp_lidx_left = fixation_points_idx_diff_left <= 1;
	
	% these idx have >= 2 samples of below threshold velocity -> proto
	% fixations instead of saccades.
	fixation_samples_idx_right = low_velocity_samples_idx_right(tmp_lidx_right);
	
	fixation_samples_idx_left = low_velocity_samples_idx_left(tmp_lidx_left);
	
	bin_width = 2;
	Xedges = (600:bin_width:(1920-600));
	Yedges = (100:bin_width:750);
	title_string = 'Gaze samples histogram fixations for the right eye (velocity_threshold_pixels_per_sample)';
	cur_fh = figure('Name', ['Gaze histogram right eye (', title_string, ')']);
	histogram2(registered_right_eye_gaze_samples_orig(fixation_samples_idx_right, 1), registered_right_eye_gaze_samples_orig(fixation_samples_idx_right, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
	title (['Gaze histogram right eye trials (', title_string, ')']);
	axis equal;
	colorbar;
	set(gca(), 'YDir', 'reverse');
	write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram fixations for the right eye (velocity_threshold_pixels_per_sample).pdf'));
	
	
	title_string = 'Gaze samples histogram fixations for the left eye (velocity_threshold_pixels_per_sample)';
	cur_fh = figure('Name', ['Gaze histogram left eye (', title_string, ')']);
	histogram2(registered_right_eye_gaze_samples_orig(fixation_samples_idx_left, 1), registered_right_eye_gaze_samples_orig(fixation_samples_idx_left, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
	title (['Gaze histogram left eye trials (', title_string, ')']);
	axis equal;
	colorbar;
	set(gca(), 'YDir', 'reverse');
	write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram fixations for the left eye (velocity_threshold_pixels_per_sample).pdf'));
	
	
	Xedges = (0:1920);
	Yedges = (0:1080);
	values = histcounts2(registered_right_eye_gaze_samples_orig(fixation_samples_idx_left, 1), registered_right_eye_gaze_samples_orig(fixation_samples_idx_left, 2), Xedges, Yedges, 'Normalization','probability');
	norm_values = values / max(values(:));
	figure;
	imagesc(norm_values');
	imwrite(norm_values','Gaze samples histogram fixations for the left eye (velocity_threshold_pixels_per_sample).jpg')
	
	
	
	% data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp) = NaN;
	%
	% pos_right_x_position_NaN = right_x_position_list_deg(fgs_idx:end);
	% not_nan_lidx_X = ~isnan(right_x_position_list_deg(fgs_idx:end));
	% pos_right_x_position = pos_right_x_position_NaN(not_nan_lidx_X);
	%
	% pos_right_y_position_NaN = right_y_position_list_deg(fgs_idx:end);
	% not_nan_lidx_Y = ~isnan(right_y_position_list_deg(fgs_idx:end));
	% pos_right_y_position = pos_right_y_position_NaN(not_nan_lidx_Y);
	%
	% timestamps_NaN = data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp);
	% not_nan_lidx_t = ~isnan(timestamps_NaN);
	% timestamps = timestamps_NaN(not_nan_lidx_t);
	
	
	%Detection of saccade for all the trials
	if ~(use_velocity_fixation_detector)
		samples_4_saccade_detector_idx = setdiff((1:1:size(data_struct_extract.data, 1)), invalid_datapoints);
		
		
		right_eye_out = em_saccade_blink_detection (timestamps_4_saccade_detector(samples_4_saccade_detector_idx) / 1000, ...
			right_x_position_list_deg(samples_4_saccade_detector_idx), right_y_position_list_deg(samples_4_saccade_detector_idx), 'em_custom_settings_SNP_eyelink.m');
		
		right_eye_out.sac_onsets = right_eye_out.sac_onsets - negative_time_offset;
		right_eye_out.sac_offsets = right_eye_out.sac_offsets - negative_time_offset;
		timestamps = data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp);
	
		left_eye_out = em_saccade_blink_detection (timestamps_4_saccade_detector(samples_4_saccade_detector_idx) / 1000, ...
			left_x_position_list_deg(samples_4_saccade_detector_idx), left_y_position_list_deg(samples_4_saccade_detector_idx), 'em_custom_settings_SNP_eyelink.m');
		
		left_eye_out.sac_onsets = left_eye_out.sac_onsets - negative_time_offset;
		left_eye_out.sac_offsets = left_eye_out.sac_offsets - negative_time_offset;
	
		% exclude saccades
		fixation_onsets_right = (right_eye_out.sac_offsets(:,1:end-1) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint
		fixation_offsets_right = (right_eye_out.sac_onsets(:,2:end) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint
		
		samples_in_fixations_ldx_4_right = fn_find_samples_by_onset_offset_lists(timestamps, fixation_onsets_right, fixation_offsets_right);
		samples_not_in_fixations_ldx_4_right = ~samples_in_fixations_ldx_4_right;
		
		fixation_onsets_left = (left_eye_out.sac_offsets(:,1:end-1) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint
		fixation_offsets_left = (left_eye_out.sac_onsets(:,2:end) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint
		
		samples_in_fixations_ldx_4_left = fn_find_samples_by_onset_offset_lists(timestamps, fixation_onsets_left, fixation_offsets_left);
		samples_not_in_fixations_ldx_4_left = ~samples_in_fixations_ldx_4_left;
		
		
		% 	samples_in_range_ldx=find(samples_in_range_ldx > 0);
		registered_left_eye_gaze_samples(samples_not_in_fixations_ldx_4_left, 1:2) = NaN;
		registered_right_eye_gaze_samples(samples_not_in_fixations_ldx_4_right, 1:2) = NaN;
		registered_left_eye_gaze_samples_affine(samples_not_in_fixations_ldx_4_left, 1:2) = NaN;
		registered_right_eye_gaze_samples_affine(samples_not_in_fixations_ldx_4_right, 1:2) = NaN;
	else
		samples_not_in_fixations_ldx_right = ones(size(timestamps_4_saccade_detector));
		samples_not_in_fixations_ldx_right(fixation_samples_idx_right) = 0;
		samples_not_in_fixations_ldx_right = logical(samples_not_in_fixations_ldx_right);
		
		samples_not_in_fixations_ldx_left = ones(size(timestamps_4_saccade_detector));
		samples_not_in_fixations_ldx_left(fixation_samples_idx_left) = 0;
		samples_not_in_fixations_ldx_left = logical(samples_not_in_fixations_ldx_left);
		
		registered_left_eye_gaze_samples = registered_left_eye_gaze_samples_orig;
		registered_right_eye_gaze_samples = registered_right_eye_gaze_samples_orig;
		% 	registered_left_eye_gaze_samples_affine = registered_left_eye_gaze_samples_affine_orig;
		% 	registered_right_eye_gaze_samples_affine = registered_right_eye_gaze_samples_affine_orig;
		
		registered_left_eye_gaze_samples(samples_not_in_fixations_ldx_left, 1:2) = NaN;
		registered_right_eye_gaze_samples(samples_not_in_fixations_ldx_right, 1:2) = NaN;
		% 	registered_left_eye_gaze_samples_affine(samples_not_in_fixations_ldx_left, 1:2) = NaN;
		% 	registered_right_eye_gaze_samples_affine(samples_not_in_fixations_ldx_right, 1:2) = NaN;
	end
	% TODO adjust recalibration struct, by setting non-fixation sample positions to NaN
	recalibration_struct.data(samples_not_in_fixations_ldx_right, recalibration_struct.cn.Right_Eye_x) = NaN;
	recalibration_struct.data(samples_not_in_fixations_ldx_right, recalibration_struct.cn.Right_Eye_y) = NaN;
	recalibration_struct.data(samples_not_in_fixations_ldx_left, recalibration_struct.cn.Left_Eye_x) = NaN;
	recalibration_struct.data(samples_not_in_fixations_ldx_left, recalibration_struct.cn.Left_Eye_y) = NaN;
	
	
end

timestamps = data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp);

bin_width = 2;
Xedges = (600:bin_width:(1920-600));
Yedges = (100:bin_width:750);
title_string = 'Gaze samples histogram fixations for the right eye after detector';
cur_fh = figure('Name', ['Gaze histogram right eye (', title_string, ')']);
histogram2(registered_right_eye_gaze_samples (:, 1),registered_right_eye_gaze_samples (:, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
title (['Gaze histogram right eye trials (', title_string, ')']);
axis equal;
colorbar;
set(gca(), 'YDir', 'reverse');
write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram fixations right eye after detector.pdf'));


title_string = 'Gaze samples histogram fixations for the left eye after detector';
cur_fh = figure('Name', ['Gaze histogram left eye (', title_string, ')']);
histogram2(registered_left_eye_gaze_samples (:, 1),registered_left_eye_gaze_samples (:, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
title (['Gaze histogram left eye trials (', title_string, ')']);
axis equal;
colorbar;
set(gca(), 'YDir', 'reverse');
write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram fixations left eye after detector.pdf'));




% if (use_velocity_fixation_detector)
% 	samples_not_in_fixations_ldx_right = ones(size(samples_in_fixations_ldx_4_right));
% 	samples_not_in_fixations_ldx_right(fixation_samples_idx_right) = 0;
% 	samples_not_in_fixations_ldx_right = logical(samples_not_in_fixations_ldx_right);
%
% 	samples_not_in_fixations_ldx_left = ones(size(samples_in_fixations_ldx_4_left));
% 	samples_not_in_fixations_ldx_left(fixation_samples_idx_left) = 0;
% 	samples_not_in_fixations_ldx_left = logical(samples_not_in_fixations_ldx_left);
%
%
% 	registered_left_eye_gaze_samples = registered_left_eye_gaze_samples_orig;
% 	registered_right_eye_gaze_samples = registered_right_eye_gaze_samples_orig;
% 	% 	registered_left_eye_gaze_samples_affine = registered_left_eye_gaze_samples_affine_orig;
% 	% 	registered_right_eye_gaze_samples_affine = registered_right_eye_gaze_samples_affine_orig;
%
%
% 	registered_left_eye_gaze_samples(samples_not_in_fixations_ldx_left, 1:2) = NaN;
% 	registered_right_eye_gaze_samples(samples_not_in_fixations_ldx_right, 1:2) = NaN;
% 	% 	registered_left_eye_gaze_samples_affine(samples_not_in_fixations_ldx_left, 1:2) = NaN;
% 	% 	registered_right_eye_gaze_samples_affine(samples_not_in_fixations_ldx_right, 1:2) = NaN;
% end

registered_right_eye_gaze_samples_x = registered_right_eye_gaze_samples(:,1);
registered_right_eye_gaze_samples_y = registered_right_eye_gaze_samples(:,2);
registered_left_eye_gaze_samples_x = registered_left_eye_gaze_samples(:,1);
registered_left_eye_gaze_samples_y = registered_left_eye_gaze_samples(:,2);


%Gaze/Touch points on the basis of trials
%TrialWiseDataGaze = modified_trialwiseDataStructure(data_struct_extract.data, trialnum_tracker, nrows_maintask);
%Registered gaze points
%RegisteredTrialWiseDataGaze_poly = registered_trialwiseDataStructure_new(recalibration_struct, trialnum_tracker, nrows_maintask);
% RegisteredTrialWiseDataGaze_poly_right = registered_trialwiseDataStructure_right_eye(data_struct_extract, recalibration_struct, trialnum_tracker, nrows_maintask);
% RegisteredTrialWiseDataGaze_poly_left = registered_trialwiseDataStructure_left_eye(data_struct_extract, recalibration_struct, trialnum_tracker, nrows_maintask);

RegisteredTrialWiseDataGaze_poly_right = fn_registered_trialwiseDataStructure_eye(data_struct_extract, recalibration_struct, trialnum_tracker, nrows_maintask, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp, recalibration_struct.cn.Right_Eye_x, recalibration_struct.cn.Right_Eye_y);
RegisteredTrialWiseDataGaze_poly_left = fn_registered_trialwiseDataStructure_eye(data_struct_extract, recalibration_struct, trialnum_tracker, nrows_maintask, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp, recalibration_struct.cn.Left_Eye_x, recalibration_struct.cn.Left_Eye_y);

%RegisteredTrialWiseDataGaze_affine = registered_trialwiseDataStructure(data_struct_extract.data, registered_right_eye_gaze_samples_affine, trialnumber_by_tracker_sample_list, nrows_maintask);
% TrialWiseDataTouchA = tn_trialwiseDataStructure(validUnique_touchpointsA.data, trialnum_tracker_touchpointsA, nrows_maintask);
% TrialWiseDataTouchB = tn_trialwiseDataStructure(validUnique_touchpointsB.data, trialnum_tracker_touchpointsB, nrows_maintask);

TrialWiseDataTouchA = fn_tn_trialwiseDataStructure(validUnique_touchpointsA.data, trialnum_tracker_touchpointsA, nrows_maintask);
TrialWiseDataTouchB = fn_tn_trialwiseDataStructure(validUnique_touchpointsB.data, trialnum_tracker_touchpointsB, nrows_maintask);
[~, b] = size(TrialWiseDataTouchB.timepoints);

%Interpolation: equally spaced
%[InterpolatedTrialWiseDataGaze]= tn_interpTrialData(TrialWiseDataGaze);
InterpRegTrialWiseDataGaze_poly_right = tn_interpTrialData(RegisteredTrialWiseDataGaze_poly_right);
InterpRegTrialWiseDataGaze_poly_left = tn_interpTrialData(RegisteredTrialWiseDataGaze_poly_left);
%InterpolatedRegisteredTrialWiseDataGaze_affine= tn_interpTrialData(RegisteredTrialWiseDataGaze_affine);
[InterpolatedTrialWiseDataTouchA] = tn_interpTrialDataTouch(TrialWiseDataTouchA, InterpRegTrialWiseDataGaze_poly_right);
[InterpolatedTrialWiseDataTouchB] = tn_interpTrialDataTouch(TrialWiseDataTouchB, InterpRegTrialWiseDataGaze_poly_right);


%Define the epoch: aligned to colour target onset time
%interpolate
start_val_col_idx = maintask_datastruct.report_struct.cn.A_InitialFixationReleaseTime_ms;
start_offset = -500;
end_val_col_idx = maintask_datastruct.report_struct.cn.A_TargetOffsetTime_ms;
end_offset = +300;

%[epochdataGazeA] = tn_defineEpochnew(InterpolatedTrialWiseDataGaze, maintask_datastruct); %To Target Onset
epochdataRegisteredGazeA_poly_right = tn_defineEpochnew(InterpRegTrialWiseDataGaze_poly_right, maintask_datastruct);

%epochdataRegisteredGazeA_poly_right_new = fn_defineEpochnew_attempt(InterpRegTrialWiseDataGaze_poly_right, maintask_datastruct, start_val_col_idx, start_offset, end_val_col_idx, end_offset);

epochdataRegisteredGazeA_poly_left =  tn_defineEpochnew(InterpRegTrialWiseDataGaze_poly_left, maintask_datastruct);
%epochdataRegisteredGazeA_affine = tn_defineEpochnew(InterpolatedRegisteredTrialWiseDataGaze_affine, maintask_datastruct);
[epochdataTouchA] = tn_defineEpochnew(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchB] = tn_defineEpochnew(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
ArrayforInterpolation=(-0.5:0.002:1.3);
%[InterpolatedepochdataGazeA] = tn_interpTrialDataEpoch(epochdataGazeA.TargetOnset, ArrayforInterpolation);
InterpepochdataRegGazeA_poly_right = tn_interpTrialDataEpoch (epochdataRegisteredGazeA_poly_right.TargetOnset, ArrayforInterpolation);
InterpepochdataRegGazeA_poly_left = tn_interpTrialDataEpoch (epochdataRegisteredGazeA_poly_left.TargetOnset, ArrayforInterpolation);
[InterpolatedepochdataTouchA] = tn_interpTrialDataTouch(epochdataTouchA.TargetOnset, InterpepochdataRegGazeA_poly_right);
[InterpolatedepochdataTouchB] = tn_interpTrialDataTouch(epochdataTouchB.TargetOnset, InterpepochdataRegGazeA_poly_left);

%%This is to define the epoch: aligned to the Initial fixation release time of the Player B (confederate in my case, but can be used as it is for any data)
%%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points

ArrayforInterpolation_BIFRA=(-0.5:0.002:0.9);
%[epochdataGazeB_Initial_Fixation_Release_A] = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGaze, maintask_datastruct);
epochdataRegGazeB_Initial_Fixation_Release_A_poly_right = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpRegTrialWiseDataGaze_poly_right, maintask_datastruct);
epochdataRegGazeB_Initial_Fixation_Release_A_poly_left = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpRegTrialWiseDataGaze_poly_left, maintask_datastruct);
%epochdataRegGazeB_Initial_Fixation_Release_A_affine = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedRegisteredTrialWiseDataGaze_affine, maintask_datastruct);
[epochdataTouchB_Initial_Fixation_Release_A] = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchB_Initial_Fixation_Release_B] = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
%[InterpolatedepochdataGazeB_Initial_Fixation_Release_A] = tn_interpTrialDataEpoch(epochdataGazeB_Initial_Fixation_Release_A, ArrayforInterpolation_BIFRA);
InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right = tn_interpTrialDataEpoch(epochdataRegGazeB_Initial_Fixation_Release_A_poly_right, ArrayforInterpolation_BIFRA);
InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left = tn_interpTrialDataEpoch(epochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ArrayforInterpolation_BIFRA);
%InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_affine = tn_interpTrialDataEpoch(epochdataRegGazeB_Initial_Fixation_Release_A_affine, ArrayforInterpolation_BIFRA);
[InterpolatedepochdataTouchB_Initial_Fixation_Release_A] = tn_interpTrialDataTouch(epochdataTouchB_Initial_Fixation_Release_A, InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right);
[InterpolatedepochdataTouchB_Initial_Fixation_Release_B] = tn_interpTrialDataTouch(epochdataTouchB_Initial_Fixation_Release_B, InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right);

%This is to define the epoch: aligned to the Initial fixation release time of the Player A (Elmo in my case, but can be used as it is for any data)
%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/
ArrayforInterpolation_AIFRA =(-0.5:0.002:0.9);
%[epochdataGazeA_Initial_Fixation_Release_A] = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGaze, maintask_datastruct);
epochdataRegGazeA_Initial_Fixation_Release_A_poly_right = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpRegTrialWiseDataGaze_poly_right, maintask_datastruct);
epochdataRegGazeA_Initial_Fixation_Release_A_poly_left = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpRegTrialWiseDataGaze_poly_left, maintask_datastruct);
%epochdataRegGazeA_Initial_Fixation_Release_A_affine = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedRegisteredTrialWiseDataGaze_affine, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_A] = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_B] = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
%[InterpolatedepochdataGazeA_Initial_Fixation_Release_A] = tn_interpTrialDataEpoch(epochdataGazeA_Initial_Fixation_Release_A, ArrayforInterpolation_AIFRA);
InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right = tn_interpTrialDataEpoch(epochdataRegGazeA_Initial_Fixation_Release_A_poly_right, ArrayforInterpolation_AIFRA);
InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left = tn_interpTrialDataEpoch(epochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ArrayforInterpolation_AIFRA);
%InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_affine = tn_interpTrialDataEpoch(epochdataRegGazeA_Initial_Fixation_Release_A_affine, ArrayforInterpolation_AIFRA);
[InterpolatedepochdataTouchA_Initial_Fixation_Release_A] = tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_A, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right);
[InterpolatedepochdataTouchA_Initial_Fixation_Release_B] = tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_B, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right);


%Here I calculate the different distances
[distGazeATouchA, distGazeATouchB,distGazeA_finaltarget_A, distTouchA_finaltarget_A, distTouchB_finaltarget_B]= rn_distbetweenGazeTouch_Onset(epochdataRegisteredGazeA_poly_right, epochdataTouchA, epochdataTouchB,maintask_datastruct);
[B_distGazeATouchB B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A, B_distTouchB_finaltarget_B]= rn_distbetweenGazeTouch(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, maintask_datastruct);
[A_distGazeATouchB A_distGazeATouchA, A_distGazeA_finaltarget_A, A_distTouchA_finaltarget_A, A_distTouchB_finaltarget_B]= rn_distbetweenGazeTouch(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, maintask_datastruct);

% [Cur_fh_RTbyChoiceCombinationSwitches_blocked,Cur_fh_RTbyChoiceCombinationSwitches_unblocked merged_classifier_char_string] = rn_reactiontime_switching_trials(maintask_datastruct,ModifiedTrialSets);
% write_out_figure(Cur_fh_RTbyChoiceCombinationSwitches_blocked, fullfile(saving_dir, 'Cur_fh_RTbyChoiceCombinationSwitches_blocked.pdf'));
% write_out_figure(Cur_fh_RTbyChoiceCombinationSwitches_blocked, fullfile(saving_dir, 'Cur_fh_RTbyChoiceCombinationSwitches_unblocked.pdf'));

% Plots with x recalibrated_polynomial degree 2
% rn_TrialWiseNEWPlotRecalibrated_poly(epochdataRegisteredGazeA_poly, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly(InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly,InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly(InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_poly, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

% Plots with x recalibrated_affine
% rn_TrialWiseNEWPlotRecalibrated_affine(epochdataRegisteredGazeA_affine, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_affine(InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_affine, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_affine(InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_affine, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

%Tarana's plot woth x recalibrated_polynomial displaying only fixations
%target onset 
if ~merged_heights
	
	%rn_TrialWiseNEWPlotRecalibrated_poly(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB,ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB,ModifiedTrialSets, saving_dir);
	% rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir);
	% rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_RB(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB,ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_BR(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB,ModifiedTrialSets, saving_dir);
	%rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_RB_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir);
	%rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_BR_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_RB(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB,ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_BR(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB,ModifiedTrialSets, saving_dir);
	%rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_RB_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir);
	%rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_BR_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir);
	
	% BIFR
	%rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblockedtrials(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blockedtrials(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	
	%rn_TrialWiseNEWPlotsAlignededBIFR_reg_poly_unblocked_3D(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	%rn_TrialWiseNEWPlotsAlignededBIFR_reg_poly_blocked_3D (InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blockedtrials_RB(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blockedtrials_BR(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	%rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blocked_BR_3D (InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	%rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blocked_RB_3D (InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	
	rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblockedtrials_RB(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblockedtrials_BR(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	%rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblocked_BR_3D(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID)
	%rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblocked_RB_3D(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	
	% AIFR
	%rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly (InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blockedtrials(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblockedtrials(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	
	%rn_TrialWiseNEWPlotsAlignededAIFR_reg_poly_blocked_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	%rn_TrialWiseNEWPlotsAlignededAIFR_reg_poly_unblocked_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	
	rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blockedtrials_RB(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blockedtrials_BR(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	%rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blocked_BR_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	%rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blocked_RB_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	
	rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblockedtrials_RB(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblockedtrials_BR(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	%rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblocked_BR_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	%rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblocked_RB_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	
	%Original Tarana's plots
	% tn_TrialWiseNEWPlots(epochdataGazeA, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID);
	% tn_TrialWiseNEWPlotsAlignedtoBIFR(InterpolatedepochdataGazeB_Initial_Fixation_Release_A, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	% tn_TrialWiseNEWPlotsAlignedtoAIFR(InterpolatedepochdataGazeA_Initial_Fixation_Release_A, InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
	
	%[distGazeATouchA, distGazeATouchB, distTouchBTouchA] = rn_TrialWiseDISTNEWPlotsAlignedOnset(OnsetdistGazeATouchA, OnsetdistGazeATouchB, OnsetdistTouchBTouchA,epochdataRegisteredGazeA_poly_right, ModifiedTrialSets, saving_dir);
	
	[DistGazeATouchA_blocked, DistGazeATouchB_blocked, DistGazeA_finaltargetA_blocked, DistTouchA_finaltargetA_blocked] = rn_TrialWiseDISTNEWPlotsAlignedOnset_blockedtrials(distGazeATouchA, distGazeATouchB,distGazeA_finaltarget_A, distTouchA_finaltarget_A,epochdataRegisteredGazeA_poly_right, epochdataRegisteredGazeA_poly_left,ModifiedTrialSets, saving_dir);
	[DistGazeATouchA_unblocked, DistGazeATouchB_unblocked, DistGazeA_finaltargetA_unblocked, DistTouchA_finaltargetA_unblocked] = rn_TrialWiseDISTNEWPlotsAlignedOnset_unblockedtrials(distGazeATouchA, distGazeATouchB,distGazeA_finaltarget_A, distTouchA_finaltarget_A,epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left,ModifiedTrialSets, saving_dir);
	
	[DistGazeATouchA_blocked_RB, DistGazeATouchB_blocked_RB,DistGazeA_finaltargetA_blocked_RB, DistTouchA_finaltargetA_blocked_RB]= rn_TrialWiseDISTNEWPlotsAlignedOnset_blockedtrials_RB(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left,ModifiedTrialSets, saving_dir);
	[DistGazeATouchA_blocked_BR, DistGazeATouchB_blocked_BR,DistGazeA_finaltargetA_blocked_BR, DistTouchA_finaltargetA_blocked_BR]= rn_TrialWiseDISTNEWPlotsAlignedOnset_blockedtrials_BR(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left,ModifiedTrialSets, saving_dir);
	
	[DistGazeATouchA_unblocked_BR, DistGazeATouchB_unblocked_BR,DistGazeA_finaltargetA_unblocked_BR, DistTouchA_finaltargetA_unblocked_BR]= rn_TrialWiseDISTNEWPlotsAlignedOnset_unblockedtrials_RB(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left,ModifiedTrialSets, saving_dir);
	[DistGazeATouchA_unblocked_RB, DistGazeATouchB_unblocked_RB,DistGazeA_finaltargetA_unblocked_RB, DistTouchA_finaltargetA_unblocked_RB]= rn_TrialWiseDISTNEWPlotsAlignedOnset_unblockedtrials_BR(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left,ModifiedTrialSets, saving_dir);
	
	%[BIFRDistGazeATouchA,BIFRDistGazeATouchB] = tn_TrialWiseDISTNEWPlotsAlignedtoBIFR (B_distGazeATouchA, B_distGazeATouchB,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_blocked,BIFRDistGazeATouchB_blocked,BIFRDistGazeA_finaltargetA_blocked, BIFRDistTouchA_finaltargetA_blocked] = tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_blockedtrials(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_blocked_RB,BIFRDistGazeATouchB_blocked_RB,BIFRDistGazeA_finaltargetA_blocked_RB, BIFRDistTouchA_finaltargetA_blocked_RB] = tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_blockedtrials_RB(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left,ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_blocked_BR,BIFRDistGazeATouchB_blocked_BR,BIFRDistGazeA_finaltargetA_blocked_BR, BIFRDistTouchA_finaltargetA_blocked_BR] = tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_blockedtrials_BR(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left,ModifiedTrialSets, saving_dir);
	
	[BIFRDistGazeATouchA_unblocked,BIFRDistGazeATouchB_unblocked,BIFRDistGazeA_finaltargetA_unblocked, BIFRDistTouchA_finaltargetA_unblocked]= tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_unblockedtrials(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_unblocked_RB,BIFRDistGazeATouchB_unblocked_RB,BIFRDistGazeA_finaltargetA_unblocked_RB, BIFRDistTouchA_finaltargetA_unblocked_RB]= tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_unblockedtrials_RB(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A,B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_unblocked_BR,BIFRDistGazeATouchB_unblocked_BR,BIFRDistGazeA_finaltargetA_unblocked_BR, BIFRDistTouchA_finaltargetA_unblocked_BR] = tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_unblockedtrials_BR(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A,B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	
	%[AIFRDistGazeATouchA, AIFRDistGazeATouchB]= tn_TrialWiseDISTNEWPlotsAlignedtoAIFR(A_distGazeATouchA, A_distGazeATouchB,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir)
	[AIFRDistGazeATouchA_blocked,AIFRDistGazeATouchB_blocked,AIFRDistGazeA_finaltargetA_blocked, AIFRDistTouchA_finaltargetA_blocked] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_blockedtrials(A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[AIFRDistGazeATouchA_blocked_RB,AIFRDistGazeATouchB_blocked_RB,AIFRDistGazeA_finaltargetA_blocked_RB, AIFRDistTouchA_finaltargetA_blocked_RB] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_blockedtrials_RB(A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,ModifiedTrialSets, saving_dir);
	[AIFRDistGazeATouchA_blocked_BR,AIFRDistGazeATouchB_blocked_BR,AIFRDistGazeA_finaltargetA_blocked_BR, AIFRDistTouchA_finaltargetA_blocked_BR] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_blockedtrials_BR (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,ModifiedTrialSets, saving_dir);
	
	
	[AIFRDistGazeATouchA_unblocked,AIFRDistGazeATouchB_unblocked,AIFRDistGazeA_finaltargetA_unblocked, AIFRDistTouchA_finaltargetA_unblocked] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_unblockedtrials(A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[AIFRDistGazeATouchA_unblocked_RB,AIFRDistGazeATouchB_unblocked_RB,AIFRDistGazeA_finaltargetA_unblocked_RB, AIFRDistTouchA_finaltargetA_unblocked_RB] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_unblockedtrials_RB(A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[AIFRDistGazeATouchA_unblocked_BR,AIFRDistGazeATouchB_unblocked_BR,AIFRDistGazeA_finaltargetA_unblocked_BR, AIFRDistTouchA_finaltargetA_unblocked_BR] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_unblockedtrials_BR(A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,ModifiedTrialSets, saving_dir);
	
else
	
	%MERGED HEIGHTS
	%TARGET ONSET
	[TouchA_blocked ,TouchB_blocked]= rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_merged(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	[TouchA_unblocked, TouchB_unblocked]= rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_merged(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	[TouchA_blocked_foll_BR ,TouchB_blocked_foll_BR]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_foll_BR_merged(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	[TouchA_blocked_prefoll_BR ,TouchB_blocked_prefoll_BR] = rn_TrialWiseNEWPlotRecalibrated_poly_blocked_prefoll_BR_merged(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	[TouchA_blocked_foll_RB ,TouchB_blocked_foll_RB]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_foll_RB_merged(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	[TouchA_blocked_prefoll_RB ,TouchB_blocked_prefoll_RB] = rn_TrialWiseNEWPlotRecalibrated_poly_blocked_prefoll_RB_merged(InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	[TouchA_unblocked_foll_BR ,TouchB_unblocked_foll_BR] = rn_TrialWiseNEWPlotRecalibrated_poly_unblocked_foll_BR_merged (InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	[TouchA_unblocked_prefoll_BR ,TouchB_unblocked_prefoll_BR] = rn_TrialWiseNEWPlotRecalibrated_poly_unblocked_prefoll_RB_mer (InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	[TouchA_unblocked_foll_RB ,TouchB_unblocked_foll_RB] = rn_TrialWiseNEWPlotRecalibrated_poly_unblocked_foll_RB_merged (InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	[TouchA_unblocked_prefoll_RB ,TouchB_unblocked_prefoll_RB] = rn_TrialWiseNEWPlotRecalibrated_poly_unblocked_prefoll_BR_mer (InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, InterpolatedepochdataTouchA,InterpolatedepochdataTouchB, ModifiedTrialSets, saving_dir);
	
	%BIFR
	[BIFR_TouchA_blocked ,BIFR_TouchB_blocked]= rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_BIFR_merg(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[BIFR_TouchA_unblocked, BIFR_TouchB_unblocked]= rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_BIFR_merg(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[BIFR_TouchA_blocked_foll_BR ,BIFR_TouchB_blocked_foll_BR]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_foll_BR_BIFR_merg(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[BIFR_TouchA_blocked_prefoll_BR ,BIFR_TouchB_blocked_prefoll_BR]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_BIFR_prefoll_BR_me(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
    [BIFR_TouchA_blocked_foll_RB ,BIFR_TouchB_blocked_foll_RB]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_foll_RB_BIFR_merg(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[BIFR_TouchA_blocked_prefoll_RB ,BIFR_TouchB_blocked_prefoll_RB]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_BIFR_prefoll_RB_me(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
    [BIFR_TouchA_unblocked_foll_BR ,BIFR_TouchB_unblocked_foll_BR] = rn_TrialWiseNEWPlotRecalibrated_poly_unblocked_foll_BR_BIFR_me(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[BIFR_TouchA_unblocked_prefoll_BR ,BIFR_TouchB_unblocked_prefoll_BR] = rn_TrialWiseNEWPlotRecalibrated_poly_unbl_BIFR_prefoll_BR_me(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[BIFR_TouchA_unblocked_foll_RB ,BIFR_TouchB_unblocked_foll_RB] = rn_TrialWiseNEWPlotRecalibrated_poly_unblocked_foll_RB_BIFR_me (InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
    [BIFR_TouchA_unblocked_prefoll_RB ,BIFR_TouchB_unblocked_prefoll_RB] = rn_TrialWiseNEWPlotRecalibrated_poly_unbl_BIFR_prefoll_RB_me (InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);

	
	%AIFR
	[AIFR_TouchA_blocked ,AIFR_TouchB_blocked]= rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_AIFR_merg(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[AIFR_TouchA_unblocked, AIFR_TouchB_unblocked]= rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_AIFR_merg(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[AIFR_TouchA_blocked_foll_BR ,AIFR_TouchB_blocked_foll_BR]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_foll_BR_AIFR_merg(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
    [AIFR_TouchA_blocked_prefoll_BR ,AIFR_TouchB_blocked_prefoll_BR]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_AIFR_prefoll_BR_me(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
    [AIFR_TouchA_blocked_foll_RB ,AIFR_TouchB_blocked_foll_RB]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_foll_RB_AIFR_merg(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[AIFR_TouchA_blocked_prefoll_RB ,AIFR_TouchB_blocked_prefoll_RB]= rn_TrialWiseNEWPlotRecalibrated_poly_blocked_AIFR_prefoll_RB_me(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
    [AIFR_TouchA_unblocked_foll_BR ,AIFR_TouchB_unblocked_foll_BR] = rn_TrialWiseNEWPlotRecalibrated_poly_unblocked_foll_BR_AIFR_mer (InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[AIFR_TouchA_unblocked_prefoll_BR ,AIFR_TouchB_unblocked_prefoll_BR] = rn_TrialWiseNEWPlotRecalibrated_poly_unbl_AIFR_prefoll_BR_me (InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
    [AIFR_TouchA_unblocked_foll_RB ,AIFR_TouchB_unblocked_foll_RB] = rn_TrialWiseNEWPlotRecalibrated_poly_unblocked_foll_RB_AIFR_me (InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);
	[AIFR_TouchA_unblocked_prefoll_RB ,AIFR_TouchB_unblocked_prefoll_RB] = rn_TrialWiseNEWPlotRecalibrated_poly_unbl_AIFR_prefoll_RB_me (InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir);

	%DISTANCE ONSET 
	[DistGazeATouchA_blocked_mer, DistGazeATouchB_blocked_mer, DistGazeA_finaltargetA_blocked_mer, DistTouchA_finaltargetA_blocked_mer, Timepoints_blocked_mer] = rn_TrialWiseDISTNEWPlotsAlignedOnset_blockedtrials_merged(distGazeATouchA, distGazeATouchB,distGazeA_finaltarget_A, distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right, InterpepochdataRegGazeA_poly_left,ModifiedTrialSets, saving_dir);
	[DistGazeATouchA_unblocked_mer, DistGazeATouchB_unblocked_mer, DistGazeA_finaltargetA_unblocked_mer, DistTouchA_finaltargetA_unblocked_mer, Timepoints_unblocked_mer] = rn_TrialWiseDISTNEWPlotsAlignedOnset_unblockedtrials_merged (distGazeATouchA, distGazeATouchB,distGazeA_finaltarget_A, distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right, InterpepochdataRegGazeA_poly_left,ModifiedTrialSets, saving_dir);
	[DistGazeATouchA_blocked_foll_RB_mer, DistGazeATouchB_blocked_foll_RB_mer,DistGazeA_finaltargetA_blocked_foll_RB_mer, DistTouchA_finaltargetA_blocked_foll_RB_mer, Timepoints_blocked_RB_mer]= rn_TrialWiseDISTNEWPlotsAlignedOnset_switchRB_foll_blocked_mer(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, ModifiedTrialSets, saving_dir);
    [DistGazeATouchA_blocked_prefoll_RB_mer, DistGazeATouchB_blocked_prefoll_RB_mer,DistGazeA_finaltargetA_blocked_prefoll_RB_mer, DistTouchA_finaltargetA_blocked_prefoll_RB_mer, Timepoints_blocked_RB_mer]= rn_TrialWiseDISTNEWPlotsOnset_switchRB_prefoll_blocked_mer(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, ModifiedTrialSets, saving_dir);
    [DistGazeATouchA_blocked_foll_BR_mer, DistGazeATouchB_blocked_foll_BR_mer,DistGazeA_finaltargetA_blocked_foll_BR_mer, DistTouchA_finaltargetA_blocked_foll_BR_mer, Timepoints_blocked_BR_mer]= rn_TrialWiseDISTNEWPlotsAlignedOnset_switchBR_foll_blocked_mer(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right, InterpepochdataRegGazeA_poly_left,ModifiedTrialSets, saving_dir);
	[DistGazeATouchA_blocked_prefoll_BR_mer, DistGazeATouchB_blocked_prefoll_BR_mer,DistGazeA_finaltargetA_blocked_prefoll_BR_mer, DistTouchA_finaltargetA_blocked_prefoll_BR_mer, Timepoints_blocked_BR_mer]= rn_TrialWiseDISTNEWPlotsOnset_switchBR_prefoll_blocked_mer(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right, InterpepochdataRegGazeA_poly_left,ModifiedTrialSets, saving_dir);
	[DistGazeATouchA_unblocked_foll_BR_mer, DistGazeATouchB_unblocked_foll_BR_mer,DistGazeA_finaltargetA_unblocked_foll_BR_mer, DistTouchA_finaltargetA_unblocked_foll_BR_mer, Timepoints_unblocked_BR_mer]= rn_TrialWiseDISTNEWPlotsAlignedOnset_switchBR_foll_unblocked_m(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, ModifiedTrialSets, saving_dir);
    [DistGazeATouchA_unblocked_prefoll_BR_mer, DistGazeATouchB_unblocked_prefoll_BR_mer,DistGazeA_finaltargetA_unblocked_prefoll_BR_mer, DistTouchA_finaltargetA_unblocked_prefoll_BR_mer, Timepoints_unblocked_BR_mer]= rn_TrialWiseDISTNEWPlotsOnset_switchBR_prefoll_unblocked_mer(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, ModifiedTrialSets, saving_dir);
	[DistGazeATouchA_unblocked_foll_RB_mer, DistGazeATouchB_unblocked_foll_RB_mer,DistGazeA_finaltargetA_unblocked_foll_RB_mer, DistTouchA_finaltargetA_unblocked_foll_RB_mer, Timepoints_unblocked_RB_mer]= rn_TrialWiseDISTNEWPlotsAlignedOnset_switchRB_foll_unblocked_m(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, ModifiedTrialSets, saving_dir);
    [DistGazeATouchA_unblocked_prefoll_RB_mer, DistGazeATouchB_unblocked_prefoll_RB_mer,DistGazeA_finaltargetA_unblocked_prefoll_RB_mer, DistTouchA_finaltargetA_unblocked_prefoll_RB_mer, Timepoints_unblocked_RB_mer]= rn_TrialWiseDISTNEWPlotsOnset_switchRB_prefoll_unblocked_mer(distGazeATouchA,distGazeATouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,InterpepochdataRegGazeA_poly_right,InterpepochdataRegGazeA_poly_left, ModifiedTrialSets, saving_dir);

	%DISTANCE BIFR
	[BIFRDistGazeATouchA_blocked_mer,BIFRDistGazeATouchB_blocked_mer,BIFRDistGazeA_finaltargetA_blocked_mer, BIFRDistTouchA_finaltargetA_blocked_mer, BIFR_Timepoints_blocked_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_blockedtrials_merged(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_unblocked_mer,BIFRDistGazeATouchB_unblocked_mer,BIFRDistGazeA_finaltargetA_unblocked_mer, BIFRDistTouchA_finaltargetA_unblocked_mer, BIFR_Timepoints_unblocked_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_unblockedtrials_merged (B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left ,ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_blocked_foll_RB_mer,BIFRDistGazeATouchB_blocked_foll_RB_mer,BIFRDistGazeA_finaltargetA_blocked_foll_RB_mer, BIFRDistTouchA_finaltargetA_blocked_foll_RB_mer, BIFR_Timepoints_blocked_RB_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_blocked_foll_RB_mer(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_blocked_prefoll_RB_mer,BIFRDistGazeATouchB_blocked_prefoll_RB_mer,BIFRDistGazeA_finaltargetA_blocked_prefoll_RB_mer, BIFRDistTouchA_finaltargetA_blocked_prefoll_RB_mer, BIFR_Timepoints_blocked_RB_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_blocked_prefoll_RB_mer(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
    [BIFRDistGazeATouchA_blocked_foll_BR_mer,BIFRDistGazeATouchB_blocked_foll_BR_mer,BIFRDistGazeA_finaltargetA_blocked_foll_BR_mer, BIFRDistTouchA_finaltargetA_blocked_foll_BR_mer, BIFR_Timepoints_blocked_BR_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_blocked_foll_BR_mer(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_blocked_prefoll_BR_mer,BIFRDistGazeATouchB_blocked_prefoll_BR_mer,BIFRDistGazeA_finaltargetA_blocked_prefoll_BR_mer, BIFRDistTouchA_finaltargetA_blocked_prefoll_BR_mer, BIFR_Timepoints_blocked_BR_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_blocked_prefoll_BR_mer(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_unblocked_foll_RB_mer,BIFRDistGazeATouchB_unblocked_foll_RB_mer,BIFRDistGazeA_finaltargetA_unblocked_foll_RB_mer, BIFRDistTouchA_finaltargetA_unblocked_foll_RB_mer,BIFR_Timepoints_unblocked_RB_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_unblocked_foll_RB_mer(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_unblocked_prefoll_RB_mer,BIFRDistGazeATouchB_unblocked_prefoll_RB_mer,BIFRDistGazeA_finaltargetA_unblocked_prefoll_RB_mer, BIFRDistTouchA_finaltargetA_unblocked_prefoll_RB_mer,BIFR_Timepoints_unblocked_RB_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_unblocked_prefoll_RB_mer(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_unblocked_foll_BR_mer,BIFRDistGazeATouchB_unblocked_foll_BR_mer,BIFRDistGazeA_finaltargetA_unblocked_foll_BR_mer, BIFRDistTouchA_finaltargetA_unblocked_foll_BR_mer, BIFR_Timepoints_unblocked_BR_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_unblocked_foll_BR_mer(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[BIFRDistGazeATouchA_unblocked_prefoll_BR_mer,BIFRDistGazeATouchB_unblocked_prefoll_BR_mer,BIFRDistGazeA_finaltargetA_unblocked_prefoll_BR_mer, BIFRDistTouchA_finaltargetA_unblocked_prefoll_BR_mer, BIFR_Timepoints_unblocked_BR_mer] = rn_TrialWiseDISTNEWPlotsAlignedBIFR_unblocked_prefoll_BR_mer(B_distGazeATouchB,B_distGazeATouchA, B_distGazeA_finaltarget_A, B_distTouchA_finaltarget_A,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);

	%DISTANCE AIFR
	[AIFRDistGazeATouchA_blocked_mer,AIFRDistGazeATouchB_blocked_mer,AIFRDistGazeA_finaltargetA_blocked_mer, AIFRDistTouchA_finaltargetA_blocked_mer, AIFR_Timepoints_blocked_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_blockedtrials_merged (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[AIFRDistGazeATouchA_unblocked_mer,AIFRDistGazeATouchB_unblocked_mer,AIFRDistGazeA_finaltargetA_unblocked_mer, AIFRDistTouchA_finaltargetA_unblocked_mer, AIFR_Timepoints_unblocked_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_unblockedtrials_merged (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[AIFRDistGazeATouchA_blocked_foll_RB_mer,AIFRDistGazeATouchB_blocked_foll_RB_mer,AIFRDistGazeA_finaltargetA_blocked_foll_RB_mer, AIFRDistTouchA_finaltargetA_blocked_foll_RB_mer, AIFR_Timepoints_blocked_RB_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_blocked_foll_RB_mer (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[AIFRDistGazeATouchA_blocked_prefoll_RB_mer,AIFRDistGazeATouchB_blocked_prefoll_RB_mer,AIFRDistGazeA_finaltargetA_blocked_prefoll_RB_mer, AIFRDistTouchA_finaltargetA_blocked_prefoll_RB_mer, AIFR_Timepoints_blocked_RB_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_blocked_prefoll_RB_mer (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
    [AIFRDistGazeATouchA_blocked_foll_BR_mer,AIFRDistGazeATouchB_blocked_foll_BR_mer,AIFRDistGazeA_finaltargetA_blocked_foll_BR_mer, AIFRDistTouchA_finaltargetA_blocked_foll_BR_mer, AIFR_Timepoints_blocked_BR_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_blocked_foll_BR_mer (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
    [AIFRDistGazeATouchA_blocked_prefoll_BR_mer,AIFRDistGazeATouchB_blocked_prefoll_BR_mer,AIFRDistGazeA_finaltargetA_blocked_prefoll_BR_mer, AIFRDistTouchA_finaltargetA_blocked_prefoll_BR_mer, AIFR_Timepoints_blocked_BR_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_blocked_prefoll_BR_mer (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
    [AIFRDistGazeATouchA_unblocked_foll_RB_mer,AIFRDistGazeATouchB_unblocked_foll_RB_mer,AIFRDistGazeA_finaltargetA_unblocked_foll_RB_mer, AIFRDistTouchA_finaltargetA_unblocked_foll_RB_mer,AIFR_Timepoints_unblocked_RB_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_unblocked_foll_RB_mer (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
	[AIFRDistGazeATouchA_unblocked_prefoll_RB_mer,AIFRDistGazeATouchB_unblocked_prefoll_RB_mer,AIFRDistGazeA_finaltargetA_unblocked_prefoll_RB_mer, AIFRDistTouchA_finaltargetA_unblocked_prefoll_RB_mer,AIFR_Timepoints_unblocked_RB_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_unblocked_prefoll_RB_mer (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left, ModifiedTrialSets, saving_dir);
    [AIFRDistGazeATouchA_unblocked_foll_BR_mer,AIFRDistGazeATouchB_unblocked_foll_BR_mer,AIFRDistGazeA_finaltargetA_unblocked_foll_BR_mer, AIFRDistTouchA_finaltargetA_unblocked_foll_BR_mer,AIFR_Timepoints_unblocked_BR_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_unblocked_foll_BR_mer (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,ModifiedTrialSets, saving_dir);
    [AIFRDistGazeATouchA_unblocked_prefoll_BR_mer,AIFRDistGazeATouchB_unblocked_prefoll_BR_mer,AIFRDistGazeA_finaltargetA_unblocked_prefoll_BR_mer, AIFRDistTouchA_finaltargetA_unblocked_prefoll_BR_mer,AIFR_Timepoints_unblocked_BR_mer] = rn_TrialWiseDISTNEWPlotsAlignedAIFR_unblocked_prefoll_BR_mer (A_distGazeATouchB,A_distGazeATouchA, A_distGazeA_finaltarget_A,A_distTouchA_finaltarget_A,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,ModifiedTrialSets, saving_dir);

end


%Statistical stuff
%Creation of structs that will be later saved as matfile and loaded for the
%permutation test. 
EpochWiseData.TrialSets = ModifiedTrialSets;

EpochWiseData.FullTrial.Aligned_Data.Gaze.A = RegisteredTrialWiseDataGaze_poly_right;
EpochWiseData.FullTrial.Aligned_Data.Touch.A = TrialWiseDataTouchA;
EpochWiseData.FullTrial.Aligned_Data.Touch.B = TrialWiseDataTouchB;

EpochWiseData.TargetOnset.Aligned_Data.Gaze.A = epochdataRegisteredGazeA_poly_right;
EpochWiseData.TargetOnset.Aligned_Data.Touch.A = epochdataTouchA;
EpochWiseData.TargetOnset.Aligned_Data.Touch.B = epochdataTouchB;

EpochWiseData.AIFR.Aligned_Data.Gaze.A = epochdataRegGazeA_Initial_Fixation_Release_A_poly_right;
EpochWiseData.AIFR.Aligned_Data.Touch.A = epochdataTouchA_Initial_Fixation_Release_A;
EpochWiseData.AIFR.Aligned_Data.Touch.B = epochdataTouchA_Initial_Fixation_Release_B;

EpochWiseData.BIFR.Aligned_Data.Gaze.A = epochdataRegGazeB_Initial_Fixation_Release_A_poly_right;
EpochWiseData.BIFR.Aligned_Data.Touch.A = epochdataTouchB_Initial_Fixation_Release_A;
EpochWiseData.BIFR.Aligned_Data.Touch.B = epochdataTouchB_Initial_Fixation_Release_B;


EpochWiseData.FullTrial.Aligned_Interpolated_Data.Gaze.A = InterpRegTrialWiseDataGaze_poly_right;
EpochWiseData.FullTrial.Aligned_Interpolated_Data.Touch.A = InterpolatedTrialWiseDataTouchA;
EpochWiseData.FullTrial.Aligned_Interpolated_Data.Touch.B = InterpolatedTrialWiseDataTouchB;

EpochWiseData.TargetOnset.Aligned_Interpolated_Data.Gaze.A = InterpepochdataRegGazeA_poly_right;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.Touch.A = InterpolatedepochdataTouchA;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.Touch.B = InterpolatedepochdataTouchB;

EpochWiseData.AIFR.Aligned_Interpolated_Data.Gaze.A = InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right;
EpochWiseData.AIFR.Aligned_Interpolated_Data.Touch.A = InterpolatedepochdataTouchA_Initial_Fixation_Release_A;
EpochWiseData.AIFR.Aligned_Interpolated_Data.Touch.B = InterpolatedepochdataTouchA_Initial_Fixation_Release_B;


EpochWiseData.BIFR.Aligned_Interpolated_Data.Gaze.A = InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right;
EpochWiseData.BIFR.Aligned_Interpolated_Data.Touch.A = InterpolatedepochdataTouchB_Initial_Fixation_Release_A;
EpochWiseData.BIFR.Aligned_Interpolated_Data.Touch.B = InterpolatedepochdataTouchB_Initial_Fixation_Release_B;

%Reorganizing stuff for the permutatio test : raw touch data 
%TARGET ONSET A
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked.A = TouchA_blocked;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked.timepoints = Timepoints_blocked_mer;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked.A = TouchA_unblocked;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked.timepoints = Timepoints_unblocked_mer;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked_FirstFollowing_BR.A = TouchA_blocked_foll_BR;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked_FirstFollowing_RB.A = TouchA_blocked_foll_RB;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_BR.A = TouchA_blocked_prefoll_BR;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_RB.A = TouchA_blocked_prefoll_RB;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_BR.A = TouchA_unblocked_foll_BR;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB.A = TouchA_unblocked_foll_RB;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_BR.A = TouchA_unblocked_prefoll_BR;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB.A = TouchA_unblocked_prefoll_RB;

%TARGET ONSET B
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked.B = TouchB_blocked;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked.timepoints = Timepoints_blocked_mer;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked.B = TouchB_unblocked;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked.timepoints = Timepoints_unblocked_mer;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked_FirstFollowing_BR.B = TouchB_blocked_foll_BR;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked_FirstFollowing_RB.B = TouchB_blocked_foll_RB;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_BR.B = TouchB_blocked_prefoll_BR;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_RB.B = TouchB_blocked_prefoll_RB;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_BR.B = TouchB_unblocked_foll_BR;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB.B = TouchB_unblocked_foll_RB;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_BR.B = TouchB_unblocked_prefoll_BR;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB.B = TouchB_unblocked_prefoll_RB;
EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked.timepoints = Timepoints_unblocked_mer;


%AIFR A 
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked.A = AIFR_TouchA_blocked;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked.timepoints = AIFR_Timepoints_blocked_mer;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked.A = AIFR_TouchA_unblocked;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked.timepoints = AIFR_Timepoints_unblocked_mer;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked_FirstFollowing_BR.A = AIFR_TouchA_blocked_foll_BR;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked_FirstFollowing_RB.A = AIFR_TouchA_blocked_foll_RB;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_BR.A = AIFR_TouchA_blocked_prefoll_BR;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_RB.A = AIFR_TouchA_blocked_prefoll_RB;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_BR.A = AIFR_TouchA_unblocked_foll_BR;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB.A = AIFR_TouchA_unblocked_foll_RB;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_BR.A = AIFR_TouchA_unblocked_prefoll_BR;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB.A = AIFR_TouchA_unblocked_prefoll_RB;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked.timepoints = Timepoints_unblocked_mer;


%AIFR B 
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked.B = AIFR_TouchB_blocked;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked.timepoints = AIFR_Timepoints_blocked_mer;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked.B = AIFR_TouchB_unblocked;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked.timepoints = AIFR_Timepoints_unblocked_mer;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked_FirstFollowing_BR.B = AIFR_TouchB_blocked_foll_BR;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked_FirstFollowing_RB.B = AIFR_TouchB_blocked_foll_RB;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_BR.B = AIFR_TouchB_blocked_prefoll_BR;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_RB.B = AIFR_TouchB_blocked_prefoll_RB;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_BR.B = AIFR_TouchB_unblocked_foll_BR;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB.B = AIFR_TouchB_unblocked_foll_RB;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_BR.B = AIFR_TouchB_unblocked_prefoll_BR;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB.B = AIFR_TouchB_unblocked_prefoll_RB;
EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked.timepoints = Timepoints_unblocked_mer;

%BIFR A
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked.A = BIFR_TouchA_blocked;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked.timepoints = BIFR_Timepoints_blocked_mer;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked.A = BIFR_TouchA_unblocked;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked.timepoints = BIFR_Timepoints_unblocked_mer;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked_FirstFollowing_BR.A = BIFR_TouchA_blocked_foll_BR;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked_FirstFollowing_RB.A = BIFR_TouchA_blocked_foll_RB;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_BR.A = BIFR_TouchA_blocked_prefoll_BR;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_RB.A = BIFR_TouchA_blocked_prefoll_RB;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_BR.A = BIFR_TouchA_unblocked_foll_BR;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB.A = BIFR_TouchA_unblocked_foll_RB;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_BR.A = BIFR_TouchA_unblocked_prefoll_BR;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB.A = BIFR_TouchA_unblocked_prefoll_RB;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked.timepoints = Timepoints_unblocked_mer;

%BIFR B
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked.B = BIFR_TouchB_blocked;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked.timepoints = BIFR_Timepoints_blocked_mer;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked.B = BIFR_TouchB_unblocked;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked.timepoints = BIFR_Timepoints_unblocked_mer;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked_FirstFollowing_BR.B = BIFR_TouchB_blocked_foll_BR;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked_FirstFollowing_RB.B = BIFR_TouchB_blocked_foll_RB;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_BR.B = BIFR_TouchB_blocked_prefoll_BR;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked_PreFirstFollowing_RB.B = BIFR_TouchB_blocked_prefoll_RB;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_BR.B = BIFR_TouchB_unblocked_foll_BR;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB.B = BIFR_TouchB_unblocked_foll_RB;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_BR.B = BIFR_TouchB_unblocked_prefoll_BR;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB.B = BIFR_TouchB_unblocked_prefoll_RB;
EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked.timepoints = Timepoints_unblocked_mer;

%Reorganizing stuff for the permutation test : distance unblocked
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.AA = DistGazeATouchA_unblocked_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.AB = DistGazeATouchB_unblocked_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.AT = DistGazeA_finaltargetA_unblocked_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.timepoints = Timepoints_unblocked_mer;


EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.AA = AIFRDistGazeATouchA_unblocked_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.AB = AIFRDistGazeATouchB_unblocked_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.AT = AIFRDistGazeA_finaltargetA_unblocked_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.timepoints = AIFR_Timepoints_unblocked_mer;


EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.AA = BIFRDistGazeATouchA_unblocked_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.AB = BIFRDistGazeATouchB_unblocked_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.AT = BIFRDistGazeA_finaltargetA_unblocked_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked.timepoints = BIFR_Timepoints_unblocked_mer;


%Reorganizing stuff for the permutation test : distance blocked
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.AA = DistGazeATouchA_blocked_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.AB = DistGazeATouchB_blocked_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.AT = DistGazeA_finaltargetA_blocked_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.timepoints = Timepoints_blocked_mer;


EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.AA = AIFRDistGazeATouchA_blocked_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.AB = AIFRDistGazeATouchB_blocked_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.AT = AIFRDistGazeA_finaltargetA_blocked_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.timepoints = AIFR_Timepoints_blocked_mer;


EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.AA = BIFRDistGazeATouchA_blocked_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.AB = BIFRDistGazeATouchB_blocked_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.AT = BIFRDistGazeA_finaltargetA_blocked_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked.timepoints = BIFR_Timepoints_blocked_mer;


%Reorganizing stuff for the permutation test : distance unblocked_BR
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR.AA = DistGazeATouchA_unblocked_foll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR.AB = DistGazeATouchB_unblocked_foll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR.AT = DistGazeA_finaltargetA_unblocked_foll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR.AA = DistGazeATouchA_unblocked_prefoll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR.AB = DistGazeATouchB_unblocked_prefoll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR.AT = DistGazeA_finaltargetA_unblocked_prefoll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_BR.timepoints = Timepoints_unblocked_BR_mer;


EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR.AA = AIFRDistGazeATouchA_unblocked_foll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR.AB = AIFRDistGazeATouchB_unblocked_foll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR.AT = AIFRDistGazeA_finaltargetA_unblocked_foll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR.AA = AIFRDistGazeATouchA_unblocked_prefoll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR.AB = AIFRDistGazeATouchB_unblocked_prefoll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR.AT = AIFRDistGazeA_finaltargetA_unblocked_prefoll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_BR.timepoints = AIFR_Timepoints_unblocked_BR_mer;


EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR.AA = BIFRDistGazeATouchA_unblocked_foll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR.AB = BIFRDistGazeATouchB_unblocked_foll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR.AT = BIFRDistGazeA_finaltargetA_unblocked_foll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR.AA = BIFRDistGazeATouchA_unblocked_prefoll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR.AB = BIFRDistGazeATouchB_unblocked_prefoll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR.AT = BIFRDistGazeA_finaltargetA_unblocked_prefoll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_BR.timepoints = BIFR_Timepoints_unblocked_BR_mer;


%Reorganizing stuff for the permutation test : distance unblocked_RB
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB.AA = DistGazeATouchA_unblocked_foll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB.AB = DistGazeATouchB_unblocked_foll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB.AT = DistGazeA_finaltargetA_unblocked_foll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB.AA = DistGazeATouchA_unblocked_prefoll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB.AB = DistGazeATouchB_unblocked_prefoll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB.AT = DistGazeA_finaltargetA_unblocked_prefoll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_RB.timepoints = Timepoints_unblocked_RB_mer;


EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB.AA = AIFRDistGazeATouchA_unblocked_foll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB.AB = AIFRDistGazeATouchB_unblocked_foll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB.AT = AIFRDistGazeA_finaltargetA_unblocked_foll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB.AA = AIFRDistGazeATouchA_unblocked_prefoll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB.AB = AIFRDistGazeATouchB_unblocked_prefoll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB.AT = AIFRDistGazeA_finaltargetA_unblocked_prefoll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_RB.timepoints = AIFR_Timepoints_unblocked_RB_mer;


EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB.AA = BIFRDistGazeATouchA_unblocked_foll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB.AB = BIFRDistGazeATouchB_unblocked_foll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB.AT = BIFRDistGazeA_finaltargetA_unblocked_foll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB.AA = BIFRDistGazeATouchA_unblocked_prefoll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB.AB = BIFRDistGazeATouchB_unblocked_prefoll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB.AT = BIFRDistGazeA_finaltargetA_unblocked_prefoll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_RB.timepoints = BIFR_Timepoints_unblocked_RB_mer;


%Reorganizing stuff for the permutation test : distance blocked_BR
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_BR.AA = DistGazeATouchA_blocked_foll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_BR.AB = DistGazeATouchB_blocked_foll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_BR.AT = DistGazeA_finaltargetA_blocked_foll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_BR.AA = DistGazeATouchA_blocked_prefoll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_BR.AB = DistGazeATouchB_blocked_prefoll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_BR.AT = DistGazeA_finaltargetA_blocked_prefoll_BR_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_BR.timepoints = Timepoints_blocked_BR_mer;


EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_BR.AA = AIFRDistGazeATouchA_blocked_foll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_BR.AB = AIFRDistGazeATouchB_blocked_foll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_BR.AT = AIFRDistGazeA_finaltargetA_blocked_foll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_BR.AA = AIFRDistGazeATouchA_blocked_prefoll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_BR.AB = AIFRDistGazeATouchB_blocked_prefoll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_BR.AT = AIFRDistGazeA_finaltargetA_blocked_prefoll_BR_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_BR.timepoints = AIFR_Timepoints_blocked_BR_mer;


EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_BR.AA = BIFRDistGazeATouchA_blocked_foll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_BR.AB = BIFRDistGazeATouchB_blocked_foll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_BR.AT = BIFRDistGazeA_finaltargetA_blocked_foll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_BR.AA = BIFRDistGazeATouchA_blocked_prefoll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_BR.AB = BIFRDistGazeATouchB_blocked_prefoll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_BR.AT = BIFRDistGazeA_finaltargetA_blocked_prefoll_BR_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_BR.timepoints = BIFR_Timepoints_blocked_BR_mer;


%Reorganizing stuff for the permutation test : distance blocked_RB
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_RB.AA = DistGazeATouchA_blocked_foll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_RB.AB = DistGazeATouchB_blocked_foll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_RB.AT = DistGazeA_finaltargetA_blocked_foll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_RB.AA = DistGazeATouchA_blocked_prefoll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_RB.AB = DistGazeATouchB_blocked_prefoll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_RB.AT = DistGazeA_finaltargetA_blocked_prefoll_RB_mer;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_RB.timepoints = Timepoints_blocked_RB_mer;


EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_RB.AA = AIFRDistGazeATouchA_blocked_foll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_RB.AB = AIFRDistGazeATouchB_blocked_foll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_RB.AT = AIFRDistGazeA_finaltargetA_blocked_foll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_RB.AA = AIFRDistGazeATouchA_blocked_prefoll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_RB.AB = AIFRDistGazeATouchB_blocked_prefoll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_RB.AT = AIFRDistGazeA_finaltargetA_blocked_prefoll_RB_mer;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_RB.timepoints = AIFR_Timepoints_blocked_RB_mer;


EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_RB.AA = BIFRDistGazeATouchA_blocked_foll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_RB.AB = BIFRDistGazeATouchB_blocked_foll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_FirstFollowing_RB.AT = BIFRDistGazeA_finaltargetA_blocked_foll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_RB.AA = BIFRDistGazeATouchA_blocked_prefoll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_RB.AB = BIFRDistGazeATouchB_blocked_prefoll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_PreFirstFollowing_RB.AT = BIFRDistGazeA_finaltargetA_blocked_prefoll_RB_mer;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked_RB.timepoints = BIFR_Timepoints_blocked_RB_mer;



%%This is just to save the matfile. Name has to be changed every time. Or
%%you could just automate it.


if (ispc)
	save(fullfile(saving_dir, 'FixationTouchAnalyses.mat'),'-v7.3', 'EpochWiseData');
	%save(fullfile(saving_dir, 'AllGazeTouchAnalyses.mat'),'-v7.3', 'EpochWiseData');
end

close all

if (close_figures_on_return)
	close all;
end

return
end

function [columnnames_struct, n_fields] = local_get_column_name_indices(name_list, start_val)
% return a structure with each field for each member if the name_list cell
% array, giving the position in the name_list, then the columnnames_struct
% can serve as to address the columns, so the functions assigning values
% to the columns do not have to care too much about the positions, and it
% becomes easy to add fields.
% name_list: cell array of string names for the fields to be added
% start_val: numerical value to start the field values with (if empty start
%            with 1 so the results are valid indices into name_list)

if nargin < 2
	start_val = 1;  % value of the first field
end
n_fields = length(name_list);
for i_col = 1 : length(name_list)
	cur_name = name_list{i_col};
	% skip empty names, this allows non consequtive numberings
	if ~isempty(cur_name)
		columnnames_struct.(cur_name) = i_col + (start_val - 1);
	end
end
return
end
