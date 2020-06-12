fileID='20190320T095244.A_Elmo.B_JK.SCP_01.';

if (ispc)
    saving_dir='C:\taskcontroller\SCP_DATA\ANALYSES\GazeAnalyses';
    data_root_str = 'C:';
    data_dir = fullfile(data_root_str, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190320', '20190320T095244.A_Elmo.B_JK.SCP_01.sessiondir');
   
else
    data_root_str = '/';
    saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN');
    data_base_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ');
    
    % network!
    data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data');
    
    data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190320', '20190320T095244.A_Elmo.B_JK.SCP_01.sessiondir');
end

EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', '20190320T095244.A_Elmo.B_JK.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog.txt');
PQtrackerfilenameA= fullfile(data_dir, 'trackerlogfiles', '20190320T095244.A_Elmo.B_JK.SCP_01.TID_PQLabTrackerA.trackerlog.txt');
PQtrackerfilenameB= fullfile(data_dir, 'trackerlogfiles', '20190320T095244.A_Elmo.B_JK.SCP_01.TID_SecondaryPQLabTrackerB.trackerlog.txt');


maintask_datastruct=load(fullfile(data_dir, '20190320T095244.A_Elmo.B_JK.SCP_01.triallog.v012.mat'));
EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', '20190320T095244.A_Elmo.B_JK.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog.txt.gz');
EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', '20190320T095244.A_Elmo.B_JK.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');

PQtrackerfilenameA = fullfile(data_dir, 'trackerlogfiles', '20190320T095244.A_Elmo.B_JK.SCP_01.TID_PQLabTrackerA.trackerlog.txt.gz');
PQtrackerfilenameB = fullfile(data_dir, 'trackerlogfiles', '20190320T095244.A_Elmo.B_JK.SCP_01.TID_SecondaryPQLabTrackerB.trackerlog.txt.gz');

PQtrackerfilenameA = fullfile(data_dir, 'trackerlogfiles', '20190320T095244.A_Elmo.B_JK.SCP_01.TID_PQLabTrackerA.trackerlog');
PQtrackerfilenameB = fullfile(data_dir, 'trackerlogfiles', '20190320T095244.A_Elmo.B_JK.SCP_01.TID_SecondaryPQLabTrackerB.trackerlog');


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

[trialnum_tracker] = fn_trialnumber(maintask_datastruct, data_struct_extract); %%This function tells which gaze data points are a part of which trial.

% parsing and removing invalid touch points. Tells each timepoints to which trial
% belongs 
[validUnique_touchpointsA, touchtracker_datastructA, trialnum_tracker_TouchpointsA] = fn_PQtrackerdata(PQtrackerfilenameA, maintask_datastruct); 
[validUnique_touchpointsB, touchtracker_datastructB, trialnum_tracker_TouchpointsB] = fn_PQtrackerdata(PQtrackerfilenameB, maintask_datastruct);

%Gaze/Touch points on the basis of trials

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

%%This is to define the epoch: aligned to the Initial fixation release time of the Player A (Elmo in my case, but can be used as it is for any data)
%%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/
ArrayforInterpolation=(-1:0.002:0.5);
[epochdataGazeA_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGaze, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_A]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchA_Initial_Fixation_Release_B]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeA_Initial_Fixation_Release_A]= tn_interpTrialDataEpoch(epochdataGazeA_Initial_Fixation_Release_A, ArrayforInterpolation);
[InterpolatedepochdataTouchA_Initial_Fixation_Release_A]= tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_A, InterpolatedepochdataGazeA_Initial_Fixation_Release_A); 
[InterpolatedepochdataTouchA_Initial_Fixation_Release_B]= tn_interpTrialDataTouch(epochdataTouchA_Initial_Fixation_Release_B, InterpolatedepochdataGazeA_Initial_Fixation_Release_A);

%Segregation of trials  
[ModifiedTrialSets]=rn_segregateTrialData(maintask_datastruct);

