function [] = SCP_ephys_base_analysis_YC2301(session_ID, export_PETH_only)
%ELMO_FB128TDT_TEST Summary of this function goes here
%   Detailed explanation goes here
% TODO:
%   also plot for:
%       B's choices
%       A & B's high value target position
%       add reward train events
%       split trials by reaction time difference in to 2-3 classes:
%           A faster, A == B, B faster, with a configurable range for ==
%       exclude cluster IDs with too few spikes
%
% DONE:
%   allow to scale all plots to the same hight.
%       allow variance display in PETHs
%       save out high resolution dot rasters as well as the average by
%           category mean and CI


timestamps.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);
debug = 1;

SFB_2021 = 1;


% make sure we are in the path
% AddToMatlabPath( pwd, [], [] );
% make sure TDT's matlab functions are available to read the epocs from the TDT header
start_TDTMatlabSDK();
start_fieldtrip();



if ~exist('session_ID', 'var') || isempty(session_ID)
	% session with shuffled and blocked  partner,and SoloA
	session_ID = fullfile('F:', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2021', '210219', '20210219T145809.A_Elmo.B_DL.SCP_01.sessiondir');
end


% if not empty, just load this data file
debug_spikedata_file = 'dataspikes_ch103_negthr.mat';
debug_spikedata_file = [];
InvisibleFigures = 1;
% how to detect valid spike channels, either posthr/negthr (*thr) OR
% _redetectlong
spikefile_wildcard_string = 'dataspikes_ch*thr.mat';
%spikefile_wildcard_string = 'dataspikes_ch*_redetectlong.mat';



% CURRENTLY convert_TDT_ts_2_EvIDE_ts = 0; is not working.
% either convert TDT time to EventIDE time or vice versa, tested, seems to work
convert_TDT_ts_2_EvIDE_ts = 1; % this is the better approach, as EventIDE timestamps are unique and year 2000 based
load_TDT_analog_in_data = 1; % try to loasd the analog IN data recoded on the TDT system, for reward pulses...
% which event data to use for timebase conversion between TDT and EventIDE
REF_EPOC = 'DigitalInMessage'; % 'St21', 'Tnum', or 'DigitalInMessage', DigitalInMessage is the most precise, way to use the hihj res timestamps from the trial numbers sent from EventIDE to TDT
synthesize_missing_agents_target_touches = 1;
create_touch_by_sequence_columns = 1;	% create alignment events for the some timing columns that are not split by actor but by sequence

%LFP parameters:
process_LFPs = 0;
LFP_ID_substring = 'LFPw_Ch'; % '_LFPw_Ch', or '_RSn1_ch'
LFP_ID_substring = 'RSn1_ch'; % '_LFPw_Ch', or '_RSn1_ch'
LFP_ext_string  = 'sev';
LFP_resample_frequency_Hz = 1000;
LFP_load_field_trip_data = 1;	% if 1 try to load fieldtrip header and data instead of creating them from scratch, saving a bit of time
LFP_load_lfp_tfa_data = 1;
LFP_export_LFP_4_NDT_ = 0; % whether or not to also save the LFP data formated in NDT raster format NOTE: just doing evoked potential is not going to be helpful here
export_LFP_only = 0;



% PETH parameters
bin_width_ms = 50; % used as histogram bin size, boxcar width and gaussian double sigma (@* sigma covers ~63%), ignored for custom
pre_event_dur_ms = 1000;
post_event_dur_ms = 1000;
convolution_kernel_type = 'gaussian'; % gaussian, boxcar, histogram, or a custom kernel as array
PETH_plot_VAR_by_cat_measure = 'none';    % 'none' or '', 'ci_halfwidth', 'sem', 'stddev'
PETH_ci_alpha = 0.05;
raster_type = 'none'; % img, points, or none
plot_opt_struct.plot_legend = 1;
plot_dyadic_solo_choice_combination = 1;
plot_TrialSubType = 1;
plot_conf_predictability = 1;
plot_dyadic_solo_choice_combination_ByVisibility = 0;
skip_plots = 1;

%YC23:
export_PETH_only = 1;


% if (SFB_2021)
% 	plot_dyadic_solo_choice_combination = 0;
% 	plot_TrialSubType = 1;
% 	plot_conf_predictability = 0;
% 	plot_dyadic_solo_choice_combination_ByVisibility = 0;
% end

% for later analysis it will be helpful to save event aligned 1ms PETHs as
% per trial array.
save_event_aligned_per_trial_1ms_histogram = 1;
if ~exist('export_PETH_only', 'var') || isempty(export_PETH_only)
	export_PETH_only = 0;   % skip plotting and just export the data
end
if export_PETH_only == 2
	export_LFP_only = 1;
end
save_generic_PETH = 0;
export_PETH_as_raster_4_NDT = 1;
NDT_min_trials_per_label_item = []; % 20

% settings for tuning calculations
tuning_struct.analyse_tuning = 1;
tuning_struct.TrialSubType_list = {'SoloA'};
tuning_struct.label_list = {'A_LR_pos_list'}; % {'A_LR_pos_list', 'B_LR_pos_list'};
tuning_struct.alignment_list = {'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms'}; % {'A_InitialFixationReleaseTime_ms'}; %
% define the ranges
tuning_struct.baseline_range = [-999 -500] + pre_event_dur_ms;% what to compare against for the pre and post ranges
tuning_struct.pre_range = [-499 0] + pre_event_dur_ms;	% these are in ms
tuning_struct.post_range = [1 500] + pre_event_dur_ms;	% these are in ms
tuning_struct.method = 'compare_pre_post_over_labels';
% tuning TODO
% split out by trial type!
% use more elaborate ANOVA to model multiple factors in parallel
% add visual response, own action, others action, seqience...
% allow cross allignment comparisons
% maybe extract the data directly from alignment)event, and range[]



if max([tuning_struct.pre_range, tuning_struct.post_range]) > (pre_event_dur_ms + post_event_dur_ms)
	error('Range exceeds PETH range');
end
if min([tuning_struct.pre_range, tuning_struct.post_range]) < 1
	error('Range exceeds PETH range');
end
% TODO remove after testing
% export_PETH_as_raster_4_NDT = 0;
process_LFPs = 0;


NDT_raster_label_list = {'A_pos_list', 'A_LR_pos_list', 'social_context_list', 'TrialSubType_list', ...
	'RewardA_x_TrialSubType_code', 'A_NumberRewardPulsesDelivered_HIT', 'ABdiffGoSignalTimes_value_list', 'dyadic_solo_choice_combination_list', ...
	'conf_predictability_dyadic_choice_combination_list', 'conf_predictability_list', 'dyadic_ABdiffGoSignalTimes_list', 'solo_ABdiffGoSignalTimes_list', ...
	'dyadic_choice_combination_list', 'solo_choice_combination_list', 'dyadic_choice_combination_ByDiffGo_list', 'solo_choice_combination_ByDiffGo_list', ...
	};
% fn_NDT_decode learned to ignore label categories with too few instances,
% no need to export different sets
NDT_raster_label_list = {};
% export these numeric parameters as cell of names, naming bad trials as ExcludedTrials
NDT_raster_label_list = {'A_NumberRewardPulsesDelivered_HIT', 'B_NumberRewardPulsesDelivered_HIT', ...
	'ABdiffGoSignalTimes_value_list'};

% for NDT
NDT.alignment_event_list = {...
	'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms', ...
	'A_TargetTouchTime_ms', 'B_TargetTouchTime_ms', ...
	'A_GoSignalTime_ms', 'B_GoSignalTime_ms', ...
	'A_InitialFixationOnsetTime_ms', ...
	'A_TargetOnsetTime_ms', ...
	'A_RewardTrainOnsetTime_TDT_ms', 'B_RewardTrainOnsetTime_TDT_ms', ...
	'FIRST_InitialFixationReleaseTime_ms', 'SECOND_InitialFixationReleaseTime_ms', ...
	'FIRST_GoSignalTime_ms', 'SECOND_GoSignalTime_ms', ...
	'FIRST_TargetTouchTime_ms', 'SECOND_TargetTouchTime_ms', ...
	};

NDT.alignment_event_list = {...
	'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms', ...
	'A_InitialFixationOnsetTime_ms', ...
	'A_TargetOnsetTime_ms', ...
	'A_RewardTrainOnsetTime_TDT_ms', 'B_RewardTrainOnsetTime_TDT_ms', ...
	'FIRST_InitialFixationReleaseTime_ms', 'SECOND_InitialFixationReleaseTime_ms', ...
	};

NDT.labels_list = {'conf_predictability_list', 'conf_predictability_dyadic_choice_combination_list', 'social_context_list', 'TrialSubType_list', ...
	'A_pos_list', 'A_LR_pos_list', ...
	'A_NumberRewardPulsesDelivered_HIT', 'dyadic_A_NumberRewardPulsesDelivered_HIT', ...
	'dyadic_solo_choice_combination_ByDiffGo_list', 'conf_predictability_dyadic_choice_combination_ByDiffGo_list', ...
	'dyadic_ABdiffGoSignalTimes_list', 'solo_ABdiffGoSignalTimes_list', 'dyadic_choice_combination_list', ...
	'dyadic_choice_combination_ByDiffGo_list', ...
	'dyadic_sameness_ByDiffGo_list', ...
	'B_pos_list', 'B_LR_pos_list', ...
	'SoloVsSemiSolo_list', 'DyadicVsSemiSolo_list', ...
	'blocked_B_pos_list', 'blocked_B_LR_pos_list', ...
	'shuffled_B_pos_list', 'shuffled_B_LR_pos_list', ...
	'AgoB_blocked_B_pos_list', 'AgoB_blocked_B_LR_pos_list', ...
	'AgoB_shuffled_B_pos_list', 'AgoB_shuffled_B_LR_pos_list', ...
	'BgoA_blocked_B_pos_list', 'BgoA_blocked_B_LR_pos_list', ...
	'BgoA_shuffled_B_pos_list', 'BgoA_shuffled_B_LR_pos_list', ...
	};

NDT.labels_list = {'TrialSubType_list', ...
	'A_pos_list', 'A_LR_pos_list', ...
	'A_NumberRewardPulsesDelivered_HIT', 'dyadic_A_NumberRewardPulsesDelivered_HIT', ...
	'B_pos_list', 'B_LR_pos_list', ...
	'SoloVsSemiSolo_list', 'DyadicVsSemiSolo_list', ...
	...%'blocked_B_pos_list', 'blocked_B_LR_pos_list', ...
	...%'shuffled_B_pos_list', 'shuffled_B_LR_pos_list', ...
	'AgoB_blocked_B_pos_list', 'AgoB_blocked_B_LR_pos_list', ...
	'AgoB_shuffled_B_pos_list', 'AgoB_shuffled_B_LR_pos_list', ...
	...%'BgoA_blocked_B_pos_list', 'BgoA_blocked_B_LR_pos_list', ...
	...%'BgoA_shuffled_B_pos_list', 'BgoA_shuffled_B_LR_pos_list', ...
	};
NDT.export_labels_as_idx_and_header = 1;
NDT.bin_width = 200;
NDT.step_size = 100;
NDT.start_decode = 0;


min_spikes_per_trial = 10; % if on average we have fewer spikes than this, do not create a plot

% split trials by sequence of GO Signals for A and B
% 20210923: make the source of the "diffGoSignal" signal configurable
GoSignalQuantum_ms = 100;
GoSignal_saturation_ms = 400;
split_diffGoSignal_eq_0_by_RT = 1;
diffGoSignal_eq_0_by_RT_RT_type = 'InitialTargetReleaseRT'; % which difference time vector to use to resolve "draws" (equal Go Times for A and B), IniTargRel_05MT_RT, TargetAcquisitionRT, InitialTargetReleaseRT
% TODO generalize the next towo to allo arbitrary quantised differens data
plot_separately_per_diffGo_category = 0;    % generate one plot per diffGo category, otherwise fold diffGo into the per plot categories
plot_diffGo_categories_as_lines = 1;        % for each original category use linestyles to show the 4 differebt diffGo classes.


% generic split by timing differences
% quantization is required to keep enough trials per category
timing_split.quantum_ms = 500;	% we do round(diff_timing / timing_split.quantum_ms) * timing_split.quantum_ms) unless set to [] or 0, to get meaningfull classes
timing_split.saturation_max_ms = 1000; % if not empty, clamp all timing values > saturation_max_ms to saturation_max_ms
timing_split.saturation_min_ms = -1 * timing_split.saturation_max_ms; % same as above but for values smaller than saturation_min_ms
timing_split.quant_method = [];% for the Go signal use round


loop_over_choices_of_A = 1; % create a composite panel for all target positions, by choice of agent A
% TODO reduce to left versus right?
A_position_set_name = 'LR'; % all or LR


merge_all_cluster_ids = 0;  % if set to 1 all clusterIDs will be temporarily replaced by clusterID 0
% use a manually created Excel table to reassign cluster IDs to merge or
% reject clustered units
merge_and_reject_cluster_ids = 1;   % use a merge and reject list to reassign wave_clus clusterIDs to real clusters.
%merge_and_reject_file_stem = 'unit_merge_and_reject_sheet.v01.20210218.';
merge_and_reject_file_stem = 'unit_merge_and_reject_sheet.v01.20210309.160ch.neg.pos.';
merge_and_reject_file_ext = '.xlsx';
cluster_exclude_list = [-9, -8, -7, -6, -5, -4, -3 -2, -1, 0, 9];  % list of cluster IDs not to process, neagtive numbers denote artifacts...


if (merge_all_cluster_ids)
	% make sure to allow clusterid 0 if merge_all_cluster_ids is set...
	disp('merge_all_cluster_ids requested, so remove cluster ID 0 from cluster_exclude_list.');
	cluster_exclude_list = setdiff(cluster_exclude_list, 0);
end

% for composite images, scale all raster and peth plots to the maximum in
% the set?
scale_raster = 1;
scale_peth = 1;

% no GUI means no figure windows possible, so try to work around that
if (fnIsMatlabRunningInTextMode())
	InvisibleFigures = 1;
end
if (InvisibleFigures)
	figure_visibility_string = 'off';
	disp('Using visible figures, for speed.');
else
	figure_visibility_string = 'on';
	disp('Using visible figures, for debugging/formatting.');
end
plot_opt_struct.figure_visibility_string = figure_visibility_string;
plot_opt_struct.Interpreter_string = 'None';

plot_opt_struct.XTick = [-500, 0, 500]; % ignore if empty, otherwise use this
plot_opt_struct.YTick = [];
plot_opt_struct.LineWidth = 2;
plot_opt_struct.Title.FontSize = 16;
plot_opt_struct.Title.FontWeight = 'normal';
plot_opt_struct.PETH_min_trials_per_cat = 3;


set(groot, 'defaultAxesLineWidth', 1.0, 'defaultAxesFontName', 'Arial', 'defaultAxesFontSize', 16, 'defaultAxesFontWeight', 'normal');
%set(groot, 'AxesLineWidth', 'factory', 'AxesFontName', 'factory', 'AxesFontSize', 'factory', 'AxesFontWeight', 'factory');



% HERE WE LOAD THE BEHAVIORAL (EventIDE) AND PHYSIOLOGY (TDT) DATA

% load the behavioral data (EventIDE)
[ out_struct, session_id, session_id_list, session_struct_list, in_session_id, session_dir ] = fnLoadDataBySessionDir( session_ID , 'local', [] );
%[ out_struct, session_id, session_id_list, session_struct_list ] = fnLoadDataBySessionDir( session_ID , [], [] );
report_struct = out_struct.triallog;
[sess_dir, ~, ~] = fileparts(report_struct.src_fqn);

% get the TDT data directory and name, TDT calles these Tanks...
[TDT_tank_ID, TDT_tank_FQN, TDT_sess_base_dir] = fn_get_TDT_tank_ID_and_FQN(sess_dir, session_ID, 'TDT');

% load the TDT information (headers, epocs, and non-broadband streams)
narrowband_streams_mat_suffix = '.TDT_RZ2_streams.mat';
[TDT_header, TDT_epocs, TDT_streams] = fn_load_TDT_header_epocs_narrowband_streams(TDT_tank_FQN, TDT_tank_ID, narrowband_streams_mat_suffix, load_TDT_analog_in_data);

