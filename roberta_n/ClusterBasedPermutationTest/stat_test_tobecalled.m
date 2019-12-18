function [] = stat_test_tobecalled()

dbstop if error

data_root_str = fullfile('C:', 'SCP');
saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN', 'Elmo_JK_merged_all', 'Merged Heights plots');
%filename = 'AllGazeTouchAnalyses.mat';
%load(fullfile(saving_dir,'AllGazeTouchAnalyses.mat'))
filename = 'FixationTouchAnalyses.mat';
load(fullfile(saving_dir,'FixationTouchAnalyses.mat'))

FullStructure_unblocked_Touch = EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked;

FullStructure_unblocked_FirstFollowing_Touch_BR = EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_BR; 
FullStructure_unblocked_PreFirstFollowing_Touch_BR = EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_BR; 
FullStructure_unblocked_FirstFollowing_Touch_RB = EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB; 
FullStructure_unblocked_PreFirstFollowing_Touch_RB = EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB; 
FullStructure_blocked_Touch = EpochWiseData.TargetOnset.Aligned_Rawdata.Touch.Blocked;

FullStructure_unblocked_Gaze = EpochWiseData.TargetOnset.Aligned_Rawdata.Gaze.Unblocked;
FullStructure_unblocked_FirstFollowing_Gaze_BR = EpochWiseData.TargetOnset.Aligned_Rawdata.Gaze.Unblocked_FirstFollowing_BR; 
FullStructure_unblocked_PreFirstFollowing_Gaze_BR = EpochWiseData.TargetOnset.Aligned_Rawdata.Gaze.Unblocked_PreFirstFollowing_BR; 
FullStructure_unblocked_FirstFollowing_Gaze_RB = EpochWiseData.TargetOnset.Aligned_Rawdata.Gaze.Unblocked_FirstFollowing_RB; 
FullStructure_unblocked_PreFirstFollowing_Gaze_RB = EpochWiseData.TargetOnset.Aligned_Rawdata.Gaze.Unblocked_PreFirstFollowing_RB; 
FullStructure_blocked_Gaze = EpochWiseData.TargetOnset.Aligned_Rawdata.Gaze.Blocked;
FullStructure_unblocked_Vergence = EpochWiseData.TargetOnset.Aligned_Rawdata.Vergence.Unblocked; 
FullStructure_unblocked_FirstFollowing_Vergence_RB = EpochWiseData.TargetOnset.Aligned_Rawdata.Vergence.Unblocked_FirstFollowing_RB; 
FullStructure_unblocked_PreFirstFollowing_Vergence_RB = EpochWiseData.TargetOnset.Aligned_Rawdata.Vergence.Unblocked_PreFirstFollowing_RB; 
FullStructure_unblocked_FirstFollowing_Vergence_BR = EpochWiseData.TargetOnset.Aligned_Rawdata.Vergence.Unblocked_FirstFollowing_BR; 
FullStructure_unblocked_PreFirstFollowing_Vergence_BR = EpochWiseData.TargetOnset.Aligned_Rawdata.Vergence.Unblocked_PreFirstFollowing_BR; 
FullStructure_blocked_Vergence = EpochWiseData.TargetOnset.Aligned_Rawdata.Vergence.Blocked;

FullStructure_unblocked_BIFR_Touch = EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked;
FullStructure_blocked_BIFR_Touch = EpochWiseData.BIFR.Aligned_Rawdata.Touch.Blocked;
FullStructure_blocked_BIFR_Gaze =  EpochWiseData.BIFR.Aligned_Rawdata.Gaze.Blocked
FullStructure_unblocked_BIFR_Gaze =  EpochWiseData.BIFR.Aligned_Rawdata.Gaze.Unblocked
FullStructure_blocked_BIFR_Vergence =  EpochWiseData.BIFR.Aligned_Rawdata.Vergence.Blocked
FullStructure_unblocked_BIFR_Vergence =  EpochWiseData.BIFR.Aligned_Rawdata.Vergence.Unblocked
FullStructure_unblocked_AIFR_Touch = EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked;
FullStructure_blocked_AIFR_Touch =  EpochWiseData.AIFR.Aligned_Rawdata.Touch.Blocked;
FullStructure_blocked_AIFR_Gaze =  EpochWiseData.AIFR.Aligned_Rawdata.Gaze.Blocked
FullStructure_unblocked_AIFR_Gaze =  EpochWiseData.AIFR.Aligned_Rawdata.Gaze.Unblocked
FullStructure_blocked_AIFR_Vergence =  EpochWiseData.AIFR.Aligned_Rawdata.Vergence.Blocked
FullStructure_unblocked_AIFR_Vergence =  EpochWiseData.AIFR.Aligned_Rawdata.Vergence.Unblocked

