%This epoch: Alignment- Player B's IF release; Start point: -200 ms of the
%alignment and until Target offset
function [epochdata]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(TrialWiseData, maintask_datastruct)

[a b]=size(TrialWiseData.timepoints);
epochdata.xCoordinates(1:a,1:b)=NaN;
epochdata.yCoordinates(1:a,1:b)=NaN;
epochdata.timepoints(1:a,1:b)=NaN;
    for indexer4= 1:a
    
        [epochdata_idx]=find((TrialWiseData.timepoints(indexer4,:)>=maintask_datastruct.report_struct.data(indexer4, maintask_datastruct.report_struct.cn.B_InitialFixationReleaseTime_ms)-200) & (TrialWiseData.timepoints(indexer4,:)<(maintask_datastruct.report_struct.data(indexer4, maintask_datastruct.report_struct.cn.A_TargetOffsetTime_ms))));
        
        epochdata.xCoordinates(indexer4,1:length(epochdata_idx))=TrialWiseData.xCoordinates(indexer4,epochdata_idx);
        epochdata.yCoordinates(indexer4,1:length(epochdata_idx))=TrialWiseData.yCoordinates(indexer4,epochdata_idx);
        epochdata.timepoints(indexer4,1:length(epochdata_idx))=(TrialWiseData.timepoints(indexer4,epochdata_idx)-(maintask_datastruct.report_struct.data(indexer4,maintask_datastruct.report_struct.cn.B_InitialFixationReleaseTime_ms)))/1000;
        
    end
    epochdata.xCoordinates(epochdata.xCoordinates==0) = NaN;
    epochdata.yCoordinates(epochdata.yCoordinates==0) = NaN;  
    epochdata.timepoints(epochdata.timepoints==0) = NaN;  %This logical might fail when EventIDEtimepoint-targetonset time=0 . In 201811277, Elmo SM , this doesn't fail. 

end