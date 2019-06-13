%%This is to extract valid points from the Touch Tracker Log Files
%%Input: Filename/ location of the TouchTracker Log File, TrialLog Structure
%%Output: validUnique_touchpoints- Data structure which has only Valid and
%%Unique(This is done because Touchtracker gives multiple data points on the same time point; which we don't want) touch points
%trialnum_tracker_Touchpoints- TrialNumbers list
function [validUnique_touchpoints, touchtracker_datastruct, trialnum_tracker_Touchpoints]= fn_PQtrackerdata(filename,maintask_datastruct)
touchtracker_datastruct=fnParseEventIDETrackerLog_v01 (filename, ';', [], []);
[a,b]=unique(touchtracker_datastruct.data(:,1),'last');

nrows_maintask=0;
ncols_maintask=0;
[nrows_maintask,ncols_maintask]=size(maintask_datastruct.report_struct.data);
valid_touch_datapoints=find(touchtracker_datastruct.data(:,11)~=-2147483648.00000);
validUnique_touchpoints_idx=intersect(valid_touch_datapoints,b);
validUnique_touchpoints=[];
validUnique_touchpoints.header=touchtracker_datastruct.header;
validUnique_touchpoints.data=touchtracker_datastruct.data(validUnique_touchpoints_idx,:);
[trialnum_tracker_Touchpoints]= fn_trialnumber (maintask_datastruct,validUnique_touchpoints );


end
