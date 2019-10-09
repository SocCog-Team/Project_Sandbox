function [] = fn_touch_and_gaze_analysis(fileID, gazereg_name)

timestamps.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);


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

invalid_datapoints = find(data_struct_extract.data (:,2)==-32768); %% Removing invalid data pts as defined by eyelink/eventide
data_struct_extract.data(invalid_datapoints,2:3) = NaN;

report_struct = maintask_datastruct.report_struct; 
start_val_col_idx = report_struct.cn.A_InitialFixationReleaseTime_ms;
end_val_col_idx = report_struct.cn.A_TargetOffsetTime_ms; 
start_offset = -500;
end_offset = 500;

trialnum_tracker = tn_trialnumber (maintask_datastruct, data_struct_extract);

% parsing and removing invalid touch points. Tells each timepoints to which trial
% belongs
[validUnique_touchpointsA, touchtracker_datastructA, trialnum_tracker_TouchpointsA] = fn_PQtrackerdata(PQtrackerfilenameA, maintask_datastruct);
[validUnique_touchpointsB, touchtracker_datastructB, trialnum_tracker_TouchpointsB] = fn_PQtrackerdata(PQtrackerfilenameB, maintask_datastruct);
 
% %Gaze/Touch points on the basis of trials
 
[TrialWiseDataGaze]= modified_trialwiseDataStructure(data_struct_extract.data, trialnum_tracker, nrows_maintask);
[TrialWiseDataTouchA]= tn_trialwiseDataStructure(validUnique_touchpointsA.data,trialnum_tracker_TouchpointsA,nrows_maintask);
[TrialWiseDataTouchB]= tn_trialwiseDataStructure(validUnique_touchpointsB.data,trialnum_tracker_TouchpointsB,nrows_maintask);
[~, b]=size(TrialWiseDataTouchB.timepoints);

%Interpolation: equally spaced
[InterpolatedTrialWiseDataGaze]= tn_interpTrialData(TrialWiseDataGaze);
[InterpolatedTrialWiseDataTouchA]= tn_interpTrialDataTouch(TrialWiseDataTouchA, InterpolatedTrialWiseDataGaze);
[InterpolatedTrialWiseDataTouchB]= tn_interpTrialDataTouch(TrialWiseDataTouchB, InterpolatedTrialWiseDataGaze);


%Define the epoch: aligned to colour target onset time
%interpolate
[epochdataGazeA]= tn_defineEpochnew(InterpolatedTrialWiseDataGaze, maintask_datastruct); %To Target Onset
[epochdataTouchA]= tn_defineEpochnew(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchB]= tn_defineEpochnew(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
ArrayforInterpolation=(-0.5:0.002:1.3);
[InterpolatedepochdataGazeA]= tn_interpTrialDataEpoch(epochdataGazeA.TargetOnset, ArrayforInterpolation);
[InterpolatedepochdataTouchA]= tn_interpTrialDataTouch(epochdataTouchA.TargetOnset, InterpolatedepochdataGazeA);
[InterpolatedepochdataTouchB]= tn_interpTrialDataTouch(epochdataTouchB.TargetOnset, InterpolatedepochdataGazeA);

%%This is to define the epoch: aligned to the Initial fixation release time of the Player B (confederate in my case, but can be used as it is for any data)
%%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/
ArrayforInterpolation=(-0.2:0.002:0.9);
[epochdataGazeB_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGaze, maintask_datastruct);
[epochdataTouchB_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchB_Initial_Fixation_Release_B]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeB_Initial_Fixation_Release_A]= tn_interpTrialDataEpoch(epochdataGazeB_Initial_Fixation_Release_A, ArrayforInterpolation);
[InterpolatedepochdataTouchB_Initial_Fixation_Release_A]= tn_interpTrialDataTouch(epochdataTouchB_Initial_Fixation_Release_A, InterpolatedepochdataGazeB_Initial_Fixation_Release_A);
[InterpolatedepochdataTouchB_Initial_Fixation_Release_B]= tn_interpTrialDataTouch(epochdataTouchB_Initial_Fixation_Release_B, InterpolatedepochdataGazeB_Initial_Fixation_Release_A);

%This is to define the epoch: aligned to the Initial fixation release time of the Player A (Elmo in my case, but can be used as it is for any data)
%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/
ArrayforInterpolation=(-1:0.002:0.5);
[epochdataGazeA_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGaze, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_B]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeA_Initial_Fixation_Release_A]= tn_interpTrialDataEpoch(epochdataGazeA_Initial_Fixation_Release_A, ArrayforInterpolation);
[InterpolatedepochdataTouchA_Initial_Fixation_Release_A]= tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_A, InterpolatedepochdataGazeA_Initial_Fixation_Release_A);
[InterpolatedepochdataTouchA_Initial_Fixation_Release_B]= tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_B, InterpolatedepochdataGazeA_Initial_Fixation_Release_A);


%Segregation of trials
[ModifiedTrialSets]=rn_segregateTrialData(maintask_datastruct);

%Plotting Elmo's RT over human's switching block unblocked_condition
[Cur_fh_RTbyChoiceCombinationSwitches, merged_classifier_char_string]=rn_reactiontime_switching_block_trials(maintask_datastruct,ModifiedTrialSets);

