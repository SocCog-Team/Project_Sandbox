function [scores, FullStructure] = rn_StructureDataforPermTest_differentcondition_B(FullStructure_unblocked)
%%For permutation testing of the whole session

fieldnames_unblocked_B = fieldnames(FullStructure_unblocked.B);


for a = 1 : 8
		disp(['Processing condition: ', fieldnames_unblocked_B{a}]);
		cur_fieldnames_unblocked_B = fieldnames_unblocked_B{a};
		if (a==1) || (a==3) || (a==5) || (a==7)
			cur_fieldnames_unblocked_B_newconditon = fieldnames_unblocked_B{a+1};
		else
			continue
		end
		
		TrialLists_unblocked_B = FullStructure_unblocked.B.(cur_fieldnames_unblocked_B);
		tmp_TrialLists_unblocked_B = FullStructure_unblocked.B.(cur_fieldnames_unblocked_B_newconditon);
		TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_B);
		
		
		tmp_scores = [];
		%scores(a) = fn_modified_MS_t_testing(TrialLists_unblocked_BA, TrialLists_blocked_BA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
		tmp_scores = fn_modified_MS_t_testing(TrialLists_unblocked_B, tmp_TrialLists_unblocked_B, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
		
		scores{a} = tmp_scores;
		%FullStructure(a).PermScores = scores(a);
		FullStructure(a).PermScores = tmp_scores;
end
