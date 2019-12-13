function [ModifiedTrialSets]= rn_segregateTrialData_monkey_pair( maintask_datastruct)
addpath('/Users/rnocerino/DPZ/taskcontroller/CODE/Project_Sandbox/roberta_n');
[ModifiedTrialSets] = fnCollectTrialSets(maintask_datastruct.report_struct);  

%Joint successful trials- Trials which are jointly played, are
%non-instructed and both players are rewarded in it

ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial = ModifiedTrialSets.ByJointness.DualSubjectJointTrials;
LastJointTrial = length(ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial);
ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial(LastJointTrial) = NaN;
Joint_choicetargets = intersect(ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial, ModifiedTrialSets.ByChoices.NumChoices02);
bothrewarded = intersect(ModifiedTrialSets.ByOutcome.SideA.REWARD, ModifiedTrialSets.ByOutcome.SideB.REWARD);

SuccessfulChoiceTrials = intersect(Joint_choicetargets, bothrewarded);
SuccessfulChoiceTrialsBlocked = intersect (SuccessfulChoiceTrials,ModifiedTrialSets.ByVisibility.AB_invisible);  
SuccessfulChoiceTrialsUnblocked_idx = ~ismember(SuccessfulChoiceTrials, SuccessfulChoiceTrialsBlocked);
SuccessfulChoiceTrialsUnblocked = SuccessfulChoiceTrials(SuccessfulChoiceTrialsUnblocked_idx);

ModifiedTrialSets.SuccessfulChoiceTrials = SuccessfulChoiceTrials;
ModifiedTrialSets.SuccessfulChoiceTrialsBlocked = SuccessfulChoiceTrialsBlocked;
ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked = SuccessfulChoiceTrialsUnblocked;

% Both monkeys are active, but just one of them is playing 
% test for touching the initial target:
TmpJointTrialsA = find(maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.A_InitialFixationTouchTime_ms) > 0);
TmpJointTrialsB = find(maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.B_InitialFixationTouchTime_ms) > 0);
ModifiedTrialSets.ByJointness.SideA.SoloSubjectTrials = setdiff(TmpJointTrialsA, TmpJointTrialsB);
ModifiedTrialSets.ByJointness.SideB.SoloSubjectTrials = setdiff(TmpJointTrialsB, TmpJointTrialsA);

% test for touching the touch target :
TmpSoloTrialsA = setdiff(TmpJointTrialsA, TmpJointTrialsB);
TmpSoloTrialsB = setdiff(TmpJointTrialsB, TmpJointTrialsA);
ModifiedTrialSets.ByJointness.SideA.SoloSubjectTrials = intersect(ModifiedTrialSets.ByJointness.SideA.SoloSubjectTrials, TmpSoloTrialsA);
ModifiedTrialSets.ByJointness.SideB.SoloSubjectTrials = intersect(ModifiedTrialSets.ByJointness.SideB.SoloSubjectTrials, TmpSoloTrialsB);

% test for reward
TmpRewardAOutcomeIdx = find(strcmp('REWARD', maintask_datastruct.report_struct.unique_lists.A_OutcomeString));
if ~isempty(TmpRewardAOutcomeIdx)
	TmpJointTrialsA = find(maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.A_OutcomeString_idx) == TmpRewardAOutcomeIdx);
	TrialSets.ByJointness.DualSubjectJointTrials = intersect(ModifiedTrialSets.ByJointness.DualSubjectJointTrials, TmpJointTrialsA);
else
	TmpJointTrialsA = [];
end
TmpRewardBOutcomeIdx = find(strcmp('REWARD', maintask_datastruct.report_struct.unique_lists.B_OutcomeString));
if ~isempty(TmpRewardBOutcomeIdx)
	TmpJointTrialsB = find(maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.B_OutcomeString_idx) == TmpRewardBOutcomeIdx);
	TrialSets.ByJointness.DualSubjectJointTrials = intersect(ModifiedTrialSets.ByJointness.DualSubjectJointTrials, TmpJointTrialsB);
else
	TmpJointTrialsB = [];
end

TmpSoloTrialsA = setdiff(TmpJointTrialsA, TmpJointTrialsB);
TmpSoloTrialsB = setdiff(TmpJointTrialsB, TmpJointTrialsA);
TrialSets.ByJointness.SideA.SoloSubjectTrials = intersect(ModifiedTrialSets.ByJointness.SideA.SoloSubjectTrials, TmpSoloTrialsA);
TrialSets.ByJointness.SideB.SoloSubjectTrials = intersect(ModifiedTrialSets.ByJointness.SideB.SoloSubjectTrials, TmpSoloTrialsB);


% solo trials: two subjects present, single troials only one subject
% active/present
ModifiedTrialSets.ByJointness.SideA.SoloSubjectTrials = intersect(ModifiedTrialSets.ByJointness.SideA.SoloSubjectTrials, ModifiedTrialSets.ByActivity.SideA.DualSubjectTrials);
ModifiedTrialSets.ByJointness.SideB.SoloSubjectTrials = intersect(ModifiedTrialSets.ByJointness.SideB.SoloSubjectTrials, ModifiedTrialSets.ByActivity.SideB.DualSubjectTrials);

