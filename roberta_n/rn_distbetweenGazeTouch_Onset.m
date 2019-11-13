%%Euclidean distance between Gaze and Touch 
function [distGazeTouch]= rn_distbetweenGazeTouch_Onset(epochdataGaze, epochdataTouch)

if ~exist ('epochdataGaze.timepoints')
	[rowsGaze colsGaze]= size(epochdataGaze.TargetOnset.timepoints);
end

if ~exist ('epochdataGaze.xCoordinates')
	epochdataGaze.xCoordinates = epochdataGaze.TargetOnset.xCoordinates;
end

if ~exist ('epochdataGaze.yCoordinates')
	epochdataGaze.yCoordinates = epochdataGaze.TargetOnset.yCoordinates;
end

if ~exist ('epochdataTouch.timepoints')
	[rowsTouch colsTouch]= size(epochdataTouch.TargetOnset.timepoints);
end

if ~exist ('epochdataTouch.xCoordinates')
	epochdataTouch.xCoordinates = epochdataTouch.TargetOnset.xCoordinates;
end

if ~exist ('epochdataTouch.yCoordinates')
	epochdataTouch.yCoordinates = epochdataTouch.TargetOnset.yCoordinates;
end 

numRows=min(rowsGaze,rowsTouch);

distGazeTouch = sqrt((epochdataGaze.xCoordinates(1:numRows,:) - epochdataTouch.xCoordinates(1:numRows,:)).^2 + (epochdataGaze.yCoordinates(1:numRows,:) - epochdataTouch.yCoordinates(1:numRows,:)).^2); 

end

