function [ trialnum_tracker ] = fn_assign_trialnum2samples_by_range( report_struct, data_struct_extract, start_val_col_idx, start_offset, end_val_col_idx, end_offset )
%FN_ASSIGN_TRIALNUM2SAMPLES_BY_RANGE Summary of this function goes here
%   Detailed explanation goes here
% Makes an array of each data point of the tracker log corresponding to the
% trial number

data_cn = data_struct_extract.cn;

trialnum_tracker = zeros(length(data_struct_extract.data), 1);
n_trials = size(report_struct.data, 1);
for trial_datapoints = 1:(n_trials - 1)
	if (report_struct.data(trial_datapoints, 1) ~= 0)
		samples_in_current_trial_idx = (data_struct_extract.data(:, data_cn.Tracker_corrected_EventIDE_TimeStamp) >= (report_struct.data(trial_datapoints, start_val_col_idx) + start_offset)) & ...
			(data_struct_extract.data(:, data_cn.Tracker_corrected_EventIDE_TimeStamp) <= (report_struct.data(trial_datapoints, end_val_col_idx) + end_offset));
		% exclude incomplete trials
		if (report_struct.data(trial_datapoints, start_val_col_idx) == 0) || (report_struct.data(trial_datapoints, end_val_col_idx) == 0)
			samples_in_current_trial_idx = [];
		end	
		if ~isempty(samples_in_current_trial_idx)
			trialnum_tracker(samples_in_current_trial_idx) = trial_datapoints;
			%trialnum_tracker(samples_in_current_trial_idx) = report_struct.data(trial_datapoints, report_struct.cn.TrialNumber);
		end
	end
end


%     indexer1=ismember(trialnum_tracker,SuccessfulChoiceTrials);
%     indexer2=find((indexer1==1 )& (data_struct_extract.data(:,2)>0));
%     for trial_datapoints= 1: nrows_maintask
%         trial_idx=find((data_struct_extract.data(:,1)>= maintask_datastruct.report_struct.data(trial_datapoints,1))&(data_struct_extract.data(:,1)<=(maintask_datastruct.report_struct.Reward(trial_datapoints*2,1)+ 1500)));
%         trialnum_tracker(trial_idx,1)=trial_datapoints;
%
%     end
end
