function [ModifiedTrialSets]=rn_segregateTrialData(maintask_datastruct)
addpath('/Users/rnocerino/DPZ/taskcontroller/CODE/Project_Sandbox/roberta_n');
[ModifiedTrialSets] = fnCollectTrialSets( maintask_datastruct.report_struct );  

%Joint successful trials- Trials which are jointly played, are
%non-instructed and both players are rewarded in it

ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial = ModifiedTrialSets.ByJointness.DualSubjectJointTrials;
LastJointTrial = length(ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial);
ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial(LastJointTrial) = NaN;
Joint_choicetargets = intersect(ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial, ModifiedTrialSets.ByChoices.NumChoices02);
bothrewarded = intersect(ModifiedTrialSets.ByOutcome.SideA.REWARD, ModifiedTrialSets.ByOutcome.SideB.REWARD);

SuccessfulChoiceTrials = intersect(Joint_choicetargets, bothrewarded);
SuccessfulChoiceTrials_BlockedTrials = intersect(SuccessfulChoiceTrials, ModifiedTrialSets.ByVisibility.AB_invisible);
SuccessfulChoiceTrials_UnBlockedTrials = setdiff(SuccessfulChoiceTrials, SuccessfulChoiceTrials_BlockedTrials);

ModifiedTrialSets.SuccessfulChoiceTrials = SuccessfulChoiceTrials;
ModifiedTrialSets.SuccessfulChoiceTrials_BlockedTrials = SuccessfulChoiceTrials_BlockedTrials;
ModifiedTrialSets.SuccessfulChoiceTrials_UnBlockedTrials = SuccessfulChoiceTrials_UnBlockedTrials;



% Segregation on the basis of Target Position-Colour and Side: Red on objective right or
% yellow on objective right
red_objright_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,4)==1182 & maintask_datastruct.report_struct.Stimuli.data(:,3)==1); %Red on objective right
yellow_objright_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,4)==1182 & maintask_datastruct.report_struct.Stimuli.data(:,3)==2); %Blue on objective right
red_objright_trials=maintask_datastruct.report_struct.Stimuli.data(red_objright_idx,2);
yellow_objright_trials=maintask_datastruct.report_struct.Stimuli.data(yellow_objright_idx,2);

ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.All=intersect(red_objright_trials,SuccessfulChoiceTrials);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.All=intersect(yellow_objright_trials,SuccessfulChoiceTrials);

% Segregation on the basis of Target Height-Top,center, Bottom

top_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,11)==1 & maintask_datastruct.report_struct.Stimuli.data(:,5)==445); %Target in the top row
center_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,11)==1 & maintask_datastruct.report_struct.Stimuli.data(:,5)==500); %Target in the center row
bottom_idx=find (maintask_datastruct.report_struct.Stimuli.data(:,11)==1 & maintask_datastruct.report_struct.Stimuli.data(:,5)==556); %Target in the bottom row
top_trials=maintask_datastruct.report_struct.Stimuli.data(top_idx,2);
center_trials=maintask_datastruct.report_struct.Stimuli.data(center_idx,2);
bottom_trials=maintask_datastruct.report_struct.Stimuli.data(bottom_idx,2);


ModifiedTrialSets.ByTargetposition.ByHeight.Top=intersect(top_trials,SuccessfulChoiceTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Center=intersect(center_trials,SuccessfulChoiceTrials);
ModifiedTrialSets.ByTargetposition.ByHeight.Bottom=intersect(bottom_trials,SuccessfulChoiceTrials);

%The 6 combinations of positions
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top= intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.All, ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center= intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.All, ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom= intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.All, ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top=intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.All,ModifiedTrialSets.ByTargetposition.ByHeight.Top);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center=intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.All,ModifiedTrialSets.ByTargetposition.ByHeight.Center);
ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom=intersect(ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.All,ModifiedTrialSets.ByTargetposition.ByHeight.Bottom);

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

Type11=intersect(Reward_SideA1_Trials,Reward_SideB1_Trials);
Type22=intersect(Reward_SideA2_Trials,Reward_SideB2_Trials);
Type34=intersect(Reward_SideA3_Trials,Reward_SideB4_Trials);
Type43=intersect(Reward_SideA4_Trials,Reward_SideB3_Trials);