%Plotting reaction times during switching block trials
%[Cur_fh_RTbyChoiceCombinationSwitches, merged_classifier_char_string]=rn_reactiontime_switching_block_trials(maintask_datastruct,ModifiedTrialSets);
 
%load t_form
t_form = load(fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190320','GAZEREG.SID_20190320T092435.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat'));

%apply the chosen registration to the raw left and right eye
registered_left_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Left_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Left_Eye_Raw_Y))]);
registered_right_eye_gaze_samples = transformPointsInverse(t_form.registration_struct.polynomial.Right_Eye_Raw.tform, [(data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_X)) (data_struct_extract.data(:,data_struct_extract.cn.Right_Eye_Raw_Y))]);

%convert to DVA
[left_x_position_list_deg, left_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_left_eye_gaze_samples(:,1),registered_left_eye_gaze_samples(:,2),...
	960, 341.2698, 1920/1209.4, 1080/680.4, 300);

[right_x_position_list_deg, right_y_position_list_deg] = fn_convert_pixels_2_DVA(registered_right_eye_gaze_samples(:,1),registered_right_eye_gaze_samples(:,2),...
	960, 341.2698, 1920/1209.4, 1080/680.4, 300);

% detection saccades(Igor's toolbox)

neg_timestamp_idx = find(data_struct_extract.data(:,data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp) < 0);
first_good_sample_idx = neg_timestamp_idx(end) + 1;
fgs_idx = first_good_sample_idx;

%left_eye_out = em_saccade_blink_detection(data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000, left_x_position_list_deg(fgs_idx:end), left_y_position_list_deg(fgs_idx:end), 'em_custom_settings_SNP_eyelink.m');
right_eye_out = em_saccade_blink_detection(data_struct_extract.data(fgs_idx:end, data_struct_extract.cn.Tracker_corrected_EventIDE_TimeStamp)/ 1000, right_x_position_list_deg(fgs_idx:end), right_y_position_list_deg(fgs_idx:end), 'em_custom_settings_SNP_eyelink.m');

distance_gaze_left_eye = sqrt(((data_struct_extract.data(:,2) - left_x_position_list_deg).^2)+(((data_struct_extract.data(:,3)-left_y_position_list_deg).^2)));
distance_gaze_right_eye = sqrt(((data_struct_extract.data(:,2) - right_x_position_list_deg).^2)+(((data_struct_extract.data(:,3)-right_y_position_list_deg).^2)));
vergence = (distance_gaze_left_eye-distance_gaze_right_eye);
h=histogram(vergence);

vergence = sqrt((registered_left_eye_gaze_samples(:, 1) - registered_right_eye_gaze_samples(:, 1)).^2 +...
				(registered_left_eye_gaze_samples(:, 2) - registered_right_eye_gaze_samples(:, 2)).^2);

vergence = (registered_right_eye_gaze_samples(:, 1) - registered_left_eye_gaze_samples(:, 1));		
		
ranged_vergence_idx = find(vergence >= -100 & vergence <= 100);
figure('Name', 'vergence histogram');
h=histogram(vergence(ranged_vergence_idx), 200);

abs_vergence = abs(vergence);			
figure('Name', 'Vergence histogram [pixel]');
h=histogram(vergence);



Xedges = (0:1:1920);
Yedges = (0:1:1080);
figure('Name', 'Gaze histogram');
histogram2(registered_right_eye_gaze_samples(:, 1), registered_right_eye_gaze_samples(:, 2), Xedges, Yedges, 'DisplayStyle', 'tile');
set(gca(), 'YDir', 'reverse');

[N, Xedges, Yedges, binX, binY] = histcounts2(registered_right_eye_gaze_samples(:, 1), registered_right_eye_gaze_samples(:, 2), Xedges, Yedges);

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
		
		tmp_max = max(vergence(current_sample_set));
		if ~isempty(tmp_max)
			max_vergence_array(i_x, i_y) = tmp_max;
			absmax_vergence_array(i_x, i_y) = max(abs_vergence(current_sample_set));
		end
		
		tmp_min = min(vergence(current_sample_set));
		if ~isempty(tmp_min)
			min_vergence_array(i_x, i_y) = tmp_min;
			absmin_vergence_array(i_x, i_y) = min(abs_vergence(current_sample_set));
		end
		
		tmp_mean = mean(vergence(current_sample_set));
		if ~isempty(mean(vergence(current_sample_set)))
			mean_vergence_array(i_x, i_y) = mean(vergence(current_sample_set));
		end
	end
end	
	
figure('Name', 'maximal Vergenace');
imagesc(max_vergence_array')
colorbar;
set(gca(), 'CLim', [-100, 100]);

figure('Name', 'mean Vergenace');
imagesc(mean_vergence_array')
colorbar;
set(gca(), 'CLim', [-100, 100]);

figure('Name', 'absmax Vergenace');
imagesc(absmax_vergence_array')
colorbar;
set(gca(), 'CLim', [-100, 100]);

figure('Name', 'min Vergenace');
imagesc(min_vergence_array')
colorbar;
set(gca(), 'CLim', [-100, 100]);

figure('Name', 'absmin Vergenace');
imagesc(absmin_vergence_array')
colorbar;
set(gca(), 'CLim', [-100, 100]);


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
 
%UNBLOCKED TRIALS
%Human behavior : switch from Red to Blue

switch_trial_RB = ModifiedTrialSets.BySwitchingBlock.RB ;
trial_before_switch_RB = (switch_trial-1) ;
trial_next_switch_RB = (switch_trial+1) ;

fixation_onsets_switch_trial_RB = fixation_onsets(switch_trial);
fixation_x_coordinates_switch_trial_RB= epochdataGazeA.TargetOnset.xCoordinates(switch_trial);
fixation_y_coordinates_switch_trial_RB = epochdataGazeA.TargetOnset.yCoordinates(switch_trial);


fixation_onsets_trial_before_switch_RB = fixation_onsets(trial_before_switch);
fixation_x_coordinates_trial_before_switch_RB = epochdataGazeA.TargetOnset.xCoordinates(trial_before_switch);
fixation_y_coordinates_trial_before_switch_RB = epochdataGazeA.TargetOnset.yCoordinates(trial_before_switch);
	
fixation_onsets_trial_next_switch_RB = fixation_onsets(trial_next_switch);
fixation_x_coordinates_trial_next_switch_RB = epochdataGazeA.TargetOnset.xCoordinates(trial_next_switch);
fixation_x_coordinates_trial_next_switch_RB = epochdataGazeA.TargetOnset.yCoordinates(trial_next_switch);

%Human behavior : switch from Blue to Red 

switch_trial_BR = ModifiedTrialSets.BySwitchingBlock.BR ;
trial_before_switch_BR = (switch_trial-1) ;
trial_next_switch_BR = (switch_trial+1) ;

fixation_onsets_switch_trial_BR = fixation_onsets(switch_trial);
fixation_x_coordinates_switch_trial_BR= epochdataGazeA.TargetOnset.xCoordinates(switch_trial);
fixation_y_coordinates_switch_trial_BR = epochdataGazeA.TargetOnset.yCoordinates(switch_trial);

fixation_onsets_trial_before_switch_BR = fixation_onsets(trial_before_switch);
fixation_x_coordinates_trial_before_switch_BR = epochdataGazeA.TargetOnset.xCoordinates(trial_before_switch);
fixation_y_coordinates_trial_before_switch_BR = epochdataGazeA.TargetOnset.yCoordinates(trial_before_switch);
	
fixation_onsets_trial_next_switch_BR = fixation_onsets(trial_next_switch);
fixation_x_coordinates_trial_next_switch_BR = epochdataGazeA.TargetOnset.xCoordinates(trial_next_switch);
fixation_x_coordinates_trial_next_switch_BR = epochdataGazeA.TargetOnset.yCoordinates(trial_next_switch);




