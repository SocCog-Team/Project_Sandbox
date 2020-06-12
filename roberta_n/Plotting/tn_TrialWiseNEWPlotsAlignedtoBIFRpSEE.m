%%This is just for plotting ; 1-24 is The 4 value based conditions, 2 side
%%conditions, and the 3 different heights at which the targets appear which
%%are later combined
function []= tn_TrialWiseNEWPlotsAlignedtoBIFRpSEE(epochdataGazeA, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)

pSeeNames=fieldnames(ModifiedTrialSets.pSee.LesserThanChanceA);
   
% ByStimulusPosition_leftrightChoicecategoriesNamesSp=ByChoicePositionColourRewardNames(counter+4);
% ByStimulusPosition_leftrightChoicecategoriesNamesSpStr=ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.(ByStimulusPosition_leftrightChoicecategoriesNamesSp{1});
a=0;

for counter= 1:24
    pSeeSp=pSeeNames(counter);
    pSeeSpStr=ModifiedTrialSets.pSee.LesserThanChanceA.(pSeeSp{1});
    
    TrialLists=pSeeSpStr;
%     numb=length(TrialLists);
%     for RemoveLastTrial= 1: numb
%         
%     timepointsLists=linspace(-0.5, ,length(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)));
%     timeBins=histogram(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:));
%     timeBins.BinEdges=timepointsLists;
%     for i= 1: length(timepointsLists)-1
%         abc(:,i)=find(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)> timepointsLists(i) & epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)<= timepointsLists(i+1)
%     end
    
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
    if length(TrialLists)==0
       continue; 
    end
    
   
    subplot(2,2,a);
    OverLayPlotsGazeA=plot(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:),epochdataGazeA.B_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),'.','Color','k');
    hold on
    OverLayPlotsTouchB=plot(epochdataTouchB.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:),epochdataTouchB.B_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),'.','Color','b');
    hold on
    OverLayPlotsTouchA=plot(epochdataTouchA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:),epochdataTouchA.B_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),'.','Color','r');

    % %     OverLayPlotsGazeA.MarkerSize=3;
%     OverLayPlotsGazeA.Color='red';
    hold on 
    AverageGazeA=mean(epochdataGazeA.B_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),1);
    AverageTouchA=mean(epochdataGazeA.B_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),1);
    AverageTouchB=mean(epochdataGazeA.B_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),1);
%     av=mean(epochdataTouchA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:),1);
    ylim([650 1250]);
    xlim([-0.5 1.8])
