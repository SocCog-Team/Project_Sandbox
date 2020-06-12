%%Euclidean distance between Gaze and Touch
function [ distGazeA_TouchA, distGazeA_TouchB, distGazeA_final_target_A, distTouchA_final_target_A, distTouchB_final_target_B]= rn_distbetweenGazeTouch_Onset(epochdataGaze, epochdataTouchA, epochdataTouchB, maintask_datastruct)
report_struct = maintask_datastruct.report_struct;
final_target = struct ();
final_target.A_selected.xcoordinates = zeros(size(epochdataGaze.TargetOnset.xCoordinates));
final_target.A_selected.ycoordinates = zeros(size(epochdataGaze.TargetOnset.yCoordinates));
final_target.B_selected.xcoordinates = zeros(size(epochdataGaze.TargetOnset.xCoordinates));
final_target.B_selected.ycoordinates = zeros(size(epochdataGaze.TargetOnset.yCoordinates));

for i_trial = 1 : size(epochdataGaze.TargetOnset.xCoordinates,1)
	A_final_target_x = report_struct.data(i_trial, report_struct.cn.A_TouchSelectedTargetPosition_X);
	A_final_target_y = report_struct.data(i_trial, report_struct.cn.A_TouchSelectedTargetPosition_Y);
	B_final_target_x = report_struct.data(i_trial, report_struct.cn.B_TouchSelectedTargetPosition_X);
	B_final_target_y = report_struct.data(i_trial, report_struct.cn.B_TouchSelectedTargetPosition_Y);
	
	final_target.A_selected.xcoordinates(i_trial, :) = A_final_target_x;
	final_target.A_selected.ycoordinates(i_trial, :) = A_final_target_y;
	final_target.B_selected.xcoordinates(i_trial, :) = B_final_target_x;
	final_target.B_selected.ycoordinates(i_trial, :) = B_final_target_y;
	
	
end


distGazeA_TouchA = sqrt((epochdataGaze.TargetOnset.xCoordinates(:,:) - epochdataTouchA.TargetOnset.xCoordinates(:,:)).^2 + (epochdataGaze.TargetOnset.yCoordinates(:,:) - epochdataTouchA.TargetOnset.yCoordinates(:,:)).^2);
distGazeA_TouchB = sqrt((epochdataGaze.TargetOnset.xCoordinates(:,:) - epochdataTouchB.TargetOnset.xCoordinates(:,:)).^2 + (epochdataGaze.TargetOnset.yCoordinates(:,:) - epochdataTouchB.TargetOnset.yCoordinates(:,:)).^2);

if max(distGazeA_TouchA(:)) > 3000
	[row,col] = find(distGazeA_TouchA > 3000);
	disp('Doh...');
end

distGazeA_final_target_A = sqrt((epochdataGaze.TargetOnset.xCoordinates(:,:) - final_target.A_selected.xcoordinates(:,:)).^2 + (epochdataGaze.TargetOnset.yCoordinates(:,:) - final_target.A_selected.ycoordinates(:, :)).^2);
distTouchA_final_target_A = sqrt((epochdataTouchA.TargetOnset.xCoordinates(:,:) - final_target.A_selected.xcoordinates(:,:)).^2 + (epochdataTouchA.TargetOnset.yCoordinates(:,:) - final_target.A_selected.ycoordinates(:, :)).^2);
distTouchB_final_target_B = sqrt((epochdataTouchB.TargetOnset.xCoordinates(:,:) - final_target.B_selected.xcoordinates(:,:)).^2 + (epochdataTouchB.TargetOnset.yCoordinates(:,:) - final_target.B_selected.ycoordinates(:, :)).^2);
return
end

