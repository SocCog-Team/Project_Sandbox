%%This is to structure things in a way that each row corresponds to trial
%%number and the columns have X, Y coordinates or timepoints depending on
%%which sub-structure you're looking in . 
%%Input- xytime: Structure of gaze or touch tracker Log file
%%trialnum_tracker: Array in which each row corresponds to which trial
%%number this data point corresponds to 
%%nrows_maintask: number of rows in the trial log file
%%Example to use: [TrialWiseData]= tn_trialwiseDataStructure(TrialLogDataStructure.data,trialnum_tracker,nrows_maintask)

function [ TrialWiseData ] = tn_trialwiseDataStructure(xytime, trialnum_tracker, nrows_maintask)
TrialWiseData = ([]);
for trialnum = 1:nrows_maintask
	trialnum_idx = find(trialnum_tracker == trialnum);
	if trialnum ~= 0
		if ~isempty(trialnum_idx)
			TrialWiseData.TrialNumber(trialnum,1) = trialnum;
			TrialWiseData.timepoints(trialnum,1:length(trialnum_idx)) = xytime(trialnum_idx,1);
			TrialWiseData.xCoordinates(trialnum,1:length(trialnum_idx)) = xytime(trialnum_idx,2);
			TrialWiseData.yCoordinates(trialnum,1:length(trialnum_idx)) = xytime(trialnum_idx,3);
		else
			if ~isfield(TrialWiseData, 'timepoints')
				num_cols = 10;
			else
				num_cols = size(TrialWiseData.timepoints, 2);
			end
			TrialWiseData.TrialNumber(trialnum,1) = trialnum;
			TrialWiseData.timepoints(trialnum,1:num_cols) = NaN;
			TrialWiseData.xCoordinates(trialnum,1:num_cols) = NaN;
			TrialWiseData.yCoordinates(trialnum,1:num_cols) = NaN;
		end
	end
end
    TrialWiseData.timepoints(TrialWiseData.timepoints == 0) = NaN;   
    TrialWiseData.xCoordinates(TrialWiseData.xCoordinates == 0) = NaN;   
    TrialWiseData.yCoordinates(TrialWiseData.yCoordinates == 0) = NaN;   

end

