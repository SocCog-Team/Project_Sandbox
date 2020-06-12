% Cluster-based permutation test
%	In order to calculate a statistical difference
%	in ppc between conditions (pre- and post-injection) at every frequency and 
%	adequately deal with the multiple comparison problem, we used the cluster-based 
%	permutation test as described in Maris & Oostenveld, 2007. The idea of cluster-based 
%	correction is that, because of autocorrelation in the data, a finding is significant 
%	if it is ?big enough?, that is, if enough neighboring points also have suprathreshold 
%	values. Individual pixels that are significant are therefore considered false alarms 
%	(Mike X Cohen, ?Analyzing neural time series data?).
%	First, we applied a paired-sample t-test to each frequency point and and classified 
%	every frequency bin with p-value < 0.05 (t-test statistic is larger or smaller 
%	than the critical value +- 1.96 for p-value of 0.05) together with consecutive 
%	time bins with p < 0.05 as one cluster based on the frequency adjacency. Clusters 
%	were defined separately for positive and negative values of t-test statistic. 
%	At this point p-value of 0.05 was used only for the definition of clusters 
%	and not as the final statistical test. The absolute values of t-test statistic were
%	summed within each cluster. Then the summed t-test statistic values was calculated 
%	within each cluster for 1000 permuted data sets. Each permuted data set was created 
%	by randomly rearranging the condition labels of spike-field pairs of the real data. On each
%	permutation step, the cluster with the highest summed statistic value was kept to 
%	create a distribution of t-values (null distribution). This distribution was then 
%	compared to the summed t-value of each cluster in the real data, which was classified as significant
%	when its summed t-value was higher than at least 95% of t-values from the null 
%	distribution (i.e. alpha-level = 0.05). In some cases when a single frequency 
%	was defined as significant because no continuous clusters were identified, these single-frequency significant
%	values were also discarded as false positives


timestamps.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);



% saving_dir = 'C:\Users\Tarana\SCP_Code\tn_PermutationTesting';
% % saving_dir = pwd;
%addpath('C:\Users\Tarana\SCP_Code\tn_PermutationTesting');
saving_dir = 'C:\Users\Tarana\SCP_Code\ModifiedCodefromSebastian\tn_PermutationTesting';
filename = 'EarlySessionsCombined.mat';
load(fullfile(saving_dir,filename));
FullStructure = EarlySessions.ClubbedSessions.BIFR.ValueSidepSeePlus50;
% load('EarlySessions.ClubbedSessions.BIFR.ValueSidepSeePlus50.mat');
[BIFRValueSidepSeePlus50scores, FullStructure] = tn_StructureDataforPermTest(FullStructure);
tn_PlotAvgCombined(abc.FullStructure, saving_dir, filename);





% how long did it take?
timestamps.(mfilename).end = toc(timestamps.(mfilename).start);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end), ' seconds.']);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / 60), ' minutes. Done...']);