%COMPARISON BETWEEN TOUCH A UNBLOCKED AND TOUCH A BLOCKED: TARGET ONSET 
[scores_unblockedTouchAVSblockedTouchA, FullStructure_unblockedTouchAVSblockedTouchA] = rn_StructureDataforPermTest(FullStructure_unblocked_Touch,FullStructure_blocked_Touch);
rn_PlotAvgCombinedTouchAunblockedVSTouchAblocked(FullStructure_unblockedTouchAVSblockedTouchA, FullStructure_unblocked_Touch,FullStructure_blocked_Touch, saving_dir);
%COMPARISON BETWEEN TOUCH A UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : TARGET ONSET
[scores_unblockedTouchAVSunblockedTouchA, FullStructure_unblockedTouchAVSunblockedTouchA] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked_Touch);
rn_PlotAvgCombined_Touch_different_conditions_unblocked(FullStructure_unblockedTouchAVSunblockedTouchA,FullStructure_unblocked_Touch,saving_dir);
%COMPARISON BETWEEN TOUCH A BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : TARGET ONSET 
[scores_blockedTouchAVSblockedTouchA, FullStructure_blockedTouchAVSblockedTouchA] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked_Touch);
rn_PlotAvgCombined_Touch_different_conditions_blocked (FullStructure_blockedTouchAVSblockedTouchA, FullStructure_blocked_Touch, saving_dir)

%COMPARISON BETWEEN TOUCH B UNBLOCKED AND TOUCH B BLOCKED: TARGET ONSET 
[scores_unblockedTouchBVSblockedTouchB, FullStructure_unblockedTouchBVSblockedTouchB] = rn_StructureDataforPermTest_B(FullStructure_unblocked_Touch,FullStructure_blocked_Touch);
rn_PlotAvgCombinedTouchBunblockedVSTouchBblocked(FullStructure_unblockedTouchBVSblockedTouchB, FullStructure_unblocked_Touch,FullStructure_blocked_Touch, saving_dir);
%COMPARISON BETWEEN TOUCH B UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : TARGET ONSET
[scores_unblockedTouchBVSunblockedTouchB, FullStructure_unblockedTouchBVSunblockedTouchB] = rn_StructureDataforPermTest_differentcondition_B(FullStructure_unblocked_Touch);
rn_PlotAvgCombined_Touch_B_different_conditions_unblocked(FullStructure_unblockedTouchBVSunblockedTouchB,FullStructure_unblocked_Touch,saving_dir);
%COMPARISON BETWEEN TOUCH B BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : TARGET ONSET 
[scores_blockedTouchBVSblockedTouchB, FullStructure_blockedTouchBVSblockedTouchB] = rn_StructureDataforPermTest_differentcondition_blocked_B(FullStructure_blocked_Touch);
rn_PlotAvgCombined_Touch_B_different_conditions_blocked(FullStructure_blockedTouchBVSblockedTouchB, FullStructure_blocked_Touch, saving_dir)


%COMPARISON BETWEEN GAZE UNBLOCKED AND GAZE BLOCKED : TARGET ONSET
[scores_unblockedGazeVSblockedGaze, FullStructure_unblockedGazeVSblockedGaze] = rn_StructureDataforPermTest(FullStructure_unblocked_Gaze,FullStructure_blocked_Gaze);
rn_PlotAvgCombinedGazeunblockedVSGazeblocked(FullStructure_unblockedGazeVSblockedGaze, FullStructure_unblocked_Gaze,FullStructure_blocked_Gaze, saving_dir);
%COMPARISON BETWEEN GAZE UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : TARGET ONSET
[scores_unblockedGazeVSunblockedGaze, FullStructure_unblockedGazeVSunblockedGaze] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked_Gaze);
rn_PlotAvgCombined_Gaze_different_conditions_unblocked(FullStructure_unblockedGazeVSunblockedGaze,FullStructure_unblocked_Gaze,saving_dir);
%COMPARISON BETWEEN GAZE BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : TARGET ONSET 
[scores_blockedGazeVSblockedGaze, FullStructure_blockedGazeVSblockedGaze] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked_Gaze);
rn_PlotAvgCombined_Gaze_different_conditions_blocked (FullStructure_blockedGazeVSblockedGaze, FullStructure_blocked_Gaze, saving_dir)

