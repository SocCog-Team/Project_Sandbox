%This epoch: Alignment- Player A's Target Touch; Start point: -200 ms of the
%alignment and until Target offset
function [epochdata]= rn_defineEpochnewTouchAlignedtoA_TargetTouchTime_ms(TrialWiseData, maintask_datastruct)

[a b]=size(TrialWiseData.timepoints);
epochdata.xCoordinates(1:a,1:b)=NaN;
epochdata.yCoordinates(1:a,1:b)=NaN;
epochdata.timepoints(1:a,1:b)=NaN;
    for n_rows= 1:a
    
        [epochdata_idx]=find((TrialWiseData.timepoints(n_rows,:)>=maintask_datastruct.report_struct.data(n_rows, maintask_datastruct.report_struct.cn.B_TargetTouchTime_ms)-200) & (TrialWiseData.timepoints(n_rows,:)<(maintask_datastruct.report_struct.data(n_rows, maintask_datastruct.report_struct.cn.B_TmpTouchReleaseTime_ms))));
        
        epochdata.xCoordinates(n_rows,1:length(epochdata_idx))=TrialWiseData.xCoordinates(n_rows,epochdata_idx);
        epochdata.yCoordinates(n_rows,1:length(epochdata_idx))=TrialWiseData.yCoordinates(n_rows,epochdata_idx);
		
        epochdata.timepoints(n_rows,1:length(epochdata_idx))=(TrialWiseData.timepoints(n_rows,epochdata_idx)-(maintask_datastruct.report_struct.data(n_rows,maintask_datastruct.report_struct.cn.B_TargetTouchTime_ms)))/1000;
        
    end
    epochdata.xCoordinates(epochdata.xCoordinates==0) = NaN;
    epochdata.yCoordinates(epochdata.yCoordinates==0) = NaN; 
	
    epochdata.timepoints(epochdata.timepoints==0) = NaN;  %This logical might fail when EventIDEtimepoint-targetonset time=0. 

end