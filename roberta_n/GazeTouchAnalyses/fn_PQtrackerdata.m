%%This is to extract valid points from the Touch Tracker Log Files
%%Input: Filename/ location of the TouchTracker Log File, TrialLog Structure
%%Output: validUnique_touchpoints- Data structure which has only Valid and
%%Unique(This is done because Touchtracker gives multiple data points on the same time point; which we don't want) touch points
%trialnum_tracker_Touchpoints- TrialNumbers list
function [touchtracker_datastruct, trialnum_tracker_Touchpoints] = fn_PQtrackerdata(touchtracker_datastruct, maintask_datastruct, trial_start_ts_col, trial_start_offset_ms, trial_end_ts_col, trial_end_offset_ms)
% touchtracker_datastruct=fnParseEventIDETrackerLog_v01 (filename, ';', [], []);
[a, last_idx_per_unique_timestamp_idx] = unique(touchtracker_datastruct.data(:, touchtracker_datastruct.cn.EventIDE_TimeStamp), 'last'); % for the time being only select the last sample per time point

% nrows_maintask = 0;
% ncols_maintask = 0;
%[nrows_maintask, ncols_maintask] = size(maintask_datastruct.report_struct.data);
valid_touch_datapoints = find(touchtracker_datastruct.data(:,11)~=-2147483648.00000);
validUnique_touchpoints_idx = intersect(valid_touch_datapoints, last_idx_per_unique_timestamp_idx);
%validUnique_touchpoints = [];
%validUnique_touchpoints.header = touchtracker_datastruct.header;
%validUnique_touchpoints.data = touchtracker_datastruct.data(validUnique_touchpoints_idx,:);
%trialnum_tracker_Touchpoints = fn_trialnumber(maintask_datastruct, validUnique_touchpoints );

touchtracker_datastruct.data = touchtracker_datastruct.data(validUnique_touchpoints_idx, :);
trialnum_tracker_Touchpoints = fn_assign_trialnum2samples_by_range(maintask_datastruct.report_struct, touchtracker_datastruct, trial_start_ts_col, trial_start_offset_ms, trial_end_ts_col, trial_end_offset_ms);
 
end
