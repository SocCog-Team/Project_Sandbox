function [ModifiedTrialSets]=tn_segregateTrialData(maintask_datastruct)
addpath('C:\Users\Tarana\SCP_Code\SessionDataAnalysis\IndividualSessionAnalyses');
[ ModifiedTrialSets ] = fnCollectTrialSets( maintask_datastruct.report_struct );  
%Joint successful trials- Trials which are jointly played, are
%non-instructed and both players are rewarded in it
ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial=ModifiedTrialSets.ByJointness.DualSubjectJointTrials
LastJointTrial=length(ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial);
ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial(LastJointTrial)=NaN;
Joint_choicetargets=intersect(ModifiedTrialSets.ByJointness.DualSubjectJointTrialsRemovedLastTrial,ModifiedTrialSets.ByChoices.NumChoices02);
bothrewarded=intersect(ModifiedTrialSets.ByOutcome.SideA.REWARD, ModifiedTrialSets.ByOutcome.SideB.REWARD);
SuccessfulChoiceTrials=intersect(Joint_choicetargets,bothrewarded);
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
ModifiedTrialSets.ByRewardType.Type11=intersect(Type11,SuccessfulChoiceTrials);
ModifiedTrialSets.ByRewardType.Type22=intersect(Type22,SuccessfulChoiceTrials);
ModifiedTrialSets.ByRewardType.Type34=intersect(Type34,SuccessfulChoiceTrials);
ModifiedTrialSets.ByRewardType.Type43=intersect(Type43,SuccessfulChoiceTrials);

%By colour selcted
ModifiedTrialSets.ByColourSelected.A.Red=union(ModifiedTrialSets.ByRewardType.Type22,ModifiedTrialSets.ByRewardType.Type43);
ModifiedTrialSets.ByColourSelected.A.Yellow=union(ModifiedTrialSets.ByRewardType.Type11,ModifiedTrialSets.ByRewardType.Type34);
ModifiedTrialSets.ByColourSelected.B.Red=union(ModifiedTrialSets.ByRewardType.Type11,ModifiedTrialSets.ByRewardType.Type43);
ModifiedTrialSets.ByColourSelected.B.Yellow=union(ModifiedTrialSets.ByRewardType.Type22,ModifiedTrialSets.ByRewardType.Type34);

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

