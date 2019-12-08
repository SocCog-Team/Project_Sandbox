%This epoch: Alignment- Player B's Touch Target; Start point: -200 ms of the
%alignment and until Target offset
function [epochdata]= rn_defineEpochnewGazeAlignedtoB_TargetTouchTime_ms(TrialWiseData, maintask_datastruct)

[a b]=size(TrialWiseData.timepoints);
epochdata.xCoordinates_right_eye(1:a,1:b)=NaN;
epochdata.yCoordinates_right_eye(1:a,1:b)=NaN;
epochdata.xCoordinates_left_eye(1:a,1:b)=NaN;
epochdata.yCoordinates_left_eye(1:a,1:b)=NaN;
epochdata.timepoints(1:a,1:b)=NaN;
    for n_rows= 1:a
    
        [epochdata_idx]=find((TrialWiseData.timepoints(n_rows,:)>=maintask_datastruct.report_struct.data(n_rows, maintask_datastruct.report_struct.cn.B_TargetTouchTime_ms)-200) & (TrialWiseData.timepoints(n_rows,:)<=(maintask_datastruct.report_struct.data(n_rows, maintask_datastruct.report_struct.cn.B_TargetOffsetTime_ms))));
        
        epochdata.xCoordinates_right_eye(n_rows,1:length(epochdata_idx))=TrialWiseData.xCoordinates_right_eye(n_rows,epochdata_idx);
        epochdata.yCoordinates_right_eye(n_rows,1:length(epochdata_idx))=TrialWiseData.yCoordinates_right_eye(n_rows,epochdata_idx);
		epochdata.xCoordinates_left_eye(n_rows,1:length(epochdata_idx))=TrialWiseData.xCoordinates_left_eye(n_rows,epochdata_idx);
        epochdata.yCoordinates_left_eye(n_rows,1:length(epochdata_idx))=TrialWiseData.yCoordinates_left_eye(n_rows,epochdata_idx);
        epochdata.timepoints(n_rows,1:length(epochdata_idx))=(TrialWiseData.timepoints(n_rows,epochdata_idx)-(maintask_datastruct.report_struct.data(n_rows,maintask_datastruct.report_struct.cn.B_TargetTouchTime_ms)))/1000;
        
    end
    epochdata.xCoordinates_right_eye(epochdata.xCoordinates_right_eye==0) = NaN;
    epochdata.yCoordinates_right_eye(epochdata.yCoordinates_right_eye==0) = NaN; 
	epochdata.xCoordinates_left_eye(epochdata.xCoordinates_left_eye==0) = NaN;
    epochdata.yCoordinates_left_eye(epochdata.yCoordinates_left_eye==0) = NaN;
    epochdata.timepoints(epochdata.timepoints==0) = NaN; 
end