%%This is just for plotting ; 1-24 is The 4 value based conditions, 2 side
%%conditions, and the 3 different heights at which the targets appear which
%%are later combined
function []= rn_TrialWiseNEWPlotsAlignedtoAIFR_reg_poly_unblockedtrials_BR(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)

Byrewardttype_pos_unblocked_BR_Names=fieldnames(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR);

% ByStimulusPosition_leftrightChoicecategoriesNamesSp=ByChoicePositionColourRewardNames(counter+4);
% ByStimulusPosition_leftrightChoicecategoriesNamesSpStr=ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.(ByStimulusPosition_leftrightChoicecategoriesNamesSp{1});
a=0;

for counter= 1:24
	Byrewardttype_posSp=Byrewardttype_pos_unblocked_BR_Names(counter);
	Byrewardttype_posSpStr=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.(Byrewardttype_posSp{1});
	
	TrialLists=Byrewardttype_posSpStr;
	%     numb=length(TrialLists);
	%     for RemoveLastTrial= 1: numb
	%
	%     timepointsLists=linspace(-0.5, ,length(epochdataGazeA.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)));
	%     timeBins=histogram(epochdataGazeA.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:));
	%     timeBins.BinEdges=timepointsLists;
	%     for i= 1: length(timepointsLists)-1
	%         abc(:,i)=find(epochdataGazeA.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)> timepointsLists(i) & epochdataGazeA.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)<= timepointsLists(i+1)
	%     end
	
	if counter==1 || counter==5 || counter==9 || counter==13 || counter==17 || counter== 21
		figure()
		set( gcf, 'PaperUnits','centimeters' );
		xSize = 24; ySize = 24;
		xLeft = 0; yTop = 0;
		set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
		
		left_color = [0 0 0];
		right_color = [0 0 0];
		set(figure,'defaultAxesColorOrder',[left_color; right_color])
	end
	
	a=a+1;
	if a>4
		a=1;
	end
	if length(TrialLists)==0
		continue;
	end
	
	
	subplot(2,2,a);
	
	xL_centraltarget=[-0.25,1];
	line(xL_centraltarget,[960 960],'Color','k');
	
	hold on
	xL_touchtarget=[-0.25, 1];
	ylim([650 1250]);
	xlim([-0.2 1]);
	
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
	
	
	AverageGazeA=mean(epochdataRegisteredGazeA_poly_right.xCoordinates(TrialLists,:),1,'omitnan');
	AverageTouchA=mean(epochdataTouchA.xCoordinates(TrialLists,:),1,'omitnan');
	AverageTouchB=mean(epochdataTouchB.xCoordinates(TrialLists,:),1,'omitnan');
	vergence = (epochdataRegisteredGazeA_poly_right.xCoordinates)- (epochdataRegisteredGazeA_poly_left.xCoordinates);
	AverageVergence = mean (vergence(TrialLists,:),1,'omitnan');
	
	
	OverLayPlotsTouchB=plot(epochdataTouchB.timepoints(TrialLists,:),epochdataTouchB.xCoordinates(TrialLists,:),'.','Color','b');
	hold on
	OverLayPlotsTouchA=plot(epochdataTouchA.timepoints(TrialLists,:),epochdataTouchA.xCoordinates(TrialLists,:),'.','Color','r');
	% %     OverLayPlotsGazeA.MarkerSize=3;
	%     OverLayPlotsGazeA.Color='red';
	hold on
	
	OverLayPlotsTouchAVGA=plot(epochdataTouchA.timepoints(TrialLists,:),AverageTouchA,'*','Color','r' );
	hold on
	OverLayPlotsTouchAVGB=plot(epochdataTouchB.timepoints(TrialLists,:),AverageTouchB,'*','Color','b' );
	hold on 
	OverLayPlotsGazeA=plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:),epochdataRegisteredGazeA_poly_right.xCoordinates(TrialLists,:),'.','Color','k');
	hold on 
	OverLayPlotsGazeAVGA=plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:),AverageGazeA,'.','Color',[1,0.5,0],'MarkerSize', 6 )
    hold on 
	yyaxis right
	OverLayPlotsVergence = plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists(1),:),AverageVergence,'.','Color','m','MarkerSize',4)
	set(gca,'ylim',[-50 50])
	
	
	
	
	%     MaxLengthTimePoints_idx=find(epochdataTouchB.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)==max(length(epochdataTouchB.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:))));
	%     min(nnz(~isnan(epochdataTouchB.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:))))
	%     OverLayPlotsTouchAVGB=plot(epochdataTouchB.A_InitialFixationReleaseTime_ms.timepoints(TrialLists(1),:),mean(epochdataTouchB.A_InitialFixationReleaseTime_ms.xCoordinates(TrialLists,:),1),'*','Color','b' )
	%
	
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
		saveas(gcf, fullfile(saving_dir,[fileID, '_XRegPolyFixTime_UnBLocked_BR_Red_ObjectiveRightTopAlignedtoAIFR.jpg']))
		
	end
	if counter>=5 && counter<=8
		saveas(gcf, fullfile(saving_dir,[fileID, '_XRegPolyFixTime_UnBlocked_BR_Red_ObjectiveRightCenterAlignedtoAIFR.jpg']))
		
	end
	if counter>=9 && counter<=12
		saveas(gcf, fullfile(saving_dir,[fileID, '_XRegPolyFixTime_UnBlocked_BR_Red_ObjectiveRightBottomAlignedtoAIFR.jpg']))
		
	end
	if counter>=13 && counter<=16
		saveas(gcf, fullfile(saving_dir,[fileID, '_XRegPolyFixTime_UnBlocked_BR_Red_ObjectiveLeftTopAlignedtoAIFR.jpg']))
		
	end
	if counter>=17 && counter<=20
		saveas(gcf, fullfile(saving_dir,[fileID, '_XRegPolyFixTime_UnBlocked_BR_Red_ObjectiveLeftCenterAlignedtoAIFR.jpg']))
		
	end
	if counter>=21 && counter<=24
		saveas(gcf, fullfile(saving_dir,[fileID, '_XRegPolyFixTime_UnBlocked_BR_Red_ObjectiveLeftBottomAlignedtoAIFR.jpg']))
	end
