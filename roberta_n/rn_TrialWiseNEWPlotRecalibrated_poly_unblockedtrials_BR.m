%%This is to plot aligned data.
%%I overlay gaze from multiple trials ; and plot Own/Own; Own/Other;
%%Other/Own; Other/Other and put Touch from A and B on this 


function []= rn_TrialWiseNEWPlotRecalibrated_poly_unblockedtrials_BR(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir)

Byrewardttype_pos_unblocked_BR_Names=fieldnames(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Unblocked.BR);
  
% ByStimulusPosition_leftrightChoicecategoriesNamesSp=ByChoicePositionColourRewardNames(counter+4);
% ByStimulusPosition_leftrightChoicecategoriesNamesSpStr=ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.(ByStimulusPosition_leftrightChoicecategoriesNamesSp{1});

a=0;
TrialNumStr = 'No. of Trials= ';
for counter = 1:24
    Byrewardttype_posSp = Byrewardttype_pos_unblocked_BR_Names(counter);
    Byrewardttype_posSpStr = ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Unblocked.BR.(Byrewardttype_posSp{1});
    
    TrialLists = Byrewardttype_posSpStr;
	
%     numb=length(TrialLists);
%     for RemoveLastTrial= 1: numb
%         
%     timepointsLists=linspace(-0.5, ,length(epochdataGazeA.TargetOnset.timepoints(TrialLists,:)));
%     timeBins=histogram(epochdataGazeA.TargetOnset.timepoints(TrialLists,:));
%     timeBins.BinEdges=timepointsLists;
%     for i= 1: length(timepointsLists)-1
%         abc(:,i)=find(epochdataGazeA.TargetOnset.timepoints(TrialLists,:)> timepointsLists(i) & epochdataGazeA.TargetOnset.timepoints(TrialLists,:)<= timepointsLists(i+1)
%     end
    
	
		
    if counter==1 || counter==5 || counter==9 || counter==13 || counter==17 || counter== 21
        figure()
        set( gcf, 'PaperUnits','centimeters' );
        xSize = 24; ySize = 24;
        xLeft = 0; yTop = 0;
        set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );  
	
		left_color = [0 0 0];
		right_color = [0 0 0];
		set(figure,'defaultAxesColorOrder',[left_color; right_color]);

    end
   
    a=a+1;
    if a>4
        a=1;
	end 
    if length(TrialLists)==0
       continue; 
    end
    if counter>=1 && counter<=12
		annotation('textbox',[.9 .8 .1 .2],'String','Red on Objective Right','EdgeColor','none')
	end
	if counter>=13 && counter<=24
		annotation('textbox',[.9 .8 .1 .2],'String','Red on Objective Left','EdgeColor','none')
	end
	
	
	subplot(2,2,a);
	
	str=strcat(TrialNumStr, num2str(size((TrialLists),1)));
	text(0,1250,str);
	if a==1
		strCond='A-Own/B-Own';
		text(0,1300,strCond);
	end
	if a==2
		strCond='A-Own/B-Other';
		text(0,1300,strCond);
	end
	if a==3
		strCond='A-Other/B-Own';
		text(0,1300,strCond);
	end
	if a==4
		strCond='A-Other/B-Other';
		text(0,1300,strCond);
	end
	
    xL_centraltarget=[-0.5,1.8];
    line(xL_centraltarget,[960 960],'Color','k');
    ylim([650 1250]);
	xlim([-0.5 1.8]);
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
	
	vergence = (epochdataRegisteredGazeA_poly_right.TargetOnset.xCoordinates)- (epochdataRegisteredGazeA_poly_left.TargetOnset.xCoordinates);
	AverageVergence = mean (vergence(TrialLists,:),1,'omitnan');
	
    AverageTouchA = mean(epochdataTouchA.TargetOnset.xCoordinates(TrialLists,:),1,'omitnan');
    AverageTouchB = mean(epochdataTouchB.TargetOnset.xCoordinates(TrialLists,:),1,'omitnan');
	
%   av=mean(epochdataTouchA.TargetOnset.timepoints(TrialLists,:),1);
   
    
    AverageGazeA=mean(epochdataRegisteredGazeA_poly_right.TargetOnset.xCoordinates(TrialLists,:),1,'omitnan');

	OverLayPlotsGazeA=plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists,:),epochdataRegisteredGazeA_poly_right.TargetOnset.xCoordinates(TrialLists,:),'.','Color','k','MarkerSize',6);
    hold on
    OverLayPlotsTouchA=plot(epochdataTouchA.TargetOnset.timepoints(TrialLists,:),epochdataTouchA.TargetOnset.xCoordinates(TrialLists,:),'.','Color','r','MarkerSize',6);
    hold on
    OverLayPlotsTouchB=plot(epochdataTouchB.TargetOnset.timepoints(TrialLists,:),epochdataTouchB.TargetOnset.xCoordinates(TrialLists,:),'.','Color','b','MarkerSize',6);
    hold on
	OverLayPlotsGazeAVGA=plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AverageGazeA,'.','Color',[1,0.5,0],'MarkerSize',8)
    hold on
    OverLayPlotsTouchAVGA=plot(epochdataTouchA.TargetOnset.timepoints(TrialLists(1),:),AverageTouchA,'.','Color','g','MarkerSize',8)
    hold on
    OverLayPlotsTouchAVGB=plot(epochdataTouchB.TargetOnset.timepoints(TrialLists(1),:),AverageTouchB,'.','Color','y','MarkerSize',8)
