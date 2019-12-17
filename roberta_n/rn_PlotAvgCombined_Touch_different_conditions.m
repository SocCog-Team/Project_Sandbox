function [] = rn_PlotAvgCombined_Touch_different_conditions (FullStructure, FullStructure_unblocked,FullStructure_blocked, saving_dir)
b = 0;
TrialNumStr = 'N: ';

fieldnames_unblocked_A = fieldnames(FullStructure_unblocked.A);
fieldnames_unblocked_A = fieldnames(FullStructure_unblocked.A);

for a = 1 
	cur_fieldnames_unblocked_A = fieldnames_unblocked_A{a};
	cur_fieldnames_unblocked_A_newcondition = fieldnames_unblocked_A{a+1};
	
	TrialLists_unblocked_A = FullStructure_unblocked.A.(cur_fieldnames_unblocked_A);
	tmp_TrialLists_unblocked_A = FullStructure_unblocked.A.(cur_fieldnames_unblocked_A_newcondition);
	TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_A);
	TrialListsScores = FullStructure(a).PermScores;
	
	% Names=fieldnames(SampleA);
	% b=0;
	
	% for a= 1:length(Names)
	%     Sp=Names(a);
	%     SpSampleA=SampleA.(Sp{1});
	%     SpSampleB=SampleB.(Sp{1});
	%     SpTimepoints=Timepoints.(Sp{1});
	% %     SpScores=Scores.(Sp{1});
	%     SpBIFRAlignedAIFR=AIFRsEpoch.(Sp{1});
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
	
	AvgA_unblocked = mean(TrialLists_unblocked_A,1,'omitnan');
	STD_A_unblocked = std(TrialLists_unblocked_A, 'omitnan');
	SEM_A_unblocked = std(TrialLists_unblocked_A , 'omitnan') / size(TrialLists_unblocked_A, 1);
	A_unblocked_isNotNaN_array = ~isnan(TrialLists_unblocked_A);
	A_unblocked_N_per_bin_list = sum(A_unblocked_isNotNaN_array, 1);
	[A_unblocked_CIHW95] = calc_cihw(STD_A_unblocked, A_unblocked_N_per_bin_list, 0.05);
	%   [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
	A_unblocked_CIHW95(A_unblocked_CIHW95 == 0) = NaN;
	
	tmp_AvgA_unblocked = mean(tmp_TrialLists_unblocked_A, 1, 'omitnan');
	tmp_STD_A_unblocked = std(tmp_TrialLists_unblocked_A, 'omitnan');
	tmp_SEM_A_unblocked = std(tmp_TrialLists_unblocked_A, 'omitnan') / size(tmp_TrialLists_unblocked_A, 1);
	tmp_A_unblocked_isNotNaN_array = ~isnan(tmp_TrialLists_unblocked_A);
	tmp_A_unblocked_N_per_bin_list = sum(tmp_A_unblocked_isNotNaN_array, 1);
	[tmp_A_unblocked_CIHW95] = calc_cihw(tmp_STD_A_unblocked,tmp_A_unblocked_N_per_bin_list, 0.05);
	%   [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
	tmp_A_unblocked_CIHW95(tmp_A_unblocked_CIHW95 == 0) = NaN;
	
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
% 	subplot(2,2,b);
	
	% 	if a==1
	% 		annotation('textbox',[.5 .8 .9 .2],'String','Trials with red on objective right','EdgeColor','none')
	%
	% 	end
	% 	if a==5
	% 		annotation('textbox',[.5 .8 .9 .2],'String','Trials with red on objectiveleft','EdgeColor','none')
	% 	end
	str_unblocked = strcat(TrialNumStr, num2str(size((TrialLists_unblocked_A),1)));
	str_blocked = strcat(TrialNumStr, num2str(size((tmp_TrialLists_unblocked_A),1)));
	
	complete_str = strcat ('A-unblocked: ', str_unblocked, ' A-blocked: ', str_blocked)
	title (str_unblocked);
	
	if b==1
		strCond ='A-Own/B-Own';
		title({strCond,...
			str_unblocked})
		ax = gca;
		ax.TitleFontSizeMultiplier = 1;
	end
	if b==2
		strCond ='A-Own/B-Other';
		title({strCond,...
			str_unblocked})
		ax = gca;
		ax.TitleFontSizeMultiplier = 1;
	end
	if b==3
		strCond ='A-Other/B-Own';
		title({strCond,...
			str_unblocked})
		ax = gca;
		ax.TitleFontSizeMultiplier = 1;
	end
	if b==4
		strCond ='A-Other/B-Other';
		title({strCond,...
			str_unblocked})
		ax = gca;
		ax.TitleFontSizeMultiplier = 1;
	end
	
	xlim([-0.2 0.9]);
	ylim([650 1250]);
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
	[AClosertoZero BClosertoZero] = tn_ClosertoZero(AvgA_unblocked,tmp_AvgA_unblocked, TrialListsTimepoints);
	%      hold on
	% TO DO : try to understand
	%     [AClosertoZero BClosertoZero] = tn_ClosertoZerowithTarget(AvgAA_unblocked,AvgAA_blocked,AvgAT_unblocked,AvgAT_blocked,TrialListsTimepoints);
	hold on
	plot((TrialListsTimepoints(1,:)),AvgA_unblocked,'Color','r', 'LineWidth',2);
	hold on
	plot((TrialListsTimepoints(1,:)),(AvgA_unblocked+SEM_A_unblocked),'Color','r', 'LineWidth',0.5);
	plot((TrialListsTimepoints(1,:)),AvgA_unblocked-SEM_A_unblocked,'Color','r', 'LineWidth',0.5);
	hold on
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked,'Color','b', 'LineWidth',2);
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked + tmp_SEM_A_unblocked,'Color','b', 'LineWidth',0.5);
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked - tmp_SEM_A_unblocked,'Color','b', 'LineWidth',0.5);
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
	plot((TrialListsTimepoints(1,:)),AvgA_unblocked + A_unblocked_CIHW95,'Color','r', 'LineWidth',0.5, 'LineStyle', '--');
	plot((TrialListsTimepoints(1,:)),AvgA_unblocked - A_unblocked_CIHW95,'Color','r', 'LineWidth',0.5, 'LineStyle', '--');
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked + tmp_A_unblocked_CIHW95,'Color','b', 'LineWidth',0.5, 'LineStyle', '--');
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked - tmp_A_unblocked_CIHW95,'Color','b', 'LineWidth',0.5, 'LineStyle', '--');
	%     plot((TrialListsTimepoints(6,:)),AvgAT_unblocked + T_unblocked_CIHW95,'Color','k', 'LineWidth',0.5, 'LineStyle', '--');
	%     plot((TrialListsTimepoints(6,:)),AvgAT_unblocked - T_unblocked_CIHW95,'Color','k', 'LineWidth',0.5, 'LineStyle', '--');
	% %     plot((TrialListsTimepoints(6,:)),AvgAT_blocked + T_blocked_CIHW95,'Color','m', 'LineWidth',0.5, 'LineStyle', '--');
	% %     plot((TrialListsTimepoints(6,:)),AvgAT_blocked - T_blocked_CIHW95,'Color','m', 'LineWidth',0.5, 'LineStyle', '--');
	
	hold on
	[Clusters, ListSignClusters]= tn_PlottingClusters(TrialListsScores, TrialListsTimepoints);
	
	
	
	if b==1
		ylabel('Avg Touch A unblocked and Touch A unblocked','FontSize',9)
		xlabel('Time(secs)','FontSize',9)
	end
	
	
	if a == 1
		write_out_figure(gcf, fullfile(saving_dir,'_AvgTouchA_unblockedVSTouchAunblockedTimeRed_ObjectiveRightAlignedtoTargetOnset.pdf'))
	end
	
	
	
	% 	if ~(comparison_TargetOnset_AAunblockedVSAAblocked) && ~(comparison_BIFR_AAunblockedVSAAblocked)
	% 		if a>=1 && a<=4
	% 			write_out_figure(gcf, fullfile(saving_dir,'_AvgDiffbwGazeA_unblockedTouchAblockedTimeRed_ObjectiveRightAlignedtoAIFRwithTarget.pdf'))
	% 		end
	% 		if a>=5 && a<=8
	% 			write_out_figure(gcf, fullfile(saving_dir,'_AvgDiffbwGazeA_unblockedTouchAblockedTimeRed_ObjectiveLeftAlignedtoAIFRwithTarget.pdf'))
	% 		end
	% 	end
	
	
	
	
	
	%     if a>=9 && a<=12
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveRightBottomAlignedtoBIFR.jpg']))
	%
	%     end
	%     if a>=13 && a<=16
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftTopAlignedtoBIFR.jpg']))
	%
	%     end
	%     if a>=17 && a<=20
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftCenterAlignedtoBIFR.jpg']))
	%
	%     end
	%     if a>=21 && a<=24
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftBottomAlignedtoBIFR.jpg']))
	%     end
	
