

function [] = tn_PlotAvgCombined (FullStructure,saving_dir, fileID)
b = 0;
TrialNumStr = 'No. of Trials= ';

last_a = 7; % 1-8

for a = 1 : last_a
    
    TrialListsAA = FullStructure(a).AA;
    TrialListsAB = FullStructure(a).AB;
    TrialListsTimepoints = FullStructure(a).Timepoints;
    TrialListsAT= FullStructure(a).AT;
    TrialListsAIFR = FullStructure(a).AIFRvalues;
%     TrialListsScores = FullStructure(a).PermScores;
% Names=fieldnames(SampleA);
% b=0;
    
% for a= 1:length(Names)
%     Sp=Names(a);
%     SpSampleA=SampleA.(Sp{1});
%     SpSampleB=SampleB.(Sp{1});
%     SpTimepoints=Timepoints.(Sp{1});
% %     SpScores=Scores.(Sp{1});
%     SpBIFRAlignedAIFR=AIFRsEpoch.(Sp{1});
%     
    
    if (a == 1) || (a == 5) 
        figure()
        set( gcf, 'PaperUnits', 'centimeters' );
        xSize = 24;
		ySize = 24;
        xLeft = 0;
		yTop = 0;
        set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] ); 
    end
    
    
    b = b + 1;
    if b > 4
        b = 1;
	end
	
    AVGBIFRalignedAIFR = mean(TrialListsAIFR, 1, 'omitnan');
    AvgA = mean(TrialListsAA, 1, 'omitnan');
	STD_A = std(TrialListsAA, 'omitnan');
    SEM_A = std(TrialListsAA, 'omitnan') / size(TrialListsAA, 1);
	AA_isNotNaN_array = ~isnan(TrialListsAA);
	AA_N_per_bin_list = sum(AA_isNotNaN_array, 1);
    [A_CIHW95] = calc_cihw(STD_A, AA_N_per_bin_list, 0.05);	
