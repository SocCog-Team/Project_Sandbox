function [ ] = rn_reaction_times()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ~exist('fileID', 'var') || isempty(fileID)
	fileID = '20190320T095244.A_Elmo.B_JK.SCP_01';
end

if ~exist('gazereg_name', 'var') || isempty(gazereg_name)
	gazereg_name = 'GAZEREG.SID_20190320T092435.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat';
end

year_string = fileID(1:4);
date_string = fileID(3:8);

if (ispc)
	saving_dir='C:\taskcontroller\SCP_DATA\ANALYSES\GazeAnalyses';
	data_root_str = fullfile('C:', 'SCP');
	data_base_dir = fullfile('Y:');
else
	data_root_str = '/';
	data_base_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ');
	% network!
	data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data', 'taskcontroller');
end

data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, [fileID, '.sessiondir']);


output_dir = pwd;

gazereg_FQN = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', year_string, date_string, gazereg_name);

maintask_datastruct = fnParseEventIDEReportSCPv06(fullfile(data_dir, [fileID, '.triallog']));
EyeLinkfilenameA= fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_EyeLinkProxyTrackerA.trackerlog']);
data_struct_extract = fnParseEventIDETrackerLog_v01 (EyeLinkfilenameA, ';', [], []);

PQtrackerfilenameA = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_PQLabTrackerA.trackerlog']);
touchtracker_datastructA = fnParseEventIDETrackerLog_v01 (PQtrackerfilenameA, ';', [], []);

PQtrackerfilenameB = fullfile(data_dir, 'trackerlogfiles', [fileID, '.TID_SecondaryPQLabTrackerB.trackerlog']);
touchtracker_datastructB = fnParseEventIDETrackerLog_v01 (PQtrackerfilenameB, ';', [], []);

sessionID_list = {'20190320T095244.A_Elmo.B_JK.SCP_01',...
	'20190321T083454.A_Elmo.B_JK.SCP_01',...
	'20190322T083726.A_Elmo.B_JK.SCP_01',...
	'20190329T112049.A_Elmo.B_SM.SCP_01',...
	'20190403T090741.A_Elmo.B_JK.SCP_01',...
	'20190404T090735.A_Elmo.B_JK.SCP_01'};

gazereg_list = {'GAZEREG.SID_20190320T092435.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190321T072108.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190322T071957.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190329T111602.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190403T073047.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat',...
	'GAZEREG.SID_20190404T083605.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTElmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat'};

[maintask_datastruct, data_struct_extract, touchtracker_datastructA, touchtracker_datastructB, recalibration_struct] = fn_merging_session(sessionID_list,gazereg_list);
saving_dir = fullfile(data_root_str, 'Users', 'rnocerino', 'DPZ', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'GazeAnalyses_RN', 'Elmo_JK_merged_all', 'Merged Heights plots');

nrows_eyetracker = 0;
ncols_eyetracker = 0;
[nrows_eyetracker, ncols_eyetracker] = size(data_struct_extract.data);

nrows_maintask = 0;
ncols_maintask = 0;
[nrows_maintask, ncols_maintask] = size(maintask_datastruct.report_struct.data);

ModifiedTrialSets = rn_segregateTrialData_monkey_pair( maintask_datastruct);

% reaction time
A_InitialTargetReleaseRT = maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.A_InitialFixationReleaseTime_ms) - maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.A_TargetOnsetTime_ms);
B_InitialTargetReleaseRT = maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.B_InitialFixationReleaseTime_ms) - maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.B_TargetOnsetTime_ms);
A_TargetAcquisitionRT = maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.A_TargetTouchTime_ms) - maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.A_TargetOnsetTime_ms);
B_TargetAcquisitionRT = maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.B_TargetTouchTime_ms) - maintask_datastruct.report_struct.data(:, maintask_datastruct.report_struct.cn.B_TargetOnsetTime_ms);

