function [ ModifiedTrialSets ] = rn_segregateTrialData( maintask_datastruct)
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
SuccessfulChoiceTrials_BlockedTrials= intersect(SuccessfulChoiceTrials,ModifiedTrialSets.ByVisibility.AB_invisible);

SuccessfulChoiceTrials_UnblockedTrials = setdiff(SuccessfulChoiceTrials, SuccessfulChoiceTrials_BlockedTrials);
 
ModifiedTrialSets.SuccessfulChoiceTrials = SuccessfulChoiceTrials;
ModifiedTrialSets.SuccessfulChoiceTrials_BlockedTrials = SuccessfulChoiceTrials_BlockedTrials;
ModifiedTrialSets.SuccessfulChoiceTrials_UnblockedTrials = SuccessfulChoiceTrials_UnblockedTrials;


% Segregation on the basis of Target Position-Colour and Side: Red on objective right or
% yellow on objective right

red_objright_idx = find (maintask_datastruct.report_struct.Stimuli.data(:,4) == 1182 & maintask_datastruct.report_struct.Stimuli.data(:,3) == 1); %Red on objective right
yellow_objright_idx = find (maintask_datastruct.report_struct.Stimuli.data(:,4) == 1182 & maintask_datastruct.report_struct.Stimuli.data(:,3) == 2); %Blue on objective right
red_objright_trials = maintask_datastruct.report_struct.Stimuli.data(red_objright_idx,2);
yellow_objright_trials = maintask_datastruct.report_struct.Stimuli.data(yellow_objright_idx,2);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.All = intersect(red_objright_idx,SuccessfulChoiceTrials);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.All = intersect(yellow_objright_idx,SuccessfulChoiceTrials);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked = intersect(red_objright_idx, SuccessfulChoiceTrials_BlockedTrials);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked = intersect(yellow_objright_idx, SuccessfulChoiceTrials_BlockedTrials);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked = intersect(red_objright_idx, SuccessfulChoiceTrials_UnblockedTrials);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked = intersect(yellow_objright_idx, SuccessfulChoiceTrials_UnblockedTrials);

% Segregation on the basis of Target Height-Top,center, Bottom. 


top_idx = find (maintask_datastruct.report_struct.Stimuli.data(:,11)==1 & maintask_datastruct.report_struct.Stimuli.data(:,5)==445); %Target in the top row
center_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,11)==1 & maintask_datastruct.report_struct.Stimuli.data(:,5)==500); %Target in the center row
bottom_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,11)==1 & maintask_datastruct.report_struct.Stimuli.data(:,5)==556); %Target in the bottom row
top_trials=maintask_datastruct.report_struct.Stimuli.data(top_idx,2);
center_trials=maintask_datastruct.report_struct.Stimuli.data(center_idx,2);
bottom_trials=maintask_datastruct.report_struct.Stimuli.data(bottom_idx,2);


ModifiedTrialSets.ByTargetposition.ByHeight.Top_all =intersect(top_idx,SuccessfulChoiceTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Center_all =intersect(center_idx,SuccessfulChoiceTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Bottom_all =intersect(bottom_idx,SuccessfulChoiceTrials);

ModifiedTrialSets.ByTargetposition.ByHeight.Top_blocked = intersect(top_idx, SuccessfulChoiceTrials_BlockedTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Center_blocked = intersect(center_idx, SuccessfulChoiceTrials_BlockedTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Bottom_blocked = intersect(bottom_idx, SuccessfulChoiceTrials_BlockedTrials);

ModifiedTrialSets.ByTargetposition.ByHeight.Top_unblocked =intersect(top_idx,SuccessfulChoiceTrials_UnblockedTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Center_unblocked =intersect(center_idx,SuccessfulChoiceTrials_UnblockedTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Bottom_unblocked =intersect(bottom_idx,SuccessfulChoiceTrials_UnblockedTrials);

%The 6 combinations of positions
%For all successful trials
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_all = intersect( ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.All, ModifiedTrialSets.ByTargetposition.ByHeight.Top_all);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_all = intersect( ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.All, ModifiedTrialSets.ByTargetposition.ByHeight.Center_all);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_all = intersect( ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.All, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom_all);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_all = intersect( ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top_all);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_all = intersect( ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center_all);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_all = intersect( ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom_all);

%for the successful blocked trials 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked, ModifiedTrialSets.ByTargetposition.ByHeight.Top_blocked);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked, ModifiedTrialSets.ByTargetposition.ByHeight.Center_blocked);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom_blocked);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked,ModifiedTrialSets.ByTargetposition.ByHeight.Top_blocked);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked,ModifiedTrialSets.ByTargetposition.ByHeight.Center_blocked);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom_blocked);

