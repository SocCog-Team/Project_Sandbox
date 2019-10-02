function [] = fn_vergence_analysis(fileID, gazereg_name)

timestamps.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);


if ~exist('fileID', 'var') || isempty(fileID)
	fileID = '20190320T095244.A_Elmo.B_JK.SCP_01';
end

if ~exist('gazereg_name', 'var') || isempty(gazereg_name)
	gazereg_name = 'GAZEREG.SID_20190320T092435.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat';
end

close_figures_on_return = 1;

if (ispc)
	saving_dir='C:\taskcontroller\SCP_DATA\ANALYSES\GazeAnalyses';
	data_root_str = 'C:';
	data_dir = fullfile(data_root_str, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190320', [fileID, '.sessiondir']);
	output_dir = pwd;
	
else
	data_root_str = '/';
	saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN');
	data_base_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ');
	
	% network!
	data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data');
	
	
	year_string = fileID(1:4);
	date_string = fileID(3:8);
	
	data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, [fileID, '.sessiondir']);
	output_dir = pwd;
end

gazereg_FQN = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, gazereg_name);

maintask_datastruct = fnParseEventIDEReportSCPv06(fullfile(data_dir, [fileID, '.triallog']));
TrialSets = fnCollectTrialSets(maintask_datastruct.report_struct);

EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_EyeLinkProxyTrackerA.trackerlog']);

data_struct_extract = struct([]);

data_struct_extract = fnParseEventIDETrackerLog_v01 (EyeLinkfilenameA, ';', [], []);
nrows_eyetracker = 0;
ncols_eyetracker = 0;
[nrows_eyetracker, ncols_eyetracker] = size(data_struct_extract.data);

nrows_maintask = 0;
ncols_maintask = 0;
[nrows_maintask, ncols_maintask] = size(maintask_datastruct.report_struct.data);

invalid_datapoints = find(data_struct_extract.data (:,2)==-32768); %% Removing invalid data pts as defined by eyelink/eventide
data_struct_extract.data(invalid_datapoints,2:3) = NaN;

trialnum_tracker = fn_trialnumber(maintask_datastruct, data_struct_extract);

trialnumber_by_tracker_sample_list = data_struct_extract.data(:, data_struct_extract.cn.TrialNumber);

%load t_form
t_form = load(gazereg_FQN);

%apply the chosen registration to the raw left and right eye
registered_left_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Left_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_Y))]);
registered_right_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Right_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_Y))]);
 
%convert to DVA
% [left_x_position_list_deg, left_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_left_eye_gaze_samples(:,1),registered_left_eye_gaze_samples(:,2),...
% 	960, 341.2698, 1920/1209.4, 1080/680.4, 300);
% 
% [right_x_position_list_deg, right_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_right_eye_gaze_samples(:,1),registered_right_eye_gaze_samples(:,2),...
% 	960, 341.2698, 1920/1209.4, 1080/680.4, 300);



registered_right_eye_gaze_samples_x = registered_right_eye_gaze_samples(:,1);
registered_right_eye_gaze_samples_y = registered_right_eye_gaze_samples(:,2);
registered_left_eye_gaze_samples_x = registered_left_eye_gaze_samples(:,1);

[TrialSets] = fnCollectTrialSets( maintask_datastruct.report_struct );	 


solo_trials_idx = ismember(trialnumber_by_tracker_sample_list, TrialSets.ByJointness.DualSubjectSoloTrials);
solo_trials = trialnumber_by_tracker_sample_list(solo_trials_idx);
invisible_trials_idx = ismember(trialnumber_by_tracker_sample_list, TrialSets.ByVisibility.AB_invisible);
invisible_trials =  trialnumber_by_tracker_sample_list(invisible_trials_idx);
joint_trials_idx = ismember(trialnumber_by_tracker_sample_list, TrialSets.ByJointness.DualSubjectJointTrials);
joint_trials = trialnumber_by_tracker_sample_list(joint_trials_idx);