% joint trials are always for both sides
ModifiedTrialSets.ByJointness.SideA.DualSubjectJointTrials = ModifiedTrialSets.ByJointness.DualSubjectJointTrials;
ModifiedTrialSets.ByJointness.SideB.DualSubjectJointTrials = ModifiedTrialSets.ByJointness.DualSubjectJointTrials;

% what to do about the dual subject non-joint trials, with two subjects present and active, but only one working?
ModifiedTrialSets.ByJointness.DualSubjectSoloTrials = union(ModifiedTrialSets.ByJointness.SideA.SoloSubjectTrials, ModifiedTrialSets.ByJointness.SideB.SoloSubjectTrials);



trial_num = maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.TrialNumber);


% Segregation on the basis of Target Position-Colour and Side: Red on objective right or
% yellow on objective right
red_objright_idx= maintask_datastruct.report_struct.Stimuli.data(:,4)==1182 & maintask_datastruct.report_struct.Stimuli.data(:,3)==1; %Red on objective right
yellow_objright_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,4)==1182 & maintask_datastruct.report_struct.Stimuli.data(:,3)==2); %Blue on objective right

red_objright_trials = maintask_datastruct.report_struct.Stimuli.data(red_objright_idx,2);
yellow_objright_trials = maintask_datastruct.report_struct.Stimuli.data(yellow_objright_idx,2);

red_objright_trials_idx = ismember(trial_num, red_objright_trials);
red_objright_trials_idx = find (red_objright_trials_idx == 1);


yellow_objright_trials_idx = ismember(trial_num, yellow_objright_trials);
yellow_objright_trials_idx = find (yellow_objright_trials_idx == 1);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_All = intersect(red_objright_trials_idx,SuccessfulChoiceTrialsUnblocked);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_All = intersect(yellow_objright_trials_idx,SuccessfulChoiceTrialsUnblocked);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_blocked.All = intersect(red_objright_trials_idx,SuccessfulChoiceTrialsBlocked);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_blocked.All = intersect(yellow_objright_trials_idx,SuccessfulChoiceTrialsBlocked);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_unblocked.All = intersect(red_objright_trials_idx,SuccessfulChoiceTrialsUnblocked);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_unblocked.All = intersect(yellow_objright_trials_idx,SuccessfulChoiceTrialsUnblocked);



% Segregation on the basis of Target Height-Top,center, Bottom
top_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,11)==1 & maintask_datastruct.report_struct.Stimuli.data(:,5)==445); %Target in the top row
center_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,11)==1 & maintask_datastruct.report_struct.Stimuli.data(:,5)==500); %Target in the center row
bottom_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,11)==1 & maintask_datastruct.report_struct.Stimuli.data(:,5)==556); %Target in the bottom row

top_trials=maintask_datastruct.report_struct.Stimuli.data(top_idx,2);
center_trials=maintask_datastruct.report_struct.Stimuli.data(center_idx,2);
bottom_trials=maintask_datastruct.report_struct.Stimuli.data(bottom_idx,2);


top_trials_idx = ismember(trial_num, top_trials);
top_trials_idx = find (top_trials_idx == 1);

center_trials_idx = ismember(trial_num, center_trials);
center_trials_idx = find (center_trials_idx == 1);

bottom_trials_idx = ismember(trial_num, bottom_trials);
bottom_trials_idx = find (bottom_trials_idx == 1);

ModifiedTrialSets.ByTargetposition.ByHeight.Top=intersect(top_trials_idx,SuccessfulChoiceTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Center=intersect(center_trials_idx,SuccessfulChoiceTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Bottom=intersect(bottom_trials_idx,SuccessfulChoiceTrials);

%The 6 combinations of positions
%Successful trials
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_all = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_All, ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_all = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_All, ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_all = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_All, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_all = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_all = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_all = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
 
%Successful blocked trials
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_blocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_blocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_blocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);

%Successful unblocked trials 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_unblocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_unblocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_unblocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);



%By reward type
Reward_SideA1_idx=find(maintask_datastruct.report_struct.Reward.data(:,3)==1 & maintask_datastruct.report_struct.Reward.data(:,5)==1);
Reward_SideA2_idx=find(maintask_datastruct.report_struct.Reward.data(:,3)==1 & maintask_datastruct.report_struct.Reward.data(:,5)==2);
Reward_SideA3_idx=find(maintask_datastruct.report_struct.Reward.data(:,3)==1 & maintask_datastruct.report_struct.Reward.data(:,5)==3);
Reward_SideA4_idx=find(maintask_datastruct.report_struct.Reward.data(:,3)==1 & maintask_datastruct.report_struct.Reward.data(:,5)==4);
Reward_SideB1_idx=find(maintask_datastruct.report_struct.Reward.data(:,3)==2 & maintask_datastruct.report_struct.Reward.data(:,5)==1);
Reward_SideB2_idx=find(maintask_datastruct.report_struct.Reward.data(:,3)==2 & maintask_datastruct.report_struct.Reward.data(:,5)==2);
Reward_SideB3_idx=find(maintask_datastruct.report_struct.Reward.data(:,3)==2 & maintask_datastruct.report_struct.Reward.data(:,5)==3);
Reward_SideB4_idx=find(maintask_datastruct.report_struct.Reward.data(:,3)==2 & maintask_datastruct.report_struct.Reward.data(:,5)==4);

