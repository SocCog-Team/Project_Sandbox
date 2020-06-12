function [] = fn_vergence_analysis(fileID, gazereg_name)

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


maintask_datastruct = fnParseEventIDEReportSCPv06(fullfile(data_dir, [fileID, '.triallog']));
if ~isfield(maintask_datastruct, 'report_struct')
	tmp.report_struct = maintask_datastruct;
	maintask_datastruct = tmp;
end
report_struct = maintask_datastruct.report_struct;



EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_EyeLinkProxyTrackerA.trackerlog']);

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


%trialnum_tracker = fn_trialnumber(maintask_datastruct, data_struct_extract);
%trialnumber_by_tracker_sample_list = data_struct_extract.data(:, data_struct_extract.cn.TrialNumber);
trialnumber_by_tracker_sample_list = fn_assign_trialnum2samples_by_range(report_struct, data_struct_extract, report_struct.cn.A_InitialFixationReleaseTime_ms, -500, report_struct.cn.A_TargetOffsetTime_ms, 500);

%trialnumber_by_tracker_sample_list = fn_assign_trialnum2samples_by_range(report_struct, data_struct_extract, report_struct.cn.A_InitialFixationReleaseTime_ms, -500, report_struct.cn.A_TargetOffsetTime_ms, -500);

%load t_form
t_form = load(gazereg_FQN);

%apply the chosen registration to the raw left and right eye
registered_left_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Left_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_Y))]);
registered_right_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Right_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_Y))]);


ModifiedTrialSets = rn_segregateTrialData(maintask_datastruct);

DualSubjectSolo_trials = intersect(ModifiedTrialSets.ByJointness.DualSubjectSoloTrials,ModifiedTrialSets.ByChoices.NumChoices02);
DualSubjectSolo_SuccessfulChoiceTrials = intersect(DualSubjectSolo_trials,ModifiedTrialSets.ByOutcome.SideA.REWARD);

SingleSubjectTrials_trials = intersect(ModifiedTrialSets.ByActivity.SingleSubjectTrials,ModifiedTrialSets.ByChoices.NumChoices02);
SingleSubject_SuccessfulChoiceTrials= intersect(SingleSubjectTrials_trials,ModifiedTrialSets.ByOutcome.SideA.REWARD);

Joint_choicetargets = intersect(ModifiedTrialSets.ByJointness.DualSubjectJointTrials,ModifiedTrialSets.ByChoices.NumChoices02);
bothrewarded = intersect(ModifiedTrialSets.ByOutcome.SideA.REWARD, ModifiedTrialSets.ByOutcome.SideB.REWARD);

Joint_SuccessfulChoiceTrials = intersect(Joint_choicetargets, bothrewarded);
Joint_SuccessfulChoiceTrials_BlockedTrials = intersect(Joint_SuccessfulChoiceTrials,ModifiedTrialSets.ByVisibility.AB_invisible);
Joint_SuccessfulChoiceTrials_UnBlockedTrials = setdiff(Joint_SuccessfulChoiceTrials, Joint_SuccessfulChoiceTrials_BlockedTrials);



%convert to DVA
[right_x_position_list_deg, right_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_right_eye_gaze_samples(:,1),registered_right_eye_gaze_samples(:,2),...
	960, 341.2698, 1920/1209.4, 1080/680.4, 300);

% detection saccades(Igor's toolbox)
neg_timestamp_idx = find(data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp) < 0);
first_good_sample_idx = neg_timestamp_idx(end) + 1;
fgs_idx = first_good_sample_idx;

%Detection of saccade for all the trials 
right_eye_out = em_saccade_blink_detection(data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000, right_x_position_list_deg(fgs_idx:end), right_y_position_list_deg(fgs_idx:end), 'em_custom_settings_SNP_eyelink.m');
%left_eye_out = em_saccade_blink_detection(data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000, left_x_position_list_deg(fgs_idx:end), left_y_position_list_deg(fgs_idx:end), 'em_custom_settings_SNP_eyelink.m');

