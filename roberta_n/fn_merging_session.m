function [maintask_datastruct, data_struct_extract, touchtracker_datastructA, touchtracker_datastructB, recalibration_struct] = fn_merging_session( fileID, gazereg_name  )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

data_root_str = fullfile('C:', 'SCP');

% network!
data_base_dir = fullfile('Y:');

if ~exist('fileID', 'var') || isempty(fileID)
	fileID = '20190320T095244.A_Elmo.B_JK.SCP_01';
end

year_string = fileID(1:4);
date_string = fileID(3:8);

if ~exist('gazereg_name', 'var') || isempty(gazereg_name)
	gazereg_name = 'GAZEREG.SID_20190320T092435.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat';
end

data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, [fileID, '.sessiondir']);
saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN', [fileID, '.sessiondir']);

gazereg_FQN = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, gazereg_name);

sessionID_list = {'20190320T095244.A_Elmo.B_JK.SCP_01',...
	'20190321T083454.A_Elmo.B_JK.SCP_01'}
 %	'20190322T083726.A_Elmo.B_JK.SCP_01'}
% 	'20190329T112049.A_Elmo.B_SM.SCP_01',...
% 	'20190403T090741.A_Elmo.B_JK.SCP_01',...
% 	'20190404T090735.A_Elmo.B_JK.SCP_01'};

gazereg_list = {'GAZEREG.SID_20190320T092435.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190321T072108.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat'}
	%'GAZEREG.SID_20190322T071957.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat'}
% 	'GAZEREG.SID_20190329T111602.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
% 	'GAZEREG.SID_20190403T073047.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
% 	'GAZEREG.SID_20190404T083605.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat'};

offset = 100000000;


