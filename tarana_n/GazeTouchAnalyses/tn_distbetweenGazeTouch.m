%%Just simple subtraction of the gaze and touch data
function [distGazeTouch]= tn_distbetweenGazeTouch(epochdataGaze, epochdataTouch)
[rowsGaze colsGaze]= size(epochdataGaze.timepoints);
[rowsTouch colsTouch]= size(epochdataTouch.timepoints);

numRows=min(rowsGaze,rowsTouch);
distGazeTouch(1:numRows,:)= (epochdataGaze.xCoordinates(1:numRows,:)-epochdataTouch.xCoordinates(1:numRows,:));


end