function [] = fn_charactreize_single_unit_ANOVA(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID)
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

gaussian_filter_width = 150;
Abl_degree = atand((960-849)/(450-389))+180;
Aml_degree = atand((500-450)/(960-849))+270;
Atl_degree = 360-atand((960-849)/(612-450));
Atr_degree = atand((1072-960)/(612-450));
Amr_degree = 90-atand((500-450)/(1072-960));
Abr_degree = 180-atand((1072-960)/(450-389));
degree_list = [Abl_degree, Abr_degree, Aml_degree, Amr_degree, Atl_degree, Atr_degree];

firing_rate_timing =[];
timing_factor = {};
for i_alignment = 1 : length(alignment_event_list)
	reference_alignment_data = unit_raster_by_alignment_event.(alignment_event_list{i_alignment});

	trials_in_set_idx = reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value);
	rewarded_trial_idx = reference_alignment_data.raster_site_info.TrialSets.ByOutcome.REWARD;
	% find valid trials in the set
	% which measure to explain with the analysis, here from decoding label
	% lists
	% factor_name = 'A_pos_list';
	factor_name = 'A_pos_list';
	factor_idx = reference_alignment_data.raster_labels.(factor_name) + 1;
	factor_uniqe_instances = [{'NONE'}; reference_alignment_data.unique_label_instances_struct.(factor_name)];
	factor_list = factor_uniqe_instances(factor_idx);
	existing_factor_idx = find(~strcmp(factor_list, 'NONE'));

	goodtrial_idx = intersect(intersect(rewarded_trial_idx, existing_factor_idx),  trials_in_set_idx);


	cur_alignment = alignment_event_list{i_alignment};
	cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
	adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
	firing_rate_Hz = sum(cur_data_struct.raster_data(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
	
	[p, tbl, stats] = anova1(firing_rate_Hz(goodtrial_idx), factor_list(goodtrial_idx),'off');
	cur_group_idx = [factor_idx(goodtrial_idx)];
	[uGroup, aIx, bIx] = unique(cur_group_idx, 'rows');
	[sorted_bIx, sort_idx] = sort(bIx);
	
	if isnan(p) == 0
		temp = mes1way(firing_rate_Hz(goodtrial_idx(sort_idx)), 'partialeta2', 'group',cur_group_idx(sort_idx));
		eta_squared = [];
		for i = 1:length(p)
			eta_squared(end+1)= temp.partialeta2(i);
		end
	else
		eta_squared = [];
		for i = 1:length(p)
			eta_squared(end+1)= nan;
		end
	end % 	the between group ss divided by total ss
	
	% plot the average firing rate plot
	
	fh = figure('Name', [cur_alignment, ': ', factor_name], 'Visible', figure_visibility_string);
	t = tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact');
	cur_x_vec = cur_data_struct.raster_site_info.event_aligned_bincenter_ts_list;
	unique_factors = unique(factor_list(goodtrial_idx));
	factor_color = lines(length(unique_factors));
	legend_list = {};

	nexttile
	for i_factor_instance = 1 : length(unique_factors)
		cur_factor_instance = unique_factors{i_factor_instance};
		cur_factor_instance_trial_idx =  find(strcmp(factor_list, cur_factor_instance));
		cur_trial_idx = intersect(cur_factor_instance_trial_idx, goodtrial_idx);
		cur_data = mean(cur_data_struct.raster_data(cur_trial_idx, :), 1, 'omitnan') * (1000 / cur_data_struct.raster_site_info.bin_width_ms);
% 		cur_raster = cur_data_struct.raster_data(cur_trial_idx, adjusted_window_range(1):adjusted_window_range(2));
		legend_list(end+1) = {cur_factor_instance};
	
		hold on
		cur_smooth_data = smoothdata(cur_data, 'gaussian', gaussian_filter_width);
		plot(cur_x_vec, cur_smooth_data, 'Color', factor_color(i_factor_instance, :));
		%[N, edges, bin] = histcounts(cur_data_struct.raster_data(cur_trial_idx, :), size(cur_data_struct.raster_data,2));
	end
	y_limits = get(gca(), 'YLim');
	% show alinment as vertiacl line
	plot([0 0], y_limits, 'Color', [0 0 0]);
	title('Avergae firing rate to six positions');
	
	% show the statistics analysis window
	%plot(window.range, [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
	patch([window.range(1), window.range(2), window.range(2), window.range(1)], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1);
	legend(legend_list,'Location','eastoutside');
	title({['Factor: ', factor_name, ' (anova p-value =', num2str(p, '%.4f'), ' partial eta squared = ', num2str(eta_squared, '%.3f'), ')']}, 'Interpreter', 'None');
	xlabel('Time relative to alignment event [ms]');
	ylabel('Firing rate [Hz]');
	hold off
	% show the statistics analysis window
	%plot(window.range, [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);

% 	plot the tuning curve
	factor_firing_rate =[];
	firing_rate_frame = [];
	degree_frame = [];
	for i_factor_instance = 1 : length(unique_factors)
		cur_factor_instance = unique_factors{i_factor_instance};
		cur_factor_instance_trial_idx =  find(strcmp(factor_list, cur_factor_instance));
		cur_trial_idx = intersect(cur_factor_instance_trial_idx, goodtrial_idx);
		cur_data = mean(cur_data_struct.raster_data(cur_trial_idx, :), 1, 'omitnan')*length(cur_data_struct.raster_data(cur_trial_idx, :));
% 		cur_raster = cur_data_struct.raster_data(cur_trial_idx, adjusted_window_range(1):adjusted_window_range(2));
		legend_list(end+1) = {[cur_factor_instance, ' (N: ', num2str(length(cur_trial_idx), '%d'), ')']};
		cur_factor_firing_rate = sum(cur_data_struct.raster_data(cur_trial_idx, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
		factor_firing_rate(end+1)=mean(cur_factor_firing_rate);
		firing_rate_frame = cat(1,firing_rate_frame, cur_factor_firing_rate);
		degree_frame = cat(1, degree_frame, repelem(degree_list(i_factor_instance),length(cur_factor_firing_rate))');
		
		%[N, edges, bin] = histcounts(cur_data_struct.raster_data(cur_trial_idx, :), size(cur_data_struct.raster_data,2));
	end
	
	boxplot_frame = table(degree_frame, firing_rate_frame);
	nexttile
	mystring = 'a(1)+a(2)*cosd(theta - a(3))';
	myfun= inline(mystring, 'a', 'theta');
	a = nlinfit(degree_list, factor_firing_rate, myfun, [1 1 0]);
	factor_fit = myfun(a,linspace(0,360));
	hold on
	boxplot(boxplot_frame.firing_rate_frame, boxplot_frame.degree_frame, 'Positions',boxplot_frame.degree_frame);
	y_limits = get(gca(), 'YLim');
	axis([0 360 y_limits])
	plot(linspace(0,360), factor_fit, '-','DisplayName', 'Tuning curve');
	plot([180 180], y_limits, '--','Color', [0 0 0]);
	legend('Tuning curve','L/R Line','Location','eastoutside')
	xticks(0:60:360)
	xticklabels({'0','60','120','180','240','300'})
	hold off
	xlabel('Degree [°]');
	ylabel('Firing rate [Hz]');

	sgtitle({['Alignment: ', cur_alignment]}, 'Interpreter', 'None');
% 	subtitle(subplot(6,1,1:3), 'Tuning Curve')
	
	unit_name_channel = unit_name{5};
	unit_name_cluster = unit_name{6};
	write_out_figure(fh, fullfile(output_directory, [session_ID, '.', unit_name_channel, '.', unit_name_cluster, '.',  set.value, '.', cur_alignment, '.', factor_name, '.pdf']));
	
	fh_list(i_alignment) = fh;
% 	close(fh);




% for i_fh = 1 : length(fh_list)
% 	cur_fh = fh_list(i_fh);
% 	close(cur_fh);
end




end

