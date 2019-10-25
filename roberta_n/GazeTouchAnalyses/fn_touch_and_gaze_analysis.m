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


if (ispc)
	saving_dir='C:\taskcontroller\SCP_DATA\ANALYSES\GazeAnalyses';
	data_root_str = 'C:';
	data_dir = fullfile(data_root_str, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190320', [fileID, '.sessiondir']);
	output_dir = pwd;
	
else
	data_root_str = '/';
	saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN');
	data_base_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ');
	
	% network!
	data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data');
	
	
	year_string = fileID(1:4);
	date_string = fileID(3:8);
	
	data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, [fileID, '.sessiondir']);
	output_dir = pwd;
end

gazereg_FQN = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, gazereg_name);


if exist(fullfile(data_dir, [fileID, '.triallog.v012.mat']), 'file')
	maintask_datastruct=load(fullfile(data_dir, [fileID, '.triallog.v012.mat']));
else
	maintask_datastruct = fnParseEventIDEReportSCPv06(fullfile(data_dir, [fileID, '.triallog.txt']));
end


%EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_EyeLinkProxyTrackerA.trackerlog.txt.gz']);
EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_EyeLinkProxyTrackerA.trackerlog']);

%PQtrackerfilenameA = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_PQLabTrackerA.trackerlog.txt.gz']);
%PQtrackerfilenameB = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_SecondaryPQLabTrackerB.trackerlog.txt.gz']);
PQtrackerfilenameA = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_PQLabTrackerA.trackerlog']);
PQtrackerfilenameB = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_SecondaryPQLabTrackerB.trackerlog']);


data_struct_extract = struct([]);

data_struct_extract = fnParseEventIDETrackerLog_v01 (EyeLinkfilenameA, ';', [], []);
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

invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data (:, data_struct_extract.cn.Right_Eye_Raw_X) == eyelink_oob_value));
invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data (:, data_struct_extract.cn.Right_Eye_Raw_Y) == eyelink_oob_value));
invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data (:, data_struct_extract.cn.Left_Eye_Raw_X) == eyelink_oob_value));
invalid_datapoints = union(invalid_datapoints, find(data_struct_extract.data (:, data_struct_extract.cn.Left_Eye_Raw_Y) == eyelink_oob_value));

data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Right_Eye_Raw_X) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Right_Eye_Raw_Y) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Left_Eye_Raw_X) = NaN;
data_struct_extract.data(invalid_datapoints, data_struct_extract.cn.Left_Eye_Raw_Y) = NaN;


t_form = load(gazereg_FQN);
%apply the chosen registration to the raw left and right eye (all the
%trials)
registered_left_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Left_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_Y))]);
registered_right_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Right_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_Y))]);

registered_left_eye_gaze_samples_affine = transformPointsInverse(t_form.registration_struct.affine.Left_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_Y))]);
registered_right_eye_gaze_samples_affine = transformPointsInverse(t_form.registration_struct.affine.Right_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_Y))]);

