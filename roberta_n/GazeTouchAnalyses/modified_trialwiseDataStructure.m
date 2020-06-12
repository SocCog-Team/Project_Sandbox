function[TrialWiseData]= modified_trialwiseDataStructure(xytime,trialnum_tracker,nrows_maintask)
    TrialWiseData=([]);
    for trialnum= 1:nrows_maintask
        trialnum_idx=find(trialnum_tracker==trialnum);
        if trialnum~=0 && isempty(trialnum_idx)~=1
            TrialWiseData.TrialNumber(trialnum,1)=trialnum;
        
            TrialWiseData.timepoints(trialnum,1:length(trialnum_idx))=xytime(trialnum_idx,29);
            TrialWiseData.xCoordinates(trialnum,1:length(trialnum_idx))=xytime(trialnum_idx,2);
	
			            
			TrialWiseData.yCoordinates(trialnum,1:length(trialnum_idx))=xytime(trialnum_idx,3);

        end
    end
    TrialWiseData.timepoints(TrialWiseData.timepoints==0) = NaN;   
    TrialWiseData.xCoordinates(TrialWiseData.xCoordinates==0) = NaN;   
    TrialWiseData.yCoordinates(TrialWiseData.yCoordinates==0) = NaN;   

end