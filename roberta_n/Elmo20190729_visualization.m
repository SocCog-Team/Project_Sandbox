function [] = fn_create_matlab_calibration_from_gaze_calibration(gaze_tracker_logfile_FQN, acceptable_radius_pix)

debug = 1;


if ~exist('acceptable_radius_pix', 'var') || isempty(acceptable_radius_pix)
	acceptable_radius_pix = 50;
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



tmp_fixation_points_idx = find(euclidean_dist <= 0.05);

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

% tmp = table(:, 3);
% nofixationpoints_idx = table(:,1:2) == 0;
% table(nofixationpoints_idx(:, 1), 3) = 0;
% center_idx= table(:,1) == 960 & table(:,2) == 420;
% table(center_idx,3) = 1;
% bottom_center_idx= table(:,1) == 737.8000 & table(:,2) == 420;
% table(bottom_center_idx,3) = 2;
% top_center_idx= table(:,1) == 1.1822e+03 & table(:,2) == 420;
% table(top_center_idx,3) = 3;
% top_left_idx= table(:,1) == 1.1822e+03 & table(:,2) == 300;
% table(top_left_idx,3) = 4;
% center_left_idx= table(:,1) == 960 & table(:,2) == 300;
% table(center_left_idx,3) = 5;
% bottom_left_idx= table(:,1) == 737.8000 & table(:,2) == 300;
% table(bottom_left_idx,3) = 6;
% bottom_right_idx= table(:,1) == 737.8000 & table(:,2) == 540;
% table(bottom_right_idx,3) = 7;
% center_right_idx= table(:,1) == 960 & table(:,2) == 540;
% table(center_right_idx,3) = 8;
% top_right_idx= table(:,1) == 1.1822e+03 & table(:,2) == 540;
% table(top_right_idx,3) = 9;
% 
% %table(35112:end,:)= [];
% isequal(tmp, table(:, 3))
% tmp2 = [tmp, table(:, 3)];
% tmp_diff = (diff(tmp));
% tmp_idx = find(tmp_diff ~= 0);
% tmp2_diff = (diff(table(:, 3)));
% tmp2_idx = find(tmp2_diff ~= 0);
% tmp3 = [tmp(tmp_idx),  table(tmp_idx, 3)]; 
% tmp4 = [tmp(tmp_idx+1),  table(tmp_idx+1, 3)]; 


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
	
	% get the fixation tarhet's cordinates
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


[pathstr, name, ext] = fileparts(gaze_tracker_logfile_FQN);
figure_handle = figure('Name', ['Roberta''s gaze visualizer: ', name, ext]);
% subplot(2, 1, 2)
plot(fixation_point_x(:),fixation_point_y(:),'s','MarkerSize',10,'MarkerFaceColor',[1 0 0]);

set(gca(), 'XLim', [(960-300) (960+300)], 'YLim', [(1080-500-200) (1080-500+400)]);

hold on
plot(gaze_x(:),gaze_y(:),'b','LineWidth', 1, 'Color', [0.8 0.8 0.8])

% tmp_gaze_x = NaN;
% tmp_gaze_x(fixation_points_idx) = gaze_x(fixation_points_idx);
% tmp_gaze_y = NaN;
% tmp_gaze_y(fixation_points_idx) = gaze_y(fixation_points_idx);

plot(gaze_x(fixation_points_idx), gaze_y(fixation_points_idx), 'LineWidth', 1, 'LineStyle', 'none', 'Color', 'b', 'Marker', '+', 'Markersize', 1);
plot(gaze_x(tmp_fixation_points_idx), gaze_y(tmp_fixation_points_idx), 'LineWidth', 1, 'LineStyle', 'none', 'Color', 'm', 'Marker', '+', 'Markersize', 1);
plot(gaze_x(validpoints_idx),gaze_y(validpoints_idx),'LineWidth',1, 'LineStyle', 'none', 'Color', 'y', 'Marker', '+', 'Markersize', 1);
plot(gaze_x(bad_sample_points_idx),gaze_y(bad_sample_points_idx), 'LineWidth',1, 'LineStyle', 'none', 'Color', 'g', 'Marker', '+', 'Markersize', 1);

