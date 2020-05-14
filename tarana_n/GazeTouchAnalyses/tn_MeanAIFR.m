%%Just to calculate the Mean time when Player A released his hand from IF
%%target - in each condition 
function [AIFRsEpoch]=tn_MeanAIFR(maintask_datastruct)
    AIFRs=maintask_datastruct.report_struct.data(:,maintask_datastruct.report_struct.cn.A_InitialFixationReleaseTime_ms);
    BIFRs=maintask_datastruct.report_struct.data(:,maintask_datastruct.report_struct.cn.B_InitialFixationReleaseTime_ms);
    AIFRsEpoch=(AIFRs-BIFRs)/1000;
    
end