for i_session = 1 : length(sessionID_list)
	fileID = sessionID_list{i_session};
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
	
	for i_gaze_reg = 1: length (gazereg_list)
		gazereg_ID = gazereg_list{i_gaze_reg};
		year_string_gaze_reg = gazereg_ID(13:16);
		date_string_gaze_reg = gazereg_ID(15:20);
	    per_gaze_reg_offset = (i_gaze_reg - 1) * offset;
		
		registered_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string_gaze_reg , date_string_gaze_reg);
		t_form = load(fullfile(registered_dir, [gazereg_ID]));
		reg_left_eye = transformPointsInverse(t_form.registration_struct.polynomial.Left_Eye_Raw.tform, [(tmp_dataStruct.data(:,tmp_dataStruct.cn.Left_Eye_Raw_X)) (tmp_dataStruct.data(:,tmp_dataStruct.cn.Left_Eye_Raw_Y))]);
		reg_right_eye = transformPointsInverse(t_form.registration_struct.polynomial.Right_Eye_Raw.tform, [(tmp_dataStruct.data(:,tmp_dataStruct.cn.Right_Eye_Raw_X)) (tmp_dataStruct.data(:,tmp_dataStruct.cn.Right_Eye_Raw_Y))]);
		
		field1 = 'TrialNumber';  value1 = 1;
		field2 = 'CorrectedTimeStamps';  value2 = 2;
		field3 = 'Left_Eye_x';  value3 = 3;
		field4 = 'Left_Eye_y';  value4 = 4;
		field5 = 'Right_Eye_x';  value5 = 5;
		field6 = 'Right_Eye_y';  value6 = 6;
		
		tmp_recalibration_struct = struct ();
		tmp_recalibration_struct.cn= struct(field1,value1,field2,value2,field3,value3,field4,value4, field5, value5, field6, value6);
		
		tmp_recalibration_struct.data = horzcat (tmp_dataStruct.data(:, tmp_dataStruct.cn.TrialNumber), tmp_dataStruct.data(:,tmp_dataStruct.cn.Tracker_corrected_EventIDE_TimeStamp),...
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
			
					
		end
		
% 		if (length(gazereg_list) > 1)
% 			trialnum_col_recalibration = tmp_recalibration_struct.cn.TrialNumber;
% 			tmp_recalibration_struct.data(:,trialnum_col_recalibration) = tmp_recalibration_struct.data(:,trialnum_col_recalibration)+ per_gaze_reg_offset;
% 		end
		
		% fix up _idx fields
		if (i_session > 1)
			trial_struct = tmp_maintask_datastruct.report_struct;
			
			idx_col_list = regexp(trial_struct.header, '_idx$');
			
			for i_idx_col = 1 : length(idx_col_list)
				if ~isempty(idx_col_list{i_idx_col})
					current_col_name = trial_struct.header{i_idx_col};
					
					if isempty(regexp(current_col_name, 'ENUM_idx$'));
						disp(['Non ENUM _idx column: ', current_col_name]);
						unique_list_name = current_col_name(1:end-4);
						
						tmp_main_cur_col_idx_list = (main_dataStruct.data(:, main_dataStruct.cn.(current_col_name)));
						tmp_main_cur_col_idx_list_zero_idx = find(tmp_main_cur_col_idx_list == 0);
						if ~isempty(tmp_main_cur_col_idx_list_zero_idx)
							main_dataStruct.data(tmp_main_cur_col_idx_list_zero_idx, main_dataStruct.cn.(current_col_name)) = length(main_dataStruct.unique_lists.(unique_list_name)) + 1;
							main_dataStruct.unique_lists.(unique_list_name){end+1} ='EMPTY';
						end
						
						tmp_main_cur_col_idx_list = (trial_struct.data(:, trial_struct.cn.(current_col_name)));
						tmp_main_cur_col_idx_list_zero_idx = find(tmp_main_cur_col_idx_list == 0);
						if ~isempty(tmp_main_cur_col_idx_list_zero_idx)
							trial_struct.data(tmp_main_cur_col_idx_list_zero_idx, trial_struct.cn.(current_col_name)) = length(trial_struct.unique_lists.(unique_list_name)) + 1;
							trial_struct.unique_lists.(unique_list_name){end+1} = 'EMPTY';
						end
						
						
						main_dataStruct_cur_idx_col_list = main_dataStruct.unique_lists.(unique_list_name)(main_dataStruct.data(:, main_dataStruct.cn.(current_col_name)));
						trial_struct_cur_idx_col_list = trial_struct.unique_lists.(unique_list_name)(trial_struct.data(:, trial_struct.cn.(current_col_name)));
						
						
						if size(main_dataStruct_cur_idx_col_list, 1) < size(main_dataStruct_cur_idx_col_list, 2)
							main_dataStruct_cur_idx_col_list = main_dataStruct_cur_idx_col_list';
						end
						if size(trial_struct_cur_idx_col_list, 1) < size(trial_struct_cur_idx_col_list, 2)
							trial_struct_cur_idx_col_list = trial_struct_cur_idx_col_list';
						end
						
						tmp_list = [main_dataStruct_cur_idx_col_list; trial_struct_cur_idx_col_list];
						[out_list, in_list_idx] = fnUnsortedUnique(tmp_list);
						
						main_dataStruct.unique_lists.(unique_list_name) = out_list';
						tmp_idx = zeros(size(tmp_list));
						for i_unique_val = 1 : length(out_list)
							unique_val_idx = strcmp(tmp_list, out_list{i_unique_val});
							tmp_idx(unique_val_idx) = i_unique_val;
						end
						
						main_dataStruct.data(:, main_dataStruct.cn.(current_col_name)) = tmp_idx(1: size(main_dataStruct.data, 1));
						trial_struct.data(:, trial_struct.cn.(current_col_name)) = tmp_idx(size(main_dataStruct.data, 1) + 1 : end);
						
					end
				end
			end
			tmp_maintask_datastruct.report_struct = trial_struct;
		end
		
		if (i_session == 1)
			main_dataStruct = tmp_main_dataStruct;
		else
			main_dataStruct.data = [main_dataStruct.data; tmp_main_dataStruct.data];
		end
		
		
		if (i_session == 1)
			dataStruct = tmp_dataStruct;
		else
			dataStruct.data = [dataStruct.data; tmp_dataStruct.data];
		end
		
		if (i_session == 1)
			touch_A_Struct = tmp_touch_A;
		else
			touch_A_Struct.data = [touch_A_Struct.data; tmp_touch_A.data];
		end
		
		if (i_session == 1)
			touch_B_Struct = tmp_touch_B;
		else
			touch_B_Struct.data = [touch_B_Struct.data; tmp_touch_B.data];
		end
		if (i_gaze_reg == 1)
			recalibration_struct = tmp_recalibration_struct;
		else
			recalibration_struct.data = [recalibration_struct.data ; tmp_recalibration_struct.data];
		end
		
		
		
		
		maintask_datastruct.report_struct = main_dataStruct;
		data_struct_extract = dataStruct;
		touchtracker_datastructA = touch_A_Struct;
		touchtracker_datastructB = touch_B_Struct;
		
		nrows_eyetracker = 0;
		ncols_eyetracker = 0;
		[nrows_eyetracker, ncols_eyetracker] = size(data_struct_extract.data);
		
		nrows_maintask = 0;
		ncols_maintask = 0;
		[nrows_maintask, ncols_maintask] = size(maintask_datastruct.report_struct.data);
		
		
		
		
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
return

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


