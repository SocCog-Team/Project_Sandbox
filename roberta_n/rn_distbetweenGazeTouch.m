%%Euclidean distance between Gaze and Touch
function [ distGazeA_TouchA, distGazeA_TouchB,distGazeA_finaltarget_A,distTouchA_finaltarget_A,distTouchB_finaltarget_B]= rn_distbetweenGazeTouch(epochdataGaze, epochdataTouchA, epochdataTouchB, maintask_datastruct)
report_struct = maintask_datastruct.report_struct;
final_target = struct ();
final_target.A_selected.xcoordinates = zeros(size(epochdataGaze.xCoordinates));
final_target.A_selected.ycoordinates = zeros(size(epochdataGaze.yCoordinates));
final_target.B_selected.xcoordinates = zeros(size(epochdataGaze.xCoordinates));
final_target.B_selected.ycoordinates = zeros(size(epochdataGaze.yCoordinates));

for i_trial = 1 : size(epochdataGaze.xCoordinates,1)
	A_final_target_x = report_struct.data(i_trial, report_struct.cn.A_TouchSelectedTargetPosition_X);
	A_final_target_y = report_struct.data(i_trial, report_struct.cn.A_TouchSelectedTargetPosition_Y);
	B_final_target_x = report_struct.data(i_trial, report_struct.cn.B_TouchSelectedTargetPosition_X);
	B_final_target_y = report_struct.data(i_trial, report_struct.cn.B_TouchSelectedTargetPosition_Y);
	
	final_target.A_selected.xcoordinates(i_trial, :) = A_final_target_x;
	final_target.A_selected.ycoordinates(i_trial, :) = A_final_target_y;
	final_target.B_selected.xcoordinates(i_trial, :) = B_final_target_x;
	final_target.B_selected.ycoordinates(i_trial, :) = B_final_target_y;
	
	
end


distGazeA_TouchA = sqrt((epochdataGaze.xCoordinates(:,:) - epochdataTouchA.xCoordinates(:,:)).^2 + (epochdataGaze.yCoordinates(:,:) - epochdataTouchA.yCoordinates(:,:)).^2);
distGazeA_TouchB = sqrt((epochdataGaze.xCoordinates(:,:) - epochdataTouchB.xCoordinates(:,:)).^2 + (epochdataGaze.yCoordinates(:,:) - epochdataTouchB.yCoordinates(:,:)).^2);

distGazeA_finaltarget_A = sqrt((epochdataGaze.xCoordinates(:,:) - final_target.A_selected.xcoordinates(:,:)).^2 + (epochdataGaze.yCoordinates(:,:) - final_target.A_selected.ycoordinates(:, :)).^2);
distTouchA_finaltarget_A = sqrt((epochdataTouchA.xCoordinates(:,:) - final_target.A_selected.xcoordinates(:,:)).^2 + (epochdataTouchA.yCoordinates(:,:) - final_target.A_selected.ycoordinates(:, :)).^2);
distTouchB_finaltarget_B = sqrt((epochdataTouchB.xCoordinates(:,:) - final_target.B_selected.xcoordinates(:,:)).^2 + (epochdataTouchB.yCoordinates(:,:) - final_target.B_selected.ycoordinates(:, :)).^2);

end

