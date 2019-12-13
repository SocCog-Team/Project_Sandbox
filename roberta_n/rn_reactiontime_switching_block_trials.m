 function [Cur_fh_RTbyChoiceCombinationSwitches_blocked,Cur_fh_RTbyChoiceCombinationSwitches_unblocked merged_classifier_char_string] = rn_reactiontime_switching_block_trials(sessionID_list)

if ~exist('fileID', 'var') || isempty(fileID)
	fileID= '20190320T095244.A_Elmo.B_JK.SCP_01';
end

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
% 
% year_string = fileID(1:4);
% date_string = fileID(3:8);
% 
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, [fileID, '.sessiondir']);
% saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN', [fileID, '.sessiondir']);
% output_dir = pwd;
% 
% 
% sessionID_list = {'20190320T095244.A_Elmo.B_JK.SCP_01',...
% 	'20190321T083454.A_Elmo.B_JK.SCP_01',...
% 	'20190322T083726.A_Elmo.B_JK.SCP_01',...
% 	'20190329T112049.A_Elmo.B_SM.SCP_01',...
% 	'20190403T090741.A_Elmo.B_JK.SCP_01',...
% 	'20190404T090735.A_Elmo.B_JK.SCP_01'};

per_session_trialnumber_offset = 10000;
for i_session = 1 : length(sessionID_list)
	cur_per_session_trialnumber_offset = per_session_trialnumber_offset * i_session;
	fileID = sessionID_list{i_session};
	sessionID = sessionID_list{i_session};
	
	year_string = sessionID(1:4);
	date_string = sessionID(3:8);
	
	session_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string , date_string , [sessionID, '.sessiondir']);
	
	
	% 	if exist(fullfile(data_dir, [sessionID, '.triallog.v012.mat']), 'file')
	% 		maintask_datastruct=load(fullfile(session_dir, [sessionID, '.triallog.v012.mat']));
	% 	else
	tmp_maintask_datastruct = fnParseEventIDEReportSCPv06(fullfile(session_dir, [sessionID, '.triallog']));
	tmp_DataStruct = tmp_maintask_datastruct.report_struct;
	% 	end
	
	if (length(sessionID_list) > 1)
		trialnum_col = tmp_maintask_datastruct.report_struct.cn.TrialNumber;
		tmp_DataStruct.data(:, trialnum_col) = tmp_DataStruct.data(:, trialnum_col) + cur_per_session_trialnumber_offset;
	end
	
	if (i_session == 1)
		DataStruct = tmp_DataStruct;
	else
		DataStruct.data = [DataStruct.data; tmp_DataStruct.data];
	end
end

maintask_datastruct.report_struct = DataStruct;

[ModifiedTrialSets] = rn_segregateTrialData(maintask_datastruct);


full_choice_combinaton_pattern_list = {'RM', 'MR', 'BM', 'MB', 'RB', 'BR', 'RG', 'GR', 'BG', 'GB', 'GM', 'MG'};
selected_choice_combinaton_pattern_list = {'RM', 'MR', 'BM', 'MB', 'RB', 'BR'};
pattern_alignment_offset = 1; % the offset to the position
n_pre_bins = 3;
n_post_bins = 3;
strict_pattern_extension = 1;
pad_mismatch_with_nan = 1;
aggregate_type_meta_list = {'nan_padded'}; %  {'nan_padded', 'raw'}, the raw looks like the 1st derivation
InvisibleFigures = 0;


% reaction times
A_InitialTargetReleaseRT = DataStruct.data(:, DataStruct.cn.A_InitialFixationReleaseTime_ms) - DataStruct.data(:, DataStruct.cn.A_TargetOnsetTime_ms);
B_InitialTargetReleaseRT = DataStruct.data(:, DataStruct.cn.B_InitialFixationReleaseTime_ms) - DataStruct.data(:, DataStruct.cn.B_TargetOnsetTime_ms);
A_TargetAcquisitionRT = DataStruct.data(:, DataStruct.cn.A_TargetTouchTime_ms) - DataStruct.data(:, DataStruct.cn.A_TargetOnsetTime_ms);
B_TargetAcquisitionRT = DataStruct.data(:, DataStruct.cn.B_TargetTouchTime_ms) - DataStruct.data(:, DataStruct.cn.B_TargetOnsetTime_ms);

