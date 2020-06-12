function [] = fn_gaze_recalibrator(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, acceptable_radius_pix, transformationType)

debug = 0;

if ~exist('tracker_type', 'var') || isempty(tracker_type)
	tracker_type = 'eyelink';
end

if ~exist('velocity_threshold_pixels_per_sample', 'var') || isempty(velocity_threshold_pixels_per_sample)
	velocity_threshold_pixels_per_sample = 0.05;
end

if ~exist('acceptable_radius_pix', 'var') || isempty(acceptable_radius_pix)
	acceptable_radius_pix = 10;
end

if ~exist('transformationType', 'var') || isempty(transformationType)
	transformationType = 'affine';
end



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

if isempty(gaze_tracker_logfile_FQN)	
	[gaze_tracker_logfile_name, gaze_tracker_logfile_path] = uigetfile('*.trackerlog.*', 'Select gaze calibration trackerlogfile');
end
	
	
data_struct_extract = struct([]);

data_struct_extract = fnParseEventIDETrackerLog_v01(gaze_tracker_logfile_FQN, ';', [], []);

nrows_eyetracker = 0;
ncols_eyetracker = 0;
[nrows_eyetracker, ncols_eyetracker] = size(data_struct_extract.data);

%invalid_datapoints = find(data_struct_extract.data (:, data_struct_extract.cn.Gaze_X) == -32768); %% Removing invalid data pts as defined by eyelink/eventide
%data_struct_extract.data(invalid_datapoints, 2:3) = NaN;

fixation_point_x = (data_struct_extract.data(:, data_struct_extract.cn.FixationPointX));
fixation_point_y = (data_struct_extract.data(:, data_struct_extract.cn.FixationPointY)* -1) + 1080; %flipped

tmp_gaze_x = data_struct_extract.data(:, data_struct_extract.cn.Gaze_X);
tmp_gaze_y = data_struct_extract.data(:, data_struct_extract.cn.Gaze_Y);


calibration.gain_x = data_struct_extract.data(end, data_struct_extract.cn.GLM_Coefficients_GainX);
calibration.gain_y = data_struct_extract.data(end, data_struct_extract.cn.GLM_Coefficients_GainY);
calibration.offset_x = data_struct_extract.data(end, data_struct_extract.cn.GLM_Coefficients_OffsetX);
calibration.offset_y = data_struct_extract.data(end, data_struct_extract.cn.GLM_Coefficients_OffsetY);


tmp2_gaze_x = (data_struct_extract.data(:, data_struct_extract.cn.Right_Eye_Raw_X) * calibration.gain_x) + calibration.offset_x;
tmp2_gaze_y = (data_struct_extract.data(:, data_struct_extract.cn.Right_Eye_Raw_Y) * calibration.gain_y) + calibration.offset_y;

gaze_x = tmp2_gaze_x;
gaze_y_unflipped = tmp2_gaze_y;
gaze_y = (tmp2_gaze_y .* -1) + 1080; %flipped



dist_x = diff(gaze_x);
dist_x(end+1) = NaN;

%dist_x = [0; dist_x];
abs_dist_x = abs(dist_x);

dist_y = diff(gaze_y);
dist_y(end+1) = NaN;
%dist_y = [0; dist_y];
abs_dist_y = abs(dist_y);

euclidean_dist = sqrt((((dist_x).^2) + ((dist_y).^2)));
histogram(euclidean_dist, (0.00:0.001:1.0));

timestamps = data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp);
deltat = unique(diff(timestamps));

velocity = euclidean_dist / deltat;

tmp_fixation_points_idx = find(euclidean_dist <= velocity_threshold_pixels_per_sample);

fixation_points_idx_diff = diff(tmp_fixation_points_idx);

fixation_points_idx_diff(end+1) = 10;

tmp_idx = find(fixation_points_idx_diff <= 1);

fixation_points_idx = tmp_fixation_points_idx(tmp_idx);


validpoints_idx = find(data_struct_extract.data(:, data_struct_extract.cn.FixationPointVisible) >= 1); %points that are visible



% trials_centraltarget_x = find (data_struct_extract.data(:,26) == 960);
% trials_centraltarget_y  = find (data_struct_extract.data(:, 27) == 420);
% test= intersect (trials_centraltarget_x ,trials_centraltarget_y ); % trials in which the this fixation target was displayed


%fixation_points_idx = find(abs_dist_x <= 0.000 & abs_dist_y <= 0.000);

%fixation_points_idx = (1:1:length(gaze_x));