end

a=0;

%%For Y Gaze vs Time
for counter= 1:24
    Byrewardttype_posSp=Byrewardttype_pos_unblocked_BR_Names(counter);
    Byrewardttype_posSpStr=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.(Byrewardttype_posSp{1});
    
    TrialLists=Byrewardttype_posSpStr;
%     numb=length(TrialLists);
%     for RemoveLastTrial= 1: numb
%         
%     timepointsLists=linspace(-0.5, ,length(epochdataGazeA.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)));
%     timeBins=histogram(epochdataGazeA.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:));
%     timeBins.BinEdges=timepointsLists;
%     for i= 1: length(timepointsLists)-1
%         abc(:,i)=find(epochdataGazeA.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)> timepointsLists(i) & epochdataGazeA.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)<= timepointsLists(i+1)
%     end
    
    if counter==1 || counter==5 || counter==9 || counter==13 || counter==17 || counter== 21
        figure()
		set( gcf, 'PaperUnits','centimeters' );
		xSize = 24; ySize = 24;
		xLeft = 0; yTop = 0;
		set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
		
		left_color = [0 0 0];
		right_color = [0 0 0];
		set(figure,'defaultAxesColorOrder',[left_color; right_color])
	
        
    end
   
    a=a+1;
    if a>4
        a=1;
    end
    if length(TrialLists)==0
       continue; 
    end
    subplot(2,2,a);
	xL_centraltarget=[-0.5,1.8];
    line(xL_centraltarget,[500 500],'Color','k');
    ylim([400 600]);
    xlim([-0.5 1.8])
    hold on
    xL_touchtarget=[-0.5,1.8];
    yL = get(gca,'YLim');    
    hold on
    line([0 0],yL,'Color','g');
    if counter>=1 && counter<=12 
        if a==1 || a==2
            line(xL_touchtarget,[445 445],'Color','b', 'LineStyle','--');
            line(xL_touchtarget,[556 556],'Color','r');
        else 
            line(xL_touchtarget,[445 445],'Color','b');
            line(xL_touchtarget,[556 556],'Color','r','LineStyle', '--');
        end
    else
        if a==1 || a==2
            line(xL_touchtarget,[445 445],'Color','r');
            line(xL_touchtarget,[556 556],'Color','b','LineStyle', '--');
        else 
            line(xL_touchtarget,[445 445],'Color','r','LineStyle', '--');
            line(xL_touchtarget,[556 556],'Color','b');
        end
    end

