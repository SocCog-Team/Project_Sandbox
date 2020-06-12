
%%Adding the address of eye-tracker (Eye-link data only) and touch-tracker logfiles and the task data structure-START%% 
%%You will get this from fnParseEventIDETrackerLog_v01 and fnParseEventIDEReportSCPv06
tn_addpath();

fileID='20190312T085408.A_Elmo.B_JK.SCP_01.';

if (ispc)
    saving_dir='C:\taskcontroller\SCP_DATA\ANALYSES\GazeAnalyses';
    data_root_str = 'C:';
    data_dir = fullfile(data_root_str, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190312', '20190312T085408.A_Elmo.B_JK.SCP_01.sessiondir');
    % PupilLabsfilenameA='20190313T153709.A_RN.B_LA.SCP_01.TID_PupilLabsTrackerA.trackerlog.txt';
    %%%%Adding the address of eye-tracker and touch-tracker logfiles and the task data structure-END%%
else
    data_root_str = '/';
    saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN');
    data_base_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ');
    
    % network!
    data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data');
    
    data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190312', '20190312T085408.A_Elmo.B_JK.SCP_01.sessiondir');
end

EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', '20190312T085408.A_Elmo.B_JK.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog.txt.Fixed.txt');
PQtrackerfilenameA= fullfile(data_dir, 'trackerlogfiles', '20190312T085408.A_Elmo.B_JK.SCP_01.TID_PQLabTrackerA.trackerlog.txt.Fixed.txt');
PQtrackerfilenameB= fullfile(data_dir, 'trackerlogfiles', '20190312T085408.A_Elmo.B_JK.SCP_01.TID_SecondaryPQLabTrackerB.trackerlog.txt.Fixed.txt');

maintask_datastruct=load(fullfile(data_dir, '20190312T085408.A_Elmo.B_JK.SCP_01.triallog.v012.mat'));
EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', '20190312T085408.A_Elmo.B_JK.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog.txt.gz');
PQtrackerfilenameA= fullfile(data_dir, 'trackerlogfiles', '20190312T085408.A_Elmo.B_JK.SCP_01.TID_PQLabTrackerA.trackerlog.txt.gz');
PQtrackerfilenameB= fullfile(data_dir, 'trackerlogfiles', '20190312T085408.A_Elmo.B_JK.SCP_01.TID_SecondaryPQLabTrackerB.trackerlog.txt.gz');



data_struct_extract = struct([]);
data_struct_extract = fnParseEventIDETrackerLog_v01 (EyeLinkfilenameA, ';', [], []);

nrows_eyetracker = 0;
ncols_eyetracker = 0;
[nrows_eyetracker, ncols_eyetracker] = size(data_struct_extract.data);
nrows_maintask = 0;
ncols_maintask = 0;

[nrows_maintask,ncols_maintask] = size(maintask_datastruct.report_struct.data);
invalid_datapoints = find(data_struct_extract.data (:,2)==-32768); %% Removing invalid data pts as defined by eyelink/eventide
data_struct_extract.data(invalid_datapoints,2:3) = NaN;



[ trialnum_tracker ]= fn_trialnumber (maintask_datastruct, data_struct_extract); %%This function tells which gaze data points are a part of which trial.

% [trialdata_x, trialdata_y, num_pts_in_a_trial,timepoints]=fn_trialwise_data (nrows_eyetracker, data_struct_extract,trialnum_tracker, trialnumber );

% [trial_deg_x,trial_deg_y]=fn_pix2deg_xy(trialdata_x, trialdata_y);
% save test_trial trial_deg_x trial_deg_y timepoints
% out=em_saccade_blink_detection(timepoints,trial_deg_x,trial_deg_y,'em_custom_settings_SNP_eyelink.m');
% saveas(gcf,fullfile(saving_dir,[fileID,'_',trialnumber '_saccade_detection_plot.png']));
% fn_trialwise_plot (maintask_datastruct, trialdata_x, trialdata_y, num_pts_in_a_trial, trialnumber, fileID, saving_dir, central_touch_target_x , central_touch_target_y,timepoints);
% 
%fn_PQtrackerdata:  In this function, the touch tracker logfile is parsed and invalid data pts are removed and
%%gaze datapts with the same time pt are removed with the unique function
%%This also tells which touch datapoint occurs in which trial. 
[validUnique_touchpointsA, touchtracker_datastructA, trialnum_tracker_TouchpointsA]= fn_PQtrackerdata(PQtrackerfilenameA, maintask_datastruct); 
[validUnique_touchpointsB, touchtracker_datastructB, trialnum_tracker_TouchpointsB]= fn_PQtrackerdata(PQtrackerfilenameB, maintask_datastruct);
% All this function does is arrange data on the basis of trials. So, x , y ,t are in three sub-structures . 
%%And in each of those, Each row has a dimension of gaze/ touch data of a trial.  
[TrialWiseDataGazeA]= tn_trialwiseDataStructure(data_struct_extract.data,trialnum_tracker,nrows_maintask); 
[TrialWiseDataTouchA]= tn_trialwiseDataStructure(validUnique_touchpointsA.data,trialnum_tracker_TouchpointsA,nrows_maintask);
[TrialWiseDataTouchB]= tn_trialwiseDataStructure(validUnique_touchpointsB.data,trialnum_tracker_TouchpointsB,nrows_maintask);
[a, b]=size(TrialWiseDataTouchB.timepoints);

%%Here, I am interpolating the whole data series, on a trial-by-trial
%%fashion; such that all data is equally spaced.
[InterpolatedTrialWiseDataGazeA]= tn_interpTrialData(TrialWiseDataGazeA);
[InterpolatedTrialWiseDataTouchA]= tn_interpTrialDataTouch(TrialWiseDataTouchA, InterpolatedTrialWiseDataGazeA); 
[InterpolatedTrialWiseDataTouchB]= tn_interpTrialDataTouch(TrialWiseDataTouchB, InterpolatedTrialWiseDataGazeA);
ArrayforInterpolation=(-0.5:0.002:1.3);
%%This is to define the epoch: aligned to the coloured target onset
%%time
[epochdataGazeA]= tn_defineEpochnew(InterpolatedTrialWiseDataGazeA, maintask_datastruct); %To Target Onset
[epochdataTouchA]= tn_defineEpochnew(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchB]= tn_defineEpochnew(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeA]= tn_interpTrialDataEpoch(epochdataGazeA.TargetOnset, ArrayforInterpolation);
[InterpolatedepochdataTouchA]= tn_interpTrialDataTouch(epochdataTouchA.TargetOnset, InterpolatedepochdataGazeA); 
[InterpolatedepochdataTouchB]= tn_interpTrialDataTouch(epochdataTouchB.TargetOnset, InterpolatedepochdataGazeA);

%%This is to define the epoch: aligned to the Initial fixation release time of the Player B (confederate in my case, but can be used as it is for any data)
%%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/  
ArrayforInterpolation=(-0.2:0.002:0.9);
[epochdataGazeBIFRA]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGazeA, maintask_datastruct);
[epochdataTouchBIFRA]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchBIFRB]= tn_defineEpochnewAlignedtoB_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeBIFRA]= tn_interpTrialDataEpoch(epochdataGazeBIFRA, ArrayforInterpolation);
[InterpolatedepochdataTouchBIFRA]= tn_interpTrialDataTouch(epochdataTouchBIFRA, InterpolatedepochdataGazeBIFRA); 
[InterpolatedepochdataTouchBIFRB]= tn_interpTrialDataTouch(epochdataTouchBIFRB, InterpolatedepochdataGazeBIFRA);