Reward_SideA1_Trials=maintask_datastruct.report_struct.Reward.data(Reward_SideA1_idx,2);
Reward_SideA2_Trials=maintask_datastruct.report_struct.Reward.data(Reward_SideA2_idx,2);
Reward_SideA3_Trials=maintask_datastruct.report_struct.Reward.data(Reward_SideA3_idx,2);
Reward_SideA4_Trials=maintask_datastruct.report_struct.Reward.data(Reward_SideA4_idx,2);
Reward_SideB1_Trials=maintask_datastruct.report_struct.Reward.data(Reward_SideB1_idx,2);
Reward_SideB2_Trials=maintask_datastruct.report_struct.Reward.data(Reward_SideB2_idx,2);
Reward_SideB3_Trials=maintask_datastruct.report_struct.Reward.data(Reward_SideB3_idx,2);
Reward_SideB4_Trials=maintask_datastruct.report_struct.Reward.data(Reward_SideB4_idx,2);

Type11 = intersect(Reward_SideA1_Trials,Reward_SideB1_Trials);
Type11_idx = ismember(trial_num, Type11);
Type11_idx = find (Type11_idx == 1);

Type22 = intersect(Reward_SideA2_Trials,Reward_SideB2_Trials);
Type22_idx = ismember(trial_num, Type22);
Type22_idx = find (Type22_idx == 1);

Type34 = intersect(Reward_SideA3_Trials,Reward_SideB4_Trials);
Type34_idx = ismember(trial_num, Type34);
Type34_idx = find (Type34_idx == 1);

Type43 = intersect(Reward_SideA4_Trials,Reward_SideB3_Trials);
Type43_idx = ismember(trial_num, Type43);
Type43_idx = find (Type43_idx == 1);


% %By colour selected
% ModifiedTrialSets.ByColourSelected.A.Red = union(ModifiedTrialSets.ByRewardType.Type22, ModifiedTrialSets.ByRewardType.Type43);
% ModifiedTrialSets.ByColourSelected.A.Yellow = union(ModifiedTrialSets.ByRewardType.Type11, ModifiedTrialSets.ByRewardType.Type34);
% ModifiedTrialSets.ByColourSelected.B.Red = union(ModifiedTrialSets.ByRewardType.Type11, ModifiedTrialSets.ByRewardType.Type43);
% ModifiedTrialSets.ByColourSelected.B.Yellow = union(ModifiedTrialSets.ByRewardType.Type22, ModifiedTrialSets.ByRewardType.Type34);


ModifiedTrialSets.ByColourSelected.A.Red = ModifiedTrialSets.ByChoice.SideA.TargetValueHigh;
ModifiedTrialSets.ByColourSelected.A.Yellow = ModifiedTrialSets.ByChoice.SideA.TargetValueLow;
ModifiedTrialSets.ByColourSelected.B.Red = ModifiedTrialSets.ByChoice.SideB.TargetValueLow;
ModifiedTrialSets.ByColourSelected.B.Yellow = ModifiedTrialSets.ByChoice.SideB.TargetValueHigh;

%By ChangingBlockTrials

% A_Own_B_Other  = intersect (ModifiedTrialSets.ByColourSelected.A.Red,ModifiedTrialSets.ByColourSelected.B.Red);
% A_Other_B_Own = intersect (ModifiedTrialSets.ByColourSelected.A.Yellow, ModifiedTrialSets.ByColourSelected.B.Yellow); 
A_Own_B_Own = intersect (ModifiedTrialSets.ByColourSelected.A.Red, ModifiedTrialSets.ByColourSelected.B.Yellow); 
A_OtherB_Other= intersect (ModifiedTrialSets.ByColourSelected.A.Yellow,ModifiedTrialSets.ByColourSelected.B.Red);

%create a string with our color representations of the 4 choice combinations
NumTrials = size(maintask_datastruct.report_struct.data(:,2),1);
PreferableTargetSelected_B= zeros([NumTrials, 1]);
PreferableTargetSelected_B(ModifiedTrialSets.ByChoice.SideB.ProtoTargetValueHigh) = 1;

%choice_combination_color_string = char(PreferableTargetSelected_B);
choice_combination_color_string(ModifiedTrialSets.ByColourSelected.B.Red) = 'R';
choice_combination_color_string(ModifiedTrialSets.ByColourSelected.B.Yellow) = 'B';
% choice_combination_color_string(A_Own_B_Own) = 'M';
% choice_combination_color_string(A_OtherB_Other) = 'G';
choice_combination_color_string = (choice_combination_color_string)';

pattern_in_class_string_struct_blocked = fn_extract_switches_from_classifier_string(choice_combination_color_string(ModifiedTrialSets.SuccessfulChoiceTrialsBlocked));

switching_number_blockedtrial_BR  = ModifiedTrialSets.SuccessfulChoiceTrialsBlocked(pattern_in_class_string_struct_blocked.BR);
first_red_trial_list_blocked_BR = ModifiedTrialSets.SuccessfulChoiceTrialsBlocked(pattern_in_class_string_struct_blocked.BR + 1);
switching_number_blockedtrial_RB = ModifiedTrialSets.SuccessfulChoiceTrialsBlocked(pattern_in_class_string_struct_blocked.RB);
first_blue_trial_list_blocked_RB = ModifiedTrialSets.SuccessfulChoiceTrialsBlocked(pattern_in_class_string_struct_blocked.RB + 1);

