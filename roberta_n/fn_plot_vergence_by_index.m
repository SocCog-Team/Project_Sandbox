function [vergence] = fn_plot_vergence_by_index(right_gaze_xy, left_gaze_xy, selected_trials_idx, Xedges, Yedges, title_string, set_name, output_dir, fileID )
%FN_PLOT_VERGENCE_BY_INDEX Summary of this function goes here
%   Detailed explanation goes here

vergence = [];

if (sum(selected_trials_idx) > 0) && ~isempty(selected_trials_idx) 
	
	right_x_coordinates = right_gaze_xy(selected_trials_idx, 1);
	right_y_coordinates = right_gaze_xy(selected_trials_idx, 2);
	left_x_coordinates = left_gaze_xy(selected_trials_idx, 1);
	
	vergence = (right_x_coordinates - left_x_coordinates);
	
 
	ranged_vergence_idx = find(vergence >= -100 & vergence <= 100);
	cur_fh = figure('Name', ['Ranged vergence histogram (', title_string, ')']);
	h = histogram(vergence(ranged_vergence_idx), 200);
	title(['Ranged vergence histogram  (', title_string, ')']);
	%write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080', fileID, ['Ranged_vergence_histogram_', set_name, '.pdf']));
    write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080_new_offset', fileID, ['Ranged_vergence_histogram_', set_name, '.pdf']));
	
	abs_vergence = abs(vergence);
	cur_fh = figure('Name', ['Vergence histogram (', title_string, ')']);
	h = histogram(vergence);
	title(['Vergence histogram  (', title_string, ')']);
    write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080', fileID, ['Vergence_histogram_', set_name, '.pdf']));
	%write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080_new_offset', fileID, ['Vergence_histogram_', set_name, '.pdf']));
	
	
	cur_fh = figure('Name', ['Gaze histogram (', title_string, ')']);
	histogram2(right_x_coordinates, right_y_coordinates, Xedges, Yedges, 'DisplayStyle', 'tile', 'Normalization', 'probability')
	title (['Gaze histogram trials (', title_string, ')']);
	axis equal;
	colorbar;
	set(gca(), 'YDir', 'reverse');
	
	write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080', fileID, ['Gaze2D_histogram_', set_name, '.pdf']));
	%write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080_new_offset', fileID, ['Gaze2D_histogram_', set_name, '.pdf']));
	
	[N, Xedges, Yedges, binX, binY] = histcounts2(right_x_coordinates, right_y_coordinates, Xedges, Yedges);
	
	absmax_vergence_array = zeros(size(N));
	max_vergence_array = zeros(size(N));
	min_vergence_array = zeros(size(N));
	absmin_vergence_array = zeros(size(N));
	mean_vergence_array = zeros(size(N));
	
	samples_by_binx_idx_list = cell([1 (length(Xedges) - 1)]);
	for i_x = 1 : (length(Xedges) - 1)
		current_x = mean([Xedges(i_x:i_x + 1)]);
		current_x_sample_idx = find(binX == i_x);
		samples_by_binx_idx_list{i_x} = current_x_sample_idx;
	end
	
	samples_by_biny_idx_list = cell([1 (length(Yedges) - 1)]);
	for i_y = 1 : (length(Yedges) - 1)
		current_y = mean([Yedges(i_y:i_y + 1)]);
		current_y_sample_idx = find(binY == i_y);
		samples_by_biny_idx_list{i_y} = current_y_sample_idx;
	end	
	
	for i_x = 1 : (length(Xedges) - 1)
		current_x = mean([Xedges(i_x:i_x + 1)]);
		current_x_sample_idx = samples_by_binx_idx_list{i_x};
		
		for i_y = 1 : (length(Yedges) - 1)
			current_y = mean([Yedges(i_y:i_y + 1)]);
			current_y_sample_idx = samples_by_biny_idx_list{i_y};
			
			current_sample_set = intersect(current_x_sample_idx, current_y_sample_idx);
			
			tmp_max = max(vergence(current_sample_set));
			if ~isempty(tmp_max)
				max_vergence_array(i_x, i_y) = tmp_max;
				absmax_vergence_array(i_x, i_y) = max(abs_vergence(current_sample_set));
			end
			
			tmp_min = min(vergence(current_sample_set));
			if ~isempty(tmp_min)
				min_vergence_array(i_x, i_y) = tmp_min;
				absmin_vergence_array(i_x, i_y) = min(abs_vergence(current_sample_set));
			end
			
			tmp_mean = mean(vergence(current_sample_set));
			
			if ~isempty(mean(vergence(current_sample_set)))
				mean_vergence_array(i_x, i_y) = mean(vergence(current_sample_set));
			end
			
		end
	end
	cur_fh = figure('Name', ['Maximal vergence (', title_string, ')']);
	imagesc(max_vergence_array');
	colorbar;
	set(gca(), 'CLim', [-100, 100]);
	title (['Maximal vergence (', title_string, ')']);
	axis equal;
	write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080', fileID, ['max_vergence_array_', set_name, '.pdf']));
	%write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080_new_offset', fileID, ['max_vergence_array_', set_name, '.pdf']));
	
	
	cur_fh = figure('Name', ['Mean vergence (', title_string, ')']);
	imagesc(mean_vergence_array');
	colorbar;
	set(gca(), 'CLim', [-100, 100]);
	title (['Mean vergenace (', title_string, ')']);
	axis equal;
	write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080', fileID, ['mean_vergence_array_', set_name, '.pdf']));
	%write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080_new_offset', fileID, ['mean_vergence_array_', set_name, '.pdf']));
	
	cur_fh = figure('Name', ['Absmax vergence (', title_string, ')']);
	imagesc(absmax_vergence_array');
	colorbar;
	set(gca(), 'CLim', [-100, 100]);
	title (['Absmax vergence (', title_string, ')']);
	axis equal;
	write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080', fileID, ['absmax_vergence_array_', set_name, '.pdf']));
	%write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080_new_offset', fileID, ['absmax_vergence_array_', set_name, '.pdf']));
	
	cur_fh = figure('Name', ['Min vergence (', title_string, ')']);
	imagesc(min_vergence_array');
	colorbar;
	set(gca(), 'CLim', [-100, 100]);
	title (['Min vergence (', title_string, ')']);
	axis equal;
	write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080', fileID, ['min_vergence_array_', set_name, '.pdf']));
	%write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080_new_offset', fileID, ['min_vergence_array_', set_name, '.pdf']));
	
	cur_fh = figure('Name', ['Absmin Vergence (', title_string, ')']);
	imagesc(absmin_vergence_array');
	colorbar;
	title (['Absmin vergence (', title_string, ')']);
	axis equal;
	set(gca(), 'CLim', [-100, 100]);
	write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080', fileID, ['absmin_vergence_array_', set_name, '.pdf']));
	%write_out_figure(cur_fh, fullfile(output_dir, 'figures_1920x1080_new_offset', fileID, ['absmin_vergence_array_', set_name, '.pdf']));
end

return
end
