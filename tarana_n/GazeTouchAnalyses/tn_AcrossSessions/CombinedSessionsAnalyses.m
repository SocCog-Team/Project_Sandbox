
saving_dir='C:\Users\Tarana\SCP_Code\tn_PermutationTesting';
addpath('C:\Users\Tarana\SCP_Code\tn_PermutationTesting');
filename='LateSessionsCombined.mat';
load(fullfile(saving_dir,filename));
FullStructure=LateSessions.ClubbedSessions.BIFR.ValueSidepSeePlus50;
[BIFRValueSidepSeePlus50scores, FullStructure]=tn_StructureDataforPermTest(FullStructure);
tn_PlotAvgCombined (FullStructure,saving_dir, filename)