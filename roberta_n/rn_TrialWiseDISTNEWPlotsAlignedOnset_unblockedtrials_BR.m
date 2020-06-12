%%Only for plotting DistA-A and DistA-B and segregating data
%%1-8 is 8 conditions : 4 value based and 2 side based conditions. ; 
%%[Own/Own; OwnOther; Other/Own; Other/Other]X [Red on objective right]
%%[Own/Own; OwnOther; Other/Own; Other/Other]X [Red on objective left]
function [DistGazeATouchA, DistGazeATouchB,DistGazeA_finaltarget_A, DistTouchA_finaltarget_A]= rn_TrialWiseDISTNEWPlotsAlignedOnset_unblockedtrials_BR(distGazeATouchA, distGazeATouchB,distGazeA_finaltarget_A, distTouchA_finaltarget_A,epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, ModifiedTrialSets, saving_dir)
close all
Byrewardttype_pos_unblocked_BR_Names=fieldnames(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Unblocked.BR);

% ByStimulusPosition_leftrightChoicecategoriesNamesSp=ByChoicePositionColourRewardNames(counter+4);
% ByStimulusPosition_leftrightChoicecategoriesNamesSpStr=ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.(ByStimulusPosition_leftrightChoicecategoriesNamesSp{1});
a=0;
TrialNumStr='No. of Trials= ';