tmp_switching_number_blockedtrial_RB = switching_number_blockedtrial_RB;
%tmp_switching_number_blockedtrial_RB(end+1) = ModifiedTrialSets.SuccessfulChoiceTrialsBlocked(end);
tmp_switching_number_blockedtrial_BR = switching_number_blockedtrial_BR;



% make sure to add the index for the the last trial in the last block
if (first_blue_trial_list_blocked_RB(end) > first_red_trial_list_blocked_BR(end))
	tmp_switching_number_blockedtrial_BR(end+1) = ModifiedTrialSets.SuccessfulChoiceTrialsBlocked(end);
else
	tmp_switching_number_blockedtrial_RB(end+1) = ModifiedTrialSets.SuccessfulChoiceTrialsBlocked(end);
end	
	
% make sure the offsets are correct for RB
if (first_blue_trial_list_blocked_RB(1) > first_red_trial_list_blocked_BR(1))
	tmp_switching_number_blockedtrial_BR(1) = [];
else
	tmp_switching_number_blockedtrial_RB(1) = [];
end

% choice_combination_color_string_monkey = char(PreferableTargetSelected_B);
choice_combination_color_string_monkey(ModifiedTrialSets.ByColourSelected.B.Red) = 'R';
choice_combination_color_string_monkey(ModifiedTrialSets.ByColourSelected.B.Yellow) = 'B';
choice_combination_color_string_monkey(A_Own_B_Own) = 'M';
choice_combination_color_string_monkey(A_OtherB_Other) = 'G';
choice_combination_color_string_monkey = (choice_combination_color_string_monkey)';

pattern_in_class_string_struct_blocked_monkey = fn_extract_switches_from_classifier_string(choice_combination_color_string_monkey(ModifiedTrialSets.SuccessfulChoiceTrialsBlocked));



for i_BR_monkey = 1:length(first_red_trial_list_blocked_BR)
	BR_monkey_blocked_start_idx = first_red_trial_list_blocked_BR(i_BR_monkey);
	%for i_RB = 1:length(switching_number_blockedtrial_RB)
	RB_monkey_blocked_end_idx = tmp_switching_number_blockedtrial_RB(i_BR_monkey);
	tmp_idx = find(choice_combination_color_string_monkey(BR_monkey_blocked_start_idx:RB_monkey_blocked_end_idx) == 'R');
	if isempty(tmp_idx)
		continue
	end
	first_following_trial_list_blocked_BR(i_BR_monkey) = tmp_idx(1) + BR_monkey_blocked_start_idx - 1;
	if first_following_trial_list_blocked_BR(i_BR_monkey) <= first_red_trial_list_blocked_BR(i_BR_monkey)
		continue
	end
	pre_following_trial_blocked_BR(i_BR_monkey) = first_following_trial_list_blocked_BR(i_BR_monkey) -1;
	
end 


for i_RB_monkey = 1:length(first_blue_trial_list_blocked_RB)
	RB_monkey_blocked_start_idx = first_blue_trial_list_blocked_RB(i_RB_monkey);
	%for i_RB = 1:length(switching_number_blockedtrial_RB)
	BR_monkey_blocked_end_idx = tmp_switching_number_blockedtrial_BR(i_RB_monkey);
	tmp_idx = find(choice_combination_color_string_monkey(RB_monkey_blocked_start_idx:BR_monkey_blocked_end_idx) == 'B');
	if isempty(tmp_idx)
		continue
	end
	first_following_trial_list_blocked_RB(i_RB_monkey) = tmp_idx(1) + RB_monkey_blocked_start_idx - 1;
	if first_following_trial_list_blocked_RB(i_RB_monkey) <= first_blue_trial_list_blocked_RB(i_RB_monkey)
		continue
	end
	pre_following_trial_blocked_RB(i_RB_monkey) = first_following_trial_list_blocked_RB(i_RB_monkey) -1;
end


ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.BR = first_following_trial_list_blocked_BR;
ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.BR = pre_following_trial_blocked_BR; 

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_following_blocked.All = intersect(red_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.BR);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_following_blocked.All = intersect(yellow_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.BR);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_prefoll_blocked.All = intersect(red_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.BR);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_prefoll_blocked.All = intersect(yellow_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.BR);


ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.RB = first_following_trial_list_blocked_RB;
ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.RB = pre_following_trial_blocked_RB; 

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_following_blocked.All = intersect(red_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.RB);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_following_blocked.All = intersect(yellow_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.RB);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_prefoll_blocked.All = intersect(red_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.RB);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_prefoll_blocked.All = intersect(yellow_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.RB);


%6 reward combinations RB first following in the blocked condition 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_following_blocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_following_blocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_following_blocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_following_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_following_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_following_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
 
%6 reward combinations RB pre following in the blocked condition 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_prefoll_blocked.All , ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_prefoll_blocked.All , ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_prefoll_blocked.All , ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_prefoll_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_prefoll_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_prefoll_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
 

%6 reward combinations BR first following in the blocked condition 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_following_blocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_following_blocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_following_blocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_following_blocked.All ,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_following_blocked.All ,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_following_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);