%   OverLayPlotsGazeA.MarkerSize=3;
%   OverLayPlotsGazeA.Color='red';
    hold on 
	yyaxis right
	OverLayPlotsVergence = plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AverageVergence,'.','Color','m','MarkerSize',8)
	set(gca,'ylim',[-50 50])


    
%     
%     MaxLengthTimePoints_idx=find(epochdataTouchB.TargetOnset.timepoints(TrialLists,:)==max(length(epochdataTouchB.TargetOnset.timepoints(TrialLists,:))));
%     min(nnz(~isnan(epochdataTouchB.TargetOnset.timepoints(TrialLists,:))))
    
   hold on 
    if a==1
		yyaxis left
        ylabel('A selected Own Colour \newline X-Coordinates','FontSize',15)
                
    end
    if a==3
        xlabel('Time(secs) \newline B selected Own Colour','FontSize',15)  
		yyaxis left
        ylabel('A selected Other"s Colour \newline X-Coordinates','FontSize',15)
    end
    if a==4
        xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',15)
    end
    if counter>=1 && counter<=4 
        saveas(gcf, fullfile(saving_dir,'_XRegPolyFixTime_Unblocked_BR_Red_ObjectiveRightTop.pdf'))
        
    end
    if counter>=5 && counter<=8 
        saveas(gcf, fullfile(saving_dir,'_XRegPolyFixTime_Unblocked_BR_Red_ObjectiveRightCenter.pdf'))
        
    end
    if counter>=9 && counter<=12  
        saveas(gcf, fullfile(saving_dir,'_XRegPolyFixTime_Unblocked_BR_Red_ObjectiveRightBottom.pdf'))
        
    end
    if counter>=13 && counter<=16 
        saveas(gcf, fullfile(saving_dir,'_XRegPolyFixTime_Unblocked_BR_Red_ObjectiveLeftTop.pdf'))
        
    end
    if counter>=17 && counter<=20  
        saveas(gcf, fullfile(saving_dir,'_XRegPolyFixTime_Unblocked_BR_Red_ObjectiveLeftCenter.pdf'))
        
    end
    if counter>=21 && counter<=24 
        saveas(gcf, fullfile(saving_dir,'_XRegPolyFixTime_Unblocked_BR_Red_ObjectiveLeftBottom.pdf'))
    end
end

a=0;

