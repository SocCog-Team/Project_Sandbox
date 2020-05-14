%%Just subtract the gaze position from which target the player A selects 
function [EpochWiseData]=tn_DistGazeTarget(EpochWiseData)
[DistGazeATargetLesser]= tn_GazeTargetSegregateBIFRpSeeLesserThanChance(EpochWiseData.BIFR.Aligned_Interpolated_Data.Gaze.A.xCoordinates, EpochWiseData.TrialSets)
[DistGazeATargetHigher]= tn_GazeTargetSegregateBIFRpSeeHigherThanChance(EpochWiseData.BIFR.Aligned_Interpolated_Data.Gaze.A.xCoordinates, EpochWiseData.TrialSets)
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistGazeTarget.pSeeGreaterthan50=DistGazeATargetHigher;
EpochWiseData.BIFR.Aligned_Interpolated_Data.DistGazeTarget.pSeeLesserthan50=DistGazeATargetLesser;
end