%COMPARISON BETWEEN VERGENCE UNBLOCKED AND VERGENCE BLOCKED : TARGET ONSET
[scores_unblockedVergenceVSblockedVergence, FullStructure_unblockedVergenceVSblockedVergence] = rn_StructureDataforPermTest(FullStructure_unblocked_Vergence,FullStructure_blocked_Vergence);
rn_PlotAvgCombinedVergenceunblockedVSVergenceblocked(FullStructure_unblockedVergenceVSblockedVergence, FullStructure_unblocked_Vergence,FullStructure_blocked_Vergence, saving_dir);
%COMPARISON BETWEEN VERGENCE UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : TARGET ONSET
[scores_unblockedVergenceVSunblockedVergence, FullStructure_unblockedVergenceVSunblockedVergence] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked_Vergence);
rn_PlotAvgCombined_Vergence_different_conditions_unblocked(FullStructure_unblockedVergenceVSunblockedVergence,FullStructure_unblocked_Vergence,saving_dir);
%COMPARISON BETWEEN VERGENCE BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : TARGET ONSET 
[scores_blockedVergenceVSblockedVergence, FullStructure_blockedVergenceVSblockedVergence] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked_Vergence);
rn_PlotAvgCombined_Vergence_different_conditions_blocked (FullStructure_blockedVergenceVSblockedVergence, FullStructure_blocked_Vergence, saving_dir)

%COMPARISON BETWEEN Touch PREFOLLOWING_BR AND FIRST FOLLOWING_BR: TARGET ONSET
[scores_unblockedTouchA_PreFollVSunblockedTouch_AFirstFoll_BR, Full_unblockedTouchA_PreFollVSunblockedTouch_AFirstFoll_BR] = rn_StructureDataforPermTest_foll(FullStructure_unblocked_PreFirstFollowing_Touch_BR,FullStructure_unblocked_FirstFollowing_Touch_BR);
rn_PlotAvgCombinedTouchAunblockedPreVSTouchAunblockedFirst_BR(Full_unblockedTouchA_PreFollVSunblockedTouch_AFirstFoll_BR, FullStructure_unblocked_FirstFollowing_Touch_BR,FullStructure_unblocked_PreFirstFollowing_Touch_BR, saving_dir);
%COMPARISON BETWEEN Touch PREFOLLOWING_RB AND FIRST FOLLOWING_RB: TARGET ONSET
[scores_unblockedTouchA_PreFollVSunblockedTouch_AFirstFoll_RB, Full_unblockedTouchA_PreFollVSunblockedTouch_AFirstFoll_RB] = rn_StructureDataforPermTest_foll(FullStructure_unblocked_PreFirstFollowing_Touch_RB,FullStructure_unblocked_FirstFollowing_Touch_RB);
rn_PlotAvgCombinedTouchAunblockedPreVSTouchAunblockedFirst_RB(Full_unblockedTouchA_PreFollVSunblockedTouch_AFirstFoll_RB, FullStructure_unblocked_FirstFollowing_Touch_RB,FullStructure_unblocked_PreFirstFollowing_Touch_RB, saving_dir);
%COMPARISON BETWEEN TOUCH PREFOLLOWING_RB AND TOUCH FOLLOWING_RB
%OTHER'S/OWN VS OTHER'S/OTHER'S Target onset 
[scores_unblockedTouchA_PreFollVSunblockedTouch_AFirstFoll_RB_su, Full_unbloTouchA_PreFollVSunbloTouch_AFirstFoll_RB_subset] = rn_StructureDataforPermTest_subset_foll(FullStructure_unblocked_PreFirstFollowing_Touch_RB,FullStructure_unblocked_FirstFollowing_Touch_RB);
rn_PlotAvgCombined_TouchA_PreVSFirst_unblocked(Full_unbloTouchA_PreFollVSunbloTouch_AFirstFoll_RB_subset, FullStructure_unblocked_FirstFollowing_Touch_RB,FullStructure_unblocked_PreFirstFollowing_Touch_RB, saving_dir);

