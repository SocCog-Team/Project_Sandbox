function [] = fn_touch_and_gaze_analysis(fileID, gazereg_name)

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


if exist(fullfile(data_dir, [fileID, '.triallog.v012.mat']), 'file')
	maintask_datastruct=load(fullfile(data_dir, [fileID, '.triallog.v012.mat']));
else
	maintask_datastruct = fnParseEventIDEReportSCPv06(fullfile(data_dir, [fileID, '.triallog.txt']));
end


%EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_EyeLinkProxyTrackerA.trackerlog.txt.gz']);
EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_EyeLinkProxyTrackerA.trackerlog']);

%PQtrackerfilenameA = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_PQLabTrackerA.trackerlog.txt.gz']);
%PQtrackerfilenameB = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_SecondaryPQLabTrackerB.trackerlog.txt.gz']);
PQtrackerfilenameA = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_PQLabTrackerA.trackerlog']);
PQtrackerfilenameB = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_SecondaryPQLabTrackerB.trackerlog']);


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

report_struct = maintask_datastruct.report_struct; 
start_val_col_idx = report_struct.cn.A_InitialFixationReleaseTime_ms;
end_val_col_idx = report_struct.cn.A_TargetOffsetTime_ms; 
start_offset = -500;
end_offset = 500;

%trialnum_tracker = fn_assign_trialnum2samples_by_range(report_struct, data_struct_extract,start_val_col_idx, start_offset,end_val_col_idx , end_offset ); %%This function tells which gaze data points are a part of which trial.
trialnum_tracker = tn_trialnumber (maintask_datastruct, data_struct_extract);
%trialnum_tracker_gaze = data_struct_extract.data(:, data_struct_extract.cn.TrialNumber);

% parsing and removing invalid touch points. Tells each timepoints to which trial
% belongs
[validUnique_touchpointsA, touchtracker_datastructA, trialnum_tracker_TouchpointsA] = fn_PQtrackerdata(PQtrackerfilenameA, maintask_datastruct);
[validUnique_touchpointsB, touchtracker_datastructB, trialnum_tracker_TouchpointsB] = fn_PQtrackerdata(PQtrackerfilenameB, maintask_datastruct);
% 
% %Gaze/Touch points on the basis of trials
% 
[TrialWiseDataGaze]= modified_trialwiseDataStructure(data_struct_extract.data, trialnum_tracker, nrows_maintask);
[TrialWiseDataTouchA]= tn_trialwiseDataStructure(validUnique_touchpointsA.data,trialnum_tracker_TouchpointsA,nrows_maintask);
[TrialWiseDataTouchB]= tn_trialwiseDataStructure(validUnique_touchpointsB.data,trialnum_tracker_TouchpointsB,nrows_maintask);
[a, b]=size(TrialWiseDataTouchB.timepoints);

%Interpolation: equally spaced
[InterpolatedTrialWiseDataGaze]= tn_interpTrialData(TrialWiseDataGaze);
[InterpolatedTrialWiseDataTouchA]= tn_interpTrialDataTouch(TrialWiseDataTouchA, InterpolatedTrialWiseDataGaze);
[InterpolatedTrialWiseDataTouchB]= tn_interpTrialDataTouch(TrialWiseDataTouchB, InterpolatedTrialWiseDataGaze);


%Define the epoch: aligned to colour target onset time
%interpolate
[epochdataGazeA]= tn_defineEpochnew(InterpolatedTrialWiseDataGaze, maintask_datastruct); %To Target Onset
[epochdataTouchA]= tn_defineEpochnew(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchB]= tn_defineEpochnew(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
ArrayforInterpolation=(-0.5:0.002:1.3);
[InterpolatedepochdataGazeA]= tn_interpTrialDataEpoch(epochdataGazeA.TargetOnset, ArrayforInterpolation);
[InterpolatedepochdataTouchA]= tn_interpTrialDataTouch(epochdataTouchA.TargetOnset, InterpolatedepochdataGazeA);
[InterpolatedepochdataTouchB]= tn_interpTrialDataTouch(epochdataTouchB.TargetOnset, InterpolatedepochdataGazeA);

%%This is to define the epoch: aligned to the Initial fixation release time of the Player B (confederate in my case, but can be used as it is for any data)
%%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/
ArrayforInterpolation=(-0.2:0.002:0.9);
[epochdataGazeB_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGaze, maintask_datastruct);
[epochdataTouchB_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchB_Initial_Fixation_Release_B]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeB_Initial_Fixation_Release_A]= tn_interpTrialDataEpoch(epochdataGazeB_Initial_Fixation_Release_A, ArrayforInterpolation);
[InterpolatedepochdataTouchB_Initial_Fixation_Release_A]= tn_interpTrialDataTouch(epochdataTouchB_Initial_Fixation_Release_A, InterpolatedepochdataGazeB_Initial_Fixation_Release_A);
[InterpolatedepochdataTouchB_Initial_Fixation_Release_B]= tn_interpTrialDataTouch(epochdataTouchB_Initial_Fixation_Release_B, InterpolatedepochdataGazeB_Initial_Fixation_Release_A);