ModifiedTrialSets.Byrewardttype_pos.Type6401=intersect(ModifiedTrialSets.ByRewardType.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6402=intersect(ModifiedTrialSets.ByRewardType.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Toprightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Type6403=intersect(ModifiedTrialSets.ByRewardType.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6404=intersect(ModifiedTrialSets.ByRewardType.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top);%Topleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Type6405=intersect(ModifiedTrialSets.ByRewardType.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6406=intersect(ModifiedTrialSets.ByRewardType.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Type6407=intersect(ModifiedTrialSets.ByRewardType.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6408=intersect(ModifiedTrialSets.ByRewardType.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center);%Centerleftselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Type6409=intersect(ModifiedTrialSets.ByRewardType.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6410=intersect(ModifiedTrialSets.ByRewardType.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomrightselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Type6411=intersect(ModifiedTrialSets.ByRewardType.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6412=intersect(ModifiedTrialSets.ByRewardType.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom);%Bottomleftselected_AOtherBOther




ModifiedTrialSets.Byrewardttype_pos.Type6413=intersect(ModifiedTrialSets.ByRewardType.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6414=intersect(ModifiedTrialSets.ByRewardType.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Topleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Type6415=intersect(ModifiedTrialSets.ByRewardType.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6416=intersect(ModifiedTrialSets.ByRewardType.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top);%Toprightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Type6417=intersect(ModifiedTrialSets.ByRewardType.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6418=intersect(ModifiedTrialSets.ByRewardType.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Type6419=intersect(ModifiedTrialSets.ByRewardType.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6420=intersect(ModifiedTrialSets.ByRewardType.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center);%Centerrightselected_AOtherBOther

ModifiedTrialSets.Byrewardttype_pos.Type6421=intersect(ModifiedTrialSets.ByRewardType.Type22, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6422=intersect(ModifiedTrialSets.ByRewardType.Type43, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomleftselected_AOwnBOther
ModifiedTrialSets.Byrewardttype_pos.Type6423=intersect(ModifiedTrialSets.ByRewardType.Type34, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOwn
ModifiedTrialSets.Byrewardttype_pos.Type6424=intersect(ModifiedTrialSets.ByRewardType.Type11, ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom);%Bottomrightselected_AOtherBOther



%By whether the selected target is on TopRight;TopLeft;
%CenterRight;CenterLeft; BottomRight; Bottom Left and the 4 combinations of
%OwnOwn;OwnOther;OtherOwn;OtherOther

ModifiedTrialSets.ByChoicePositionColourReward.Type6401=ModifiedTrialSets.Byrewardttype_pos.Type6401;
ModifiedTrialSets.ByChoicePositionColourReward.Type6402=ModifiedTrialSets.Byrewardttype_pos.Type6402;
ModifiedTrialSets.ByChoicePositionColourReward.Type6403=ModifiedTrialSets.Byrewardttype_pos.Type6415;
ModifiedTrialSets.ByChoicePositionColourReward.Type6404=ModifiedTrialSets.Byrewardttype_pos.Type6416;

ModifiedTrialSets.ByChoicePositionColourReward.Type6405=ModifiedTrialSets.Byrewardttype_pos.Type6413;
ModifiedTrialSets.ByChoicePositionColourReward.Type6406=ModifiedTrialSets.Byrewardttype_pos.Type6414;
ModifiedTrialSets.ByChoicePositionColourReward.Type6407=ModifiedTrialSets.Byrewardttype_pos.Type6403;
ModifiedTrialSets.ByChoicePositionColourReward.Type6408=ModifiedTrialSets.Byrewardttype_pos.Type6404;

ModifiedTrialSets.ByChoicePositionColourReward.Type6409=ModifiedTrialSets.Byrewardttype_pos.Type6405;
ModifiedTrialSets.ByChoicePositionColourReward.Type6410=ModifiedTrialSets.Byrewardttype_pos.Type6406;
ModifiedTrialSets.ByChoicePositionColourReward.Type6411=ModifiedTrialSets.Byrewardttype_pos.Type6419;
ModifiedTrialSets.ByChoicePositionColourReward.Type6412=ModifiedTrialSets.Byrewardttype_pos.Type6420;

ModifiedTrialSets.ByChoicePositionColourReward.Type6413=ModifiedTrialSets.Byrewardttype_pos.Type6417;
ModifiedTrialSets.ByChoicePositionColourReward.Type6414=ModifiedTrialSets.Byrewardttype_pos.Type6418;
ModifiedTrialSets.ByChoicePositionColourReward.Type6415=ModifiedTrialSets.Byrewardttype_pos.Type6407;
ModifiedTrialSets.ByChoicePositionColourReward.Type6416=ModifiedTrialSets.Byrewardttype_pos.Type6408;

ModifiedTrialSets.ByChoicePositionColourReward.Type6417=ModifiedTrialSets.Byrewardttype_pos.Type6409;
ModifiedTrialSets.ByChoicePositionColourReward.Type6418=ModifiedTrialSets.Byrewardttype_pos.Type6410;
ModifiedTrialSets.ByChoicePositionColourReward.Type6419=ModifiedTrialSets.Byrewardttype_pos.Type6423;
ModifiedTrialSets.ByChoicePositionColourReward.Type6420=ModifiedTrialSets.Byrewardttype_pos.Type6424;

ModifiedTrialSets.ByChoicePositionColourReward.Type6421=ModifiedTrialSets.Byrewardttype_pos.Type6421;
ModifiedTrialSets.ByChoicePositionColourReward.Type6422=ModifiedTrialSets.Byrewardttype_pos.Type6422;
ModifiedTrialSets.ByChoicePositionColourReward.Type6423=ModifiedTrialSets.Byrewardttype_pos.Type6411;
ModifiedTrialSets.ByChoicePositionColourReward.Type6424=ModifiedTrialSets.Byrewardttype_pos.Type6412;


%
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2401=union(ModifiedTrialSets.Byrewardttype_pos.Type6401,union(ModifiedTrialSets.Byrewardttype_pos.Type6405,ModifiedTrialSets.Byrewardttype_pos.Type6409)); %OwnOwn_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2402=union(ModifiedTrialSets.Byrewardttype_pos.Type6402,union(ModifiedTrialSets.Byrewardttype_pos.Type6406,ModifiedTrialSets.Byrewardttype_pos.Type6410)); %OwnOther_RedOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2403=union(ModifiedTrialSets.Byrewardttype_pos.Type6403,union(ModifiedTrialSets.Byrewardttype_pos.Type6407,ModifiedTrialSets.Byrewardttype_pos.Type6411)); %OtherOwn_RedOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2404=union(ModifiedTrialSets.Byrewardttype_pos.Type6404,union(ModifiedTrialSets.Byrewardttype_pos.Type6408,ModifiedTrialSets.Byrewardttype_pos.Type6412)); %OtherOther_RedOnObjectiveRight_A_LeftSelected

ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2405=union(ModifiedTrialSets.Byrewardttype_pos.Type6413,union(ModifiedTrialSets.Byrewardttype_pos.Type6417,ModifiedTrialSets.Byrewardttype_pos.Type6421)); %OwnOwn_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2406=union(ModifiedTrialSets.Byrewardttype_pos.Type6414,union(ModifiedTrialSets.Byrewardttype_pos.Type6418,ModifiedTrialSets.Byrewardttype_pos.Type6422)); %OwnOther_YellowOnObjectiveRight_A_LeftSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2407=union(ModifiedTrialSets.Byrewardttype_pos.Type6415,union(ModifiedTrialSets.Byrewardttype_pos.Type6419,ModifiedTrialSets.Byrewardttype_pos.Type6423)); %OtherOwn_YellowOnObjectiveRight_A_RightSelected
ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2408=union(ModifiedTrialSets.Byrewardttype_pos.Type6416,union(ModifiedTrialSets.Byrewardttype_pos.Type6420,ModifiedTrialSets.Byrewardttype_pos.Type6424)); %OtherOther_YellowOnObjectiveRight_A_RightSelected

%%For Trials when Right Side was selected and Left side was selected-
%%irrespective of which value combination it is. 
ModifiedTrialSets.BySelectedSideA.Type1201=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2401,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2402,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2407, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2408))); %A_SelectedRIGHT side
ModifiedTrialSets.BySelectedSideA.Type1202=union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2403,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2404,union(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2405, ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.Type2406))); %A_SelectedLEFT side




%For the human pair with RN_LA 13.03
ModifiedTrialSets.ForRNLA1303.Block1= intersect(SuccessfulChoiceTrials, (1:1:20));
ModifiedTrialSets.ForRNLA1303.Block2= intersect(SuccessfulChoiceTrials, (25:1:41));
ModifiedTrialSets.ForRNLA1303.Block3= intersect(SuccessfulChoiceTrials, (43:1:58));
ModifiedTrialSets.ForRNLA1303.Block4= intersect(SuccessfulChoiceTrials, (59:1:73));
ModifiedTrialSets.ForRNLA1303.Block5= intersect(SuccessfulChoiceTrials, (73:1:90));

reactionTime=transpose([maintask_datastruct.report_struct.data(:,maintask_datastruct.report_struct.cn.A_InitialFixationReleaseTime_ms), maintask_datastruct.report_struct.data(:,maintask_datastruct.report_struct.cn.B_InitialFixationReleaseTime_ms)]);
[pSee] = calc_probabilities_to_see( reactionTime, 50 );
pSee=transpose(pSee);
pSeeGreaterThanChanceA=find(pSee(:,1)>0.5);
pSeeGreaterThanChanceB=find(pSee(:,2)>0.5);
pSeeLesserThanChanceA=find(pSee(:,1)<=0.5);
pSeeLesserThanChanceB=find(pSee(:,2)<=0.5);

ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6401=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6401);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6402=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6402);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6403=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6403);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6404=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6404);

ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6405=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6405);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6406=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6406);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6407=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6407);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6408=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6408);

ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6409=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6409);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6410=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6410);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6411=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6411);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6412=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6412);

ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6413=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6413);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6414=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6414);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6415=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6415);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6416=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6416);

ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6417=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6417);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6418=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6418);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6419=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6419);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6420=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6420);

ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6421=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6421);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6422=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6422);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6423=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6423);
ModifiedTrialSets.pSee.GreaterThanChanceA.Byrewardttype_posType6424=intersect(pSeeGreaterThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6424);

ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6401=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6401);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6402=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6402);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6403=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6403);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6404=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6404);

ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6405=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6405);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6406=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6406);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6407=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6407);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6408=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6408);

ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6409=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6409);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6410=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6410);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6411=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6411);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6412=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6412);

ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6413=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6413);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6414=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6414);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6415=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6415);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6416=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6416);

ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6417=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6417);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6418=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6418);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6419=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6419);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6420=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6420);

ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6421=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6421);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6422=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6422);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6423=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6423);
ModifiedTrialSets.pSee.LesserThanChanceA.Byrewardttype_posType6424=intersect(pSeeLesserThanChanceA, ModifiedTrialSets.Byrewardttype_pos.Type6424);


