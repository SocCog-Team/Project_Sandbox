function [scores, FullStructure]=tn_StructureDataforPermTest(FullStructure)
%%For permutation testing of the whole session


last_a = 8; % 1-8

for a = 1 : last_a
    % early_out
    
    disp(['Processing condition: ', num2str(a)]);
    TrialListsAA = FullStructure(a).AA;
    TrialListsAB = FullStructure(a).AB;
    TrialListsTimepoints = FullStructure(a).Timepoints;
    
%     [keys]=TrialListsTimepoints;
    [scores(a)] = tn_modified_MS_t_testing(TrialListsAA, TrialListsAB, TrialListsTimepoints);
% %     [keys, scores]= tn_StructureDatatoRunMS_permtest(DistGazeATouchA, DistGazeATouchB, Timepoints);
%b=a
    FullStructure(a).PermScores = scores(a);
end

end