%The 4 Reward contingencies in joint, non-instructed trials
%ModifiedTrialSets.ByRewardType.Type11=intersect(Type11,SuccessfulChoiceTrials);
% ModifiedTrialSets.ByRewardType.UnBlockedTrials.Type11=intersect(Type11,SuccessfulChoiceTrials_UnBlockedTrials);
% ModifiedTrialSets.ByRewardType.UnBlockedTrials.Type22=intersect(Type22,SuccessfulChoiceTrials_UnBlockedTrials);
% ModifiedTrialSets.ByRewardType.UnBlockedTrials.Type34=intersect(Type34,SuccessfulChoiceTrials_UnBlockedTrials);
% ModifiedTrialSets.ByRewardType.UnBlockedTrials.Type43=intersect(Type43,SuccessfulChoiceTrials_UnBlockedTrials);
% 
% 
% ModifiedTrialSets.ByRewardType.BlockedTrials.Type11=intersect(Type11,SuccessfulChoiceTrials_BlockedTrials);
% ModifiedTrialSets.ByRewardType.BlockedTrials.Type22=intersect(Type22,SuccessfulChoiceTrials_BlockedTrials);
% ModifiedTrialSets.ByRewardType.BlockedTrials.Type34=intersect(Type34,SuccessfulChoiceTrials_BlockedTrials);
% ModifiedTrialSets.ByRewardType.BlockedTrials.Type43=intersect(Type43,SuccessfulChoiceTrials_BlockedTrials);



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
%A_Own_B_Own = intersect (ModifiedTrialSets.ByColourSelected.A.Red, ModifiedTrialSets.ByColourSelected.A.Yellow); 
%A_OtherB_Other= intersect (ModifiedTrialSets.ByColourSelected.A.Yellow,ModifiedTrialSets.ByColourSelected.A.Red);

%create a string with our color representations of the 4 choice combinations
NumTrials = size(maintask_datastruct.report_struct.data(:,2));
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

post_one_trial_switching_blocked_RB = (ModifiedTrialSets.BySwitchingBlock.BlockedTrials.RB)+1;
post_one_trial_switching_blocked_RB = post_one_trial_switching_blocked_RB(ismember(post_one_trial_switching_blocked_RB, SuccessfulChoiceTrials_BlockedTrials));

post_two_trial_switching_blocked_RB = (ModifiedTrialSets.BySwitchingBlock.BlockedTrials.RB)+2;
post_two_trial_switching_blocked_RB = post_two_trial_switching_blocked_RB(ismember(post_two_trial_switching_blocked_RB, SuccessfulChoiceTrials_BlockedTrials));

post_switching_blocked_RB = union (post_one_trial_switching_blocked_RB,post_two_trial_switching_blocked_RB);
switch_post_switch_blocked_RB = union(post_switching_blocked_RB,ModifiedTrialSets.BySwitchingBlock.BlockedTrials.RB);

ModifiedTrialSets.BySwitch_PostSwitching.Blocked.RB = switch_post_switch_blocked_RB;
ModifiedTrialSets.BySwitch_PostSwitching.Blocked.RB = post_one_trial_switching_blocked_RB;


ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR = switching_number_blockedtrial_BR;
post_one_trial_switching_blocked_BR = (ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR)+1;
post_one_trial_switching_blocked_BR = post_one_trial_switching_blocked_BR(ismember(post_one_trial_switching_blocked_BR, SuccessfulChoiceTrials_BlockedTrials));

post_two_trial_switching_blocked_BR = (ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR)+2;
post_two_trial_switching_blocked_BR = post_two_trial_switching_blocked_BR(ismember(post_two_trial_switching_blocked_BR, SuccessfulChoiceTrials_BlockedTrials));

post_switching_blocked_BR = union (post_one_trial_switching_blocked_BR,post_two_trial_switching_blocked_BR);
switch_post_switch_blocked_BR = union(post_one_trial_switching_blocked_BR,ModifiedTrialSets.BySwitchingBlock.BlockedTrials.BR);

ModifiedTrialSets.BySwitch_PostSwitching.Blocked.BR = switch_post_switch_blocked_BR; 
ModifiedTrialSets.BySwitch_PostSwitching.Blocked.BR = post_one_trial_switching_blocked_BR;

pattern_in_class_string_struct_unblocked = fn_extract_switches_from_classifier_string(choice_combination_color_string(SuccessfulChoiceTrials_UnBlockedTrials));

switching_number_unblockedtrial_RB = ModifiedTrialSets.SuccessfulChoiceTrials_UnBlockedTrials(pattern_in_class_string_struct_unblocked.RB);
switching_number_unblockedtrial_BR = ModifiedTrialSets.SuccessfulChoiceTrials_UnBlockedTrials(pattern_in_class_string_struct_unblocked.BR);

ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB = switching_number_unblockedtrial_RB;
post_one_trial_switching_unblocked_RB = (ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB)+1;
post_one_trial_switching_unblocked_RB = post_one_trial_switching_unblocked_RB(ismember(post_one_trial_switching_unblocked_RB, SuccessfulChoiceTrials_UnBlockedTrials));
post_two_trial_switching_unblocked_RB = (ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB)+2;
post_two_trial_switching_unblocked_RB = post_two_trial_switching_unblocked_RB(ismember(post_two_trial_switching_unblocked_RB, SuccessfulChoiceTrials_UnBlockedTrials));

