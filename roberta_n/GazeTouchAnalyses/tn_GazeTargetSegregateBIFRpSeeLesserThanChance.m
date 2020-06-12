%%Just segregates data based on where the target selected by A was. (for
%%low action visibility condition)
function [DistGazeATarget]= tn_GazeTargetSegregateBIFRpSeeLesserThanChance(GazeA, ModifiedTrialSets)
%%Here epochdataGazeA= Refers to timepoints and sqhould be epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints
pSeeLesserThanChanceNames=fieldnames(ModifiedTrialSets.pSee.LesserThanChanceA);
   
% ByStimulusPosition_leftrightChoicecategoriesNamesSp=ByChoicePositionColourRewardNames(counter+4);
% ByStimulusPosition_leftrightChoicecategoriesNamesSpStr=ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.(ByStimulusPosition_leftrightChoicecategoriesNamesSp{1});
a=0;

% TrialNumStr='No. of Trials= ';

for counter= 1:length(pSeeLesserThanChanceNames)
    pSeeLesserThanChanceSp=pSeeLesserThanChanceNames(counter);
    pSeeLesserThanChanceSpStr=ModifiedTrialSets.pSee.LesserThanChanceA.(pSeeLesserThanChanceSp{1});
    
    TrialLists=pSeeLesserThanChanceSpStr;
%     numb=length(TrialLists);
%     for RemoveLastTrial= 1: numb
%         
%     timepointsLists=linspace(-0.5, ,length(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)));
%     timeBins=histogram(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:));
%     timeBins.BinEdges=timepointsLists;
%     for i= 1: length(timepointsLists)-1
%         abc(:,i)=find(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)> timepointsLists(i) & epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)<= timepointsLists(i+1)
%     end
    
    
    
    if counter==1 
        DistGazeATarget.Type2401=GazeA(TrialLists,:)-1182;
%         DistGazeATarget.Type2401=GazeA(TrialLists,:)-1182;
%         DistGazeATouchB.Type2401=distGazeATouchB(TrialLists,:);
%         TimepointsTrialWise.Type2401=epochdataGazeATimepoints(TrialLists,:);
%         BIFRAlignedAIFRAVG.Type2401=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==5|| counter== 9
     DistGazeATarget.Type2401=vertcat(DistGazeATarget.Type2401,GazeA(TrialLists,:)-1182);    
%     DistGazeATarget.Type2401=vertcat(DistGazeATarget.Type2401,GazeA(TrialLists,:)-1182);
%     DistGazeATouchB.Type2401=vertcat(DistGazeATouchB.Type2401,distGazeATouchB(TrialLists,:));
%     TimepointsTrialWise.Type2401=vertcat(TimepointsTrialWise.Type2401,epochdataGazeATimepoints(TrialLists,:));
%     BIFRAlignedAIFRAVG.Type2401=vertcat(BIFRAlignedAIFRAVG.Type2401,AIFRrelativetoBIFR(TrialLists,:));
    end
    if counter==2 
        DistGazeATarget.Type2402=GazeA(TrialLists,:)-1182;
%         DistGazeATouchB.Type2402=distGazeATouchB(TrialLists,:);
%         TimepointsTrialWise.Type2402=epochdataGazeATimepoints(TrialLists,:);
%         BIFRAlignedAIFRAVG.Type2402=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==6|| counter== 10
    DistGazeATarget.Type2402=vertcat(DistGazeATarget.Type2402,GazeA(TrialLists,:)-1182);
%     DistGazeATouchB.Type2402=vertcat(DistGazeATouchB.Type2402,distGazeATouchB(TrialLists,:));
%     TimepointsTrialWise.Type2402=vertcat(TimepointsTrialWise.Type2402,epochdataGazeATimepoints(TrialLists,:));
%     BIFRAlignedAIFRAVG.Type2402=vertcat(BIFRAlignedAIFRAVG.Type2402,AIFRrelativetoBIFR(TrialLists,:));
    end
    if counter==3 
        DistGazeATarget.Type2403=GazeA(TrialLists,:)-738;