%COMPARISON BETWEEN TOUCH PREFOLLOWING_RB AND TOUCH FOLLOWING_RB
%OTHER'S/OWN VS OTHER'S/OTHER'S BIFR
FullStructure_unblocked_PreFirstFollowing_Touch_RB_BIFR = EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB; 
FullStructure_unblocked_FirstFollowing_Touch_RB_BIFR =  EpochWiseData.BIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB; 
[scores_unblTouchA_PreFollVSunblTouch_AFirstFoll_RB_su_BIFR, Full_unblTouchA_PreFollVSunblTouch_AFirstFoll_RB_su_BIFR] = rn_StructureDataforPermTest_subset_foll(FullStructure_unblocked_PreFirstFollowing_Touch_RB_BIFR,FullStructure_unblocked_FirstFollowing_Touch_RB_BIFR);

%COMPARISON BETWEEN TOUCH PREFOLLOWING_RB AND TOUCH FOLLOWING_RB
%OTHER'S/OWN VS OTHER'S/OTHER'S AIFR
FullStructure_unblocked_PreFirstFollowing_Touch_RB_AIFR = EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB; 
FullStructure_unblocked_FirstFollowing_Touch_RB_AIFR=  EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB; 
[scores_unblTouchA_PreFollVSunblTouch_AFirstFoll_RB_su_AIFR, Full_unbloTouchA_PreFollVSunbloTouch_AFirstFoll_RB_sub_AIFR] = rn_StructureDataforPermTest_subset_foll(FullStructure_unblocked_PreFirstFollowing_Touch_RB_AIFR,FullStructure_unblocked_FirstFollowing_Touch_RB_AIFR);



%COMPARISON BETWEEN Gaze PREFOLLOWING_BR AND FIRST FOLLOWING_BR: TARGET ONSET
[scores_unblockedGaze_PreFollVSunblockedGaze_FirstFoll_BR, Full_unblockedGaze_PreFollVSunblockedGaze_FirstFoll_BR] = rn_StructureDataforPermTest_foll(FullStructure_unblocked_PreFirstFollowing_Gaze_BR,FullStructure_unblocked_FirstFollowing_Gaze_BR);
rn_PlotAvgCombinedGazeunblockedPreVSGazeunblockedFirst_BR(Full_unblockedGaze_PreFollVSunblockedGaze_FirstFoll_BR, FullStructure_unblocked_FirstFollowing_Gaze_BR,FullStructure_unblocked_PreFirstFollowing_Gaze_BR, saving_dir);
%COMPARISON BETWEEN Gaze PREFOLLOWING_RB AND FIRST FOLLOWING_RB: TARGET ONSET
[scores_unblockedGaze_PreFollVSunblockedGaze_FirstFoll_RB, Full_unblockedGaze_PreFollVSunblockedGaze_FirstFoll_RB] = rn_StructureDataforPermTest_foll(FullStructure_unblocked_PreFirstFollowing_Gaze_RB,FullStructure_unblocked_FirstFollowing_Gaze_RB);
rn_PlotAvgCombinedGazeunblockedPreVSGazeunblockedFirst_RB(Full_unblockedGaze_PreFollVSunblockedGaze_FirstFoll_RB, FullStructure_unblocked_FirstFollowing_Gaze_RB,FullStructure_unblocked_PreFirstFollowing_Gaze_RB, saving_dir);
%COMPARISON BETWEEN Gaze PREFOLLOWING_RB AND TOUCH FOLLOWING_RB
%OTHER'S/OWN VS OTHER'S/OTHER'S: target onset 
[scores_unblockedGaze_PreFollVSunblockedGazeFirstFoll_RB_su, Full_unbloGaze_PreFollVSunbloGazeFirstFoll_RB_subset] = rn_StructureDataforPermTest_subset_foll(FullStructure_unblocked_PreFirstFollowing_Gaze_RB,FullStructure_unblocked_FirstFollowing_Gaze_RB);
rn_PlotAvgCombined_Gaze_PreVSFirst_unblocked(Full_unbloGaze_PreFollVSunbloGazeFirstFoll_RB_subset, FullStructure_unblocked_FirstFollowing_Gaze_RB,FullStructure_unblocked_PreFirstFollowing_Gaze_RB, saving_dir);