post_switching_unblocked_RB = union (post_one_trial_switching_unblocked_RB, post_two_trial_switching_unblocked_RB);
switch_post_switch_unblocked_RB = union(post_switching_unblocked_RB, ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.RB);

ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.RB = switch_post_switch_unblocked_RB; 
ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.RB = post_one_trial_switching_unblocked_RB; 

ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR = switching_number_unblockedtrial_BR;

post_one_trial_switching_unblocked_BR = (ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR)+1;
post_one_trial_switching_unblocked_BR = post_one_trial_switching_unblocked_BR(ismember(post_one_trial_switching_unblocked_BR, SuccessfulChoiceTrials_UnBlockedTrials));


post_two_trial_switching_unblocked_BR = (ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR)+2;
post_two_trial_switching_unblocked_BR = post_two_trial_switching_unblocked_BR(ismember(post_two_trial_switching_unblocked_BR, SuccessfulChoiceTrials_UnBlockedTrials));

post_switching_unblocked_BR = union (post_one_trial_switching_unblocked_BR, post_two_trial_switching_unblocked_BR);
switch_post_switch_unblocked_BR = union(post_switching_unblocked_BR, ModifiedTrialSets.BySwitchingBlock.UnBlockedTrials.BR);

ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.BR = switch_post_switch_unblocked_BR; 
ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.BR = post_one_trial_switching_unblocked_BR;


%The 4 Reward contingencies in joint, non-instructed trials
%ModifiedTrialSets.ByRewardType.Type11=intersect(Type11,SuccessfulChoiceTrials);
% ModifiedTrialSets.ByRewardType.UnBlockedTrials.Type11=intersect(Type11,SuccessfulChoiceTrials_UnBlockedTrials);
% ModifiedTrialSets.ByRewardType.UnBlockedTrials.Type22=intersect(Type22,SuccessfulChoiceTrials_UnBlockedTrials);
% ModifiedTrialSets.ByRewardType.UnBlockedTrials.Type34=intersect(Type34,SuccessfulChoiceTrials_UnBlockedTrials);
% ModifiedTrialSets.ByRewardType.UnBlockedTrials.Type43=intersect(Type43,SuccessfulChoiceTrials_UnBlockedTrials);


% ModifiedTrialSets.ByRewardType.BlockedTrials.Type11=intersect(Type11,SuccessfulChoiceTrials_BlockedTrials);
% ModifiedTrialSets.ByRewardType.BlockedTrials.Type22=intersect(Type22,SuccessfulChoiceTrials_BlockedTrials);
% ModifiedTrialSets.ByRewardType.BlockedTrials.Type34=intersect(Type34,SuccessfulChoiceTrials_BlockedTrials);
% ModifiedTrialSets.ByRewardType.BlockedTrials.Type43=intersect(Type43,SuccessfulChoiceTrials_BlockedTrials);


%ModifiedTrialSets.ByRewardType.Type11=intersect(Type11,SuccessfulChoiceTrials);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type11 = intersect(Type11, ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.RB);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type22 = intersect(Type22, ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.RB);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type34 = intersect(Type34, ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.RB);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type43 = intersect(Type43, ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.RB);

ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type11=intersect(Type11,ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.BR);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type22=intersect(Type22,ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.BR);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type34=intersect(Type34,ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.BR);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type43=intersect(Type43,ModifiedTrialSets.BySwitch_PostSwitching.Unblocked.BR);


ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type11=intersect(Type11,ModifiedTrialSets.BySwitch_PostSwitching.Blocked.RB);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type22=intersect(Type22,ModifiedTrialSets.BySwitch_PostSwitching.Blocked.RB);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type34=intersect(Type34,ModifiedTrialSets.BySwitch_PostSwitching.Blocked.RB);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type43=intersect(Type43,ModifiedTrialSets.BySwitch_PostSwitching.Blocked.RB);

ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type11=intersect(Type11,ModifiedTrialSets.BySwitch_PostSwitching.Blocked.BR);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type22=intersect(Type22,ModifiedTrialSets.BySwitch_PostSwitching.Blocked.BR);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type34=intersect(Type34,ModifiedTrialSets.BySwitch_PostSwitching.Blocked.BR);
ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type43=intersect(Type43,ModifiedTrialSets.BySwitch_PostSwitching.Blocked.BR);

%By position and colour selected
ModifiedTrialSets.ByPositionAndColor_ASelected.Type231=intersect(ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top, ModifiedTrialSets.ByColourSelected.A.Red);