%This is to define the epoch: aligned to the Initial fixation release time of the Player A (Elmo in my case, but can be used as it is for any data)
%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/
ArrayforInterpolation=(-1:0.002:0.5);
[epochdataGazeA_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGaze, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_B]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeA_Initial_Fixation_Release_A]= tn_interpTrialDataEpoch(epochdataGazeA_Initial_Fixation_Release_A, ArrayforInterpolation);
[InterpolatedepochdataTouchA_Initial_Fixation_Release_A]= tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_A, InterpolatedepochdataGazeA_Initial_Fixation_Release_A);
[InterpolatedepochdataTouchA_Initial_Fixation_Release_B]= tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_B, InterpolatedepochdataGazeA_Initial_Fixation_Release_A);

%Segregation of trials
[ModifiedTrialSets]=rn_segregateTrialData(maintask_datastruct);

%Plotting Elmo's RT over human's switching block unblocked_condition
[Cur_fh_RTbyChoiceCombinationSwitches, merged_classifier_char_string]=rn_reactiontime_switching_block_trials(maintask_datastruct,ModifiedTrialSets);

%load t_form
t_form = load(gazereg_FQN);

%apply the chosen registration to the raw left and right eye (all the
%trials)
registered_left_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Left_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_Y))]);
registered_right_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Right_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_Y))]);


switching_trials_RB_idx = ismember(trialnum_tracker, ModifiedTrialSets.BySwitchingBlock.RB);
switching_trials_RB = trialnum_tracker(switching_trials_RB_idx);
right_x_coordinates_RB = registered_right_eye_gaze_samples(switching_trials_RB_idx, 1);
right_y_coordinates_RB = registered_right_eye_gaze_samples(switching_trials_RB_idx, 2);

switching_trials_BR_idx = ismember(trialnum_tracker, ModifiedTrialSets.BySwitchingBlock.BR);
switching_trials_BR = trialnum_tracker(switching_trials_BR_idx);
right_x_coordinates_BR = registered_right_eye_gaze_samples(switching_trials_BR_idx, 1);
right_y_coordinates_BR = registered_right_eye_gaze_samples(switching_trials_BR_idx, 2);

%convert to DVA
[right_x_position_list_deg, right_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_right_eye_gaze_samples(:,1),registered_right_eye_gaze_samples(:,2),...
	960, 341.2698, 1920/1209.4, 1080/680.4, 300);

[right_x_position_list_deg_RB, right_y_position_list_deg_RB] = fn_convert_pixels_2_DVA(right_x_coordinates_RB,right_y_coordinates_RB,...
	960, 341.2698, 1920/1209.4, 1080/680.4, 300);

[right_x_position_list_deg_BR, right_y_position_list_deg_BR] = fn_convert_pixels_2_DVA(right_x_coordinates_BR,right_y_coordinates_BR,...
	960, 341.2698, 1920/1209.4, 1080/680.4, 300);

% detection saccades(Igor's toolbox)

neg_timestamp_idx = find(data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp) < 0);
first_good_sample_idx = neg_timestamp_idx(end) + 1;
fgs_idx = first_good_sample_idx;

timestamps_s = data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000;
switching_block_timestamps_RB = timestamps_s(switching_trials_RB_idx);
switching_block_timestamps_BR = timestamps_s(switching_trials_BR_idx);


%Detection of saccade for all the trials 

