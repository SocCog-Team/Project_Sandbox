function [ RegisteredTrialWiseData ] = registered_trialwiseDataStructure_left_eye( data_struct_extract, recalibration_struct, trialnumber_by_tracker_sample_list, nrows_maintask )
    RegisteredTrialWiseData = ([]);
    for trialnum = 1:nrows_maintask
        trialnum_idx = find(trialnumber_by_tracker_sample_list == trialnum);

		if (trialnum ~= 0)
			if (~isempty(trialnum_idx))
				RegisteredTrialWiseData.TrialNumber(trialnum, 1) = trialnum;
				RegisteredTrialWiseData.timepoints(trialnum, 1:length(trialnum_idx)) = data_struct_extract.data(trialnum_idx,1);
				RegisteredTrialWiseData.xCoordinates(trialnum, 1:length(trialnum_idx)) = recalibration_struct.data(trialnum_idx,3);
				RegisteredTrialWiseData.yCoordinates(trialnum, 1:length(trialnum_idx)) = recalibration_struct.data(trialnum_idx,4);
			else
				RegisteredTrialWiseData.TrialNumber(trialnum, 1) = trialnum;
				if ~isfield(RegisteredTrialWiseData, 'timepoints')
					num_cols = 10;
				else
					num_cols = size(RegisteredTrialWiseData.timepoints, 2);
				end
				RegisteredTrialWiseData.timepoints(trialnum, 1:num_cols) = NaN;
				RegisteredTrialWiseData.xCoordinates(trialnum, 1:num_cols) = NaN;
				RegisteredTrialWiseData.yCoordinates(trialnum, 1:num_cols) = NaN;
			end
		end
		
    end
    RegisteredTrialWiseData.timepoints(RegisteredTrialWiseData.timepoints == 0) = NaN;   
    RegisteredTrialWiseData.xCoordinates(RegisteredTrialWiseData.xCoordinates == 0) = NaN;   
    RegisteredTrialWiseData.yCoordinates(RegisteredTrialWiseData.yCoordinates == 0) = NaN;   
    
end