% get all state transitions as TDT epocs, this is required for
% fn_match_EventIDE_and_TDT_reference_events with REF_EPOCH = DigitalInMessage
epocized_TDT_stat = fn_compress_TDT_stream_to_epoc_by_change_detection(TDT_streams.streams.stat);
TDT_epocs.epocs.DigitalInMessage = epocized_TDT_stat;

% to convert between different time bases we need events that we kno
% whappened at the same wall-clock time so we can automatically calculate
% conversion factors between the two time bases
[ParaState_EvIDE_idx, ParaState_EvIDE_timestamps, ParaState_TDT_timestamps, ParaState_TDT_idx] = fn_match_EventIDE_and_TDT_reference_events(REF_EPOC, report_struct, TDT_epocs);

% calculate time conversions, avoid the first and last event...
[first2second_time_conversion_struct, second2first_time_conversion_struct, time_conversion_struct] = fn_translate_TDT_and_EventIDE_timebases(REF_EPOC, 'TDT', ParaState_TDT_timestamps(2:end-1), 'EvIDE', ParaState_EvIDE_timestamps(2:end-1), TDT_sess_base_dir);


if (load_TDT_analog_in_data)
	% extract the reward pulse timings and convert to EvIDE time
	reward_pulse_EvIDE_ts_A = fn_extract_reward_pulse_timestamps(TDT_streams.streams.RewA, 3.5, time_conversion_struct);
	reward_pulse_EvIDE_ts_B = fn_extract_reward_pulse_timestamps(TDT_streams.streams.RewB, 3.5, time_conversion_struct);
	% now extract reward pulse trains and use report_struct data to
	% select manual and task reward events
	A_RewardTrainOnsetTime_TDT_ms = fn_construct_reward_pulse_train_onset_ts_list(reward_pulse_EvIDE_ts_A.onset_sample_timestamp_list, 'A', report_struct);
	B_RewardTrainOnsetTime_TDT_ms = fn_construct_reward_pulse_train_onset_ts_list(reward_pulse_EvIDE_ts_B.onset_sample_timestamp_list, 'B', report_struct);
	% transiently add to the report_struct
	report_struct = fn_handle_data_struct('add_columns', report_struct, [A_RewardTrainOnsetTime_TDT_ms.TASK_HIT_reward_train_onset_timestamp_list, B_RewardTrainOnsetTime_TDT_ms.TASK_HIT_reward_train_onset_timestamp_list], {'A_RewardTrainOnsetTime_TDT_ms', 'B_RewardTrainOnsetTime_TDT_ms'});
end


% generate a list of columns that contain touch event timestamps (from report_struct.cn)
% what about reward start times, what about brightening events if IFT and
% CTs?
% TODO: add IH release A/B, IFT AcqA/B, CT AcqA/B, RewardA, RewardB
%   Add IFT Onset A/B, IFT Offset A/B, IFT brightening A/B, CT brightening A/B, CT OFFset
touch_event_ts_col_names_list = {...
	'A_HoldReleaseTime_ms', 'B_HoldReleaseTime_ms',...
	'A_InitialFixationTouchTime_ms', 'B_InitialFixationTouchTime_ms', ...
	'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms', ...
	'A_TargetTouchTime_ms', 'B_TargetTouchTime_ms'};
visual_event_ts_col_names_list = {...
	'A_InitialFixationOnsetTime_ms', 'B_InitialFixationOnsetTime_ms', ...
	'A_TargetOnsetTime_ms', 'B_TargetOnsetTime_ms', ...
	'A_GoSignalTime_ms', 'B_GoSignalTime_ms', ...
	'A_TargetOffsetTime_ms', 'B_TargetOffsetTime_ms'};

additional_task_event_ts_names_list = { ...
	'A_RewardTrainOnsetTime_TDT_ms', 'B_RewardTrainOnsetTime_TDT_ms' ...
	'FIRST_InitialFixationReleaseTime_ms', 'SECOND_InitialFixationReleaseTime_ms',...
	'FIRST_TargetTouchTime_ms', 'SECOND_TargetTouchTime_ms',...
	'FIRST_GoSignalTime_ms', 'SECOND_GoSignalTime_ms',...
	};


event_ts_col_names_list = [touch_event_ts_col_names_list, visual_event_ts_col_names_list, additional_task_event_ts_names_list];

% define the set we are intersted in
% all
selected_event_set = {...
	'A_HoldReleaseTime_ms', 'B_HoldReleaseTime_ms',...
	'A_InitialFixationTouchTime_ms', 'B_InitialFixationTouchTime_ms', ...
	'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms', ...
	'A_TargetTouchTime_ms', 'B_TargetTouchTime_ms', ...
	'A_InitialFixationOnsetTime_ms', 'B_InitialFixationOnsetTime_ms', ...
	'A_TargetOnsetTime_ms', 'B_TargetOnsetTime_ms', ...
	'A_GoSignalTime_ms', 'B_GoSignalTime_ms', ...
	'A_TargetOffsetTime_ms', 'B_TargetOffsetTime_ms', ...
	'A_RewardTrainOnsetTime_TDT_ms', 'B_RewardTrainOnsetTime_TDT_ms' ...
	};
% unique events (e.g. A_TargetOffsetTime_ms' == 'B_TargetOffsetTime_ms)
selected_event_set = {...
	'A_HoldReleaseTime_ms', 'B_HoldReleaseTime_ms',...
	'A_InitialFixationTouchTime_ms', 'B_InitialFixationTouchTime_ms', ...
	'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms', ...
	'A_TargetTouchTime_ms', 'B_TargetTouchTime_ms', ...
	'A_InitialFixationOnsetTime_ms', ...
	'A_TargetOnsetTime_ms', ...
	'A_GoSignalTime_ms', 'B_GoSignalTime_ms', ...
	'A_TargetOffsetTime_ms', ...
	'A_RewardTrainOnsetTime_TDT_ms', 'B_RewardTrainOnsetTime_TDT_ms' ...
	};

% currently selected set
selected_event_set = {...
	'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms', ...
	'A_GoSignalTime_ms', 'B_GoSignalTime_ms', ...
	'A_InitialFixationOnsetTime_ms', ...
	'A_TargetTouchTime_ms', 'B_TargetTouchTime_ms', ...
	'A_TargetOnsetTime_ms', ...
	'A_RewardTrainOnsetTime_TDT_ms', 'B_RewardTrainOnsetTime_TDT_ms' ...
	};


% the set of events that need to be analysed depending on the sequence of
% the Go signals
diffGoTimes_sensitive_event_set = {...
	'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms', ...
	'A_TargetTouchTime_ms', 'B_TargetTouchTime_ms', ...
	'A_GoSignalTime_ms', 'B_GoSignalTime_ms', ...
	};



% now get a subset of relevant trials:
TrialSets = fnCollectTrialSets(report_struct);
% add SoloBRewardAB to SideA, as A is still rewarded...
TrialSets.ByTrialSubType.SideA.SoloBRewardAB = TrialSets.ByTrialSubType.SideB.SoloBRewardAB;
% add SoloARewardAB to SideB, as B is still rewarded...
TrialSets.ByTrialSubType.SideB.SoloARewardAB = TrialSets.ByTrialSubType.SideA.SoloARewardAB;


% for solo trials synthesize the missing *_InitialFixationReleaseTime_ms
% for the other side, just to have roughly similar plots
if (synthesize_missing_agents_target_touches)
	% we need dyadic/joint trials
	if ~isempty(TrialSets.ByJointness.DualSubjectJointTrials) && ~isempty(TrialSets.ByJointness.DualSubjectSoloTrials)
		GoodTrialsIdx = intersect(TrialSets.ByOutcome.REWARD, TrialSets.ByChoices.NumChoices02);
		JointGoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByJointness.SideA.DualSubjectJointTrials);
		% SideA
		if ~isempty(TrialSets.ByJointness.SideA.SoloSubjectTrials)
			% get the B's IFT release times for rewards joint trials
			B_IFT_releaseRT = report_struct.data(:, report_struct.cn.B_InitialFixationReleaseTime_ms) - report_struct.data(:, report_struct.cn.B_GoSignalTime_ms);
			mean_B_IFT_releaseRT_ms = mean(B_IFT_releaseRT(JointGoodTrialsIdx));
			
			B_CT_acquisitionRT = report_struct.data(:, report_struct.cn.B_TargetTouchTime_ms) - report_struct.data(:, report_struct.cn.B_GoSignalTime_ms);
			mean_B_CT_acquisitionRT_ms = mean(B_CT_acquisitionRT(JointGoodTrialsIdx));
			
			SoloAGoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByJointness.SideA.SoloSubjectTrials);
			report_struct.data(SoloAGoodTrialsIdx, report_struct.cn.B_InitialFixationReleaseTime_ms) = report_struct.data(SoloAGoodTrialsIdx, report_struct.cn.B_GoSignalTime_ms) + mean_B_IFT_releaseRT_ms;
			report_struct.data(SoloAGoodTrialsIdx, report_struct.cn.B_TargetTouchTime_ms) = report_struct.data(SoloAGoodTrialsIdx, report_struct.cn.B_GoSignalTime_ms) + mean_B_CT_acquisitionRT_ms;
			disp(['Synthesizing B''s IFT release times for SoloA trials, from existing Dyadic  IFT release times; mean_B_IFT_releaseRT_ms: ', num2str(mean_B_IFT_releaseRT_ms)]);
		end
		% SideB
		if ~isempty(TrialSets.ByJointness.SideB.SoloSubjectTrials)
			% get the B's IFT release times for rewards joint trials
			A_IFT_releaseRT = report_struct.data(:, report_struct.cn.A_InitialFixationReleaseTime_ms) - report_struct.data(:, report_struct.cn.A_GoSignalTime_ms);
			mean_A_IFT_releaseRT_ms = mean(A_IFT_releaseRT(JointGoodTrialsIdx));
			
			A_CT_acquisitionRT = report_struct.data(:, report_struct.cn.A_TargetTouchTime_ms) - report_struct.data(:, report_struct.cn.A_GoSignalTime_ms);
			mean_A_CT_acquisitionRT_ms = mean(A_CT_acquisitionRT(JointGoodTrialsIdx));
			
			SoloBGoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByJointness.SideB.SoloSubjectTrials);
			report_struct.data(SoloBGoodTrialsIdx, report_struct.cn.A_InitialFixationReleaseTime_ms) = report_struct.data(SoloBGoodTrialsIdx, report_struct.cn.A_GoSignalTime_ms) + mean_A_IFT_releaseRT_ms;
			report_struct.data(SoloBGoodTrialsIdx, report_struct.cn.A_TargetTouchTime_ms) = report_struct.data(SoloBGoodTrialsIdx, report_struct.cn.A_GoSignalTime_ms) + mean_A_CT_acquisitionRT_ms;
			disp(['Synthesizing A''s IFT release times for SoloA trials, from existing Dyadic  IFT release times; mean_A_IFT_releaseRT_ms: ', num2str(mean_A_IFT_releaseRT_ms)]);
		end
	end
end

if (create_touch_by_sequence_columns)
	per_side_event_suffix_list = {'_HoldReleaseTime_ms', '_InitialFixationTouchTime_ms', '_InitialFixationReleaseTime_ms', '_TargetTouchTime_ms', '_GoSignalTime_ms', '_RewardTrainOnsetTime_TDT_ms'};
	per_side_event_suffix_list = {'_InitialFixationReleaseTime_ms', '_TargetTouchTime_ms', '_GoSignalTime_ms'};
	for i_per_side_event_suffix = 1 : length(per_side_event_suffix_list)
		cur_per_side_event_suffix = per_side_event_suffix_list{i_per_side_event_suffix};
		first_event_time_ms = zeros([size(report_struct.data, 1), 1]);
		second_event_time_ms = zeros([size(report_struct.data, 1), 1]);
		A_time_ms = report_struct.data(:, report_struct.cn.(['A', cur_per_side_event_suffix]));
		B_time_ms = report_struct.data(:, report_struct.cn.(['B', cur_per_side_event_suffix]));
		valid_A_time_idx = fn_check_event_ts_with_trial_start_and_end_ts(A_time_ms, report_struct);
		valid_B_time_idx = fn_check_event_ts_with_trial_start_and_end_ts(B_time_ms, report_struct);
		
		only_A_valid_idx = setdiff(valid_A_time_idx, valid_B_time_idx);
		if ~isempty(only_A_valid_idx)
			first_event_time_ms(only_A_valid_idx) = A_time_ms(only_A_valid_idx);
		end
		only_B_valid_idx = setdiff(valid_B_time_idx, valid_A_time_idx);
		if ~isempty(only_B_valid_idx)
			first_event_time_ms(only_B_valid_idx) = A_time_ms(only_B_valid_idx);
		end
		both_A_and_B_valid_idx = intersect(valid_A_time_idx, valid_B_time_idx);
		if ~isempty(both_A_and_B_valid_idx)
			AB_time_ms = [A_time_ms, B_time_ms];
			first_event_time_ms(both_A_and_B_valid_idx) = min(AB_time_ms(both_A_and_B_valid_idx, :), [], 2);
			second_event_time_ms(both_A_and_B_valid_idx) = max(AB_time_ms(both_A_and_B_valid_idx, :), [], 2);
		end
		selected_event_set{end+1} = ['FIRST', cur_per_side_event_suffix];
		selected_event_set{end+1} = ['SECOND', cur_per_side_event_suffix];
		
		disp(['Temporarily adding FIRST/SECOND', cur_per_side_event_suffix, ' columns to the report struct']);
		report_struct = fn_handle_data_struct('add_columns', report_struct, [first_event_time_ms, second_event_time_ms], {['FIRST', cur_per_side_event_suffix], ['SECOND', cur_per_side_event_suffix]});
	end
end

selected_event_idx = ismember(event_ts_col_names_list, selected_event_set);
selected_events_EvIDE_ts_struct = fn_create_event_ts_struct_from_colnames(event_ts_col_names_list(selected_event_idx), report_struct);
selected_events_TDT_ts_struct = fn_convert_event_ts_struct_timebase(selected_events_EvIDE_ts_struct, time_conversion_struct, 'EvIDE', 'TDT');
% for data export
all_events_EvIDE_ts_struct = fn_create_event_ts_struct_from_colnames(event_ts_col_names_list(:), report_struct);
all_events_TDT_ts_struct = fn_convert_event_ts_struct_timebase(all_events_EvIDE_ts_struct, time_conversion_struct, 'EvIDE', 'TDT');



% selected_events_EvIDE_ts_struct.A_RewardTrainOnsetTime_TDT_ms = A_RewardTrainOnsetTime_TDT_ms.TASK_HIT_reward_train_onset_timestamp_list;
% selected_events_EvIDE_ts_struct.B_RewardTrainOnsetTime_TDT_ms = B_RewardTrainOnsetTime_TDT_ms.TASK_HIT_reward_train_onset_timestamp_list;
% selected_event_set{end + 1} = 'A_RewardTrainOnsetTime_TDT_ms';
% selected_event_set{end + 1} = 'B_RewardTrainOnsetTime_TDT_ms';