right_eye_out = em_saccade_blink_detection(data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000, right_x_position_list_deg(fgs_idx:end), right_y_position_list_deg(fgs_idx:end), 'OpenFigure', true,'Plot',true');

%Detection of saccade for the switching block trials from Red to Yellow 
%right_eye_out_RB = em_saccade_blink_detection(switching_block_timestamps_RB,right_x_position_list_deg_RB, right_y_position_list_deg_RB, 'OpenFigure', true,'Plot',true');

%Detection of saccade for the switching block trials from Yellow to Red
%right_eye_out_BR = em_saccade_blink_detection(switching_block_timestamps_BR,right_x_position_list_deg_BR, right_y_position_list_deg_BR, 'OpenFigure', true,'Plot',true');

%vergence = fn_vergence_analysis(fileID, gazereg_name);

% 
% vergence = (registered_right_eye_gaze_samples(:, 1) - registered_left_eye_gaze_samples(:, 1));
% 
% ranged_vergence_idx = find(vergence >= -100 & vergence <= 100);
% cur_fh = figure('Name', 'vergence histogram');
% h=histogram(vergence(ranged_vergence_idx), 200);
% write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['Vergence_histogram.pdf']));
% 
% 
% 
% abs_vergence = abs(vergence);
% figure('Name', 'Vergence histogram [pixel]');
% h=histogram(vergence);
% 
% Xedges = (0:1:1920);
% Yedges = (0:1:1080);
% cur_fh = figure('Name', 'Gaze histogram');
% histogram2(registered_right_eye_gaze_samples(:, 1), registered_right_eye_gaze_samples(:, 2), Xedges, Yedges, 'DisplayStyle', 'tile');
% set(gca(), 'YDir', 'reverse');
% 
% write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['Gaze2D_histogram.pdf']));
% 
% 
% [N, Xedges, Yedges, binX, binY] = histcounts2(registered_right_eye_gaze_samples(:, 1), registered_right_eye_gaze_samples(:, 2), Xedges, Yedges);
% 
% absmax_vergence_array = zeros(size(N));
% max_vergence_array = zeros(size(N));
% min_vergence_array = zeros(size(N));
% absmin_vergence_array = zeros(size(N));
% mean_vergence_array = zeros(size(N));
% 
% samples_by_binx_idx_list = cell([1 (length(Xedges) - 1)]);
% for i_x = 1 : (length(Xedges) - 1)
% 	current_x = mean([Xedges(i_x:i_x + 1)]);
% 	current_x_sample_idx = find(binX == i_x);
% 	samples_by_binx_idx_list{i_x} = current_x_sample_idx;
% end
% 
% samples_by_biny_idx_list = cell([1 (length(Yedges) - 1)]);
% for i_y = 1 : (length(Yedges) - 1)
% 	current_y = mean([Yedges(i_y:i_y + 1)]);
% 	current_y_sample_idx = find(binY == i_y);
% 	samples_by_biny_idx_list{i_y} = current_y_sample_idx;
% end
% 
% 
% 
% 
% for i_x = 1 : (length(Xedges) - 1)
% 	current_x = mean([Xedges(i_x:i_x + 1)]);
% 	current_x_sample_idx = samples_by_binx_idx_list{i_x};
% 	
% 	for i_y = 1 : (length(Yedges) - 1)
% 		current_y = mean([Yedges(i_y:i_y + 1)]);
% 		current_y_sample_idx = samples_by_biny_idx_list{i_y};
% 		
% 		current_sample_set = intersect(current_x_sample_idx, current_y_sample_idx);
% 		
% 		tmp_max = max(vergence(current_sample_set));
% 		if ~isempty(tmp_max)
% 			max_vergence_array(i_x, i_y) = tmp_max;
% 			absmax_vergence_array(i_x, i_y) = max(abs_vergence(current_sample_set));
% 		end
% 		
% 		tmp_min = min(vergence(current_sample_set));
% 		if ~isempty(tmp_min)
% 			min_vergence_array(i_x, i_y) = tmp_min;
% 			absmin_vergence_array(i_x, i_y) = min(abs_vergence(current_sample_set));
% 		end
% 		
% 		tmp_mean = mean(vergence(current_sample_set));
% 		if ~isempty(mean(vergence(current_sample_set)))
% 			mean_vergence_array(i_x, i_y) = mean(vergence(current_sample_set));
% 		end
% 	end
% end
% 
% cur_fh = figure('Name', 'maximal Vergenace');
% imagesc(max_vergence_array')
% colorbar;
% set(gca(), 'CLim', [-100, 100]);
% write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['max_vergence_array.pdf']));
% 
% cur_fh = figure('Name', 'mean Vergenace');
% imagesc(mean_vergence_array')
% colorbar;
% set(gca(), 'CLim', [-100, 100]);
% write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['mean_vergence_array.pdf']));
% 
% cur_fh = figure('Name', 'absmax Vergenace');
% imagesc(absmax_vergence_array')
% colorbar;
% set(gca(), 'CLim', [-100, 100]);
% write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['absmax_vergence_array.pdf']));
% 
% cur_fh = figure('Name', 'min Vergenace');
% imagesc(min_vergence_array')
% colorbar;
% set(gca(), 'CLim', [-100, 100]);
% write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['min_vergence_array.pdf']));
% 
% cur_fh = figure('Name', 'absmin Vergenace');
% imagesc(absmin_vergence_array')
% colorbar;
% set(gca(), 'CLim', [-100, 100]);
% write_out_figure(cur_fh, fullfile(output_dir, 'figures', fileID, ['absmin_vergence_array.pdf']));


% exclude saccades

fixation_onsets = (right_eye_out.sac_offsets(:,:) .* 1000)'; %conversion in ms as the TrialWiseData.timepoint
fixation_onsets_trialID_list= zeros(size(fixation_onsets));

for i_trialnumber= 1:size(TrialWiseDataGaze.TrialNumber);
	
	current_trial_start_ts = TrialWiseDataGaze.timepoints(i_trialnumber, 1);
	
	if isnan(current_trial_start_ts)
		continue
	end
	
	tmp_nonnan_idx = find(~isnan(TrialWiseDataGaze.timepoints(i_trialnumber, :)));
	current_trial_end_ts = TrialWiseDataGaze.timepoints(i_trialnumber, tmp_nonnan_idx(end));
	
	if isnan(current_trial_end_ts)
		continue
	end
	
	fixation_onset_4_current_trial_idx = find((fixation_onsets >= current_trial_start_ts) & (fixation_onsets <= current_trial_end_ts));
	fixation_onsets_trialID_list(fixation_onset_4_current_trial_idx) = TrialWiseDataGaze.TrialNumber(i_trialnumber);
	
end

fixation_onsets_trialID_list_idx = find(fixation_onsets_trialID_list>0);
fixation_onsets_trial_of_interest= fixation_onsets_trialID_list(fixation_onsets_trialID_list_idx);

fixation_onsets_4_trial = fixation_onsets(fixation_onsets_trialID_list_idx);


%Human behavior : switch from Red to Blue

switch_trial_RB_idx=ismember(fixation_onsets_trial_of_interest,ModifiedTrialSets.BySwitchingBlock.RB);
switch_trial_RB= fixation_onsets_trial_of_interest(switch_trial_RB_idx);

fixation_onsets_4_switch_trial_RB= fixation_onsets_4_trial(switch_trial_RB_idx);


gaze_x= data_struct_extract.data(:,2);
gaze_y= data_struct_extract.data(:,3);

fixation_x_coordinates_switch_trial_RB = gaze_x(switch_trial_RB_idx);
fixation_y_coordinates_switch_trial_RB = gaze_y(switch_trial_RB_idx);

before_switch_trial_RB_idx=ismember(fixation_onsets_trial_of_interest,(ModifiedTrialSets.BySwitchingBlock.RB -1));
before_switch_trial_RB = fixation_onsets_trial_of_interest(before_switch_trial_RB_idx)
fixation_onsets_before_switch_trial_RB= fixation_onsets_4_trial(before_switch_trial_RB_idx);
fixation_x_coordinates_before_switch_trial_RB = gaze_x(before_switch_trial_RB_idx);
fixation_y_coordinates_before_switch_trial_RB = gaze_y(before_switch_trial_RB_idx);

next_switch_trial_RB_idx=ismember(fixation_onsets_trial_of_interest,(ModifiedTrialSets.BySwitchingBlock.RB +1));
next_switch_trial_RB = fixation_onsets_trial_of_interest(next_switch_trial_RB_idx);
fixation_onsets_next_switch_trial_RB= fixation_onsets_4_trial(next_switch_trial_RB_idx);
fixation_x_coordinates_next_switch_trial_RB = gaze_x(next_switch_trial_RB_idx);
fixation_y_coordinates_next_switch_trial_RB = gaze_y(next_switch_trial_RB_idx);

%Human behavior : switch from Blue to Red

switch_trial_BR_idx=ismember(fixation_onsets_trial_of_interest,ModifiedTrialSets.BySwitchingBlock.BR);
switch_trial_BR= fixation_onsets_trial_of_interest(switch_trial_BR_idx);

fixation_onsets_4_switch_trial_BR= fixation_onsets_4_trial(switch_trial_BR_idx);
fixation_x_coordinates_switch_trial_BR = gaze_x(switch_trial_BR_idx);
fixation_y_coordinates_switch_trial_BR = gaze_y(switch_trial_BR_idx);

before_switch_trial_BR_idx=ismember(fixation_onsets_trial_of_interest,(ModifiedTrialSets.BySwitchingBlock.BR -1));
before_switch_trial_BR = fixation_onsets_trial_of_interest(before_switch_trial_BR_idx);
fixation_onsets_before_switch_trial_BR= fixation_onsets_4_trial(before_switch_trial_BR_idx);
fixation_x_coordinates_before_switch_trial_BR = gaze_x(before_switch_trial_BR_idx);
fixation_y_coordinates_before_switch_trial_BR = gaze_y(before_switch_trial_BR_idx);

next_switch_trial_BR_idx=ismember(fixation_onsets_trial_of_interest,(ModifiedTrialSets.BySwitchingBlock.BR +1));
next_switch_trial_BR = fixation_onsets_trial_of_interest(next_switch_trial_BR_idx);
fixation_onsets_next_switch_trial_BR= fixation_onsets_4_trial(next_switch_trial_BR_idx);
fixation_x_coordinates_next_switch_trial_BR = gaze_x(next_switch_trial_BR_idx);
fixation_y_coordinates_next_switch_trial_BR = gaze_y(next_switch_trial_BR_idx);




if (close_figures_on_return)
	close all;
end

return
end
