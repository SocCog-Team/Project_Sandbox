function [InterpolatedTrialWiseData]= tn_interpTrialDataTouch(TrialWiseData, InterpolatedTrialWiseDataGaze)
[a ab]=size(TrialWiseData.timepoints);
[ab b]=size(InterpolatedTrialWiseDataGaze.timepoints);
% InterpolatedTrialWiseData.TrialNumber=TrialWiseData.TrialNumber;
for i= 1:a
    if ~isnan(TrialWiseData.timepoints(i,1))
        InterpolatedTrialWiseData.timepoints(i,1:b)=NaN;
        LastTimepoint=max(InterpolatedTrialWiseDataGaze.timepoints(i,:));
        [r, LastTimepoint_idx]=find(InterpolatedTrialWiseDataGaze.timepoints ==max(InterpolatedTrialWiseDataGaze.timepoints(i,:)));
        LastTimepointT=max(TrialWiseData.timepoints(i,:));
        [r, LastTimepointT_idx]=find(TrialWiseData.timepoints ==max(TrialWiseData.timepoints(i,:)));
        
        InterpolatedTrialWiseData.timepoints(i,:)=InterpolatedTrialWiseDataGaze.timepoints(i,:);
%         lengthOfInterpolated=length((InterpolatedTrialWiseDataGaze.timepoints(i,1):2:LastTimepoint));
        lengthOfInterpolated=LastTimepoint_idx(1);
        
		[r c]=size(InterpolatedTrialWiseData.timepoints(i,:));
        
        
        TotalNaN=find(isnan(TrialWiseData.timepoints(i,:)));
        if ~isempty(TotalNaN)
            
            if TotalNaN(1)<LastTimepoint_idx(1)
                TrialWiseData.timepoints(i,TotalNaN(1))=0;
            end
		end
		
		x=TrialWiseData.timepoints(i,1:LastTimepointT_idx);
        vx=TrialWiseData.xCoordinates(i,1:LastTimepointT_idx);
        xq=InterpolatedTrialWiseData.timepoints(i,1:lengthOfInterpolated);
        vy=TrialWiseData.yCoordinates(i,1:LastTimepointT_idx);
        stopp=i;
        
        
        
        InterpolatedTrialWiseData.xCoordinates(i,1:b)=NaN;
        InterpolatedTrialWiseData.yCoordinates(i,1:b)=NaN;
        if c< b-1
            InterpolatedTrialWiseData.timepoints(i,c+1:b)=NaN;
            
        end
        xi=interp1(x,vx,xq);
        yi=interp1(x,vy,xq);
%         if c< b-1
%             InterpolatedTrialWiseData.xCoordinates(i,c+1:b)=NaN;
%             InterpolatedTrialWiseData.yCoordinates(i,c+1:b)=NaN;
         InterpolatedTrialWiseData.xCoordinates(i,1:length(xi))=xi;
         InterpolatedTrialWiseData.yCoordinates(i,1:length(yi))=yi;
%         end
    else
        InterpolatedTrialWiseData.timepoints(i,1:b)=NaN;
        InterpolatedTrialWiseData.xCoordinates(i,1:b)=NaN;
        InterpolatedTrialWiseData.yCoordinates(i,1:b)=NaN;
        
    end
    
end


end