%6 reward combinations BR pre following in the blocked condition 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_prefoll_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_prefoll_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_prefoll_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_prefoll_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_prefoll_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_prefoll_blocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);


pattern_in_class_string_struct_unblocked = fn_extract_switches_from_classifier_string(choice_combination_color_string(ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked));
switching_number_unblockedtrial_RB = ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked(pattern_in_class_string_struct_unblocked.RB);
first_blue_trial_list_unblocked_RB = ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked(pattern_in_class_string_struct_unblocked.RB +1);
switching_number_unblockedtrial_BR = ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked(pattern_in_class_string_struct_unblocked.BR);
first_red_trial_list_unblocked_BR = ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked(pattern_in_class_string_struct_unblocked.BR +1);

pattern_in_class_string_struct_unblocked_monkey = fn_extract_switches_from_classifier_string(choice_combination_color_string_monkey(ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked));

% tmp_switching_number_unblockedtrial_RB = switching_number_unblockedtrial_RB(2:end);
% %tmp_switching_number_unblockedtrial_RB(end+1) = ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked(end);

tmp_switching_number_unblockedtrial_RB = switching_number_unblockedtrial_RB;
tmp_switching_number_unblockedtrial_BR = switching_number_unblockedtrial_BR;

% make sure to add the index for the the last trial in the last block
if (first_blue_trial_list_unblocked_RB(end) > first_red_trial_list_unblocked_BR(end))
	tmp_switching_number_unblockedtrial_BR(end+1) = ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked(end);
else
	tmp_switching_number_unblockedtrial_RB(end+1) = ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked(end);
end	
	
% make sure the offsets are correct for RB
if (first_blue_trial_list_unblocked_RB(1) > first_red_trial_list_unblocked_BR(1))
	tmp_switching_number_unblockedtrial_BR(1) = [];
else
	tmp_switching_number_unblockedtrial_RB(1) = [];
end

for i_BR_monkey = 1:length(first_red_trial_list_unblocked_BR)
	BR_monkey_unblocked_start_idx = first_red_trial_list_unblocked_BR(i_BR_monkey);
	%for i_RB = 1:length(switching_number_blockedtrial_RB)
	RB_monkey_unblocked_end_idx = tmp_switching_number_unblockedtrial_RB(i_BR_monkey);
	tmp_idx = find(choice_combination_color_string_monkey(BR_monkey_unblocked_start_idx:RB_monkey_unblocked_end_idx) == 'R');
	if isempty(tmp_idx)
		continue
	end
	first_following_trial_list_unblocked_BR(i_BR_monkey) = tmp_idx(1) + BR_monkey_unblocked_start_idx -1 ;
	if first_following_trial_list_unblocked_BR(i_BR_monkey) <= first_red_trial_list_unblocked_BR(i_BR_monkey)
		continue
	end
	pre_following_trial_unblocked_BR(i_BR_monkey) = first_following_trial_list_unblocked_BR(i_BR_monkey) -1;
end


for i_RB_monkey = 1:length(first_blue_trial_list_unblocked_RB)
	RB_monkey_unblocked_start_idx = first_blue_trial_list_unblocked_RB(i_RB_monkey);
	%for i_RB = 1:length(switching_number_blockedtrial_RB)
	BR_monkey_unblocked_end_idx = tmp_switching_number_unblockedtrial_BR(i_RB_monkey);
	tmp_idx = find(choice_combination_color_string_monkey(RB_monkey_unblocked_start_idx:BR_monkey_unblocked_end_idx) == 'B');
	if isempty(tmp_idx)
		continue
	end
	first_following_trial_list_unblocked_RB(i_RB_monkey) = tmp_idx(1) + RB_monkey_unblocked_start_idx - 1;
	if first_following_trial_list_unblocked_RB(i_RB_monkey) <= first_blue_trial_list_unblocked_RB(i_RB_monkey)
		continue
	end
	pre_following_trial_unblocked_RB(i_RB_monkey) = first_following_trial_list_unblocked_RB(i_RB_monkey) -1;
end


ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.BR = first_following_trial_list_unblocked_BR;
ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.BR = pre_following_trial_unblocked_BR; 

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_following_unblocked.All = intersect(red_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.BR);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_following_unblocked.All = intersect(yellow_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.BR);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_prefoll_unblocked.All = intersect(red_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.BR);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_prefoll_unblocked.All = intersect(yellow_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.BR);


ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.RB = first_following_trial_list_unblocked_RB;
ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.RB = pre_following_trial_unblocked_RB; 

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_following_unblocked.All = intersect(red_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.RB);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_following_unblocked.All = intersect(yellow_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.RB);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_prefoll_unblocked.All = intersect(red_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.RB);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_prefoll_unblocked.All = intersect(yellow_objright_trials_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.RB);

%6 reward combinations RB first following in the unblocked condition 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_following_unblocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_following_unblocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_following_unblocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_following_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_following_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_following_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
 
%6 reward combinations RB pre following in the unblocked condition 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_prefoll_unblocked.All , ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_prefoll_unblocked.All , ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_RB_prefoll_unblocked.All , ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_prefoll_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_prefoll_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_RB_prefoll_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
 

%6 reward combinations BR first following in the unblocked condition 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_following_unblocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_following_unblocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_following_unblocked.All, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_following_unblocked.All ,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_following_unblocked.All ,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_following_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);

