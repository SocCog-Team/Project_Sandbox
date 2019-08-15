function [] = fn_gaze_recalibrator(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType)
%FN_GAZE_RECALIBRATOR Analyse simple dot following gaze mapping data to
%generate better registration matrices to convert "raw" gaze data into
%eventIDE pixel coordinates
%   The main idea behind this function is to first associate known taget
%   positions with gaze samples when the subject fixated that target and
%   then use these as control point pairs to feed matlab's fitgeotrans
%   function to get mapping "tforms" that allow to get a better
%   registration between measured sample coordinates and "real" screen
%   coordinates.

timestamp_list.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);

% eventIDE sets the top left corner as (0,0), matlab sets the bottom left
% corner to (0,0) to make the up down directions in matlab appear correct
% we need to adjust the eventide values prior to display into the matlab
% coordinate system by using the following formula:
%	matlab_y_value = (eventide_y_value * -1) + eventide_screen_height_pix
eventide_screen_height_pix = 1080;


debug = 0;
% exclude samples with higher instantaneous veolicity than this value, this
% will allow to reject samples during saccades
if ~exist('velocity_threshold_pixels_per_sample', 'var') || isempty(velocity_threshold_pixels_per_sample)
	velocity_threshold_pixels_per_sample = 0.05;
end

% how many milliseconds to ignore after the onset of a new fixation target,
% to allow the subject to saccade to the new target
if ~exist('saccade_allowance_time_ms', 'var') || isempty(saccade_allowance_time_ms)
	saccade_allowance_time_ms = 200;
end

% this defines the radius in pixels around the center of the cluster
% selector for the tested gaze target positions
if ~exist('acceptable_radius_pix', 'var') || isempty(acceptable_radius_pix)
	acceptable_radius_pix = 10;
end

% this defines the registration method to use to generate the mapping
% between identified sample positions and corresponding target positions
if ~exist('transformationType', 'var') || isempty(transformationType)
	transformationType = 'affine';
end