% % 
    AverageGazeA=mean(epochdataRegisteredGazeA_poly_right.yCoordinates(TrialLists,:),1);
    AverageTouchA=mean(epochdataTouchA.yCoordinates(TrialLists,:),1,'omitnan');
    AverageTouchB=mean(epochdataTouchB.yCoordinates(TrialLists,:),1,'omitnan');
	vergence = (epochdataRegisteredGazeA_poly_right.xCoordinates)- (epochdataRegisteredGazeA_poly_left.xCoordinates);
	AverageVergence = mean (vergence(TrialLists,:),1,'omitnan');
	
%     av=mean(epochdataTouchA.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:),1);

    OverLayPlotsGazeA=plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:),epochdataRegisteredGazeA_poly_right.yCoordinates(TrialLists,:),'.','Color','k');
    OverLayPlotsGazeAVGA=plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists(1),:),AverageGazeA,'.','Color','r','MarkerSize', 6 )
    hold on 
    OverLayPlotsTouchAVGA=plot(epochdataTouchA.timepoints(TrialLists(1),:),AverageTouchA,'*','Color','r' )
    hold on
    
%     
%     MaxLengthTimePoints_idx=find(epochdataTouchB.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:)==max(length(epochdataTouchB.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:))));
%     min(nnz(~isnan(epochdataTouchB.A_InitialFixationReleaseTime_ms.timepoints(TrialLists,:))))
    OverLayPlotsTouchAVGB=plot(epochdataTouchB.timepoints(TrialLists(1),:),AverageTouchB,'*','Color','b' )
	 hold on 
	yyaxis right
	OverLayPlotsVergence = plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists(1),:),AverageVergence,'.','Color','m','MarkerSize',4)
	set(gca,'ylim',[-50 50])
	
	
 
    if a==1
		yyaxis left
        ylabel('A selected Own Colour \newline Y-Coordinates','FontSize',15)
                
    end
    if a==3
        xlabel('Time(secs) \newline B selected Own Colour','FontSize',15)     
		yyaxis left
        ylabel('A selected Other"s Colour \newline Y-Coordinates','FontSize',15)
    end
    if a==4
        xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',15)
    end
    if counter>=1 && counter<=4 
        saveas(gcf, fullfile(saving_dir,[fileID, '_YRegPolyFixTime_UnBlocked_BR_Red_ObjectiveRightBottomAlignedtoAIFR.jpg']))
        
    end
    if counter>=5 && counter<=8 
        saveas(gcf, fullfile(saving_dir,[fileID, '_YRegPolyFixTime_UnBlocked_BR_Red_ObjectiveRightCenterAlignedtoAIFR.jpg']))
        
    end
    if counter>=9 && counter<=12  
        saveas(gcf, fullfile(saving_dir,[fileID, '_YRegPolyFixTime_UnBlocked_BR_Red_ObjectiveRightTopAlignedtoAIFR.jpg']))
        
    end
    if counter>=13 && counter<=16 
        saveas(gcf, fullfile(saving_dir,[fileID, '_YRegPolyFixTime_UnBlocked_BR_Red_ObjectiveLeftBottomAlignedtoAIFR.jpg']))
        
    end
    if counter>=17 && counter<=20  
        saveas(gcf, fullfile(saving_dir,[fileID, '_YRegPolyFixTime_UnBlocked_BR_Red_ObjectiveLeftCenterAlignedtoAIFR.jpg']))
        
    end
    if counter>=21 && counter<=24 
        saveas(gcf, fullfile(saving_dir,[fileID, '_YRegPolyFixTime_UnBlocked_BR_Red_ObjectiveLeftTopAlignedtoAIFR.jpg']))
    end
end



% %%SAVE THE FIGURES !
end