% InitialTargetRelease reaction time plus half of the movement time
A_IniTargRel_05MT_RT = A_InitialTargetReleaseRT + 0.5 * (A_TargetAcquisitionRT - A_InitialTargetReleaseRT);
B_IniTargRel_05MT_RT = B_InitialTargetReleaseRT + 0.5 * (B_TargetAcquisitionRT - B_InitialTargetReleaseRT);

A_RT_data_ms = A_IniTargRel_05MT_RT;
B_RT_data_ms = B_IniTargRel_05MT_RT;

A_RT_data_s = A_RT_data_ms / 1000;
B_RT_data_s = B_RT_data_ms/1000;

% Intersection between the unblocked trials and the three heights when red
% is on the objective right
SuccessfulChoiceTrialsUnblocked_Right_Top = intersect(ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked,ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Top_all);
SuccessfulChoiceTrialsUnblocked_Right_Center = intersect(ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked,ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Center_all);
SuccessfulChoiceTrialsUnblocked_Right_Bottom = intersect(ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked,ModifiedTrialSets.ByTargetposition.ByColour.Red_objectiveright.Bottom_all);

%Intersection between the unblocked trials and the three heights when
%yellow is on the objective right
SuccessfulChoiceTrialsUnblocked_Left_Top = intersect(ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked,ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Top_all);
SuccessfulChoiceTrialsUnblocked_Left_Center = intersect(ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked,ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Center_all);
SuccessfulChoiceTrialsUnblocked_Left_Bottom = intersect(ModifiedTrialSets.SuccessfulChoiceTrialsUnblocked,ModifiedTrialSets.ByTargetposition.ByColour.Yellow_objectiveright.Bottom_all);

binedges = ([-0.2:1]);
Byrewardttype_pos_blocked_Names=fieldnames(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked);
a = 0;
for counter = 1 : 8
	
	Byrewardttype_posSp = Byrewardttype_pos_blocked_Names(counter);
	Byrewardttype_posSpStr = ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.(Byrewardttype_posSp{1});
	TrialLists = Byrewardttype_posSpStr;
	
	
	
	if counter ==1 || counter ==5
		figure()
		set( gcf, 'PaperUnits','centimeters' );
		xSize = 24; ySize = 24;
		xLeft = 0; yTop = 0;
		set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
		
		left_color = [0 0 0];
		right_color = [0 0 0];
		set(figure,'defaultAxesColorOrder',[left_color; right_color]);
		
	end
	
	a=a+1;
	if a>4
		a=1;
	end
	if length(TrialLists)==0
		continue;
	end
	
	subplot(2,2,a);
		
	histogram(A_RT_data_s(TrialLists),'BinLimits',binedges,'FaceColor', 'r');
	hold on
	histogram(B_RT_data_s(TrialLists),'BinLimits',binedges,'FaceColor', 'b');
	
	
	if counter>=1 && counter<=4
		write_out_figure(gcf, fullfile(saving_dir,'RTplushalfmovement_human_monkey_Red_ObjectiveRight.pdf'))
		
	end
	if counter>=5 && counter<=8
		write_out_figure(gcf, fullfile(saving_dir,'RTplushalfmovement_human_monkey_Red_ObjectiveLeft.pdf'))
		
	end
end 