%6 reward combinations BR pre following in the unblocked condition 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_prefoll_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_prefoll_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright_BR_prefoll_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_prefoll_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_prefoll_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright_BR_prefoll_unblocked.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);


%The 4 Reward contingencies in joint, non-instructed trials
%ModifiedTrialSets.ByRewardType.Type11=intersect(Type11,SuccessfulChoiceTrials);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type11 = intersect(Type11_idx,SuccessfulChoiceTrials);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type22 = intersect(Type22_idx,SuccessfulChoiceTrials);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type34 = intersect(Type34_idx,SuccessfulChoiceTrials);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type43 = intersect(Type43_idx,SuccessfulChoiceTrials);

%BLOCKED
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type11 = intersect(Type11_idx,SuccessfulChoiceTrialsBlocked);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type22 = intersect(Type22_idx,SuccessfulChoiceTrialsBlocked);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type34 = intersect(Type34_idx,SuccessfulChoiceTrialsBlocked);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type43 = intersect(Type43_idx,SuccessfulChoiceTrialsBlocked);

%UNBLOCKED
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type11 = intersect(Type11_idx,SuccessfulChoiceTrialsUnblocked);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type22 = intersect(Type22_idx,SuccessfulChoiceTrialsUnblocked);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type34 = intersect(Type34_idx,SuccessfulChoiceTrialsUnblocked);
ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type43 = intersect(Type43_idx,SuccessfulChoiceTrialsUnblocked);

%POST SWITCH FIRST FOLLOWING TRIAL UNBLOCKED FROM RED TO BLUE 
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type11 = intersect(Type11_idx, ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type22 = intersect(Type22_idx, ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type34 = intersect(Type34_idx, ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type43 = intersect(Type43_idx, ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.RB);

%POST SWITCH PRE FOLLOWING TRIAL UNBLOCKED FROM RED TO BLUE
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type11 = intersect(Type11_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type22 = intersect(Type22_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type34 = intersect(Type34_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type43 = intersect(Type43_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.RB);

%POST SWITCH FIRST FOLLOWING TRIAL UNBLOCKED FROM BLUE TO RED 
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type11 = intersect(Type11_idx, ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type22 = intersect(Type22_idx, ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type34 = intersect(Type34_idx, ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type43 = intersect(Type43_idx, ModifiedTrialSets.BySwitchingBlock.First_Following.Unblocked.BR);

%POST SWITCH PRE FOLLOWING TRIAL UNBLOCKED FROM BLUE TO RED
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type11 = intersect(Type11_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type22 = intersect(Type22_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type34 = intersect(Type34_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type43 = intersect(Type43_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Unblocked.BR);

%POST SWITCH FIRST FOLLOWING TRIAL BLOCKED FROM RED TO BLUE
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type11=intersect(Type11_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type22=intersect(Type22_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type34=intersect(Type34_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type43=intersect(Type43_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.RB);

%POST SWITCH PRE FOLLOWING TRIAL BLOCKED FROM RED TO BLUE
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type11 = intersect(Type11_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type22 = intersect(Type22_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type34 = intersect(Type34_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.RB);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type43 = intersect(Type43_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.RB);

%POST SWITCH FIRST FOLLOWING TRIAL BLOCKED FROM BLUE TO RED 
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type11=intersect(Type11_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type22=intersect(Type22_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type34=intersect(Type34_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type43=intersect(Type43_idx,ModifiedTrialSets.BySwitchingBlock.First_Following.Blocked.BR);

%POST SWITCH PRE FOLLOWING TRIAL BLOCKED FROM BLUE TO RED
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type11 = intersect(Type11_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type22 = intersect(Type22_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type34 = intersect(Type34_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.BR);
ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type43 = intersect(Type43_idx, ModifiedTrialSets.BySwitchingBlock.Prefirstfollowing.Blocked.BR);


%By position and colour selected
%ModifiedTrialSets.ByPositionAndColor_ASelected.Type231=intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top, ModifiedTrialSets.ByColourSelected.A.Red);

%By SelectedTarget
%The own/other colour & stimulus position

%The own/other colour and stimulus position during blocked condition 
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6401 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_all);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6402 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_all);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6403 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_all);%Toprighttselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6404 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_all);%Toprighttselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6405 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_all);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6406 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_all);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6407 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_all);%Centerrighttselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6408 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_all);%Centerrighttselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6409 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_all);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6410 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_all);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6411 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_all);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6412 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_all);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6413 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_all);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6414 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_all);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6415 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_all);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6416 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_all);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6417 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_all);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6418 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_all);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6419 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_all);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6420 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_all);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6421 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_all);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6422 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_all);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6423 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_all);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6424 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrials.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_all);%Bottomrightselected_AOtherBOther

%BLOCKED
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6401 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_blocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6402 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_blocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6403 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_blocked);%Toprighttselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6404 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_blocked);%Toprighttselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6405 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_blocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6406 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_blocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6407 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_blocked);%Centerrighttselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6408 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_blocked);%Centerrighttselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6409 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_blocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6410 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_blocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6411 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_blocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6412 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_blocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6413 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_blocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6414 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_blocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6415 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_blocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6416 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_blocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6417 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_blocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6418 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_blocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6419 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_blocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6420 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_blocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6421 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_blocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6422 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_blocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6423 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_blocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6424 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsBlocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_blocked);%Bottomrightselected_AOtherBOther