for counter= 1:24
	Byrewardttype_posSp=Byrewardttype_pos_unblocked_BR_Names(counter);
	Byrewardttype_posSpStr=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Unblocked.BR.(Byrewardttype_posSp{1});
	
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
		DistGazeA_finaltarget_A.Type2401 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2401 = distTouchA_finaltarget_A(TrialLists,:);
		%DistTouchB_finaltarget_B.Type2401 = distTouchB_finaltarget_B(TrialLists,:);
		
	end
	if counter==5|| counter== 9
		DistGazeATouchA.Type2401=vertcat(DistGazeATouchA.Type2401,distGazeATouchA(TrialLists,:));
		DistGazeATouchB.Type2401=vertcat(DistGazeATouchB.Type2401,distGazeATouchB(TrialLists,:));
		DistGazeA_finaltarget_A.Type2401 = vertcat(DistGazeA_finaltarget_A.Type2401,distGazeA_finaltarget_A(TrialLists,:));
		DistTouchA_finaltarget_A.Type2401 = vertcat(DistTouchA_finaltarget_A.Type2401,distTouchA_finaltarget_A(TrialLists,:));
		%DistTouchB_finaltarget_B.Type2401 = vertcat(DistTouchB_finaltarget_B.Type2401,distTouchB_finaltarget_B(TrialLists,:));
	end
	if counter==2
		DistGazeATouchA.Type2402 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2402 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2402 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2402 = distTouchA_finaltarget_A(TrialLists,:);
		%DistTouchB_finaltarget_B.Type2402 = distTouchB_finaltarget_B(TrialLists,:);
		
	end
	if counter==6|| counter== 10
		DistGazeATouchA.Type2402 = vertcat(DistGazeATouchA.Type2402,distGazeATouchA(TrialLists,:));
		DistGazeATouchB.Type2402 = vertcat(DistGazeATouchB.Type2402,distGazeATouchB(TrialLists,:));
		DistGazeA_finaltarget_A.Type2402 = vertcat(DistGazeA_finaltarget_A.Type2402,distGazeA_finaltarget_A(TrialLists,:));
		DistTouchA_finaltarget_A.Type2402 = vertcat(DistTouchA_finaltarget_A.Type2402,distTouchA_finaltarget_A(TrialLists,:));
		%DistTouchB_finaltarget_B.Type2402 = vertcat(DistTouchB_finaltarget_B.Type2402,distTouchB_finaltarget_B(TrialLists,:));
		
	end
	if counter==3
		DistGazeATouchA.Type2403 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2403 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2403 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2403 = distTouchA_finaltarget_A(TrialLists,:);
		%DistTouchB_finaltarget_B.Type2403 = distTouchB_finaltarget_B(TrialLists,:);
		
	end
	if counter==7|| counter== 11
		DistGazeATouchA.Type2403=vertcat(DistGazeATouchA.Type2403,distGazeATouchA(TrialLists,:));
		DistGazeATouchB.Type2403=vertcat(DistGazeATouchB.Type2403,distGazeATouchB(TrialLists,:));
		DistGazeA_finaltarget_A.Type2403 = vertcat(DistGazeA_finaltarget_A.Type2403,distGazeA_finaltarget_A(TrialLists,:));
		DistTouchA_finaltarget_A.Type2403 = vertcat(DistTouchA_finaltarget_A.Type2403,distTouchA_finaltarget_A(TrialLists,:));
		%DistTouchB_finaltarget_B.Type2403 = vertcat(DistTouchB_finaltarget_B.Type2403,distTouchB_finaltarget_B(TrialLists,:));
		
		
	end
	
	if counter==4
		DistGazeATouchA.Type2404 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2404 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2404 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2404 = distTouchA_finaltarget_A(TrialLists,:);
		%DistTouchB_finaltarget_B.Type2404 = distTouchB_finaltarget_B(TrialLists,:);
		
	end
	if counter==8|| counter== 12
		DistGazeATouchA.Type2404 = vertcat(DistGazeATouchA.Type2404,distGazeATouchA(TrialLists,:));
		DistGazeATouchB.Type2404 = vertcat(DistGazeATouchB.Type2404,distGazeATouchB(TrialLists,:));
		DistGazeA_finaltarget_A.Type2404 = vertcat(DistGazeA_finaltarget_A.Type2404,distGazeA_finaltarget_A(TrialLists,:));
		DistTouchA_finaltarget_A.Type2404 = vertcat(DistTouchA_finaltarget_A.Type2404,distTouchA_finaltarget_A(TrialLists,:));
		%DistTouchB_finaltarget_B.Type2404 = vertcat(DistTouchB_finaltarget_B.Type2404,distTouchB_finaltarget_B(TrialLists,:));
		
	end
	
	if counter==13
		DistGazeATouchA.Type2405 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2405 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2405 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2405 = distTouchA_finaltarget_A(TrialLists,:);
		%DistTouchB_finaltarget_B.Type2405 = distTouchB_finaltarget_B(TrialLists,:);
	end
	if counter==17|| counter== 21
		DistGazeATouchA.Type2405 = vertcat(DistGazeATouchA.Type2405,distGazeATouchA(TrialLists,:));
		DistGazeATouchB.Type2405 = vertcat(DistGazeATouchB.Type2405,distGazeATouchB(TrialLists,:));
		DistGazeA_finaltarget_A.Type2405 = vertcat(DistGazeA_finaltarget_A.Type2405,distGazeA_finaltarget_A(TrialLists,:));
		DistTouchA_finaltarget_A.Type2405 = vertcat(DistTouchA_finaltarget_A.Type2405,distTouchA_finaltarget_A(TrialLists,:));
		%DistTouchB_finaltarget_B.Type2405 = vertcat(DistTouchB_finaltarget_B.Type2405,distTouchB_finaltarget_B(TrialLists,:));
	end
	if counter==14
		DistGazeATouchA.Type2406 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2406 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2406 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2406 = distTouchA_finaltarget_A(TrialLists,:);
		%DistTouchB_finaltarget_B.Type2406 = distTouchB_finaltarget_B(TrialLists,:);
	end
	if counter==18|| counter== 22
		DistGazeATouchA.Type2406 = vertcat(DistGazeATouchA.Type2406,distGazeATouchA(TrialLists,:));
		DistGazeATouchB.Type2406 = vertcat(DistGazeATouchB.Type2406,distGazeATouchB(TrialLists,:));
		DistGazeA_finaltarget_A.Type2406 = vertcat(DistGazeA_finaltarget_A.Type2406,distGazeA_finaltarget_A(TrialLists,:));
		DistTouchA_finaltarget_A.Type2406 = vertcat(DistTouchA_finaltarget_A.Type2406,distTouchA_finaltarget_A(TrialLists,:));
		%DistTouchB_finaltarget_B.Type2406 = vertcat(DistTouchB_finaltarget_B.Type2406,distTouchB_finaltarget_B(TrialLists,:));
	end
	if counter==15
		DistGazeATouchA.Type2407 = distGazeATouchA(TrialLists,:);
		DistGazeATouchB.Type2407 = distGazeATouchB(TrialLists,:);
		DistGazeA_finaltarget_A.Type2407 = distGazeA_finaltarget_A(TrialLists,:);
		DistTouchA_finaltarget_A.Type2407 = distTouchA_finaltarget_A(TrialLists,:);
		%DistTouchB_finaltarget_B.Type2407 = distTouchB_finaltarget_B(TrialLists,:);
		
	end
	if counter==19|| counter== 23
		DistGazeATouchA.Type2407 = vertcat(DistGazeATouchA.Type2407,distGazeATouchA(TrialLists,:));
		DistGazeATouchB.Type2407 = vertcat(DistGazeATouchB.Type2407,distGazeATouchB(TrialLists,:));
		DistGazeA_finaltarget_A.Type2407 = vertcat(DistGazeA_finaltarget_A.Type2407,distGazeA_finaltarget_A(TrialLists,:));
		DistTouchA_finaltarget_A.Type2407 = vertcat(DistTouchA_finaltarget_A.Type2407,distTouchA_finaltarget_A(TrialLists,:));
		%DistTouchB_finaltarget_B.Type2407 = vertcat(DistTouchB_finaltarget_B.Type2407,distTouchB_finaltarget_B(TrialLists,:));
	end
	
	if counter==16
		if isempty(TrialLists)
			DistGazeATouchA.Type2408(1,1:(size(DistGazeATouchA.Type2407,2)))=NaN;
			DistGazeATouchB.Type2408(1,1:(size(DistGazeATouchB.Type2407,2)))=NaN;
			DistGazeA_finaltarget_A.Type2408(1:1:(size(DistGazeA_finaltarget_A.Type2407,2)))=NaN;
			DistTouchA_finaltarget_A.Type2408(1:1:(size(DistTouchA_finaltarget_A.Type2407,2)))=NaN;
			%DistTouchB_finaltarget_B.Type2408(1:1:(size(DistTouchB_finaltarget_B.Type2407,2)))=NaN;
		else
			
			DistGazeATouchA.Type2408 = distGazeATouchA(TrialLists,:);
			DistGazeATouchB.Type2408 = distGazeATouchB(TrialLists,:);
			DistGazeA_finaltarget_A.Type2408 = distGazeA_finaltarget_A(TrialLists,:);
			DistTouchA_finaltarget_A.Type2408 = distTouchA_finaltarget_A(TrialLists,:);
			%DistTouchB_finaltarget_B.Type2408 = distTouchB_finaltarget_B(TrialLists,:);
			
		end
	end
	if counter==20|| counter== 24
		DistGazeATouchA.Type2408=vertcat(DistGazeATouchA.Type2408,distGazeATouchA(TrialLists,:));
		DistGazeATouchB.Type2408=vertcat(DistGazeATouchB.Type2408,distGazeATouchB(TrialLists,:));
		DistGazeA_finaltarget_A.Type2408 = vertcat(DistGazeA_finaltarget_A.Type2408,distGazeA_finaltarget_A(TrialLists,:));
		DistTouchA_finaltarget_A.Type2408 = vertcat(DistTouchA_finaltarget_A.Type2408,distTouchA_finaltarget_A(TrialLists,:));
		%DistTouchB_finaltarget_B.Type2408 = vertcat(DistTouchB_finaltarget_B.Type2408,distTouchB_finaltarget_B(TrialLists,:));
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
	
	str=strcat(TrialNumStr, num2str(size((TrialLists),1)));
	text(0,550,str);
	if a==1
		strCond='A-Own/B-Own';
		text(0,600,strCond);
	end
	if a==2
		strCond='A-Own/B-Other';
		text(0,600,strCond);
	end
	if a==3
		strCond='A-Other/B-Own';
		text(0,600,strCond);
	end
	if a==4
		strCond='A-Other/B-Other';
		text(0,600,strCond);
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
    vergence = (epochdataRegisteredGazeA_poly_right.TargetOnset.xCoordinates)- (epochdataRegisteredGazeA_poly_left.TargetOnset.xCoordinates);
	AverageVergence = mean (vergence(TrialLists,:),1,'omitnan');
	
	AveragedistGazeA_finaltarget_A = mean(distGazeA_finaltarget_A(TrialLists,:),1, 'omitnan');
	AveragedistTouchA_finaltarget_A = mean (distTouchA_finaltarget_A(TrialLists,:),1,'omitnan');
	%AveragedistTouchB_finaltarget_B = mean (distTouchB_finaltarget_B(TrialLists,:),1,'omitnan');

	
	DistGazeATouchAOverlay = plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists,:),distGazeATouchA(TrialLists,:),'.','Color','r','MarkerSize',4);
	hold on
	DistGazeATouchBOverlay = plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists,:),distGazeATouchB(TrialLists,:),'.','Color','b','MarkerSize',4);
	hold on
	DistGazeATouchAAVGOverlay = plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AveragedistGazeATouchA,'*','Color','g','MarkerSize',6);
	hold on
	DistGazeATouchBAVGOverlay = plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AveragedistGazeATouchB,'*','Color','y','MarkerSize',6);
	hold on
	DistGazeA_finaltarget_AAVGOverlay = plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AveragedistGazeA_finaltarget_A,'*','Color','k','MarkerSize',6);
	hold on 
	DistTouchA_finaltarget_AAVGOverlay = plot (epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AveragedistTouchA_finaltarget_A,'*','Color','c','MarkerSize',6);
	hold on 
	%DistTouchB_finaltarget_BAVGOverlay = plot (epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AveragedistTouchB_finaltarget_B,'*','Color',[1 0.5 0 ],'MarkerSize',6);
	hold on
	yyaxis right
	OverLayPlotsVergence = plot(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AverageVergence,'.','Color','m','MarkerSize',6)
	set(gca,'ylim',[-50 50])
	
    hold on 
	if a==1
	    yyaxis left
        ylabel('A selected Own Colour \newline  Difference between Gaze and Touch','FontSize',12)
		
	end
	if a==3
		xlabel('Time(secs) \newline B selected Own Colour','FontSize',12)
		yyaxis left
		ylabel('A selected Other"s Colour \newline  Difference between Gaze and Touch','FontSize',12)
	end
	if a==4
		xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',12)
	end
    
    if counter>=1 && counter<=4
		write_out_figure(gcf, fullfile(saving_dir,'EuclDiffbwTouchTime_UnBlocked_BR_Red_ObjectiveRightTopAlignedtoOnset.pdf'))
		
	end
	if counter>=5 && counter<=8
		write_out_figure(gcf, fullfile(saving_dir,'EuclDiffbwTouchTime_UnBlocked_BR_Red_ObjectiveRightCenterAlignedtoOnset.pdf'))
		
	end
	if counter>=9 && counter<=12
		write_out_figure(gcf, fullfile(saving_dir,'EuclDiffbwTouchTime_UnBLocked_BR_Red_ObjectiveRightBottomAlignedtoOnset.pdf'))
		
	end
	if counter>=13 && counter<=16
		write_out_figure(gcf, fullfile(saving_dir,'EuclDiffbwTouchTime_UnBLocked_BR_Red_ObjectiveLeftTopAlignedtoOnset.pdf'))
		
	end
	if counter>=17 && counter<=20
		write_out_figure(gcf, fullfile(saving_dir,'EuclDiffbwTouchTime_UnBLocked_BR_Red_ObjectiveLeftCenterAlignedtoOnset.pdf'))
		
	end
	if counter>=21 && counter<=24
		write_out_figure(gcf, fullfile(saving_dir,'EuclDiffbwTouchTime_UnBlocked_BR_Red_ObjectiveLeftBottomAlignedtoOnset.pdf'))
	end
end

a=0;

return
end