bin_width = 2;
Xedges = (600:bin_width:(1920-600));
Yedges = (100:bin_width:750);
title_string = 'Gaze samples histogram including NaNs';
cur_fh = figure('Name', ['Gaze histogram (', title_string, ')']);
histogram2(registered_right_eye_gaze_samples (:, 1), registered_right_eye_gaze_samples(:, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
title (['Gaze histogram trials (', title_string, ')']);
axis equal;
colorbar;
set(gca(), 'YDir', 'reverse');
write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram including NaNs.pdf'));

registered_left_eye_gaze_samples_orig = registered_left_eye_gaze_samples;
registered_right_eye_gaze_samples_orig = registered_right_eye_gaze_samples;
registered_left_eye_gaze_samples_affine_orig = registered_left_eye_gaze_samples_affine;
registered_right_eye_gaze_samples_affine_orig = registered_right_eye_gaze_samples_affine;



if (exclude_saccade_samples)
	%convert to DVA
	[right_x_position_list_deg, right_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_right_eye_gaze_samples(:,1),registered_right_eye_gaze_samples(:,2),...
		960, 341.2698, 1920/1209.4, 1080/680.4, 300);
	
	%[left_x_position_list_deg, left_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_left_eye_gaze_samples(:,1),registered_left_eye_gaze_samples(:,2),...
	%960, 341.2698, 1920/1209.4, 1080/680.4, 300);
	
	% detection saccades(Igor's toolbox)
	% neg_timestamp_idx = find(data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp) < 0);
	% first_good_sample_idx = neg_timestamp_idx(end) + 1;
	% fgs_idx = first_good_sample_idx;
	
	negative_time_offset = abs(data_struct_extract.data(1,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)) + 1;
	timestamps_4_saccade_detector = data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp) + negative_time_offset;
	

	% calculate the pixel displacement between consecutive samples
	displacement_x_list = diff(registered_right_eye_gaze_samples_orig(:, 1));
	displacement_x_list(end+1) = NaN;	% we want the displacement for all samples so thatr all indices match
	
	displacement_y_list = diff(registered_right_eye_gaze_samples_orig(:, 2));
	displacement_y_list(end+1) = NaN;	% we want the displacement for all samples so thatr all indices match
	
	% now calculate the total displacement as euclidean distance in 2D
	% for any fixed sampling rate this velocity in pixels/sample correlates
	% strongly with the instantaneous velocity in pixel/time
	per_sample_euclidean_displacement_pix_list = sqrt((((displacement_x_list).^2) + ((displacement_y_list).^2)));
	
	
	% this is the "real" velocity in per time units
	sample_period_ms = unique(diff(data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)));
	velocity_pix_ms = per_sample_euclidean_displacement_pix_list / (sample_period_ms);
	
	%velocity_threshold_pixels_per_sample = 0.25;
	%velocity_threshold_pixels_per_sample = 0.5;
	%velocity_threshold_pixels_per_sample = 1;
	velocity_threshold_pixels_per_sample = 5;
	
	% index samples with instantaneous volicity below and above the threshold
	low_velocity_samples_idx = find(per_sample_euclidean_displacement_pix_list <= velocity_threshold_pixels_per_sample);
	high_velocity_samples_idx = find(per_sample_euclidean_displacement_pix_list > velocity_threshold_pixels_per_sample);
	
	
	% find consecutive samples with below velocity_threshold_pixels_per_sample
	% changes
	fixation_points_idx_diff = diff(low_velocity_samples_idx);
	fixation_points_idx_diff(end+1) = 10; % the value does not matter as long as it is >1 for the next line
	tmp_lidx = fixation_points_idx_diff <= 1;
	% these idx have >= 2 samples of below threshold velocity -> proto
	% fixations instead of saccades.
	fixation_samples_idx = low_velocity_samples_idx(tmp_lidx);
	
	
	bin_width = 2;
	Xedges = (600:bin_width:(1920-600));
	Yedges = (100:bin_width:750);
	title_string = 'Gaze samples histogram fixations (velocity_threshold_pixels_per_sample)';
	cur_fh = figure('Name', ['Gaze histogram (', title_string, ')']);
	histogram2(registered_right_eye_gaze_samples_orig(fixation_samples_idx, 1), registered_right_eye_gaze_samples_orig(fixation_samples_idx, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
	title (['Gaze histogram trials (', title_string, ')']);
	axis equal;
	colorbar;
	set(gca(), 'YDir', 'reverse');
	write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram fixations (velocity_threshold_pixels_per_sample).pdf'));
	
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
		            right_x_position_list_deg(samples_4_saccade_detector_idx), right_x_position_list_deg(samples_4_saccade_detector_idx), 'em_custom_settings_SNP_eyelink.m');
	
	right_eye_out.sac_onsets = right_eye_out.sac_onsets - negative_time_offset;
	right_eye_out.sac_offsets = right_eye_out.sac_offsets - negative_time_offset;
	timestamps = data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp);
 	
 	
    %left_eye_out = em_saccade_blink_detection(data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000, left_x_position_list_deg(fgs_idx:end), left_y_position_list_deg(fgs_idx:end), 'em_custom_settings_SNP_eyelink.m');
 	
	% exclude saccades
	fixation_onsets = (right_eye_out.sac_offsets(:,1:end-1) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint
	fixation_offsets = (right_eye_out.sac_onsets(:,2:end) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint

	samples_in_fixations_ldx = fn_find_samples_by_onset_offset_lists(timestamps, fixation_onsets, fixation_offsets);
	samples_not_in_fixations_ldx = ~samples_in_fixations_ldx;
	
	% 	samples_in_range_ldx=find(samples_in_range_ldx > 0);
	registered_left_eye_gaze_samples(samples_not_in_fixations_ldx, 1:2) = NaN;
	registered_right_eye_gaze_samples(samples_not_in_fixations_ldx, 1:2) = NaN;
	registered_left_eye_gaze_samples_affine(samples_not_in_fixations_ldx, 1:2) = NaN;
	registered_right_eye_gaze_samples_affine(samples_not_in_fixations_ldx, 1:2) = NaN;
end

timestamps = data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp);

bin_width = 2;
Xedges = (600:bin_width:(1920-600));
Yedges = (100:bin_width:750);
title_string = 'Gaze samples histogram fixations after detector';
cur_fh = figure('Name', ['Gaze histogram (', title_string, ')']);
histogram2(registered_right_eye_gaze_samples (:, 1),registered_right_eye_gaze_samples (:, 2), Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
title (['Gaze histogram trials (', title_string, ')']);
axis equal;
colorbar;
set(gca(), 'YDir', 'reverse');
write_out_figure(cur_fh, fullfile(saving_dir, 'Gaze samples histogram fixations after detector.pdf'));

if (use_velocity_fixation_detector)
	samples_not_in_fixations_ldx = ones(size(samples_in_fixations_ldx));
	samples_not_in_fixations_ldx(fixation_samples_idx) = 0;
	samples_not_in_fixations_ldx = logical(samples_not_in_fixations_ldx);
	
	
	registered_left_eye_gaze_samples = registered_left_eye_gaze_samples_orig;
	registered_right_eye_gaze_samples = registered_right_eye_gaze_samples_orig;
	registered_left_eye_gaze_samples_affine = registered_left_eye_gaze_samples_affine_orig;
	registered_right_eye_gaze_samples_affine = registered_right_eye_gaze_samples_affine_orig;
	
	
	registered_left_eye_gaze_samples(samples_not_in_fixations_ldx, 1:2) = NaN;
	registered_right_eye_gaze_samples(samples_not_in_fixations_ldx, 1:2) = NaN;
	registered_left_eye_gaze_samples_affine(samples_not_in_fixations_ldx, 1:2) = NaN;
	registered_right_eye_gaze_samples_affine(samples_not_in_fixations_ldx, 1:2) = NaN;
end


trialnum_tracker = tn_trialnumber (maintask_datastruct, data_struct_extract);

% parsing and removing invalid touch points. Tells each timepoints to which trial
% belongs
[validUnique_touchpointsA, touchtracker_datastructA, trialnum_tracker_TouchpointsA] = fn_PQtrackerdata(PQtrackerfilenameA, maintask_datastruct);
[validUnique_touchpointsB, touchtracker_datastructB, trialnum_tracker_TouchpointsB] = fn_PQtrackerdata(PQtrackerfilenameB, maintask_datastruct);


%Segregation of trials
ModifiedTrialSets = rn_segregateTrialData(maintask_datastruct);


%Gaze/Touch points on the basis of trials

TrialWiseDataGaze = modified_trialwiseDataStructure(data_struct_extract.data, trialnum_tracker, nrows_maintask);
%Registered gaze points
RegisteredTrialWiseDataGaze_poly = registered_trialwiseDataStructure(data_struct_extract.data, registered_right_eye_gaze_samples, trialnum_tracker, nrows_maintask);
RegisteredTrialWiseDataGaze_affine = registered_trialwiseDataStructure(data_struct_extract.data, registered_right_eye_gaze_samples_affine, trialnum_tracker, nrows_maintask);
TrialWiseDataTouchA = tn_trialwiseDataStructure(validUnique_touchpointsA.data, trialnum_tracker_TouchpointsA, nrows_maintask);
TrialWiseDataTouchB = tn_trialwiseDataStructure(validUnique_touchpointsB.data, trialnum_tracker_TouchpointsB, nrows_maintask);
[~, b] = size(TrialWiseDataTouchB.timepoints);

%Interpolation: equally spaced
[InterpolatedTrialWiseDataGaze]= tn_interpTrialData(TrialWiseDataGaze);
InterpolatedRegisteredTrialWiseDataGaze_poly= tn_interpTrialData(RegisteredTrialWiseDataGaze_poly);
InterpolatedRegisteredTrialWiseDataGaze_affine= tn_interpTrialData(RegisteredTrialWiseDataGaze_affine);
[InterpolatedTrialWiseDataTouchA]= tn_interpTrialDataTouch(TrialWiseDataTouchA, InterpolatedTrialWiseDataGaze);
[InterpolatedTrialWiseDataTouchB]= tn_interpTrialDataTouch(TrialWiseDataTouchB, InterpolatedTrialWiseDataGaze);


%Define the epoch: aligned to colour target onset time
%interpolate
[epochdataGazeA] = tn_defineEpochnew(InterpolatedTrialWiseDataGaze, maintask_datastruct); %To Target Onset
epochdataRegisteredGazeA_poly = tn_defineEpochnew(InterpolatedRegisteredTrialWiseDataGaze_poly, maintask_datastruct);
epochdataRegisteredGazeA_affine = tn_defineEpochnew(InterpolatedRegisteredTrialWiseDataGaze_affine, maintask_datastruct);
[epochdataTouchA] = tn_defineEpochnew(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchB] = tn_defineEpochnew(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
ArrayforInterpolation=(-0.5:0.002:1.3);
[InterpolatedepochdataGazeA] = tn_interpTrialDataEpoch(epochdataGazeA.TargetOnset, ArrayforInterpolation);
InterpolatedepochdataRegGazeA_poly = tn_interpTrialDataEpoch (epochdataRegisteredGazeA_poly.TargetOnset, ArrayforInterpolation);
[InterpolatedepochdataTouchA] = tn_interpTrialDataTouch(epochdataTouchA.TargetOnset, InterpolatedepochdataRegGazeA_poly);
[InterpolatedepochdataTouchB] = tn_interpTrialDataTouch(epochdataTouchB.TargetOnset, InterpolatedepochdataRegGazeA_poly);

%%This is to define the epoch: aligned to the Initial fixation release time of the Player B (confederate in my case, but can be used as it is for any data)
%%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/
ArrayforInterpolation_BIFRA=(-0.5:0.002:0.9);
[epochdataGazeB_Initial_Fixation_Release_A] = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGaze, maintask_datastruct);
epochdataRegGazeB_Initial_Fixation_Release_A_poly = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedRegisteredTrialWiseDataGaze_poly, maintask_datastruct);
epochdataRegGazeB_Initial_Fixation_Release_A_affine = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedRegisteredTrialWiseDataGaze_affine, maintask_datastruct);
[epochdataTouchB_Initial_Fixation_Release_A] = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchB_Initial_Fixation_Release_B] = tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeB_Initial_Fixation_Release_A] = tn_interpTrialDataEpoch(epochdataGazeB_Initial_Fixation_Release_A, ArrayforInterpolation_BIFRA);
InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly = tn_interpTrialDataEpoch(epochdataRegGazeB_Initial_Fixation_Release_A_poly, ArrayforInterpolation_BIFRA);
InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_affine = tn_interpTrialDataEpoch(epochdataRegGazeB_Initial_Fixation_Release_A_affine, ArrayforInterpolation_BIFRA);
[InterpolatedepochdataTouchB_Initial_Fixation_Release_A] = tn_interpTrialDataTouch(epochdataTouchB_Initial_Fixation_Release_A, InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly);
[InterpolatedepochdataTouchB_Initial_Fixation_Release_B] = tn_interpTrialDataTouch(epochdataTouchB_Initial_Fixation_Release_B, InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly);

