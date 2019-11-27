function [maintask_datastruct, data_struct_extract, touchtracker_datastructA, touchtracker_datastructB, recalibration_struct] = fn_merging_session( sessionID_list, gazereg_list  )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

data_root_str = fullfile('C:', 'SCP');

% network!
data_base_dir = fullfile('Y:');
offset = 100000000;


for i_session = 1 : length(sessionID_list)
	%fileID = sessionID_list{i_session};
	sessionID = sessionID_list{i_session};
	year_string = sessionID(1:4);
	date_string = sessionID(3:8);
	per_session_offset = (i_session - 1) * offset;
	session_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string , date_string , [sessionID, '.sessiondir']);
	
	
	tmp_maintask_datastruct = fnParseEventIDEReportSCPv06(fullfile(session_dir, [sessionID, '.triallog']));
	tmp_main_dataStruct = tmp_maintask_datastruct.report_struct;
	
	EyeLinkfilenameA= fullfile(session_dir, 'trackerlogfiles', [sessionID, '.TID_EyeLinkProxyTrackerA.trackerlog']);
	tmp_data_struct_extract = fnParseEventIDETrackerLog_v01 (EyeLinkfilenameA, ';', [], []);
	tmp_dataStruct = tmp_data_struct_extract;
	
	PQtrackerfilenameA = fullfile(session_dir, 'trackerlogfiles', [sessionID, '.TID_PQLabTrackerA.trackerlog']);
	tmp_touchtracker_A_datastruct = fnParseEventIDETrackerLog_v01 (PQtrackerfilenameA, ';', [], []);
	tmp_touch_A = tmp_touchtracker_A_datastruct;
	
	PQtrackerfilenameB = fullfile(session_dir, 'trackerlogfiles', [sessionID, '.TID_SecondaryPQLabTrackerB.trackerlog']);
	tmp_touchtracker_B_datastruct=fnParseEventIDETrackerLog_v01 (PQtrackerfilenameB, ';', [], []);
	tmp_touch_B = tmp_touchtracker_B_datastruct;
	
	
	gazereg_ID = gazereg_list{i_session};
	year_string_gaze_reg = gazereg_ID(13:16);
	date_string_gaze_reg = gazereg_ID(15:20);
	%per_gaze_reg_offset = (i_gaze_reg - 1) * offset;
	
	registered_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string_gaze_reg , date_string_gaze_reg);
	t_form = load(fullfile(registered_dir, [gazereg_ID]));
	reg_left_eye = transformPointsInverse(t_form.registration_struct.polynomial.Left_Eye_Raw.tform, [(tmp_dataStruct.data(:,tmp_dataStruct.cn.Left_Eye_Raw_X)) (tmp_dataStruct.data(:,tmp_dataStruct.cn.Left_Eye_Raw_Y))]);
	reg_right_eye = transformPointsInverse(t_form.registration_struct.polynomial.Right_Eye_Raw.tform, [(tmp_dataStruct.data(:,tmp_dataStruct.cn.Right_Eye_Raw_X)) (tmp_dataStruct.data(:,tmp_dataStruct.cn.Right_Eye_Raw_Y))]);
	
	
	tmp_recalibration_struct = struct ();
	tmp_recalibration_struct.header = {'TrialNumber', 'CorrectedTimeStamps', 'Left_Eye_x', 'Left_Eye_y', 'Right_Eye_x', 'Right_Eye_y'};
	
	tmp_recalibration_struct.cn = local_get_column_name_indices(tmp_recalibration_struct.header); %struct(field1,value1,field2,value2,field3,value3,field4,value4, field5, value5, field6, value6);
	
	tmp_recalibration_struct.data = horzcat (tmp_dataStruct.data(:, tmp_dataStruct.cn.TrialNumber) + per_session_offset, tmp_dataStruct.data(:,tmp_dataStruct.cn.Tracker_corrected_EventIDE_TimeStamp) + per_session_offset,...
		reg_left_eye(:,1),reg_left_eye(:,2) , reg_right_eye(:,1),reg_right_eye(:,2));
	
	
	
	
	if (length(sessionID_list) > 1)
		
		trialnum_col_maintask = tmp_maintask_datastruct.report_struct.cn.TrialNumber;
		tmp_main_dataStruct.data(:, trialnum_col_maintask) = tmp_main_dataStruct.data(:, trialnum_col_maintask) + per_session_offset;
		
		timestamps_col_maintask = tmp_maintask_datastruct.report_struct.cn.Timestamp;
		tmp_main_dataStruct.data(:,timestamps_col_maintask) = tmp_main_dataStruct.data(:,timestamps_col_maintask) + per_session_offset;
		
		timestamps_col_A_abort_time_maintask = tmp_maintask_datastruct.report_struct.cn.A_AbortTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_abort_time_maintask) = tmp_main_dataStruct.data(:,timestamps_col_A_abort_time_maintask) + per_session_offset;
		
		timestamps_col_A_IFOnset_maintask = tmp_maintask_datastruct.report_struct.cn.A_InitialFixationOnsetTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_IFOnset_maintask) = tmp_main_dataStruct.data(:,timestamps_col_A_IFOnset_maintask) + per_session_offset;
		
		timestamps_col_A_hold_release_maintask = tmp_maintask_datastruct.report_struct.cn.A_HoldReleaseTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_hold_release_maintask) = tmp_main_dataStruct.data(:,timestamps_col_A_hold_release_maintask) + per_session_offset;
		
		timestamps_col_A_IFTouchmaintask = tmp_maintask_datastruct.report_struct.cn.A_InitialFixationTouchTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_IFTouchmaintask) = tmp_main_dataStruct.data(:,timestamps_col_A_IFTouchmaintask) + per_session_offset;
		
		timestamps_col_A_IFReleasemaintask = tmp_maintask_datastruct.report_struct.cn.A_InitialFixationReleaseTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_IFReleasemaintask) = tmp_main_dataStruct.data(:,timestamps_col_A_IFReleasemaintask) + per_session_offset;
		
		timestamps_col_A_IFAdjRelease_maintask = tmp_maintask_datastruct.report_struct.cn.A_InitialFixationAdjReleaseTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_IFAdjRelease_maintask) = tmp_main_dataStruct.data(:,timestamps_col_A_IFAdjRelease_maintask) + per_session_offset;
		
		timestamps_col_A_TargetOnset_maintask = tmp_maintask_datastruct.report_struct.cn.A_TargetOnsetTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_TargetOnset_maintask) = tmp_main_dataStruct.data(:,timestamps_col_A_TargetOnset_maintask) + per_session_offset;
		
		timestamps_col_A_TargetTouch_maintask = tmp_maintask_datastruct.report_struct.cn.A_TargetTouchTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_TargetTouch_maintask) = tmp_main_dataStruct.data(:,timestamps_col_A_TargetTouch_maintask) + per_session_offset;
		
		timestamps_col_A_TargetOffset_maintask = tmp_maintask_datastruct.report_struct.cn.A_TargetOffsetTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_TargetOffset_maintask) = tmp_main_dataStruct.data(:,timestamps_col_A_TargetOffset_maintask) + per_session_offset;
		
		timestamps_col_A_TmpTouchRelease_maintask = tmp_maintask_datastruct.report_struct.cn.A_TmpTouchReleaseTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_A_TmpTouchRelease_maintask) = tmp_main_dataStruct.data(:,timestamps_col_A_TmpTouchRelease_maintask) + per_session_offset;
		
		timestamps_col_B_abort_time_maintask = tmp_maintask_datastruct.report_struct.cn.B_AbortTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_abort_time_maintask) = tmp_main_dataStruct.data(:,timestamps_col_B_abort_time_maintask) + per_session_offset;
		
		timestamps_col_B_IFOnset_maintask = tmp_maintask_datastruct.report_struct.cn.B_InitialFixationOnsetTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_IFOnset_maintask) = tmp_main_dataStruct.data(:,timestamps_col_B_IFOnset_maintask) + per_session_offset;
		
		timestamps_col_B_hold_release_maintask = tmp_maintask_datastruct.report_struct.cn.B_HoldReleaseTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_hold_release_maintask) = tmp_main_dataStruct.data(:,timestamps_col_B_hold_release_maintask) + per_session_offset;
		
		timestamps_col_B_IFTouchmaintask = tmp_maintask_datastruct.report_struct.cn.B_InitialFixationTouchTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_IFTouchmaintask) = tmp_main_dataStruct.data(:,timestamps_col_B_IFTouchmaintask) + per_session_offset;
		
		timestamps_col_B_IFReleasemaintask = tmp_maintask_datastruct.report_struct.cn.B_InitialFixationReleaseTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_IFReleasemaintask) = tmp_main_dataStruct.data(:,timestamps_col_B_IFReleasemaintask) + per_session_offset;
		
		timestamps_col_B_IFAdjRelease_maintask = tmp_maintask_datastruct.report_struct.cn.B_InitialFixationAdjReleaseTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_IFAdjRelease_maintask) = tmp_main_dataStruct.data(:,timestamps_col_B_IFAdjRelease_maintask) + per_session_offset;
		
		timestamps_col_B_TargetOnset_maintask = tmp_maintask_datastruct.report_struct.cn.B_TargetOnsetTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_TargetOnset_maintask) = tmp_main_dataStruct.data(:,timestamps_col_B_TargetOnset_maintask) + per_session_offset;
		
		timestamps_col_B_TargetTouch_maintask = tmp_maintask_datastruct.report_struct.cn.B_TargetTouchTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_TargetTouch_maintask) = tmp_main_dataStruct.data(:,timestamps_col_B_TargetTouch_maintask) + per_session_offset;
		
		timestamps_col_B_TargetOffset_maintask = tmp_maintask_datastruct.report_struct.cn.B_TargetOffsetTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_TargetOffset_maintask) = tmp_main_dataStruct.data(:,timestamps_col_B_TargetOffset_maintask) + per_session_offset;
		
		timestamps_col_B_TmpTouchRelease_maintask = tmp_maintask_datastruct.report_struct.cn.B_TmpTouchReleaseTime_ms;
		tmp_main_dataStruct.data(:,timestamps_col_B_TmpTouchRelease_maintask) = tmp_main_dataStruct.data(:,timestamps_col_B_TmpTouchRelease_maintask) + per_session_offset;
		
		
		trialnum_col_gaze = tmp_data_struct_extract.cn.TrialNumber;
		tmp_dataStruct.data(:, trialnum_col_gaze) = tmp_dataStruct.data(:, trialnum_col_gaze) + per_session_offset;
		
		timestamps_col_gaze = tmp_data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp;
		tmp_dataStruct.data(:,timestamps_col_gaze) = tmp_dataStruct.data(:,timestamps_col_gaze) + per_session_offset;
		
		
		trialnum_col_touch_A = tmp_touch_A.cn.TrialNum;
		tmp_touch_A.data(:, trialnum_col_touch_A) = tmp_touch_A.data(:, trialnum_col_touch_A) + per_session_offset;
		
		timestamps_col_touch_A = tmp_touch_A.cn.Tracker_corrected_EventIDE_TimeStamp;
		tmp_touch_A.data(:,timestamps_col_touch_A) = tmp_touch_A.data(:,timestamps_col_touch_A) + per_session_offset;
		
		trialnum_col_touch_B = tmp_touch_B.cn.TrialNum;
		tmp_touch_B.data(:, trialnum_col_touch_B) = tmp_touch_B.data(:, trialnum_col_touch_B) + per_session_offset;
		
		timestamps_col_touch_B = tmp_touch_A.cn.Tracker_corrected_EventIDE_TimeStamp;
		tmp_touch_B.data(:,timestamps_col_touch_B) = tmp_touch_B.data(:,timestamps_col_touch_B) + per_session_offset;
		
		
		% fix the reward sub structure
		reward_struct = tmp_maintask_datastruct.report_struct.Reward;
		tmp_main_dataStruct.Reward.data(:,reward_struct.cn.TrialNumber) = reward_struct.data(:,reward_struct.cn.TrialNumber) + per_session_offset;
		tmp_main_dataStruct.Reward.data(:,reward_struct.cn.RewardStartTime) = reward_struct.data(:,reward_struct.cn.RewardStartTime) + per_session_offset;
		
		% fix the stimuli substructure
		stimuli_struct = tmp_maintask_datastruct.report_struct.Stimuli;
		tmp_main_dataStruct.Stimuli.data(:,stimuli_struct.cn.TrialNumber) = stimuli_struct.data(:,stimuli_struct.cn.TrialNumber) + per_session_offset;
		tmp_main_dataStruct.Stimuli.data(:,stimuli_struct.cn.Timestamp) = stimuli_struct.data(:,stimuli_struct.cn.Timestamp) + per_session_offset;
		
		
		
		
	end
	
	% 		if (length(gazereg_list) > 1)
	% 			trialnum_col_recalibration = tmp_recalibration_struct.cn.TrialNumber;
	% 			tmp_recalibration_struct.data(:,trialnum_col_recalibration) = tmp_recalibration_struct.data(:,trialnum_col_recalibration)+ per_gaze_reg_offset;
	% 		end
	
	% fix up _idx fields
	if (i_session > 1)		
		[main_dataStruct, new_data_struct] = fn_merged_indexed_cols_and_unique_lists(main_dataStruct, tmp_maintask_datastruct.report_struct);
		tmp_maintask_datastruct.report_struct = new_data_struct;
		% Reward substruct
		[main_dataStruct.Reward, new_data_struct] = fn_merged_indexed_cols_and_unique_lists(main_dataStruct.Reward, tmp_maintask_datastruct.report_struct.Reward);
		tmp_maintask_datastruct.report_struct.Reward = new_data_struct;
		% Stimuli substruct
		[main_dataStruct.Stimuli, new_data_struct] = fn_merged_indexed_cols_and_unique_lists(main_dataStruct.Stimuli, tmp_maintask_datastruct.report_struct.Stimuli);
		tmp_maintask_datastruct.report_struct.Stimuli = new_data_struct;
		
		
		