%for the successful unblockedtrials 
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked, ModifiedTrialSets.ByTargetposition.ByHeight.Top_unblocked);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked, ModifiedTrialSets.ByTargetposition.ByHeight.Center_unblocked);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom_unblocked);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked,ModifiedTrialSets.ByTargetposition.ByHeight.Top_unblocked);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked,ModifiedTrialSets.ByTargetposition.ByHeight.Center_unblocked);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom_unblocked);



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

trial_num = maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.TrialNumber);

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

%The 4 Reward contingencies in joint, non-instructed trials
%ModifiedTrialSets.ByRewardType.Type11=intersect(Type11,SuccessfulChoiceTrials);

ModifiedTrialSets.ByRewardType.Unblocked.Type11 = intersect(Type11_idx,SuccessfulChoiceTrials_UnblockedTrials);
ModifiedTrialSets.ByRewardType.Unblocked.Type22 = intersect(Type22_idx,SuccessfulChoiceTrials_UnblockedTrials);
ModifiedTrialSets.ByRewardType.Unblocked.Type34 = intersect(Type34_idx,SuccessfulChoiceTrials_UnblockedTrials);
ModifiedTrialSets.ByRewardType.Unblocked.Type43 = intersect(Type43_idx,SuccessfulChoiceTrials_UnblockedTrials);


ModifiedTrialSets.ByRewardType.Blocked.Type11=intersect(Type11_idx,SuccessfulChoiceTrials_BlockedTrials);
ModifiedTrialSets.ByRewardType.Blocked.Type22 = intersect(Type22_idx,SuccessfulChoiceTrials_BlockedTrials);
ModifiedTrialSets.ByRewardType.Blocked.Type34=intersect(Type34_idx,SuccessfulChoiceTrials_BlockedTrials);
ModifiedTrialSets.ByRewardType.Blocked.Type43=intersect(Type43_idx,SuccessfulChoiceTrials_BlockedTrials);



% %By colour selected

% ModifiedTrialSets.ByColourSelected.Unblocked.A.Red = union(ModifiedTrialSets.ByRewardType.UnblockedTrials.Type22, ModifiedTrialSets.ByRewardType.UnblockedTrials.Type43);
% ModifiedTrialSets.ByColourSelected.Unblocked.A.Yellow = union(ModifiedTrialSets.ByRewardType.UnblockedTrials.Type11, ModifiedTrialSets.ByRewardType.UnblockedTrials.Type34);
% ModifiedTrialSets.ByColourSelected.Unblocked.B.Red = union(ModifiedTrialSets.ByRewardType.UnblockedTrials.Type11, ModifiedTrialSets.ByRewardType.UnblockedTrials.Type43);
% ModifiedTrialSets.ByColourSelected.Unblocked.B.Yellow = union(ModifiedTrialSets.ByRewardType.UnblockedTrials.Type22, ModifiedTrialSets.ByRewardType.UnblockedTrials.Type34);

ModifiedTrialSets.ByColourSelected.A.Red = ModifiedTrialSets.ByChoice.SideA.TargetValueHigh;
ModifiedTrialSets.ByColourSelected.A.Yellow = ModifiedTrialSets.ByChoice.SideA.TargetValueLow;
ModifiedTrialSets.ByColourSelected.B.Red = ModifiedTrialSets.ByChoice.SideB.TargetValueLow;
ModifiedTrialSets.ByColourSelected.B.Yellow = ModifiedTrialSets.ByChoice.SideB.TargetValueHigh;

%By ChangingBlockTrials

% A_Own_B_Other  = intersect (ModifiedTrialSets.ByColourSelected.A.Red,ModifiedTrialSets.ByColourSelected.B.Red);
% A_Other_B_Own = intersect (ModifiedTrialSets.ByColourSelected.A.Yellow, ModifiedTrialSets.ByColourSelected.B.Yellow); 
%A_Own_B_Own = intersect (ModifiedTrialSets.ByColourSelected.A.Red, ModifiedTrialSets.ByColourSelected.A.Yellow); 
%A_OtherB_Other= intersect (ModifiedTrialSets.ByColourSelected.A.Yellow,ModifiedTrialSets.ByColourSelected.A.Red);