%By SelectedTarget
%The own/other colour & stimulus position
% ModifiedTrialSets.Byrewardttype_pos.Names={'ModifiedTrialSets.Byrewardttype_pos.Type6401','ModifiedTrialSets.Byrewardttype_pos.Type6402',...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6403',...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6404','ModifiedTrialSets.Byrewardttype_pos.Type6405',...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6406','ModifiedTrialSets.Byrewardttype_pos.Type6407'...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6408','ModifiedTrialSets.Byrewardttype_pos.Type6409'...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6410','ModifiedTrialSets.Byrewardttype_pos.Type6411'...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6412','ModifiedTrialSets.Byrewardttype_pos.Type6413'...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6414','ModifiedTrialSets.Byrewardttype_pos.Type6415'...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6416','ModifiedTrialSets.Byrewardttype_pos.Type6417'...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6418','ModifiedTrialSets.Byrewardttype_pos.Type6419'...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6420','ModifiedTrialSets.Byrewardttype_pos.Type6421'...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6422','ModifiedTrialSets.Byrewardttype_pos.Type6423'...
%     'ModifiedTrialSets.Byrewardttype_pos.Type6424'};


%The own/other colour and stimulus position during post switching trials
%from red to blue in the blocked condition 
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6401 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6402 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6403 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6404 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6405 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6406 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6407 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6408 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6409 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6410 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6411 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6412 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6413 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6414 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6415 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6416 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6417 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6418 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6419 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6420 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6421 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6422 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6423 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6424 = intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOther

%The own/other colour and stimulus position during post switching trials
%from blue to red in the blocked condition 

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6401=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6402=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6403=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6404=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6405=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6406=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Blocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOther


%%The own/other colour and stimulus position during post switching trials
%from red to blue in the unblocked condition 

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6401=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6402=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6403=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6404=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6405=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6406=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.RB.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOther

%The own/other colour and stimulus position during post switching trials
%from blue to red in the unblocked condition 

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6401=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6402=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6403=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6404=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6405=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6406=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6407=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6408=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6409=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6410=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6411=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6412=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6413=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6414=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6415=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6416=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6417=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6418=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6419=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6420=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6421=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6422=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6423=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6424=intersect(ModifiedTrialSets.ByRewardType.BySwitch_PostSwitching.Unblocked.BR.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOther

%By whether the selected target is on TopRight;TopLeft;
%CenterRight;CenterLeft; BottomRight; Bottom Left and the 4 combinations of
%OwnOwn;OwnOther;OtherOwn;OtherOther
%Post switch RB blocked 

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6413 = ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.RB.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6412;

%Post switch BR blocked 
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6413=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Blocked.BR.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6412;


%By whether the selected target is on TopRight;TopLeft;
%CenterRight;CenterLeft; BottomRight; Bottom Left and the 4 combinations of
%OwnOwn;OwnOther;OtherOwn;OtherOther
%%Post switch RB unblocked 

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6413=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6412;


%Post switch BR unblocked 
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6401=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6402=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6403=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6404=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6405=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6406=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6407=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6408=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6409=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6410=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6411=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6412=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6413=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6414=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6415=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6416=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6417=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6418=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6419=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6420=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6421=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6422=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6423=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.BySwitch_PostSwitching_Unblocked.BR.Type6424=ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6412;

%Stimulus position : left/right
%unblocked blue to red  
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.BR.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%unblocked red to blue
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Unblocked.RB.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected


%Stimulus position : left/right
%blocked
%unblocked blue to red  
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.BR.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%unblocked red to blue
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6405,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6406,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6407,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6408,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6417,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6418,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6419,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6420,ModifiedTrialSets.Byrewardttype_pos.BySwitch_PostSwitching.Blocked.RB.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected




%%For Trials when Right Side was selected and Left side was selected-
%%irrespective of which value combination it is. 

%Unblocked red to blue 
ModifiedTrialSets.BySelectedSideA.BySwitch_PostSwitching_UnBlocked.RB.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitch_PostSwitching_UnBlocked.RB.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2406))); %A_SelectedLEFT side

%unblocked blue to red 
ModifiedTrialSets.BySelectedSideA.BySwitch_PostSwitching_UnBlocked.BR.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitch_PostSwitching_UnBlocked.BR.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Unblocked.BR.Type2406))); %A_SelectedLEFT side

%Blocked red to blue
ModifiedTrialSets.BySelectedSideA.BySwitch_PostSwitching_Blocked.RB.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitch_PostSwitching_Blocked.RB.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.RB.Type2406))); %A_SelectedLEFT side

%blocked blue to red 
ModifiedTrialSets.BySelectedSideA.BySwitch_PostSwitching_Blocked.BR.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.BySwitch_PostSwitching_Blocked.BR.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.BySwitch_PostSwitching_Blocked.BR.Type2406))); %A_SelectedLEFT side


return
end


 
 