Byrewardttype_pos_blocked_Names=fieldnames(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked);
a = 0;
for counter = 1 : 8
	
	Byrewardttype_posSp = Byrewardttype_pos_blocked_Names(counter);
	Byrewardttype_posSpStr = ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.(Byrewardttype_posSp{1});
	TrialLists = Byrewardttype_posSpStr;
	
	
	
	if counter ==1 || counter ==5
		figure()
		set( gcf, 'PaperUnits','centimeters' );
		xSize = 24; ySize = 24;
		xLeft = 0; yTop = 0;
		set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
		
		left_color = [0 0 0];
		right_color = [0 0 0];
		set(figure,'defaultAxesColorOrder',[left_color; right_color]);
		
	end
	
	a=a+1;
	if a>4
		a=1;
	end
	if length(TrialLists)==0
		continue;
	end
	
	subplot(2,2,a);
		
	A_InitialTargetReleaseRT_s = A_InitialTargetReleaseRT /1000;
	B_InitialTargetReleaseRT_s = B_InitialTargetReleaseRT /1000;
	histogram(A_InitialTargetReleaseRT_s(TrialLists),'BinLimits',binedges,'FaceColor', 'r');
	hold on
	histogram(B_InitialTargetReleaseRT_s(TrialLists),'BinLimits',binedges,'FaceColor', 'b');
	
	
	if counter>=1 && counter<=4
		write_out_figure(gcf, fullfile(saving_dir,'Release_RT_human_monkey_Red_ObjectiveRight.pdf'))
		
	end
	if counter>=5 && counter<=8
		write_out_figure(gcf, fullfile(saving_dir,'Release_RT_human_monkey_Red_ObjectiveLeft.pdf'))
		
	end
end 


Byrewardttype_pos_blocked_Names=fieldnames(ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked);
a = 0;
for counter = 1 : 8
	
	Byrewardttype_posSp = Byrewardttype_pos_blocked_Names(counter);
	Byrewardttype_posSpStr = ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.SuccessfulChoiceTrialsBlocked.(Byrewardttype_posSp{1});
	TrialLists = Byrewardttype_posSpStr;
	
	
	
	if counter ==1 || counter ==5
		figure()
		set( gcf, 'PaperUnits','centimeters' );
		xSize = 24; ySize = 24;
		xLeft = 0; yTop = 0;
		set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
		
		left_color = [0 0 0];
		right_color = [0 0 0];
		set(figure,'defaultAxesColorOrder',[left_color; right_color]);
		
	end
	
	a=a+1;
	if a>4
		a=1;
	end
	if length(TrialLists)==0
		continue;
	end
	
	subplot(2,2,a);
		
	A_TargetAcquisitionRT_s = A_TargetAcquisitionRT /1000;
	B_TargetAcquisitionRT_s = B_TargetAcquisitionRT /1000;
	histogram(A_TargetAcquisitionRT_s(TrialLists),'BinLimits',binedges,'FaceColor', 'r');
	hold on
	histogram(B_TargetAcquisitionRT_s(TrialLists),'BinLimits',binedges,'FaceColor', 'b');
	
	
	if counter>=1 && counter<=4
		write_out_figure(gcf, fullfile(saving_dir,'Acquisition_RT_human_monkey_Red_ObjectiveRight.pdf'))
		
	end
	if counter>=5 && counter<=8
		write_out_figure(gcf, fullfile(saving_dir,'Acquisition_RT_human_monkey_Red_ObjectiveLeft.pdf'))
		
	end
end 

%RIGHT 
for i_unblocked_right_top = 1:length(SuccessfulChoiceTrialsUnblocked_Right_Top)
	TrialList = SuccessfulChoiceTrialsUnblocked_Right_Top(i_unblocked_right_top);
	A_TargetAcquisitionRT_right_top_s(i_unblocked_right_top) = A_TargetAcquisitionRT_s(TrialList);
end
cur_fh = figure('Name', ['TargetAcquisition_RT distribution target right_top']);
histogram(A_TargetAcquisitionRT_right_top_s,'BinLimits',binedges);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition_RT distribution target right_top.pdf'))

for i_unblocked_right_center = 1:length(SuccessfulChoiceTrialsUnblocked_Right_Center)
	TrialList = SuccessfulChoiceTrialsUnblocked_Right_Center(i_unblocked_right_center);
	A_TargetAcquisitionRT_right_center_s(i_unblocked_right_center) = A_TargetAcquisitionRT_s(TrialList);
end
cur_fh = figure('Name', ['RT distribution target right_middle']);
histogram(A_TargetAcquisitionRT_right_center_s,'BinLimits',binedges);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition_RT distribution target right_middle.pdf'))


