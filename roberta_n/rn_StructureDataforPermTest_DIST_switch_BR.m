function [scores, FullStructure] = rn_StructureDataforPermTest_DIST_switch_BR(FullStructure_unblocked, FullStructure_unblocked_pre, FullStructure_unblocked_first)
%%For permutation testing of the whole session

FullStructure_unblocked_pre_AA = fieldnames(FullStructure_unblocked_pre.AA);
FullStructure_unblocked_first_AA = fieldnames(FullStructure_unblocked_first.AA);



for a = 1 : 8
   disp(['Processing condition: ', FullStructure_unblocked_pre_AA{a}]);
	cur_fieldnames_unblocked_pre_AA = FullStructure_unblocked_pre_AA{a};
	
    
	if (a==2) ||(a==6)
		cur_fieldnames_unblocked_AA_newconditon = FullStructure_unblocked_first_AA{a+2};
	else
		cur_fieldnames_unblocked_AA_newconditon = FullStructure_unblocked_first_AA{a};
		
	end
	
    TrialLists_unblocked_AA = FullStructure_unblocked_pre.AA.(cur_fieldnames_unblocked_AA_newconditon);
	tmp_TrialLists_unblocked_AA = FullStructure_unblocked_first.AA.(cur_fieldnames_unblocked_pre_AA);
	TrialListsTimepoints = FullStructure_unblocked.timepoints.TrialWise.(cur_fieldnames_unblocked_pre_AA);
	
	
	tmp_scores = [];
	%scores(a) = fn_modified_MS_t_testing(TrialLists_unblocked_AA, TrialLists_blocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	tmp_scores = fn_modified_MS_t_testing(TrialLists_unblocked_AA, tmp_TrialLists_unblocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	
	scores{a} = tmp_scores;
	%FullStructure(a).PermScores = scores(a);
	FullStructure(a).PermScores = tmp_scores;
end

end