%load t_form
t_form = load(gazereg_FQN);

%apply the chosen registration to the raw left and right eye (all the
%trials)
registered_left_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Left_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_Y))]);
registered_right_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Right_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_Y))]);


% switching_trials_RB_idx = ismember(trialnum_tracker, ModifiedTrialSets.BySwitchingBlock.RB);
% switching_trials_RB = trialnum_tracker(switching_trials_RB_idx);
% right_x_coordinates_RB = registered_right_eye_gaze_samples(switching_trials_RB_idx, 1);
% right_y_coordinates_RB = registered_right_eye_gaze_samples(switching_trials_RB_idx, 2);
% 
% switching_trials_BR_idx = ismember(trialnum_tracker, ModifiedTrialSets.BySwitchingBlock.BR);
% switching_trials_BR = trialnum_tracker(switching_trials_BR_idx);
% right_x_coordinates_BR = registered_right_eye_gaze_samples(switching_trials_BR_idx, 1);
% right_y_coordinates_BR = registered_right_eye_gaze_samples(switching_trials_BR_idx, 2);

%convert to DVA
[right_x_position_list_deg, right_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_right_eye_gaze_samples(:,1),registered_right_eye_gaze_samples(:,2),...
	960, 341.2698, 1920/1209.4, 1080/680.4, 300);

% [right_x_position_list_deg_RB, right_y_position_list_deg_RB] = fn_convert_pixels_2_DVA(right_x_coordinates_RB,right_y_coordinates_RB,...
% 	960, 341.2698, 1920/1209.4, 1080/680.4, 300);
% 
% [right_x_position_list_deg_BR, right_y_position_list_deg_BR] = fn_convert_pixels_2_DVA(right_x_coordinates_BR,right_y_coordinates_BR,...
% 	960, 341.2698, 1920/1209.4, 1080/680.4, 300);

% detection saccades(Igor's toolbox)

neg_timestamp_idx = find(data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp) < 0);
first_good_sample_idx = neg_timestamp_idx(end) + 1;
fgs_idx = first_good_sample_idx;

% timestamps_s = data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000;
% switching_block_timestamps_RB = timestamps_s(switching_trials_RB_idx);
% switching_block_timestamps_BR = timestamps_s(switching_trials_BR_idx);


%Detection of saccade for all the trials 

%right_eye_out_default_parameters = em_saccade_blink_detection(data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000, right_x_position_list_deg(fgs_idx:end), right_y_position_list_deg(fgs_idx:end),'OpenFigure', true,'Plot',true);
right_eye_out = em_saccade_blink_detection(data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000, right_x_position_list_deg(fgs_idx:end), right_y_position_list_deg(fgs_idx:end), 'em_custom_settings_SNP_eyelink.m');

% exclude saccades

fixation_onsets = (right_eye_out.sac_offsets(:,:) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint
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
[fixation_switch_unblocked_RB touch_switch_unblocked_RB] =  fn_fixation_analysis (fixation_onsets_4_trial, epochdataGazeB_Initial_Fixation_Release_A, ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB ,epochdataTouchB_Initial_Fixation_Release_B);
distFixATouchB_switchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_switch_unblocked_RB, touch_switch_unblocked_RB);

[fixation_before_switch_unblocked_RB touch_before_switch_unblocked_RB] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB-1 ,epochdataTouchB_Initial_Fixation_Release_B);
distFixATouchB_beforeswitchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_before_switch_unblocked_RB, touch_before_switch_unblocked_RB);

[fixation_next_switch_unblocked_RB touch_next_switch_unblocked_RB] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB+1 ,epochdataTouchB_Initial_Fixation_Release_B);
distFixATouchB_nextswitchtrials_unblocked_RB = rn_distbetweenFixTouch(fixation_next_switch_unblocked_RB, touch_next_switch_unblocked_RB);

%Unblocked trials from yellow to red

[fixation_switch_unblocked_BR touch_switch_unblocked_BR] =  fn_fixation_analysis (fixation_onsets_4_trial, epochdataGazeB_Initial_Fixation_Release_A, ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR ,epochdataTouchB_Initial_Fixation_Release_B);
distFixATouchB_switchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_switch_unblocked_BR, touch_switch_unblocked_BR);

[fixation_before_switch_unblocked_BR touch_before_switch_unblocked_BR] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR-1 ,epochdataTouchB_Initial_Fixation_Release_B);
distFixATouchB_beforeswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_before_switch_unblocked_BR, touch_before_switch_unblocked_BR);

[fixation_next_switch_unblocked_BR touch_next_switch_unblocked_BR] = fn_fixation_analysis (fixation_onsets_4_trial,epochdataGazeB_Initial_Fixation_Release_A,ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR+1 ,epochdataTouchB_Initial_Fixation_Release_B);
distFixATouchB_nextswitchtrials_unblocked_BR = rn_distbetweenFixTouch(fixation_next_switch_unblocked_BR, touch_next_switch_unblocked_BR);

if (close_figures_on_return)
	close all;
end

return
end