%%This is to define the epoch: aligned to the Initial fixation release time of the Player A (Elmo in my case, but can be used as it is for any data)
%%I interpolate this epoch data to an equally spaced array. Now , I will have all touch and gaze data at the same time points/
ArrayforInterpolation=(-1:0.002:0.5);
[epochdataGazeAIFRA]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataGazeA, maintask_datastruct);
[epochdataTouchAIFRA]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchA, maintask_datastruct);
[epochdataTouchAIFRB]= tn_defineEpochnewAlignedtoA_InitialFixationReleaseTime_ms(InterpolatedTrialWiseDataTouchB, maintask_datastruct);
[InterpolatedepochdataGazeAIFRA]= tn_interpTrialDataEpoch(epochdataGazeAIFRA, ArrayforInterpolation);
[InterpolatedepochdataTouchAIFRA]= tn_interpTrialDataTouch(epochdataTouchAIFRA, InterpolatedepochdataGazeAIFRA); 
[InterpolatedepochdataTouchAIFRB]= tn_interpTrialDataTouch(epochdataTouchAIFRB, InterpolatedepochdataGazeAIFRA);

%%This is to segregate data into the different, side, value and action
%%visibility conditions. *But, this has many more segregations.
[ModifiedTrialSets]=tn_segregateTrialData(maintask_datastruct);
[AIFRrelativetoBIFR]=tn_MeanAIFR(maintask_datastruct); 