process_IC = 1;
if (process_IC)
	GroupTrialIdxList = {};
	GroupNameList = {};
	
	% only look at successfull choice trials
	GoodTrialsIdx = intersect(TrialSets.ByOutcome.REWARD, TrialSets.ByChoices.NumChoices02);    % exclude trials with only one target (instructed reach, informed reach)
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByTrialType.InformedTrials);             % exclude free choice
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByJointness.DualSubjectJointTrials);     % exclude non-joint trials
	GroupTrialIdxList{end+1} = GoodTrialsIdx;
	GroupNameList{end+1} = 'IC_JointTrials';
	
	% Solo trials are trials with another actor present, but not playing
	GoodTrialsIdx = intersect(TrialSets.ByOutcome.REWARD, TrialSets.ByChoices.NumChoices02);    % exclude trials with only one target (instructed reach, informed reach)
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByTrialType.InformedTrials);             % exclude free choice
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByJointness.SideA.SoloSubjectTrials);     % exclude non-joint trials
	GroupTrialIdxList{end+1} = GoodTrialsIdx;
	GroupNameList{end+1} = 'IC_SoloTrialsSideA';
	
	GoodTrialsIdx = intersect(TrialSets.ByOutcome.REWARD, TrialSets.ByChoices.NumChoices02);    % exclude trials with only one target (instructed reach, informed reach)
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByTrialType.InformedTrials);             % exclude free choice
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByJointness.SideB.SoloSubjectTrials);     % exclude non-joint trials
	GroupTrialIdxList{end+1} = GoodTrialsIdx;
	GroupNameList{end+1} = 'IC_SoloTrialsSideB';
	
	% SingleSubject trials are fom single subject sessions
	GoodTrialsIdx = intersect(TrialSets.ByOutcome.REWARD, TrialSets.ByChoices.NumChoices02);    % exclude trials with only one target (instructed reach, informed reach)
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByTrialType.InformedTrials);             % exclude free choice
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByActivity.SideA.SingleSubjectTrials);     % exclude non-joint trials
	GroupTrialIdxList{end+1} = GoodTrialsIdx;
	GroupNameList{end+1} = 'IC_SingleSubjectTrialsSideA';
	
	GoodTrialsIdx = intersect(TrialSets.ByOutcome.REWARD, TrialSets.ByChoices.NumChoices02);    % exclude trials with only one target (instructed reach, informed reach)
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByTrialType.InformedTrials);             % exclude free choice
	GoodTrialsIdx = intersect(GoodTrialsIdx, TrialSets.ByActivity.SideB.SingleSubjectTrials);     % exclude non-joint trials
	GroupTrialIdxList{end+1} = GoodTrialsIdx;
	GroupNameList{end+1} = 'IC_SingleSubjectTrialsSideB';
end

IC_SingleSubjectTrialsSideA_idx = find(ismember(GroupNameList, 'IC_SingleSubjectTrialsSideA'));
GoodTrialsIdx = GroupTrialIdxList{IC_SingleSubjectTrialsSideA_idx};
GroupName = GroupNameList{IC_SingleSubjectTrialsSideA_idx};


IC_JointTrials_idx = find(ismember(GroupNameList, 'IC_JointTrials'));
GoodTrialsIdx = GroupTrialIdxList{IC_JointTrials_idx};
GroupName = GroupNameList{IC_JointTrials_idx};

% merge data for Solo and dyadic trials
GoodTrialsIdx = union(GroupTrialIdxList{find(ismember(GroupNameList, 'IC_SoloTrialsSideA'))}, ...
	GroupTrialIdxList{find(ismember(GroupNameList, 'IC_JointTrials'))});

GoodTrialsIdx = union(GoodTrialsIdx, ...
	GroupTrialIdxList{find(ismember(GroupNameList, 'IC_SingleSubjectTrialsSideA'))});

GoodTrialsIdx = union(GoodTrialsIdx, ...
	GroupTrialIdxList{find(ismember(GroupNameList, 'IC_SoloTrialsSideB'))});

GoodTrialsIdx = union(GoodTrialsIdx, ...
	GroupTrialIdxList{find(ismember(GroupNameList, 'IC_SingleSubjectTrialsSideB'))});


% in the current task (BvS) the relative onset t=ime of actions is
% important, so categoriese each trial based on the difference in go times
% (and for equal go times look at the actual reaction times)

% collect the GO signal times relative to the TargetOnsetTime_ms
AB_diffGoSignalTime = report_struct.data(:, report_struct.cn.A_GoSignalTime_ms) - report_struct.data(:, report_struct.cn.B_GoSignalTime_ms);
%TODO choices of A for each of B's (ans vice versa)
cur_AB_diffGoSignalTime = fn_saturate_by_min_max(AB_diffGoSignalTime(GoodTrialsIdx), -GoSignal_saturation_ms, GoSignal_saturation_ms);
unique_cur_AB_diffGoSignalTime = unique(cur_AB_diffGoSignalTime);
% only look at the selected good trials
quantized_cur_AB_diffGoSignalTime = fn_saturate_by_min_max(fn_quantize(cur_AB_diffGoSignalTime, GoSignalQuantum_ms), -GoSignal_saturation_ms, GoSignal_saturation_ms);
% but also calculate stuff for all trials
quantized_AB_diffGoSignalTime = fn_saturate_by_min_max(fn_quantize(AB_diffGoSignalTime, GoSignalQuantum_ms), -GoSignal_saturation_ms, GoSignal_saturation_ms);
unique_quantized_cur_ABdiffGoSignalTimes = unique(quantized_cur_AB_diffGoSignalTime);


AB_GoSignalTime_diff = report_struct.data(:, report_struct.cn.A_GoSignalTime_ms) - report_struct.data(:, report_struct.cn.B_GoSignalTime_ms);
AB_GoSignalTime_diff_struct = fn_create_quantized_saturated_value_and_label_lists( AB_GoSignalTime_diff, timing_split.quantum_ms, 'round', timing_split.saturation_min_ms, timing_split.saturation_max_ms, 'ABgo', GoodTrialsIdx );

timing_split.quant_method = [];
% InitialTargetRelease
A_InitialTargetReleaseRT = report_struct.data(:, report_struct.cn.A_InitialFixationReleaseTime_ms); %  - report_struct.data(:, report_struct.cn.A_GoSignalTime_ms)
B_InitialTargetReleaseRT = report_struct.data(:, report_struct.cn.B_InitialFixationReleaseTime_ms); %  - report_struct.data(:, report_struct.cn.B_GoSignalTime_ms)
AB_InitialTargetReleaseRT_diff = A_InitialTargetReleaseRT - B_InitialTargetReleaseRT;
% special case Solo trials, in which only one side has a real reaction time,
% if both are zero the trial is invalid and will be excluded anyway
AB_InitialTargetReleaseRT_diff(A_InitialTargetReleaseRT == 0) = report_struct.data(A_InitialTargetReleaseRT == 0, report_struct.cn.A_GoSignalTime_ms) - B_InitialTargetReleaseRT(A_InitialTargetReleaseRT == 0);
AB_InitialTargetReleaseRT_diff(B_InitialTargetReleaseRT == 0) = A_InitialTargetReleaseRT(B_InitialTargetReleaseRT == 0) - report_struct.data(B_InitialTargetReleaseRT == 0, report_struct.cn.B_GoSignalTime_ms);
AB_InitialTargetReleaseRT_diff_struct = fn_create_quantized_saturated_value_and_label_lists( AB_InitialTargetReleaseRT_diff, timing_split.quantum_ms, timing_split.quant_method, timing_split.saturation_min_ms, timing_split.saturation_max_ms, 'ABirt', GoodTrialsIdx );


% trials in which an agent's actions are at leat 500ms away from the
% other's go signal
AB_equal_go_idx = find(AB_GoSignalTime_diff == 0);
A_InitialTargetReleaseRT_minus_B_GO_diff = A_InitialTargetReleaseRT - report_struct.data(:, report_struct.cn.B_GoSignalTime_ms);
B_InitialTargetReleaseRT_minus_A_GO_diff = B_InitialTargetReleaseRT - report_struct.data(:, report_struct.cn.A_GoSignalTime_ms);
A_IFTRelease_minus_B_GO_RT_diff_struct = fn_create_quantized_saturated_value_and_label_lists( A_InitialTargetReleaseRT_minus_B_GO_diff, 1000, timing_split.quant_method, -500, 500, 'Aiftr_Bgo', GoodTrialsIdx );
B_IFTRelease_minus_A_GO_RT_diff_struct = fn_create_quantized_saturated_value_and_label_lists( B_InitialTargetReleaseRT_minus_A_GO_diff, 1000, timing_split.quant_method, -500, 500, 'Biftr_Ago', GoodTrialsIdx );

A_IFTrel_minus_Bgo_list = A_IFTRelease_minus_B_GO_RT_diff_struct.symbolic_sat_labeled_values;
A_IFTrel_minus_Bgo_list(:) = {'NONE'};
A_IFTrel_minus_Bgo_list(A_IFTRelease_minus_B_GO_RT_diff_struct.quantized_data == -1000) = {'A_faster_Bgo'};
A_IFTrel_minus_Bgo_list(A_IFTRelease_minus_B_GO_RT_diff_struct.quantized_data == 1000) = {'A_slower_Bgo'};
A_IFTrel_minus_Bgo_list(AB_equal_go_idx) = {'ABgo'};

B_IFTrel_minus_Ago_list = B_IFTRelease_minus_A_GO_RT_diff_struct.symbolic_sat_labeled_values;
B_IFTrel_minus_Ago_list(:) = {'NONE'};
B_IFTrel_minus_Ago_list(B_IFTRelease_minus_A_GO_RT_diff_struct.quantized_data == -1000) = {'B_faster_Ago'};
B_IFTrel_minus_Ago_list(B_IFTRelease_minus_A_GO_RT_diff_struct.quantized_data == 1000) = {'B_slower_Ago'};
B_IFTrel_minus_Ago_list(AB_equal_go_idx) = {'ABgo'};

% for dyadic trials we want 500ms clean of others go-signal & action,
% whatever was closer in time

A_IFTrel_minus_Bgo_or_action_list




% TargetAcquisitionRT
A_TargetAcquisitionRT = report_struct.data(:, report_struct.cn.A_TargetTouchTime_ms); % - report_struct.data(:, report_struct.cn.A_GoSignalTime_ms);
B_TargetAcquisitionRT = report_struct.data(:, report_struct.cn.B_TargetTouchTime_ms); % - report_struct.data(:, report_struct.cn.B_GoSignalTime_ms);
AB_TargetAcquisitionRT_diff = A_TargetAcquisitionRT - B_TargetAcquisitionRT;
AB_TargetAcquisitionRT_diff(A_TargetAcquisitionRT == 0) = report_struct.data(A_TargetAcquisitionRT == 0, report_struct.cn.A_GoSignalTime_ms) - B_TargetAcquisitionRT(A_TargetAcquisitionRT == 0);
AB_TargetAcquisitionRT_diff(B_TargetAcquisitionRT == 0) = A_TargetAcquisitionRT(B_TargetAcquisitionRT == 0) - report_struct.data(B_TargetAcquisitionRT == 0, report_struct.cn.B_GoSignalTime_ms);
AB_TargetAcquisitionRT_diff_struct = fn_create_quantized_saturated_value_and_label_lists( AB_TargetAcquisitionRT_diff, timing_split.quantum_ms, timing_split.quant_method, timing_split.saturation_min_ms, timing_split.saturation_max_ms, 'ABcrt', GoodTrialsIdx );


% InitialTargetRelease reaction time plus half of the movement time
A_IniTargRel_05MT_RT = A_InitialTargetReleaseRT + 0.5 * (A_TargetAcquisitionRT - A_InitialTargetReleaseRT);
B_IniTargRel_05MT_RT = B_InitialTargetReleaseRT + 0.5 * (B_TargetAcquisitionRT - B_InitialTargetReleaseRT);
AB_IniTargRel_05MT_RT_diff = A_IniTargRel_05MT_RT - B_IniTargRel_05MT_RT;
AB_IniTargRel_05MT_RT_diff_struct = fn_create_quantized_saturated_value_and_label_lists( AB_IniTargRel_05MT_RT_diff, timing_split.quantum_ms, timing_split.quant_method, timing_split.saturation_min_ms, timing_split.saturation_max_ms, 'ABrmt', GoodTrialsIdx );




% split the equal GO signal cases by who was faster
if (split_diffGoSignal_eq_0_by_RT)
	zero_diff_idx = find(quantized_AB_diffGoSignalTime == 0);
	RT_diff_list = eval(['AB_', diffGoSignal_eq_0_by_RT_RT_type, '_diff']);
	% find when A was faster
	A_faster_idx = find(RT_diff_list <= 0);
	tmp_A_idx = intersect(zero_diff_idx, A_faster_idx);
	quantized_AB_diffGoSignalTime(tmp_A_idx) = -0.1;
	B_faster_idx = find(RT_diff_list > 0);
	tmp_B_idx = intersect(zero_diff_idx, B_faster_idx);
	quantized_AB_diffGoSignalTime(tmp_B_idx) = +0.1;
	
	%quantized_AB_diffGoSignalTime = round(AB_diffGoSignalTime/GoSignalQuantum_ms) * GoSignalQuantum_ms;
	unique_quantized_cur_ABdiffGoSignalTimes = unique(quantized_AB_diffGoSignalTime(GoodTrialsIdx));
	% insert the two new categories, even if one is empty
	unique_quantized_cur_ABdiffGoSignalTimes = unique([unique_quantized_cur_ABdiffGoSignalTimes; -0.1; +0.1]);
end

% create a list with Afaster trials. anfd Bfaster trials




% this collects the diffGo trials
diffGo_trial_cat_list = zeros(size(quantized_AB_diffGoSignalTime));
for i_ABdiffGoSignalTimes_cat = 1 : length(unique_quantized_cur_ABdiffGoSignalTimes)
	cur_ABdiffGoSignalTimes_cat = unique_quantized_cur_ABdiffGoSignalTimes(i_ABdiffGoSignalTimes_cat);
	trials_in_cur_ABdiffGoSignalTimes_cat_idx = find(quantized_AB_diffGoSignalTime == cur_ABdiffGoSignalTimes_cat);
	if ~isempty(trials_in_cur_ABdiffGoSignalTimes_cat_idx)
		diffGo_trial_cat_list(trials_in_cur_ABdiffGoSignalTimes_cat_idx) = i_ABdiffGoSignalTimes_cat;
	end
end

ABdiffGoSignalTimes_value_list = unique_quantized_cur_ABdiffGoSignalTimes(diffGo_trial_cat_list);
% we only have 4 classes, just name them by hand for better legends
unique_quantized_cur_ABdiffGoSignalTimes_names = {'Go: A<B', 'Go: A=B, A faster', 'Go: A=B, B faster', 'Go: B<A'};
ABdiffGoSignalTimes_name_per_trial_list = unique_quantized_cur_ABdiffGoSignalTimes_names(diffGo_trial_cat_list);


% solo_idx = TrialSets.ByTrialSubType.SoloA;
% dyadic_idx = TrialSets.ByTrialSubType.Dyadic;
%
%
% % this collects the diffGo trials
% %diffGo_trial_cat_list = zeros(size(quantized_AB_diffGoSignalTime));
% diffGo_TrialSets = struct();
%
% for i_ABdiffGoSignalTimes_cat = 1 : length(unique_quantized_cur_ABdiffGoSignalTimes)
%     cur_ABdiffGoSignalTimes_cat = unique_quantized_cur_ABdiffGoSignalTimes(i_ABdiffGoSignalTimes_cat);
%     cur_sanitized_cat_name = fn_sanitize_value_as_matlab_variable_name(cur_ABdiffGoSignalTimes_cat, 1);
%     trials_in_cur_ABdiffGoSignalTimes_cat_idx = find(quantized_AB_diffGoSignalTime == cur_ABdiffGoSignalTimes_cat);
%
%     trials_in_cur_ABdiffGoSignalTimes_cat_idx = find(quantized_AB_diffGoSignalTime == cur_ABdiffGoSignalTimes_cat);
%
%     if ~isempty(trials_in_cur_ABdiffGoSignalTimes_cat_idx)
%         %diffGo_trial_cat_list(trials_in_cur_ABdiffGoSignalTimes_cat_idx) = i_ABdiffGoSignalTimes_cat;
%
%         diffGo_TrialSets.(cur_sanitized_cat_name) = trials_in_cur_ABdiffGoSignalTimes_cat_idx;
%
%         cur_good_trials = intersect(GoodTrialsIdx, find(abs(AB_InitialTargetReleaseRT_diff) < 10000));
%
%         diffGo_RTs_solo.(cur_sanitized_cat_name) = mean(AB_InitialTargetReleaseRT_diff(intersect(cur_good_trials, intersect(solo_idx, diffGo_TrialSets.(cur_sanitized_cat_name)))));
%         diffGo_RTs_dyadic.(cur_sanitized_cat_name) = mean(AB_InitialTargetReleaseRT_diff(intersect(cur_good_trials, intersect(dyadic_idx, diffGo_TrialSets.(cur_sanitized_cat_name)))));
%
%
%         %AB_InitialTargetReleaseRT_diff;
%     end
% end
%
%