%		trial_struct = tmp_maintask_datastruct.report_struct;		
% 		idx_col_list = regexp(trial_struct.header, '_idx$');
% 		
% 		for i_idx_col = 1 : length(idx_col_list)
% 			if ~isempty(idx_col_list{i_idx_col})
% 				current_col_name = trial_struct.header{i_idx_col};
% 				
% 				if isempty(regexp(current_col_name, 'ENUM_idx$'));
% 					disp(['Non ENUM _idx column: ', current_col_name]);
% 					unique_list_name = current_col_name(1:end-4);
% 					
% 					tmp_main_cur_col_idx_list = (main_dataStruct.data(:, main_dataStruct.cn.(current_col_name)));
% 					tmp_main_cur_col_idx_list_zero_idx = find(tmp_main_cur_col_idx_list == 0);
% 					if ~isempty(tmp_main_cur_col_idx_list_zero_idx)
% 						main_dataStruct.data(tmp_main_cur_col_idx_list_zero_idx, main_dataStruct.cn.(current_col_name)) = length(main_dataStruct.unique_lists.(unique_list_name)) + 1;
% 						main_dataStruct.unique_lists.(unique_list_name){end+1} ='EMPTY';
% 					end
% 					
% 					tmp_main_cur_col_idx_list = (trial_struct.data(:, trial_struct.cn.(current_col_name)));
% 					tmp_main_cur_col_idx_list_zero_idx = find(tmp_main_cur_col_idx_list == 0);
% 					if ~isempty(tmp_main_cur_col_idx_list_zero_idx)
% 						trial_struct.data(tmp_main_cur_col_idx_list_zero_idx, trial_struct.cn.(current_col_name)) = length(trial_struct.unique_lists.(unique_list_name)) + 1;
% 						trial_struct.unique_lists.(unique_list_name){end+1} = 'EMPTY';
% 					end
% 					
% 					
% 					main_dataStruct_cur_idx_col_list = main_dataStruct.unique_lists.(unique_list_name)(main_dataStruct.data(:, main_dataStruct.cn.(current_col_name)));
% 					trial_struct_cur_idx_col_list = trial_struct.unique_lists.(unique_list_name)(trial_struct.data(:, trial_struct.cn.(current_col_name)));
% 					
% 					
% 					if size(main_dataStruct_cur_idx_col_list, 1) < size(main_dataStruct_cur_idx_col_list, 2)
% 						main_dataStruct_cur_idx_col_list = main_dataStruct_cur_idx_col_list';
% 					end
% 					if size(trial_struct_cur_idx_col_list, 1) < size(trial_struct_cur_idx_col_list, 2)
% 						trial_struct_cur_idx_col_list = trial_struct_cur_idx_col_list';
% 					end
% 					
% 					tmp_list = [main_dataStruct_cur_idx_col_list; trial_struct_cur_idx_col_list];
% 					[out_list, in_list_idx] = fnUnsortedUnique(tmp_list);
% 					
% 					main_dataStruct.unique_lists.(unique_list_name) = out_list';
% 					tmp_idx = zeros(size(tmp_list));
% 					for i_unique_val = 1 : length(out_list)
% 						unique_val_idx = strcmp(tmp_list, out_list{i_unique_val});
% 						tmp_idx(unique_val_idx) = i_unique_val;
% 					end
% 					
% 					main_dataStruct.data(:, main_dataStruct.cn.(current_col_name)) = tmp_idx(1: size(main_dataStruct.data, 1));
% 					trial_struct.data(:, trial_struct.cn.(current_col_name)) = tmp_idx(size(main_dataStruct.data, 1) + 1 : end);
% 					
% 				end
% 			end
% 		end
% 		tmp_maintask_datastruct.report_struct = trial_struct;
	end
	
	
	
	if (i_session == 1)
		main_dataStruct = tmp_main_dataStruct;
		dataStruct = tmp_dataStruct;
		touch_A_Struct = tmp_touch_A;
		touch_B_Struct = tmp_touch_B;
		recalibration_struct = tmp_recalibration_struct;
	else
		main_dataStruct.data = [main_dataStruct.data; tmp_main_dataStruct.data];
		main_dataStruct.Reward.data = [main_dataStruct.Reward.data; tmp_main_dataStruct.Reward.data];
		main_dataStruct.Stimuli.data = [main_dataStruct.Stimuli.data; tmp_main_dataStruct.Stimuli.data];
		
		dataStruct.data = [dataStruct.data; tmp_dataStruct.data];
		touch_A_Struct.data = [touch_A_Struct.data; tmp_touch_A.data];
		touch_B_Struct.data = [touch_B_Struct.data; tmp_touch_B.data];
		recalibration_struct.data = [recalibration_struct.data ; tmp_recalibration_struct.data];
	end
	
	
	
	
	
	maintask_datastruct.report_struct = main_dataStruct;
	data_struct_extract = dataStruct;
	touchtracker_datastructA = touch_A_Struct;
	touchtracker_datastructB = touch_B_Struct;
	
	
	
	
	%apply the chosen registration to the raw left and right eye (all the
	%trials)
	% registered_left_eye_gaze_samples = transformPointsInverse(tmp_t_form.registration_struct.polynomial.Left_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_Y))]);
	% registered_left_eye_gaze_samples_x_coordinates = registered_left_eye_gaze_samples (:,1);
	% registered_left_eye_gaze_samples_y_coordinates = registered_left_eye_gaze_samples (:,2);
	%
	% registered_right_eye_gaze_samples = transformPointsInverse(tmp_t_form.registration_struct.polynomial.Right_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_Y))]);
	% registered_right_eye_gaze_samples_x_coordinates = registered_right_eye_gaze_samples (:,1);
	% registered_right_eye_gaze_samples_y_coordinates = registered_right_eye_gaze_samples (:,2);
	%
	% % recalibration_struct = struct ();
	% % recalibration_struct.header = {'TrialNumber','Tracker_corrected_EventIDE_Timestamp' 'Left_X', 'Left_Y', 'Right_X', 'Right_Y'};
	% %
	% % recalibration_struct.data = horzcat (data_struct_extract.data(:, data_struct_extract.cn.TrialNumber),data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp),...
	% % 	registered_left_eye_gaze_samples_x_coordinates,registered_left_eye_gaze_samples_y_coordinates,registered_right_eye_gaze_samples_x_coordinates,...
	% % 	registered_right_eye_gaze_samples_y_coordinates) ;
	% %
	%end