joint_visible_trials= setdiff(joint_trials,invisible_trials);
joint_visible_trials_idx = ismember (trialnumber_by_tracker_sample_list,joint_visible_trials);
 

%x and y coordinates for a subset of trials 

right_x_coordinates_solo_trials = registered_right_eye_gaze_samples_x(solo_trials_idx);
right_y_coordinates_solo_trials = registered_right_eye_gaze_samples_y(solo_trials_idx);
left_x_coordinates_solo_trials = registered_left_eye_gaze_samples_x(solo_trials_idx);

right_x_coordinates_invisible_trials  = registered_right_eye_gaze_samples_x(invisible_trials_idx);
right_y_coordinates_invisible_trials = registered_right_eye_gaze_samples_y(invisible_trials_idx);
left_x_coordinates_invisible_trials = registered_left_eye_gaze_samples_x(invisible_trials_idx);

right_x_coordinates_joint_visible_trials  = registered_right_eye_gaze_samples_x(joint_visible_trials_idx);
right_y_coordinates_joint_visible_trials = registered_right_eye_gaze_samples_y(joint_visible_trials_idx);
left_x_coordinates_joint_visible_trials = registered_left_eye_gaze_samples_x(joint_visible_trials_idx);


%SOLO TRIALS
vergence_solo_trials = (right_x_coordinates_solo_trials - left_x_coordinates_solo_trials);

ranged_vergence_solo_trials_idx = find(vergence_solo_trials >= -100 & vergence_solo_trials <= 100);
cur_fh = figure('Name', 'vergence histogram solo trials');
h=histogram(vergence_solo_trials(ranged_vergence_solo_trials_idx), 200);
title(['Vergence histogram solo trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['Vergence_histogram_solo_trials.pdf']));

abs_vergence = abs(vergence_solo_trials);
figure('Name', 'Vergence histogram [pixel]');
h=histogram(vergence_solo_trials);

Xedges = (0:1:1920);
Yedges = (0:1:1080);
cur_fh = figure('Name', 'Gaze histogram');
histogram2(right_x_coordinates_solo_trials, right_y_coordinates_solo_trials, Xedges, Yedges, 'DisplayStyle', 'tile');
title (['Gaze histogram solo trials'])
set(gca(), 'YDir', 'reverse');

write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['Gaze2D_histogram_solo_trials.pdf']));


[N, Xedges, Yedges, binX, binY] = histcounts2(right_x_coordinates_solo_trials, right_y_coordinates_solo_trials, Xedges, Yedges);

absmax_vergence_array = zeros(size(N));
max_vergence_array = zeros(size(N));
min_vergence_array = zeros(size(N));
absmin_vergence_array = zeros(size(N));
mean_vergence_array = zeros(size(N));

samples_by_binx_idx_list = cell([1 (length(Xedges) - 1)]);
for i_x = 1 : (length(Xedges) - 1)
	current_x = mean([Xedges(i_x:i_x + 1)]);
	current_x_sample_idx = find(binX == i_x);
	samples_by_binx_idx_list{i_x} = current_x_sample_idx;
end

samples_by_biny_idx_list = cell([1 (length(Yedges) - 1)]);
for i_y = 1 : (length(Yedges) - 1)
	current_y = mean([Yedges(i_y:i_y + 1)]);
	current_y_sample_idx = find(binY == i_y);
	samples_by_biny_idx_list{i_y} = current_y_sample_idx;
end




