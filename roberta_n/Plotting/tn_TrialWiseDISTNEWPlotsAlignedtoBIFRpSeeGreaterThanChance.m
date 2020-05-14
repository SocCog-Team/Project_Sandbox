%%Only for plotting DistA-A and DistA-B and segregating data
%%1-8 is 8 conditions : 4 value based and 2 side based conditions. ; 
%%[Own/Own; OwnOther; Other/Own; Other/Other]X [Red on objective right]
%%[Own/Own; OwnOther; Other/Own; Other/Other]X [Red on objective left]
function [DistGazeATouchA, DistGazeATouchB, TimepointsTrialWise, BIFRAlignedAIFRAVG]= tn_TrialWiseDISTNEWPlotsAlignedtoBIFRpSeeGreaterThanChance(distGazeATouchA, distGazeATouchB,epochdataGazeATimepoints, ModifiedTrialSets, saving_dir, fileID,AIFRrelativetoBIFR)
%%Here epochdataGazeA= Refers to timepoints and sqhould be epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints
close all

pSeeGreaterThanChanceNames=fieldnames(ModifiedTrialSets.pSee.GreaterThanChanceA);
   
% ByStimulusPosition_leftrightChoicecategoriesNamesSp=ByChoicePositionColourRewardNames(counter+4);
% ByStimulusPosition_leftrightChoicecategoriesNamesSpStr=ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.(ByStimulusPosition_leftrightChoicecategoriesNamesSp{1});
a=0;
%
TrialNumStr='No. of Trials= ';

