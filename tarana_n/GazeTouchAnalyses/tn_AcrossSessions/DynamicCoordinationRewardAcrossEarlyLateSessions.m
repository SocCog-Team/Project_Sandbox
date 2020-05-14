function []=DynamicCoordinationRewardAcrossEarlyLateSessions()
AllSessionMetrics = load ('C:\taskcontroller\SCP_DATA\ANALYSES\ALL_SESSSION_METRICS.all_joint_choice_trials.mat');

SessionsEarlyFilenames={'20181121T091506.A_Elmo.B_SM.SCP_01.triallog',...
    '20181123T121605.A_Elmo.B_SM.SCP_01.triallog',...
    '20181127T093819.A_Elmo.B_SM.SCP_01.triallog',...
    '20181128T094141.A_Elmo.B_SM.SCP_01.triallog',...
    '20181129T092325.A_Elmo.B_SM.SCP_01.triallog'};
SessionsLateFilenames={'20190311T131935.A_Elmo.B_SM.SCP_01.triallog',...
    '20190312T085408.A_Elmo.B_JK.SCP_01.triallog',...
    '20190313T084850.A_Elmo.B_JK.SCP_01.triallog',...
    '20190314T083757.A_Elmo.B_JK.SCP_01.triallog',...
    '20190315T092050.A_Elmo.B_JK.SCP_01.triallog',...
    '20190319T084942.A_Elmo.B_JK.SCP_01.triallog',...
    '20190320T095244.A_Elmo.B_JK.SCP_01.triallog'};


EarlySessions=[127,125,123,121,119];
LateSessions=[60,58,56,54,52,48,46];

EarlySessionsNames=['181121';'181123';'181127';'181128';'181129'];

LateSessionsNames=['190311';'190312';'190313';'190314';'190315';'190319';'190320'];

EarlySessionsAvgReward=AllSessionMetrics.coordination_metrics_table.data(EarlySessions,AllSessionMetrics.coordination_metrics_table.cn.averReward); 
LateSessionsAvgReward=AllSessionMetrics.coordination_metrics_table.data(LateSessions,AllSessionMetrics.coordination_metrics_table.cn.averReward); 


EarlySessionsdltReward=AllSessionMetrics.coordination_metrics_table.data(EarlySessions,AllSessionMetrics.coordination_metrics_table.cn.dltReward); 
LateSessionsdltReward=AllSessionMetrics.coordination_metrics_table.data(LateSessions,AllSessionMetrics.coordination_metrics_table.cn.dltReward); 

EarlySessionsdltRewardCIup=AllSessionMetrics.coordination_metrics_table.data(EarlySessions,AllSessionMetrics.coordination_metrics_table.cn.dltConfInterval_Upper); 
LateSessionsdltRewardCIup=AllSessionMetrics.coordination_metrics_table.data(LateSessions,AllSessionMetrics.coordination_metrics_table.cn.dltConfInterval_Upper); 

EarlySessionsdltRewardCIdown=AllSessionMetrics.coordination_metrics_table.data(EarlySessions,AllSessionMetrics.coordination_metrics_table.cn.dltConfInterval_Lower); 
LateSessionsdltRewardCIdown=AllSessionMetrics.coordination_metrics_table.data(LateSessions,AllSessionMetrics.coordination_metrics_table.cn.dltConfInterval_Lower); 

EarlySessionsdltRewardSign=AllSessionMetrics.coordination_metrics_table.data(EarlySessions,AllSessionMetrics.coordination_metrics_table.cn.dltSignif); 
LateSessionsdltRewardSign=AllSessionMetrics.coordination_metrics_table.data(LateSessions,AllSessionMetrics.coordination_metrics_table.cn.dltSignif); 
figure()
angle=45;
x = 1:5;
subplot(1,2,1)
EarlySessdltReward=bar(x,EarlySessionsdltReward, 0.5);
hold on
er=errorbar(x,EarlySessionsdltReward,EarlySessionsdltRewardCIdown-EarlySessionsdltReward,EarlySessionsdltRewardCIup-EarlySessionsdltReward);
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xSignVals=find(EarlySessionsdltRewardSign==1);
if ~isempty(xSignVals)
    plot(xSignVals,0.8,'*', 'Color', 'k')
end
hold off
ylim([-1 1])
% xlabel(EarlySessionsNames)
xlabel(' Early Sessions', 'FontSize',15);
set(gca, 'XTickLabel', {'181121','181123','181127','181128','181129'});
set(gca,'XTickLabelRotation',angle); 
ylabel ('Dynamic Coordination Reward', 'FontSize',15)


subplot(1,2,2)
x = 1:7;
LateSessdltReward=bar(x,LateSessionsdltReward,0.5);
hold on
er=errorbar(x,LateSessionsdltReward,LateSessionsdltRewardCIdown-LateSessionsdltReward,LateSessionsdltRewardCIup-LateSessionsdltReward);
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xSignVals=find(LateSessionsdltRewardSign==1);
if ~isempty(xSignVals)
    plot(xSignVals,0.8,'*', 'Color', 'k')
end
hold off
ylim([-1 1])
xlabel(LateSessionsNames)
xlabel('Late Sessions', 'FontSize',15);
set(gca,'XTickLabel',{'190311','190312','190313','190314','190315','190319','190320'});
set(gca,'XTickLabelRotation',angle); 
ylabel ('Dynamic Coordination Reward', 'FontSize',15)

saving_dir='C:\taskcontroller\SCP_DATA\ANALYSES\Behavioural Analyses\ElmoConfederateTraining\Combined';
saveas(gcf, fullfile(saving_dir,'DynamicCoordinationRewardEarlyvsLateSession.jpg'));
%        
% annotation('textbox',[.2 .2 .1 .2],'String','','EdgeColor','none')
end
% function str = cell2str(c)
% % Convert a cell array of strings into an array of strings.
% % CELL2STR pads each string in order to force all strings
% % have the same length.
% %
% % Determine the length of each string in cell array c
% nblanks = cellfun(@length, c);
% maxn = max(nblanks);
% nblanks = maxn-nblanks; 
% % Create a cell array of blanks.  Each column of the cell array contains
% % the number of blanks necessary to pad each row of the converted string
% padding = cellfun(@blanks,num2cell(nblanks), 'UniformOutput', false);
% % Concatinate cell array and padding
% str = {c{:}; padding{:}};
% % This operation converts new the cell array into a string
% str = [str{:}];
% % Reshape the string into an array of strings
% ncols = maxn;
% nrows = length(str)/ncols;
% str = reshape(str,ncols,nrows)';
% end