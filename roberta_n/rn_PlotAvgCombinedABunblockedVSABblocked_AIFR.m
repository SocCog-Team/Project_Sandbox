function [] = rn_PlotAvgCombinedABunblockedVSABblocked_AIFR (FullStructure, FullStructure_unblocked,FullStructure_blocked, saving_dir)
b = 0;
TrialNumStr = 'N: ';

fieldnames_unblocked_AB = fieldnames(FullStructure_unblocked.AB);
fieldnames_blocked_AB = fieldnames(FullStructure_blocked.AB);

for a = 1:8
	cur_fieldnames_unblocked_AB = fieldnames_unblocked_AB{a};
	cur_fieldnames_blocked_AB = fieldnames_blocked_AB{a};
	
	TrialLists_unblocked_AB = FullStructure_unblocked.AB.(cur_fieldnames_unblocked_AB);
	TrialLists_blocked_AB = FullStructure_blocked.AB.(cur_fieldnames_blocked_AB);
	TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_AB);
	TrialListsScores = FullStructure(a).PermScores;
	
	% Names=fieldnames(SampleA);
	% b=0;
	
	% for a= 1:length(Names)
	%     Sp=Names(a);
	%     SpSampleA=SampleA.(Sp{1});
	%     SpSampleB=SampleB.(Sp{1});
	%     SpTimepoints=Timepoints.(Sp{1});
	% %     SpScores=Scores.(Sp{1});
	%     SpAIFRAlignedAIFR=AIFRsEpoch.(Sp{1});
	%
	
	if (a == 1) || (a == 5)
		figure()
		set( gcf, 'PaperUnits', 'centimeters' );
		xSize = 24;
		ySize = 24;
		xLeft = 0;
		yTop = 0;
		set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
	end
	
	
	b = b + 1;
	if b > 4
		b = 1;
	end
	
	AvgAB_unblocked = mean(TrialLists_unblocked_AB,1,'omitnan');
	STD_AB_unblocked = std(TrialLists_unblocked_AB, 'omitnan');
	SEM_AB_unblocked = std(TrialLists_unblocked_AB , 'omitnan') / size(TrialLists_unblocked_AB, 1);
	AB_unblocked_isNotNaN_array = ~isnan(TrialLists_unblocked_AB);
	AB_unblocked_N_per_bin_list = sum(AB_unblocked_isNotNaN_array, 1);
	[A_unblocked_CIHW95] = calc_cihw(STD_AB_unblocked, AB_unblocked_N_per_bin_list, 0.05);
	%   [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
	A_unblocked_CIHW95(A_unblocked_CIHW95 == 0) = NaN;
	
	AvgAB_blocked = mean(TrialLists_blocked_AB, 1, 'omitnan');
	STD_AB_blocked = std(TrialLists_blocked_AB, 'omitnan');
	SEM_AB_blocked = std(TrialLists_blocked_AB, 'omitnan') / size(TrialLists_blocked_AB, 1);
	AB_blocked_isNotNaN_array = ~isnan(TrialLists_unblocked_AB);
	AB_blocked_N_per_bin_list = sum(AB_blocked_isNotNaN_array, 1);
	[A_blocked_CIHW95] = calc_cihw(STD_AB_blocked, AB_blocked_N_per_bin_list, 0.05);
	%   [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
	A_blocked_CIHW95(A_blocked_CIHW95 == 0) = NaN;
	
	%     AvgAT_unblocked = mean(TrialLists_unblocked_AT, 1, 'omitnan');
	% 	STD_AT_unblocked = std(TrialLists_unblocked_AT, 'omitnan');
	%     SEM_AT_unblocked = std(TrialLists_unblocked_AT, 'omitnan') / size(TrialLists_unblocked_AT, 1);
	% 	AT_unblocked_isNotNaN_array = ~isnan(TrialLists_unblocked_AT);
	% 	AT_unblocked_N_per_bin_list = sum(AT_unblocked_isNotNaN_array, 1);
	%     [T_unblocked_CIHW95] = calc_cihw(STD_AT_unblocked, AT_unblocked_N_per_bin_list, 0.05);
	% %   [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
	%     T_unblocked_CIHW95(T_unblocked_CIHW95 == 0) = NaN;
	% %
	%     AvgAT_blocked = mean(TrialLists_blocked_AT, 1, 'omitnan');
	% 	STD_AT_blocked = std(TrialLists_blocked_AT, 'omitnan');
	%     SEM_AT_blocked = std(TrialLists_blocked_AT, 'omitnan') / size(TrialLists_blocked_AT, 1);
	% 	AT_blocked_isNotNaN_array = ~isnan(TrialLists_blocked_AT);
	% 	AT_blocked_N_per_bin_list = sum(AT_blocked_isNotNaN_array, 1);
	%     [T_blocked_CIHW95] = calc_cihw(STD_AT_blocked, AT_blocked_N_per_bin_list, 0.05);
	% %   [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
	%     T_blocked_CIHW95(T_blocked_CIHW95 == 0) = NaN;
	
	%TO DO : look carefully
	subplot(2,2,b);
	
	if a==1
		annotation('textbox',[.2 .8 .9 .2],'String','Trials with red on Objective Right','EdgeColor','none')
		
	end
	if a==5
		annotation('textbox',[.2 .8 .9 .2],'String','Trials with red on Objective Left','EdgeColor','none')
	end
	str=strcat(TrialNumStr, num2str(size((TrialLists_unblocked_AB),1)),TrialNumStr, num2str(size((TrialLists_blocked_AB),1)));
	title (str);
	
	%     text(0.70,380,str);
	%     if b==1
	%         strCond ='A-Own/B-Own';
	%         text(0.7,420,strCond);
	%     end
	%     if b==2
	%         strCond ='A-Own/B-Other';
	%         text(0.70,420,strCond);
	%     end
	%     if b==3
	%         strCond ='A-Other/B-Own';
	%         text(0.70,420,strCond);
	%     end
	%     if b==4
	%         strCond ='A-Other/B-Other';
	%         text(0.70,420,strCond);
	%     end
	
	xlim([-0.2 0.9]);
	ylim([0 500]);
	yL = get(gca,'YLim');
	hold on
	line([0 0],yL,'Color','b');
	hold on
	xL = get(gca,'XLim');
	hold on
	line(xL,[0 0],'Color','k');
	hold on
	
	%[Clusters, ListSignClusters]= tn_PlottingClusters(TrialListsScores, TrialListsTimepoints);
	hold on
	[AClosertoZero BClosertoZero] = tn_ClosertoZero(AvgAB_unblocked,AvgAB_blocked, TrialListsTimepoints);
	%      hold on
	% TO DO : try to understand
	%     [AClosertoZero BClosertoZero] = tn_ClosertoZerowithTarget(AvgAA_unblocked,AvgAA_blocked,AvgAT_unblocked,AvgAT_blocked,TrialListsTimepoints);
	hold on
	plot((TrialListsTimepoints(1,:)),AvgAB_unblocked,'Color','r', 'LineWidth',2);
	hold on
	plot((TrialListsTimepoints(1,:)),(AvgAB_unblocked+SEM_AB_unblocked),'Color','r', 'LineWidth',0.5);
	plot((TrialListsTimepoints(1,:)),AvgAB_unblocked-SEM_AB_unblocked,'Color','r', 'LineWidth',0.5);
	hold on
	plot((TrialListsTimepoints(1,:)),AvgAB_blocked,'Color','b', 'LineWidth',2);
	plot((TrialListsTimepoints(1,:)),AvgAB_blocked + SEM_AB_blocked,'Color','b', 'LineWidth',0.5);
	plot((TrialListsTimepoints(1,:)),AvgAB_blocked - SEM_AB_blocked,'Color','b', 'LineWidth',0.5);
	hold on
	%     plot((TrialListsTimepoints(6,:)),AvgAT_unblocked,'Color','k', 'LineWidth',2);
	%     hold on
	%     plot((TrialListsTimepoints(6,:)),AvgAT_unblocked + SEM_AT_blocked,'Color','k', 'LineWidth',0.5);
	%     plot((TrialListsTimepoints(6,:)),AvgAT_unblocked - SEM_AT_blocked,'Color','k', 'LineWidth',0.5);
	%     hold on
	% 	plot((TrialListsTimepoints(6,:)),AvgAT_blocked,'Color','m', 'LineWidth',2);
	%     hold on
	%     plot((TrialListsTimepoints(6,:)),AvgAT_blocked + SEM_AT_blocked,'Color','m', 'LineWidth',0.5);
	%     plot((TrialListsTimepoints(6,:)),AvgAT_blocked - SEM_AT_blocked,'Color','m', 'LineWidth',0.5);
	%     hold on
	plot((TrialListsTimepoints(1,:)),AvgAB_blocked + A_blocked_CIHW95,'Color','b', 'LineWidth',0.5, 'LineStyle', '--');
	plot((TrialListsTimepoints(1,:)),AvgAB_blocked - A_blocked_CIHW95,'Color','b', 'LineWidth',0.5, 'LineStyle', '--');
	plot((TrialListsTimepoints(1,:)),AvgAB_unblocked + A_unblocked_CIHW95,'Color','r', 'LineWidth',0.5, 'LineStyle', '--');
	plot((TrialListsTimepoints(1,:)),AvgAB_unblocked - A_unblocked_CIHW95,'Color','r', 'LineWidth',0.5, 'LineStyle', '--');
	%     plot((TrialListsTimepoints(6,:)),AvgAT_unblocked + T_unblocked_CIHW95,'Color','k', 'LineWidth',0.5, 'LineStyle', '--');
	%     plot((TrialListsTimepoints(6,:)),AvgAT_unblocked - T_unblocked_CIHW95,'Color','k', 'LineWidth',0.5, 'LineStyle', '--');
	% %     plot((TrialListsTimepoints(6,:)),AvgAT_blocked + T_blocked_CIHW95,'Color','m', 'LineWidth',0.5, 'LineStyle', '--');
	% %     plot((TrialListsTimepoints(6,:)),AvgAT_blocked - T_blocked_CIHW95,'Color','m', 'LineWidth',0.5, 'LineStyle', '--');
	
	hold on
	[Clusters, ListSignClusters]= tn_PlottingClusters(TrialListsScores, TrialListsTimepoints);
	
	
	
	if b==1
		ylabel('A selected Own Colour \newline Avg Difference between Gaze \newline and Touch/selected Target by A','FontSize',9)
		
	end
	if b==3
		xlabel('Time(secs) \newline B selected Own Colour','FontSize',9)
		ylabel('A selected Other"s Colour \newline  Avg Difference between Gaze \newline and Touch/selected Target by A','FontSize',9)
	end
	if b==4
		xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',9)
	end
	
	
	if a>=1 && a<=4
		write_out_figure(gcf, fullfile(saving_dir,'_AvgDiffbwGazeA_unblockedTouchBblockedTimeRed_ObjectiveRightAlignedtoAIFR.pdf'))
	end
	if a>=5 && a<=8
		write_out_figure(gcf, fullfile(saving_dir,'_AvgDiffbwGazeA_unblockedTouchBblockedTimeRed_ObjectiveLeftAlignedtoAIFR.pdf'))
	end
	
		
	
	
	% 	if ~(comparison_TargetOnset_AAunblockedVSAAblocked) && ~(comparison_AIFR_AAunblockedVSAAblocked)
	% 		if a>=1 && a<=4
	% 			write_out_figure(gcf, fullfile(saving_dir,'_AvgDiffbwGazeA_unblockedTouchAblockedTimeRed_ObjectiveRightAlignedtoAIFRwithTarget.pdf'))
	% 		end
	% 		if a>=5 && a<=8
	% 			write_out_figure(gcf, fullfile(saving_dir,'_AvgDiffbwGazeA_unblockedTouchAblockedTimeRed_ObjectiveLeftAlignedtoAIFRwithTarget.pdf'))
	% 		end
	% 	end
	
	
	
	
	
	%     if a>=9 && a<=12
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveRightBottomAlignedtoAIFR.jpg']))
	%
	%     end
	%     if a>=13 && a<=16
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftTopAlignedtoAIFR.jpg']))
	%
	%     end
	%     if a>=17 && a<=20
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftCenterAlignedtoAIFR.jpg']))
	%
	%     end
	%     if a>=21 && a<=24
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftBottomAlignedtoAIFR.jpg']))
	%     end
end

b=0;
return
end
 

function [Clusters, ListSignClusters]= tn_PlottingClusters(Scores, Timepoints)

if isempty(Scores)
	Clusters = [];
	ListSignClusters = [];
	return
end

Clusters= Scores.clusters;

NumClusters= length(Clusters);

for a1= 1:NumClusters
	if Scores.out.h{a1}==1
		ListSignClusters(a1)=a1;
	else
		ListSignClusters(a1)=NaN;
	end
end

%     TrialLists=SpStr;
%
%     if isempty(TrialLists)
%        continue;
%     end
%     LengthTrialLists=length(TrialLists);

for a=1:length(Clusters);
	ClusterSp=Clusters{a};
	
	if length(ClusterSp)>1
		
		ClusterTimes=Timepoints(1,(ClusterSp(1):ClusterSp(2)));
		
	else
		ClusterTimes=Timepoints(1,ClusterSp(1));
	end
	LengthClusterTimes=length(ClusterTimes);
	% x1=abc(1): 1: abc(2);
	PlotClusterTimes=zeros(LengthClusterTimes,1);
	PlotClusterTimes(PlotClusterTimes==0)=450;
	PlotClusterTimes=transpose(PlotClusterTimes);
	%     plot(x1,x);
	plot(ClusterTimes,PlotClusterTimes, 'LineWidth',7, 'Color', [0.5 0.5 0.5]);
	
end
hold on
if length(ListSignClusters(~isnan(ListSignClusters)))>0
	for a=1:length(ListSignClusters)
		
		SignClusterSp=ListSignClusters(a);
		if isnan(SignClusterSp)
			continue;
		end
		SignClusterSpStr=Clusters(a);
		if length(SignClusterSpStr{1})>1
			
			SignClusterTimes=Timepoints(1,(SignClusterSpStr{1}(1):SignClusterSpStr{1}(2)));
			
		else
			SignClusterTimes=Timepoints(1,SignClusterSp(1));
		end
		SignLengthClusterTimes=length(SignClusterTimes);
		% x1=abc(1): 1: abc(2);
		PlotSignClusterTimes=zeros(SignLengthClusterTimes,1);
		PlotSignClusterTimes(PlotSignClusterTimes==0)=500;
		PlotSignClusterTimes=transpose(PlotSignClusterTimes);
		%     plot(x1,x);
		plot(SignClusterTimes,PlotSignClusterTimes, 'LineWidth',7, 'Color', 'k');
		
		
	end
end
% for a=1:numel(ListSignClusters);
%     ClusterSp=Clusters{a};
%     ClusterTimes=Timepoints(1,(ClusterSp(1):ClusterSp(2)));
%     LengthClusterTimes=length(ClusterTimes)
%
% % x1=abc(1): 1: abc(2);
%     PlotClusterTimes=zeros(LengthClusterTimes,1);
%     PlotClusterTimes(PlotClusterTimes==0)=300;
%     PlotClusterTimes=transpose(PlotClusterTimes);
%     plot((ClusterTimes,PlotClusterTimes, 'LineWidth',7, 'Color', 'k');
% end
xlim([-0.2 0.9]);
ylim([0 500]);

return
end



function [AClosertoZero, BClosertoZero] = tn_ClosertoZero (SampleA, SampleB, Timepoints)
AClosertoZero = find(abs(SampleA(1,:))< abs(SampleB(1,:)));
BClosertoZero = find(abs(SampleA(1,:))>=abs(SampleB(1,:)));
fullLength = length(AClosertoZero);
AClosertoZeroTimes = Timepoints(1, AClosertoZero);
ClosertoZeroY = zeros(fullLength,1);
ClosertoZeroY(ClosertoZeroY==0) = 0;
ClosertoZeroY = transpose(ClosertoZeroY);
plot(AClosertoZeroTimes,ClosertoZeroY,'.', 'Color','r');
fullLength = length(BClosertoZero);
BClosertoZeroTimes = Timepoints(1, BClosertoZero);
ClosertoZeroY = zeros(fullLength,1);
ClosertoZeroY(ClosertoZeroY==0) = 0;
ClosertoZeroY = transpose(ClosertoZeroY);
plot(BClosertoZeroTimes,ClosertoZeroY,'.', 'Color','b');

end
function [AClosertoZero, BClosertoZero]= tn_ClosertoZerowithTarget (SampleA, SampleB,SampleT_unblocked,SampleT_blocked, Timepoints)
AClosertoZero = find((abs(SampleA(1,:))< abs(SampleB(1,:))) &(abs(SampleA(1,:))< abs(SampleT_unblocked(1,:))));
BClosertoZero = find((abs(SampleB(1,:))<=abs(SampleA(1,:))) & ((abs(SampleB(1,:))< abs(SampleT_blocked(1,:)))));
T_unblockedClosertoZero = find((abs(SampleT_unblocked(1,:))<abs(SampleA(1,:))) & ((abs(SampleT_unblocked(1,:))<=abs(SampleB(1,:)))));
T_blockedClosertoZero = find((abs(SampleT_blocked(1,:))<abs(SampleA(1,:))) & ((abs(SampleT_blocked(1,:))<=abs(SampleB(1,:)))));

fullLength = length(AClosertoZero);
AClosertoZeroTimes = Timepoints(6, AClosertoZero);
ClosertoZeroY = zeros(fullLength,1);
ClosertoZeroY(ClosertoZeroY==0) = 280;
ClosertoZeroY = transpose(ClosertoZeroY);
plot(AClosertoZeroTimes,ClosertoZeroY,'.', 'Color','r');

fullLength = length(BClosertoZero);
BClosertoZeroTimes = Timepoints(6, BClosertoZero);
ClosertoZeroY = zeros(fullLength,1);
ClosertoZeroY(ClosertoZeroY==0) = 280;
ClosertoZeroY = transpose(ClosertoZeroY);
plot(BClosertoZeroTimes,ClosertoZeroY,'.', 'Color','b');

fullLength = length(T_unblockedClosertoZero);
TunblockedClosertoZeroTimes = Timepoints(6, T_unblockedClosertoZero);
ClosertoZeroY = zeros(fullLength,1);
ClosertoZeroY(ClosertoZeroY==0)=280;
ClosertoZeroY = transpose(ClosertoZeroY);
plot(TunblockedClosertoZeroTimes,ClosertoZeroY,'.', 'Color','k');

% fullLength = length(T_blockedClosertoZero);
% TblockedClosertoZeroTimes = Timepoints(6, T_blockedClosertoZero);
% ClosertoZeroY = zeros(fullLength,1);
% ClosertoZeroY(ClosertoZeroY==0)=280;
% ClosertoZeroY = transpose(ClosertoZeroY);
% plot(TblockedClosertoZeroTimes,ClosertoZeroY,'.', 'Color','m');
end