%%By colour selected
BlockChangesRedtoBlue=find(diff(ModifiedTrialSets.ByColourSelected.B.Red(:,1))>1);
BlockChangesBluetoRed=find(diff(ModifiedTrialSets.ByColourSelected.B.Yellow(:,1))>1);
ModifiedTrialSets.ChangeofBlockTrials.RedtoBlue=ModifiedTrialSets.ByColourSelected.B.Red(BlockChangesRedtoBlue,1);
ModifiedTrialSets.ChangeofBlockTrials.BluetoRed=ModifiedTrialSets.ByColourSelected.B.Yellow(BlockChangesBluetoRed,1);

for block=1:size(ModifiedTrialSets.ChangeofBlockTrials.RedtoBlue,1)-1
    
    if block==1
        blockarrays(block).RedtoBlue=1:1:ModifiedTrialSets.ChangeofBlockTrials.RedtoBlue(block);
    else
        blockarrays(block).RedtoBlue=ModifiedTrialSets.ChangeofBlockTrials.RedtoBlue(block):1:ModifiedTrialSets.ChangeofBlockTrials.RedtoBlue(block+1);
    
    end
end

for block=1:size(ModifiedTrialSets.ChangeofBlockTrials.BluetoRed,1)-1
    if block==1
        blockarrays(block).BluetoRed=1:1:ModifiedTrialSets.ChangeofBlockTrials.BluetoRed(block);
    else
        blockarrays(block).BluetoRed=ModifiedTrialSets.ChangeofBlockTrials.BluetoRed(block):1:ModifiedTrialSets.ChangeofBlockTrials.BluetoRed(block+1);
    end
end


ModifiedTrialSets.ConfederateBlocking=blockarrays;

 end
 