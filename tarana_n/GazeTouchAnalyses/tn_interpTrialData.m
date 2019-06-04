%%This is for the interpolation of the whole data to being just equally
%%spaced, on a trial-by-trial fashion for Gaze
function [InterpolatedTrialWiseData]= tn_interpTrialData(TrialWiseData)
[a b]=size(TrialWiseData.timepoints);
InterpolatedTrialWiseData.TrialNumber=TrialWiseData.TrialNumber;
for i= 1:a
    if ~isnan(TrialWiseData.timepoints(i,1))
        InterpolatedTrialWiseData.timepoints(i,1:b)=NaN;
        LastTimepoint=max(TrialWiseData.timepoints(i,:));
        [r, LastTimepoint_idx]=find(TrialWiseData.timepoints ==max(TrialWiseData.timepoints(i,:)));
        InterpolatedTrialWiseData.timepoints(i,1:length((TrialWiseData.timepoints(i,1):2:LastTimepoint)))=(TrialWiseData.timepoints(i,1):2:LastTimepoint);
        lengthOfInterpolated=length((TrialWiseData.timepoints(i,1):2:LastTimepoint));
        [r c]=size(InterpolatedTrialWiseData.timepoints(i,:));
        TrialWiseData.timepoints(i,:)=sort(TrialWiseData.timepoints(i,:));
        sametimept= find(diff(TrialWiseData.timepoints(i,:))==0);
        if length(sametimept)>0 %%here I check whether there are data points on the same time points
            TrialWiseData.timepoints(i,sametimept+1)=TrialWiseData.timepoints(i,sametimept+1)+(1e-7); % And if yes, I simply add a very small number (like 1e-7) to it
        end
        x=TrialWiseData.timepoints(i,1:LastTimepoint_idx);
        vx=TrialWiseData.xCoordinates(i,1:LastTimepoint_idx);
        xq=InterpolatedTrialWiseData.timepoints(i,1:lengthOfInterpolated);
        vy=TrialWiseData.yCoordinates(i,1:LastTimepoint_idx);
        stoppt=i
        InterpolatedTrialWiseData.xCoordinates(i,1:b)=NaN;
        InterpolatedTrialWiseData.yCoordinates(i,1:b)=NaN;
%         
%        [x, index] = unique(x); yi = interp1(x, y(index), xi);
        if c< b-1
            InterpolatedTrialWiseData.timepoints(i,c+1:b)=NaN; %% This is just to add NaNs in the end to make the table size consistent
            
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