%create a string with our color representations of the 4 choice combinations
NumTrials = size(maintask_datastruct.report_struct.data(:,2),1);
PreferableTargetSelected_B= zeros([NumTrials, 1]);
PreferableTargetSelected_B(ModifiedTrialSets.ByChoice.SideB.ProtoTargetValueHigh) = 1;

choice_combination_color_string = char(PreferableTargetSelected_B);
choice_combination_color_string(ModifiedTrialSets.ByColourSelected.B.Red) = 'R';
choice_combination_color_string(ModifiedTrialSets.ByColourSelected.B.Yellow) = 'B';
% choice_combination_color_string(A_Own_B_Own) = 'M';
% choice_combination_color_string(A_OtherB_Other) = 'G';
choice_combination_color_string = (choice_combination_color_string)';


pattern_in_class_string_struct_blocked = fn_extract_switches_from_classifier_string(choice_combination_color_string(SuccessfulChoiceTrials_BlockedTrials));

switching_number_blockedtrial_RB = ModifiedTrialSets.SuccessfulChoiceTrials_BlockedTrials(pattern_in_class_string_struct_blocked.RB);
switching_number_blockedtrial_BR = ModifiedTrialSets.SuccessfulChoiceTrials_BlockedTrials(pattern_in_class_string_struct_blocked.BR);

ModifiedTrialSets.BySwitchingBlock.BlockedTrials.RB = switching_number_blockedtrial_RB;

real_switching_blocked_RB = (ModifiedTrialSets.BySwitchingBlock.BlockedTrials.RB)+1;
real_switching_blocked_RB = real_switching_blocked_RB(ismember(real_switching_blocked_RB, SuccessfulChoiceTrials_BlockedTrials));

post_one_trial_switching_blocked_RB = real_switching_blocked_RB +1;
post_one_trial_switching_blocked_RB = post_one_trial_switching_blocked_RB(ismember(post_one_trial_switching_blocked_RB, SuccessfulChoiceTrials_BlockedTrials));

post_switching_blocked_RB = union (real_switching_blocked_RB,post_one_trial_switching_blocked_RB);
%switch_post_switch_blocked_RB = union(post_switching_blocked_RB,ModifiedTrialSets.BySwitchingBlock.BlockedTrials.RB);

%ModifiedTrialSets.ByPostSwitch.Blocked.RB = switch_post_switch_blocked_RB;
%ModifiedTrialSets.ByPostSwitch.Blocked.RB = post_one_trial_switching_blocked_RB;
ModifiedTrialSets.ByPostSwitch.Blocked.RB = post_switching_blocked_RB;

ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR = switching_number_blockedtrial_BR;
real_switching_blocked_BR = (ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR)+1;
real_switching_blocked_BR = real_switching_blocked_BR(ismember(real_switching_blocked_BR, SuccessfulChoiceTrials_BlockedTrials));

post_one_trial_switching_blocked_BR = real_switching_blocked_BR +1;
post_one_trial_switching_blocked_BR = post_one_trial_switching_blocked_BR(ismember(post_one_trial_switching_blocked_BR, SuccessfulChoiceTrials_BlockedTrials));

post_switching_blocked_BR = union (real_switching_blocked_BR,post_one_trial_switching_blocked_BR);
%switch_post_switch_blocked_BR = union(real_switching_blocked_BR,ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR);

% ModifiedTrialSets.ByPostSwitch.Blocked.BR = switch_post_switch_blocked_BR;
% ModifiedTrialSets.ByPostSwitch.Blocked.BR = post_one_trial_switching_blocked_BR;
ModifiedTrialSets.ByPostSwitch.Blocked.BR = post_switching_blocked_BR;
 
pattern_in_class_string_struct_unblocked = fn_extract_switches_from_classifier_string(choice_combination_color_string(SuccessfulChoiceTrials_UnblockedTrials));

