% Makes an array of each data point of the tracker log corresponding to the
% trial number
function [ trialnum_tracker ]= fn_trialnumber (maintask_datastruct, data_struct_extract )
    
    trialnum_tracker=zeros(length(data_struct_extract.data),1);
    indexer=0;
    [a b]=size(maintask_datastruct.report_struct.data);
    for trial_datapoints= 1: a-1
        if (maintask_datastruct.report_struct.data(trial_datapoints,1)~=0)
            indexer = (data_struct_extract.data(:,1)>= maintask_datastruct.report_struct.data(trial_datapoints,1))&(data_struct_extract.data(:,1)<= maintask_datastruct.report_struct.data(trial_datapoints,47));   
            trialnum_tracker(indexer,1)=trial_datapoints;
            
            indexer=0;    
        end
    end
%     indexer1=ismember(trialnum_tracker,jointtrials);
%     indexer2=find((indexer1==1 )& (data_struct_extract.data(:,2)>0));
%     for trial_datapoints= 1: nrows_maintask
%         trial_idx=find((data_struct_extract.data(:,1)>= maintask_datastruct.report_struct.data(trial_datapoints,1))&(data_struct_extract.data(:,1)<=(maintask_datastruct.report_struct.Reward(trial_datapoints*2,1)+ 1500)));
%         trialnum_tracker(trial_idx,1)=trial_datapoints;
%     
%     end
end
