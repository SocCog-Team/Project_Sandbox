function [scores, FullStructure] = rn_StructureDataforPermTest_differentcondition_blocked(FullStructure_blocked)
%%For permutation testing of the whole session

fieldnames_blocked_A = fieldnames(FullStructure_blocked.A);


for a = 1 : 8
		disp(['Processing condition: ', fieldnames_blocked_A{a}]);
		cur_fieldnames_blocked_A = fieldnames_blocked_A{a};
		if (a==1) || (a==3) || (a==5) || (a==7)
			cur_fieldnames_blocked_A_newconditon = fieldnames_blocked_A{a+1};
		else
			continue
		end
		
		TrialLists_blocked_A = FullStructure_blocked.A.(cur_fieldnames_blocked_A);
		tmp_TrialLists_blocked_A = FullStructure_blocked.A.(cur_fieldnames_blocked_A_newconditon);
		TrialListsTimepoints = FullStructure_blocked.timepoints.TrialWise.(cur_fieldnames_blocked_A);
		
		
		tmp_scores = [];
		%scores(a) = fn_modified_MS_t_testing(TrialLists_blocked_AA, TrialLists_blocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
		tmp_scores = fn_modified_MS_t_testing(TrialLists_blocked_A, tmp_TrialLists_blocked_A, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
		
		scores{a} = tmp_scores;
		%FullStructure(a).PermScores = scores(a);
		FullStructure(a).PermScores = tmp_scores;
end