%fixation_points_idx = (750:1:1250);
%fixation_points_idx = fixation_points_idx(750:1:1250);

%table= horzcat(data_struct_extract.data(1:35111, data_struct_extract.cn.FixationPointX),(data_struct_extract.data(1:35111, data_struct_extract.cn.FixationPointY)));
table = horzcat(data_struct_extract.data(:, data_struct_extract.cn.FixationPointX),(data_struct_extract.data(:, data_struct_extract.cn.FixationPointY)));

table(:,3)=NaN;
table(:,4)= (data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp));
timestamp = (data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp));

existing_fixation_target_x_y_coordinate_list = unique(table(:,1:2), 'rows');

zero_offset = 0;
for i_fixation_target_x_y_coordinate = 1 : length(existing_fixation_target_x_y_coordinate_list)
	current_target_ID = i_fixation_target_x_y_coordinate - zero_offset;
	if existing_fixation_target_x_y_coordinate_list(i_fixation_target_x_y_coordinate, :) == [0, 0]
		zero_offset = 1;
		current_target_ID = i_fixation_target_x_y_coordinate - zero_offset;
	end
	current_target_ID_lidx = table(:, 1) == existing_fixation_target_x_y_coordinate_list(i_fixation_target_x_y_coordinate, 1) & table(:, 2) == existing_fixation_target_x_y_coordinate_list(i_fixation_target_x_y_coordinate, 2);
	table(current_target_ID_lidx, 3) = current_target_ID;
end




switch_list = diff(table(:, 3));
preswitch_trial_idx = find(switch_list ~= 0);
switch_trial_idx = preswitch_trial_idx + 1;

unique_fixation_targets = unique(table(:, 3));
nonzero_unique_fixation_target_idx = find(unique_fixation_targets);


targetstart_ts_idx = [1; switch_trial_idx];
targetend_ts_idx = [preswitch_trial_idx; size(table, 1)];

good_sample_points_lidx = zeros([size(table, 1), 1]);
saccade_allowance_time_ms = 200;

fixation_target_position_table = zeros([length(nonzero_unique_fixation_target_idx), 2]);


for i_switch = 1 : length(targetstart_ts_idx)
	current_start_idx = targetstart_ts_idx(i_switch);
	current_end_idx = targetend_ts_idx(i_switch);
	
	current_start_ts = table(current_start_idx, 4);
	current_end_ts = table(current_end_idx, 4);
	current_target_ID = table(current_start_idx, 3);
	current_target_duration = current_end_ts - current_start_ts;
	
	% get the fixation target's cordinates
	current_target_x = table(current_start_idx, 1);
	current_target_y = table(current_start_idx, 2);
	if current_target_duration >= saccade_allowance_time_ms
		%found a long enough target display duration
		% find the start_idx
		offset_start_ts = current_start_ts + saccade_allowance_time_ms;
		
		proto_offset_start_idx_list = find(table(:, 4) >= offset_start_ts);
		
		offset_start_idx = proto_offset_start_idx_list(1);
		good_sample_points_lidx(offset_start_idx: current_end_idx) = 1;
		
	end
	
	if current_target_ID ~= 0
		fixation_target_position_table(current_target_ID, :) = [current_target_x, current_target_y];
	end
	
end

good_sample_points_idx = find(good_sample_points_lidx);
bad_sample_points_idx = find(good_sample_points_lidx == 0);


[gaze_tracker_logfile_path, gaze_tracker_logfile_name, gaze_tracker_logfile_ext] = fileparts(gaze_tracker_logfile_FQN);
figure_handle = figure('Name', ['Roberta''s gaze visualizer: ', gaze_tracker_logfile_name, gaze_tracker_logfile_ext]);
% subplot(2, 1, 2)
plot(fixation_point_x(:),fixation_point_y(:),'s','MarkerSize',10,'MarkerFaceColor',[1 0 0]);

set(gca(), 'XLim', [(960-300) (960+300)], 'YLim', [(1080-500-200) (1080-500+400)]);

