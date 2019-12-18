%%[Own/Own; OwnOther; Other/Own; Other/Other]X [Red on objective left]
function [DistGazeATouchA, DistGazeATouchB, DistGazeA_finaltarget_A, DistTouchA_finaltarget_A, Timepoints]= rn_TrialWiseDISTNEWPlotsAlignedAIFR_blocked_foll_BR_mer(distGazeATouchA, distGazeATouchB,distGazeA_finaltarget_A, distTouchA_finaltarget_A,epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, ModifiedTrialSets, saving_dir)

Byrewardttype_pos_blocked_Names=fieldnames(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR);

% ByStimulusPosition_leftrightChoicecategoriesNamesSp=ByChoicePositionColourRewardNames(counter+4);
% ByStimulusPosition_leftrightChoicecategoriesNamesSpStr=ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.(ByStimulusPosition_leftrightChoicecategoriesNamesSp{1});
a=0;
TrialNumStr='N: ';


for counter= 1:8
	Byrewardttype_posSp=Byrewardttype_pos_blocked_Names(counter);
	Byrewardttype_posSpStr = ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.(Byrewardttype_posSp{1});
	
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
		DistGazeATouchA.Type2401 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2401 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2401 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2401 = distTouchA_finaltarget_A(TrialLists,:);
		Timepoints.TrialWise.Type2401 = epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:);
	end
	
	if counter==2
		DistGazeATouchA.Type2402 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2402 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2402 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2402 = distTouchA_finaltarget_A(TrialLists,:);
	    Timepoints.TrialWise.Type2402 = epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:);

	end
	
	if counter==3
		DistGazeATouchA.Type2403 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2403 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2403 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2403 = distTouchA_finaltarget_A(TrialLists,:);
		Timepoints.TrialWise.Type2403 = epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:);

	end
	
	if counter==4
		DistGazeATouchA.Type2404 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2404 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2404 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2404 = distTouchA_finaltarget_A(TrialLists,:);
		Timepoints.TrialWise.Type2404 = epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:);

	end
	
	if counter==5
		DistGazeATouchA.Type2405 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2405 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2405 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2405 = distTouchA_finaltarget_A(TrialLists,:);
		Timepoints.TrialWise.Type2405 = epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:);

	end
	
	if counter==6
		DistGazeATouchA.Type2406 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2406 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2406 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2406 = distTouchA_finaltarget_A(TrialLists,:);
		Timepoints.TrialWise.Type2406 = epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:);

	end
	
	if counter==7
		DistGazeATouchA.Type2407 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2407 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2407 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2407 = distTouchA_finaltarget_A(TrialLists,:);
		Timepoints.TrialWise.Type2407 = epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:);

	end
	
	if counter==8
		DistGazeATouchA.Type2408 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2408 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2408 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2408 = distTouchA_finaltarget_A(TrialLists,:);
	    Timepoints.TrialWise.Type2408 = epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:);

	end
	
	if counter==1 || counter==5
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
	if isempty(TrialLists)
		continue;
	end
	if counter>=1 && counter<=4
		annotation('textbox',[.2 .8 .9 .2],'String','Trials aligned to target onset in the blocked condition : Red on Objective Right','EdgeColor','none')
	end
	if counter>=5 && counter<=8
		annotation('textbox',[.2 .8 .9 .2],'String','Trials aligned to target onset in the blocked condition : Red on Objective Left','EdgeColor','none')
	end
	
	subplot(2,2,a);
	str=strcat(TrialNumStr, num2str(size((TrialLists),1)));
	title (str);
	
	if a==1
		strCond='A-Own/B-Own';
		final_str = strcat (strCond,str);
		title(final_str);
	end
	if a==2
		strCond='A-Own/B-Other';
		final_str = strcat (strCond,str);
		title(final_str);
	end
	if a==3
		strCond='A-Other/B-Own';
		final_str = strcat (strCond,str);
		title(final_str);
	end
	if a==4
		strCond='A-Other/B-Other';
		final_str = strcat (strCond,str);
		title(final_str);
	end
	yL = get(gca,'YLim');
	
	line([0 0],yL,'Color','b');
	hold on
	%     line([AVGAIFR AVGAIFR],yL,'Color','r','LineStyle','--');
	xlim([-0.5 1.8])
    xL = get(gca,'XLim') ;
	hold on
	line(xL,[300 300],'Color','k');
	hold on
	ylim([0 600])
	yL = get(gca,'YLim');
	hold on
	line([0 0],yL,'Color','g');
	hold on
	
	
	AveragedistGazeATouchA = mean(distGazeATouchA(TrialLists,:),1, 'omitnan');
	AveragedistGazeATouchB = mean (distGazeATouchB(TrialLists,:),1,'omitnan');
    vergence = (epochdataRegisteredGazeA_poly_right.xCoordinates)- (epochdataRegisteredGazeA_poly_left.xCoordinates);
	AverageVergence = mean (vergence(TrialLists,:),1,'omitnan');
	
	AveragedistGazeA_finaltarget_A = mean(distGazeA_finaltarget_A(TrialLists,:),1, 'omitnan');
	AveragedistTouchA_finaltarget_A = mean (distTouchA_finaltarget_A(TrialLists,:),1,'omitnan');
	%AveragedistTouchB_finaltarget_B = mean (distTouchB_finaltarget_B(TrialLists,:),1,'omitnan');

	
	DistGazeATouchAOverlay = plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:),distGazeATouchA(TrialLists,:),'.','Color','r','MarkerSize',4);
	hold on
	DistGazeATouchBOverlay = plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists,:),distGazeATouchB(TrialLists,:),'.','Color','b','MarkerSize',4);
	hold on
	DistGazeATouchAAVGOverlay = plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists(1),:),AveragedistGazeATouchA,'*','Color','g','MarkerSize',6);
	hold on
	DistGazeATouchBAVGOverlay = plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists(1),:),AveragedistGazeATouchB,'*','Color','y','MarkerSize',6);
	hold on
	DistGazeA_finaltarget_AAVGOverlay = plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists(1),:),AveragedistGazeA_finaltarget_A,'*','Color','k','MarkerSize',6);
	hold on 
	DistTouchA_finaltarget_AAVGOverlay = plot (epochdataRegisteredGazeA_poly_right.timepoints(TrialLists(1),:),AveragedistTouchA_finaltarget_A,'*','Color','c','MarkerSize',6);
	hold on 
	%DistTouchB_finaltarget_BAVGOverlay = plot (epochdataRegisteredGazeA_poly_right.timepoints(TrialLists(1),:),AveragedistTouchB_finaltarget_B,'*','Color',[1 0.5 0 ],'MarkerSize',6);
	hold on
	yyaxis right
	OverLayPlotsVergence = plot(epochdataRegisteredGazeA_poly_right.timepoints(TrialLists(1),:),AverageVergence,'.','Color','m','MarkerSize',8)
	set(gca,'ylim',[-50 50])
	
    hold on 
	if a==1
	    yyaxis left
        ylabel('Difference between Gaze and Touch','FontSize',10)
		
	end
	if a==3
		xlabel('Time(secs)','FontSize',10)
		yyaxis left
		ylabel('Difference between Gaze and Touch','FontSize',10)
	end
	if a==4
		xlabel('Time(secs','FontSize',10)
	end
	
	
	
	if counter>=1 && counter<=4
		write_out_figure(gcf, fullfile(saving_dir,'EuclDiffbwTouchTime_Blocked_firstfollowing_BR_Red_ObjectiveRightAlignedtoAIFR.pdf'))
		
	end
	if counter>=5 && counter<=8
		write_out_figure(gcf, fullfile(saving_dir,'EuclDiffbwTouchTime_Blocked_firstfollowing_BR_Red_ObjectiveLeftAlignedtoAIFR.pdf'))
		
	end
	
end

a=0;

return
end