%%All this is just for plotting data
tn_TrialWiseNEWPlots(epochdataGazeA, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID);
tn_TrialWiseNEWPlotsAlignedtoBIFR(InterpolatedepochdataGazeBIFRA, InterpolatedepochdataTouchBIFRA,InterpolatedepochdataTouchBIFRB, ModifiedTrialSets, saving_dir, fileID);
tn_TrialWiseNEWPlotsAlignedtoAIFR(InterpolatedepochdataGazeAIFRA, InterpolatedepochdataTouchAIFRA,InterpolatedepochdataTouchAIFRB, ModifiedTrialSets, saving_dir, fileID);

%%Here, I just calculate the difference between gaze and touch at each time
%%point
[BIFRdistGazeATouchB]= tn_distbetweenGazeTouch(InterpolatedepochdataGazeBIFRA, InterpolatedepochdataTouchBIFRB);
[BIFRdistGazeATouchA]= tn_distbetweenGazeTouch(InterpolatedepochdataGazeBIFRA, InterpolatedepochdataTouchBIFRA);

[AIFRdistGazeATouchB]= tn_distbetweenGazeTouch(InterpolatedepochdataGazeAIFRA, InterpolatedepochdataTouchAIFRB);
[AIFRdistGazeATouchA]= tn_distbetweenGazeTouch(InterpolatedepochdataGazeAIFRA, InterpolatedepochdataTouchAIFRA);


%%Just for plotting- again; But I also structure the previously calculated
%%data and utilise the trial condition segregation
[BIFRSeparatedDistGazeATouchA, BIFRSeparatedDistGazeATouchB]= tn_TrialWiseDISTNEWPlotsAlignedtoBIFR(BIFRdistGazeATouchA, BIFRdistGazeATouchB,InterpolatedepochdataGazeBIFRA, ModifiedTrialSets, saving_dir, fileID);
[AIFRSeparatedDistGazeATouchA, AIFRSeparatedDistGazeATouchB]= tn_TrialWiseDISTNEWPlotsAlignedtoAIFR(AIFRdistGazeATouchA, AIFRdistGazeATouchB,InterpolatedepochdataGazeAIFRA, ModifiedTrialSets, saving_dir, fileID);

[BIFRSeparatedpSeeplus50DistGazeATouchA, BIFRSeparatedpSeeplus50DistGazeATouchB, BIFRSeparatedpSeeplus50Timepoints,BIFRSeparatedpSeeplus50AIFRvalues]= tn_TrialWiseDISTNEWPlotsAlignedtoBIFRpSeeGreaterThanChance(BIFRdistGazeATouchA, BIFRdistGazeATouchB,InterpolatedepochdataGazeBIFRA.timepoints, ModifiedTrialSets, saving_dir, fileID, AIFRrelativetoBIFR);
[BIFRSeparatedpSeeless50DistGazeATouchA, BIFRSeparatedpSeeless50DistGazeATouchB, BIFRSeparatedpSeeless50Timepoints,BIFRSeparatedpSeeless50AIFRvalues]= tn_TrialWiseDISTNEWPlotsAlignedtoBIFRpSeeLesserThanChance(BIFRdistGazeATouchA, BIFRdistGazeATouchB,InterpolatedepochdataGazeBIFRA.timepoints, ModifiedTrialSets, saving_dir, fileID, AIFRrelativetoBIFR);

[AIFRSeparatedpSeeplus50DistGazeATouchA, AIFRSeparatedpSeeplus50DistGazeATouchB, AIFRSeparatedpSeeplus50Timepoints]= tn_TrialWiseDISTNEWPlotsAlignedtoAIFRpSeeGreaterThanChance(AIFRdistGazeATouchA, AIFRdistGazeATouchB,InterpolatedepochdataGazeAIFRA.timepoints, ModifiedTrialSets, saving_dir, fileID);
[AIFRSeparatedpSeeless50DistGazeATouchA, AIFRSeparatedpSeeless50DistGazeATouchB, AIFRSeparatedpSeeless50Timepoints]= tn_TrialWiseDISTNEWPlotsAlignedtoAIFRpSeeLesserThanChance(AIFRdistGazeATouchA, AIFRdistGazeATouchB,InterpolatedepochdataGazeAIFRA.timepoints, ModifiedTrialSets, saving_dir, fileID);