% InitialTargetRelease reaction time plus half of the movement time
A_IniTargRel_05MT_RT = A_InitialTargetReleaseRT + 0.5 * (A_TargetAcquisitionRT - A_InitialTargetReleaseRT);
B_IniTargRel_05MT_RT = B_InitialTargetReleaseRT + 0.5 * (B_TargetAcquisitionRT - B_InitialTargetReleaseRT);

A_RT_data = A_IniTargRel_05MT_RT;
B_RT_data = B_IniTargRel_05MT_RT;

ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial = ModifiedTrialSets.ByJointness.DualSubjectJointTrials
LastJointTrial = length(ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial);
ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial(LastJointTrial) = NaN;
Joint_choicetargets = intersect(ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial, ModifiedTrialSets.ByChoices.NumChoices02);
bothrewarded = intersect(ModifiedTrialSets.ByOutcome.SideA.REWARD, ModifiedTrialSets.ByOutcome.SideB.REWARD);

SuccessfulChoiceTrials=intersect(Joint_choicetargets,bothrewarded);
SuccessfulChoiceTrials_block = intersect(SuccessfulChoiceTrials, ModifiedTrialSets.ByVisibility.AB_invisible);
SuccessfulChoiceTrials_unblock= setdiff(SuccessfulChoiceTrials, SuccessfulChoiceTrials_block);

A_Own_B_Other = intersect(ModifiedTrialSets.ByChoice.SideA.TargetValueHigh, ModifiedTrialSets.ByChoice.SideB.TargetValueLow);
A_Other_B_Own = intersect(ModifiedTrialSets.ByChoice.SideA.TargetValueLow, ModifiedTrialSets.ByChoice.SideB.TargetValueHigh);
A_Own_B_Own = intersect(ModifiedTrialSets.ByChoice.SideA.TargetValueHigh, ModifiedTrialSets.ByChoice.SideB.TargetValueHigh);
A_Other_B_Other = intersect(ModifiedTrialSets.ByChoice.SideA.TargetValueLow, ModifiedTrialSets.ByChoice.SideB.TargetValueLow);


%create a string with our color representations of the 4 choice combinations
NumTrials = size(maintask_datastruct.report_struct.data(:,2));
PreferableTargetSelected_B= zeros([NumTrials, 1]);
PreferableTargetSelected_B(ModifiedTrialSets.ByChoice.SideB.ProtoTargetValueHigh) = 1;

choice_combination_color_string = char(PreferableTargetSelected_B);
choice_combination_color_string(A_Own_B_Other) = 'R';
choice_combination_color_string(A_Other_B_Own) = 'B';
choice_combination_color_string(A_Own_B_Own) = 'M';
choice_combination_color_string(A_Other_B_Other) = 'G';
choice_combination_color_string = (choice_combination_color_string)';

SideA_pattern_histogram_struct_blocked = fn_build_PSTH_by_switch_trial_struct(SuccessfulChoiceTrials_block, choice_combination_color_string, full_choice_combinaton_pattern_list, A_RT_data, pattern_alignment_offset, n_pre_bins, n_post_bins, strict_pattern_extension, pad_mismatch_with_nan);
SideB_pattern_histogram_struct_blocked = fn_build_PSTH_by_switch_trial_struct(SuccessfulChoiceTrials_block, choice_combination_color_string, full_choice_combinaton_pattern_list, B_RT_data, pattern_alignment_offset, n_pre_bins, n_post_bins, strict_pattern_extension, pad_mismatch_with_nan);
SideA_pattern_histogram_struct_unblocked =  fn_build_PSTH_by_switch_trial_struct(SuccessfulChoiceTrials_unblock, choice_combination_color_string, full_choice_combinaton_pattern_list, A_RT_data, pattern_alignment_offset, n_pre_bins, n_post_bins, strict_pattern_extension, pad_mismatch_with_nan);
SideB_pattern_histogram_struct_unblocked = fn_build_PSTH_by_switch_trial_struct(SuccessfulChoiceTrials_unblock, choice_combination_color_string, full_choice_combinaton_pattern_list, B_RT_data, pattern_alignment_offset, n_pre_bins, n_post_bins, strict_pattern_extension, pad_mismatch_with_nan);


SideAColor = [1 0 0];
SideBColor = [0 0 1];