%COMPARISON BETWEEN Gaze PREFOLLOWING_RB AND TOUCH FOLLOWING_RB
%OTHER'S/OWN VS OTHER'S/OTHER'S BIFR
FullStructure_unblocked_PreFirstFollowing_Gaze_RB_BIFR = EpochWiseData.BIFR.Aligned_Rawdata.Gaze.Unblocked_PreFirstFollowing_RB; 
FullStructure_unblocked_FirstFollowing_Gaze_RB_BIFR =  EpochWiseData.BIFR.Aligned_Rawdata.Gaze.Unblocked_FirstFollowing_RB; 
[scores_unblGaze_PreFollVSunblGazeFirstFoll_RB_su_BIFR, Full_unblGaze_PreFollVSunblGazeFirstFoll_RB_su_BIFR] = rn_StructureDataforPermTest_subset_foll(FullStructure_unblocked_PreFirstFollowing_Gaze_RB_BIFR,FullStructure_unblocked_FirstFollowing_Gaze_RB_BIFR);

%COMPARISON BETWEEN Gaze PREFOLLOWING_RB AND TOUCH FOLLOWING_RB
%OTHER'S/OWN VS OTHER'S/OTHER'S AIFR
FullStructure_unblocked_PreFirstFollowing_Touch_RB_AIFR = EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_PreFirstFollowing_RB; 
FullStructure_unblocked_FirstFollowing_Touch_RB_AIFR=  EpochWiseData.AIFR.Aligned_Rawdata.Touch.Unblocked_FirstFollowing_RB; 
[scores_unblTouchA_PreFollVSunblTouch_AFirstFoll_RB_su_AIFR, Full_unbloTouchA_PreFollVSunbloTouch_AFirstFoll_RB_sub_AIFR] = rn_StructureDataforPermTest_subset_foll(FullStructure_unblocked_PreFirstFollowing_Touch_RB_AIFR,FullStructure_unblocked_FirstFollowing_Touch_RB_AIFR);



%COMPARISON BETWEEN Vergence PREFOLLOWING_BR AND FIRST FOLLOWING_BR: TARGET ONSET
[scores_unblockedVerg_PreFollVSunblockedVerg_FirstFoll_BR, Full_unblockedVerg_PreFollVSunblockedVerg_FirstFoll_BR] = rn_StructureDataforPermTest_foll(FullStructure_unblocked_PreFirstFollowing_Vergence_BR,FullStructure_unblocked_FirstFollowing_Vergence_BR);
rn_PlotAvgCombinedVergunblockedPreVSVergunblockedFirst_BR(Full_unblockedVerg_PreFollVSunblockedVerg_FirstFoll_BR, FullStructure_unblocked_PreFirstFollowing_Vergence_BR,FullStructure_unblocked_FirstFollowing_Vergence_BR, saving_dir);
%COMPARISON BETWEEN Vergence PREFOLLOWING_RB AND FIRST FOLLOWING_RB: TARGET ONSET
[scores_unblockedVerg_PreFollVSunblockedVerg_FirstFoll_RB, Full_unblockedVerg_PreFollVSunblockedVerg_FirstFoll_RB] = rn_StructureDataforPermTest_foll(FullStructure_unblocked_PreFirstFollowing_Vergence_RB,FullStructure_unblocked_FirstFollowing_Vergence_RB);
rn_PlotAvgCombinedVergunblockedPreVSVergunblockedFirst_RB(Full_unblockedVerg_PreFollVSunblockedVerg_FirstFoll_RB, FullStructure_unblocked_PreFirstFollowing_Vergence_RB,FullStructure_unblocked_FirstFollowing_Vergence_RB, saving_dir);

%COMPARISON BETWEEN TOUCH A UNBLOCKED AND TOUCH A BLOCKED: BIFR
[scores_unblockedTouchAVSblockedTouchA_BIFR, FullStructure_unblockedTouchAVSblockedTouchA_BIFR] = rn_StructureDataforPermTest(FullStructure_unblocked_BIFR_Touch,FullStructure_blocked_BIFR_Touch);
rn_PlotAvgCombinedTouchAunblockedVSTouchAblocked_BIFR(FullStructure_unblockedTouchAVSblockedTouchA_BIFR, FullStructure_unblocked_BIFR_Touch,FullStructure_blocked_BIFR_Touch, saving_dir);
%COMPARISON BETWEEN TOUCH A UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : BIFR
[scores_unblockedTouchAVSunblockedTouchA_BIFR, FullStructure_unblockedTouchAVSunblockedTouchA_BIFR] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked_BIFR_Touch);
rn_PlotAvgCombined_Touch_different_conditions_unblocked_BIFR(FullStructure_unblockedTouchAVSunblockedTouchA_BIFR,FullStructure_unblocked_BIFR_Touch,saving_dir);
%COMPARISON BETWEEN TOUCH A BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : BIFR 
[scores_blockedTouchAVSblockedTouchA_BIFR, FullStructure_blockedTouchAVSblockedTouchA_BIFR] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked_BIFR_Touch);
rn_PlotAvgCombined_Touch_different_conditions_blocked_BIFR (FullStructure_blockedTouchAVSblockedTouchA_BIFR, FullStructure_blocked_BIFR_Touch, saving_dir)


