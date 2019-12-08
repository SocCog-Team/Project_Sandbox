%%Euclidean distance between Gaze and Touch 
function [distGazeTouch]= rn_distbetweenGazeTouch(epochdataGaze, epochdataTouch)


[rowsGaze colsGaze]= size(epochdataGaze.timepoints);
[rowsTouch colsTouch]= size(epochdataTouch.timepoints);
numRows=min(rowsGaze,rowsTouch);
distGazeTouch = sqrt((epochdataGaze.xCoordinates(1:numRows,:) - epochdataTouch.xCoordinates(1:numRows,:)).^2 + (epochdataGaze.yCoordinates(1:numRows,:) - epochdataTouch.yCoordinates(1:numRows,:)).^2);

end

