function [] = fn_touch_and_gaze_analysis(fileID, gazereg_name)

timestamps.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);

exclude_saccade_samples = 1;
use_velocity_fixation_detector = 1;

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
saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN', [fileID, '.sessiondir']);
output_dir = pwd;

gazereg_FQN = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, gazereg_name);

[maintask_datastruct,data_struct_extract,touchtracker_datastructA, touchtracker_datastructB, recalibration_struct] = fn_merging_session(fileID, gazereg_name);

eyelink_oob_value = -32768;

invalid_datapoints = find(data_struct_extract.data (:, data_struct_extract.cn.Gaze_X) == eyelink_oob_value); %% Removing invalid data pts as defined by eyelink/eventide
%data_struct_extract.data(invalid_datapoints,2:3) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Gaze_X) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Gaze_Y) = NaN;

invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data (:, data_struct_extract.cn.Right_Eye_Raw_X) == eyelink_oob_value));
invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data (:, data_struct_extract.cn.Right_Eye_Raw_Y) == eyelink_oob_value));
invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data (:, data_struct_extract.cn.Left_Eye_Raw_X) == eyelink_oob_value));
invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data (:, data_struct_extract.cn.Left_Eye_Raw_Y) == eyelink_oob_value));

data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Right_Eye_Raw_X) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Right_Eye_Raw_Y) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Left_Eye_Raw_X) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Left_Eye_Raw_Y) = NaN;

trialnum_tracker = tn_trialnumber (maintask_datastruct, data_struct_extract);
%trialnumber_by_tracker_sample_list = fn_assign_trialnum2samples_by_range(maintask_datastruct.report_struct, data_struct_extract, maintask_datastruct.report_struct.cn.A_InitialFixationReleaseTime_ms, -500, maintask_datastruct.report_struct.cn.A_TargetOffsetTime_ms,0);

% parsing and removing invalid touch points. Tells each timepoints to which trial
% belongs
[validUnique_touchpointsA,trialnum_tracker_touchpointsA] = fn_PQtrackerdata(touchtracker_datastructA, maintask_datastruct);
[validUnique_touchpointsB,trialnum_tracker_touchpointsB] = fn_PQtrackerdata(touchtracker_datastructB, maintask_datastruct);

% Segregation of trials
ModifiedTrialSets = rn_segregateTrialData(maintask_datastruct);


registered_left_eye_gaze_samples = recalibration_struct.data(:,3:4);
registered_right_eye_gaze_samples = recalibration_struct.data(:,5:6);


