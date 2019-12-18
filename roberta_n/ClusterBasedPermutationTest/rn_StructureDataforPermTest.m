function [scores, FullStructure] = rn_StructureDataforPermTest(FullStructure_unblocked, FullStructure_blocked)
%%For permutation testing of the whole session
fieldnames_unblocked_A = fieldnames(FullStructure_unblocked.A);
fieldnames_blocked_A = fieldnames(FullStructure_blocked.A);

for a = 1 : 8
    disp(['Processing condition: ', fieldnames_unblocked_A{a}]);
	cur_fieldnames_unblocked_A = fieldnames_unblocked_A{a};
	cur_fieldnames_blocked_A = fieldnames_blocked_A{a};

	TrialLists_unblocked_A = FullStructure_unblocked.A.(cur_fieldnames_unblocked_A);
	TrialLists_blocked_A = FullStructure_blocked.A.(cur_fieldnames_blocked_A);
	TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_A);
	
	
	tmp_scores = [];
	%scores(a) = fn_modified_MS_t_testing(TrialLists_unblocked_AA, TrialLists_blocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	tmp_scores = fn_modified_MS_t_testing(TrialLists_unblocked_A, TrialLists_blocked_A, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	
	scores{a} = tmp_scores;
	%FullStructure(a).PermScores = scores(a);
	FullStructure(a).PermScores = tmp_scores;
end
end