%The own/other colour and stimulus position during post switching trials
%from red to blue in the blocked condition 
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6401 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_blocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6402 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_blocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6403 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_blocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6404 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_blocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6405 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_blocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6406 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_blocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6407 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_blocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6408 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_blocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6409 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_blocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6410 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_blocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6411 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_blocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6412 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_blocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6413 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_blocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6414 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_blocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6415 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_blocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6416 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_blocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6417 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_blocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6418 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_blocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6419 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_blocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6420 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_blocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6421 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_blocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6422 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_blocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6423 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_blocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6424 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_blocked);%Bottomrightselected_AOtherBOther

%The own/other colour and stimulus position during post switching trials
%from red to blue in the blocked condition PRE FOLLOWING 
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6401 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_blocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6402 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_blocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6403 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_blocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6404 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_blocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6405 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_blocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6406 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_blocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_blocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_blocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_blocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_blocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_blocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type11,ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_blocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_blocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_blocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_blocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_blocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_blocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_blocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_blocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_blocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_blocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_blocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_blocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_blocked);%Bottomrightselected_AOtherBOther

%The own/other colour and stimulus position during post switching trials
%from blue to red in the blocked condition 

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6401=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_blocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6402=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_blocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6403=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_blocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6404=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_blocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6405=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_blocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6406=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_blocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_blocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_blocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_blocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_blocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_blocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_blocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_blocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_blocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_blocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_blocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_blocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_blocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_blocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_blocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_blocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_blocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_blocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_blocked);%Bottomrightselected_AOtherBOther


%The own/other colour and stimulus position during post switching trials
%from RED TO BLUE in the blocked condition PRE FOLLOWING 
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6401 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_blocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6402 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_blocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6403 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_blocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6404 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_blocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6405 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_blocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6406 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_blocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_blocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_blocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_blocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_blocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_blocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type11,ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_blocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_blocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_blocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_blocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_blocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_blocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_blocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_blocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_blocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_blocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_blocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_blocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_blocked);%Bottomrightselected_AOtherBOther


%UNBLOCKED
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6401 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_unblocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6402 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_unblocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6403 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_unblocked);%Toprighttselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6404 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_unblocked);%Toprighttselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6405 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_unblocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6406 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_unblocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6407 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_unblocked);%Centerrighttselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6408 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_unblocked);%Centerrighttselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6409 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_unblocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6410 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_unblocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6411 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_unblocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6412 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_unblocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6413 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_unblocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6414 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_unblocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6415 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_unblocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6416 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_unblocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6417 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_unblocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6418 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_unblocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6419 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_unblocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6420 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_unblocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6421 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_unblocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6422 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_unblocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6423 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_unblocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6424 = intersect(ModifiedTrialSets.ByRewardType.SuccessfulChoiceTrialsUnblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_unblocked);%Bottomrightselected_AOtherBOther

%%The own/other colour and stimulus position during post switching trials
%from red to blue in the unblocked condition 

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6401 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_unblocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6402 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_unblocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6403 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_unblocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6404 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_following_unblocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6405 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_unblocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6406 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_unblocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_unblocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_following_unblocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_unblocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_unblocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_unblocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type11,ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_following_unblocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_unblocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_unblocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_unblocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_following_unblocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_unblocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_unblocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_unblocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_following_unblocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_unblocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_unblocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_unblocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_following_unblocked);%Bottomrightselected_AOtherBOther

%The own/other colour and stimulus position during post switching trials
%from blue to red in the unblocked condition 

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6401=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_unblocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6402=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_unblocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6403=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_unblocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6404=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_following_unblocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6405=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_unblocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6406=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_unblocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_unblocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_following_unblocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_unblocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_unblocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_unblocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_following_unblocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_unblocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_unblocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_unblocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_following_unblocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_unblocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_unblocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_unblocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_following_unblocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_unblocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_unblocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_unblocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_following_unblocked);%Bottomrightselected_AOtherBOther


%%The own/other colour and stimulus position during post switching trials
%from red to blue in the unblocked condition pre following trial 

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6401 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_unblocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6402 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_unblocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6403 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_unblocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6404 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_RB_prefoll_unblocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6405 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_unblocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6406 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_unblocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_unblocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_RB_prefoll_unblocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_unblocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_unblocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_unblocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type11,ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_RB_prefoll_unblocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_unblocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_unblocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_unblocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_RB_prefoll_unblocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_unblocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_unblocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_unblocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_RB_prefoll_unblocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_unblocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_unblocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_unblocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_RB_prefoll_unblocked);%Bottomrightselected_AOtherBOther