%         DistGazeATouchB.Type2403=distGazeATouchB(TrialLists,:);
%         TimepointsTrialWise.Type2403=epochdataGazeATimepoints(TrialLists,:);
%         BIFRAlignedAIFRAVG.Type2403=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==7|| counter== 11
    DistGazeATarget.Type2403=vertcat(DistGazeATarget.Type2403,GazeA(TrialLists,:)-738);
%     DistGazeATouchB.Type2403=vertcat(DistGazeATouchB.Type2403,distGazeATouchB(TrialLists,:));
%     TimepointsTrialWise.Type2403=vertcat(TimepointsTrialWise.Type2403,epochdataGazeATimepoints(TrialLists,:));
%     BIFRAlignedAIFRAVG.Type2403=vertcat(BIFRAlignedAIFRAVG.Type2403,AIFRrelativetoBIFR(TrialLists,:));
    end
    
    if counter==4 
        DistGazeATarget.Type2404=GazeA(TrialLists,:)-738;
%         DistGazeATouchB.Type2404=distGazeATouchB(TrialLists,:);
%         TimepointsTrialWise.Type2404=epochdataGazeATimepoints(TrialLists,:);
%         BIFRAlignedAIFRAVG.Type2404=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==8|| counter== 12
    DistGazeATarget.Type2404=vertcat(DistGazeATarget.Type2404,GazeA(TrialLists,:)-738);
%     DistGazeATouchB.Type2404=vertcat(DistGazeATouchB.Type2404,distGazeATouchB(TrialLists,:));
%     TimepointsTrialWise.Type2404=vertcat(TimepointsTrialWise.Type2404,epochdataGazeATimepoints(TrialLists,:));
%     BIFRAlignedAIFRAVG.Type2404=vertcat(BIFRAlignedAIFRAVG.Type2404,AIFRrelativetoBIFR(TrialLists,:));
    end
    
    if counter==13 
        DistGazeATarget.Type2405=GazeA(TrialLists,:)-738;
%         DistGazeATouchB.Type2405=distGazeATouchB(TrialLists,:);
%         TimepointsTrialWise.Type2405=epochdataGazeATimepoints(TrialLists,:);
%         BIFRAlignedAIFRAVG.Type2405=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==17|| counter== 21
    DistGazeATarget.Type2405=vertcat(DistGazeATarget.Type2405,GazeA(TrialLists,:)-738);
%     DistGazeATouchB.Type2405=vertcat(DistGazeATouchB.Type2405,distGazeATouchB(TrialLists,:));
%     TimepointsTrialWise.Type2405=vertcat(TimepointsTrialWise.Type2405,epochdataGazeATimepoints(TrialLists,:));
%     BIFRAlignedAIFRAVG.Type2405=vertcat(BIFRAlignedAIFRAVG.Type2405,AIFRrelativetoBIFR(TrialLists,:));
    end
    if counter==14
        DistGazeATarget.Type2406=GazeA(TrialLists,:)-738;
%         DistGazeATouchB.Type2406=distGazeATouchB(TrialLists,:);
%         TimepointsTrialWise.Type2406=epochdataGazeATimepoints(TrialLists,:);
%         BIFRAlignedAIFRAVG.Type2406=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==18|| counter== 22
    DistGazeATarget.Type2406=vertcat(DistGazeATarget.Type2406,GazeA(TrialLists,:)-738);
%     DistGazeATouchB.Type2406=vertcat(DistGazeATouchB.Type2406,distGazeATouchB(TrialLists,:));
%     TimepointsTrialWise.Type2406=vertcat(TimepointsTrialWise.Type2406,epochdataGazeATimepoints(TrialLists,:));
%     BIFRAlignedAIFRAVG.Type2406=vertcat(BIFRAlignedAIFRAVG.Type2406,AIFRrelativetoBIFR(TrialLists,:));
    end
    if counter==15 
        DistGazeATarget.Type2407=GazeA(TrialLists,:)-1182;