%plot((80:100), 900);
title('Select the center of each of the calibration dots');



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

x_y_mouse = [x_y_mouse_y_flipped(:, 1), ((x_y_mouse_y_flipped(:,2) .* -1) + 1080)];

%[x,y]= getpts
%x_y_mouse= [x,y]
%plot(x(:),y(:),'LineStyle', 'none','Color','k','Marker','+','Markersize',15)

hold off
xlim([(960-300) (960+300)]);
ylim ([(1080-500-200) (1080-500+400)]);

% gaze_x_y=horzcat(gaze_x, gaze_y);
% euclidean_distance1 = sqrt(((gaze_x_y(:,1)-x_y_mouse(1,1)).^2) + ((gaze_x_y(:,2)-x_y_mouse(1,2)).^2));
% euclidean_distance2 = sqrt(((gaze_x_y(:,1)-x_y_mouse(2,1)).^2) + ((gaze_x_y(:,2)-x_y_mouse(2,2)).^2));
% euclidean_distance3 = sqrt(((gaze_x_y(:,1)-x_y_mouse(3,1)).^2) + ((gaze_x_y(:,2)-x_y_mouse(3,2)).^2));
% euclidean_distance4 = sqrt(((gaze_x_y(:,1)-x_y_mouse(4,1)).^2) + ((gaze_x_y(:,2)-x_y_mouse(4,2)).^2));
% euclidean_distance5 = sqrt(((gaze_x_y(:,1)-x_y_mouse(5,1)).^2) + ((gaze_x_y(:,2)-x_y_mouse(5,2)).^2));
% euclidean_distance6 = sqrt(((gaze_x_y(:,1)-x_y_mouse(6,1)).^2) + ((gaze_x_y(:,2)-x_y_mouse(6,2)).^2));
% euclidean_distance7 = sqrt(((gaze_x_y(:,1)-x_y_mouse(7,1)).^2) + ((gaze_x_y(:,2)-x_y_mouse(7,2)).^2));
% euclidean_distance8 = sqrt(((gaze_x_y(:,1)-x_y_mouse(8,1)).^2) + ((gaze_x_y(:,2)-x_y_mouse(8,2)).^2));
% euclidean_distance9 = sqrt(((gaze_x_y(:,1)-x_y_mouse(9,1)).^2) + ((gaze_x_y(:,2)-x_y_mouse(9,2)).^2));
% euclidean_distance = horzcat(euclidean_distance1,euclidean_distance2,euclidean_distance3,euclidean_distance4,euclidean_distance5,euclidean_distance6,euclidean_distance7,euclidean_distance8,euclidean_distance9);

nonzero_unique_fixation_target_idx = find(unique_fixation_targets);
euclidean_distance_array = zeros([size(gaze_x, 1), length(nonzero_unique_fixation_target_idx)]);

for i_fix_target = 1 : length(find(unique_fixation_targets))
	unique_fixation_target_id = unique_fixation_targets(nonzero_unique_fixation_target_idx(i_fix_target));
	
	euclidean_distance_array(:, unique_fixation_target_id) = sqrt(((gaze_x - x_y_mouse(unique_fixation_target_id,1)).^2 ) + ((gaze_y_unflipped - x_y_mouse(unique_fixation_target_id,2)).^2 ));
	
	if (debug)
		figure_h = figure('Name', ['FixationTarget_', num2str(unique_fixation_target_id)]);
		histogram(euclidean_distance_array(:, unique_fixation_target_id), (0.00:1:650));
	end
end


%histogram((euclidean_distance(:, :)),(0.00:1:650));


return
end