%COMPARISON BETWEEN TOUCH A UNBLOCKED AND TOUCH A BLOCKED: AIFR
[scores_unblockedTouchAVSblockedTouchA_AIFR, FullStructure_unblockedTouchAVSblockedTouchA_AIFR] = rn_StructureDataforPermTest(FullStructure_unblocked_AIFR_Touch,FullStructure_blocked_AIFR_Touch);
rn_PlotAvgCombinedTouchAunblockedVSTouchAblocked_AIFR(FullStructure_unblockedTouchAVSblockedTouchA_AIFR, FullStructure_unblocked_AIFR_Touch,FullStructure_blocked_AIFR_Touch, saving_dir);
%COMPARISON BETWEEN TOUCH A UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : AIFR
[scores_unblockedTouchAVSunblockedTouchA_AIFR, FullStructure_unblockedTouchAVSunblockedTouchA_AIFR] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked_AIFR_Touch);
rn_PlotAvgCombined_Touch_different_conditions_unblocked_AIFR(FullStructure_unblockedTouchAVSunblockedTouchA_AIFR,FullStructure_unblocked_AIFR_Touch,saving_dir);
%COMPARISON BETWEEN TOUCH A BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : AIFR
[scores_blockedTouchAVSblockedTouchA, FullStructure_blockedTouchAVSblockedTouchA_AIFR] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked_AIFR_Touch);
rn_PlotAvgCombined_Touch_different_conditions_blocked_AIFR (FullStructure_blockedTouchAVSblockedTouchA_AIFR, FullStructure_blocked_AIFR_Touch, saving_dir)

%COMPARISON BETWEEN GAZE UNBLOCKED AND GAZE BLOCKED: BIFR
[scores_unblockedGazeVSblockedGaze_BIFR, FullStructure_unblockedGazeVSblockedGaze_BIFR] = rn_StructureDataforPermTest(FullStructure_unblocked_BIFR_Gaze,FullStructure_blocked_BIFR_Gaze);
rn_PlotAvgCombinedGazeunblockedVSGazeblocked_BIFR(FullStructure_unblockedGazeVSblockedGaze_BIFR, FullStructure_unblocked_BIFR_Gaze,FullStructure_blocked_BIFR_Gaze, saving_dir);
%COMPARISON BETWEEN Gaze UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : BIFR
[scores_unblockedGazeVSunblockedGaze_BIFR, FullStructure_unblockedGazeVSunblockedGaze_BIFR] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked_BIFR_Gaze);
rn_PlotAvgCombined_Gaze_different_conditions_unblocked_BIFR(FullStructure_unblockedGazeVSunblockedGaze_BIFR,FullStructure_unblocked_BIFR_Gaze,saving_dir);
%COMPARISON BETWEEN Gaze BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : BIFR 
[scores_blockedGazeVSblockedGaze_BIFR, FullStructure_blockedGazeVSblockedGaze_BIFR] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked_BIFR_Gaze);
rn_PlotAvgCombined_Gaze_different_conditions_blocked_BIFR (FullStructure_blockedGazeVSblockedGaze_BIFR, FullStructure_blocked_BIFR_Gaze, saving_dir)

%COMPARISON BETWEEN GAZE UNBLOCKED AND GAZE BLOCKED: AIFR
[scores_unblockedGazeVSblockedGaze_AIFR, FullStructure_unblockedGazeVSblockedGaze_AIFR] = rn_StructureDataforPermTest(FullStructure_unblocked_AIFR_Gaze,FullStructure_blocked_AIFR_Gaze);
rn_PlotAvgCombinedGazeunblockedVSGazeblocked_AIFR(FullStructure_unblockedGazeVSblockedGaze_AIFR, FullStructure_unblocked_AIFR_Gaze,FullStructure_blocked_AIFR_Gaze, saving_dir);
%COMPARISON BETWEEN Gaze UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : AIFR
[scores_unblockedGazeVSunblockedGaze_AIFR, FullStructure_unblockedGazeVSunblockedGaze_AIFR] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked_AIFR_Gaze);
rn_PlotAvgCombined_Gaze_different_conditions_unblocked_AIFR(FullStructure_unblockedGazeVSunblockedGaze_AIFR,FullStructure_unblocked_AIFR_Gaze,saving_dir);
%COMPARISON BETWEEN Gaze BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : AIFR 
[scores_blockedGazeVSblockedGaze_AIFR, FullStructure_blockedGazeVSblockedGaze_AIFR] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked_AIFR_Gaze);
rn_PlotAvgCombined_Gaze_different_conditions_blocked_AIFR (FullStructure_blockedGazeVSblockedGaze_AIFR, FullStructure_blocked_AIFR_Gaze, saving_dir)



