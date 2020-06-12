%%this is to interpolate to a specific array for each epoch- This makes all
%%touch and gaze data at the timepoints of arrayforinterpolation.
function [InterpolatedTrialWiseData]= tn_interpTrialDataEpoch(TrialWiseData, ArrayforInterpolation)
[a b]=size(TrialWiseData.timepoints);
% 

lengthOfInterpolated=length(ArrayforInterpolation);

        
c=lengthOfInterpolated;

for i= 1:a
    if ~isnan(TrialWiseData.timepoints(i,1))
        InterpolatedTrialWiseData.timepoints(i,1:b)=NaN;
        

        InterpolatedTrialWiseData.timepoints(i,1:length((ArrayforInterpolation)))=(ArrayforInterpolation);
        
        LastTimepoint=max(TrialWiseData.timepoints(i,:));
        LastTimepoint_idx=find(TrialWiseData.timepoints(i,:) ==max(TrialWiseData.timepoints(i,:)));
        
        
        TotalNaN=find(isnan(TrialWiseData.timepoints(i,:)));
        if ~isempty(TotalNaN)
            
            if TotalNaN(1)<LastTimepoint_idx
                TrialWiseData.timepoints(i,TotalNaN(1))=0;
            end
        end
        TrialWiseData.timepoints(i,:)=sort(TrialWiseData.timepoints(i,:));
        sametimept= find(diff(TrialWiseData.timepoints(i,:))==0);
        if length(sametimept)>0  %%Again I just check whether there are multiple daa pts on the same time pt and just add 1e-7 on the subsequent one
            TrialWiseData.timepoints(i,sametimept+1)=TrialWiseData.timepoints(i,sametimept+1)+(1e-7);
        end
        x=TrialWiseData.timepoints(i,1:LastTimepoint_idx);
        vx=TrialWiseData.xCoordinates(i,1:LastTimepoint_idx);
        xq=InterpolatedTrialWiseData.timepoints(i,1:c);
        vy=TrialWiseData.yCoordinates(i,1:LastTimepoint_idx);
        stoppt=i
        InterpolatedTrialWiseData.xCoordinates(i,1:b)=NaN; %% NaNs aare just added at the end of each trial to make the size cosistent. 
        InterpolatedTrialWiseData.yCoordinates(i,1:b)=NaN;
%         
%        [x, index] = unique(x); yi = interp1(x, y(index), xi);
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