%This is to define the epoch: aligned to the Initial fixation release time of the Player A (Elmo in my case, but can be used as it is for any data)
%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/
ArrayforInterpolation_AIFRA =(-0.5:0.002:0.9);
[epochdataGazeA_Initial_Fixation_Release_A] = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGaze, maintask_datastruct);
epochdataRegGazeA_Initial_Fixation_Release_A_poly = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedRegisteredTrialWiseDataGaze_poly, maintask_datastruct);
epochdataRegGazeA_Initial_Fixation_Release_A_affine = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedRegisteredTrialWiseDataGaze_affine, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_A] = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_B] = tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeA_Initial_Fixation_Release_A] = tn_interpTrialDataEpoch(epochdataGazeA_Initial_Fixation_Release_A, ArrayforInterpolation_AIFRA);
InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_poly = tn_interpTrialDataEpoch(epochdataRegGazeA_Initial_Fixation_Release_A_poly, ArrayforInterpolation_AIFRA);
InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_affine = tn_interpTrialDataEpoch(epochdataRegGazeA_Initial_Fixation_Release_A_affine, ArrayforInterpolation_AIFRA);
[InterpolatedepochdataTouchA_Initial_Fixation_Release_A] = tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_A, InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_poly);
[InterpolatedepochdataTouchA_Initial_Fixation_Release_B] = tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_B, InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_poly);