switching_number_unblockedtrial_RB = ModifiedTrialSets.SuccessfulChoiceTrials_UnblockedTrials(pattern_in_class_string_struct_unblocked.RB);
switching_number_unblockedtrial_BR = ModifiedTrialSets.SuccessfulChoiceTrials_UnblockedTrials(pattern_in_class_string_struct_unblocked.BR);

ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB = switching_number_unblockedtrial_RB;
real_switching_unblocked_RB = (ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB)+1;
real_switching_unblocked_RB = real_switching_unblocked_RB(ismember(real_switching_unblocked_RB, SuccessfulChoiceTrials_UnblockedTrials));
post_one_trial_switching_unblocked_RB = real_switching_unblocked_RB +1;
post_one_trial_switching_unblocked_RB = post_one_trial_switching_unblocked_RB(ismember(post_one_trial_switching_unblocked_RB, SuccessfulChoiceTrials_UnblockedTrials));

post_switching_unblocked_RB = union (real_switching_unblocked_RB, post_one_trial_switching_unblocked_RB);
%switch_post_switch_unblocked_RB = union(post_switching_unblocked_RB, ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB);

% ModifiedTrialSets.ByPostSwitch.Unblocked.RB = switch_post_switch_unblocked_RB; 
% ModifiedTrialSets.ByPostSwitch.Unblocked.RB = post_one_trial_switching_unblocked_RB; 
ModifiedTrialSets.ByPostSwitch.Unblocked.RB = post_switching_unblocked_RB; 


ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR = switching_number_unblockedtrial_BR;

real_switching_unblocked_BR = (ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR)+1;
real_switching_unblocked_BR = real_switching_unblocked_BR(ismember(real_switching_unblocked_BR, SuccessfulChoiceTrials_UnblockedTrials));

post_one_trial_switching_unblocked_BR = real_switching_unblocked_BR +1;
post_one_trial_switching_unblocked_BR = post_one_trial_switching_unblocked_BR(ismember(post_one_trial_switching_unblocked_BR, SuccessfulChoiceTrials_UnblockedTrials));

post_switching_unblocked_BR = union (real_switching_unblocked_BR, post_one_trial_switching_unblocked_BR);
%switch_post_switch_unblocked_BR = union(post_switching_unblocked_BR, ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR);

% ModifiedTrialSets.ByPostSwitch.Unblocked.BR = switch_post_switch_unblocked_BR; 
% ModifiedTrialSets.ByPostSwitch.Unblocked.BR = post_one_trial_switching_unblocked_BR;
ModifiedTrialSets.ByPostSwitch.Unblocked.BR = post_switching_unblocked_BR;

%ModifiedTrialSets.ByRewardType.Type11=intersect(Type11,SuccessfulChoiceTrials);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type11 = intersect(Type11_idx, ModifiedTrialSets.ByPostSwitch.Unblocked.RB);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type22 = intersect(Type22_idx, ModifiedTrialSets.ByPostSwitch.Unblocked.RB);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type34 = intersect(Type34_idx, ModifiedTrialSets.ByPostSwitch.Unblocked.RB);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type43 = intersect(Type43_idx, ModifiedTrialSets.ByPostSwitch.Unblocked.RB);

ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type11=intersect(Type11_idx,ModifiedTrialSets.ByPostSwitch.Unblocked.BR);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type22=intersect(Type22_idx,ModifiedTrialSets.ByPostSwitch.Unblocked.BR);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type34=intersect(Type34_idx,ModifiedTrialSets.ByPostSwitch.Unblocked.BR);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type43=intersect(Type43_idx,ModifiedTrialSets.ByPostSwitch.Unblocked.BR);


ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type11=intersect(Type11_idx,ModifiedTrialSets.ByPostSwitch.Blocked.RB);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type22=intersect(Type22_idx,ModifiedTrialSets.ByPostSwitch.Blocked.RB);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type34=intersect(Type34_idx,ModifiedTrialSets.ByPostSwitch.Blocked.RB);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type43=intersect(Type43_idx,ModifiedTrialSets.ByPostSwitch.Blocked.RB);

ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type11=intersect(Type11_idx,ModifiedTrialSets.ByPostSwitch.Blocked.BR);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type22=intersect(Type22_idx,ModifiedTrialSets.ByPostSwitch.Blocked.BR);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type34=intersect(Type34_idx,ModifiedTrialSets.ByPostSwitch.Blocked.BR);
ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type43=intersect(Type43_idx,ModifiedTrialSets.ByPostSwitch.Blocked.BR);