% merge SOLO and DYADIC use the 4 dyadic choice combination + the 2 solo
dyadic_solo_choice_combination_struct = fn_define_by_trial_idx_color_linestyle_struct(TrialSets, 'dyadic_solo_choice_combination', 'ChoiceCombByAsTargPos');
dyadic_solo_choice_combination_list = dyadic_solo_choice_combination_struct.unique_cat_name_list(dyadic_solo_choice_combination_struct.cat_per_trial_idx + 1);


% pure choie combinations with classic Anton colors
choice_combination_struct = fn_define_by_trial_idx_color_linestyle_struct(TrialSets, 'choice_combination', 'PureChoiceComb');
choice_combination_list = choice_combination_struct.unique_cat_name_list(choice_combination_struct.cat_per_trial_idx + 1);


%TrialSubType_list = fn_expand_TrialSets_byVar_by_Side(size(report_struct.data, 1), TrialSets.ByTrialSubType.SideA, 'None');
TrialSubType_struct = fn_define_by_trial_idx_color_linestyle_struct(TrialSets, 'TrialSubType', 'TrialSubType', 'SideA');
TrialSubType_list = TrialSubType_struct.unique_cat_name_list(TrialSubType_struct.cat_per_trial_idx + 1)';

dyadic_sameness_struct = fn_define_by_trial_idx_color_linestyle_struct(TrialSets, 'dyadic_sameness', 'DyadicSameness');
dyadic_sameness_list = dyadic_sameness_struct.unique_cat_name_list(dyadic_sameness_struct.cat_per_trial_idx + 1)';



% social context: solo vesus dyadic, semisolo, and simulated variants
social_context_list = cell(size(TrialSubType_list));
social_context_list(ismember(TrialSubType_list, {'SemiSolo', 'SemiSoloBlockedView'})) = {'SemiSolo'};
social_context_list(ismember(TrialSubType_list, {'Dyadic', 'DyadicBlockedView'})) = {'Dyadic'};
social_context_list(ismember(TrialSubType_list, {'SoloA', 'SoloABlockedView', 'SoloARewardAB', 'SoloAHighReward', 'SoloB', 'SoloBBlockedView', 'SoloBRewardAB', 'SoloBHighReward'})) = {'Solo'};
social_context_list(ismember(TrialSubType_list, {'SoloARewardAB', 'SoloBRewardAB'})) = {'PassiveSoloRewarded'};
social_context_list(ismember(TrialSubType_list, {'None', 'NONE'})) = {'None'};


% to compare Solo versus SemiSolo we need a new list
SoloVsSemiSolo_list = social_context_list;
SoloVsSemiSolo_list(ismember(social_context_list, {'Dyadic'})) = {'None'};

DyadicVsSemiSolo_list = social_context_list;
DyadicVsSemiSolo_list(ismember(social_context_list, {'Solo'})) = {'None'};

% confederate's predictability
n_trials = size(report_struct.data, 1);
dyadic_trials = TrialSets.ByTrialSubType.Dyadic;
if isfield(TrialSets.ByTrialSubType, 'DyadicBlockedView') && ~isempty(TrialSets.ByTrialSubType.DyadicBlockedView)
	dyadic_trials = union(TrialSets.ByTrialSubType.Dyadic, TrialSets.ByTrialSubType.DyadicBlockedView);
end
non_dyadic_trials = setdiff((1:1:n_trials), dyadic_trials);
RandomizationMethodCodes_list = report_struct.Enums.RandomizationMethodCodes.unique_lists.RandomizationMethodCodes;

if isfield( report_struct.SessionByTrial.cn, 'ConfederateChoiceCueRandomizer_method_A')
	ConfChoiceCueRnd_method_A_RandomizationMethodCodes_idx = report_struct.SessionByTrial.data(:, report_struct.SessionByTrial.cn.ConfederateChoiceCueRandomizer_method_A) + 1;
	ConfChoiceCue_A_rnd_method_by_trial_list = RandomizationMethodCodes_list(ConfChoiceCueRnd_method_A_RandomizationMethodCodes_idx);
	ConfChoiceCue_A_invisible_idx = find(report_struct.data(:, report_struct.cn.A_ShowChoiceHint) == 0);
	ConfChoiceCue_A_rnd_method_by_trial_list(ConfChoiceCue_A_invisible_idx) = RandomizationMethodCodes_list(1);
	ConfChoiceCue_A_rnd_method_by_trial_list(non_dyadic_trials) = RandomizationMethodCodes_list(1);
else
	ConfChoiceCueRnd_method_A_RandomizationMethodCodes_idx = [];
	ConfChoiceCue_A_rnd_method_by_trial_list = [];
	ConfChoiceCue_A_invisible_idx =[];
end

if isfield( report_struct.SessionByTrial.cn, 'ConfederateChoiceCueRandomizer_method_B')
	ConfChoiceCueRnd_method_B_RandomizationMethodCodes_idx = report_struct.SessionByTrial.data(:, report_struct.SessionByTrial.cn.ConfederateChoiceCueRandomizer_method_B) + 1;
	ConfChoiceCue_B_rnd_method_by_trial_list = RandomizationMethodCodes_list(ConfChoiceCueRnd_method_B_RandomizationMethodCodes_idx);
	ConfChoiceCue_B_invisible_idx = find(report_struct.data(:, report_struct.cn.B_ShowChoiceHint) == 0);
	ConfChoiceCue_B_rnd_method_by_trial_list(ConfChoiceCue_B_invisible_idx) = RandomizationMethodCodes_list(1);
	ConfChoiceCue_B_rnd_method_by_trial_list(non_dyadic_trials) = RandomizationMethodCodes_list(1);
else
	ConfChoiceCueRnd_method_B_RandomizationMethodCodes_idx = [];
	ConfChoiceCue_B_rnd_method_by_trial_list = [];
	ConfChoiceCue_B_invisible_idx =[];
end


% predictability by CC
conf_predictability_dyadic_choice_combination_struct = fn_define_by_trial_idx_color_linestyle_struct(TrialSets, 'conf_predictability_dyadic_choice_combination', 'CombChoiceByConfPredictabilityByAsTargPos', ConfChoiceCue_B_rnd_method_by_trial_list);
conf_predictability_dyadic_choice_combination_list = conf_predictability_dyadic_choice_combination_struct.unique_cat_name_list(conf_predictability_dyadic_choice_combination_struct.cat_per_trial_idx + 1);

pure_predictability_unique_cat_name_list = { 'None', 'Blocked', 'Blocked', 'Blocked', 'Blocked', 'Shuffled', 'Shuffled', 'Shuffled', 'Shuffled'};
conf_predictability_list = pure_predictability_unique_cat_name_list(conf_predictability_dyadic_choice_combination_struct.cat_per_trial_idx + 1);

% special case 20201218T130348, where FS was acting in blocked fashion
% during SoloBRewardAB trials
if (strcmp(report_struct.LoggingInfo.SessionLogFileName, '20201218T130348.A_Elmo.B_FS.SCP_01' ))
	conf_predictability_list(ismember(TrialSubType_list, 'SoloBRewardAB')) = {'Blocked'};
end



%unique(conf_predictability_list)


% blocked view
visibility_by_trial_list = ones([n_trials, 1]);
visibility_by_trial_list(TrialSets.ByVisibility.AB_invisible) = 2;
visibility_by_trial_cat_name_list = {'None', 'Vis', 'Invis'};
visibility_by_trial_cat_list = visibility_by_trial_cat_name_list(visibility_by_trial_list + 1);

% convert the 3-4 diffGo categories into line types (reset existing line type classifications)
dyadic_solo_choice_combination_ByDiffGo_struct = fn_split_by_new_catgory_as_linestyles(dyadic_solo_choice_combination_struct, ...
	diffGo_trial_cat_list, unique_quantized_cur_ABdiffGoSignalTimes_names, {'-', '--', '-.', ':'}, 'ByDiffGo');
dyadic_solo_choice_combination_ByDiffGo_list = dyadic_solo_choice_combination_ByDiffGo_struct.unique_cat_name_list(dyadic_solo_choice_combination_ByDiffGo_struct.cat_per_trial_idx + 1);

conf_predictability_dyadic_choice_combination_ByDiffGo_struct = fn_split_by_new_catgory_as_linestyles(conf_predictability_dyadic_choice_combination_struct, ...
	diffGo_trial_cat_list, unique_quantized_cur_ABdiffGoSignalTimes_names, {'-', '--', '-.', ':'}, 'ByDiffGo');
conf_predictability_dyadic_choice_combination_ByDiffGo_list = conf_predictability_dyadic_choice_combination_ByDiffGo_struct.unique_cat_name_list(conf_predictability_dyadic_choice_combination_ByDiffGo_struct.cat_per_trial_idx + 1);

dyadic_solo_choice_combination_ByVisibility_struct = fn_split_by_new_catgory_as_linestyles(dyadic_solo_choice_combination_struct, ...
	visibility_by_trial_list, visibility_by_trial_cat_name_list, {'-', ':'}, 'ByVisibility');
dyadic_solo_choice_combination_ByVisibility_list = dyadic_solo_choice_combination_ByVisibility_struct.unique_cat_name_list(dyadic_solo_choice_combination_ByVisibility_struct.cat_per_trial_idx + 1);

TrialSubType_ByDiffGo_struct = fn_split_by_new_catgory_as_linestyles(TrialSubType_struct, ...
	diffGo_trial_cat_list, unique_quantized_cur_ABdiffGoSignalTimes_names, {'-', '--', '-.', ':'}, 'ByDiffGo');
TrialSubType_ByDiffGo_list = TrialSubType_ByDiffGo_struct.unique_cat_name_list(TrialSubType_ByDiffGo_struct.cat_per_trial_idx + 1);

choice_combination_ByDiffGo_struct = fn_split_by_new_catgory_as_linestyles(choice_combination_struct, ...
	diffGo_trial_cat_list, unique_quantized_cur_ABdiffGoSignalTimes_names, {'-', '--', '-.', ':'}, 'ByDiffGo');
choice_combination_ByDiffGo_list = choice_combination_ByDiffGo_struct.unique_cat_name_list(choice_combination_ByDiffGo_struct.cat_per_trial_idx + 1);


dyadic_sameness_ByDiffGo_struct = fn_split_by_new_catgory_as_linestyles(dyadic_sameness_struct, ...
	diffGo_trial_cat_list, unique_quantized_cur_ABdiffGoSignalTimes_names, {'-', '--', '-.', ':'}, 'ByDiffGo');
dyadic_sameness_ByDiffGo_list = dyadic_sameness_ByDiffGo_struct.unique_cat_name_list(dyadic_sameness_ByDiffGo_struct.cat_per_trial_idx + 1);



% position labels are:
position_labels = {'MiddleLeft', 'TopLeft', 'BottomLeft', 'TopRight', 'BottomRight', 'MiddleRight'};
% we want a three by two sub panel matrix, so reorder to
ordered_position_labels = {'TopLeft', 'TopRight', 'MiddleLeft', 'MiddleRight', 'BottomLeft', 'BottomRight'};
short_ordered_position_labels = {'tl', 'tr', 'ml', 'mr', 'bl', 'br'};

ordered_LR_position_labels = {'Left', 'Right', 'Left', 'Right', 'Left', 'Right'};
short_ordered_LR_position_labels = {'l', 'r', 'l', 'r', 'l', 'r'};

ordered_LR_positions = [1, 2, 1, 2, 1, 2];

%TODO get these independent of whether there are trials, by a subject
%otherwise the indices are off...


% now find the unique choices for Agent A
% A_TouchSelectedTargetPosition_X is filled even if Subject A did not
% touch, but  TargetTouchTime_ms is zero if no target was touched
% so currently these are by A's preference if A did not touch
A_selected_X = report_struct.data(:, report_struct.cn.A_TouchSelectedTargetPosition_X);
A_selected_Y = report_struct.data(:, report_struct.cn.A_TouchSelectedTargetPosition_Y);
B_selected_X = report_struct.data(:, report_struct.cn.B_TouchSelectedTargetPosition_X);
B_selected_Y = report_struct.data(:, report_struct.cn.B_TouchSelectedTargetPosition_Y);
% the color targets, since red is always opposite of yellow,
Red_target_X = report_struct.data(:, report_struct.cn.A_RandomizedTargetPosition_X);
Red_target_Y = report_struct.data(:, report_struct.cn.A_RandomizedTargetPosition_Y);


%TODO: order by B's choices if A only watches SoloBRewardAB
A_no_selection_idx = find(report_struct.data(:, report_struct.cn.A_TargetTouchTime_ms) == 0);
for i_A_no_selection = 1 : length(A_no_selection_idx)
	cur_trial_idx = A_no_selection_idx(i_A_no_selection);
	if report_struct.data(:, report_struct.cn.B_TargetTouchTime_ms) > 0
		A_selected_X(cur_trial_idx) =  B_selected_X(cur_trial_idx);
		A_selected_Y(cur_trial_idx) =  B_selected_Y(cur_trial_idx);
	end
end

[A_selected_positions, ~, A_selected_position_idx] = unique([A_selected_X, A_selected_Y], 'rows');
%selected_positions(selected_position_idx,:)

% exclude 0 0 positions as these come from aborted trials but confuse the
% position assignments
if isequal(A_selected_positions(1, :), [0 0])
	zero_pos_trial_idx = find(A_selected_position_idx == 1);
	GoodTrialsIdx = setdiff(GoodTrialsIdx, zero_pos_trial_idx);
	% remove the superflous index, since the trial is maked bad already.
	A_selected_position_idx = A_selected_position_idx -1;
	A_selected_positions(1, :) = [];
end

A_ordered_selected_positions = zeros(size(A_selected_positions));
A_ordered_selected_position_idx = zeros(size(A_selected_position_idx));
for i_ordered_unique_pos = 1 : length(position_labels)
	cur_ordered_position_label = ordered_position_labels{i_ordered_unique_pos};
	cur_unordered_idx = find(ismember(position_labels, cur_ordered_position_label));
	A_ordered_selected_positions(i_ordered_unique_pos, :) = A_selected_positions(cur_unordered_idx, :);
	A_ordered_selected_position_idx(find(A_selected_position_idx == cur_unordered_idx)) = i_ordered_unique_pos;
end

zero_pos_idx = find(A_ordered_selected_position_idx == 0);
% these trials are invalid anyway, but we need to assign something, that is
% a valid index
A_ordered_selected_position_idx(zero_pos_idx) = 1;

% all six positions
long_A_pos_list = ordered_position_labels(A_ordered_selected_position_idx);
short_A_pos_list = short_ordered_position_labels(A_ordered_selected_position_idx);
% only left right
long_A_LR_pos_list = ordered_LR_position_labels(A_ordered_selected_position_idx);
short_A_LR_pos_list = short_ordered_LR_position_labels(A_ordered_selected_position_idx);

% B_pos_list
% B_LR_pos_list
[B_selected_positions, ~, B_selected_position_idx] = unique([B_selected_X, B_selected_Y], 'rows');

% exclude 0 0 positions as these come from aborted trials but confuse the
% position assignments
if isequal(B_selected_positions(1, :), [0 0])
	zero_pos_trial_idx = find(B_selected_position_idx == 1);
	%GoodTrialsIdx = setdiff(GoodTrialsIdx, zero_pos_trial_idx);
	% remove the superflous index, since the trial is maked bad already.
	B_selected_position_idx = B_selected_position_idx -1;
	B_selected_positions(1, :) = [];
end

B_ordered_selected_positions = zeros(size(B_selected_positions));
B_ordered_selected_position_idx = zeros(size(B_selected_position_idx));
for i_ordered_unique_pos = 1 : length(position_labels)
	cur_ordered_position_label = ordered_position_labels{i_ordered_unique_pos};
	cur_unordered_idx = find(ismember(position_labels, cur_ordered_position_label));
	B_ordered_selected_positions(i_ordered_unique_pos, :) = B_selected_positions(cur_unordered_idx, :);
	B_ordered_selected_position_idx(find(B_selected_position_idx == cur_unordered_idx)) = i_ordered_unique_pos;
end

zero_pos_idx = find(B_ordered_selected_position_idx == 0);
% these trials are invalid anyway, but we need to assign something, that is
% a valid index
B_ordered_selected_position_idx(zero_pos_idx) = 1;