end

b=0;

for c = 5 
	cur_fieldnames_unblocked_A = fieldnames_unblocked_A{c};
	cur_fieldnames_unblocked_A_newcondition = fieldnames_unblocked_A{c+1};
	
	TrialLists_unblocked_A = FullStructure_unblocked.A.(cur_fieldnames_unblocked_A);
	tmp_TrialLists_unblocked_A = FullStructure_unblocked.A.(cur_fieldnames_unblocked_A_newcondition);
	TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_A);
	TrialListsScores = FullStructure(c).PermScores;
	
	% Names=fieldnames(SampleA);
	% b=0;
	
	% for a= 1:length(Names)
	%     Sp=Names(a);
	%     SpSampleA=SampleA.(Sp{1});
	%     SpSampleB=SampleB.(Sp{1});
	%     SpTimepoints=Timepoints.(Sp{1});
	% %     SpScores=Scores.(Sp{1});
	%     SpBIFRAlignedAIFR=AIFRsEpoch.(Sp{1});
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
	
	AvgA_unblocked = mean(TrialLists_unblocked_A,1,'omitnan');
	STD_A_unblocked = std(TrialLists_unblocked_A, 'omitnan');
	SEM_A_unblocked = std(TrialLists_unblocked_A , 'omitnan') / size(TrialLists_unblocked_A, 1);
	A_unblocked_isNotNaN_array = ~isnan(TrialLists_unblocked_A);
	A_unblocked_N_per_bin_list = sum(A_unblocked_isNotNaN_array, 1);
	[A_unblocked_CIHW95] = calc_cihw(STD_A_unblocked, A_unblocked_N_per_bin_list, 0.05);
	%   [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
	A_unblocked_CIHW95(A_unblocked_CIHW95 == 0) = NaN;
	
	tmp_AvgA_unblocked = mean(tmp_TrialLists_unblocked_A, 1, 'omitnan');
	tmp_STD_A_unblocked = std(tmp_TrialLists_unblocked_A, 'omitnan');
	tmp_SEM_A_unblocked = std(tmp_TrialLists_unblocked_A, 'omitnan') / size(tmp_TrialLists_unblocked_A, 1);
	tmp_A_unblocked_isNotNaN_array = ~isnan(tmp_TrialLists_unblocked_A);
	tmp_A_unblocked_N_per_bin_list = sum(tmp_A_unblocked_isNotNaN_array, 1);
	[tmp_A_unblocked_CIHW95] = calc_cihw(tmp_STD_A_unblocked,tmp_A_unblocked_N_per_bin_list, 0.05);
	%   [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
	tmp_A_unblocked_CIHW95(tmp_A_unblocked_CIHW95 == 0) = NaN;
	
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
% 	subplot(2,2,b);
	
	% 	if a==1
	% 		annotation('textbox',[.5 .8 .9 .2],'String','Trials with red on objective right','EdgeColor','none')
	%
	% 	end
	% 	if a==5
	% 		annotation('textbox',[.5 .8 .9 .2],'String','Trials with red on objectiveleft','EdgeColor','none')
	% 	end
	str_unblocked = strcat(TrialNumStr, num2str(size((TrialLists_unblocked_A),1)));
	str_blocked = strcat(TrialNumStr, num2str(size((tmp_TrialLists_unblocked_A),1)));
	
	complete_str = strcat ('A-unblocked: ', str_unblocked, ' A-blocked: ', str_blocked)
	title (str_unblocked);
	
	if b==1
		strCond ='A-Own/B-Own';
		title({strCond,...
			str_unblocked})
		ax = gca;
		ax.TitleFontSizeMultiplier = 1;
	end
	if b==2
		strCond ='A-Own/B-Other';
		title({strCond,...
			str_unblocked})
		ax = gca;
		ax.TitleFontSizeMultiplier = 1;
	end
	if b==3
		strCond ='A-Other/B-Own';
		title({strCond,...
			str_unblocked})
		ax = gca;
		ax.TitleFontSizeMultiplier = 1;
	end
	if b==4
		strCond ='A-Other/B-Other';
		title({strCond,...
			str_unblocked})
		ax = gca;
		ax.TitleFontSizeMultiplier = 1;
	end
	
	xlim([-0.2 0.9]);
	ylim([650 1250]);
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
	[AClosertoZero BClosertoZero] = tn_ClosertoZero(AvgA_unblocked,tmp_AvgA_unblocked, TrialListsTimepoints);
	%      hold on
	% TO DO : try to understand
	%     [AClosertoZero BClosertoZero] = tn_ClosertoZerowithTarget(AvgAA_unblocked,AvgAA_blocked,AvgAT_unblocked,AvgAT_blocked,TrialListsTimepoints);
	hold on
	plot((TrialListsTimepoints(1,:)),AvgA_unblocked,'Color','r', 'LineWidth',2);
	hold on
	plot((TrialListsTimepoints(1,:)),(AvgA_unblocked+SEM_A_unblocked),'Color','r', 'LineWidth',0.5);
	plot((TrialListsTimepoints(1,:)),AvgA_unblocked-SEM_A_unblocked,'Color','r', 'LineWidth',0.5);
	hold on
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked,'Color','b', 'LineWidth',2);
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked + tmp_SEM_A_unblocked,'Color','b', 'LineWidth',0.5);
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked - tmp_SEM_A_unblocked,'Color','b', 'LineWidth',0.5);
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
	plot((TrialListsTimepoints(1,:)),AvgA_unblocked + A_unblocked_CIHW95,'Color','r', 'LineWidth',0.5, 'LineStyle', '--');
	plot((TrialListsTimepoints(1,:)),AvgA_unblocked - A_unblocked_CIHW95,'Color','r', 'LineWidth',0.5, 'LineStyle', '--');
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked + tmp_A_unblocked_CIHW95,'Color','b', 'LineWidth',0.5, 'LineStyle', '--');
	plot((TrialListsTimepoints(1,:)),tmp_AvgA_unblocked - tmp_A_unblocked_CIHW95,'Color','b', 'LineWidth',0.5, 'LineStyle', '--');
	%     plot((TrialListsTimepoints(6,:)),AvgAT_unblocked + T_unblocked_CIHW95,'Color','k', 'LineWidth',0.5, 'LineStyle', '--');
	%     plot((TrialListsTimepoints(6,:)),AvgAT_unblocked - T_unblocked_CIHW95,'Color','k', 'LineWidth',0.5, 'LineStyle', '--');
	% %     plot((TrialListsTimepoints(6,:)),AvgAT_blocked + T_blocked_CIHW95,'Color','m', 'LineWidth',0.5, 'LineStyle', '--');
	% %     plot((TrialListsTimepoints(6,:)),AvgAT_blocked - T_blocked_CIHW95,'Color','m', 'LineWidth',0.5, 'LineStyle', '--');
	
	hold on
	[Clusters, ListSignClusters]= tn_PlottingClusters(TrialListsScores, TrialListsTimepoints);
	
	
	
	if b==1
		ylabel('Avg Touch A unblocked and Touch A unblocked','FontSize',9)
		
	end
	if b==3
		xlabel('Time(secs)','FontSize', 9)
		ylabel('Avg Touch A unblocked and Touch A unblocked','FontSize',9)
	end
	if b==4
		xlabel('Time(secs)','FontSize',9)
	end
	

	if c == 5
		write_out_figure(gcf, fullfile(saving_dir,'_AvgTouchA_unblockedVSTouchAunblockedTimeRed_ObjectiveLeftAlignedtoTargetOnset.pdf'))
	end
	
	
	% 	if ~(comparison_TargetOnset_AAunblockedVSAAblocked) && ~(comparison_BIFR_AAunblockedVSAAblocked)
	% 		if a>=1 && a<=4
	% 			write_out_figure(gcf, fullfile(saving_dir,'_AvgDiffbwGazeA_unblockedTouchAblockedTimeRed_ObjectiveRightAlignedtoAIFRwithTarget.pdf'))
	% 		end
	% 		if a>=5 && a<=8
	% 			write_out_figure(gcf, fullfile(saving_dir,'_AvgDiffbwGazeA_unblockedTouchAblockedTimeRed_ObjectiveLeftAlignedtoAIFRwithTarget.pdf'))
	% 		end
	% 	end
	
	
	
	
	
	%     if a>=9 && a<=12
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveRightBottomAlignedtoBIFR.jpg']))
	%
	%     end
	%     if a>=13 && a<=16
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftTopAlignedtoBIFR.jpg']))
	%
	%     end
	%     if a>=17 && a<=20
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftCenterAlignedtoBIFR.jpg']))
	%
	%     end
	%     if a>=21 && a<=24
	%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftBottomAlignedtoBIFR.jpg']))
	%     end
	
end



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
	PlotClusterTimes(PlotClusterTimes==0)=1150;
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
		PlotSignClusterTimes(PlotSignClusterTimes==0)=1200;
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
ylim([650 1250]);

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