ModifiedTrialSets.ByRewardType.Unblocked.Type11 = intersect(Type11_idx, ModifiedTrialSets.SuccessfulChoiceTrials_UnblockedTrials);
ModifiedTrialSets.ByRewardType.Unblocked.Type22 = intersect(Type22_idx, ModifiedTrialSets.SuccessfulChoiceTrials_UnblockedTrials);
ModifiedTrialSets.ByRewardType.Unblocked.Type34 = intersect(Type34_idx, ModifiedTrialSets.SuccessfulChoiceTrials_UnblockedTrials);
ModifiedTrialSets.ByRewardType.Unblocked.Type43 = intersect(Type43_idx, ModifiedTrialSets.SuccessfulChoiceTrials_UnblockedTrials);

ModifiedTrialSets.ByRewardType.Blocked.Type11 = intersect(Type11_idx,ModifiedTrialSets.SuccessfulChoiceTrials_BlockedTrials);
ModifiedTrialSets.ByRewardType.Blocked.Type22 = intersect(Type22_idx,ModifiedTrialSets.SuccessfulChoiceTrials_BlockedTrials);
ModifiedTrialSets.ByRewardType.Blocked.Type34 = intersect(Type34_idx,ModifiedTrialSets.SuccessfulChoiceTrials_BlockedTrials);
ModifiedTrialSets.ByRewardType.Blocked.Type43 = intersect(Type43_idx,ModifiedTrialSets.SuccessfulChoiceTrials_BlockedTrials);

%By position and colour selected
ModifiedTrialSets.ByPositionAndColor_ASelected.Type231 = intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.All, ModifiedTrialSets.ByColourSelected.A.Red);

%By SelectedTarget
%The own/other colour & stimulus position
ModifiedTrialSets.Byrewardttype_pos.SuccessfulChoi.Type6401 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6402 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6403 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6404 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6405 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6406 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6407 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6408 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6409 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6410 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6411 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6412 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6413 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6414 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6415 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6416 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6417 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6418 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6419 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6420 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6421 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6422 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6423 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6424 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOtherBOther


%The own/other colour and stimulus position during blocked condition 

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6401 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6402 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6403 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6404 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6405 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6406 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6407 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6408 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6409 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6410 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6411 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6412 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6413 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6414 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6415 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6416 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6417 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6418 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6419 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6420 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6421 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6422 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6423 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6424 = intersect(ModifiedTrialSets.ByRewardType.Blocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOtherBOther

%The own/other colour and stimulus position during post switching trials
%from red to blue in the blocked condition 
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6401 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6402 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6403 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6404 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6405 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6406 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6407 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6408 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6409 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6410 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6411 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6412 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6413 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6414 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6415 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6416 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6417 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6418 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6419 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6420 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6421 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6422 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6423 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6424 = intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOtherBOther


%The own/other colour and stimulus position during post switching trials
%from blue to red in the blocked condition 

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6401=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6402=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6403=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6404=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Top_blocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6405=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6406=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6407=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6408=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6409=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6410=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6411=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6412=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6413=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6414=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6415=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6416=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Top_blocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6417=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6418=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6419=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6420=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Center_blocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6421=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6422=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6423=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6424=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Blocked_Bottom_blocked);%Bottomrightselected_AOtherBOther

%The own/other colour and stimulus position during unblocked condition 
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6401 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6402 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6403 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6404 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6405 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6406 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6407 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6408 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6409 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6410 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6411 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6412 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6413 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6414 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6415 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6416 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6417 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6418 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6419 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6420 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6421 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6422 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6423 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6424 = intersect(ModifiedTrialSets.ByRewardType.Unblocked.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOtherBOther

%%The own/other colour and stimulus position during post switching trials
%from red to blue in the unblocked condition 

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6401=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6402=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6403=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6404=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6405=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6406=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6407=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6408=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6409=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6410=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6411=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6412=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6413=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6414=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6415=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6416=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6417=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6418=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6419=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6420=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6421=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6422=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6423=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6424=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOtherBOther

%The own/other colour and stimulus position during post switching trials
%from blue to red in the unblocked condition 

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6401=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6402=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6403=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6404=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6405=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6406=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6407=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6408=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6409=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6410=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6411=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6412=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6413=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6414=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6415=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6416=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Top_unblocked);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6417=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6418=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6419=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6420=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Center_unblocked);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6421=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6422=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6423=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6424=intersect(ModifiedTrialSets.ByRewardType.ByPostSwitch.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Unblocked_Bottom_unblocked);%Bottomrightselected_AOtherBOther

