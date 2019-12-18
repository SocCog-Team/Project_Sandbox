%%Only for plotting DistA-A and DistA-B and segregating data
function [DistGazeATouchA, DistGazeATouchB]= tn_TrialWiseDISTNEWPlotsAlignedtoAIFR(distGazeATouchA, distGazeATouchB,InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right, ModifiedTrialSets, saving_dir, fileID)
close all
Byrewardttype_pos_blocked_Names=fieldnames(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials);
   
% ByStimulusPosition_leftrightChoicecategoriesNamesSp=ByChoicePositionColourRewardNames(counter+4);
% ByStimulusPosition_leftrightChoicecategoriesNamesSpStr=ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.(ByStimulusPosition_leftrightChoicecategoriesNamesSp{1});
a=0;
TrialNumStr='No. of Trials= ';


for counter= 1:24
    Byrewardttype_posSp=Byrewardttype_pos_blocked_Names(counter);
    Byrewardttype_posSpStr=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.(Byrewardttype_posSp{1});
    
    TrialLists=Byrewardttype_posSpStr;

   
    LengthTrialLists=length(TrialLists);
    for i= 1:LengthTrialLists
        if TrialLists(i) >=1 && TrialLists(i)<=10
            TrialLists(i)=NaN;
        end
    end
    
    TrialLists1 = TrialLists(~isnan(TrialLists));
    TrialLists= TrialLists1;

    if counter==1 
        DistGazeATouchA.Type2401=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2401=distGazeATouchB(TrialLists,:);
    end
    if counter==5|| counter== 9
    DistGazeATouchA.Type2401=vertcat(distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2401=vertcat(distGazeATouchB(TrialLists,:));
    end
    if counter==2 
        DistGazeATouchA.Type2402=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2402=distGazeATouchB(TrialLists,:);
    end
    if counter==6|| counter== 10
    DistGazeATouchA.Type2402=vertcat(distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2402=vertcat(distGazeATouchB(TrialLists,:));
    end
    if counter==3 
        DistGazeATouchA.Type2403=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2403=distGazeATouchB(TrialLists,:);
    end
    if counter==7|| counter== 11
    DistGazeATouchA.Type2403=vertcat(distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2403=vertcat(distGazeATouchB(TrialLists,:));
    end
    
    if counter==4 
        DistGazeATouchA.Type2404=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2404=distGazeATouchB(TrialLists,:);
    end
    if counter==8|| counter== 12
    DistGazeATouchA.Type2404=vertcat(distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2404=vertcat(distGazeATouchB(TrialLists,:));
    end
    
    if counter==13 
        DistGazeATouchA.Type2405=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2405=distGazeATouchB(TrialLists,:);
    end
    if counter==17|| counter== 21
    DistGazeATouchA.Type2405=vertcat(distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2405=vertcat(distGazeATouchB(TrialLists,:));
    end
    if counter==14
        DistGazeATouchA.Type2406=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2406=distGazeATouchB(TrialLists,:);
    end
    if counter==18|| counter== 22
    DistGazeATouchA.Type2406=vertcat(distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2406=vertcat(distGazeATouchB(TrialLists,:));
    end
    if counter==15 
        DistGazeATouchA.Type2407=distGazeATouchA(TrialLists,:);
        DistGazeATouchB.Type2407=distGazeATouchB(TrialLists,:);
    end
    if counter==19|| counter== 23
    DistGazeATouchA.Type2407=vertcat(distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2407=vertcat(distGazeATouchB(TrialLists,:));
    end
    
    if counter==16 
        
        if isempty(TrialLists)
                DistGazeATouchA.Type2408(1,1:(size(DistGazeATouchA.Type2407,2)))=NaN;
                DistGazeATouchB.Type2408(1,1:(size(DistGazeATouchB.Type2407,2)))=NaN;
        else    
               
            DistGazeATouchA.Type2408=distGazeATouchA(TrialLists,:);
            DistGazeATouchB.Type2408=distGazeATouchB(TrialLists,:);
        end    
        
    end
    if counter==20|| counter== 24
    DistGazeATouchA.Type2408=vertcat(distGazeATouchA(TrialLists,:));
    DistGazeATouchB.Type2408=vertcat(distGazeATouchB(TrialLists,:));
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
    if counter>=1 && counter<=12
        annotation('textbox',[.9 .8 .1 .2],'String','Red on Objective Right','EdgeColor','none')
    end
    if counter>=13 && counter<=24
        annotation('textbox',[.9 .8 .1 .2],'String','Red on Objective Left','EdgeColor','none')
    end

    
    subplot(2,2,a);
    ylim([0 600]);
    yL = get(gca,'YLim');    
    
    line([0 0],yL,'Color','r');
    hold on
%     line([AVGAIFR AVGAIFR],yL,'Color','r','LineStyle','--');
    xL = get(gca,'XLim');    
    hold on
    line(xL,[0 0],'Color','k');
    
    
    str=strcat(TrialNumStr, num2str(size((TrialLists),1)));
    text(0.25,420,str);
    if a==1
        strCond='A-Own/B-Own';
        text(0.25,450,strCond);
    end
    if a==2
        strCond='A-Own/B-Other';
        text(0.25,450,strCond);
    end
    if a==3
        strCond='A-Other/B-Own';
        text(0.25,450,strCond);
    end
    if a==4
        strCond='A-Other/B-Other';
        text(0.25,450,strCond);
    end
    
    
    DistGazeATouchAOverlay=plot(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right.timepoints(TrialLists,:),distGazeATouchA(TrialLists,:),'.','Color','r');
    hold on
    DistGazeATouchBOverlay=plot(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right.timepoints(TrialLists,:),distGazeATouchB(TrialLists,:),'.','Color','b');
    hold on
	
	DistGazeATouchAOverlay=plot(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right.timepoints(TrialLists,:),mean(distGazeATouchA(TrialLists,:)),'*','Color','r');
	hold on
	DistGazeATouchBOverlay=plot(InterpepochdataRegGazeA_Initial_Fixation_Release_A_poly_right.timepoints(TrialLists,:),mean(distGazeATouchB(TrialLists,:)),'*','Color','b');
	hold on

    xlim([-0.5 1])
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
        write_out_figure(gcf, fullfile(saving_dir, '_EuclDiffbwGazeTouchTime_Red_ObjectiveRightTopAlignedtoAIFR.pdf'))
        
    end
    if counter>=5 && counter<=8 
        write_out_figure(gcf, fullfile(saving_dir, '_EuclDiffbwGazeTouchTime_Red_ObjectiveRightCenterAlignedtoAIFR.pdf'))
        
    end
    if counter>=9 && counter<=12  
        write_out_figure(gcf, fullfile(saving_dir, '_EuclDiffbwGazeTouchTime_Red_ObjectiveRightBottomAlignedtoAIFR.pdf'))
        
    end
    if counter>=13 && counter<=16 
        write_out_figure(gcf, fullfile(saving_dir, '_EuclDiffbwGazeTouchTime_Red_ObjectiveLeftTopAlignedtoAIFR.pdf'))
        
    end
    if counter>=17 && counter<=20  
        write_out_figure(gcf, fullfile(saving_dir, '_EuclDiffbwGazeTouchTime_Red_ObjectiveLeftCenterAlignedtoAIFR.pdf'))
        
    end
    if counter>=21 && counter<=24 
        write_out_figure(gcf, fullfile(saving_dir, '_EuclDiffbwGazeTouchTime_Red_ObjectiveLeftBottomAlignedtoAIFR.pdf'))
    end
end

a=0;


end