%     [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
    A_CIHW95(A_CIHW95 == 0) = NaN;
	
    AvgB = mean(TrialListsAB, 1, 'omitnan');
    STD_B = std(TrialListsAB, 'omitnan');
    SEM_B = std(TrialListsAB, 'omitnan') / size(TrialListsAB, 1);                         
	AB_isNotNaN_array = ~isnan(TrialListsAB);
	AB_N_per_bin_list = sum(AB_isNotNaN_array, 1);
	[B_CIHW95] = calc_cihw(STD_B, AB_N_per_bin_list, 0.05);	
% 	[B_CIHW95] = calc_cihw(STD_B, (size((TrialListsAB), 1)), 0.05);
    B_CIHW95(B_CIHW95 == 0)= NaN;
    
    AvgT = mean(TrialListsAT, 1, 'omitnan');
	STD_T = std(TrialListsAT, 'omitnan');
    SEM_T = std(TrialListsAA, 'omitnan') / size(TrialListsAT, 1);
	AT_isNotNaN_array = ~isnan(TrialListsAT);
	AT_N_per_bin_list = sum(AT_isNotNaN_array, 1);
    [T_CIHW95] = calc_cihw(STD_T, AT_N_per_bin_list, 0.05);	
%     [A_CIHW95] = calc_cihw(STD_A, (size((TrialListsAA),1)), 0.05);
    T_CIHW95(T_CIHW95 == 0) = NaN;
   
    subplot(2,2,b);
    if a==1
        annotation('textbox',[.9 .8 .1 .2],'String','Red on Objective Right','EdgeColor','none')
    end
    if a==5
        annotation('textbox',[.9 .8 .1 .2],'String','Red on Objective Left','EdgeColor','none')
    end
    annotation('textbox',[.9 .75 .1 .2],'String','pSee higher than chance','EdgeColor','none')
    %annotation('textbox',[.9 .75 .1 .2],'String','pSee lower than chance','EdgeColor','none')
    str=strcat(TrialNumStr, num2str(size((TrialListsAA),1)));
    text(0.70,380,str);
    if b==1
        strCond='A-Own/B-Own';
        text(0.7,420,strCond);
    end
    if b==2
        strCond='A-Own/B-Other';
        text(0.70,420,strCond);
    end
    if b==3
        strCond='A-Other/B-Own';
        text(0.70,420,strCond);
    end
    if b==4
        strCond='A-Other/B-Other';
        text(0.70,420,strCond);
    end
    xlim([-0.2 0.9]);
    ylim([-500 500]);
    yL = get(gca,'YLim');    
    hold on
    line([0 0],yL,'Color','b');
    hold on
    line([AVGBIFRalignedAIFR AVGBIFRalignedAIFR],yL,'Color','r', 'LineStyle', '--');
    xL = get(gca,'XLim');    
    hold on
    line(xL,[0 0],'Color','k');
    hold on
    
%     [Clusters, ListSignClusters]= tn_PlottingClusters(TrialListsScores, TrialListsTimepoints);
%     hold on
%     [AClosertoZero BClosertoZero]=tn_ClosertoZero(AvgA,AvgB, TrialListsTimepoints);
%      hold on
    [AClosertoZero BClosertoZero]=tn_ClosertoZerowithTarget(AvgA,AvgB,AvgT, TrialListsTimepoints);
    hold on
    plot((TrialListsTimepoints(6,:)),AvgA,'Color','r', 'LineWidth',2);
    hold on
    plot((TrialListsTimepoints(6,:)),(AvgA+SEM_A),'Color','r', 'LineWidth',0.5);
    plot((TrialListsTimepoints(6,:)),AvgA-SEM_A,'Color','r', 'LineWidth',0.5);
    hold on
    plot((TrialListsTimepoints(6,:)),AvgB,'Color','b', 'LineWidth',2);
    plot((TrialListsTimepoints(6,:)),AvgB+SEM_B,'Color','b', 'LineWidth',0.5);
    plot((TrialListsTimepoints(6,:)),AvgB-SEM_B,'Color','b', 'LineWidth',0.5);
    hold on
    plot((TrialListsTimepoints(6,:)),AvgT,'Color','k', 'LineWidth',2);
    hold on
    plot((TrialListsTimepoints(6,:)),(AvgT+SEM_T),'Color','k', 'LineWidth',0.5);
    plot((TrialListsTimepoints(6,:)),AvgT-SEM_T,'Color','k', 'LineWidth',0.5);
    hold on
    plot((TrialListsTimepoints(6,:)),AvgB+B_CIHW95,'Color','b', 'LineWidth',0.5, 'LineStyle', '--');
    plot((TrialListsTimepoints(6,:)),AvgB-B_CIHW95,'Color','b', 'LineWidth',0.5, 'LineStyle', '--');
    plot((TrialListsTimepoints(6,:)),AvgA+A_CIHW95,'Color','r', 'LineWidth',0.5, 'LineStyle', '--');
    plot((TrialListsTimepoints(6,:)),AvgA-A_CIHW95,'Color','r', 'LineWidth',0.5, 'LineStyle', '--');
     plot((TrialListsTimepoints(6,:)),AvgT+T_CIHW95,'Color','k', 'LineWidth',0.5, 'LineStyle', '--');
    plot((TrialListsTimepoints(6,:)),AvgT-T_CIHW95,'Color','k', 'LineWidth',0.5, 'LineStyle', '--');
    
    
    hold on
    
    
    if b==1
        ylabel('A selected Own Colour \newline Avg Difference between Gaze \newline and Touch/selected Target by A','FontSize',15)
                
    end
    if b==3
        xlabel('Time(secs) \newline B selected Own Colour','FontSize',15)      
        ylabel('A selected Other"s Colour \newline  Avg Difference between Gaze \newline and Touch/selected Target by A','FontSize',15)
    end
    if b==4
        xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',15)
    end

    if a>=1 && a<=4 
        saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeePlus50Red_ObjectiveRightAlignedtoBIFRWITHTARGET.jpg']))
        
    end
    if a>=5 && a<=8 
        saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeePlus50Red_ObjectiveLeftAlignedtoBIFRWITHTARGET.jpg']))
        
    end
%     if a>=9 && a<=12  
%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveRightBottomAlignedtoBIFR.jpg']))
%         
%     end
%     if a>=13 && a<=16 
%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftTopAlignedtoBIFR.jpg']))
%         
%     end
%     if a>=17 && a<=20  
%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftCenterAlignedtoBIFR.jpg']))
%         
%     end
%     if a>=21 && a<=24 
%         saveas(gcf, fullfile(saving_dir,[fileID, '_AvgDiffbwGazeTouchTimepSeeLess50Red_ObjectiveLeftBottomAlignedtoBIFR.jpg']))
%     end
end

b=0;
end

function [Clusters, ListSignClusters]= tn_PlottingClusters(Scores, Timepoints)

    
    Clusters= Scores.clusters;
    
    NumClusters= length(Clusters);
    
    for a1= 1:NumClusters
        if Scores.out.h{a1}==1
            ListSignClusters(a1)=a1;
        else
            ListSignClusters(a1)=NaN;
        end
    end

%     TrialLists=SpStr;
% 
%     if isempty(TrialLists)
%        continue; 
%     end
%     LengthTrialLists=length(TrialLists);

    for a=1:length(Clusters);
        ClusterSp=Clusters{a};
        
        if length(ClusterSp)>1
        
            ClusterTimes=Timepoints(6,(ClusterSp(1):ClusterSp(2)));
        
        else
            ClusterTimes=Timepoints(6,ClusterSp(1));
        end
        LengthClusterTimes=length(ClusterTimes);
% x1=abc(1): 1: abc(2);
        PlotClusterTimes=zeros(LengthClusterTimes,1);
        PlotClusterTimes(PlotClusterTimes==0)=300;
        PlotClusterTimes=transpose(PlotClusterTimes);
%     plot(x1,x);
        plot(ClusterTimes,PlotClusterTimes, 'LineWidth',7, 'Color', [0.5 0.5 0.5]);
    
    end
    hold on
    if length(ListSignClusters(~isnan(ListSignClusters)))>0
        for a=1:length(ListSignClusters)
            
            SignClusterSp=ListSignClusters(a);
            if isnan(SignClusterSp)
                continue;
            end
            SignClusterSpStr=Clusters(a);
            if length(SignClusterSpStr{1})>1
        
                SignClusterTimes=Timepoints(6,(SignClusterSpStr{1}(1):SignClusterSpStr{1}(2)));
        
            else
                SignClusterTimes=Timepoints(6,SignClusterSp(1));
            end
            SignLengthClusterTimes=length(SignClusterTimes);
% x1=abc(1): 1: abc(2);
            PlotSignClusterTimes=zeros(SignLengthClusterTimes,1);
            PlotSignClusterTimes(PlotSignClusterTimes==0)=350;
            PlotSignClusterTimes=transpose(PlotSignClusterTimes);
%     plot(x1,x);
            plot(SignClusterTimes,PlotSignClusterTimes, 'LineWidth',7, 'Color', 'k');
            
             
        end
    end
% for a=1:numel(ListSignClusters);
%     ClusterSp=Clusters{a};
%     ClusterTimes=Timepoints(1,(ClusterSp(1):ClusterSp(2)));
%     LengthClusterTimes=length(ClusterTimes)
% 
% % x1=abc(1): 1: abc(2);
%     PlotClusterTimes=zeros(LengthClusterTimes,1);
%     PlotClusterTimes(PlotClusterTimes==0)=300;
%     PlotClusterTimes=transpose(PlotClusterTimes);
%     plot((ClusterTimes,PlotClusterTimes, 'LineWidth',7, 'Color', 'k');
% end
    xlim([-0.2 0.9]);
    ylim([-500 500]);
    
    
end
function [AClosertoZero, BClosertoZero]=tn_ClosertoZero (SampleA, SampleB, Timepoints)
        AClosertoZero=find(abs(SampleA(1,:))< abs(SampleB(1,:)));
        BClosertoZero=find(abs(SampleA(1,:))>=abs(SampleB(1,:)));
        fullLength=length(AClosertoZero);
        AClosertoZeroTimes=Timepoints(6, AClosertoZero);
        ClosertoZeroY=zeros(fullLength,1);
        ClosertoZeroY(ClosertoZeroY==0)=280;
        ClosertoZeroY=transpose(ClosertoZeroY);
        plot(AClosertoZeroTimes,ClosertoZeroY,'.', 'Color','r');
        fullLength=length(BClosertoZero);
        BClosertoZeroTimes=Timepoints(6, BClosertoZero);
        ClosertoZeroY=zeros(fullLength,1);
        ClosertoZeroY(ClosertoZeroY==0)=280;
        ClosertoZeroY=transpose(ClosertoZeroY);
        plot(BClosertoZeroTimes,ClosertoZeroY,'.', 'Color','b');
     
end
function [AClosertoZero, BClosertoZero]=tn_ClosertoZerowithTarget (SampleA, SampleB,SampleT, Timepoints)
        AClosertoZero=find((abs(SampleA(1,:))< abs(SampleB(1,:))) &(abs(SampleA(1,:))< abs(SampleT(1,:))));
        BClosertoZero=find((abs(SampleB(1,:))<=abs(SampleA(1,:))) & ((abs(SampleB(1,:))< abs(SampleT(1,:)))));
        TClosertoZero=find((abs(SampleT(1,:))<abs(SampleA(1,:))) & ((abs(SampleT(1,:))<=abs(SampleB(1,:)))));
        fullLength=length(AClosertoZero);
        AClosertoZeroTimes=Timepoints(6, AClosertoZero);
        ClosertoZeroY=zeros(fullLength,1);
        ClosertoZeroY(ClosertoZeroY==0)=280;
        ClosertoZeroY=transpose(ClosertoZeroY);
        plot(AClosertoZeroTimes,ClosertoZeroY,'.', 'Color','r');
        fullLength=length(BClosertoZero);
        BClosertoZeroTimes=Timepoints(6, BClosertoZero);
        ClosertoZeroY=zeros(fullLength,1);
        ClosertoZeroY(ClosertoZeroY==0)=280;
        ClosertoZeroY=transpose(ClosertoZeroY);
        plot(BClosertoZeroTimes,ClosertoZeroY,'.', 'Color','b');
        fullLength=length(TClosertoZero);
        TClosertoZeroTimes=Timepoints(6, TClosertoZero);
        ClosertoZeroY=zeros(fullLength,1);
        ClosertoZeroY(ClosertoZeroY==0)=280;
        ClosertoZeroY=transpose(ClosertoZeroY);
        plot(TClosertoZeroTimes,ClosertoZeroY,'.', 'Color','k');
    end    