%By whether the selected target is on TopRight;TopLeft;
%CenterRight;CenterLeft; BottomRight; Bottom Left and the 4 combinations of
%OwnOwn;OwnOther;OtherOwn;OtherOther
%blocked condition

ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6401 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6402 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6403 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6404 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6405 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6406 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6407 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6408 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6409 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6410 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6411 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6412 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6413 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6414 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6415 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6416 = ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6417=ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6418=ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6419=ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6420=ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6421=ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6422=ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6423=ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.Blocked.Type6424=ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6412;

%Post switch RB blocked 

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6401=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6402=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6403=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6404=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6405=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6406=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6407=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6408=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6409=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6410=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6411=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6412=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6413 = ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6414=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6415=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6416=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6417=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6418=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6419=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6420=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6421=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6422=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6423=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.RB.Type6424=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6412;

%Post switch BR blocked 
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6401=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6402=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6403=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6404=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6405=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6406=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6407=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6408=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6409=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6410=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6411=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6412=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6413=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6414=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6415=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6416=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6417=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6418=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6419=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6420=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6421=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6422=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6423=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Blocked.BR.Type6424=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6412;


%By whether the selected target is on TopRight;TopLeft;
%CenterRight;CenterLeft; BottomRight; Bottom Left and the 4 combinations of
%OwnOwn;OwnOther;OtherOwn;OtherOther
%unblocked condition

ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6401=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6402=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6403=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6404=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6405=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6406=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6407=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6408=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6409=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6410=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6411=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6412=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6413=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6414=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6415=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6416=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6417=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6418=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6419=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6420=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6421=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6422=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6423=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.Unblocked.Type6424=ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6412;

%%Post switch RB unblocked 
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6401=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6402=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6403=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6404=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6405=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6406=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6407=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6408=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6409=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6410=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6411=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6412=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6413=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6414=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6415=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6416=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6417=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6418=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6419=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6420=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6421=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6422=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6423=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.RB.Type6424=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6412;


%Post switch BR unblocked 
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6401=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6402=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6403=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6404=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6405=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6406=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6407=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6408=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6409=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6410=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6411=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6412=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6413=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6414=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6415=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6416=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6417=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6418=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6419=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6420=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6421=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6422=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6423=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.ByPostSwitch_Unblocked.BR.Type6424=ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6412;

%Stimulus position : left/right
%unblocked 
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6405,ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6406,ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6407,ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6408,ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6417,ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6418,ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6419,ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6420,ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%unblocked blue to red  
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6405,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6406,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6407,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6408,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6417,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6418,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6419,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6420,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.BR.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%unblocked red to blue
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6405,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6406,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6407,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6408,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6417,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6418,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6419,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6420,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Unblocked.RB.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected


%Stimulus position : left/right
%blocked
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6405,ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6406,ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6407,ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.Unblocked.Type6408,ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6417,ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6418,ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6419,ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6420,ModifiedTrialSets.Byrewardttype_pos.Blocked.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%blocked blue to red  
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6405,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6406,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6407,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6408,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6417,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6418,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6419,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6420,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.BR.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%blocked red to blue
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6405,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6406,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6407,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6408,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6417,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6418,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6419,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6420,ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected




%%For Trials when Right Side was selected and Left side was selected-
%%irrespective of which value combination it is. 
%Unblocked
ModifiedTrialSets.BySelectedSideA.Unblocked.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.Unblocked.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Unblocked.Type2406))); %A_SelectedLEFT side

%Unblocked red to blue 
ModifiedTrialSets.BySelectedSideA.ByPostSwitch_Unblocked.RB.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.ByPostSwitch_Unblocked.RB.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2406))); %A_SelectedLEFT side

%unblocked blue to red 
ModifiedTrialSets.BySelectedSideA.ByPostSwitch_Unblocked.BR.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.ByPostSwitch_Unblocked.BR.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Unblocked.BR.Type2406))); %A_SelectedLEFT side

%Blocked
ModifiedTrialSets.BySelectedSideA.Blocked.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.Blocked.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Blocked.Type2406))); %A_SelectedLEFT side


%Blocked red to blue
ModifiedTrialSets.BySelectedSideA.ByPostSwitch_Blocked.RB.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.ByPostSwitch_Blocked.RB.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.RB.Type2406))); %A_SelectedLEFT side

%blocked blue to red 
ModifiedTrialSets.BySelectedSideA.ByPostSwitch_Blocked.BR.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.ByPostSwitch_Blocked.BR.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.ByPostSwitch_Blocked.BR.Type2406))); %A_SelectedLEFT side


return
end


 
 