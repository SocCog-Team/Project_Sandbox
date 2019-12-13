%%Aligns the data to Target Onset Time
%%Input: TrialWiseData- The structure which has each row corresponding to a
%%trial and columns have x, y or time
%%maintask_datastruct- This is the data structure of the Trial Log File
%%Output: epochdata is arranged similar to TrialWiseData. But everything is
%%aligned to Target onset time
function [epochdata]= tn_defineEpochnew(TrialWiseData, maintask_datastruct)
epochdata=[];
% valid_gaze_datapoints=find(data_struct_extract.data(:,15)~=-32768);
for indexer4 = 1:size(TrialWiseData.timepoints,1)
	epochdata_idx=find((TrialWiseData.timepoints(indexer4,:)>=maintask_datastruct.report_struct.data(indexer4, maintask_datastruct.report_struct.cn.A_TargetOnsetTime_ms)-500) & (TrialWiseData.timepoints(indexer4,:)<(maintask_datastruct.report_struct.data(indexer4, maintask_datastruct.report_struct.cn.A_TargetOffsetTime_ms)+300)));
	
	epochdata.TargetOnset.xCoordinates(indexer4,1:length(epochdata_idx)) = TrialWiseData.xCoordinates(indexer4,epochdata_idx);
	epochdata.TargetOnset.yCoordinates(indexer4,1:length(epochdata_idx)) = TrialWiseData.yCoordinates(indexer4,epochdata_idx);
	epochdata.TargetOnset.timepoints(indexer4,1:length(epochdata_idx)) = (TrialWiseData.timepoints(indexer4,epochdata_idx) - ...
		(maintask_datastruct.report_struct.data(indexer4,maintask_datastruct.report_struct.cn.A_TargetOnsetTime_ms)))/1000;
	
	
end

epochdata.TargetOnset.xCoordinates(epochdata.TargetOnset.xCoordinates==0) = NaN;
epochdata.TargetOnset.yCoordinates(epochdata.TargetOnset.yCoordinates==0) = NaN;
epochdata.TargetOnset.timepoints(epochdata.TargetOnset.timepoints==0) = NaN;  %This logical might fail when EventIDEtimepoint-targetonset time=0 . Hasn't failed yet.

return
end


	
	
	
	
	