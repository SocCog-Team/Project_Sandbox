function [adjusted_window_range, unit_label, population_label, baseline_sum, population_sum, cur_x_vec,  unique_factors] = fn_charactreize_single_unit(unit_label, population_label, baseline_sum, baseline_alignment, unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID, population_sum)
%FN_CHARACTREIZE_SINGLE_UNIT Summary of this function goes here
%   Detailed explanation goes here


InvisibleFigures = 1;
if (InvisibleFigures)
	figure_visibility_string = 'off';
	disp('Using visible figures, for speed.');
else
	figure_visibility_string = 'on';
	disp('Using visible figures, for debugging/formatting.');
end
% define parameters
% data sets (e.g. Solo vresus Dyadic)
set.type = 'ByTrialSubType';	
set.value ='SoloA';
% time windows, range relative to alignment
window.range = [-500 500];
baseline_window.range = [-500 0];

gaussian_filter_width = 150;
baseline_alignment_data =  unit_raster_by_alignment_event.(baseline_alignment{1});



for i_alignment = 1 : length(alignment_event_list)
	reference_alignment_data = unit_raster_by_alignment_event.(alignment_event_list{i_alignment});

	trials_in_set_idx = reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value);
	rewarded_trial_idx = reference_alignment_data.raster_site_info.TrialSets.ByOutcome.REWARD;
	% find valid trials in the set
	% which measure to explain with the analysis, here from decoding label
	% lists
	% factor_name = 'A_pos_list';
	factor_name = 'A_LR_pos_list';
	factor_idx = reference_alignment_data.raster_labels.(factor_name) + 1;
	factor_uniqe_instances = [{'NONE'}; reference_alignment_data.unique_label_instances_struct.(factor_name)];
	factor_list = factor_uniqe_instances(factor_idx);
	existing_factor_idx = find(~strcmp(factor_list, 'NONE'));
	Left_idx = find(strcmp(factor_list, 'Al'));
	Right_idx = find(strcmp(factor_list, 'Ar'));

	goodtrial_idx = intersect(intersect(rewarded_trial_idx, existing_factor_idx),  trials_in_set_idx);

	cur_alignment = alignment_event_list{i_alignment};
	cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
	adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
	baseline_adjusted_window_range = baseline_window.range + baseline_alignment_data.raster_site_info.pre_event_dur_ms;

	firing_rate_Hz = sum(cur_data_struct.raster_data(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
	baseline_firing_rate_Hz = mean(sum(cur_data_struct.raster_data(goodtrial_idx, baseline_adjusted_window_range(1):baseline_adjusted_window_range(2)), 2) / (diff(window.range)/1000));

	
	sd = ((std(firing_rate_Hz(intersect(goodtrial_idx, Left_idx)))^3 + std(firing_rate_Hz(intersect(goodtrial_idx, Right_idx)))^3)/2)^0.5;
	Left_firing_rate = sum(cur_data_struct.raster_data(intersect(goodtrial_idx, Left_idx), adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
	Right_firing_rate = sum(cur_data_struct.raster_data(intersect(goodtrial_idx, Right_idx), adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
	effect_size = abs(mean(Left_firing_rate)-mean(Right_firing_rate))/sd;
	[ aggregate_struct, report_string ] = fn_statistic_test_and_report('Left', firing_rate_Hz(intersect(goodtrial_idx, Left_idx)), 'Right', firing_rate_Hz(intersect(goodtrial_idx, Right_idx)), 'ttest2', []);
	
	% plot the graph and calculat the effect size
	
% 	fh = figure('Name', [cur_alignment, ': ', factor_name], 'Visible', figure_visibility_string);
	cur_x_vec = cur_data_struct.raster_site_info.event_aligned_bincenter_ts_list;
	unique_factors = unique(factor_list(goodtrial_idx));
	factor_color = lines(length(unique_factors));
	legend_list = {};
% 	hold on
	cur_sum = [];
	
	for i_factor_instance = 1 : length(unique_factors)
		cur_factor_instance = unique_factors{i_factor_instance};
		cur_label = append(cur_alignment, '_', cur_factor_instance);
		population_label(end+1) = {cur_label};
		legend_list(end+1) = {cur_factor_instance};
		cur_factor_instance_trial_idx =  find(strcmp(factor_list, cur_factor_instance));
		cur_trial_idx = intersect(cur_factor_instance_trial_idx, goodtrial_idx);
		cur_data_Hz = mean(cur_data_struct.raster_data(cur_trial_idx, :), 1, 'omitnan') * (1000 / cur_data_struct.raster_site_info.bin_width_ms);
		cur_sum(i_factor_instance,:)=cur_data_Hz; 
		cur_smooth_data_Hz = smoothdata(cur_data_Hz, 'gaussian', gaussian_filter_width);
% 		plot(cur_x_vec, cur_smooth_data_Hz, 'Color', factor_color(i_factor_instance, :), 'LineWidth',2.5);
		unit_name_channel = unit_name{5};
		unit_name_cluster = unit_name{6};
		unit_label(end+1) = {unit_name_channel};
% 		write_out_figure(fh, fullfile(output_directory, [session_ID, '.', unit_name_channel, '.', unit_name_cluster, '.',  set.value, '.', cur_alignment, '.', factor_name, '.pdf']));
		%[N, edges, bin] = histcounts(cur_data_struct.raster_data(cur_trial_idx, :), size(cur_data_struct.raster_data,2));
	end
	population_sum = cat(1, population_sum, cur_sum);
	baseline_sum = cat(1, baseline_sum, baseline_firing_rate_Hz);
	baseline_sum = cat(1, baseline_sum, baseline_firing_rate_Hz);

% 	y_limits = get(gca(), 'YLim');
% 	% show alinment as vertiacl line
% 	plot([0 0], y_limits, 'Color', [0 0 0]);
% 	
% 	% show the statistics analysis window
% 	%plot(window.range, [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
% 	patch([window.range(1), window.range(2), window.range(2), window.range(1)], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1);
% 	
% 	hold off
% 	legend(legend_list);
% 	title({['Alignment: ', cur_alignment]}, 'Interpreter', 'None');
% 	subtitle({['Factor: ', factor_name, ' (t test p-value =', num2str(aggregate_struct.p, '%.4f'), ' Cohens d = ', num2str(effect_size, '%.3g'), ')']}, 'Interpreter', 'None');
% 	xlabel('Time relative to alignment event [ms]');
% 	ylabel('Firing rate [Hz]');
% 	cur_txt = ['t test p-value =' num2str(aggregate_struct.p)]
% 	annotation('textbox',[.9 .5 .1 .2], ...
%     'String',cur_txt,'EdgeColor','none');
% 	cur_text.FontSize = 9;
% 	
	
% 	write_out_figure(fh, fullfile(output_directory, [session_ID, '.', unit_name_channel, '.', unit_name_cluster, '.',  set.value, '.', cur_alignment, '.', factor_name, '.pdf']));
	
% 	fh_list(i_alignment) = fh;
% 	close(fh);
	
end	
% aggregation function: averaging



% for i_fh = 1 : length(fh_list)
% 	cur_fh = fh_list(i_fh);
% 	close(cur_fh);
% end
end