for i_x = 1 : (length(Xedges) - 1)
	current_x = mean([Xedges(i_x:i_x + 1)]);
	current_x_sample_idx = samples_by_binx_idx_list{i_x};
	
	for i_y = 1 : (length(Yedges) - 1)
		current_y = mean([Yedges(i_y:i_y + 1)]);
		current_y_sample_idx = samples_by_biny_idx_list{i_y};
		
		current_sample_set = intersect(current_x_sample_idx, current_y_sample_idx);
		
		tmp_max = max(vergence_solo_trials(current_sample_set));
		if ~isempty(tmp_max)
			max_vergence_array_solo_trials(i_x, i_y) = tmp_max;
			absmax_vergence_array_solo_trials(i_x, i_y) = max(abs_vergence(current_sample_set));
		end
		
		tmp_min = min(vergence_solo_trials(current_sample_set));
		if ~isempty(tmp_min)
			min_vergence_array_solo_trials(i_x, i_y) = tmp_min;
			absmin_vergence_array_solo_trials(i_x, i_y) = min(abs_vergence(current_sample_set));
		end
		
		tmp_mean = mean(vergence_solo_trials(current_sample_set));
		
		if ~isempty(mean(vergence_solo_trials(current_sample_set)))
			mean_vergence_array_solo_trials(i_x, i_y) = mean(vergence_solo_trials(current_sample_set));
		end
       
end

cur_fh = figure('Name', 'maximal Vergence solo trials');
imagesc(max_vergence_array_solo_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title ([' maximal vergence solo trials '])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['max_vergence_array_solo_trials.pdf']));