bin_width = 2;
Xedges = (600:bin_width:(1920-600));
Yedges = (100:bin_width:750);
title_string = 'Gaze samples histogram right eye including NaNs';
cur_fh = figure('Name', ['Gaze histogram right eye (', title_string, ')']);
histogram2(registered_right_eye_gaze_samples (:, 1), registered_right_eye_gaze_samples(:, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
title (['Gaze histogram right eye trials (', title_string, ')']);
axis equal;
colorbar;
set(gca(), 'YDir', 'reverse');
write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram right eye including NaNs.pdf'));


title_string = 'Gaze samples histogram left eye including NaNs';
cur_fh = figure('Name', ['Gaze histogram left eye (', title_string, ')']);
histogram2(registered_left_eye_gaze_samples (:, 1), registered_left_eye_gaze_samples(:, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
title (['Gaze histogram left eye trials (', title_string, ')']);
axis equal;
colorbar;
set(gca(), 'YDir', 'reverse');
write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram left eye including NaNs.pdf'));


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
 
if (use_velocity_fixation_detector)
	samples_not_in_fixations_ldx_right = ones(size(samples_in_fixations_ldx_4_right));
	samples_not_in_fixations_ldx_right(fixation_samples_idx_right) = 0;
	samples_not_in_fixations_ldx_right = logical(samples_not_in_fixations_ldx_right);
	
	samples_not_in_fixations_ldx_left = ones(size(samples_in_fixations_ldx_4_left));
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

registered_right_eye_gaze_samples_x = registered_right_eye_gaze_samples(:,1);
registered_right_eye_gaze_samples_y = registered_right_eye_gaze_samples(:,2);
registered_left_eye_gaze_samples_x = registered_left_eye_gaze_samples(:,1);
registered_left_eye_gaze_samples_y = registered_left_eye_gaze_samples(:,2);


%Gaze/Touch points on the basis of trials
%TrialWiseDataGaze = modified_trialwiseDataStructure(data_struct_extract.data, trialnum_tracker, nrows_maintask);
%Registered gaze points
RegisteredTrialWiseDataGaze_poly_right = registered_trialwiseDataStructure(data_struct_extract.data, registered_right_eye_gaze_samples, trialnum_tracker, nrows_maintask);
RegisteredTrialWiseDataGaze_poly_left = registered_trialwiseDataStructure(data_struct_extract.data, registered_left_eye_gaze_samples, trialnum_tracker, nrows_maintask);
%RegisteredTrialWiseDataGaze_affine = registered_trialwiseDataStructure(data_struct_extract.data, registered_right_eye_gaze_samples_affine, trialnumber_by_tracker_sample_list, nrows_maintask);
TrialWiseDataTouchA = tn_trialwiseDataStructure(validUnique_touchpointsA.data, trialnum_tracker_touchpointsA, nrows_maintask);
TrialWiseDataTouchB = tn_trialwiseDataStructure(validUnique_touchpointsB.data, trialnum_tracker_touchpointsB, nrows_maintask);
[~, b] = size(TrialWiseDataTouchB.timepoints);

%Interpolation: equally spaced
%[InterpolatedTrialWiseDataGaze]= tn_interpTrialData(TrialWiseDataGaze);
InterpRegTrialWiseDataGaze_poly_right= tn_interpTrialData(RegisteredTrialWiseDataGaze_poly_right);
InterpRegTrialWiseDataGaze_poly_left= tn_interpTrialData(RegisteredTrialWiseDataGaze_poly_left);
%InterpolatedRegisteredTrialWiseDataGaze_affine= tn_interpTrialData(RegisteredTrialWiseDataGaze_affine);
[InterpolatedTrialWiseDataTouchA]= tn_interpTrialDataTouch(TrialWiseDataTouchA, InterpRegTrialWiseDataGaze_poly_right);
[InterpolatedTrialWiseDataTouchB]= tn_interpTrialDataTouch(TrialWiseDataTouchB, InterpRegTrialWiseDataGaze_poly_right);


%Define the epoch: aligned to colour target onset time
%interpolate
%[epochdataGazeA] = tn_defineEpochnew(InterpolatedTrialWiseDataGaze, maintask_datastruct); %To Target Onset
epochdataRegisteredGazeA_poly_right = tn_defineEpochnew(InterpRegTrialWiseDataGaze_poly_right, maintask_datastruct);
epochdataRegisteredGazeA_poly_left = tn_defineEpochnew(InterpRegTrialWiseDataGaze_poly_left, maintask_datastruct);
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

%[Cur_fh_RTbyChoiceCombinationSwitches, merged_classifier_char_string] = rn_reactiontime_switching_block_trials(fileID);

% Plots with x recalibrated_polynomial degree 2 
% rn_TrialWiseNEWPlotRecalibrated_poly(epochdataRegisteredGazeA_poly, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly(InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly,InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly(InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_poly, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

% Plots with x recalibrated_affine 
% rn_TrialWiseNEWPlotRecalibrated_affine(epochdataRegisteredGazeA_affine, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_affine(InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_affine, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_affine(InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_affine, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

%Tarana's plot woth x recalibrated_polynomial displaying only fixations 
% target onset 
% rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID);
% 
% rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_RB(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_RB_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_BR(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_BR_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir, fileID);
% 
% rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_RB(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_RB_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_BR(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_BR_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB,ModifiedTrialSets, saving_dir, fileID);
% 
% %BIFR
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblockedtrials(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignededBIFR_reg_poly_unblocked_3D(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blockedtrials(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignededBIFR_reg_poly_blocked_3D (InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% 
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blockedtrials_RB(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blocked_RB_3D (InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blockedtrials_BR(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_blocked_BR_3D (InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% 
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblockedtrials_RB(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblocked_RB_3D(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblockedtrials_BR(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly_unblocked_BR_3D(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_left, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID)

%AIFR 
rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blockedtrials(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignededAIFR_reg_poly_blocked_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblockedtrials(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignededAIFR_reg_poly_unblocked_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blockedtrials_RB(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blocked_RB_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blockedtrials_BR(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_blocked_BR_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblockedtrials_RB(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblocked_RB_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblockedtrials_BR(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblocked_BR_3D(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_left,InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

% %Original Tarana's plots
%  tn_TrialWiseNEWPlots(epochdataGazeA, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID);
% tn_TrialWiseNEWPlotsAlignedtoBIFR(InterpolatedepochdataGazeB_Initial_Fixation_Release_A, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% tn_TrialWiseNEWPlotsAlignedtoAIFR(InterpolatedepochdataGazeA_Initial_Fixation_Release_A, InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

%Distance Gaze and Touch aligned to B release (with polynomial
%registration)
[Onset_distGazeATouchB] = rn_distbetweenGazeTouch_Onset(epochdataRegisteredGazeA_poly_right, epochdataTouchB);
[Onset_distGazeATouchA] = rn_distbetweenGazeTouch_Onset(epochdataRegisteredGazeA_poly_right, epochdataTouchA);

%Distance Gaze and Touch aligned to A release (with polynomial
%registration)
[B_distGazeATouchB]= rn_distbetweenGazeTouch(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, InterpolatedepochdataTouchB_Initial_Fixation_Release_B);
[B_distGazeATouchA]= rn_distbetweenGazeTouch(InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, InterpolatedepochdataTouchB_Initial_Fixation_Release_A);

%Distance Gaze and Touch aligneed to A release (with polynomial
%registration)
[A_distGazeATouchB]= rn_distbetweenGazeTouch(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpolatedepochdataTouchA_Initial_Fixation_Release_B);
[A_distGazeATouchA]= rn_distbetweenGazeTouch(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, InterpolatedepochdataTouchA_Initial_Fixation_Release_A);

[OnsetdistGazeATouchA_blocked, OnsetdistGazeATouchB_blocked] = rn_TrialWiseDISTNEWPlotsAlignedOnset_blockedtrials(Onset_distGazeATouchA, Onset_distGazeATouchB,epochdataRegisteredGazeA_poly_right, ModifiedTrialSets, saving_dir, fileID);
[OnsetdistGazeAtouchA_unblocked, OnsetdistGazeATouchA_unblocked] = rn_TrialWiseDISTNEWPlotsAlignedOnset_unblockedtrials(Onset_distGazeATouchA, Onset_distGazeATouchB,epochdataRegisteredGazeA_poly_right, ModifiedTrialSets, saving_dir, fileID);
[OnsetdistGazeATouchA_blocked_RB, OnsetdistGazeATouchB_blocked_RB]= rn_TrialWiseDISTNEWPlotsAlignedOnset_blockedtrials_RB(Onset_distGazeATouchA, Onset_distGazeATouchB,epochdataRegisteredGazeA_poly_right, ModifiedTrialSets, saving_dir, fileID);
[OnsetdistGazeATouchA_blocked_BR, OnsetdistGazeATouchB_blocked_BR]= rn_TrialWiseDISTNEWPlotsAlignedOnset_blockedtrials_BR(Onset_distGazeATouchA, Onset_distGazeATouchB,epochdataRegisteredGazeA_poly_right, ModifiedTrialSets, saving_dir, fileID);
[OnsetdistGazeATouchA_unblocked_RB, OnsetdistGazeATouchB_unblocked_RB]= rn_TrialWiseDISTNEWPlotsAlignedOnset_unblockedtrials_RB(Onset_distGazeATouchA, Onset_distGazeATouchB,epochdataRegisteredGazeA_poly_right, ModifiedTrialSets, saving_dir, fileID);
[OnsetdistGazeATouchA_unblocked_BR, OnsetdistGazeATouchB_unblocked_BR]= rn_TrialWiseDISTNEWPlotsAlignedOnset_unblockedtrials_BR(Onset_distGazeATouchA, Onset_distGazeATouchB,epochdataRegisteredGazeA_poly_right, ModifiedTrialSets, saving_dir, fileID);


[BIFRDistGazeATouchA_blocked,BIFRDistGazeATouchB_blocked] = tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_blockedtrials(B_distGazeATouchA, B_distGazeATouchB,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);
[BIFRDistGazeATouchA_blocked_RB,BIFRDistGazeATouchB_blocked_RB] = tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_blockedtrials_RB(B_distGazeATouchA, B_distGazeATouchB,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);
[BIFRDistGazeATouchA_blocked_BR,BIFRDistGazeATouchB_blocked_BR] = tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_blockedtrials_BR(B_distGazeATouchA, B_distGazeATouchB,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);

[BIFRDistGazeATouchA_unblocked,BIFRDistGazeATouchB_unblocked]= tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_unblockedtrials(B_distGazeATouchA, B_distGazeATouchB,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);
[BIFRDistGazeATouchA_unblocked_RB,BIFRDistGazeATouchB_unblocked_RB]= tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_unblockedtrials_RB(B_distGazeATouchA, B_distGazeATouchB,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);
[BIFRDistGazeATouchA_unblocked_BR,BIFRDistGazeATouchB_unblocked_BR] = tn_TrialWiseDISTNEWPlotsAlignedtoBIFR_unblockedtrials_BR (B_distGazeATouchA, B_distGazeATouchB,InterpepochdataRegGazeB_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);

[AIFRDistGazeATouchA_blocked,AIFRDistGazeATouchB_blocked] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_blockedtrials(A_distGazeATouchA, A_distGazeATouchB,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);
[AIFRDistGazeATouchA_blocked_RB,AIFRDistGazeATouchB_blocked_RB] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_blockedtrials_RB(A_distGazeATouchA, A_distGazeATouchB,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);
[AIFRDistGazeATouchA_blocked_BR,AIFRDistGazeATouchB_blocked_BR] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_blockedtrials_BR (A_distGazeATouchA, A_distGazeATouchB,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);


[AIFRDistGazeATouchA_unblocked,AIFRDistGazeATouchB_unblocked] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_unblockedtrials(A_distGazeATouchA, A_distGazeATouchB,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);
[AIFRDistGazeATouchA_unblocked_RB,AIFRDistGazeATouchB_unblocked_RB] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_unblockedtrials_RB(A_distGazeATouchA, A_distGazeATouchB,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);
[AIFRDistGazeATouchA_unblocked_BR,AIFRDistGazeATouchB_unblocked_BR] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR_unblockedtrials_BR(A_distGazeATouchA, A_distGazeATouchB,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID);

 



if (close_figures_on_return)
	close all;
end

return
end
