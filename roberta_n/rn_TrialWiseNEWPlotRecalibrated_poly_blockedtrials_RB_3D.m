%%This is to plot aligned data.
%%I overlay gaze from multiple trials ; and plot Own/Own; Own/Other;
%%Other/Own; Other/Other and put Touch from A and B on this


function []= rn_TrialWiseNEWPlotRecalibrated_poly_blockedtrials_RB_3D(epochdataRegisteredGazeA_poly_right,epochdataRegisteredGazeA_poly_left, epochdataTouchA,epochdataTouchB, ModifiedTrialSets, saving_dir, fileID)

Byrewardttype_pos_blocked_RB_Names=fieldnames(ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB);

% ByStimulusPosition_leftrightChoicecategoriesNamesSp=ByChoicePositionColourRewardNames(counter+4);
% ByStimulusPosition_leftrightChoicecategoriesNamesSpStr=ModifiedTrialSets.ByStimulusPosition_leftrightChoicecategories.(ByStimulusPosition_leftrightChoicecategoriesNamesSp{1});

a=0;
for counter = 1:24
    Byrewardttype_posSp = Byrewardttype_pos_blocked_RB_Names(counter);
    Byrewardttype_posSpStr = ModifiedTrialSets.Byrewardttype_pos.ByPostSwitch.Blocked.RB.(Byrewardttype_posSp{1});
    
    TrialLists = Byrewardttype_posSpStr;
    
    %     numb=length(TrialLists);
    %     for RemoveLastTrial= 1: numb
    %
    %     timepointsLists=linspace(-0.5, ,length(epochdataGazeA.TargetOnset.timepoints(TrialLists,:)));
    %     timeBins=histogram(epochdataGazeA.TargetOnset.timepoints(TrialLists,:));
    %     timeBins.BinEdges=timepointsLists;
    %     for i= 1: length(timepointsLists)-1
    %         abc(:,i)=find(epochdataGazeA.TargetOnset.timepoints(TrialLists,:)> timepointsLists(i) & epochdataGazeA.TargetOnset.timepoints(TrialLists,:)<= timepointsLists(i+1)
    %     end
    
    if counter==1 || counter==5 || counter==9 || counter==13 || counter==17 || counter== 21
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
    vergence = (epochdataRegisteredGazeA_poly_right.TargetOnset.xCoordinates)- (epochdataRegisteredGazeA_poly_left.TargetOnset.xCoordinates);
    AverageVergence = mean (vergence(TrialLists,:),1,'omitnan');
    AverageVergence_offset = 600 ; 
    NewAverageVergence = AverageVergence + AverageVergence_offset ; 

    
    AverageTouchA_x = mean(epochdataTouchA.TargetOnset.xCoordinates(TrialLists,:),1,'omitnan');
    AverageTouchA_y = mean(epochdataTouchA.TargetOnset.yCoordinates(TrialLists,:),1,'omitnan');
    AverageTouchB_x = mean(epochdataTouchB.TargetOnset.xCoordinates(TrialLists,:),1,'omitnan');
    AverageTouchB_y = mean(epochdataTouchB.TargetOnset.yCoordinates(TrialLists,:),1,'omitnan');
    AverageGazeA_x = mean(epochdataRegisteredGazeA_poly_right.TargetOnset.xCoordinates(TrialLists,:),1,'omitnan');
    AverageGazeA_y = mean(epochdataRegisteredGazeA_poly_right.TargetOnset.yCoordinates(TrialLists,:),1,'omitnan');
    
    %   av=mean(epochdataTouchA.TargetOnset.timepoints(TrialLists,:),1);
    [a b ]= size(vergence);
    v(1:b) = 400;
    OverLayPlotsTouchA=plot3(epochdataTouchA.TargetOnset.timepoints(TrialLists,:),epochdataTouchA.TargetOnset.xCoordinates(TrialLists,:),epochdataTouchA.TargetOnset.yCoordinates(TrialLists,:),'.','Color','r','MarkerSize', 4);
   
    xlim([-0.5 1.8]);
    ylim([500 1250]);
    zlim([400 600]);
    
    xL_centraltarget=[-0.5,1.8];
    line(xL_centraltarget,[960 960],[500 500],'Color','k');
    
    hold on
    xL_touchtarget=[-0.5,1.8];
    yL = get(gca,'YLim');
    hold on
    line([0 0],yL,'Color','g');
    
    if counter>=1 && counter<=12
        if a==1 || a==2
            line(xL_touchtarget,[1182 1182],[556 556],'Color','b', 'LineStyle','--');
            line(xL_touchtarget,[960 960],[500 500],'Color','k');
            line(xL_touchtarget,[739 739],[556 556],'Color','r');
            line(xL_touchtarget,[600 600],[400 400], 'Color', 'm');
            
            
        else
            line(xL_touchtarget,[1182 1182],[556 556],'Color','b', 'LineStyle','--');
            line(xL_touchtarget,[960 960],[500 500],'Color','k');
            line(xL_touchtarget,[739 739],[556 556],'Color','r');
            line(xL_touchtarget,[600 600],[400 400], 'Color', 'm');
        end
    else
        if a==1 || a==2
            line(xL_touchtarget,[1182 1182],[556 556],'Color','b', 'LineStyle','--');
            line(xL_touchtarget,[960 960],[500 500],'Color','k');
            line(xL_touchtarget,[739 739],[556 556],'Color','r');
            line(xL_touchtarget,[600 600],[400 400], 'Color', 'm');
        else
            line(xL_touchtarget,[1182 1182],[556 556],'Color','b', 'LineStyle','--');
            line(xL_touchtarget,[960 960],[500 500],'Color','k');
            line(xL_touchtarget,[739 739],[556 556],'Color','r');
            line(xL_touchtarget,[600 600],[400 400], 'Color', 'm');
        end
    end
    
    hold on
    OverLayPlotsTouchB=plot3(epochdataTouchA.TargetOnset.timepoints(TrialLists,:),epochdataTouchB.TargetOnset.xCoordinates(TrialLists,:),epochdataTouchB.TargetOnset.yCoordinates(TrialLists,:),'.','Color','b','MarkerSize', 4);
   
    %OverLayPlotsTouchAVGA=plot3(epochdataTouchA.TargetOnset.timepoints(TrialLists(1),:),AverageTouchA_x,AverageTouchA_y,'*','Color','r','MarkerSize', 6 )
    %OverLayPlotsTouchAVGB=plot3(epochdataTouchB.TargetOnset.timepoints(TrialLists(1),:),AverageTouchB_x,AverageTouchB_y,'*','Color','b','MarkerSize', 6  )
    hold on
    OverLayPlotsGazeA=plot3( epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists,:),epochdataRegisteredGazeA_poly_right.TargetOnset.xCoordinates(TrialLists,:),...
                             epochdataRegisteredGazeA_poly_right.TargetOnset.yCoordinates(TrialLists,:),'.','Color','k','MarkerSize', 4);

    %OverLayPlotsGazeAVGA=plot3(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists(1),:),AverageGazeA_x,AverageGazeA_y, '.','Color',[1,0.5,0],'MarkerSize', 6 )
    
    %   OverLayPlotsGazeA.MarkerSize=3;
    %   OverLayPlotsGazeA.Color='red';
    
     hold on
     OverLayPlotsVergence = plot3(epochdataRegisteredGazeA_poly_right.TargetOnset.timepoints(TrialLists,:),NewAverageVergence,v,'.','Color','m' )
      
    %     MaxLengthTimePoints_idx=find(epochdataTouchB.TargetOnset.timepoints(TrialLists,:)==max(length(epochdataTouchB.TargetOnset.timepoints(TrialLists,:))));
    %     min(nnz(~isnan(epochdataTouchB.TargetOnset.timepoints(TrialLists,:))))
    
    
    if a==1
        %ylabel('A selected Own Colour \newline X-Coordinates','FontSize',15)
        ylabel('X-Coordinates','FontSize',15)
        zlabel('Y-Coordinates', 'FontSize',15);
    end
    if a==3
        %xlabel('Time(secs) \newline B selected Own Colour','FontSize',15)
        xlabel('Time(secs)','FontSize',15)
        ylabel('X-Coordinates','FontSize',15)
        zlabel('Y-Coordinates','FontSize',15);
    end
    
    if a==4
        %xlabel('Time(secs) \newline B selected Other"s Colour','FontSize',15)
        xlabel('Time(secs)','FontSize',15)
        zlabel('Y-Coordinates','FontSize',15);
    end
    
    if counter>=1 && counter<=4
        write_out_figure(gcf, fullfile(saving_dir,[fileID, '_3D_Blocked_RB_Red_ObjectiveRightTop.pdf']))
        
    end
    if counter>=5 && counter<=8
        write_out_figure(gcf, fullfile(saving_dir,[fileID, '_3D_Blocked_RB_Red_ObjectiveRightCenter.pdf']))
        
    end
    if counter>=9 && counter<=12
        write_out_figure(gcf, fullfile(saving_dir,[fileID, '_3D_Blocked_RB_Red_ObjectiveRightBottom.pdf']))
        
    end
    if counter>=13 && counter<=16
        write_out_figure(gcf, fullfile(saving_dir,[fileID, '_3D_Blocked_RB_Red_ObjectiveLeftTop.pdf']))
        
    end
    if counter>=17 && counter<=20
        write_out_figure(gcf, fullfile(saving_dir,[fileID, '_3D_Blocked_RB_Red_ObjectiveLeftCenter.pdf']))
        
    end
    if counter>=21 && counter<=24
        write_out_figure(gcf, fullfile(saving_dir,[fileID, '_3D_Blocked_RB_Red_ObjectiveLeftBottom.pdf']))
    end
end

a=0;


end