%     OverLayPlotsGazeAVGA=plot(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists(1),:),AverageGazeA,'.','Color','r','MarkerSize', 6 )
%     hold on 
%     OverLayPlotsTouchAVGA=plot(epochdataTouchA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists(1),:),mean(epochdataTouchA.B_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),1),'*','Color','r' )
%     hold on
%     
%     
%     MaxLengthTimePoints_idx=find(epochdataTouchB.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)==max(length(epochdataTouchB.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:))));
%     min(nnz(~isnan(epochdataTouchB.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:))))
%     OverLayPlotsTouchAVGB=plot(epochdataTouchB.B_InitialFixationReleaseTime_ms.timepoints(TrialLists(1),:),mean(epochdataTouchB.B_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),1),'*','Color','b' )
%     
    xL_centraltarget=[-0.5,1.8];
    line(xL_centraltarget,[960 960],'Color','k');
    
    hold on
    xL_touchtarget=[-0.5,1.8];
    yL = get(gca,'YLim');    
    hold on
    line([0 0],yL,'Color','g');
    if counter>=1 && counter<=12 
        if a==1 || a==2
            line(xL_touchtarget,[739 739],'Color','b', 'LineStyle','--');
            line(xL_touchtarget,[1182 1182],'Color','r');
        else 
            line(xL_touchtarget,[739 739],'Color','b');
            line(xL_touchtarget,[1182 1182],'Color','r','LineStyle', '--');
        end
    else
        if a==1 || a==2
            line(xL_touchtarget,[739 739],'Color','r');
            line(xL_touchtarget,[1182 1182],'Color','b','LineStyle', '--');
        else 
            line(xL_touchtarget,[739 739],'Color','r','LineStyle', '--');
            line(xL_touchtarget,[1182 1182],'Color','b');
        end
    end
    if a==1
        ylabel('A selected Own Colour \newline X-Coordinates','FontSize',15)
                
    end
    if a==3
        xlabel('Time(secs) \newline B selected Own Colour','FontSize',15)      
        ylabel('A selected Other"s Colour \newline X-Coordinates','FontSize',15)
    end
    if a==4
        xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',15)
    end
    if counter>=1 && counter<=4 
        saveas(gcf, fullfile(saving_dir,[fileID, '_XGazeTimeRed_ObjectiveRightTopAlignedtoBIFRpSeeLessThanchance.jpg']))
        
    end
    if counter>=5 && counter<=8 
        saveas(gcf, fullfile(saving_dir,[fileID, '_XGazeTimeRed_ObjectiveRightCenterAlignedtoBIFRpSeeLessThanchance.jpg']))
        
    end
    if counter>=9 && counter<=12  
        saveas(gcf, fullfile(saving_dir,[fileID, '_XGazeTimeRed_ObjectiveRightBottomAlignedtoBIFRpSeeLessThanchance.jpg']))
        
    end
    if counter>=13 && counter<=16 
        saveas(gcf, fullfile(saving_dir,[fileID, '_XGazeTimeRed_ObjectiveLeftTopAlignedtoBIFRpSeeLessThanchance.jpg']))
        
    end
    if counter>=17 && counter<=20  
        saveas(gcf, fullfile(saving_dir,[fileID, '_XGazeTimeRed_ObjectiveLeftCenterAlignedtoBIFRpSeeLessThanchance.jpg']))
        
    end
    if counter>=21 && counter<=24 
        saveas(gcf, fullfile(saving_dir,[fileID, '_XGazeTimeRed_ObjectiveLeftBottomAlignedtoBIFRpSeeLessThanchance.jpg']))
    end
end

a=0;

