function [scores, FullStructure] = rn_StructureDataforPermTest_DIST_AB(FullStructure_unblocked, FullStructure_blocked)
%%For permutation testing of the whole session

fieldnames_unblocked_AB = fieldnames(FullStructure_unblocked.AB);
fieldnames_blocked_AB = fieldnames(FullStructure_blocked.AB);


for a = 1 : 8
    disp(['Processing condition: ', fieldnames_unblocked_AB{a}]);
	cur_fieldnames_unblocked_AB = fieldnames_unblocked_AB{a};
	cur_fieldnames_blocked_AB = fieldnames_blocked_AB{a};

	TrialLists_unblocked_AB = FullStructure_unblocked.AB.(cur_fieldnames_unblocked_AB);
	TrialLists_blocked_AB = FullStructure_blocked.AB.(cur_fieldnames_blocked_AB);
	TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_AB);
	
	
	tmp_scores = [];
	%scores(a) = fn_modified_MS_t_testing(TrialLists_unblocked_AA, TrialLists_blocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	tmp_scores = fn_modified_MS_t_testing(TrialLists_unblocked_AB, TrialLists_blocked_AB, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	
	scores{a} = tmp_scores;
	%FullStructure(a).PermScores = scores(a);
	FullStructure(a).PermScores = tmp_scores;
end

end