% all six positions
long_B_pos_list = ordered_position_labels(B_ordered_selected_position_idx);
short_B_pos_list = short_ordered_position_labels(B_ordered_selected_position_idx);
% only left right
long_B_LR_pos_list = ordered_LR_position_labels(B_ordered_selected_position_idx);
short_B_LR_pos_list = short_ordered_LR_position_labels(B_ordered_selected_position_idx);

% the new normal
A_LR_pos_list = cellfun(@(c)['A', c], short_A_LR_pos_list', 'uni', false);	% Al/Ar
B_LR_pos_list = cellfun(@(c)['B', c], short_B_LR_pos_list', 'uni', false); % Bl/Br

A_pos_list = cellfun(@(c)['A', c], short_A_pos_list', 'uni', false);	% Atl/Atr, ...
B_pos_list = cellfun(@(c)['B', c], short_B_pos_list', 'uni', false); % Btl/Btr, ...

% generate JointSelections
AB_pos_list = strcat('B', short_ordered_position_labels(B_ordered_selected_position_idx), 'A', short_ordered_position_labels(A_ordered_selected_position_idx))';
AB_LR_pos_list = strcat('B', short_ordered_LR_position_labels(B_ordered_selected_position_idx), 'A', short_ordered_LR_position_labels(A_ordered_selected_position_idx))';
% rather start with A than B...
AB_pos_list = strcat('A', short_ordered_position_labels(A_ordered_selected_position_idx), 'B', short_ordered_position_labels(B_ordered_selected_position_idx))';
AB_LR_pos_list = strcat('A', short_ordered_LR_position_labels(A_ordered_selected_position_idx), 'B', short_ordered_LR_position_labels(B_ordered_selected_position_idx))';




% RED position list
% B_LR_pos_list
[Red_target_positions, ~, Red_target_position_idx] = unique([Red_target_X, Red_target_Y], 'rows');

% exclude 0 0 positions as these come from aborted trials but confuse the
% position assignments
if isequal(Red_target_positions(1, :), [0 0])
	zero_pos_trial_idx = find(Red_target_position_idx == 1);
	%GoodTrialsIdx = setdiff(GoodTrialsIdx, zero_pos_trial_idx);
	% remove the superflous index, since the trial is marked bad already.
	Red_target_position_idx = Red_target_position_idx -1;
	Red_target_positions(1, :) = [];
end

Red_target_selected_positions = zeros(size(Red_target_positions));
Red_target_selected_position_idx = zeros(size(Red_target_position_idx));
for i_ordered_unique_pos = 1 : length(position_labels)
	cur_ordered_position_label = ordered_position_labels{i_ordered_unique_pos};
	cur_unordered_idx = find(ismember(position_labels, cur_ordered_position_label));
	Red_target_selected_positions(i_ordered_unique_pos, :) = Red_target_positions(cur_unordered_idx, :);
	Red_target_selected_position_idx(find(Red_target_position_idx == cur_unordered_idx)) = i_ordered_unique_pos;
end

zero_pos_idx = find(Red_target_selected_position_idx == 0);
% these trials are invalid anyway, but we need to assign something, that is
% a valid index
Red_target_selected_position_idx(zero_pos_idx) = 1;

% all six positions
Red_targ_pos_list = ordered_position_labels(Red_target_selected_position_idx)';
% only left right
Red_targ_LR_pos_list = ordered_LR_position_labels(Red_target_selected_position_idx)';

% same_different choices, defalt to different for solo
same_selected_position_idx = cellfun(@strcmp, A_LR_pos_list, B_LR_pos_list);
same_choice_list = cell(size(A_LR_pos_list));
same_choice_list(:) = {'D'};
same_choice_list(same_selected_position_idx) = {'S'};
% force all solo trials to be different
same_choice_list(ismember(social_context_list, {'Solo'})) = {'D'};

same_diff_list = same_choice_list;
same_diff_list(:) = {'Diff'};
same_diff_list(same_selected_position_idx) = {'Same'};

switch lower(A_position_set_name)
	case 'all'
	case {'lr', 'leftright'}
		A_ordered_selected_positions = A_ordered_selected_positions(3:4, :); % pretend middle positions, but should not matter much
		A_ordered_selected_position_idx = ordered_LR_positions(A_ordered_selected_position_idx);
		ordered_position_labels = {'Left', 'Right'};
	otherwise
		error(['Unknown A_position_set_name: ', A_position_set_name]);
end



% create combined lists, where a None or NaN in any one sets the combined
% label to None/NaN, differentiate between splitting and merging sets:
%   splitting sets create individual lists for all combinations of values (excluding None/NaN)
%   merging sets, for each trial fuse the labels of all lists together

list_struct = [];
exclude_keyword_list = {'None', 'NONE', 'none'};
separator_string = '_';

% get the agents
SideA_agent_list = report_struct.unique_lists.A_Name(report_struct.data(:, report_struct.cn.A_Name_idx));
if size(SideA_agent_list, 1) < size(SideA_agent_list, 2)
	SideA_agent_list = SideA_agent_list';
end
SideB_agent_list = report_struct.unique_lists.B_Name(report_struct.data(:, report_struct.cn.B_Name_idx));
if size(SideB_agent_list, 1) < size(SideB_agent_list, 2)
	SideB_agent_list = SideB_agent_list';
end
% remove the agent for single/solo trials (but keep)
proto_solo_trialsubtype_list = fieldnames(TrialSets.ByTrialSubType);
solo_trialsubtype_list = proto_solo_trialsubtype_list(ismember(proto_solo_trialsubtype_list, {'SoloA', 'SoloB', 'SoloAHighReward', 'SoloBHighReward', 'SoloABlockedView', 'SoloBBlockedView'}));
for i_solo_sst = 1 : length(solo_trialsubtype_list)
	cur_solo_trialsubtype = solo_trialsubtype_list{i_solo_sst};
	if ~isempty(strfind(cur_solo_trialsubtype, 'SoloB'))
		SideA_agent_list(TrialSets.ByTrialSubType.(cur_solo_trialsubtype)) = {'None'};
	end
	if ~isempty(strfind(cur_solo_trialsubtype, 'SoloA'))
		SideB_agent_list(TrialSets.ByTrialSubType.(cur_solo_trialsubtype)) = {'None'};
	end
end
SubjectCombination_list = strcat(SideA_agent_list, separator_string, SideB_agent_list);



% all agent/subject combinations
list_struct = fn_split_and_multi_merge_labels_into_list(list_struct, ...
	{ {},   {lower(TrialSubType_list)}, {lower(conf_predictability_list')}}, ...
	{ {SubjectCombination_list}}, ...
	{ {'SubjectCombination_list'}}, ...
	exclude_keyword_list, separator_string);

% split sets
go_sequence_list = ABdiffGoSignalTimes_name_per_trial_list;
go_sequence_list(ismember(ABdiffGoSignalTimes_name_per_trial_list, {'Go: A=B, A faster', 'Go: A=B, B faster'})) = {'ABgo'};
go_sequence_list(ismember(ABdiffGoSignalTimes_name_per_trial_list, {'Go: B<A'})) = {'BgoA'};
go_sequence_list(ismember(ABdiffGoSignalTimes_name_per_trial_list, {'Go: A<B'})) = {'AgoB'};
go_sequence_list = go_sequence_list';

% here we want non-overlapping action ranges...
tmp_irt_sequence_list = AB_InitialTargetReleaseRT_diff_struct.symbolic_sat_labeled_values;
irt_sequence_list = cell(size(tmp_irt_sequence_list));
irt_sequence_list(:) = {'None'};
irt_sequence_list(ismember(tmp_irt_sequence_list, {['qsABirt_ge+', num2str(timing_split.saturation_max_ms)], ['qsABirt_ge-', num2str(abs(timing_split.saturation_max_ms))]})) = {'BirtA'};
irt_sequence_list(ismember(tmp_irt_sequence_list, {['qsABirt_le-', num2str(abs(timing_split.saturation_min_ms))], ['qsABirt_le+', num2str(timing_split.saturation_min_ms)]})) = {'AirtB'};

tmp_crt_sequence_list = AB_TargetAcquisitionRT_diff_struct.symbolic_sat_labeled_values;
crt_sequence_list = cell(size(tmp_crt_sequence_list));
crt_sequence_list(:) = {'None'};
crt_sequence_list(ismember(tmp_crt_sequence_list, {['qsABcrt_ge+', num2str(timing_split.saturation_max_ms)], ['qsABcrt_ge-', num2str(abs(timing_split.saturation_max_ms))]})) = {'BcatA'};
crt_sequence_list(ismember(tmp_crt_sequence_list, {['qsABcrt_le-', num2str(abs(timing_split.saturation_min_ms))], ['qsABcrt_le+', num2str(timing_split.saturation_min_ms)]})) = {'AcatB'};

% exclude trials where IFT release and othre's Go signal are in the range of
% ]0, 500[ milliseconds
list_struct.A_IFTrel_minus_Bgo_list = A_IFTrel_minus_Bgo_list;
list_struct.B_IFTrel_minus_Ago_list = B_IFTrel_minus_Ago_list;



% % get the share of own choices
all_ones =  ones([size(TrialSets.All, 1), 1]);
% values from A's perspective (Red>Yellow)
A_value_name_list = {'None', 'ALo', 'AHi'};
A_value_name_idx = all_ones;
A_value_name_idx(TrialSets.ByChoice.SideA.ProtoTargetValueLow) = find(ismember(A_value_name_list, {'ALo'}));
A_value_name_idx(TrialSets.ByChoice.SideA.ProtoTargetValueHigh) = find(ismember(A_value_name_list, {'AHi'}));
% values from B's perspective (Yellow>Red)
B_value_name_list = {'None', 'BLo', 'BHi'};
B_value_name_idx = all_ones;
B_value_name_idx(TrialSets.ByChoice.SideB.ProtoTargetValueLow) = find(ismember(B_value_name_list, {'BLo'}));
B_value_name_idx(TrialSets.ByChoice.SideB.ProtoTargetValueHigh) = find(ismember(B_value_name_list, {'BHi'}));
%
A_val_list = A_value_name_list(A_value_name_idx)';
B_val_list = B_value_name_list(B_value_name_idx)';
AB_val_list = strcat(A_val_list, B_val_list);
% reset partial None to pure None values
AB_val_list(union(find(A_value_name_idx == 1), find(B_value_name_idx == 1))) = {'None'};




% % conf_predictability_list
% list_struct = fn_split_and_merge_labels_into_list(list_struct, {lower(conf_predictability_list')}, ...
%     {A_pos_list'}, {'A_pos_list'}, exclude_keyword_list, separator_string);
% list_struct = fn_split_and_merge_labels_into_list(list_struct, {lower(conf_predictability_list')}, ...
%     {A_LR_pos_list'}, {'A_LR_pos_list'}, exclude_keyword_list, separator_string);

% generate multiple lists in one go
% own and others reaches, as well as target position
list_struct = fn_split_and_multi_merge_labels_into_list(list_struct, ...
	{ ...
		{}, {lower(conf_predictability_list')}, {go_sequence_list, lower(conf_predictability_list')}, {lower(TrialSubType_list), go_sequence_list, lower(conf_predictability_list')}, ...
		{lower(TrialSubType_list), lower(conf_predictability_list'), SubjectCombination_list}, ...
		{irt_sequence_list, lower(conf_predictability_list')}, {lower(TrialSubType_list), irt_sequence_list, lower(conf_predictability_list')}, ...
	} , ...
	{ ...
		{A_pos_list}, {A_LR_pos_list}, {B_pos_list}, {B_LR_pos_list}, ...
		{Red_targ_pos_list}, {Red_targ_LR_pos_list}, ...
		{AB_pos_list}, {AB_LR_pos_list},...
		{same_diff_list}, ...
		{A_val_list}, {B_val_list}, {AB_val_list}, ...
	}, ...
	{ ...
		{'A_pos_list'}, {'A_LR_pos_list'}, {'B_pos_list'}, {'B_LR_pos_list'}, ...
		{'Red_targ_pos_list'}, {'Red_targ_LR_pos_list'}, ...
		{'AB_pos_list'}, {'AB_LR_pos_list'},...
		{'same_diff_list'}, ...
		{'A_val_list'}, {'B_val_list'}, {'AB_val_list'}, ...
	}, ...
	exclude_keyword_list, separator_string);


lower_social_context_list = lower(social_context_list);
%own action/reach has strong representation, as does joint choice, so split
%these out to reduce their influence


list_struct = fn_split_and_multi_merge_labels_into_list(list_struct, ...
	{ ...
		{lower(TrialSubType_list)}, ...
		{lower(TrialSubType_list), go_sequence_list}, ...
		{lower(TrialSubType_list), go_sequence_list, lower(conf_predictability_list')}, ...
		{lower(TrialSubType_list), go_sequence_list, A_LR_pos_list}, ...
		{lower(TrialSubType_list), go_sequence_list, lower(conf_predictability_list'), A_LR_pos_list}, ...
		{lower(TrialSubType_list), irt_sequence_list, A_LR_pos_list}, ...
		{lower(TrialSubType_list), irt_sequence_list, lower(conf_predictability_list'), A_LR_pos_list}, ...
	} , ...
	{ ...
		{B_LR_pos_list}, {same_diff_list}, ...
		{A_val_list}, {B_val_list}, {AB_val_list}, ...
	}, ...
	{ ...
		{'B_LR_pos_list'}, {'same_diff_list'}, ...
		{'A_val_list'}, {'B_val_list'}, {'AB_val_list'}, ...
	}, ...
	exclude_keyword_list, separator_string);

list_struct = fn_split_and_multi_merge_labels_into_list(list_struct, ...
	{ ...
		{lower(TrialSubType_list)}, ...
		{lower(TrialSubType_list), go_sequence_list}, ...
		{lower(TrialSubType_list), go_sequence_list, lower(conf_predictability_list')}, ...
		{lower(TrialSubType_list), go_sequence_list, B_LR_pos_list}, ...
		{lower(TrialSubType_list), go_sequence_list, lower(conf_predictability_list'), B_LR_pos_list}, ...
		{lower(TrialSubType_list), irt_sequence_list, B_LR_pos_list}, ...
		{lower(TrialSubType_list), irt_sequence_list, lower(conf_predictability_list'), B_LR_pos_list}, ...
	} , ...
	{ ...
		{A_LR_pos_list}, {same_diff_list}, ...
		{A_val_list}, {B_val_list}, {AB_val_list}, ...
	}, ...
	{ ...
		{'A_LR_pos_list'}, {'same_diff_list'}, ...
		{'A_val_list'}, {'B_val_list'}, {'AB_val_list'}, ...
	}, ...
	exclude_keyword_list, separator_string);

%TODO add value choices AH, AL, BH, BL, AHBH, AHBL, ALBH, ALBL (High Low, capitals to differ from lower case r and l for sides)

list_struct = fn_split_and_multi_merge_labels_into_list(list_struct, ...
	{ ...
		{}, {go_sequence_list}, {irt_sequence_list}, {lower_social_context_list}, {A_LR_pos_list}, {AB_LR_pos_list}, ...
		{lower_social_context_list, go_sequence_list}, ...
		{lower_social_context_list, irt_sequence_list} , ...
		{lower_social_context_list, A_LR_pos_list}, {lower_social_context_list, AB_LR_pos_list},...
		{lower_social_context_list, go_sequence_list, A_LR_pos_list}, {lower_social_context_list, go_sequence_list, AB_LR_pos_list}, ...
	},...
	{ ...
		{SubjectCombination_list}, ...
		{conf_predictability_list'}, ...
		{visibility_by_trial_cat_list'},...
		{same_diff_list} ...
		{B_LR_pos_list} ...
	}, ...
	{ ...
		{'SubjectCombination_list'}, ...
		{'conf_predictability_list'}, ...
		{'visibility_by_trial_cat_list'},...
		{'same_diff_list'} ...
		{'B_LR_pos_list'} ...
	}, ...
	exclude_keyword_list, separator_string);




% Reward magnitude
A_NumberRewardPulsesDelivered_HIT_list = compose('RA%g', report_struct.data(:, report_struct.cn.A_NumberRewardPulsesDelivered_HIT));
A_NumberRewardPulsesDelivered_HIT_list(ismember(A_NumberRewardPulsesDelivered_HIT_list, {'R0'})) = {'None'};
B_NumberRewardPulsesDelivered_HIT_list = compose('RB%g', report_struct.data(:, report_struct.cn.B_NumberRewardPulsesDelivered_HIT));
B_NumberRewardPulsesDelivered_HIT_list(ismember(B_NumberRewardPulsesDelivered_HIT_list, {'R0'})) = {'None'};

% these are HITs and rewards for Y in SoloXRewardXY trials
A_AccumulatedRewardPulses_list = compose('RA%g',diff([0; report_struct.data(:, report_struct.cn.A_AccumulatedRewardPulses)]));
B_AccumulatedRewardPulses_list = compose('RB%g',diff([0; report_struct.data(:, report_struct.cn.B_AccumulatedRewardPulses)]));

% special case SoloXRewardXY trials
if isfield(TrialSets, 'ByTrialSubType') && isfield(TrialSets.ByTrialSubType, 'SoloBRewardAB')
	A_NumberRewardPulsesDelivered_HIT_list(TrialSets.ByTrialSubType.SoloBRewardAB) = A_AccumulatedRewardPulses_list(TrialSets.ByTrialSubType.SoloBRewardAB);
end
if isfield(TrialSets, 'ByTrialSubType') && isfield(TrialSets.ByTrialSubType, 'SoloARewardAB')
	B_NumberRewardPulsesDelivered_HIT_list(TrialSets.ByTrialSubType.SoloARewardAB) = B_AccumulatedRewardPulses_list(TrialSets.ByTrialSubType.SoloARewardAB);
end
AB_JointReward_list = strcat(A_NumberRewardPulsesDelivered_HIT_list, {'_'}, B_NumberRewardPulsesDelivered_HIT_list);

list_struct = fn_split_and_multi_merge_labels_into_list(list_struct, ...
	{ {}, {TrialSubType_list}, {go_sequence_list}, {TrialSubType_list, go_sequence_list},  {irt_sequence_list}, {TrialSubType_list, irt_sequence_list} }, ...
	{ {A_NumberRewardPulsesDelivered_HIT_list'}, {B_NumberRewardPulsesDelivered_HIT_list'}, {AB_JointReward_list} }, ...
	{ {'A_Reward_list'}, {'B_Reward_list'}, {'AB_JointReward_list'} }, ...
	exclude_keyword_list, separator_string);

% trial sub type by diffGO
list_struct = fn_split_and_multi_merge_labels_into_list(list_struct, ...
	{ ...
		{}, {go_sequence_list}, {SubjectCombination_list}, {A_NumberRewardPulsesDelivered_HIT_list}, {B_NumberRewardPulsesDelivered_HIT_list}, {go_sequence_list, A_NumberRewardPulsesDelivered_HIT_list}, ...
		{irt_sequence_list}, {irt_sequence_list, A_NumberRewardPulsesDelivered_HIT_list}, ...
		{same_choice_list, A_NumberRewardPulsesDelivered_HIT_list}, {same_choice_list, go_sequence_list, A_NumberRewardPulsesDelivered_HIT_list}, {same_choice_list, irt_sequence_list, A_NumberRewardPulsesDelivered_HIT_list}, ...
	}, ...
	{ {TrialSubType_list'} }, ...
	{ {'TrialSubType_list'} }, ...
	exclude_keyword_list, separator_string);


% tmp_list_struct = fn_split_and_multi_merge_labels_into_list(list_struct, ...
%     { {}, {go_sequence_list}, {SubjectCombination_list}, {A_NumberRewardPulsesDelivered_HIT_list}, {B_NumberRewardPulsesDelivered_HIT_list}, {go_sequence_list, A_NumberRewardPulsesDelivered_HIT_list}, ...
% 	{irt_sequence_list}, {irt_sequence_list, A_NumberRewardPulsesDelivered_HIT_list}, ...
%     { {TrialSubType_list'} }, ...
%     { {'TrialSubType_list'} }, ...
%     exclude_keyword_list, separator_string);



% save from deletion as A/B_NumberRewardPulsesDelivered_HIT are members of
% % the numeric variables
% list_struct.all_A_NumberRewardPulsesDelivered_HIT = list_struct.A_NumberRewardPulsesDelivered_HIT;
% list_struct.all_B_NumberRewardPulsesDelivered_HIT = list_struct.B_NumberRewardPulsesDelivered_HIT;

% blocked_B_pos_list = B_pos_list;
% blocked_B_pos_list(ismember(conf_predictability_list, {'Shuffled', 'None'})) = {'None'};
% blocked_B_LR_pos_list = B_LR_pos_list;
% blocked_B_LR_pos_list(ismember(conf_predictability_list, {'Shuffled', 'None'})) = {'None'};
%
% shuffled_B_pos_list = B_pos_list;
% shuffled_B_pos_list(ismember(conf_predictability_list, {'Blocked', 'None'})) = {'None'};
% shuffled_B_LR_pos_list = B_LR_pos_list;
% shuffled_B_LR_pos_list(ismember(conf_predictability_list, {'Blocked', 'None'})) = {'None'};
%
%
% AgoB_blocked_B_pos_list = blocked_B_pos_list;
% AgoB_blocked_B_pos_list(ismember(ABdiffGoSignalTimes_name_per_trial_list, {'Go: A=B, A faster', 'Go: A=B, B faster', 'Go: B<A', 'None'})) = {'None'};
% AgoB_blocked_B_LR_pos_list = blocked_B_LR_pos_list;
% AgoB_blocked_B_LR_pos_list(ismember(ABdiffGoSignalTimes_name_per_trial_list, {'Go: A=B, A faster', 'Go: A=B, B faster', 'Go: B<A', 'None'})) = {'None'};
%
% AgoB_shuffled_B_pos_list = shuffled_B_pos_list;
% AgoB_shuffled_B_pos_list(ismember(ABdiffGoSignalTimes_name_per_trial_list, {'Go: A=B, A faster', 'Go: A=B, B faster', 'Go: B<A', 'None'})) = {'None'};
% AgoB_shuffled_B_LR_pos_list = shuffled_B_LR_pos_list;
% AgoB_shuffled_B_LR_pos_list(ismember(ABdiffGoSignalTimes_name_per_trial_list, {'Go: A=B, A faster', 'Go: A=B, B faster', 'Go: B<A', 'None'})) = {'None'};



% session
cur_raster_site_info.sessionID = session_id;
% behaviour
cur_raster_site_info.report_struct = report_struct;
cur_raster_site_info.TrialSets = TrialSets;

% generate a structure of per trial vectors/cell lists
cur_raster_labels = fn_convert_table_and_header_to_struct(report_struct.data, report_struct.header, 'colheader');
if isfield(report_struct, 'SessionByTrial') && ~isempty(report_struct.SessionByTrial)
	session_by_trial_raster_labels = fn_convert_table_and_header_to_struct(report_struct.SessionByTrial.data, report_struct.SessionByTrial.header, 'colheader');
	cur_raster_labels = fn_add_structs(cur_raster_labels, session_by_trial_raster_labels);
end
% save the numeric fieldnames to avoid exporting those for NDT (to keep the size small)
cur_raster_labels_numeric_fields = fieldnames(cur_raster_labels);

if ~isempty(list_struct)
	list_struct_fields = fieldnames(list_struct);
	for i_field = 1: length(list_struct_fields)
		cur_fieldname = list_struct_fields{i_field};
		if size(list_struct.(cur_fieldname), 1) < size(list_struct.(cur_fieldname), 2)
			
			cur_raster_labels.(cur_fieldname) = list_struct.(cur_fieldname)';
		else
			cur_raster_labels.(cur_fieldname) = list_struct.(cur_fieldname);
		end
	end
end

% cur_raster_labels.dyadic_A_NumberRewardPulsesDelivered_HIT = compose('%g', cur_raster_labels.A_NumberRewardPulsesDelivered_HIT);
% cur_raster_labels.dyadic_A_NumberRewardPulsesDelivered_HIT(ismember(cur_raster_labels.dyadic_A_NumberRewardPulsesDelivered_HIT, {'0'})) = {'None'};
% cur_raster_labels.dyadic_A_NumberRewardPulsesDelivered_HIT(~ismember(social_context_list, {'Dyadic'})) = {'None'};
%
% cur_raster_labels.semisolo_A_NumberRewardPulsesDelivered_HIT = compose('%g', cur_raster_labels.A_NumberRewardPulsesDelivered_HIT);
% cur_raster_labels.semisolo_A_NumberRewardPulsesDelivered_HIT(ismember(cur_raster_labels.semisolo_A_NumberRewardPulsesDelivered_HIT, {'0'})) = {'None'};
% cur_raster_labels.semisolo_A_NumberRewardPulsesDelivered_HIT(~ismember(social_context_list, {'SemiSolo'})) = {'None'};
%
% cur_raster_labels.solo_A_NumberRewardPulsesDelivered_HIT = compose('%g', cur_raster_labels.A_NumberRewardPulsesDelivered_HIT);
% cur_raster_labels.solo_A_NumberRewardPulsesDelivered_HIT(ismember(cur_raster_labels.solo_A_NumberRewardPulsesDelivered_HIT, {'0'})) = {'None'};
% cur_raster_labels.solo_A_NumberRewardPulsesDelivered_HIT(~ismember(social_context_list, {'Solo'})) = {'None'};



% add more class labels
cur_raster_labels.ConfChoiceCue_B_rnd_method_by_trial_list = ConfChoiceCue_B_rnd_method_by_trial_list';
cur_raster_labels.ConfChoiceCue_A_rnd_method_by_trial_list = ConfChoiceCue_A_rnd_method_by_trial_list';



% % choice positions/sides:
% cur_raster_labels.A_pos_list = A_pos_list';
% cur_raster_labels.A_LR_pos_list = A_LR_pos_list';
%
% cur_raster_labels.blocked_A_pos_list = blocked_A_pos_list';
% cur_raster_labels.blocked_A_LR_pos_list = blocked_A_LR_pos_list';
% cur_raster_labels.shuffled_A_pos_list = shuffled_A_pos_list';
% cur_raster_labels.shuffled_A_LR_pos_list = shuffled_A_LR_pos_list';
%
% cur_raster_labels.AgoB_blocked_A_pos_list = AgoB_blocked_A_pos_list';
% cur_raster_labels.AgoB_blocked_A_LR_pos_list = AgoB_blocked_A_LR_pos_list';
% cur_raster_labels.AgoB_shuffled_A_pos_list = AgoB_shuffled_A_pos_list';
% cur_raster_labels.AgoB_shuffled_A_LR_pos_list = AgoB_shuffled_A_LR_pos_list';
%
% cur_raster_labels.BgoA_blocked_A_pos_list = BgoA_blocked_A_pos_list';
% cur_raster_labels.BgoA_blocked_A_LR_pos_list = BgoA_blocked_A_LR_pos_list';
% cur_raster_labels.BgoA_shuffled_A_pos_list = BgoA_shuffled_A_pos_list';
% cur_raster_labels.BgoA_shuffled_A_LR_pos_list = BgoA_shuffled_A_LR_pos_list';
%
%
% cur_raster_labels.B_pos_list = B_pos_list';
% cur_raster_labels.B_LR_pos_list = B_LR_pos_list';
%
% cur_raster_labels.blocked_B_pos_list = blocked_B_pos_list';
% cur_raster_labels.blocked_B_LR_pos_list = blocked_B_LR_pos_list';
% cur_raster_labels.shuffled_B_pos_list = shuffled_B_pos_list';
% cur_raster_labels.shuffled_B_LR_pos_list = shuffled_B_LR_pos_list';
%
% cur_raster_labels.AgoB_blocked_B_pos_list = AgoB_blocked_B_pos_list';
% cur_raster_labels.AgoB_blocked_B_LR_pos_list = AgoB_blocked_B_LR_pos_list';
% cur_raster_labels.AgoB_shuffled_B_pos_list = AgoB_shuffled_B_pos_list';
% cur_raster_labels.AgoB_shuffled_B_LR_pos_list = AgoB_shuffled_B_LR_pos_list';
%
% cur_raster_labels.BgoA_blocked_B_pos_list = BgoA_blocked_B_pos_list';
% cur_raster_labels.BgoA_blocked_B_LR_pos_list = BgoA_blocked_B_LR_pos_list';
% cur_raster_labels.BgoA_shuffled_B_pos_list = BgoA_shuffled_B_pos_list';
% cur_raster_labels.BgoA_shuffled_B_LR_pos_list = BgoA_shuffled_B_LR_pos_list';
%
%
% cur_raster_labels.dyadic_AgoB_blocked_B_pos_list = dyadic_AgoB_blocked_B_pos_list';
% cur_raster_labels.dyadic_AgoB_blocked_B_LR_pos_list = dyadic_AgoB_blocked_B_LR_pos_list';
% cur_raster_labels.dyadic_AgoB_shuffled_B_pos_list = dyadic_AgoB_shuffled_B_pos_list';
% cur_raster_labels.dyadic_AgoB_shuffled_B_LR_pos_list = dyadic_AgoB_shuffled_B_LR_pos_list';
%
% cur_raster_labels.dyadic_BgoA_blocked_B_pos_list = dyadic_BgoA_blocked_B_pos_list';
% cur_raster_labels.dyadic_BgoA_blocked_B_LR_pos_list = dyadic_BgoA_blocked_B_LR_pos_list';
% cur_raster_labels.dyadic_BgoA_shuffled_B_pos_list = dyadic_BgoA_shuffled_B_pos_list';
% cur_raster_labels.dyadic_BgoA_shuffled_B_LR_pos_list = dyadic_BgoA_shuffled_B_LR_pos_list';
%
% cur_raster_labels.semisolo_AgoB_blocked_B_pos_list = semisolo_AgoB_blocked_B_pos_list';
% cur_raster_labels.semisolo_AgoB_blocked_B_LR_pos_list = semisolo_AgoB_blocked_B_LR_pos_list';
% cur_raster_labels.semisolo_AgoB_shuffled_B_pos_list = semisolo_AgoB_shuffled_B_pos_list';
% cur_raster_labels.semisolo_AgoB_shuffled_B_LR_pos_list = semisolo_AgoB_shuffled_B_LR_pos_list';
%
% cur_raster_labels.semisolo_BgoA_blocked_B_pos_list = semisolo_BgoA_blocked_B_pos_list';
% cur_raster_labels.semisolo_BgoA_blocked_B_LR_pos_list = semisolo_BgoA_blocked_B_LR_pos_list';
% cur_raster_labels.semisolo_BgoA_shuffled_B_pos_list = semisolo_BgoA_shuffled_B_pos_list';
% cur_raster_labels.semisolo_BgoA_shuffled_B_LR_pos_list = semisolo_BgoA_shuffled_B_LR_pos_list';



% social context (dyadic versus solo)
cur_raster_labels.social_context_list = social_context_list;
% the full TrialSubType name
cur_raster_labels.TrialSubType_list = TrialSubType_list;
cur_raster_labels.RewardA_x_TrialSubType_code  = dyadic_solo_choice_combination_struct.cat_per_trial_idx';
cur_raster_labels.ABdiffGoSignalTimes_value_list = ABdiffGoSignalTimes_value_list;
cur_raster_labels.dyadic_solo_choice_combination_list = dyadic_solo_choice_combination_list';
cur_raster_labels.conf_predictability_dyadic_choice_combination_list = conf_predictability_dyadic_choice_combination_list';
cur_raster_labels.conf_predictability_list = conf_predictability_list';

cur_raster_labels.dyadic_solo_choice_combination_ByDiffGo_list = dyadic_solo_choice_combination_ByDiffGo_list';
cur_raster_labels.conf_predictability_dyadic_choice_combination_ByDiffGo_list = conf_predictability_dyadic_choice_combination_ByDiffGo_list';
cur_raster_labels.dyadic_solo_choice_combination_ByVisibility_list = dyadic_solo_choice_combination_ByVisibility_list';

cur_raster_labels.dyadic_ABdiffGoSignalTimes_list = ABdiffGoSignalTimes_name_per_trial_list';
cur_raster_labels.dyadic_ABdiffGoSignalTimes_list(union(TrialSets.ByJointness.SideA.SoloSubjectTrials, TrialSets.ByJointness.SideB.SoloSubjectTrials)) = {'None'};

cur_raster_labels.solo_ABdiffGoSignalTimes_list = ABdiffGoSignalTimes_name_per_trial_list';
cur_raster_labels.solo_ABdiffGoSignalTimes_list(TrialSets.ByJointness.SideA.DualSubjectJointTrials) = {'None'};

cur_raster_labels.dyadic_choice_combination_list = choice_combination_list';
cur_raster_labels.dyadic_choice_combination_list(union(TrialSets.ByJointness.SideA.SoloSubjectTrials, TrialSets.ByJointness.SideB.SoloSubjectTrials)) = {'None'};

cur_raster_labels.solo_choice_combination_list = choice_combination_list';
cur_raster_labels.solo_choice_combination_list(TrialSets.ByJointness.SideA.DualSubjectJointTrials) = {'None'};


cur_raster_labels.dyadic_choice_combination_ByDiffGo_list = choice_combination_ByDiffGo_list';
cur_raster_labels.dyadic_choice_combination_ByDiffGo_list(union(TrialSets.ByJointness.SideA.SoloSubjectTrials, TrialSets.ByJointness.SideB.SoloSubjectTrials)) = {'None'};

cur_raster_labels.solo_choice_combination_ByDiffGo_list = choice_combination_ByDiffGo_list';
cur_raster_labels.solo_choice_combination_ByDiffGo_list(TrialSets.ByJointness.SideA.DualSubjectJointTrials) = {'None'};
% for population plotting by NDT
cur_raster_labels.TrialSubType_ByDiffGo_list = TrialSubType_ByDiffGo_list';
cur_raster_labels.LR_TrialSubType_ByDiffGo_list = strcat(ordered_position_labels(A_ordered_selected_position_idx), {'__'}, TrialSubType_ByDiffGo_list)';
cur_raster_labels.LR_TrialSubType_ByDiffGo_list(ismember(TrialSubType_ByDiffGo_list, 'None')) = {'None'};


cur_raster_labels.dyadic_sameness_list = dyadic_sameness_list;
cur_raster_labels.dyadic_sameness_ByDiffGo_list = dyadic_sameness_ByDiffGo_list';

cur_raster_labels.SoloVsSemiSolo_list = SoloVsSemiSolo_list';
cur_raster_labels.DyadicVsSemiSolo_list = DyadicVsSemiSolo_list';


cur_raster_labels_lists = fieldnames(cur_raster_labels);
for i_cur_raster_labels_list = 1 : length(cur_raster_labels_lists)
	cur_raster_labels_list_name = cur_raster_labels_lists{i_cur_raster_labels_list};
	cur_raster_labels_list = cur_raster_labels.(cur_raster_labels_list_name);
	
	[cur_raster_label_names, ~, ~] = unique(cur_raster_labels_list);
	if iscell(cur_raster_labels_list)
		% find none/NONE/None and set to zero
		none_idx = find(ismember(cur_raster_label_names, {'none', 'None', 'NONE'}));
		if ~isempty(none_idx)
			cur_raster_label_names{none_idx} = 'None';
		end
	end
	cur_raster_labels_names.(cur_raster_labels_list_name) = cur_raster_label_names;
end


if (NDT.export_labels_as_idx_and_header)
	cur_numeric_raster_labels = struct();
	cur_numeric_raster_labels_names = struct();
	cur_raster_labels_lists = fieldnames(cur_raster_labels);
	
	for i_cur_raster_labels_list = 1 : length(cur_raster_labels_lists)
		cur_raster_labels_list_name = cur_raster_labels_lists{i_cur_raster_labels_list};
		cur_raster_labels_list = cur_raster_labels.(cur_raster_labels_list_name);
		if iscell(cur_raster_labels_list)
			%[cur_raster_labels_numeric, cur_raster_labels_names] = fn_convert_
			[cur_raster_label_names, ~, cur_raster_labels_numeric] = unique(cur_raster_labels_list);
			% find none/NONE/None and set to zero
			none_idx = find(ismember(cur_raster_label_names, {'none', 'None', 'NONE'}));
			if ~isempty(none_idx)
				cur_raster_labels_numeric(find(cur_raster_labels_numeric == none_idx)) = 0;
				cur_raster_label_names{none_idx} = 'None';
			end
			cur_numeric_raster_labels.(cur_raster_labels_list_name) = cur_raster_labels_numeric;
			cur_numeric_raster_labels_names.(cur_raster_labels_list_name) = cur_raster_label_names;
		end
	end
end


% save list of label names to text file
if isempty(dir(fullfile(TDT_sess_base_dir, 'PETHdata')))
	mkdir(fullfile(TDT_sess_base_dir, 'PETHdata'));
end


% load the spreadsheet that gives the mapping from channel raw cluster ID
% to unit ID
spike_data_file_list = [];
unit_merge_and_reject_file_dirstruct = dir(fullfile(TDT_tank_FQN, [merge_and_reject_file_stem, session_id, merge_and_reject_file_ext]));
if ~isempty(unit_merge_and_reject_file_dirstruct)
	% load the table
	disp('Using unit_merge_and_reject_file_dirstruct to post-process the cluster-cutting results.');
	unit_merge_and_reject_table = readtable(fullfile(unit_merge_and_reject_file_dirstruct(end).folder, unit_merge_and_reject_file_dirstruct(end).name));
	unit_merge_and_reject_array = table2array(unit_merge_and_reject_table(:, 2:end));
	spike_data_file_list = table2cell(unit_merge_and_reject_table(:, 1));
end


% process LFPs
% Elmo-210401_SCP_DAG_v18-210401-124226_LFPw_Ch160.sev
% Elmo-210401_SCP_DAG_v18-210401-124226_RSn1_ch160.sev
% fieldtrip wants all LFP channels in a joint 2D matrix

Positions.Red_targ_LR_pos_list = Red_targ_LR_pos_list';
Positions.Red_targ_pos_list = Red_targ_pos_list';
Positions.A_pos_list = A_pos_list';
Positions.A_LR_pos_list = A_LR_pos_list';
Positions.B_pos_list = B_pos_list';
Positions.B_LR_pos_list = B_LR_pos_list';
Positions.AB_pos_list = AB_pos_list';
Positions.AB_LR_pos_list = AB_LR_pos_list';

if (process_LFPs)
	% store LFP dat in fieldtrip compatible fashion
	[lfp_data, lfp_hdr, lfp_info] = fn_export_LFP_data_for_fieldtrip(LFP_ID_substring, LFP_ext_string, LFP_resample_frequency_Hz, TDT_tank_FQN, LFP_load_field_trip_data);
	
	% create a fieldtrip compatible event struct array from timestamped
	% events/states and state durations
	paradigm_state_info.TDTSVal_paradigm_states = TDT_streams.epocs.SVal;
	paradigm_state_info.EventID_ParadigmStatesEnums = report_struct.Enums.ParadigmStates;
	[lfp_events, trial_idx_per_event_list, trial_map] = fn_export_events_for_fieldtrip(TDT_tank_FQN, LFP_resample_frequency_Hz, all_events_TDT_ts_struct, paradigm_state_info);
	
	% add the information requred to detect events
	% get all timing events in TDT time
	TrialInfo_struct.selected_events_TDT_ts_struct = all_events_TDT_ts_struct; % export all event time stamps
	TrialInfo_struct.TrialSets = TrialSets;
	TrialInfo_struct.cur_raster_labels = cur_raster_labels;
	TrialInfo_struct.Positions = Positions;
	TrialInfo_struct.resampled_frequency_Hz = LFP_resample_frequency_Hz;
	% TODO only look at those trials that are both in the report_struct
	% and in TDT recordings...
	TrialInfo_struct.report_struct = report_struct;
	TrialInfo_struct.lfp_info = lfp_info;
	tic
	save(fullfile(TDT_tank_FQN, '..', 'FieldTrip', [TDT_tank_ID, '.trialinfo.mat']), 'TrialInfo_struct');
	toc
	
	% store data for DAG's lfp_tfa harness
	lfp_tfa_event_offset = 1000; % what value to start SCP event types with, needsto match lfp_tfa_states
	lfp_tfa_dir = fullfile(TDT_tank_FQN, '..', 'lfp_tfa');
	lfp_tfa_sites_FN = ['sites_', session_id, '.mat'];
	recorded_side_string = 'A'; %which side of the set-up did the recorded subject act from/on?
	LFP_load_lfp_tfa_data = 1;
	fn_export_LFP_data_for_lfp_tfa(session_id, recorded_side_string, lfp_tfa_dir, lfp_tfa_sites_FN, lfp_data, lfp_info, lfp_events, trial_idx_per_event_list, trial_map, lfp_tfa_event_offset, LFP_resample_frequency_Hz, all_events_TDT_ts_struct, paradigm_state_info, TrialInfo_struct, LFP_load_lfp_tfa_data, TDT_tank_FQN);
	fn_export_events_as_lfp_tfa_global_define_state(lfp_events, lfp_tfa_dir, 'SCP_', lfp_tfa_event_offset);
end

if (export_LFP_only)
	% clean up
	timestamps.(mfilename).end = toc(timestamps.(mfilename).start);
	disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end), ' seconds.']);
	disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / 60), ' minutes. Done...']);
	return
end

% TODO:
% allow processing of spikes and LFPs, by turning the next into a function



% loop over all recorded channels
%TDT_tank_FQN
spike_channel_dir_struct = dir(fullfile(TDT_tank_FQN, spikefile_wildcard_string));
min_dataspike_bytes = 2 * 1000^2; % MB
cur_cluster_in_session_n = 0;

if (tuning_struct.analyse_tuning == 1)
	tuning_unit_ID_list = {};
	tuning_results = cell([length(tuning_struct.alignment_list), length(tuning_struct.label_list)]);
% 	for i_cell = 1 : length(tuning_results(:))
% 		tuning_results{i_cell} = struct();
% 	end
end

unit_count = 0;
for i_channel = 1 : length(spike_channel_dir_struct)
	% only process spike data above a certain size ()
	if ~(spike_channel_dir_struct(i_channel).isdir) && (spike_channel_dir_struct(i_channel).bytes >= min_dataspike_bytes)
		if ~isempty(debug_spikedata_file) && ~strcmp(spike_channel_dir_struct(i_channel).name, debug_spikedata_file)
			continue
		end
		disp(['Processing: ', spike_channel_dir_struct(i_channel).name]);
		channel_ID_string = spike_channel_dir_struct(i_channel).name(12:end-4);
		channel_ID_num = str2double(spike_channel_dir_struct(i_channel).name(14:16));
		channel_threshold_sign_string = spike_channel_dir_struct(i_channel).name(18:end-4);
		
		% load the data file
		cur_channel_spike_data = load(fullfile(spike_channel_dir_struct(i_channel).folder, spike_channel_dir_struct(i_channel).name));
		
		cluster_id_list = cur_channel_spike_data.cluster_class(:, 1);
		if (merge_all_cluster_ids)
			cluster_id_list(:) = 0;
		end
		
		
		if (merge_and_reject_cluster_ids) && ~isempty(spike_data_file_list)
			% find the current channel/sign index in the list of units
			cur_channel_idx = find(ismember(spike_data_file_list, spike_channel_dir_struct(i_channel).name));
			if ~isempty(cur_channel_idx)
				cur_merge_data = unit_merge_and_reject_array(cur_channel_idx, :);
				orig_cluster_id_list = cluster_id_list;
				for i_proto_units = 1 : numel(cur_merge_data)
					cur_orig_clusterID = i_proto_units -1; % zero based
					new_clusterID_value = cur_merge_data(i_proto_units);
					cur_orig_clusterID_idx = find(orig_cluster_id_list == cur_orig_clusterID);
					if ~isempty(cur_orig_clusterID_idx)
						cluster_id_list(cur_orig_clusterID_idx) = new_clusterID_value;
					end
				end
			end
		end
		
		unique_cluster_id_list = unique(cluster_id_list);
		n_cluster_ids = length(unique_cluster_id_list);
		
		for i_cluster_id = 1 : n_cluster_ids
			cur_cluster_id = unique_cluster_id_list(i_cluster_id);
			
			if ismember(cur_cluster_id, cluster_exclude_list)
				disp(['Current clusterID (', num2str(cur_cluster_id) , ') on the exclude list, skipping.']);
				continue
			end
			disp(['Processing cluster id: ', num2str(cur_cluster_id)]);
			cur_cluster_id_idx = find(cluster_id_list == cur_cluster_id);
			
			cur_raster_site_info.src_datafile =  spike_channel_dir_struct(i_channel).name;
			cur_raster_site_info.channel = channel_ID_num;
			cur_raster_site_info.clusterID = cur_cluster_id;
			unit_count = unit_count + 1;
			
			cur_cluster_in_session_n = cur_cluster_in_session_n +1;
			
			% pick the desired cluster, convert times from milliseconds to
			% the TDT time (seconds)
			spike_TDT_ts_list = cur_channel_spike_data.cluster_class(cur_cluster_id_idx, 2) / 1000;
			
			if (convert_TDT_ts_2_EvIDE_ts)
				% unlike the TDT time which is in seconds, the spike time
				% is in milliseconds so we need to adjust
				spike_TDT_ts_list = fn_convert_time_between_named_timebases((spike_TDT_ts_list), time_conversion_struct, 'TDT', 'EvIDE');
			end
			
			if (loop_over_choices_of_A)
				% alignment into helper function
				if (convert_TDT_ts_2_EvIDE_ts)
					reference_event_ts_list = selected_events_EvIDE_ts_struct;
				else
					reference_event_ts_list = selected_events_TDT_ts_struct;
				end
				reference_event_name_list = fieldnames(reference_event_ts_list);
				
				for i_reference_event = 1 : length(reference_event_name_list)
					reference_event_name = reference_event_name_list{i_reference_event};
					reference_event_ts = reference_event_ts_list.(reference_event_name);
					disp(['Plotting ', reference_event_name]);
					
					% check that the reference timestamps is larger than the trial's start Timestamp and smaller than the trials end time
					valid_reference_time_idx = fn_check_event_ts_with_trial_start_and_end_ts(reference_event_ts, report_struct);
					
					if (save_event_aligned_per_trial_1ms_histogram)
						% Formatted for  NDT toolbox consumption.
						PETH_struct = struct();
						% do something here to build a per trial "dot-raster" 1ms PETH, fill trials without events with NaNs
						PETH_struct = fn_create_per_trial_PETH(spike_TDT_ts_list, reference_event_ts, valid_reference_time_idx, reference_event_name, ...
							1, pre_event_dur_ms, post_event_dur_ms, NaN);
						% now save this out
						
						PETH_struct.raster_site_info = fn_add_structs(PETH_struct.raster_site_info, cur_raster_site_info);
						PETH_struct.raster_labels = cur_raster_labels;
						
						PETH_file_FQN = fullfile(TDT_sess_base_dir, 'PETHdata', reference_event_name, ...
							[session_id, '.', 'ch', num2str(channel_ID_num, '%03d'), '.', 'clu', num2str(cur_cluster_id, '%03d'), '.', channel_threshold_sign_string, '.', ...
							PETH_struct.raster_site_info.ID_string, '.mat']);
						if isempty(dir(fileparts(PETH_file_FQN)))
							mkdir(fileparts(PETH_file_FQN));
						end
						
						% analyse tuning
						if (tuning_struct.analyse_tuning == 1) && ismember(reference_event_name, tuning_struct.alignment_list)
							[tuning_unit_ID_list{end+1}, cur_tuning_result_struct, cur_tuning_result_struct_cell] = fn_estimate_tuning(PETH_struct, GoodTrialsIdx, tuning_struct, reference_event_name);
							
							%tuning_results{find(ismember(tuning_struct.alignment_list, reference_event_name))}(end+1)
							for i_tuning_labels = 1 : length(cur_tuning_result_struct_cell)
								if ~isempty(cur_tuning_result_struct_cell{i_tuning_labels})
									tuning_results{find(ismember(tuning_struct.alignment_list, reference_event_name)), i_tuning_labels}(end+1) = cur_tuning_result_struct_cell{i_tuning_labels};
								end
							end
						end
						
						if (save_generic_PETH)
							disp(['Saving: ', PETH_file_FQN]);
							save(PETH_file_FQN, 'PETH_struct');
						end
						%TODO generate PETHs for NDT, by excluding "bad"
						%trials and conditions with too few repetitions...
						if (export_PETH_as_raster_4_NDT)
							% exclude cur_raster_labels_numeric_fields
							if length(cur_raster_labels_numeric_fields) >= 1
								PETH_struct.raster_labels = rmfield(PETH_struct.raster_labels, cur_raster_labels_numeric_fields);
								PETH_raster_labels_names = cur_raster_labels_names;
								PETH_raster_labels_names = rmfield(PETH_raster_labels_names, cur_raster_labels_numeric_fields);
							end
							
							% numeric/idx labels
							if (NDT.export_labels_as_idx_and_header)
								PETH_struct.raster_labels = cur_numeric_raster_labels;
								PETH_raster_labels_names = cur_numeric_raster_labels_names;
							end
							
							% save the names of the labels to a file to make it easier to reference
							% them in the decode code.
							cur_raster_label_names = fieldnames(PETH_struct.raster_labels);
							% save list of label names to text file
							if isempty(dir(fullfile(TDT_sess_base_dir, 'PETHdata')))
								mkdir(fullfile(TDT_sess_base_dir, 'PETHdata'));
							end
							PETH_raster_label_file_FQN = fullfile(TDT_sess_base_dir, 'PETHdata', [session_id, '.', 'NDT.raster_label_list', '.txt']);
							disp(['Writing the list of raster_label names to: ', PETH_raster_label_file_FQN]);
							PETH_raster_label_file_fh = fopen(PETH_raster_label_file_FQN, 'w');
							fprintf(PETH_raster_label_file_fh, '%s\n', cur_raster_label_names{:});
							fclose(PETH_raster_label_file_fh);
							
							fn_export_PETH_struct_to_NDT_raster_format(GoodTrialsIdx, PETH_struct, PETH_file_FQN, NDT_raster_label_list, NDT_min_trials_per_label_item, PETH_raster_labels_names);
						end
						clear PETH_struct;
					end
					
					if (export_PETH_only)
						disp('Only exporting PETH data, no plot generation.');
						continue
					end
					
					if (~skip_plots)
						
						% require a minumum number of trials
						min_trials_with_event = 20;
						if (size(reference_event_ts, 1) - sum(reference_event_ts < 0)) < min_trials_with_event
							disp(['Skipping channel/clusterID due to less then ', min_trials_with_event, ' trials.']);
							continue
						end
						
						% variants are essentially copies of the main
						% multi-panel plot split by some category
						% prepare plots by diffGO category
						if ismember(reference_event_name, diffGoTimes_sensitive_event_set) && plot_separately_per_diffGo_category
							variant_struct.trial_cat_list = cur_diffGo_trial_cat_list;
							variant_struct.cat_name_list = cur_diffGo_trail_cat_name_list;
							variant_struct.suffix_string = '_diffGO';
						else
							% all trials in one group
							variant_struct.trial_cat_list = ones(size(diffGo_trial_cat_list));
							variant_struct.cat_name_list = {''};
							variant_struct.suffix_string = '';
						end
						
						% define trial indices and names for the individual panels
						panel_struct.trial_cat_list = A_ordered_selected_position_idx;
						panel_struct.cat_name_list = A_ordered_selected_positions;
						panel_struct.ordered_panel_labels = ordered_position_labels;
						panel_struct.description = 'by A''s spatial choice';
						
						info_struct.channel_ID_string = channel_ID_string;
						info_struct.cur_cluster_id = cur_cluster_id;
						
						
						% here we want to plot data aligned to 'A_InitialFixationReleaseTime_ms' and 'B_InitialFixationReleaseTime_ms'
						% in on plot, columns: LEFT RIGHT; rows: alignment
						% points
						% TODO convert in generalized alignment/reference_event concatenator
						if (SFB_2021) && strcmp(reference_event_name, 'A_InitialFixationReleaseTime_ms')
							% this can potentially be repeated
							[concat_trial_color_linestyle_struct, concat_reference_event_name, concat_reference_event_ts, concat_valid_reference_time_idx, concat_GoodTrialsIdx, concat_variant_struct, concat_panel_struct] = fn_concatenate_reference_events_as_panels(...
								TrialSubType_ByDiffGo_struct, TrialSubType_ByDiffGo_struct, 'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms', ...
								reference_event_ts_list.('A_InitialFixationReleaseTime_ms'), reference_event_ts_list.('B_InitialFixationReleaseTime_ms'), GoodTrialsIdx, GoodTrialsIdx, variant_struct, variant_struct, panel_struct, panel_struct, report_struct);
							
							plot_N_variants_of_M_panels_by_trial_catstruct(concat_variant_struct, concat_panel_struct, info_struct, ...
								concat_GoodTrialsIdx, spike_TDT_ts_list, concat_reference_event_name, concat_reference_event_ts, concat_valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
								concat_trial_color_linestyle_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
								scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
							
							
							[concat_trial_color_linestyle_struct, concat_reference_event_name, concat_reference_event_ts, concat_valid_reference_time_idx, concat_GoodTrialsIdx, concat_variant_struct, concat_panel_struct] = fn_concatenate_reference_events_as_panels(...
								dyadic_sameness_ByDiffGo_struct, dyadic_sameness_ByDiffGo_struct, 'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms', ...
								reference_event_ts_list.('A_InitialFixationReleaseTime_ms'), reference_event_ts_list.('B_InitialFixationReleaseTime_ms'), GoodTrialsIdx, GoodTrialsIdx, variant_struct, variant_struct, panel_struct, panel_struct, report_struct);
							
							plot_N_variants_of_M_panels_by_trial_catstruct(concat_variant_struct, concat_panel_struct, info_struct, ...
								concat_GoodTrialsIdx, spike_TDT_ts_list, concat_reference_event_name, concat_reference_event_ts, concat_valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
								concat_trial_color_linestyle_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
								scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
							
						end
						if (SFB_2021) && strcmp(reference_event_name, 'FIRST_InitialFixationReleaseTime_ms')
							% this can potentially be repeated
							[concat_trial_color_linestyle_struct, concat_reference_event_name, concat_reference_event_ts, concat_valid_reference_time_idx, concat_GoodTrialsIdx, concat_variant_struct, concat_panel_struct] = fn_concatenate_reference_events_as_panels(...
								TrialSubType_ByDiffGo_struct, TrialSubType_ByDiffGo_struct, 'FIRST_InitialFixationReleaseTime_ms', 'SECOND_InitialFixationReleaseTime_ms', ...
								reference_event_ts_list.('FIRST_InitialFixationReleaseTime_ms'), reference_event_ts_list.('SECOND_InitialFixationReleaseTime_ms'), GoodTrialsIdx, GoodTrialsIdx, variant_struct, variant_struct, panel_struct, panel_struct, report_struct);
							
							plot_N_variants_of_M_panels_by_trial_catstruct(concat_variant_struct, concat_panel_struct, info_struct, ...
								concat_GoodTrialsIdx, spike_TDT_ts_list, concat_reference_event_name, concat_reference_event_ts, concat_valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
								concat_trial_color_linestyle_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
								scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
						end
						
						if (SFB_2021) && strcmp(reference_event_name, 'FIRST_TargetTouchTime_ms')
							% this can potentially be repeated
							[concat_trial_color_linestyle_struct, concat_reference_event_name, concat_reference_event_ts, concat_valid_reference_time_idx, concat_GoodTrialsIdx, concat_variant_struct, concat_panel_struct] = fn_concatenate_reference_events_as_panels(...
								TrialSubType_ByDiffGo_struct, TrialSubType_ByDiffGo_struct, 'FIRST_TargetTouchTime_ms', 'SECOND_TargetTouchTime_ms', ...
								reference_event_ts_list.('FIRST_TargetTouchTime_ms'), reference_event_ts_list.('SECOND_TargetTouchTime_ms'), GoodTrialsIdx, GoodTrialsIdx, variant_struct, variant_struct, panel_struct, panel_struct, report_struct);
							
							plot_N_variants_of_M_panels_by_trial_catstruct(concat_variant_struct, concat_panel_struct, info_struct, ...
								concat_GoodTrialsIdx, spike_TDT_ts_list, concat_reference_event_name, concat_reference_event_ts, concat_valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
								concat_trial_color_linestyle_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
								scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
						end
						
						
						if (plot_dyadic_solo_choice_combination)
							% start as script and turn into function next
							if (plot_diffGo_categories_as_lines)
								plot_N_variants_of_M_panels_by_trial_catstruct(variant_struct, panel_struct, info_struct, ...
									GoodTrialsIdx, spike_TDT_ts_list, reference_event_name, reference_event_ts, valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
									dyadic_solo_choice_combination_ByDiffGo_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
									scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
							else
								plot_N_variants_of_M_panels_by_trial_catstruct(variant_struct, panel_struct, info_struct, ...
									GoodTrialsIdx, spike_TDT_ts_list, reference_event_name, reference_event_ts, valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
									dyadic_solo_choice_combination_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
									scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
							end
						end
						
						if (plot_TrialSubType)
							if (numel(unique(TrialSubType_ByDiffGo_list(GoodTrialsIdx))) > 1)
								stat_struct_per_category_per_panel_per_event_per_cluster_list{unit_count, i_reference_event} = plot_N_variants_of_M_panels_by_trial_catstruct(variant_struct, panel_struct, info_struct, ...
									GoodTrialsIdx, spike_TDT_ts_list, reference_event_name, reference_event_ts, valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
									TrialSubType_ByDiffGo_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
									scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
							end
						end
						
						if (plot_conf_predictability)
							if (plot_diffGo_categories_as_lines)
								if (numel(unique(conf_predictability_dyadic_choice_combination_ByDiffGo_list(GoodTrialsIdx))) > 1)
									plot_N_variants_of_M_panels_by_trial_catstruct(variant_struct, panel_struct, info_struct, ...
										GoodTrialsIdx, spike_TDT_ts_list, reference_event_name, reference_event_ts, valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
										conf_predictability_dyadic_choice_combination_ByDiffGo_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
										scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
								end
							else
								if (numel(unique(conf_predictability_list(GoodTrialsIdx))) > 1)
									plot_N_variants_of_M_panels_by_trial_catstruct(variant_struct, panel_struct, info_struct, ...
										GoodTrialsIdx, spike_TDT_ts_list, reference_event_name, reference_event_ts, valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
										conf_predictability_dyadic_choice_combination_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
										scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
								end
							end
						end
						
						if (plot_dyadic_solo_choice_combination_ByVisibility)
							if ~isempty(TrialSets.ByVisibility.AB_invisible)
								plot_N_variants_of_M_panels_by_trial_catstruct(variant_struct, panel_struct, info_struct, ...
									GoodTrialsIdx, spike_TDT_ts_list, reference_event_name, reference_event_ts, valid_reference_time_idx, bin_width_ms, pre_event_dur_ms, post_event_dur_ms, ...
									dyadic_solo_choice_combination_ByVisibility_struct, convolution_kernel_type, PETH_ci_alpha, PETH_plot_VAR_by_cat_measure, raster_type, ...
									scale_raster, scale_peth, TDT_sess_base_dir, plot_opt_struct);
							end
						end
					end
				end
			end
		end
	end
end

% now plot the tuning somehow
if (tuning_struct.analyse_tuning == 1)
	% try scatter plot for pre and post: tuning_unit_ID_list, tuning_results
	for i_tuning_alignment = 1 : length(tuning_struct.alignment_list)
			
		cur_tuning_results = tuning_results{i_tuning_alignment};
		cur_tuning_alignment_name = tuning_struct.alignment_list{i_tuning_alignment};

		if isempty(cur_tuning_results) || isempty(fieldnames(cur_tuning_results))
			disp(['No tuning analysis data for ', cur_tuning_alignment_name, ' skipping...']);
			continue
		end
		
		
		pre.val = vertcat(cur_tuning_results.pre_right_index);
		pre.p = vertcat(cur_tuning_results.pre_p);
		post.val = vertcat(cur_tuning_results.post_right_index);
		post.p = vertcat(cur_tuning_results.post_p);
		tuning_struct.sigthreshold = 0.05;
		
		pre_diff_sig_idx = find(pre.p <= tuning_struct.sigthreshold);
		post_diff_sig_idx = find(post.p <= tuning_struct.sigthreshold);
		
		edge_list = (-1:0.05:1);
		
		% as tiledplot
		tunig_fh = figure('Name', ['Tuning: ', session_id]);
		th = tiledlayout(1,2);
		
		left_ah = nexttile(th, 1);
		left_hh = histogram(left_ah, pre.val, edge_list);
		hold on
		histogram(left_ah, pre.val(pre_diff_sig_idx), edge_list);
		hold off
		fn_overlay_vertical_lines(left_ah, median(pre.val, 'omitnan'));
		title('pre reach onset', 'Interpreter', 'none');
		xticks([-1, -0.5, 0.0, 0.5, 1]);
		xlim([-1, 1]);
		
		right_ah = nexttile(th, 2);
		right_hh = histogram(right_ah, post.val, edge_list);
		hold on
		histogram(right_ah, post.val(post_diff_sig_idx), edge_list);
		hold off
		fn_overlay_vertical_lines(right_ah, median(post.val, 'omitnan'));
		title('post reach onset', 'Interpreter', 'none');
		xticks([-1, -0.5, 0.0, 0.5, 1]);
		xlim([-1, 1]);
		
		title(th, {'Left - Right tuning'});
		subtitle(th, {['Session: ', session_id], cur_tuning_alignment_name}, 'Interpreter', 'none', 'FontSize', 8);
		ylabel(th, 'Count');
		xlabel(th, 'left(-1)/righ(1) index', 'Interpreter', 'none');
		
		write_out_figure(tunig_fh, fullfile(TDT_sess_base_dir, 'Plots', [session_id, '.', cur_tuning_alignment_name, '.left-right_tuning', '.pdf']));
	end
end

% now do something with the collected average
% per_categegory_per_position_per_cluster data

if exist('stat_struct_per_category_per_panel_per_event_per_cluster_list', 'var')
	pop_summary_stats_FQN = fullfile(TDT_sess_base_dir, 'PETHdata', 'POPAVG', ['popavg', TrialSubType_ByDiffGo_struct.plot_identifier_string, '.mat']);
	pop_struct = struct();
	pop_struct.info_struct = info_struct;
	pop_struct.binning_info.bin_width_ms = bin_width_ms;
	pop_struct.binning_info.pre_event_dur_ms = pre_event_dur_ms;
	pop_struct.binning_info.post_event_dur_ms = post_event_dur_ms;
	pop_struct.catstruct = TrialSubType_ByDiffGo_struct;	% this needs to be more automatic
	pop_struct.stat_struct_per_category_per_panel_per_event_per_cluster_list = stat_struct_per_category_per_panel_per_event_per_cluster_list;
	pop_struct.reference_event_name_list = reference_event_name_list;
	pop_struct.variant_struct = variant_struct;
	pop_struct.panel_struct = panel_struct;
	if ~isfolder(fileparts(pop_summary_stats_FQN))
		mkdir(fileparts(pop_summary_stats_FQN))
	end
	save(fullfile(pop_summary_stats_FQN), 'pop_struct', '-v7.3');
end

if exist('pop_summary_stats_FQN', 'var') && exist('pop_summary_stats_FQN', 'file')
	[pop_path, pop_name, pop_ext] = fileparts(pop_summary_stats_FQN);
	pop_ouput_path = fullfile(pop_path, '..', '..');
	for i_reference_event = 1 : length(reference_event_name_list)
		reference_event_name = reference_event_name_list{i_reference_event};
		disp(['Plotting population result for ', reference_event_name]);
		fn_average_over_summary_stats_by_unit_by_cat(pop_struct, pop_ouput_path, 'zscore', 'gaussian', bin_width_ms, 'sem', 0.05, plot_opt_struct);
	end
end


close all;

% clean up
timestamps.(mfilename).end = toc(timestamps.(mfilename).start);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end), ' seconds.']);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / 60), ' minutes. Done...']);

if (NDT.start_decode)
	disp('Starting fn_NDT_decode')
	fn_NDT_decode(session_ID, NDT.alignment_event_list, NDT.labels_list, NDT.bin_width, NDT.step_size);
end

return
end