%Plotting Elmo's RT over human's switching block unblocked_condition
%[Cur_fh_RTbyChoiceCombinationSwitches, merged_classifier_char_string]=rn_reactiontime_switching_block_trials(maintask_datastruct,ModifiedTrialSets);

% Plots with x recalibrated_polynomial degree 2 
% rn_TrialWiseNEWPlotRecalibrated_poly(epochdataRegisteredGazeA_poly, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly(InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly,InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly(InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_poly, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

% Plots with x recalibrated_affine 
% rn_TrialWiseNEWPlotRecalibrated_affine(epochdataRegisteredGazeA_affine, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)
% rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_affine(InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_affine, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_affine(InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_affine, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

%Tarana's plot woth x recalibrated_polynomial displaying only fixations 
rn_TrialWiseNEWPlotRecalibrated_poly(epochdataRegisteredGazeA_poly, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)
rn_TrialWiseNEWPlotsAlignedtoBIFR_reg_poly(InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly,InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly(InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_poly, InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

% %Original Tarana's plots
%  tn_TrialWiseNEWPlots(epochdataGazeA, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID);
% tn_TrialWiseNEWPlotsAlignedtoBIFR(InterpolatedepochdataGazeB_Initial_Fixation_Release_A, InterpolatedepochdataTouchB_Initial_Fixation_Release_A,InterpolatedepochdataTouchB_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);
% tn_TrialWiseNEWPlotsAlignedtoAIFR(InterpolatedepochdataGazeA_Initial_Fixation_Release_A, InterpolatedepochdataTouchA_Initial_Fixation_Release_A,InterpolatedepochdataTouchA_Initial_Fixation_Release_B, ModifiedTrialSets, saving_dir, fileID);

%Distance Gaze and Touch aligned to B release (with polynomial
%registration)
[Onset_distGazeATouchB] = rn_distbetweenGazeTouch(InterpolatedepochdataRegGazeA_poly, InterpolatedepochdataTouchB);
[Onset_distGazeATouchA] = rn_distbetweenGazeTouch(InterpolatedepochdataRegGazeA_poly, InterpolatedepochdataTouchA);

[B_distGazeATouchB]= rn_distbetweenGazeTouch(InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly, InterpolatedepochdataTouchB_Initial_Fixation_Release_B);
[B_distGazeATouchA]= rn_distbetweenGazeTouch(InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly, InterpolatedepochdataTouchB_Initial_Fixation_Release_A);

%Distance Gaze and Touch aligneed to A release (with polynomial
%registration)
[A_distGazeATouchB]= rn_distbetweenGazeTouch(InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_poly, InterpolatedepochdataTouchA_Initial_Fixation_Release_B);
[A_distGazeATouchA]= rn_distbetweenGazeTouch(InterpolatedepochdataRegGazeA_Initial_Fixation_Release_A_poly, InterpolatedepochdataTouchA_Initial_Fixation_Release_A);

[OnsetSeparatedistGazeATouchA, OnsetSeparatedGazeATouchB]= rn_TrialWiseDISTNEWPlotsAlignedOnset(Onset_distGazeATouchA, Onset_distGazeATouchB,InterpolatedepochdataRegGazeA_poly, ModifiedTrialSets, saving_dir, fileID);

[BIFRSeparatedDistGazeATouchA, BIFRSeparatedDistGazeATouchB]= tn_TrialWiseDISTNEWPlotsAlignedtoBIFR(B_distGazeATouchA, B_distGazeATouchB,InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly, ModifiedTrialSets, saving_dir, fileID);

[AIFRSeparatedDistGazeATouchA, AIFRSeparatedDistGazeATouchB] = tn_TrialWiseDISTNEWPlotsAlignedtoAIFR(A_distGazeATouchA, A_distGazeATouchB,InterpolatedepochdataRegGazeB_Initial_Fixation_Release_A_poly, ModifiedTrialSets, saving_dir, fileID);


fixation_onsets_trialID_list= zeros(size(fixation_onsets));
for i_trialnumber= 1:size(TrialWiseDataGaze.TrialNumber);
	
	current_trial_start_ts = TrialWiseDataGaze.timepoints(i_trialnumber, 1);
	
	if isnan(current_trial_start_ts)
		continue
	end
	
	tmp_nonnan_idx = find(~isnan(TrialWiseDataGaze.timepoints(i_trialnumber, :)));
	current_trial_end_ts = TrialWiseDataGaze.timepoints(i_trialnumber, tmp_nonnan_idx(end));
	
	if isnan(current_trial_end_ts)
		continue
	end
	
	fixation_onset_4_current_trial_idx = find((fixation_onsets >= current_trial_start_ts) & (fixation_onsets <= current_trial_end_ts));
	fixation_onsets_trialID_list(fixation_onset_4_current_trial_idx) = TrialWiseDataGaze.TrialNumber(i_trialnumber);
	
end

fixation_4_trial = nonzeros(fixation_onsets_trialID_list);
fixation_onsets_4_trial = fixation_onsets(fixation_4_trial);

% Unblocked trials from red to yellow
[fixation_switch_unblocked_RB touch_B_switch_unblocked_RB touch_A_switch_unblocked_RB] =  fn_fixation_analysis (fixation_onsets_4_trial, epochdataGazeB_Initial_Fixation_Release_A, ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_switchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_switch_unblocked_RB, touch_B_switch_unblocked_RB);
distFixATouchA_switchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_switch_unblocked_RB, touch_A_switch_unblocked_RB);

[fixation_before_switch_unblocked_RB touch_B_before_switch_unblocked_RB touch_A_before_switch_unblocked_RB] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB-1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_beforeswitchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_before_switch_unblocked_RB, touch_B_before_switch_unblocked_RB);
distFixATouchA_beforeswitchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_before_switch_unblocked_RB, touch_A_before_switch_unblocked_RB);

[fixation_next_switch_unblocked_RB touch_B_next_switch_unblocked_RB touch_A_next_switch_unblocked_RB] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB+1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_nextswitchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_next_switch_unblocked_RB, touch_B_next_switch_unblocked_RB);
distFixATouchA_nextswitchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_next_switch_unblocked_RB, touch_A_next_switch_unblocked_RB);

%Unblocked trials from yellow to red
[fixation_switch_unblocked_BR touch_B_switch_unblocked_BR touch_A_switch_unblocked_BR] =  fn_fixation_analysis (fixation_onsets_4_trial, epochdataGazeB_Initial_Fixation_Release_A, ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_switchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_switch_unblocked_BR, touch_B_switch_unblocked_BR);
distFixATouchA_switchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_switch_unblocked_BR, touch_A_switch_unblocked_BR);

[fixation_before_switch_unblocked_BR touch_B_before_switch_unblocked_BR touch_A_before_switch_unblocked_BR] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR-1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_beforeswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_before_switch_unblocked_BR, touch_B_before_switch_unblocked_BR);
distFixATouchA_beforeswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_before_switch_unblocked_BR, touch_A_before_switch_unblocked_BR);