for i_unblocked_right_bottom = 1:length(SuccessfulChoiceTrialsUnblocked_Right_Bottom)
	TrialList = SuccessfulChoiceTrialsUnblocked_Right_Bottom(i_unblocked_right_bottom);
	A_TargetAcquisitionRT_right_bottom_s(i_unblocked_right_bottom) = A_TargetAcquisitionRT_s(TrialList);
end
cur_fh = figure('Name', ['RT distribution target right_bottom']);
histogram(A_TargetAcquisitionRT_right_bottom_s,'BinLimits',binedges);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition_RT distribution target right_bottom.pdf'));

%LEFT
for i_unblocked_left_top = 1:length(SuccessfulChoiceTrialsUnblocked_Left_Top)
	TrialList = SuccessfulChoiceTrialsUnblocked_Left_Top(i_unblocked_left_top);
	A_TargetAcquisitionRT_left_top_s(i_unblocked_left_top) = A_TargetAcquisitionRT_s(TrialList);
end
cur_fh = figure('Name', ['RT distribution target left_top']);
histogram(A_TargetAcquisitionRT_left_top_s,'BinLimits',binedges);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition_RT distribution target left_top.pdf'));


for i_unblocked_left_center = 1:length(SuccessfulChoiceTrialsUnblocked_Left_Center)
	TrialList = SuccessfulChoiceTrialsUnblocked_Left_Center(i_unblocked_left_center);
	A_TargetAcquisitionRT_left_center_s(i_unblocked_left_center) = A_TargetAcquisitionRT_s(TrialList);
end
cur_fh = figure('Name', ['RT distribution target left_middle']);
histogram(A_TargetAcquisitionRT_left_center_s,'BinLimits',binedges);

write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition_RT distribution target left_middle.pdf'));


for i_unblocked_left_bottom = 1:length(SuccessfulChoiceTrialsUnblocked_Left_Bottom)
	TrialList = SuccessfulChoiceTrialsUnblocked_Left_Bottom(i_unblocked_left_bottom);
	A_TargetAcquisitionRT_left_bottom_s(i_unblocked_left_bottom) = A_TargetAcquisitionRT_s(TrialList);
end
cur_fh = figure('Name', ['RT distribution target left_bottom']);
histogram(A_TargetAcquisitionRT_left_bottom_s,'BinLimits',binedges);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition_RT distribution target left_bottom.pdf'));

%Here, I calculate the statistics both with a parametric test and with a
%non parametric test (Wilcoxon rank sum test)

%Separate comparisons: different heights always on right
%[h_right_top_center_par,p_right_top_center_par,ci_right_top_center_par,stats_right_top_center_par] = ttest2(A_RT_right_top,A_RT_right_center);
[p_right_top_center_notpar,h_right_top_center_notpar,stats_right_top_center_notpar] = ranksum(A_TargetAcquisitionRT_right_top_s,A_TargetAcquisitionRT_right_center_s);

%[h_right_top_bottom_par,p_right_top_bottom_par,ci_right_top_bottom_par,stats_right_top_bottom_par] = ttest2(A_RT_right_top,A_RT_right_bottom);
[p_right_top_bottom_notpar,h_right_top_bottom_notpar,stats_right_top_bottom_notpar] = ranksum(A_TargetAcquisitionRT_right_top_s,A_TargetAcquisitionRT_right_bottom_s);

%[h_right_center_bottom_par,p_right_center_bottom_par,ci_right_center_bottom_par,stats_right_center_bottom_par] = ttest2(A_RT_right_center,A_RT_right_bottom);
[p_right_center_bottom_notpar,h_right_center_bottom_notpar,stats_right_center_bottom_notpar] = ranksum(A_TargetAcquisitionRT_right_center_s,A_TargetAcquisitionRT_right_bottom_s);


