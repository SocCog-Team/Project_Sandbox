function [scores, FullStructure] = rn_StructureDataforPermTest_B(FullStructure_unblocked, FullStructure_blocked)
%%For permutation testing of the whole session
fieldnames_unblocked_B = fieldnames(FullStructure_unblocked.B);
fieldnames_blocked_B = fieldnames(FullStructure_blocked.B);

for a = 1 : 8
    disp(['Processing condition: ', fieldnames_unblocked_B{a}]);
	cur_fieldnames_unblocked_B = fieldnames_unblocked_B{a};
	cur_fieldnames_blocked_B = fieldnames_blocked_B{a};

	TrialLists_unblocked_B = FullStructure_unblocked.B.(cur_fieldnames_unblocked_B);
	TrialLists_blocked_B = FullStructure_blocked.B.(cur_fieldnames_blocked_B);
	TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_B);
	
	
	tmp_scores = [];
	%scores(a) = fn_modified_MS_t_testing(TrialLists_unblocked_AA, TrialLists_blocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	tmp_scores = fn_modified_MS_t_testing(TrialLists_unblocked_B, TrialLists_blocked_B, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	
	scores{a} = tmp_scores;
	%FullStructure(a).PermScores = scores(a);
	FullStructure(a).PermScores = tmp_scores;
end
end