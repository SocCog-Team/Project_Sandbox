function [ RegisteredTrialWiseData ]= registered_trialwiseDataStructure( xytime,registered_xy,trialnumber_by_tracker_sample_list, nrows_maintask )
    RegisteredTrialWiseData = ([]);
    for trialnum = 1:nrows_maintask
        trialnum_idx = find(trialnumber_by_tracker_sample_list == trialnum);
        if (trialnum ~= 0) && (isempty(trialnum_idx) ~= 1)
            RegisteredTrialWiseData.TrialNumber(trialnum, 1) = trialnum;
        
            RegisteredTrialWiseData.timepoints(trialnum, 1:length(trialnum_idx)) = xytime(trialnum_idx, 29);
            RegisteredTrialWiseData.xCoordinates(trialnum, 1:length(trialnum_idx)) = registered_xy(trialnum_idx, 1);
	        RegisteredTrialWiseData.yCoordinates(trialnum, 1:length(trialnum_idx)) = registered_xy(trialnum_idx, 2);

        end
    end
    RegisteredTrialWiseData.timepoints(RegisteredTrialWiseData.timepoints == 0) = NaN;   
    RegisteredTrialWiseData.xCoordinates(RegisteredTrialWiseData.xCoordinates == 0) = NaN;   
    RegisteredTrialWiseData.yCoordinates(RegisteredTrialWiseData.yCoordinates == 0) = NaN;   

end