for counter= 1:length(pSeeGreaterThanChanceNames)
    pSeeGreaterThanChanceSp=pSeeGreaterThanChanceNames(counter);
    pSeeGreaterThanChanceSpStr=ModifiedTrialSets.pSee.GreaterThanChanceA.(pSeeGreaterThanChanceSp{1});
    
    TrialLists=pSeeGreaterThanChanceSpStr;

    
    LengthTrialLists=length(TrialLists);
    for i= 1:LengthTrialLists
        if TrialLists(i) >=1 && TrialLists(i)<=10
            TrialLists(i)=NaN;
        end
    end
    
    TrialLists1 = TrialLists(~isnan(TrialLists));
    TrialLists= TrialLists1;
    if ~isempty(TrialLists)
        AVGAIFR=mean(AIFRrelativetoBIFR(TrialLists,1));
    else
        AVGAIFR=NaN;
    end
    
    if counter==1 
        DistGazeATouchA.Type2401=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2401=distGazeATouchB(TrialLists,:);
        TimepointsTrialWise.Type2401=epochdataGazeATimepoints(TrialLists,:);
        BIFRAlignedAIFRAVG.Type2401=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==5|| counter== 9
    DistGazeATouchA.Type2401=vertcat(DistGazeATouchA.Type2401,distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2401=vertcat(DistGazeATouchB.Type2401,distGazeATouchB(TrialLists,:));
    TimepointsTrialWise.Type2401=vertcat(TimepointsTrialWise.Type2401,epochdataGazeATimepoints(TrialLists,:));
    BIFRAlignedAIFRAVG.Type2401=vertcat(BIFRAlignedAIFRAVG.Type2401,AIFRrelativetoBIFR(TrialLists,:));
    end
    if counter==2 
        DistGazeATouchA.Type2402=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2402=distGazeATouchB(TrialLists,:);
        TimepointsTrialWise.Type2402=epochdataGazeATimepoints(TrialLists,:);
        BIFRAlignedAIFRAVG.Type2402=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==6|| counter== 10
    DistGazeATouchA.Type2402=vertcat(DistGazeATouchA.Type2402,distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2402=vertcat(DistGazeATouchB.Type2402,distGazeATouchB(TrialLists,:));
    TimepointsTrialWise.Type2402=vertcat(TimepointsTrialWise.Type2402,epochdataGazeATimepoints(TrialLists,:));
    BIFRAlignedAIFRAVG.Type2402=vertcat(BIFRAlignedAIFRAVG.Type2402,AIFRrelativetoBIFR(TrialLists,:));
    end
    if counter==3 
        DistGazeATouchA.Type2403=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2403=distGazeATouchB(TrialLists,:);
        TimepointsTrialWise.Type2403=epochdataGazeATimepoints(TrialLists,:);
        BIFRAlignedAIFRAVG.Type2403=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==7|| counter== 11
    DistGazeATouchA.Type2403=vertcat(DistGazeATouchA.Type2403,distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2403=vertcat(DistGazeATouchB.Type2403,distGazeATouchB(TrialLists,:));
    TimepointsTrialWise.Type2403=vertcat(TimepointsTrialWise.Type2403,epochdataGazeATimepoints(TrialLists,:));
    BIFRAlignedAIFRAVG.Type2403=vertcat(BIFRAlignedAIFRAVG.Type2403,AIFRrelativetoBIFR(TrialLists,:));
    end
    
    if counter==4 
        DistGazeATouchA.Type2404=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2404=distGazeATouchB(TrialLists,:);
        TimepointsTrialWise.Type2404=epochdataGazeATimepoints(TrialLists,:);
        BIFRAlignedAIFRAVG.Type2404=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==8|| counter== 12
    DistGazeATouchA.Type2404=vertcat(DistGazeATouchA.Type2404,distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2404=vertcat(DistGazeATouchB.Type2404,distGazeATouchB(TrialLists,:));
    TimepointsTrialWise.Type2404=vertcat(TimepointsTrialWise.Type2404,epochdataGazeATimepoints(TrialLists,:));
    BIFRAlignedAIFRAVG.Type2404=vertcat(BIFRAlignedAIFRAVG.Type2404,AIFRrelativetoBIFR(TrialLists,:));
    end
    
    if counter==13 
        DistGazeATouchA.Type2405=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2405=distGazeATouchB(TrialLists,:);
        TimepointsTrialWise.Type2405=epochdataGazeATimepoints(TrialLists,:);
        BIFRAlignedAIFRAVG.Type2405=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==17|| counter== 21
    DistGazeATouchA.Type2405=vertcat(DistGazeATouchA.Type2405,distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2405=vertcat(DistGazeATouchB.Type2405,distGazeATouchB(TrialLists,:));
    TimepointsTrialWise.Type2405=vertcat(TimepointsTrialWise.Type2405,epochdataGazeATimepoints(TrialLists,:));
    BIFRAlignedAIFRAVG.Type2405=vertcat(BIFRAlignedAIFRAVG.Type2405,AIFRrelativetoBIFR(TrialLists,:));
    end
    if counter==14
        DistGazeATouchA.Type2406=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2406=distGazeATouchB(TrialLists,:);
        TimepointsTrialWise.Type2406=epochdataGazeATimepoints(TrialLists,:);
        BIFRAlignedAIFRAVG.Type2406=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==18|| counter== 22
    DistGazeATouchA.Type2406=vertcat(DistGazeATouchA.Type2406,distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2406=vertcat(DistGazeATouchB.Type2406,distGazeATouchB(TrialLists,:));
    TimepointsTrialWise.Type2406=vertcat(TimepointsTrialWise.Type2406,epochdataGazeATimepoints(TrialLists,:));
    BIFRAlignedAIFRAVG.Type2406=vertcat(BIFRAlignedAIFRAVG.Type2406,AIFRrelativetoBIFR(TrialLists,:));
    end
    if counter==15 
        DistGazeATouchA.Type2407=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2407=distGazeATouchB(TrialLists,:);
        TimepointsTrialWise.Type2407=epochdataGazeATimepoints(TrialLists,:);
        BIFRAlignedAIFRAVG.Type2407=AIFRrelativetoBIFR(TrialLists,:);
    end
    if counter==19|| counter== 23
    DistGazeATouchA.Type2407=vertcat(DistGazeATouchA.Type2407,distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2407=vertcat(DistGazeATouchB.Type2407,distGazeATouchB(TrialLists,:));
    TimepointsTrialWise.Type2407=vertcat(TimepointsTrialWise.Type2407,epochdataGazeATimepoints(TrialLists,:));
    BIFRAlignedAIFRAVG.Type2407=vertcat(BIFRAlignedAIFRAVG.Type2407,AIFRrelativetoBIFR(TrialLists,:));
    end
    
    if counter==16 
         if isempty(TrialLists)
                DistGazeATouchA.Type2408(1,1:(size(DistGazeATouchA.Type2407,2)))=NaN;
                DistGazeATouchB.Type2408(1,1:(size(DistGazeATouchB.Type2407,2)))=NaN;
                TimepointsTrialWise.Type2408(1,1:(size(DistGazeATouchB.Type2407,2)))=NaN;
                BIFRAlignedAIFRAVG.Type2408(1,1:(size(BIFRAlignedAIFRAVG.Type2407,2)))=NaN;
         else 
            DistGazeATouchA.Type2408=distGazeATouchA(TrialLists,:);
            DistGazeATouchB.Type2408=distGazeATouchB(TrialLists,:);
            TimepointsTrialWise.Type2408=epochdataGazeATimepoints(TrialLists,:);
            BIFRAlignedAIFRAVG.Type2408=AIFRrelativetoBIFR(TrialLists,:);
         end
    end
    if counter==20|| counter== 24
    DistGazeATouchA.Type2408=vertcat(DistGazeATouchA.Type2408,distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2408=vertcat(DistGazeATouchB.Type2408,distGazeATouchB(TrialLists,:));
    TimepointsTrialWise.Type2408=vertcat(TimepointsTrialWise.Type2408, epochdataGazeATimepoints(TrialLists,:));
    BIFRAlignedAIFRAVG.Type2408=vertcat(BIFRAlignedAIFRAVG.Type2408,AIFRrelativetoBIFR(TrialLists,:));
    end
    
    
     if counter==1 || counter==5 || counter==9 || counter==13 || counter==17 || counter== 21
        figure()
        set( gcf, 'PaperUnits','centimeters' );
        xSize = 24; ySize = 24;
        xLeft = 0; yTop = 0;
        set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );  
    end
   
    a=a+1;
    if a>4
        a=1;
    end
    if isempty(TrialLists)
       continue; 
    end
    
    subplot(2,2,a);
    if counter>=1 && counter<=12
        annotation('textbox',[.9 .8 .1 .2],'String','Red on Objective Right','EdgeColor','none')
    end
    if counter>=13 && counter<=24
        annotation('textbox',[.9 .8 .1 .2],'String','Red on Objective Left','EdgeColor','none')
    end
    annotation('textbox',[.9 .7 .1 .2],'String','pSee higher than chance','EdgeColor','none')
    str=strcat(TrialNumStr, num2str(size((TrialLists),1)));
    text(0.65,380,str);
    if a==1
        strCond='A-Own/B-Own';
        text(0.65,420,strCond);
    end
    if a==2
        strCond='A-Own/B-Other';
        text(0.65,420,strCond);
    end
    if a==3
        strCond='A-Other/B-Own';
        text(0.65,420,strCond);
    end
    if a==4
        strCond='A-Other/B-Other';
        text(0.65,420,strCond);
    end
    
    ylim([-500 500])
    xlim([-0.2 0.9])
    yL = get(gca,'YLim');   
    line([0 0],yL,'Color','b');
    xL = get(gca,'XLim');    
    hold on
    line([AVGAIFR AVGAIFR],yL,'Color','r', 'LineStyle','--');
    hold on
    line(xL,[0 0],'Color','k');
    hold on
    AbsDistGazeATouchAOverlay=plot(epochdataGazeATimepoints(TrialLists,:),distGazeATouchA(TrialLists,:),'.','Color','r');
    hold on
    AbsDistGazeATouchBOverlay=plot(epochdataGazeATimepoints(TrialLists,:),distGazeATouchB(TrialLists,:),'.','Color','b');
    hold on 

    if a==1
        ylabel('A selected Own Colour \newline  Difference between Gaze and Touch','FontSize',15)
                
    end
    if a==3
        xlabel('Time(secs) \newline B selected Own Colour','FontSize',15)      
        ylabel('A selected Other"s Colour \newline  Difference between Gaze and Touch','FontSize',15)
    end
    if a==4
        xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',15)
    end
    
    
    
    
    
    
    
    if counter>=1 && counter<=4 
        saveas(gcf, fullfile(saving_dir,[fileID, '_XHighThanChancepSeeDiffbwGazeTouchTimeRed_ObjectiveRightTopAlignedtoBIFR.jpg']))
        
    end
    if counter>=5 && counter<=8 
        saveas(gcf, fullfile(saving_dir,[fileID, '_XHighThanChancepSeeDiffbwGazeTouchTimeRed_ObjectiveRightCenterAlignedtoBIFR.jpg']))
        
    end
    if counter>=9 && counter<=12  
        saveas(gcf, fullfile(saving_dir,[fileID, '_XHighThanChancepSeeDiffbwGazeTouchTimeRed_ObjectiveRightBottomAlignedtoBIFR.jpg']))
        
    end
    if counter>=13 && counter<=16 
        saveas(gcf, fullfile(saving_dir,[fileID, '_XHighThanChancepSeeDiffbwGazeTouchTimeRed_ObjectiveLeftTopAlignedtoBIFR.jpg']))
        
    end
    if counter>=17 && counter<=20  
        saveas(gcf, fullfile(saving_dir,[fileID, '_XHighThanChancepSeeDiffbwGazeTouchTimeRed_ObjectiveLeftCenterAlignedtoBIFR.jpg']))
        
    end
    if counter>=21 && counter<=24 
        saveas(gcf, fullfile(saving_dir,[fileID, '_XHighThanChancepSeeDiffbwGazeTouchTimeRed_ObjectiveLeftBottomAlignedtoBIFR.jpg']))
    end
end

a=0;

end