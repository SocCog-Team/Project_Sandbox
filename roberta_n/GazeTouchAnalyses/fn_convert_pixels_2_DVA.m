function  [x_position_list_deg, y_position_list_deg] = fn_convert_pixels_2_DVA(x_position_list_pix, y_position_list_pix, x_screen_clostest2eye_pix, y_screen_clostest2eye_pix, screen_pix2mm_x, screen_pix2mm_y, eye2srceen_distance_mm)
%
% if isempty(viewing_dist)==1
%     viewing_dist=50;
% end

IFT_y_pos = 500;
IFT_x_pos = 960;

distance_of_y_screen_clostest2eye_pix_2_ITF_mm = -100; % positions above the IFT are negative
distance_of_x_screen_clostest2eye_pix_2_ITF_mm = 0; % positions to the right of IFT are positive

if ~exist('screen_pix2mm_x', 'var') || isempty(screen_pix2mm_x)
	screen_pix2mm_x = 1920/1209.4;
end

if ~exist('screen_pix2mm_y', 'var') || isempty(screen_pix2mm_y)
	screen_pix2mm_y = 1080/680.4;
end

if ~exist('eye2srceen_distance_mm', 'var') || isempty(eye2srceen_distance_mm)
	eye2srceen_distance_mm = 300;
end

if ~exist('x_screen_clostest2eye_pix', 'var') || isempty(x_screen_clostest2eye_pix)
	x_screen_clostest2eye_pix = IFT_x_pos + (distance_of_x_screen_clostest2eye_pix_2_ITF_mm * screen_pix2mm_x);
end

if ~exist('y_screen_clostest2eye_pix', 'var') || isempty(y_screen_clostest2eye_pix)
	y_screen_clostest2eye_pix = IFT_y_pos + (distance_of_y_screen_clostest2eye_pix_2_ITF_mm * screen_pix2mm_y);
end


delta_x_position_list_pix = x_position_list_pix - x_screen_clostest2eye_pix;
delta_y_position_list_pix = (y_position_list_pix - y_screen_clostest2eye_pix) * -1; % we want positive values for positions above the reference point
delta_x_position_list_mm = delta_x_position_list_pix / screen_pix2mm_x;
delta_y_position_list_mm = delta_y_position_list_pix / screen_pix2mm_y;

x_position_list_deg = atand(delta_x_position_list_mm / eye2srceen_distance_mm);
y_position_list_deg = atand(delta_y_position_list_mm / eye2srceen_distance_mm);

return


screen_w_pix=1920;

screen_h_pix=1080;

screen_w_cm=120.94;

screen_h_cm=68.04;

% viewing_dist=50;
% center_x_pix = SETTINGS.screen_w_pix / 2;
center_y_pix = screen_h_pix / 2;
center_x_pix = screen_w_pix / 2;
% center_y_pix = SETTINGS.screen_h_pix*SETTINGS.screen_uh_cm/SETTINGS.screen_h_cm;


% distance to the center in pix
dist_pix_x = pix_x - center_x_pix;
dist_pix_y = center_y_pix - pix_y;


pixels_per_cm_x = screen_w_pix / screen_w_cm;
pixels_per_cm_y = screen_h_pix / screen_h_cm;

dist_cm_x = dist_pix_x/pixels_per_cm_x;
dist_cm_y = dist_pix_y/pixels_per_cm_y;

%deg_x = cm2deg(SETTINGS.vd, dist_cm_x);

deg_x = 2 * atan((dist_cm_x / 2)/viewing_dist) / (pi / 180);
deg_y = 2 * atan((dist_cm_y / 2)/viewing_dist) / (pi / 180);

%
% deg_y = cm2deg(SETTINGS.vd, dist_cm_y);
%  SETTINGS.screen_w_pix = 1600; % 1024;
%         SETTINGS.screen_h_pix = 1200; %768;
%         SETTINGS.screen_w_cm = 41;
%         SETTINGS.screen_h_cm = 31;
% %
% SETTINGS.screen_uh_cm       = task.screen_uh_cm;
% SETTINGS.screen_lh_deg      = atan((SETTINGS.screen_h_cm - SETTINGS.screen_uh_cm)/SETTINGS.vd)/(pi/180);
% SETTINGS.screen_uh_deg      = atan(SETTINGS.screen_uh_cm/SETTINGS.vd)/(pi/180);
% SETTINGS.screen_h_deg       = SETTINGS.screen_lh_deg + SETTINGS.screen_uh_deg;

% SETTINGS.screen_w_deg   = cm2deg(SETTINGS.vd,SETTINGS.screen_w_cm);
% SETTINGS.screen_h_deg   = cm2deg(SETTINGS.vd,SETTINGS.screen_h_cm);
end
