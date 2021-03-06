function [scores, FullStructure] = rn_StructureDataforPermTest_DIST(FullStructure_unblocked, FullStructure_blocked)
%%For permutation testing of the whole session

fieldnames_unblocked_AA = fieldnames(FullStructure_unblocked.AA);
fieldnames_blocked_AA = fieldnames(FullStructure_blocked.AA);


for a = 1 : 8
    disp(['Processing condition: ', fieldnames_unblocked_AA{a}]);
	cur_fieldnames_unblocked_AA = fieldnames_unblocked_AA{a};
	cur_fieldnames_blocked_AA = fieldnames_blocked_AA{a};

	TrialLists_unblocked_AA = FullStructure_unblocked.AA.(cur_fieldnames_unblocked_AA);
	TrialLists_blocked_AA = FullStructure_blocked.AA.(cur_fieldnames_blocked_AA);
	TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_AA);
	
	
	tmp_scores = [];
	%scores(a) = fn_modified_MS_t_testing(TrialLists_unblocked_AA, TrialLists_blocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	tmp_scores = fn_modified_MS_t_testing(TrialLists_unblocked_AA, TrialLists_blocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	
	scores{a} = tmp_scores;
	%FullStructure(a).PermScores = scores(a);
	FullStructure(a).PermScores = tmp_scores;
end

end