%%Now, this is just for arranging all the data in nice and neat structures.
%%At the end, this is the structure which I export as a matfile and save.
EpochWiseData.FullTrial.Aligned_Data.Gaze.A=TrialWiseDataGazeA;
EpochWiseData.FullTrial.Aligned_Data.Touch.A=TrialWiseDataTouchA;
EpochWiseData.FullTrial.Aligned_Data.Touch.B=TrialWiseDataTouchB;

EpochWiseData.TargetOnset.Aligned_Data.Gaze.A=epochdataGazeA;
EpochWiseData.TargetOnset.Aligned_Data.Touch.A=epochdataTouchA;
EpochWiseData.TargetOnset.Aligned_Data.Touch.B=epochdataTouchB;

EpochWiseData.AIFR.Aligned_Data.Gaze.A=epochdataGazeAIFRA;
EpochWiseData.AIFR.Aligned_Data.Touch.A=epochdataTouchAIFRA;
EpochWiseData.AIFR.Aligned_Data.Touch.B=epochdataTouchAIFRB;

EpochWiseData.BIFR.Aligned_Data.Gaze.A=epochdataGazeBIFRA;
EpochWiseData.BIFR.Aligned_Data.Touch.A=epochdataTouchBIFRA;
EpochWiseData.BIFR.Aligned_Data.Touch.B=epochdataTouchBIFRB;


EpochWiseData.FullTrial.Aligned_Interpolated_Data.Gaze.A=InterpolatedTrialWiseDataGazeA;
EpochWiseData.FullTrial.Aligned_Interpolated_Data.Touch.A=InterpolatedTrialWiseDataTouchA;
EpochWiseData.FullTrial.Aligned_Interpolated_Data.Touch.B=InterpolatedTrialWiseDataTouchB;

EpochWiseData.TargetOnset.Aligned_Interpolated_Data.Gaze.A=InterpolatedepochdataGazeA;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.Touch.A=InterpolatedepochdataTouchA;
EpochWiseData.TargetOnset.Aligned_Interpolated_Data.Touch.B=InterpolatedepochdataTouchB;

EpochWiseData.AIFR.Aligned_Interpolated_Data.Gaze.A=InterpolatedepochdataGazeAIFRA;
EpochWiseData.AIFR.Aligned_Interpolated_Data.Touch.A=InterpolatedepochdataTouchAIFRA;
EpochWiseData.AIFR.Aligned_Interpolated_Data.Touch.B=InterpolatedepochdataTouchAIFRB;


EpochWiseData.BIFR.Aligned_Interpolated_Data.Gaze.A=InterpolatedepochdataGazeBIFRA;
EpochWiseData.BIFR.Aligned_Interpolated_Data.Touch.A=InterpolatedepochdataTouchBIFRA;
EpochWiseData.BIFR.Aligned_Interpolated_Data.Touch.B=InterpolatedepochdataTouchBIFRB;

EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.AA=AIFRdistGazeATouchA;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.AB=AIFRdistGazeATouchA;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.AA=BIFRdistGazeATouchA;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.AB=BIFRdistGazeATouchA;

EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_Based.AA=AIFRSeparatedDistGazeATouchA;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_Based.AB=AIFRSeparatedDistGazeATouchB;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Plus50.AA=AIFRSeparatedpSeeplus50DistGazeATouchA;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Less50.AA=AIFRSeparatedpSeeless50DistGazeATouchA;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Plus50.AB=AIFRSeparatedpSeeplus50DistGazeATouchB;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Less50.AB=AIFRSeparatedpSeeless50DistGazeATouchB;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Plus50.Timepoints=AIFRSeparatedpSeeplus50Timepoints;
EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Less50.Timepoints=AIFRSeparatedpSeeless50Timepoints;




EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_Based.AA=BIFRSeparatedDistGazeATouchA;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_Based.AB=BIFRSeparatedDistGazeATouchB;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Plus50.AA=BIFRSeparatedpSeeplus50DistGazeATouchA;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Less50.AA=BIFRSeparatedpSeeless50DistGazeATouchA;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Plus50.AB=BIFRSeparatedpSeeplus50DistGazeATouchB;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Less50.AB=BIFRSeparatedpSeeless50DistGazeATouchB;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Plus50.Timepoints=BIFRSeparatedpSeeplus50Timepoints;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Less50.Timepoints=BIFRSeparatedpSeeless50Timepoints;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Plus50.AIFRvalues=BIFRSeparatedpSeeplus50AIFRvalues;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Separated.Value_Side_pSee_Based.Less50.AIFRvalues=BIFRSeparatedpSeeless50AIFRvalues;