if (InvisibleFigures)
	figure_visibility_string = 'off';
else
	figure_visibility_string = 'on';
end


for i_aggregate_meta_type = 1 : length(aggregate_type_meta_list)
	current_aggregate_type = aggregate_type_meta_list{i_aggregate_meta_type};
	if ~isempty(SideB_pattern_histogram_struct_blocked) || ~isempty(SideB_pattern_histogram_struct_blocked)
		% now create a plot showing these transitions for both
		% agents
		Cur_fh_RTbyChoiceCombinationSwitches_blocked = figure('Name', ['RT histogram over choice combination switches blocked trials: ', current_aggregate_type], 'visible', figure_visibility_string);
		%fnFormatDefaultAxes(DefaultAxesType);
		%[output_rect] = fnFormatPaperSize(DefaultPaperSizeType, gcf, output_rect_fraction);
		%set(gcf(), 'Units', 'centimeters', 'Position', output_rect, 'PaperPosition', output_rect, 'PaperPosition', output_rect );
		
		RT_by_switch_struct_list = {SideA_pattern_histogram_struct_blocked, SideB_pattern_histogram_struct_blocked};
		RT_by_switch_title_prefix_list = {'A: ', 'B: '};
		RT_by_switch_switch_pre_bins_list = {n_pre_bins, n_pre_bins};
		RT_by_switch_switch_n_bins_list = {(n_pre_bins + 1 + n_post_bins), (n_pre_bins + 1 + n_post_bins)};
		%		RT_by_switch_color_list = {orange, green};
		RT_by_switch_color_list = {SideAColor, SideBColor};
		aggregate_type_list = {current_aggregate_type, current_aggregate_type};
		
		
		[Cur_fh_RTbyChoiceCombinationSwitches_blocked, merged_classifier_char_string] = fn_plot_RT_histogram_by_switches(Cur_fh_RTbyChoiceCombinationSwitches_blocked , RT_by_switch_struct_list, selected_choice_combinaton_pattern_list, RT_by_switch_title_prefix_list, RT_by_switch_switch_pre_bins_list, RT_by_switch_switch_n_bins_list, RT_by_switch_color_list, aggregate_type_list);
	end
	
end

for i_aggregate_meta_type = 1 : length(aggregate_type_meta_list)
	current_aggregate_type = aggregate_type_meta_list{i_aggregate_meta_type};
	if ~isempty(SideA_pattern_histogram_struct_unblocked) || ~isempty(SideB_pattern_histogram_struct_unblocked)
		% now create a plot showing these transitions for both
		% agents
		Cur_fh_RTbyChoiceCombinationSwitches_unblocked = figure('Name', ['RT histogram over choice combination switches unblocked trials: ', current_aggregate_type], 'visible', figure_visibility_string);
		%fnFormatDefaultAxes(DefaultAxesType);
		%[output_rect] = fnFormatPaperSize(DefaultPaperSizeType, gcf, output_rect_fraction);
		%set(gcf(), 'Units', 'centimeters', 'Position', output_rect, 'PaperPosition', output_rect, 'PaperPosition', output_rect );
		
		RT_by_switch_struct_list = {SideA_pattern_histogram_struct_unblocked, SideB_pattern_histogram_struct_unblocked};
		RT_by_switch_title_prefix_list = {'A: ', 'B: '};
		RT_by_switch_switch_pre_bins_list = {n_pre_bins, n_pre_bins};
		RT_by_switch_switch_n_bins_list = {(n_pre_bins + 1 + n_post_bins), (n_pre_bins + 1 + n_post_bins)};
		%RT_by_switch_color_list = {orange, green};
		RT_by_switch_color_list = {SideAColor, SideBColor};
		aggregate_type_list = {current_aggregate_type, current_aggregate_type};
		
		
		[Cur_fh_RTbyChoiceCombinationSwitches_unblocked, merged_classifier_char_string] = fn_plot_RT_histogram_by_switches(Cur_fh_RTbyChoiceCombinationSwitches_unblocked, RT_by_switch_struct_list, selected_choice_combinaton_pattern_list, RT_by_switch_title_prefix_list, RT_by_switch_switch_pre_bins_list, RT_by_switch_switch_n_bins_list, RT_by_switch_color_list, aggregate_type_list);
	end
end


return
end