[fixation_next_switch_unblocked_BR touch_B_next_switch_unblocked_BR touch_A_next_switch_unblocked_BR] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR+1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_nextswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_next_switch_unblocked_BR, touch_B_next_switch_unblocked_BR);
distFixATouchA_nextswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_next_switch_unblocked_BR, touch_A_next_switch_unblocked_BR);

%Blocked trials from red to yellow
[fixation_switch_blocked_RB touch_B_switch_blocked_RB touch_A_switch_blocked_RB] =  fn_fixation_analysis (fixation_onsets_4_trial, epochdataGazeB_Initial_Fixation_Release_A, ModifiedTrialSets.BySwitchingBlock.BlockedTrials.RB ,epochdataTouchB_Initial_Fixation_Release_A,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_switchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_switch_blocked_RB, touch_B_switch_blocked_RB);
distFixATouchA_switchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_switch_blocked_RB, touch_A_switch_blocked_RB);

[fixation_before_switch_blocked_RB touch_B_before_switch_blocked_RB touch_A_before_switch_blocked_RB] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.BlockedTrials.RB-1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_beforeswitchtrials_blocked_RB = rn_distbetweenFixTouch(fixation_before_switch_blocked_RB, touch_B_before_switch_blocked_RB);
distFixATouchA_beforeswitchtrials_blocked_RB = rn_distbetweenFixTouch(fixation_before_switch_blocked_RB, touch_A_before_switch_blocked_RB);