% %%For Y Gaze vs Time
% for counter= 1:24
%     pSeeSp=pSeeNames(counter);
%     pSeeSpStr=ModifiedTrialSets.pSee.(pSeeSp{1});
%     
%     TrialLists=pSeeSpStr;
% %     numb=length(TrialLists);
% %     for RemoveLastTrial= 1: numb
% %         
% %     timepointsLists=linspace(-0.5, ,length(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)));
% %     timeBins=histogram(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:));
% %     timeBins.BinEdges=timepointsLists;
% %     for i= 1: length(timepointsLists)-1
% %         abc(:,i)=find(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)> timepointsLists(i) & epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)<= timepointsLists(i+1)
% %     end
%     
%     if counter==1 || counter==5 || counter==9 || counter==13 || counter==17 || counter== 21
%         figure()
%         
%     end
%    
%     a=a+1;
%     if a>4
%         a=1;
%     end
%     if length(TrialLists)==0
%        continue; 
%     end
%     subplot(2,2,a);
%     OverLayPlotsGazeA=plot(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:),epochdataGazeA.B_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),'.','Color','k');
% % %     OverLayPlotsGazeA.MarkerSize=3;
% %     OverLayPlotsGazeA.Color='red';
%     hold on 
%     AverageGazeA=mean(epochdataGazeA.B_InitialFixationReleaseTime_ms.yCoordinates(TrialLists,:),1);
%     AverageTouchA=mean(epochdataGazeA.B_InitialFixationReleaseTime_ms.yCoordinates(TrialLists,:),1);
%     AverageTouchB=mean(epochdataGazeA.B_InitialFixationReleaseTime_ms.yCoordinates(TrialLists,:),1);
% %     av=mean(epochdataTouchA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:),1);
%     ylim([650 1250]);
%     xlim([-0.5 1.8])
%     OverLayPlotsGazeAVGA=plot(epochdataGazeA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists(1),:),AverageGazeA,'.','Color','r','MarkerSize', 6 )
%     hold on 
%     OverLayPlotsTouchAVGA=plot(epochdataTouchA.B_InitialFixationReleaseTime_ms.timepoints(TrialLists(1),:),mean(epochdataTouchA.B_InitialFixationReleaseTime_ms.yCoordinates(TrialLists,:),1),'*','Color','r' )
%     hold on
%     
% %     
% %     MaxLengthTimePoints_idx=find(epochdataTouchB.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)==max(length(epochdataTouchB.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:))));
% %     min(nnz(~isnan(epochdataTouchB.B_InitialFixationReleaseTime_ms.timepoints(TrialLists,:))))
%     OverLayPlotsTouchAVGB=plot(epochdataTouchB.B_InitialFixationReleaseTime_ms.timepoints(TrialLists(1),:),mean(epochdataTouchB.B_InitialFixationReleaseTime_ms.yCoordinates(TrialLists,:),1),'*','Color','b' )
%     
%     xL_centraltarget=[-0.5,1.8];
%     line(xL_centraltarget,[500 500],'Color','k');
%     
%     hold on
%     xL_touchtarget=[-0.5,1.8];
%     yL = get(gca,'YLim');    
%     hold on
%     line([0 0],yL,'Color','g');
% %     if counter>=1 && counter<=12 
% %         if a==1 || a==2
% %             line(xL_touchtarget,[739 739],'Color','b', 'LineStyle','--');
% %             line(xL_touchtarget,[1182 1182],'Color','r');
% %         else 
% %             line(xL_touchtarget,[739 739],'Color','b');
% %             line(xL_touchtarget,[1182 1182],'Color','r','LineStyle', '--');
% %         end
% %     else
% %         if a==1 || a==2
% %             line(xL_touchtarget,[739 739],'Color','r');
% %             line(xL_touchtarget,[1182 1182],'Color','b','LineStyle', '--');
% %         else 
% %             line(xL_touchtarget,[739 739],'Color','r','LineStyle', '--');
% %             line(xL_touchtarget,[1182 1182],'Color','b');
% %         end
% %     end
%     if a==1
%         ylabel('A selected Own Colour \newline X-Coordinates','FontSize',15)
%                 
%     end
%     if a==3
%         xlabel('Time(secs) \newline B selected Own Colour','FontSize',15)      
%         ylabel('A selected Other"s Colour \newline X-Coordinates','FontSize',15)
%     end
%     if a==4
%         xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',15)
%     end
%     if counter>=1 && counter<=4 
%         saveas(gcf, fullfile(saving_dir,[fileID, '_YGazeTimeRed_ObjectiveRightTop.jpg']))
%         
%     end
%     if counter>=5 && counter<=8 
%         saveas(gcf, fullfile(saving_dir,[fileID, '_YGazeTimeRed_ObjectiveRightCenter.jpg']))
%         
%     end
%     if counter>=9 && counter<=12  
%         saveas(gcf, fullfile(saving_dir,[fileID, '_YGazeTimeRed_ObjectiveRightBottom.jpg']))
%         
%     end
%     if counter>=13 && counter<=16 
%         saveas(gcf, fullfile(saving_dir,[fileID, '_YGazeTimeRed_ObjectiveLeftTop.jpg']))
%         
%     end
%     if counter>=17 && counter<=20  
%         saveas(gcf, fullfile(saving_dir,[fileID, '_YGazeTimeRed_ObjectiveLeftCenter.jpg']))
%         
%     end
%     if counter>=21 && counter<=24 
%         saveas(gcf, fullfile(saving_dir,[fileID, '_YGazeTimeRed_ObjectiveLeftBottom.jpg']))
%     end
% end
% 
% 
% 
% %%SAVE THE FIGURES !
end