hold on
% full traces all points with lines in between
plot(gaze_x(:),gaze_y(:),'b','LineWidth', 1, 'Color', [0.8 0.8 0.8])
% blue fixation points
plot(gaze_x(fixation_points_idx), gaze_y(fixation_points_idx), 'LineWidth', 1, 'LineStyle', 'none', 'Color', 'b', 'Marker', '+', 'Markersize', 1);
% magenta, points exceeding the velocity threshold
plot(gaze_x(tmp_fixation_points_idx), gaze_y(tmp_fixation_points_idx), 'LineWidth', 1, 'LineStyle', 'none', 'Color', 'm', 'Marker', '+', 'Markersize', 1);
% points immediately after fixation point onsets, when the sunbject can not fixate
plot(gaze_x(bad_sample_points_idx),gaze_y(bad_sample_points_idx), 'LineWidth',1, 'LineStyle', 'none', 'Color', 'r', 'Marker', '+', 'Markersize', 1);
% surviving points
plot(gaze_x(validpoints_idx),gaze_y(validpoints_idx),'LineWidth',1, 'LineStyle', 'none', 'Color', [0 0.8 0], 'Marker', '+', 'Markersize', 1);





nonzero_unique_fixation_target_idx = find(unique_fixation_targets);
x_y_mouse_y_flipped = zeros([length(nonzero_unique_fixation_target_idx), 2]);

gaze_y = (tmp2_gaze_y .* -1) + 1080; %flipped
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

euclidean_distance_array = zeros([size(gaze_x, 1), length(nonzero_unique_fixation_target_idx)]);



for i_fix_target = 1 : length(find(unique_fixation_targets))
	unique_fixation_target_id = unique_fixation_targets(nonzero_unique_fixation_target_idx(i_fix_target));
	
	euclidean_distance_array(:, unique_fixation_target_id) = sqrt(((gaze_x - x_y_mouse_y_flipped(unique_fixation_target_id, 1)).^2 ) + ...
																	((gaze_y - x_y_mouse_y_flipped(unique_fixation_target_id, 2)).^2 ));
	
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

tmp_target_selected_samples = [data_struct_extract.data(points_close_2_fixation_centers_idx, data_struct_extract.cn.FixationPointX) data_struct_extract.data(points_close_2_fixation_centers_idx, data_struct_extract.cn.FixationPointY)];

tmp_gaze_selected_samples = [gaze_x(points_close_2_fixation_centers_idx) gaze_y_unflipped(points_close_2_fixation_centers_idx)];
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
selected_samples_idx = intersect(selected_samples_idx, find(euclidean_dist <= velocity_threshold_pixels_per_sample));

% only samples xx ms after target onset
selected_samples_idx = intersect(selected_samples_idx, good_sample_points_idx);

% exclude the epochs witout a displayed target
selected_samples_idx = intersect(selected_samples_idx, find(table(:, 3)));


% for re-registering the raw gaze data, exclude samples with invalid
% tracker data (tracker specific?)
switch(tracker_type)
	case 'eyelink'
		out_of_bounds_marker_value = -32768;
		valid_right_eye_raw_idx = find(data_struct_extract.data(:, data_struct_extract.cn.Right_Eye_Raw_X) ~= out_of_bounds_marker_value);
		valid_left_eye_raw_idx = find(data_struct_extract.data(:, data_struct_extract.cn.Left_Eye_Raw_X) ~= out_of_bounds_marker_value);
		valid_eye_raw_idx = intersect(valid_right_eye_raw_idx, valid_left_eye_raw_idx);
		selected_samples_idx = intersect(selected_samples_idx, valid_eye_raw_idx);
	otherwise
		error(['tracker_type: ', tracker_type, ' not yet supported.']);
end


% moving
gaze_selected_samples = [data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.Gaze_X) data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.Gaze_Y)];
gaze_selected_samples = [gaze_x(selected_samples_idx) gaze_y_unflipped(selected_samples_idx)];


%

right_raw_gaze_selected_samples = [data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.Right_Eye_Raw_X) data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.Right_Eye_Raw_Y)];
left_raw_gaze_selected_samples = [data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.Left_Eye_Raw_X) data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.Left_Eye_Raw_Y)];

%fixed
target_selected_samples = [data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.FixationPointX) data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.FixationPointY)];

% unique([data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.FixationPointX) ...
%		data_struct_extract.data(selected_samples_idx, data_struct_extract.cn.FixationPointY)], 'rows')

% fixed = [(1:1:100); (1:1:100)]';
% 
% noise_list = (1.0 * rand([size(fixed, 1) 1]));
% 
% moving = (fixed * 0.666 + 10) ;%.+ [zeros([100 1])'; noise_list];
% 
% figure('Name', 'Who cares');
% plot(fixed);
% hold on
% plot(moving)
% 
% hold off 



%tform = fitgeotrans(moving, fixed, transformationType);

%tform = fitgeotrans(gaze_selected_samples, target_selected_samples, transformationType);
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

