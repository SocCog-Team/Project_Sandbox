function [scores, FullStructure] = rn_StructureDataforPermTest_differentcondition(FullStructure_unblocked)
%%For permutation testing of the whole session

fieldnames_unblocked_A = fieldnames(FullStructure_unblocked.A);


for a = 1 : 8
		disp(['Processing condition: ', fieldnames_unblocked_A{a}]);
		cur_fieldnames_unblocked_A = fieldnames_unblocked_A{a};
		if (a==1) || (a==3) || (a==5) || (a==7)
			cur_fieldnames_unblocked_A_newconditon = fieldnames_unblocked_A{a+1};
		else
			continue
		end
		
		TrialLists_unblocked_A = FullStructure_unblocked.A.(cur_fieldnames_unblocked_A);
		tmp_TrialLists_unblocked_A = FullStructure_unblocked.A.(cur_fieldnames_unblocked_A_newconditon);
		TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_A);
		
		
		tmp_scores = [];
		%scores(a) = fn_modified_MS_t_testing(TrialLists_unblocked_AA, TrialLists_blocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
		tmp_scores = fn_modified_MS_t_testing(TrialLists_unblocked_A, tmp_TrialLists_unblocked_A, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
		
		scores{a} = tmp_scores;
		%FullStructure(a).PermScores = scores(a);
		FullStructure(a).PermScores = tmp_scores;
end