% % For Y Gaze vs Time
% for counter= 1:24
%     Byrewardttype_posSp = Byrewardttype_pos_unblocked_BR_Names(counter);
%     Byrewardttype_posSpStr=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Unblocked.BR.(Byrewardttype_posSp{1});
%      
%    TrialLists=Byrewardttype_posSpStr;
% % %     numb=length(TrialLists);
% % %     for RemoveLastTrial= 1: numb
% % %         
% % %     timepointsLists=linspace(-0.5, ,length(epochdataGazeA.TargetOnset.timepoints(TrialLists,:)));
% % %     timeBins=histogram(epochdataGazeA.TargetOnset.timepoints(TrialLists,:));
% % %     timeBins.BinEdges=timepointsLists;
% % %     for i= 1: length(timepointsLists)-1
% % %         abc(:,i)=find(epochdataGazeA.TargetOnset.timepoints(TrialLists,:)> timepointsLists(i) & epochdataGazeA.TargetOnset.timepoints(TrialLists,:)<= timepointsLists(i+1)
% % %     end
% 
%     if counter==1 || counter==5 || counter==9 || counter==13 || counter==17 || counter== 21
%         figure()
%         set( gcf, 'PaperUnits','centimeters' );
%         xSize = 24; ySize = 24;
%         xLeft = 0; yTop = 0;
%         set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );  
% 		left_color = [0 0 0];
% 		right_color = [0 0 0];
% 		set(figure,'defaultAxesColorOrder',[left_color; right_color]);
%         
%      end
%    
%     a=a+1;
%     if a>4
%         a=1;
%     end
%     if length(TrialLists)==0
%        continue; 
%     end
%     subplot(2,2,a);
% 	xL_centraltarget=[-0.5,1.8];
%     line(xL_centraltarget,[500 500],'Color','k');
%     ylim([400 600]);
%     xlim([-0.5 1.8])
%     hold on
%     xL_touchtarget=[-0.5,1.8];
%     yL = get(gca,'YLim');    
%     hold on
%     line([0 0],yL,'Color','g');
% 	
%     if counter>=1 && counter<=12 
%         if a==1 || a==2
%             line(xL_touchtarget,[556 556],'Color','b', 'LineStyle','--');
%             line(xL_touchtarget,[556 556],'Color','r');
%         else 
%             line(xL_touchtarget,[556 556],'Color','b');
%             line(xL_touchtarget,[556 556],'Color','r','LineStyle', '--');
%         end
%     else
%         if a==1 || a==2
%             line(xL_touchtarget,[556 556],'Color','r');
%             line(xL_touchtarget,[556 556],'Color','b','LineStyle', '--');
%         else 
%             line(xL_touchtarget,[556 556],'Color','r','LineStyle', '--');
%             line(xL_touchtarget,[556 556],'Color','b');
%         end
%     end
% 	
% % % %     OverLayPlotsGazeA.MarkerSize=3;
% % %     OverLayPlotsGazeA.Color='red';
%     vergence = (epochdataRegisteredGazeA_poly_right.TargetOnset.xCoordinates)- (epochdataRegisteredGazeA_poly_left.TargetOnset.xCoordinates);
% 	AverageVergence = mean (vergence(TrialLists,:),1,'omitnan');
% 	
%     AverageGazeA=mean(epochdataRegisteredGazeA_poly_right.TargetOnset.yCoordinates(TrialLists,:),1);
%     AverageTouchA=mean(epochdataTouchA.TargetOnset.yCoordinates(TrialLists,:),1);
%     AverageTouchB=mean(epochdataTouchB.TargetOnset.yCoordinates(TrialLists,:),1);
% % % av=mean(epochdataTouchA.TargetOnset.timepoints(TrialLists,:),1);
%     OverLayPlotsGazeA=plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists,:),epochdataRegisteredGazeA_poly_right.TargetOnset.yCoordinates(TrialLists,:),'.','Color','k','MarkerSize',6);
%     hold on 
% 	OverLayPlotsTouchA=plot(epochdataTouchA.TargetOnset.timepoints(TrialLists,:),epochdataTouchA.TargetOnset.yCoordinates(TrialLists,:),'.','Color','r','MarkerSize',6);
%     hold on
%     OverLayPlotsTouchB=plot(epochdataTouchB.TargetOnset.timepoints(TrialLists,:),epochdataTouchB.TargetOnset.yCoordinates(TrialLists,:),'.','Color','b','MarkerSize',6);
%     hold on
%     OverLayPlotsGazeAVGA=plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AverageGazeA,'.','Color',[1,0.5,0],'MarkerSize',8)
%     hold on 
%     OverLayPlotsTouchAVGA=plot(epochdataTouchA.TargetOnset.timepoints(TrialLists(1),:),AverageTouchA,'*','Color','g','MarkerSize',8)
%     hold on
%     OverLayPlotsTouchAVGB=plot(epochdataTouchB.TargetOnset.timepoints(TrialLists(1),:),AverageTouchB,'*','Color','y','MarkerSize',8 )
% 	hold on 
% % %     
% % %     MaxLengthTimePoints_idx=find(epochdataTouchB.TargetOnset.timepoints(TrialLists,:)==max(length(epochdataTouchB.TargetOnset.timepoints(TrialLists,:))));
% % %     min(nnz(~isnan(epochdataTouchB.TargetOnset.timepoints(TrialLists,:))))
%     yyaxis right
% 	OverLayPlotsVergence = plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AverageVergence,'.','Color','m','MarkerSize',8)
% 	set(gca,'ylim',[-50 50])
% 	
% 
% 	hold on 
%     if a==1
% 		yyaxis left
%         ylabel('A selected Own Colour \newline Y-Coordinates','FontSize',15)
%                 
%     end
%     if a==3
%         xlabel('Time(secs) \newline B selected Own Colour','FontSize',15)      
% 		yyaxis left
%         ylabel('A selected Other"s Colour \newline Y-Coordinates','FontSize',15)
%     end
%     if a==4
%         xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',15)
%     end
%     if counter>=1 && counter<=4 
%         saveas(gcf, fullfile(saving_dir,'_YRegPolyFixTime_Unblocked_BR_Red_ObjectiveRightTop.pdf'))
%         
%     end
%     if counter>=5 && counter<=8 
%         saveas(gcf, fullfile(saving_dir,'_YRegPolyFixTime_Unblocked_BR_Red_ObjectiveRightCenter.pdf'))
%         
%     end
%     if counter>=9 && counter<=12  
%         saveas(gcf, fullfile(saving_dir,'_YRegPolyFixTime_Unblocked_BR_Red_ObjectiveRightBottom.pdf'))
%         
%     end
%     if counter>=13 && counter<=16 
%         saveas(gcf, fullfile(saving_dir,'_YRegPolyFixTime_Unblocked_BR_Red_ObjectiveLeftTop.pdf'))
%         
%     end
%     if counter>=17 && counter<=20  
%         saveas(gcf, fullfile(saving_dir,'_YRegPolyFixTime_Unblocked_BR_Red_ObjectiveLeftCenter.pdf'))
%         
%     end
%     if counter>=21 && counter<=24 
%         saveas(gcf, fullfile(saving_dir,'_YRegPolyFixTime_Unblocked_BR_Red_ObjectiveLeftBottom.pdf'))
%     end
end