%COMPARISON BETWEEN VERGENCE UNBLOCKED AND GAZE BLOCKED: BIFR
[scores_unblockedVergenceVSblockedVergence_BIFR, FullStructure_unblockedVergVSblockedVerg_BIFR] = rn_StructureDataforPermTest(FullStructure_unblocked_BIFR_Vergence,FullStructure_blocked_BIFR_Vergence);
rn_PlotAvgCombinedVergenceunblockedVSVergenceblocked_BIFR(FullStructure_unblockedVergVSblockedVerg_BIFR, FullStructure_unblocked_BIFR_Vergence,FullStructure_blocked_BIFR_Vergence, saving_dir);
%COMPARISON BETWEEN Vergence UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : BIFR
[scores_unblockedGazeVSunblockedVergence_BIFR, FullStructure_unblockedVergVSunblockedVerg_BIFR] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked_BIFR_Vergence);
rn_PlotAvgCombined_Vergence_different_conditions_unblocked_BIFR(FullStructure_unblockedVergVSunblockedVerg_BIFR,FullStructure_unblocked_BIFR_Vergence,saving_dir);
%COMPARISON BETWEEN Vergence BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : BIFR 
[scores_blockedGazeVSblockedVergence_BIFR, FullStructure_blockedVergVSblockedVerg_BIFR] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked_BIFR_Vergence);
rn_PlotAvgCombined_Vergence_different_conditions_blocked_BIFR (FullStructure_blockedVergVSblockedVerg_BIFR, FullStructure_blocked_BIFR_Vergence, saving_dir)

%COMPARISON BETWEEN VERGENCE UNBLOCKED AND GAZE BLOCKED: AIFR
[scores_unblockedVergenceVSblockedVergence_AIFR, FullStructure_unblockedVergVSblockedVerg_AIFR] = rn_StructureDataforPermTest(FullStructure_unblocked_AIFR_Vergence,FullStructure_blocked_AIFR_Vergence);
rn_PlotAvgCombinedVergenceunblockedVSVergenceblocked_AIFR(FullStructure_unblockedVergVSblockedVerg_AIFR, FullStructure_unblocked_AIFR_Vergence,FullStructure_blocked_AIFR_Vergence, saving_dir);
%COMPARISON BETWEEN Vergence UNBLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : AIFR
[scores_unblockedGazeVSunblockedVergence_AIFR, FullStructure_unblockedVergVSunblockedVerg_AIFR] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked_AIFR_Vergence);
rn_PlotAvgCombined_Vergence_different_conditions_unblocked_AIFR(FullStructure_unblockedVergVSunblockedVerg_AIFR,FullStructure_unblocked_AIFR_Vergence,saving_dir);
%COMPARISON BETWEEN Vergence BLOCKED BETWEEN OWN/OWN AND OWN/OTHER +
%OTHER/OWN AND OTHER/OTHER : AIFR 
[scores_blockedGazeVSblockedVergence_AIFR, FullStructure_blockedVergVSblockedVerg_AIFR] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked_AIFR_Vergence);
rn_PlotAvgCombined_Vergence_different_conditions_blocked_AIFR (FullStructure_blockedVergVSblockedVerg_AIFR, FullStructure_blocked_AIFR_Vergence, saving_dir)


FullStructure_unblocked = EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked;
FullStructure_blocked = EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked;
[scores_AAunblockedVSAAblocked, FullStructure_AAunblockedVSAAblocked] = rn_StructureDataforPermTest_DIST(FullStructure_unblocked,FullStructure_blocked);
rn_PlotAvgCombinedAAunblockedVSAAblocked(FullStructure_AAunblockedVSAAblocked, FullStructure_unblocked,FullStructure_blocked, saving_dir);