% TODO remove this
if ~exist('gaze_tracker_logfile_FQN', 'var')	
	%fileID='20190729T154225.A_Elmo.B_None.SCP_01.';
	if (ispc)
		saving_dir='C:\taskcontroller\SCP_DATA\ANALYSES\GazeAnalyses';
		data_root_str = 'C:';
		data_dir = fullfile(data_root_str, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190729', '20190729T154225.A_Elmo.B_None.SCP_01.sessiondir');
		
	else
		data_root_str = '/';
		saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN');
		data_base_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ');
		
		% network!
		data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data');
		data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190729', '20190729T154225.A_Elmo.B_None.SCP_01.sessiondir');
	
		
	end
	
	if ~exist('EyeLinkfilenameA', 'var')
		gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190729T154225.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog.txt.gz');
		gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190729T154225.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
	end
	
end

%if ~exist('gaze_tracker_logfile_FQN', 'var') || isempty(gaze_tracker_logfile_FQN) 
if isempty(gaze_tracker_logfile_FQN) 
	[gaze_tracker_logfile_name, gaze_tracker_logfile_path] = uigetfile('*.trackerlog.*', 'Select gaze calibration trackerlogfile');
	gaze_tracker_logfile_FQN = fullfile(gaze_tracker_logfile_path, gaze_tracker_logfile_name);
end

[gaze_tracker_logfile_path, gaze_tracker_logfile_name, gaze_tracker_logfile_ext] = fileparts(gaze_tracker_logfile_FQN);


% different gaze tracker produce different tracker log files, to handle
% these differences allow the user to explicitly specify the type
if ~exist('tracker_type', 'var') || isempty(tracker_type)
	if ~isempty(regexpi(gaze_tracker_logfile_name, 'eyelink'))
		tracker_type = 'eyelink';
	end
	if ~isempty(regexpi(gaze_tracker_logfile_name, 'pupillabs'))
		tracker_type = 'pupillabs';
		error([mfilename, ': Tracker typr pupillabs not implemented yet.']);
	end	
end


% load the data	(might take a while)
data_struct = fnParseEventIDETrackerLog_v01(gaze_tracker_logfile_FQN, ';', [], []);
ds_colnames = data_struct.cn;

% take the best available time stamps from the tracker file
if isfield(ds_colnames, 'Tracker_corrected_EventIDE_TimeStamp')
	timestamp_list = data_struct.data(:, ds_colnames.Tracker_corrected_EventIDE_TimeStamp);
else
	timestamp_list = data_struct.data(:, ds_colnames.EventIDE_TimeStamp);
end
% resort by timestamp
[sorted_timestamp_list, timestamp_sort_idx] = sort(timestamp_list);
if ~isequal(sorted_timestamp_list, timestamp_list);
	data_struct.data = data_struct.data(timestamp_sort_idx, :);
	timestamp_list = sorted_timestamp_list;
end

% extract the columns with the eventIDE coordinates for fixation target and the gaze data
fix_target_x_list = (data_struct.data(:, ds_colnames.FixationPointX));
fix_target_y_list = (data_struct.data(:, ds_colnames.FixationPointY));

fix_target_y_list_flipped = fn_convert_eventide2_matlab_coord(fix_target_y_list);

% extract the columns with the eventIDE coordinates for the gaze data
% these are not guaranteed to employ the final/best eventIDE linear
% registration "matrix" yet.
eventide_gaze_x_list = data_struct.data(:, ds_colnames.Gaze_X);
eventide_gaze_y_list = data_struct.data(:, ds_colnames.Gaze_Y);

% extract the final calibration values
calibration.gain_x = data_struct.data(end, ds_colnames.GLM_Coefficients_GainX);
calibration.gain_y = data_struct.data(end, ds_colnames.GLM_Coefficients_GainY);
calibration.offset_x = data_struct.data(end, ds_colnames.GLM_Coefficients_OffsetX);
calibration.offset_y = data_struct.data(end, ds_colnames.GLM_Coefficients_OffsetY);

% extract the GLM data for all samples
calibration_gain_x_list = data_struct.data(:, ds_colnames.GLM_Coefficients_GainX);
calibration_gain_y_list = data_struct.data(:, ds_colnames.GLM_Coefficients_GainY);
calibration_offset_x_list = data_struct.data(:, ds_colnames.GLM_Coefficients_OffsetX);
calibration_offset_y_list = data_struct.data(:, ds_colnames.GLM_Coefficients_OffsetY);
% undo all variable calibration to get back to something resembling the
% tracker's raw gaze values
raw_eventide_gaze_x_list = (eventide_gaze_x_list ./ calibration_gain_x_list) - calibration_offset_x_list;
raw_eventide_gaze_y_list = (eventide_gaze_y_list ./ calibration_gain_y_list) - calibration_offset_y_list;
% apply the final eventIDE GLM calibration matrix to all samples, as that
% should be at least acceptable. Note, we only do this so loading and
% displaying gaze and target data in the same plot looks reasonable and
% that we can approximate the instantaneous velocity.
cal_eventide_gaze_x_list = (raw_eventide_gaze_x_list * calibration.gain_x) + calibration.offset_x;
cal_eventide_gaze_y_list = (raw_eventide_gaze_y_list * calibration.gain_y) + calibration.offset_y;

% replace later
cal_eventide_gaze_y_list_flipped = fn_convert_eventide2_matlab_coord(cal_eventide_gaze_y_list);


% calculate the pixel displacement between consecutive samples
displacement_x_list = diff(cal_eventide_gaze_x_list);
displacement_x_list(end+1) = NaN;	% we want the displacement for all samples so thatr all indices match

displacement_y_list = diff(cal_eventide_gaze_y_list);
displacement_y_list(end+1) = NaN;	% we want the displacement for all samples so thatr all indices match

% now calculate the total displacement as euclidean distance in 2D
% for any fixed sampling rate this velocity in pixels/sample correlates 
% strongly with the instantaneous velocity in pixel/time
per_sample_euclidean_displacement_pix_list = sqrt((((displacement_x_list).^2) + ((displacement_y_list).^2)));
if (debug)
	histogram(per_sample_euclidean_displacement_pix_list, (0.00:0.001:1.0));
end

% this is the "real" velocity in per time units
sample_period_ms = unique(diff(timestamp_list));
velocity_pix_ms = per_sample_euclidean_displacement_pix_list / fn_robust_mean(sample_period_ms);


% index samples with instantaneous volicity below and above the threshold
low_velocity_samples_idx = find(per_sample_euclidean_displacement_pix_list <= velocity_threshold_pixels_per_sample);
high_velocity_samples_idx = find(per_sample_euclidean_displacement_pix_list > velocity_threshold_pixels_per_sample);

% find consecutive samples with below velocity_threshold_pixels_per_sample
% changes
fixation_points_idx_diff = diff(low_velocity_samples_idx);
fixation_points_idx_diff(end+1) = 10; % the value does not matter as long as it is >1 for the next line
tmp_lidx = fixation_points_idx_diff <= 1;
% these idx have >= 2 samples of below threshold velocity -> proto
% fixations instead of saccades.
fixation_samples_idx = low_velocity_samples_idx(tmp_lidx);
fixation_target_visible_sample_idx = find(data_struct.data(:, ds_colnames.FixationPointVisible) >= 1); %points that are visible


% extract the FixationTarget information by sample
fixation_target.by_sample.header = {'FixationPointX', 'FixationPointY', 'FixationPointID', 'timestamp'};
fixation_target.by_sample.cn = local_get_column_name_indices(fixation_target.by_sample.header);
FTBS_cn = fixation_target.by_sample.cn;

fixation_target.by_sample.table = zeros([size(data_struct.data, 1), 3]);
fixation_target.by_sample.table(:, 1:2) = [data_struct.data(:, ds_colnames.FixationPointX),(data_struct.data(:, ds_colnames.FixationPointY))];
fixation_target.by_sample.table(:, FTBS_cn.FixationPointID) = -1; % faster than NaN ad also not a valid index
fixation_target.by_sample.table(:, FTBS_cn.timestamp) = timestamp_list;

% assign an ID to each fixation target position
% now find the unique displayed fixation target positions
existing_fixation_target_x_y_coordinate_list = unique(fixation_target.by_sample.table(:, 1:2), 'rows');

zero_offset = 0;	% handle absence of the no fixation targt displayed condition gracefully
for i_fixation_target_x_y_coordinate = 1 : length(existing_fixation_target_x_y_coordinate_list)
	current_target_ID = i_fixation_target_x_y_coordinate - zero_offset;
	if existing_fixation_target_x_y_coordinate_list(i_fixation_target_x_y_coordinate, :) == [0, 0]
		zero_offset = 1;
		current_target_ID = i_fixation_target_x_y_coordinate - zero_offset;
	end
	current_target_ID_lidx = fixation_target.by_sample.table(:, FTBS_cn.FixationPointX) == existing_fixation_target_x_y_coordinate_list(i_fixation_target_x_y_coordinate, 1) ...
							& fixation_target.by_sample.table(:, FTBS_cn.FixationPointY) == existing_fixation_target_x_y_coordinate_list(i_fixation_target_x_y_coordinate, 2);
	fixation_target.by_sample.table(current_target_ID_lidx, FTBS_cn.FixationPointID) = current_target_ID;
end

% now find the transitions between fixation target position (also on/off transitions)
switch_list = diff(fixation_target.by_sample.table(:, FTBS_cn.FixationPointID)); % a switch results in a change of the FixationPointID
preswitch_trial_idx = find(switch_list ~= 0);	% these are the indices of the trials just before a transition
switch_trial_idx = preswitch_trial_idx + 1;		% these are the indices of the trials just after a transition
% allow existence or absence of no fixation_target displayed samples
unique_fixation_targets = unique(fixation_target.by_sample.table(:, FTBS_cn.FixationPointID));
nonzero_unique_fixation_target_idx = find(unique_fixation_targets);

% intialize tables
targetstart_ts_idx = [1; switch_trial_idx];
targetend_ts_idx = [preswitch_trial_idx; size(fixation_target.by_sample.table, 1)];
good_target_sample_points_lidx = zeros([size(fixation_target.by_sample.table, 1), 1]);
fixation_target_position_table = zeros([length(nonzero_unique_fixation_target_idx), 2]);

% collect sample indices while targets are displayed (for at least
% saccade_allowance_time_ms)
for i_switch = 1 : length(targetstart_ts_idx)
	current_start_idx = targetstart_ts_idx(i_switch);
	current_end_idx = targetend_ts_idx(i_switch);	
	current_start_ts = timestamp_list(current_start_idx);
	current_end_ts = timestamp_list(current_end_idx);
	current_target_ID = fixation_target.by_sample.table(current_start_idx, FTBS_cn.FixationPointID);
	current_target_duration = current_end_ts - current_start_ts;
	
	% get the fixation target's cordinates
	current_target_x = fixation_target.by_sample.table(current_start_idx, FTBS_cn.FixationPointX);
	current_target_y = fixation_target.by_sample.table(current_start_idx, FTBS_cn.FixationPointY);
	if current_target_duration >= saccade_allowance_time_ms
		%found a long enough target display duration
		% find the start_idx
		offset_start_ts = current_start_ts + saccade_allowance_time_ms;
		proto_offset_start_idx_list = find(timestamp_list >= offset_start_ts);
		offset_start_idx = proto_offset_start_idx_list(1);
		good_target_sample_points_lidx(offset_start_idx: current_end_idx) = 1;
	end
	% store the coordinates in the reduced table
	if current_target_ID ~= 0
		fixation_target_position_table(current_target_ID, :) = [current_target_x, current_target_y];
	end
	
end
% list of target samples with required minimal presentation duration
good_target_sample_points_idx = find(good_target_sample_points_lidx);
bad_target_sample_points_idx = find(good_target_sample_points_lidx == 0);

%CLEAN-UP CURSOR




figure_handle = figure('Name', ['Roberta''s gaze visualizer: ', gaze_tracker_logfile_name, gaze_tracker_logfile_ext]);
% subplot(2, 1, 2)
plot(fix_target_x_list(:),fix_target_y_list(:),'s','MarkerSize',10,'MarkerFaceColor',[1 0 0]);

set(gca(), 'XLim', [(960-300) (960+300)], 'YLim', [(1080-500-200) (1080-500+400)]);

hold on
% full traces all points with lines in between
plot(cal_eventide_gaze_x_list(:),cal_eventide_gaze_y_list_flipped(:),'b','LineWidth', 1, 'Color', [0.8 0.8 0.8])
% blue fixation points
plot(cal_eventide_gaze_x_list(fixation_samples_idx), cal_eventide_gaze_y_list_flipped(fixation_samples_idx), 'LineWidth', 1, 'LineStyle', 'none', 'Color', 'b', 'Marker', '+', 'Markersize', 1);
% magenta, points exceeding the velocity threshold
plot(cal_eventide_gaze_x_list(low_velocity_samples_idx), cal_eventide_gaze_y_list_flipped(low_velocity_samples_idx), 'LineWidth', 1, 'LineStyle', 'none', 'Color', 'm', 'Marker', '+', 'Markersize', 1);
% points immediately after fixation point onsets, when the sunbject can not fixate
plot(cal_eventide_gaze_x_list(bad_target_sample_points_idx),cal_eventide_gaze_y_list_flipped(bad_target_sample_points_idx), 'LineWidth',1, 'LineStyle', 'none', 'Color', 'r', 'Marker', '+', 'Markersize', 1);
% surviving points
plot(cal_eventide_gaze_x_list(fixation_target_visible_sample_idx),cal_eventide_gaze_y_list_flipped(fixation_target_visible_sample_idx),'LineWidth',1, 'LineStyle', 'none', 'Color', [0 0.8 0], 'Marker', '+', 'Markersize', 1);





nonzero_unique_fixation_target_idx = find(unique_fixation_targets);
x_y_mouse_y_flipped = zeros([length(nonzero_unique_fixation_target_idx), 2]);

cal_eventide_gaze_y_list_flipped = (tmp2_gaze_y .* -1) + 1080; %flipped
fixation_target_position_table_flipped = [fixation_target_position_table(:,1), ((fixation_target_position_table(:,2) .* -1) + 1080)];

for i_fix_target = 1 : length(find(unique_fixation_targets))
	unique_fixation_target_id = unique_fixation_targets(nonzero_unique_fixation_target_idx(i_fix_target));
	
	title(['Select the center of the gaze sample cloud belonging to fixzation target ', num2str(unique_fixation_target_id), ', press enter after selection.']);
	plot(fixation_target_position_table_flipped(unique_fixation_target_id, 1), fixation_target_position_table_flipped(unique_fixation_target_id, 2), 'LineWidth', 4, 'LineStyle', 'none', 'Color', 'r', 'Marker', '+', 'Markersize', 15);
	
	[tmp_x_list, tmp_y_list]= getpts;
	
	if isempty(tmp_x_list)
		tmp_x_list = NaN;
		tmp_y_list = NaN;
	end
	
	x_y_mouse_y_flipped(i_fix_target, 1) = tmp_x_list(end);

    x_y_mouse_y_flipped(i_fix_target, 2) = tmp_y_list(end);

	
	
	plot(fixation_target_position_table_flipped(unique_fixation_target_id, 1), fixation_target_position_table_flipped(unique_fixation_target_id, 2), 'LineWidth', 4, 'LineStyle', 'none', 'Color', 'k', 'Marker', '+', 'Markersize', 15);
	
plot(x_y_mouse_y_flipped(i_fix_target, 1), x_y_mouse_y_flipped(i_fix_target, 2), 'LineWidth', 4, 'LineStyle', 'none', 'Color', 'k', 'Marker', 'x', 'Markersize', 15);
end

saveas (gcf,'Select the center of the gaze sample cloud belonging to fixation target.fig')

%x_y_mouse = [x_y_mouse_y_flipped(:, 1), ((x_y_mouse_y_flipped(:,2) .* -1) + 1080)];
x_y_mouse = [x_y_mouse_y_flipped(:, 1), x_y_mouse_y_flipped(:,2)];
hold off
xlim([(960-300) (960+300)]);
ylim ([(1080-500-200) (1080-500+400)]);

nonzero_unique_fixation_target_idx = find(unique_fixation_targets);

euclidean_distance_array = zeros([size(cal_eventide_gaze_x_list, 1), length(nonzero_unique_fixation_target_idx)]);



for i_fix_target = 1 : length(find(unique_fixation_targets))
	unique_fixation_target_id = unique_fixation_targets(nonzero_unique_fixation_target_idx(i_fix_target));
	
	euclidean_distance_array(:, unique_fixation_target_id) = sqrt(((cal_eventide_gaze_x_list - x_y_mouse_y_flipped(unique_fixation_target_id, 1)).^2 ) + ...
																	((cal_eventide_gaze_y_list_flipped - x_y_mouse_y_flipped(unique_fixation_target_id, 2)).^2 ));
	
	if (debug)
		figure_h = figure('Name', ['FixationTarget_', num2str(unique_fixation_target_id)]);
		histogram(euclidean_distance_array(:, unique_fixation_target_id), (0.00:1:650));
	end
end


%histogram((euclidean_distance(:, :)),(0.00:1:650));


% acceptable_radius_pix
points_close_2_fixation_centers_idx = [];
distance_gaze_2_target_pix = [];
for i_fix_target = 1 : length(find(unique_fixation_targets))
	unique_fixation_target_id = unique_fixation_targets(nonzero_unique_fixation_target_idx(i_fix_target));
	current_points_idx = find(euclidean_distance_array(:, unique_fixation_target_id) <= acceptable_radius_pix);
	distance_gaze_2_target_pix = [distance_gaze_2_target_pix; euclidean_distance_array(current_points_idx, unique_fixation_target_id)];
	points_close_2_fixation_centers_idx = [points_close_2_fixation_centers_idx; current_points_idx];
end

points_close_2_fixation_centers_idx = sort(points_close_2_fixation_centers_idx);

tmp_target_selected_samples = [data_struct.data(points_close_2_fixation_centers_idx, ds_colnames.FixationPointX) data_struct.data(points_close_2_fixation_centers_idx, ds_colnames.FixationPointY)];

tmp_gaze_selected_samples = [cal_eventide_gaze_x_list(points_close_2_fixation_centers_idx) cal_eventide_gaze_y_list(points_close_2_fixation_centers_idx)];
figure('Name', 'selected_samples');
plot(tmp_target_selected_samples(:, 1), tmp_target_selected_samples(:, 2), 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '+', 'MarkerSize', 12);
hold on
plot(tmp_gaze_selected_samples(:, 1), tmp_gaze_selected_samples(:, 2), 'Color', [1 0 0], 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '.', 'MarkerSize', 1);
hold off


% select list of target x and y and gaze x and y values for all sample
% points with euclidean_distance <= acceptable_radius_pix, and
% euclidean_distance-in_time <= velocity_threshold_pixels_per_sample

selected_samples_idx = (1:1:size(euclidean_distance_array, 1))';
selected_samples_idx = intersect(selected_samples_idx, points_close_2_fixation_centers_idx);

% this here is pixel distance between samples over time!
selected_samples_idx = intersect(selected_samples_idx, find(per_sample_euclidean_displacement_pix_list <= velocity_threshold_pixels_per_sample));

% only samples xx ms after target onset
selected_samples_idx = intersect(selected_samples_idx, good_target_sample_points_idx);

% exclude the epochs witout a displayed target
selected_samples_idx = intersect(selected_samples_idx, find(fixation_target.by_sample.table(:, 3)));


% for re-registering the raw gaze data, exclude samples with invalid
% tracker data (tracker specific?)
switch(tracker_type)
	case 'eyelink'
		out_of_bounds_marker_value = -32768;
		valid_right_eye_raw_idx = find(data_struct.data(:, ds_colnames.Right_Eye_Raw_X) ~= out_of_bounds_marker_value);
		valid_left_eye_raw_idx = find(data_struct.data(:, ds_colnames.Left_Eye_Raw_X) ~= out_of_bounds_marker_value);
		valid_eye_raw_idx = intersect(valid_right_eye_raw_idx, valid_left_eye_raw_idx);
		selected_samples_idx = intersect(selected_samples_idx, valid_eye_raw_idx);
	otherwise
		error(['tracker_type: ', tracker_type, ' not yet supported.']);
end


% moving
gaze_selected_samples = [data_struct.data(selected_samples_idx, ds_colnames.cal_eventide_gaze_x_list) data_struct.data(selected_samples_idx, ds_colnames.cal_eventide_gaze_y_list_flipped)];
gaze_selected_samples = [cal_eventide_gaze_x_list(selected_samples_idx) cal_eventide_gaze_y_list(selected_samples_idx)];


%

right_raw_gaze_selected_samples = [data_struct.data(selected_samples_idx, ds_colnames.Right_Eye_Raw_X) data_struct.data(selected_samples_idx, ds_colnames.Right_Eye_Raw_Y)];
left_raw_gaze_selected_samples = [data_struct.data(selected_samples_idx, ds_colnames.Left_Eye_Raw_X) data_struct.data(selected_samples_idx, ds_colnames.Left_Eye_Raw_Y)];

%fixed
target_selected_samples = [data_struct.data(selected_samples_idx, ds_colnames.FixationPointX) data_struct.data(selected_samples_idx, ds_colnames.FixationPointY)];





tform = fitgeotrans(target_selected_samples, gaze_selected_samples, transformationType);
tform_right_raw = fitgeotrans(target_selected_samples, right_raw_gaze_selected_samples, transformationType);
tform_left_raw = fitgeotrans(target_selected_samples, left_raw_gaze_selected_samples, transformationType);


save('tform.mat','tform');



%[registered_gaze_selected_samples] = transformPointsForward(tform, target_selected_samples); 
%[registered_gaze_selected_samples] = transformPointsForward(tform, gaze_selected_samples); 
%[registered_gaze_selected_samples] = transformPointsForward(tform, gaze_selected_samples); 
[registered_gaze_selected_samples] = transformPointsInverse(tform, gaze_selected_samples); 

registered_left_raw_gaze_selected_samples = transformPointsInverse(tform_left_raw, left_raw_gaze_selected_samples); 
registered_right_raw_gaze_selected_samples = transformPointsInverse(tform_right_raw, right_raw_gaze_selected_samples); 


figure('Name', 'applied registration');

plot(target_selected_samples(:, 1), target_selected_samples(:, 2), 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '+', 'MarkerSize', 12);
hold on
plot(gaze_selected_samples(:, 1), gaze_selected_samples(:, 2), 'Color', [1 0 0], 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '.', 'MarkerSize', 1);
plot(registered_gaze_selected_samples(:, 1), registered_gaze_selected_samples(:, 2), 'Color', [0 0.8 0], 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '.', 'MarkerSize', 1);
hold off

saveas(gcf,'applied_registration.fig');

left_right_raw_fh = figure('Name', 'Left/Right raw gaze samples re-registered');
subplot(1, 2, 1);
plot(target_selected_samples(:, 1), target_selected_samples(:, 2), 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '+', 'MarkerSize', 12);
hold on
plot(left_raw_gaze_selected_samples(:, 1), left_raw_gaze_selected_samples(:, 2), 'Color', [1 0 0], 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '.', 'MarkerSize', 1);
plot(registered_left_raw_gaze_selected_samples(:, 1), registered_left_raw_gaze_selected_samples(:, 2), 'Color', [0 0.8 0], 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '.', 'MarkerSize', 1);
hold off
title('left eye');
axis equal


subplot(1, 2, 2);
plot(target_selected_samples(:, 1), target_selected_samples(:, 2), 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '+', 'MarkerSize', 12);
hold on
plot(right_raw_gaze_selected_samples(:, 1), right_raw_gaze_selected_samples(:, 2), 'Color', [1 0 0], 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '.', 'MarkerSize', 1);
plot(registered_right_raw_gaze_selected_samples(:, 1), registered_right_raw_gaze_selected_samples(:, 2), 'Color', [0 0.8 0], 'LineWidth', 3, 'LineStyle', 'None', 'Marker', '.', 'MarkerSize', 1);
hold off
title('right eye');
axis equal
write_out_figure(left_right_raw_fh, fullfile(gaze_tracker_logfile_path, 'left_right_raw.pdf'));



% how long did it take?
timestamp_list.(mfilename).end = toc(timestamp_list.(mfilename).start);
disp([mfilename, ' took: ', num2str(timestamp_list.(mfilename).end), ' seconds.']);
disp([mfilename, ' took: ', num2str(timestamp_list.(mfilename).end / 60), ' minutes. Done...']);


return
end


function [ ret_val ] = write_out_figure(img_fh, outfile_fqn, verbosity_str, print_options_str)
%WRITE_OUT_FIGURE save the figure referenced by img_fh to outfile_fqn,
% using .ext of outfile_fqn to decide which image type to save as.
%   Detailed explanation goes here
% write out the data

if ~exist('verbosity_str', 'var')
	verbosity_str = 'verbose';
end

% check whether the path exists, create if not...
[pathstr, name, img_type] = fileparts(outfile_fqn);
if isempty(dir(pathstr)),
	mkdir(pathstr);
end

% deal with r2016a changes, needs revision
if (strcmp(version('-release'), '2016a'))
	set(img_fh, 'PaperPositionMode', 'manual');
	if ~ismember(img_type, {'.png', '.tiff', '.tif'})
		print_options_str = '-bestfit';
	end
end

if ~exist('print_options_str', 'var') || isempty(print_options_str)
	print_options_str = '';
else
	print_options_str = [', ''', print_options_str, ''''];
end
resolution_str = ', ''-r600''';





device_str = [];

switch img_type(2:end)
	case 'pdf'
		% pdf in 7.3.0 is slightly buggy...
		%print(img_fh, '-dpdf', outfile_fqn);
		device_str = '-dpdf';
	case 'ps3'
		%print(img_fh, '-depsc2', outfile_fqn);
		device_str = '-depsc';
		print_options_str = '';
		outfile_fqn = [outfile_fqn, '.eps'];
	case {'ps', 'ps2'}
		%print(img_fh, '-depsc2', outfile_fqn);
		device_str = '-depsc2';
		print_options_str = '';
		outfile_fqn = [outfile_fqn, '.eps'];
	case {'tiff', 'tif'}
		% tiff creates a figure
		%print(img_fh, '-dtiff', outfile_fqn);
		device_str = '-dtiff';
	case 'png'
		% tiff creates a figure
		%print(img_fh, '-dpng', outfile_fqn);
		device_str = '-dpng';
		resolution_str = ', ''-r1200''';
	case 'eps'
		%print(img_fh, '-depsc', '-r300', outfile_fqn);
		device_str = '-depsc';
	case 'fig'
		%sm: allows to save figures for further refinements
		saveas(img_fh, outfile_fqn, 'fig');
	otherwise
		% default to uncompressed images
		disp(['Image type: ', img_type, ' not handled yet...']);
end

if ~isempty(device_str)
	device_str = [', ''', device_str, ''''];
	command_str = ['print(img_fh', device_str, print_options_str, resolution_str, ', outfile_fqn)'];
	eval(command_str);
end

if strcmp(verbosity_str, 'verbose')
	if ~isnumeric(img_fh)
		disp(['Saved figure (', num2str(img_fh.Number), ') to: ', outfile_fqn]);	% >R2014b have structure figure handles
	else
		disp(['Saved figure (', num2str(img_fh), ') to: ', outfile_fqn]);			% older Matlab has numeric figure handles
	end
end

ret_val = 0;

return
end


function [converted_coord_list] = fn_convert_eventide2_matlab_coord(input_coord_list, local_offset, local_scale, direction)
% matlab and eventIDE use different coordinate systems so scale
% the default values work for the Y-axis flip and a 1080 full hd screen
% resoution

if ~exist('local_scale', 'var') ||	isempty(local_scale)
	local_scale = -1;
end

if ~exist('local_offset', 'var') ||	isempty(local_offset)
	local_offset = 1080;
end

if ~exist('direction', 'var') ||	isempty(direction)
	direction = 'forward';
end

switch (direction)
	case 'forward'
		converted_coord_list = (input_coord_list * local_scale) + local_offset;
	case {'inverse', 'backward'}
		converted_coord_list = (input_coord_list / local_scale) - local_offset;
	otherwise
		error(['Unknown direction (', direction, ') encountered, only forward and inverse are defined.']);
end
return
end


function [robust_mean] = fn_robust_mean(value_list, outlier_fraction)
% get the mean of a value list after removing the outlier_fraction part of
% the smallest and largest values, as well as ignoring NaNs, in case of
% singleton inputs simply return that value

if ~exist('outlier_fraction', 'var') || isempty(outlier_fraction)
	outlier_fraction = 0.05;
end

% this is not fully ideal, but allows to use this function to clean up
% things
if (length(value_list) == 1)
	robust_mean = value_list;
	return
end

% remove any eventual NaNs
nan_lidx = isnan(value_list);
value_list = value_list(~nan_lidx);

if isempty(value_list)
	error('No non-NaN values in value_list.');
end

% sort to allow removal of the extremes
sorted_value_list = sort(value_list);
n_values = length(sorted_value_list);

low_cutoff_idx = round(outlier_fraction * n_values);
high_cutoff_idx = n_values - low_cutoff_idx;

if low_cutoff_idx < high_cutoff_idx
	robust_mean = mean(sorted_value_list(low_cutoff_idx+1:high_cutoff_idx-1));
end

if low_cutoff_idx >= high_cutoff_idx
	% return the central value
	robust_mean = sorted_value_list(round(n_values/2));
end

return
end

function [columnnames_struct, n_fields] = local_get_column_name_indices(name_list, start_val)
% return a structure with each field for each member if the name_list cell
% array, giving the position in the name_list, then the columnnames_struct
% can serve as to address the columns, so the functions assigning values
% to the columns do not have to care too much about the positions, and it
% becomes easy to add fields.
% name_list: cell array of string names for the fields to be added
% start_val: numerical value to start the field values with (if empty start
%            with 1 so the results are valid indices into name_list)

if nargin < 2
	start_val = 1;  % value of the first field
end
n_fields = length(name_list);
for i_col = 1 : length(name_list)
	cur_name = name_list{i_col};
	% skip empty names, this allows non consequtive numberings
	if ~isempty(cur_name)
		columnnames_struct.(cur_name) = i_col + (start_val - 1);
	end
end
return
end