% exclude saccades
fixation_onsets = (right_eye_out.sac_offsets(:,1:end-1) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint
fixation_offsets = (right_eye_out.sac_onsets(:,2:end) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint

samples_in_range_ldx = fn_find_samples_by_onset_offset_lists(data_struct_extract.data(:, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp), fixation_onsets, fixation_offsets );

% successful_trials_idx = ismember(trialnumber_by_tracker_sample_list, SuccessfulChoiceTrials);
% fix_successful_trials_idx = successful_trials_idx & samples_in_range_ldx;

solo_trials = intersect(trialnumber_by_tracker_sample_list,ModifiedTrialSets.ByJointness.DualSubjectSoloTrials);
solo_trials_idx = ismember(trialnumber_by_tracker_sample_list, solo_trials);
if isempty(find(solo_trials_idx))
	solo_trials_idx = ismember(trialnumber_by_tracker_sample_list, ModifiedTrialSets.ByActivity.SingleSubjectTrials);
end

fix_solo_trials_idx = solo_trials_idx & samples_in_range_ldx;

successful_solo_trials = intersect(trialnumber_by_tracker_sample_list,DualSubjectSolo_SuccessfulChoiceTrials);
successful_solo_trials_idx = ismember(trialnumber_by_tracker_sample_list,successful_solo_trials);
if isempty(find(successful_solo_trials_idx))
	successful_solo_trials_idx = ismember(trialnumber_by_tracker_sample_list, SingleSubject_SuccessfulChoiceTrials);
end
fix_successful_solo_trials_idx = successful_solo_trials_idx & samples_in_range_ldx;

invisible_trials =  intersect(trialnumber_by_tracker_sample_list,ModifiedTrialSets.ByVisibility.AB_invisible);
invisible_trials_idx = ismember(trialnumber_by_tracker_sample_list,invisible_trials);
fix_invisible_trials_idx = invisible_trials_idx & samples_in_range_ldx;

successful_invisible_trials = intersect(trialnumber_by_tracker_sample_list,Joint_SuccessfulChoiceTrials_BlockedTrials);
successful_invisible_trials_idx = ismember(trialnumber_by_tracker_sample_list,successful_invisible_trials);
fix_successful_invisible_trials_idx = successful_invisible_trials_idx & samples_in_range_ldx;

joint_trials = intersect(trialnumber_by_tracker_sample_list, ModifiedTrialSets.ByJointness.DualSubjectJointTrials) ;
joint_trials_idx = ismember(trialnumber_by_tracker_sample_list, joint_trials);

joint_visible_trials = setdiff(joint_trials,invisible_trials);
joint_visible_trials_idx = ismember (trialnumber_by_tracker_sample_list, joint_visible_trials);
fix_joint_visible_trials_idx = joint_visible_trials_idx & samples_in_range_ldx;

successful_visible_trials = intersect(trialnumber_by_tracker_sample_list,Joint_SuccessfulChoiceTrials_UnBlockedTrials);
successful_visible_trials_idx = ismember(trialnumber_by_tracker_sample_list,successful_visible_trials);
fix_successful_visible_trials_idx = successful_visible_trials_idx & samples_in_range_ldx;

successful_postswitch_trials_invisible_RB = intersect (successful_invisible_trials, ModifiedTrialSets.ByPostSwitch.Blocked.RB);
successful_postswitch_trials_invisible_RB_idx = ismember(trialnumber_by_tracker_sample_list, successful_postswitch_trials_invisible_RB);
fix_successful_postswitch_trials_invisible_RB_idx = successful_postswitch_trials_invisible_RB_idx & samples_in_range_ldx;

successful_postswitch_trials_invisible_BR = intersect (successful_invisible_trials, ModifiedTrialSets.ByPostSwitch.Blocked.BR);
successful_postswitch_trials_invisible_BR_idx = ismember(trialnumber_by_tracker_sample_list, successful_postswitch_trials_invisible_BR);
fix_successful_postswitch_trials_invisible_BR_idx = successful_postswitch_trials_invisible_BR_idx & samples_in_range_ldx;

successful_postswitch_trials_visible_RB = intersect (successful_visible_trials, ModifiedTrialSets.ByPostSwitch.Unblocked.RB);
successful_postswitch_trials_visible_RB_idx = ismember(trialnumber_by_tracker_sample_list, successful_postswitch_trials_visible_RB);
fix_successful_postswitch_trials_visible_RB_idx = successful_postswitch_trials_visible_RB_idx & samples_in_range_ldx;

successful_postswitch_trials_visible_BR = intersect (successful_visible_trials, ModifiedTrialSets.ByPostSwitch.Unblocked.BR);
successful_postswitch_trials_visible_BR_idx = ismember(trialnumber_by_tracker_sample_list, successful_postswitch_trials_visible_BR);
fix_successful_postswitch_trials_visible_BR_idx = successful_postswitch_trials_visible_BR_idx & samples_in_range_ldx;



bin_width = 2;
Xedges = (600:bin_width:(1920-600));
Yedges = (100:bin_width:750);

%[solo_fix_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples, fix_solo_trials_idx, ...
	%Xedges, Yedges, 'Solo fix trials', 'solo fix', output_dir, fileID);

[successful_solo_fix_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples, fix_successful_solo_trials_idx, ...
	Xedges, Yedges, 'Successful Solo fix trials', 'successful solo fix', output_dir, fileID);

%[joint_visible_fix_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples, fix_joint_visible_trials_idx, ...
	%Xedges, Yedges, 'Joint visible fix trials', 'joint_fix_visible', output_dir, fileID);

[successful_visible_fix_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples, fix_successful_visible_trials_idx, ...
	Xedges, Yedges, 'Successful Joint visible fix trials', 'successful_joint_fix_visible', output_dir, fileID);

%[joint_invisible_fix_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples, fix_invisible_trials_idx, ...
	%Xedges, Yedges, 'Joint invisible fix trials', 'joint_fix_invisible', output_dir, fileID);

[successful_invisible_fix_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples,fix_successful_invisible_trials_idx, ...
	Xedges, Yedges, 'Successful Joint invisible fix trials', 'successful_joint_fix_invisible', output_dir, fileID);

[successful_postswitch_trials_invisible_RB_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples,fix_successful_postswitch_trials_invisible_RB_idx, ...
	Xedges, Yedges, 'Successful postswitch from red to blue blocked  fix trials', 'successful_post_switch_blocked_RB_fix', output_dir, fileID);

[successful_postswitch_trials_invisible_BR_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples,fix_successful_postswitch_trials_invisible_BR_idx, ...
	Xedges, Yedges, 'Successful postswitch from blue to red blocked  fix trials', 'successful_post_switch_blocked_BR_fix', output_dir, fileID);

[successful_postswitch_trials_visible_RB_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples,fix_successful_postswitch_trials_visible_RB_idx, ...
	Xedges, Yedges, 'Successful postswitch from red to blue unblocked  fix trials', 'successful_post_switch_unblocked_RB_fix', output_dir, fileID);

[successful_postswitch_trials_visible_BR_vergence] = fn_plot_vergence_by_index(registered_right_eye_gaze_samples, registered_left_eye_gaze_samples,fix_successful_postswitch_trials_visible_BR_idx, ...
	Xedges, Yedges, 'Successful postswitch from blue to red unblocked  fix trials', 'successful_post_switch_unblocked_BR_fix', output_dir, fileID);
 	
 	
	if (close_figures_on_return)
		close all;
	end
	
	
	
	timestamps.(mfilename).end = toc(timestamps.(mfilename).start);
	disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end), ' seconds.']);
	disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / 60), ' minutes. Done...']);
	return
end