[scores_ABunblockedVSABblocked, FullStructure_ABunblockedVSABblocked] = rn_StructureDataforPermTest_DIST_AB(FullStructure_unblocked,FullStructure_blocked);
rn_PlotAvgCombinedABunblockedVSABblocked(FullStructure_ABunblockedVSABblocked, FullStructure_unblocked,FullStructure_blocked, saving_dir);


FullStructure_unblocked_BIFR = EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked;
FullStructure_blocked_BIFR = EpochWiseData.BIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked;
[scores_AAunblVSAAblo_BIFR, FullStructure_AAunblVSAAblo_BIFR] = rn_StructureDataforPermTest_DIST(FullStructure_unblocked_BIFR,FullStructure_blocked_BIFR);
rn_PlotAvgCombinedAAunblockedVSAAblocked_BIFR(FullStructure_AAunblVSAAblo_BIFR, FullStructure_unblocked_BIFR,FullStructure_blocked_BIFR, saving_dir);

FullStructure_unblocked_AIFR = EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked;
FullStructure_blocked_AIFR = EpochWiseData.AIFR.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Blocked;
[scores_AAunblVSAAblo_AIFR, FullStructure_AAunblVSAAblo_AIFR] = rn_StructureDataforPermTest_DIST(FullStructure_unblocked_AIFR,FullStructure_blocked_AIFR);
rn_PlotAvgCombinedAAunblockedVSAAblocked_AIFR(FullStructure_AAunblVSAAblo_AIFR, FullStructure_unblocked_AIFR,FullStructure_blocked_AIFR, saving_dir);

[scores_ABunblVSABblo_BIFR, FullStructure_ABunblVSABblo_BIFR] = rn_StructureDataforPermTest_DIST(FullStructure_unblocked_BIFR,FullStructure_blocked_BIFR);
rn_PlotAvgCombinedABunblockedVSABblocked_BIFR(FullStructure_ABunblVSABblo_BIFR, FullStructure_unblocked_BIFR,FullStructure_blocked_BIFR, saving_dir);

[scores_ABunblVSABblo_AIFR, FullStructure_ABunblVSABblo_AIFR] = rn_StructureDataforPermTest_DIST(FullStructure_unblocked_AIFR,FullStructure_blocked_AIFR);
rn_PlotAvgCombinedABunblockedVSABblocked_AIFR(FullStructure_ABunblVSAAblo_AIFR, FullStructure_unblocked_AIFR,FullStructure_blocked_AIFR, saving_dir);


FullStructure_unblocked_FirstFollowing_Touch_RB_Dist = EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_RB;
FullStructure_unblocked_PreFirstFollowing_Touch_RB_Dist = EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_RB;
[scores_AAunblswitchVSAAunblocked, FullStructure_AAunblockedVSAAunblocked] = rn_StructureDataforPermTest_DIST_switch(FullStructure_unblocked,FullStructure_unblocked_PreFirstFollowing_Touch_RB_Dist,FullStructure_unblocked_FirstFollowing_Touch_RB_Dist);
rn_PlotAvgCombinedAAunblockedVSAAblocked_switch (FullStructure_AAunblockedVSAAunblocked, FullStructure_unblocked_PreFirstFollowing_Touch_RB_Dist,FullStructure_unblocked_FirstFollowing_Touch_RB_Dist,FullStructure_unblocked, saving_dir)

FullStructure_unblocked_FirstFollowing_Touch_BR_Dist = EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_FirstFollowing_BR;
FullStructure_unblocked_PreFirstFollowing_Touch_BR_Dist = EpochWiseData.TargetOnset.Aligned_Interpolated_Data.DistancebwGazeTouch.Combined.Unblocked_PreFirstFollowing_BR;
[scores_AAunblswitchVSAAunblocked_BR, FullStructure_AAunblockedVSAAunblocked_BR] = rn_StructureDataforPermTest_DIST_switch_BR(FullStructure_unblocked,FullStructure_unblocked_PreFirstFollowing_Touch_BR_Dist,FullStructure_unblocked_FirstFollowing_Touch_BR_Dist);
rn_PlotAvgCombinedAAunblockedVSAAblocked_switch_BR (FullStructure_AAunblockedVSAAunblocked_BR, FullStructure_unblocked_PreFirstFollowing_Touch_BR_Dist,FullStructure_unblocked_FirstFollowing_Touch_BR_Dist,FullStructure_unblocked, saving_dir)


rn_reaction_times ()

return
end