end
end






function [out_list, in_list_idx] = fnUnsortedUnique(in_list)
% unsorted_unique auto-undo the sorting in the return values of unique
% the outlist gives the unique elements of the in_list at the relative
% position of the last occurrence in the in_list, in_list_idx gives the
% index of that position in the in_list

[sorted_unique_list, sort_idx] = unique(in_list);
[in_list_idx, unsort_idx] = sort(sort_idx);
out_list = sorted_unique_list(unsort_idx);

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



function [ existing_data_struct, new_data_struct ] = fn_merged_indexed_cols_and_unique_lists( existing_data_struct, new_data_struct )


idx_col_list = regexp(new_data_struct.header, '_idx$');

for i_idx_col = 1 : length(idx_col_list)
	if ~isempty(idx_col_list{i_idx_col})
		current_col_name = new_data_struct.header{i_idx_col};
		
		if isempty(regexp(current_col_name, 'ENUM_idx$'));
			disp(['Non ENUM _idx column: ', current_col_name]);
			unique_list_name = current_col_name(1:end-4);
			
			tmp_main_cur_col_idx_list = (existing_data_struct.data(:, existing_data_struct.cn.(current_col_name)));
			tmp_main_cur_col_idx_list_zero_idx = find(tmp_main_cur_col_idx_list == 0);
			if ~isempty(tmp_main_cur_col_idx_list_zero_idx)
				existing_data_struct.data(tmp_main_cur_col_idx_list_zero_idx, existing_data_struct.cn.(current_col_name)) = length(existing_data_struct.unique_lists.(unique_list_name)) + 1;
				existing_data_struct.unique_lists.(unique_list_name){end+1} ='EMPTY';
			end
			
			tmp_main_cur_col_idx_list = (new_data_struct.data(:, new_data_struct.cn.(current_col_name)));
			tmp_main_cur_col_idx_list_zero_idx = find(tmp_main_cur_col_idx_list == 0);
			if ~isempty(tmp_main_cur_col_idx_list_zero_idx)
				new_data_struct.data(tmp_main_cur_col_idx_list_zero_idx, new_data_struct.cn.(current_col_name)) = length(new_data_struct.unique_lists.(unique_list_name)) + 1;
				new_data_struct.unique_lists.(unique_list_name){end+1} = 'EMPTY';
			end
			
			
			existing_data_struct_cur_idx_col_list = existing_data_struct.unique_lists.(unique_list_name)(existing_data_struct.data(:, existing_data_struct.cn.(current_col_name)));
			new_data_struct_cur_idx_col_list = new_data_struct.unique_lists.(unique_list_name)(new_data_struct.data(:, new_data_struct.cn.(current_col_name)));
			
			
			if size(existing_data_struct_cur_idx_col_list, 1) < size(existing_data_struct_cur_idx_col_list, 2)
				existing_data_struct_cur_idx_col_list = existing_data_struct_cur_idx_col_list';
			end
			if size(new_data_struct_cur_idx_col_list, 1) < size(new_data_struct_cur_idx_col_list, 2)
				new_data_struct_cur_idx_col_list = new_data_struct_cur_idx_col_list';
			end
			
			tmp_list = [existing_data_struct_cur_idx_col_list; new_data_struct_cur_idx_col_list];
			[out_list, in_list_idx] = fnUnsortedUnique(tmp_list);
			
			existing_data_struct.unique_lists.(unique_list_name) = out_list';
			tmp_idx = zeros(size(tmp_list));
			for i_unique_val = 1 : length(out_list)
				unique_val_idx = strcmp(tmp_list, out_list{i_unique_val});
				tmp_idx(unique_val_idx) = i_unique_val;
			end
			
			existing_data_struct.data(:, existing_data_struct.cn.(current_col_name)) = tmp_idx(1: size(existing_data_struct.data, 1));
			new_data_struct.data(:, new_data_struct.cn.(current_col_name)) = tmp_idx(size(existing_data_struct.data, 1) + 1 : end);
			
		end
	end
end
tmp_maintask_datastruct.report_struct = new_data_struct;

return
end


