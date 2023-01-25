function [] = fn_charactreize_single_unit(unit_raster_by_alignment_event, alignment_event_list, output_directory, session_ID)
%FN_CHARACTREIZE_SINGLE_UNIT Summary of this function goes here
%   Detailed explanation goes here

reference_alignment_data = unit_raster_by_alignment_event.(alignment_event_list{1});


% define parameters
% data sets (e.g. Solo vresus Dyadic)
set.type = 'ByTrialSubType';
set.value ='SoloA';
trials_in_set_idx = reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value);
rewarded_trial_idx = reference_alignment_data.raster_site_info.TrialSets.ByOutcome.REWARD;

% time windows, range relative to alignment
window.range = [-500 500];


% find valid trials in the set



% which measure to explain with the analysis, here from decoding label
% lists
factor_name = 'A_pos_list';
factor_name = 'A_LR_pos_list';
factor_idx = reference_alignment_data.raster_labels.(factor_name) + 1;
factor_uniqe_instances = [{'NONE'}; reference_alignment_data.unique_label_instances_struct.(factor_name)];
factor_list = factor_uniqe_instances(factor_idx);
existing_factor_idx = find(~strcmp(factor_list, 'NONE'));
Left_idx = find(strcmp(factor_list, 'Al'));
Right_idx = find(strcmp(factor_list, 'Ar'));

goodtrial_idx = intersect(intersect(rewarded_trial_idx, trials_in_set_idx), existing_factor_idx);


for i_alignment = 1 : length(alignment_event_list)
	cur_alignment = alignment_event_list{i_alignment};
	cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
	adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
	firing_rate_Hz = sum(cur_data_struct.raster_data(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
	
	[ aggregate_struct, report_string ] = fn_statistic_test_and_report('Left', firing_rate_Hz(intersect(goodtrial_idx, Left_idx)), 'Right', firing_rate_Hz(intersect(goodtrial_idx, Right_idx)), 'ttest2', [])
	
	%anovan
	
	fh = figure('Name', [cur_alignment, ': ', factor_name]);
	cur_x_vec = cur_data_struct.raster_site_info.event_aligned_bincenter_ts_list;
	unique_factors = unique(factor_list(goodtrial_idx));
	factor_color = lines(length(unique_factors));
	legend_list = {};
	hold on
	for i_factor_instance = 1 : length(unique_factors)
		cur_factor_instance = unique_factors{i_factor_instance};
		legend_list(end+1) = {cur_factor_instance};
		cur_factor_instance_trial_idx =  find(strcmp(factor_list, cur_factor_instance));
		cur_trial_idx = intersect(cur_factor_instance_trial_idx, goodtrial_idx);
		cur_data = mean(cur_data_struct.raster_data(cur_trial_idx, :), 1, 'omitnan');
		plot(cur_x_vec, cur_data, 'Color', factor_color(i_factor_instance, :));
		%[N, edges, bin] = histcounts(cur_data_struct.raster_data(cur_trial_idx, :), size(cur_data_struct.raster_data,2));
	end
	y_limits = get(gca(), 'YLim');
	plot([0 0], y_limits, 'Color', [0 0 0]);
	
	hold off
	legend(legend_list);
	title({['Alignment: ', cur_alignment]}, 'Interpreter', 'None');
	subtitle({['Factor: ', factor_name]}, 'Interpreter', 'None');
	xlabel('Time relative to alignment event [ms]');
	ylabel('Firing rate [???]');
	
	write_out_figure(fh, fullfile(output_directory, ['UnitPlot.', session_ID, '.', set.value, '.', cur_alignment, '.', factor_name, '.pdf']));
	
end	
% aggregation function: averaging







end