[fixation_next_switch_blocked_RB touch_B_next_switch_blocked_RB touch_A_next_switch_blocked_RB] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.BlockedTrials.RB+1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_nextswitchtrials_blocked_RB = rn_distbetweenFixTouch(fixation_next_switch_blocked_RB, touch_B_next_switch_blocked_RB);
distFixATouchA_nextswitchtrials_blocked_RB = rn_distbetweenFixTouch(fixation_next_switch_blocked_RB, touch_A_next_switch_blocked_RB);

%blocked trials from yellow to red
[fixation_switch_blocked_BR touch_B_switch_blocked_BR touch_A_switch_blocked_BR] =  fn_fixation_analysis (fixation_onsets_4_trial, epochdataGazeB_Initial_Fixation_Release_A, ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_switchtrials_blocked_BR = rn_distbetweenFixTouch(fixation_switch_blocked_BR, touch_B_switch_blocked_BR);
distFixATouchA_switchtrials_blocked_BR = rn_distbetweenFixTouch(fixation_switch_blocked_BR, touch_A_switch_blocked_BR);

[fixation_before_switch_blocked_BR touch_B_before_switch_blocked_BR touch_A_before_switch_blocked_BR] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR-1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_beforeswitchtrials_blocked_BR = rn_distbetweenFixTouch(fixation_before_switch_unblocked_BR, touch_B_before_switch_blocked_BR);
distFixATouchA_beforeswitchtrials_blocked_BR = rn_distbetweenFixTouch(fixation_before_switch_unblocked_BR, touch_A_before_switch_blocked_BR);

[fixation_next_switch_blocked_BR touch_B_next_switch_blocked_BR touch_A_next_switch_blocked_BR] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR+1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_nextswitchtrials_blocked_BR = rn_distbetweenFixTouch(fixation_next_switch_unblocked_BR, touch_B_next_switch_blocked_BR);
distFixATouchA_nextswitchtrials_blocked_BR = rn_distbetweenFixTouch(fixation_next_switch_unblocked_BR, touch_A_next_switch_blocked_BR);

%blocked trials from red to yellow
[fixation_switch_unblocked_RB touch_B_switch_unblocked_RB touch_A_switch_unblocked_RB] =  fn_fixation_analysis (fixation_onsets_4_trial, epochdataGazeB_Initial_Fixation_Release_A, ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_switchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_switch_unblocked_RB, touch_B_switch_unblocked_RB);
distFixATouchA_switchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_switch_unblocked_RB, touch_A_switch_unblocked_RB);

[fixation_before_switch_unblocked_RB touch_B_before_switch_unblocked_RB touch_A_before_switch_unblocked_RB] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB-1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_beforeswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_before_switch_unblocked_RB, touch_B_before_switch_unblocked_RB);
distFixATouchA_beforeswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_before_switch_unblocked_RB, touch_A_before_switch_unblocked_RB);

[fixation_next_switch_unblocked_RB touch_B_next_switch_unblocked_RB touch_A_next_switch_unblocked_RB] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB+1 ,epochdataTouchB_Initial_Fixation_Release_B,epochdataTouchB_Initial_Fixation_Release_A);
distFixATouchB_nextswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_next_switch_unblocked_RB, touch_B_next_switch_unblocked_RB);
distFixATouchA_nextswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_next_switch_unblocked_RB, touch_A_next_switch_unblocked_RB);





if (close_figures_on_return)
	close all;
end

return
end