%Separate comparisons: different heights on left
%[h_left_top_center_par,p_left_top_center_par,ci_left_top_center_par,stats_left_top_center_par] = ttest2(A_RT_left_top,A_RT_left_center);
[p_left_top_center_notpar,h_left_top_center_notpar,stats_left_top_center_notpar] = ranksum(A_TargetAcquisitionRT_left_top_s,A_TargetAcquisitionRT_left_center_s);

%[h_left_top_bottom_par,p_left_top_bottom_par,ci_left_top_bottom_par,stats_left_top_bottom_par] = ttest2(A_RT_left_top,A_RT_left_bottom);
[p_left_top_bottom_notpar,h_left_top_bottom_notpar,stats_left_top_bottom_notpar] = ranksum(A_TargetAcquisitionRT_left_top_s,A_TargetAcquisitionRT_left_bottom_s);

%[h_left_center_bottom_par,p_left_center_bottom_par,ci_left_center_bottom_par,stats_left_center_bottom_par] = ttest2(A_RT_left_center,A_RT_left_bottom);
[p_left_center_bottom_notpar,h_left_center_bottom_notpar,stats_left_center_bottom_notpar] = ranksum(A_TargetAcquisitionRT_left_center_s,A_TargetAcquisitionRT_left_bottom_s);

%comparison btw left/right along the three different heights

%[h_left_top_right_top_par,p_left_top_right_top_par,ci_left_top_right_top_par,stats_left_top_right_top_par] = ttest2(A_RT_left_top,A_RT_right_top);
[p_left_top_right_top_notpar,h_left_top_right_top_notpar,stats_left_top_right_top_notpar] = ranksum(A_TargetAcquisitionRT_left_top_s,A_TargetAcquisitionRT_right_top_s);

%[h_left_center_right_center_par,p_left_center_right_center_par,ci_left_center_right_center_par,stats_left_center_right_center_par] = ttest2(A_RT_left_center,A_RT_right_center);
[p_left_center_right_center_notpar,h_left_center_right_center_notpar,stats_left_center_right_center_notpar] = ranksum(A_TargetAcquisitionRT_left_center_s,A_TargetAcquisitionRT_right_center_s);

%[h_left_bottom_right_bottom_par,p_left_bottom_right_bottom_par,ci_left_bottom_right_bottom_par,stats_left_bottom_right_bottom_par] = ttest2(A_RT_left_bottom,A_RT_right_bottom);
[p_left_bottom_right_bottom_notpar,h_left_bottom_right_bottom_notpar,stats_left_bottom_right_bottom_notpar] = ranksum(A_TargetAcquisitionRT_left_center_s,A_TargetAcquisitionRT_right_center_s);



%Here I plot the distribution of different combination addind also the p
%value
%Right_top/Right_center
cur_fh = figure('Name', ['TargetAcquisitionRT comparison btw right top and right center']);
histogram(A_TargetAcquisitionRT_right_top_s,'BinLimits',binedges);
hold on 
histogram(A_TargetAcquisitionRT_left_top_s,'BinLimits',binedges);
hold on 
str = strcat({'ranksum: '},num2str(stats_right_top_center_notpar.ranksum),{', p value: '},num2str(p_right_top_center_notpar));
title(str);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition RT comparison btw right top and right center.pdf'))

%Right_top/Right_bottom
cur_fh = figure('Name', ['TargetAcquisitionRT comparison btw right top and right bottom']);
histogram(A_TargetAcquisitionRT_right_top_s,'BinLimits',binedges);
hold on 
histogram(A_TargetAcquisitionRT_right_bottom_s,'BinLimits',binedges);
hold on 
str = strcat({'ranksum : '},num2str(stats_right_top_bottom_notpar.ranksum),{', p value: '},num2str(p_right_top_bottom_notpar));
title(str);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition RT comparison btw right top and right bottom.pdf'))