EpochWiseData.TrialSets=ModifiedTrialSets;

%%This is just to save the matfile. Name has to be changed every time. Or
%%you could just automate it. 
if (ispc)
    save( 'C:\taskcontroller\SCP_DATA\SCP-CTRL-01\SESSIONLOGS\2019\190312\20190312T085408.A_Elmo.B_JK.SCP_01.SCP_01.sessiondir\20190312T085408.A_Elmo.B_JK.SCP_01.GazeTouchAnalyses.mat', '-v7.3', 'EpochWiseData');
else
   save(fullfile(saving_dir, '20190312T085408.A_Elmo.B_JK.SCP_01.GazeTouchAnalyses.mat'), '-v7.3', 'EpochWiseData'); 
end

close all

%%This is to run the cluster-based permutation test. 
[pSeePlus50keys, pSeePlus50scores]= tn_StructureDatatoRunMS_permtest(BIFRSeparatedpSeeplus50DistGazeATouchA,BIFRSeparatedpSeeplus50DistGazeATouchB, BIFRSeparatedpSeeplus50Timepoints);
[pSeeless50keys, pSeeless50scores]= tn_StructureDatatoRunMS_permtest(BIFRSeparatedpSeeless50DistGazeATouchA,BIFRSeparatedpSeeless50DistGazeATouchB, BIFRSeparatedpSeeless50Timepoints);

% save( 'C:\taskcontroller\SCP_DATA\SCP-CTRL-01\SESSIONLOGS\2019\190312\20190312T085408.A_Elmo.B_JK.SCP_01.sessiondir\20190312T085408_AElmo_BJK_SCP01GazeTouchAnalyses_WithInterpolateduniformgazeTouchresampled.mat', '-v7.3',  'trialnum_tracker', 'trialnum_tracker_TouchpointsA', 'trialnum_tracker_TouchpointsB', 'TrialWiseDataGazeA', 'TrialWiseDataTouchA', 'TrialWiseDataTouchB','InterpolatedTrialWiseDataGazeA', 'InterpolatedTrialWiseDataTouchA', 'InterpolatedTrialWiseDataTouchB', 'epochdataGazeA', 'epochdataTouchA', 'epochdataTouchB', 'epochdataGazeBIFRA', 'epochdataTouchBIFRA', 'epochdataTouchBIFRB','epochdataGazeAIFRA', 'epochdataTouchAIFRA', 'epochdataTouchAIFRB', 'BIFRdistGazeATouchB', 'BIFRdistGazeATouchA','AIFRdistGazeATouchB', 'AIFRdistGazeATouchA', 'ModifiedTrialSets', 'BIFRSeparatedDistGazeATouchA', 'BIFRSeparatedDistGazeATouchB','AIFRSeparatedDistGazeATouchA', 'AIFRSeparatedDistGazeATouchB' ,'BIFRSeparatedBySelectedSide_A_DistGazeATouchA','BIFRSeparatedBySelectedSide_A_DistGazeATouchB', 'BIFRSeparatedBySelectedSide_A_scores', 'BIFRSeparatedBySelectedSide_A_TimepointsTrialWise', 'BIFRSeparatedpSeeless50DistGazeATouchA',  'BIFRSeparatedpSeeless50DistGazeATouchB', 'BIFRSeparatedpSeeless50Timepoints', 'BIFRSeparatedpSeeplus50DistGazeATouchA', 'BIFRSeparatedpSeeplus50DistGazeATouchB', 'BIFRSeparatedpSeeplus50Timepoints', 'pSeeless50scores', 'pSeePlus50scores', 'InterpolatedepochdataGazeA','InterpolatedepochdataGazeAIFRA', 'InterpolatedepochdataGazeBIFRA', 'InterpolatedepochdataTouchA','InterpolatedepochdataTouchAIFRA', 'InterpolatedepochdataTouchBIFRA', 'InterpolatedepochdataTouchB','InterpolatedepochdataTouchAIFRB', 'InterpolatedepochdataTouchBIFRB', 'InterpolatedTrialWiseDataGazeA', 'InterpolatedTrialWiseDataTouchA','InterpolatedTrialWiseDataTouchB', 'RandTrial')