cur_fh = figure('Name', 'mean Vergence solo trials');
imagesc(mean_vergence_array_solo_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title (['mean Vergenace solo trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['mean_vergence_array_solo_trials.pdf']));

cur_fh = figure('Name', 'absmax Vergence solo trials');
imagesc(absmax_vergence_array_solo_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title (['absmax Vergence solo trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['absmax_vergence_array_solo_trials.pdf']));

cur_fh = figure('Name', 'min Vergence solo trials');
imagesc(min_vergence_array_solo_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title (['min Vergence solo trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['min_vergence_array_solo_trials.pdf']));

cur_fh = figure('Name', 'absmin Vergence solo trials');
imagesc(absmin_vergence_array_solo_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['absmin_vergence_array_solo_trials.pdf']));

%INVISIBLE TRIALS
vergence_invisible_trials = (right_x_coordinates_invisible_trials - left_x_coordinates_invisible_trials);
ranged_vergence_invisible_trials_idx = find(vergence_invisible_trials >= -100 & vergence_invisible_trials <= 100);
cur_fh = figure('Name', 'vergence histogram invisible trials');
h=histogram(vergence_invisible_trials(ranged_vergence_invisible_trials_idx), 200);
title(['Vergence histogram invisible trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['Vergence_histogram_invisible_trials.pdf']));

abs_vergence = abs(vergence_invisible_trials);
figure('Name', 'Vergence histogram [pixel]');
h=histogram(vergence_invisible_trials);

Xedges = (0:1:1920);
Yedges = (0:1:1080);
cur_fh = figure('Name', 'Gaze histogram');
histogram2(right_x_coordinates_invisible_trials, right_y_coordinates_invisible_trials, Xedges, Yedges, 'DisplayStyle', 'tile');
title (['Gaze histogram invisible trials'])
set(gca(), 'YDir', 'reverse');

write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['Gaze2D_histogram_invisible_trials.pdf']));


[N, Xedges, Yedges, binX, binY] = histcounts2(right_x_coordinates_invisible_trials, right_y_coordinates_invisible_trials, Xedges, Yedges);

absmax_vergence_array = zeros(size(N));
max_vergence_array = zeros(size(N));
min_vergence_array = zeros(size(N));
absmin_vergence_array = zeros(size(N));
mean_vergence_array = zeros(size(N));

samples_by_binx_idx_list = cell([1 (length(Xedges) - 1)]);
for i_x = 1 : (length(Xedges) - 1)
	current_x = mean([Xedges(i_x:i_x + 1)]);
	current_x_sample_idx = find(binX == i_x);
	samples_by_binx_idx_list{i_x} = current_x_sample_idx;
end

samples_by_biny_idx_list = cell([1 (length(Yedges) - 1)]);
for i_y = 1 : (length(Yedges) - 1)
	current_y = mean([Yedges(i_y:i_y + 1)]);
	current_y_sample_idx = find(binY == i_y);
	samples_by_biny_idx_list{i_y} = current_y_sample_idx;
end




for i_x = 1 : (length(Xedges) - 1)
	current_x = mean([Xedges(i_x:i_x + 1)]);
	current_x_sample_idx = samples_by_binx_idx_list{i_x};
	
	for i_y = 1 : (length(Yedges) - 1)
		current_y = mean([Yedges(i_y:i_y + 1)]);
		current_y_sample_idx = samples_by_biny_idx_list{i_y};
		
		current_sample_set = intersect(current_x_sample_idx, current_y_sample_idx);
		
		tmp_max = max(vergence_invisible_trials(current_sample_set));
		if ~isempty(tmp_max)
			max_vergence_invisible_trials(i_x, i_y) = tmp_max;
			absmax_vergence_invisible_trials(i_x, i_y) = max(abs_vergence(current_sample_set));
		end
		
		tmp_min = min(vergence_invisible_trials(current_sample_set));
		if ~isempty(tmp_min)
			min_vergence_invisible_trials(i_x, i_y) = tmp_min;
			absmin_vergence_invisible_trials(i_x, i_y) = min(abs_vergence(current_sample_set));
		end
		
		tmp_mean = mean(vergence_invisible_trials(current_sample_set));
		if ~isempty(mean(vergence_invisible_trials(current_sample_set)))
			mean_vergence_invisible_trials(i_x, i_y) = mean(vergence_invisible_trials(current_sample_set));
		end
	end
end

cur_fh = figure('Name', 'maximal Vergence invisible trials');
imagesc(max_vergence_invisible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title ([' maximal vergence invisible trials '])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['max_vergence_array_invisible_trials.pdf']));

cur_fh = figure('Name', 'mean Vergence invisible trials');
imagesc(mean_vergence_invisible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title (['mean Vergenace invisible trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['mean_vergence_array_invisible_trials.pdf']));

cur_fh = figure('Name', 'absmax Vergence invisible trials');
imagesc(absmax_vergence_invisible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title (['absmax Vergence invisible trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['absmax_vergence_array_invisible_trials.pdf']));

cur_fh = figure('Name', 'min Vergence invisible trials');
imagesc(min_vergence_invisible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title (['min Vergence invisible trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['min_vergence_array_invisible_trials.pdf']));

cur_fh = figure('Name', 'absmin Vergence invisible trials');
imagesc(absmin_vergence_invisible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['absmin_vergence_array_invisible_trials.pdf']));

%JOINT AND VISIBLE TRIALS

vergence_joint_visible_trials = (right_x_coordinates_joint_visible_trials - left_x_coordinates_joint_visible_trials);
ranged_vergence_joint_visible_trials_idx = find(vergence_joint_visible_trials >= -100 & vergence_joint_visible_trials <= 100);
cur_fh = figure('Name', 'vergence histogram joint visible trials');
h=histogram(vergence_joint_visible_trials(ranged_vergence_joint_visible_trials_idx), 200);
title(['Vergence histogram joint visible trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['Vergence_histogram_joint_visible_trials.pdf']));

abs_vergence = abs(vergence_joint_visible_trials);
figure('Name', 'Vergence histogram [pixel]');
h=histogram(vergence_joint_visible_trials);

Xedges = (0:1:1920);
Yedges = (0:1:1080);
cur_fh = figure('Name', 'Gaze histogram');
histogram2(right_x_coordinates_joint_visible_trials, right_y_coordinates_joint_visible_trials, Xedges, Yedges, 'DisplayStyle', 'tile');
title (['Gaze histogram joint visible trials'])
set(gca(), 'YDir', 'reverse');

write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['Gaze2D_histogram_joint visible_trials.pdf']));


[N, Xedges, Yedges, binX, binY] = histcounts2(right_x_coordinates_joint_visible_trials, right_y_coordinates_joint_visible_trials, Xedges, Yedges);

absmax_vergence_array = zeros(size(N));
max_vergence_array = zeros(size(N));
min_vergence_array = zeros(size(N));
absmin_vergence_array = zeros(size(N));
mean_vergence_array = zeros(size(N));

samples_by_binx_idx_list = cell([1 (length(Xedges) - 1)]);
for i_x = 1 : (length(Xedges) - 1)
	current_x = mean([Xedges(i_x:i_x + 1)]);
	current_x_sample_idx = find(binX == i_x);
	samples_by_binx_idx_list{i_x} = current_x_sample_idx;
end

samples_by_biny_idx_list = cell([1 (length(Yedges) - 1)]);
for i_y = 1 : (length(Yedges) - 1)
	current_y = mean([Yedges(i_y:i_y + 1)]);
	current_y_sample_idx = find(binY == i_y);
	samples_by_biny_idx_list{i_y} = current_y_sample_idx;
end




for i_x = 1 : (length(Xedges) - 1)
	current_x = mean([Xedges(i_x:i_x + 1)]);
	current_x_sample_idx = samples_by_binx_idx_list{i_x};
	
	for i_y = 1 : (length(Yedges) - 1)
		current_y = mean([Yedges(i_y:i_y + 1)]);
		current_y_sample_idx = samples_by_biny_idx_list{i_y};
		
		current_sample_set = intersect(current_x_sample_idx, current_y_sample_idx);
		
		tmp_max = max(vergence_joint_visible_trials(current_sample_set));
		if ~isempty(tmp_max)
			max_vergence_joint_visible_trials(i_x, i_y) = tmp_max;
			absmax_vergence_joint_visible_trials(i_x, i_y) = max(abs_vergence(current_sample_set));
		end
		
		tmp_min = min(vergence_joint_visible_trials(current_sample_set));
		if ~isempty(tmp_min)
			min_vergence_joint_visible_trials(i_x, i_y) = tmp_min;
			absmin_vergence_joint_visible_trials(i_x, i_y) = min(abs_vergence(current_sample_set));
		end
		
		tmp_mean = mean(vergence_joint_visible_trials(current_sample_set));
		if ~isempty(mean(vergence_joint_visible_trials(current_sample_set)))
			mean_vergence_joint_visible_trials(i_x, i_y) = mean(vergence_joint_visible_trials(current_sample_set));
		end
	end
end

cur_fh = figure('Name', 'maximal Vergence joint visible trials');
imagesc(max_vergence_joint_visible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title ([' maximal vergence joint visible trials '])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['max_vergence_array_joint_visible_trials.pdf']));

cur_fh = figure('Name', 'mean Vergence joint visible trials');
imagesc(mean_vergence_joint_visible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title (['mean Vergence joint visible trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['mean_vergence_array_joint_visible_trials.pdf']));

cur_fh = figure('Name', 'absmax Vergence joint visible trials');
imagesc(absmax_vergence_joint_visible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title (['absmax Vergence joint visible trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['absmax_vergence_array_joint_visible_trials.pdf']));

cur_fh = figure('Name', 'min Vergence joint visible trials');
imagesc(min_vergence_joint_visible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
title (['min Vergence joint visible trials'])
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['min_vergence_array_joint_visible_trials.pdf']));

cur_fh = figure('Name', 'absmin Vergence joint visible trials');
imagesc(absmin_vergence_joint_visible_trials')
colorbar;
set(gca(), 'CLim', [-100, 100]);
write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['absmin_vergence_array_joint_visible_trials.pdf']));

if (close_figures_on_return)
	close all;
end



timestamps.(mfilename).end = toc(timestamps.(mfilename).start);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end), ' seconds.']);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / 60), ' minutes. Done...']);
return 
end 