%Right_center/Right_bottom
cur_fh = figure('Name', ['RT comparison btw right center and right bottom']);
histogram(A_TargetAcquisitionRT_right_center_s,'BinLimits',binedges);
hold on 
histogram(A_TargetAcquisitionRT_right_bottom_s,'BinLimits',binedges);
hold on 
str = strcat({'ranksum : '},num2str(stats_right_center_bottom_notpar.ranksum),{', p value: '},num2str(p_right_center_bottom_notpar));
title(str);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition RT comparison btw right center and right bottom.pdf'))

%Left_top/Right_center
cur_fh = figure('Name', ['TargetAcquisitionRT comparison btw left top and left center']);
histogram(A_TargetAcquisitionRT_left_top_s,'BinLimits',binedges);
hold on 
histogram(A_TargetAcquisitionRT_left_center_s,'BinLimits',binedges);
hold on 
str = strcat({'ranksum : '},num2str(stats_left_top_center_notpar.ranksum),{', p value: '},num2str(p_left_top_center_notpar));
title(str);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition RT comparison btw left top and left center.pdf'))

%Left_top/Right_bottom
cur_fh = figure('Name', ['TargetAcquisitionRT comparison btw left top and left bottom']);
histogram(A_TargetAcquisitionRT_left_top_s,'BinLimits',binedges);
hold on 
histogram(A_TargetAcquisitionRT_left_bottom_s,'BinLimits',binedges);
hold on 
str = strcat({'ranksum : '},num2str(stats_left_top_bottom_notpar.ranksum),{', p value: '},num2str(p_left_top_bottom_notpar));
title(str);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition RT comparison btw left top and left bottom.pdf'))

%Left_center/Right_bottom
cur_fh = figure('Name', ['TargetAcquisitionRT comparison btw left center and left bottom']);
histogram(A_TargetAcquisitionRT_left_center_s,'BinLimits',binedges);
hold on 
histogram(A_TargetAcquisitionRT_left_bottom_s,'BinLimits',binedges);
hold on 
str = strcat({'ranksum : '},num2str(stats_left_center_bottom_notpar.ranksum),{', p value: '},num2str(p_left_center_bottom_notpar));
title(str);
write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition RT comparison btw left center and left bottom.pdf'))


% %Left_center/Right_center
% cur_fh = figure('Name', ['TargetAcquisitionRT comparison btw left center and right center']);
% histogram(A_TargetAcquisitionRT_left_center_s,'BinLimits',binedges);
% hold on 
% histogram(A_TargetAcquisitionRT_right_center_s,'BinLimits',binedges);
% hold on 
% str = strcat({'ranksum : '},num2str(stats_left_center_right_center_notpar.ranksum),{', p value: '},num2str(p_left_center_right_center_notpar));
% title(str);
% write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition RT comparison btw left center and right center.pdf'))
% 
% 
% %Left_top/Right_top
% cur_fh = figure('Name', ['TargetAcquisitionRT comparison btw left top and right top']);
% histogram(A_TargetAcquisitionRT_left_top_s,'BinLimits',binedges);
% hold on 
% histogram(A_TargetAcquisitionRT_right_top_s,'BinLimits',binedges);
% hold on 
% str = strcat({'ranksum : '},num2str(stats_left_top_right_top_notpar.ranksum),{', p value: '},num2str(p_left_top_right_top_notpar));
% title(str);
% write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition RT comparison btw left top and right top.pdf'))
% 
% %Left_bottom/Right_bottom
% cur_fh = figure('Name', ['TargetAcquisitionRT comparison btw left bottom and right bottom']);
% histogram(A_TargetAcquisitionRT_left_bottom_s,'BinLimits',binedges);
% hold on 
% histogram(A_TargetAcquisitionRT_right_bottom_s,'BinLimits',binedges);
% hold on 
% str = strcat({'ranksum : '},num2str(stats_left_bottom_right_bottom_notpar.ranksum),{', p value: '},num2str(p_left_bottom_right_bottom_notpar));
% title(str);
% write_out_figure(cur_fh, fullfile(saving_dir, 'TargetAcquisition RT comparison btw left bottom and rightt bottom.pdf'))
% 
return
end