%The own/other colour and stimulus position during post switching trials
%from blue to red in the unblocked condition pre following

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6401 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_unblocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6402 = intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_unblocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6403 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_unblocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6404 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_BR_prefoll_unblocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6405 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.First_Following.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_unblocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6406 =intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_unblocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_unblocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_BR_prefoll_unblocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_unblocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_unblocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_unblocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type11,ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_BR_prefoll_unblocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_unblocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_unblocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_unblocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_BR_prefoll_unblocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_unblocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_unblocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_unblocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_BR_prefoll_unblocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_unblocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_unblocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_unblocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_BR_prefoll_unblocked);%Bottomrightselected_AOtherBOther




%By whether the selected target is on TopRight;TopLeft;
%CenterRight;CenterLeft; BottomRight; Bottom Left and the 4 combinations of
%OwnOwn;OwnOther;OtherOwn;OtherOther

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6401 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6402 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6403 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6404 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6405 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6406 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6407 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6408 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6409=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6410=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6411=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6412=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6413=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6414=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6415=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6416=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6417=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6418=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6419=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6420=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6421=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6422=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6423=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrials.Type6424=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6412;

%BLOCKED

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6401 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6402 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6403 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6404 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6405 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6406 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6407 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6408 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6409 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6410 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6411 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6412 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6413=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6414=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6415=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6416=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6417=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6418=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6419=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6420=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6421=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6422=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6423=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsBlocked.Type6424=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6412;

%Post switch RB blocked FOLLOWING TRIAL

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6413 = ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.RB.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6412;

%Post switch RB blocked prefollING TRIAL

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6413 = ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6412;

%Post switch BR blocked FOLLOWING TRIAL
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6413=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Blocked.BR.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6412;

%Post switch BR blocked prefollING TRIAL
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6413=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6412;

%UNBLOCKED
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6401 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6402 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6403 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6404 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6405 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6406 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6407 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6408 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6409 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6410 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6411 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6412 = ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6413=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6414=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6415=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6416=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6417=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6418=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6419=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6420=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6421=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6422=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6423=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.SuccessfulChoiceTrialsUnblocked.Type6424=ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6412;

%%Post switch RB unblocked FOLLOWING TRIAL
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6413=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.RB.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6412;

%%Post switch RB unblocked prefollING TRIAL
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6413=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6412;


%Post switch BR unblocked FOLLOWING
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6413=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.First_Following.Unblocked.BR.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6412;

%Post switch BR unblocked prefollING
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6413=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6412;

%Stimulus position : left/right
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6405,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6406,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6407,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6408,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6417,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6418,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6419,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6420,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrials.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%BLOCKED
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6405,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6406,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6407,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6408,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6417,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6418,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6419,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6420,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsBlocked.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%blocked blue to red  FOLLOWING 
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.BR.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%blocked blue to red  prefollING 
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%blocked red to blue FOLLOWING
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Blocked.RB.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%blocked red to blue prefollING
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected


%UNBLOCKED
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2401 =union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6405,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6406,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6407,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6408,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6417,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6418,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6419,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6420,ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoiceTrialsUnblocked.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%unblocked blue to red  FOLLOWING 
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.BR.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%unblocked blue to red  prefollING 
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%unblocked red to blue FOLLOWING 
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.First_Following.Unblocked.RB.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%unblocked red to blue FOLLOWING 
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected


%%For Trials when Right Side was selected and Left side was selected-
%%irrespective of which value combination it is. 
ModifiedTrialSets.BySelectedSideA.SuccessfulChoiceTrials.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.SuccessfulChoiceTrials.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrials.Type2406))); %A_SelectedLEFT side

%BLOCKED
ModifiedTrialSets.BySelectedSideA.SuccessfulChoiceTrialsBlocked.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.SuccessfulChoiceTrialsBlocked.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.Type2406))); %A_SelectedLEFT side
%Blocked red to blue FOLLOWING 
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.First_Following.Blocked.RB.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.First_Following.Blocked.RB.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.RB.Type2406))); %A_SelectedLEFT side
%Blocked red to blue prefollING 
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.RB.Type2406))); %A_SelectedLEFT side
%blocked blue to red FOLLOWING
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.First_Following.Blocked.BR.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.First_Following.Blocked.BR.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Blocked.BR.Type2406))); %A_SelectedLEFT side
%blocked blue to red prefollING
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Blocked.BR.Type2406))); %A_SelectedLEFT side

%UNBLOCKED
ModifiedTrialSets.BySelectedSideA.SuccessfulChoiceTrialsUnblocked.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.SuccessfulChoiceTrialsUnblocked.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsUnblocked.Type2406))); %A_SelectedLEFT side
%Unblocked red to blue FOLLOWING
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.First_Following.Unblocked.RB.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.First_Following.Unblocked.RB.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2406))); %A_SelectedLEFT side
%Unblocked red to blue prefollING
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2406))); %A_SelectedLEFT side

%unblocked blue to red FOLLOWING 
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.First_Following.Unblocked.BR.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.First_Following.Unblocked.BR.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.First_Following.Unblocked.BR.Type2406))); %A_SelectedLEFT side
%unblocked blue to red prefollING 
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitchingBlock.Prefirstfollowing.Unblocked.BR.Type2406))); %A_SelectedLEFT side

return
end