%         DistGazeATouchB.Type2407=distGazeATouchB(TrialLists,:);
%         TimepointsTrialWise.Type2407=epochdataGazeATimepoints(TrialLists,:);
%         BIFRAlignedAIFRAVG.Type2407=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==19|| counter== 23
    DistGazeATarget.Type2407=vertcat(DistGazeATarget.Type2407,GazeA(TrialLists,:)-1182);
%     DistGazeATouchB.Type2407=vertcat(DistGazeATouchB.Type2407,distGazeATouchB(TrialLists,:));
%     TimepointsTrialWise.Type2407=vertcat(TimepointsTrialWise.Type2407,epochdataGazeATimepoints(TrialLists,:));
%     BIFRAlignedAIFRAVG.Type2407=vertcat(BIFRAlignedAIFRAVG.Type2407,AIFRrelativetoBIFR(TrialLists,:));
    end
    
    if counter==16 
         if isempty(TrialLists)
                DistGazeATarget.Type2408(1,1:(size(DistGazeATarget.Type2407,2)))=NaN;
%                 DistGazeATouchB.Type2408(1,1:(size(DistGazeATouchB.Type2407,2)))=NaN;
%                 TimepointsTrialWise.Type2408(1,1:(size(DistGazeATouchB.Type2407,2)))=NaN;
%                 BIFRAlignedAIFRAVG.Type2408(1,1:(size(BIFRAlignedAIFRAVG.Type2407,2)))=NaN;
        else 
        DistGazeATarget.Type2408=GazeA(TrialLists,:)-1182;
%         DistGazeATouchB.Type2408=distGazeATouchB(TrialLists,:);
%         TimepointsTrialWise.Type2408=epochdataGazeATimepoints(TrialLists,:);
%         BIFRAlignedAIFRAVG.Type2408=AIFRrelativetoBIFR(TrialLists,:);
        end
    end
    if counter==20|| counter== 24
    DistGazeATarget.Type2408=vertcat(DistGazeATarget.Type2408,GazeA(TrialLists,:)-1182);
%     DistGazeATouchB.Type2408=vertcat(DistGazeATouchB.Type2408,distGazeATouchB(TrialLists,:));
%     TimepointsTrialWise.Type2408=vertcat(TimepointsTrialWise.Type2408, epochdataGazeATimepoints(TrialLists,:));
%     BIFRAlignedAIFRAVG.Type2408=vertcat(BIFRAlignedAIFRAVG.Type2408,AIFRrelativetoBIFR(TrialLists,:));
    end
    
%     if counter==1 || counter==5 || counter==9 || counter==13 || counter==17 || counter== 21
%         figure()
%         set( gcf, 'PaperUnits','centimeters' );
%         xSize = 24; ySize = 24;
%         xLeft = 0; yTop = 0;
%         set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );  
%     end
%    
%     a=a+1;
%     if a>4
%         a=1;
%     end
%     if isempty(TrialLists)
%        continue; 
%     end
%     LengthTrialLists=length(TrialLists);
%     for i= 1:LengthTrialLists
%         if TrialLists(i) >=1 && TrialLists(i)<=10
%             TrialLists(i)=NaN;
%         end
%     end
%     
%     TrialLists1 = TrialLists(~isnan(TrialLists));
%     TrialLists= TrialLists1;
%     if ~isempty(TrialLists)
%         AVGAIFR=mean(AIFRrelativetoBIFR(TrialLists,1));
%     else
%         AVGAIFR=NaN;
%     end
%     subplot(2,2,a);
%     
%     xlim([-0.2 0.9])
%     ylim([-500 500])
%     
% 
%     xlim([-0.6 0.9])
%     ylim([-500 500])
end
end
% 
% a=0;
% 
% 
% % end
% for counter= 1:8
%    if counter== 1 ||  counter== 2 || counter== 7 || counter== 8
%    EpochWiseData.BIFR.Aligned_Interpolated_Data.Gaze.A.xCoordinates-1182;
%    else
%    EpochWiseData.BIFR.Aligned_Interpolated_Data.Gaze.A.xCoordinates-1182;    