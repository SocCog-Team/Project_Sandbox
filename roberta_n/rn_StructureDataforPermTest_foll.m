function [scores, FullStructure] = rn_StructureDataforPermTest_foll(FullStructure_unblocked_pre, FullStructure_unblocked_first)
%%For permutation testing of the whole session

FullStructure_unblocked_pre_A = fieldnames(FullStructure_unblocked_pre.A);
FullStructure_unblocked_first_A = fieldnames(FullStructure_unblocked_first.A);

for a = 1 : 8
	disp(['Processing condition: ', FullStructure_unblocked_pre_A{a}]);
	cur_fieldnames_unblocked_pre_A = FullStructure_unblocked_pre_A{a};
	
	if (a==1) || (a==3) || (a==5) || (a==7)
		cur_fieldnames_unblocked_first_A = FullStructure_unblocked_first_A{a+1};
	else
		cur_fieldnames_unblocked_first_A = FullStructure_unblocked_first_A{a};
		
	end
	
	
	TrialLists_unblocked_A = FullStructure_unblocked_pre.A.(cur_fieldnames_unblocked_pre_A);
	tmp_TrialLists_unblocked_A = FullStructure_unblocked_first.A.(cur_fieldnames_unblocked_first_A);
	TrialListsTimepoints = FullStructure_unblocked_pre.timepoints.TrialWise.(cur_fieldnames_unblocked_pre_A);
	
	
	tmp_scores = [];
	%scores(a) = fn_modified_MS_t_testing(TrialLists_unblocked_AA, TrialLists_blocked_AA, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	tmp_scores = fn_modified_MS_t_testing(TrialLists_unblocked_A, tmp_TrialLists_unblocked_A, TrialListsTimepoints, 'ttest2', 1000, 0.005, 1.96);
	
	scores{a} = tmp_scores;
	%FullStructure(a).PermScores = scores(a);
	FullStructure(a).PermScores = tmp_scores;
end