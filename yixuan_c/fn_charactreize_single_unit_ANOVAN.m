function [] = fn_charactreize_single_unit_ANOVAN(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID)
%FN_CHARACTREIZE_SINGLE_UNIT Summary of this function goes here
%   Detailed explanation goes here


InvisibleFigures = 1;
if (InvisibleFigures)
	figure_visibility_string = 'off';
	disp('Using invisible figures, for speed.');
else
	figure_visibility_string = 'on';
	disp('Using visible figures, for debugging/formatting.');
end
% define parameters
% data sets (e.g. Solo vresus Dyadic)
set.type = 'ByTrialSubType';
set.value ='SoloA';
% set.value = {'Dyadic','SoloA'};
% time windows, range relative to alignment
window.range = [-500 500];
gaussian_filter_width = 150;
ANOVAN_by_factor = 0;
ANOVAN_by_factor_DiffGo = 0;
min_trials_per_condition_to_plot = 5;


for i_alignment = 1 : length(alignment_event_list)
	reference_alignment_data = unit_raster_by_alignment_event.(alignment_event_list{i_alignment});
	
	rewarded_trial_idx = reference_alignment_data.raster_site_info.TrialSets.ByOutcome.REWARD;
	% 	Dyadic_idx = reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value{1});
	% 	SoloA_idx = reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value{2});
	% 	trials_in_set_idx = cat(1,  Dyadic_idx, SoloA_idx);
	trials_in_set_idx =  reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value);
	
	DiffGo_factor_name = {'A_IFTrel_minus_Bgo_list','A_IFTrel_minus_Bgo_list'};
	cur_DiffGo_factor_name = DiffGo_factor_name{i_alignment};
	DiffGo_trial_unique_instances = reference_alignment_data.unique_label_instances_struct.(cur_DiffGo_factor_name);
	DiffGo_trial_unique_instances = ['NONE'; DiffGo_trial_unique_instances];
	DiffGo_idx = reference_alignment_data.raster_labels.(cur_DiffGo_factor_name) + 1;
	DiffGo_list = DiffGo_trial_unique_instances(DiffGo_idx);
	% find valid trials in the set
	% which measure to explain with the analysis, here from decoding label
	% lists
	% factor_name = 'A_pos_list';
	factor_name = 'A_LR_pos_list';
	B_factor_name = 'B_LR_pos_list';
	two_factor_name = 'TrialSubType_ByDiffGo_list';
	factor_idx = reference_alignment_data.raster_labels.(factor_name) + 1;
	two_factor_idx = reference_alignment_data.raster_labels.(two_factor_name) + 1;
	factor_uniqe_instances = [{'NONE'}; reference_alignment_data.unique_label_instances_struct.(factor_name)];
	two_factor_uniqe_instances = [{'NONE'};reference_alignment_data.unique_label_instances_struct.(two_factor_name)];
	% 	two_factor_uniqe_instances_idx =  find(~strcmp(two_factor_uniqe_instances, 'None'));
	% 	two_factor_uniqe_instances = two_factor_uniqe_instances(two_factor_uniqe_instances_idx);
	factor_list = factor_uniqe_instances(factor_idx);
	two_factor_list = two_factor_uniqe_instances(two_factor_idx);
	
	B_factor_idx = reference_alignment_data.raster_labels.(B_factor_name) + 1;
	B_factor_uniqe_instances = [{'NONE'}; reference_alignment_data.unique_label_instances_struct.(B_factor_name)];
	B_factor_list = B_factor_uniqe_instances(B_factor_idx);
	
	combined_factor_list = append(factor_list,'_', two_factor_list);
	
	% 	[combined_unique_instances, instances_corresponding_idx,
	% 	combined_factor_idx] = unique(combined_factor_list); it seems to be
	% 	useless :-)
	
	
	existing_factor_idx = find(~strcmp(DiffGo_list, 'NONE'));
	long_DiffGo_idx =  find(~strcmp(DiffGo_list, 'ABgo'));
	B_existing_factor_idx = find(~strcmp(two_factor_list, 'NONE'));
	A_existing_factor_idx = find(~strcmp(factor_list, 'NONE'));
	goodtrial_idx = intersect(intersect(intersect(rewarded_trial_idx, existing_factor_idx),  trials_in_set_idx),  long_DiffGo_idx);
	
	% 	for ANOVAN separated by factors
	if (ANOVAN_by_factor)
		cur_alignment = alignment_event_list{i_alignment};
		cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
		unique_factors = unique(factor_list(goodtrial_idx));
		fh = figure('Name', [cur_alignment, ': ', factor_name, ' & ', two_factor_name], 'Visible', figure_visibility_string);
		t = tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact');
		for i_factor = 1:length(unique_factors)
			nexttile
			cur_data_idx = find(strcmp(factor_list, unique_factors(i_factor)));
			cur_goodtrial_idx = intersect(cur_data_idx, goodtrial_idx);
			adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
			
			% 			cur_Dyadic_idx = intersect(Dyadic_idx, cur_goodtrial_idx);
			% 			cur_SoloA_idx = intersect(SoloA_idx, cur_goodtrial_idx);
			%
			
			two_factor_list = erase(two_factor_list, "Dyadic_Go: ");
			two_factor_list = erase(two_factor_list, "SoloA_Go: ");
			
			
			trial_sub_type_unique_idx = reference_alignment_data.raster_site_info.report_struct.data(:, reference_alignment_data.raster_site_info.report_struct.cn.A_TrialSubTypeENUM_idx);
			trialsubtype_list = reference_alignment_data.raster_site_info.report_struct.unique_lists.A_TrialSubTypeENUM(trial_sub_type_unique_idx)';
			
			exclude_trial_idx = find(ismember(two_factor_list, {'A=B, B faster', 'A=B, A faster'}));
			
			cur_goodtrial_idx = setdiff(cur_goodtrial_idx, exclude_trial_idx);
			% 			stats test: ANOVAN based on factor
			%firing_rate_Hz = sum(cur_data_struct.raster_data(cur_goodtrial_idx, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
			firing_rate_Hz = sum(cur_data_struct.raster_data(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
			
			
			% stats
			[p, tbl, stats, terms] = anovan(firing_rate_Hz(cur_goodtrial_idx), {trialsubtype_list(cur_goodtrial_idx) two_factor_list(cur_goodtrial_idx)},'model', 'full' ,'varnames',{'TrialType','DiffGo'},'display','off');
			unique_two_factor = unique(two_factor_list);
			for i_two_factor = 1: length(unique(two_factor_list))
				cur_idx = find(strcmp(two_factor_list, unique_two_factor(i_two_factor)));
				two_factor_idx(cur_idx) = i_two_factor;
			end
			cur_group_idx = [trial_sub_type_unique_idx(cur_goodtrial_idx) two_factor_idx(cur_goodtrial_idx)];
			[uGroup, aIx, bIx] = unique(cur_group_idx, 'rows');
			[sorted_bIx, sort_idx] = sort(bIx);
			temp = mes2way(firing_rate_Hz(cur_goodtrial_idx(sort_idx)), cur_group_idx(sort_idx, :), {'eta2', 'partialeta2'});
			
			eta_squared = [];
			for i = 1:3
				eta_squared(end+1)=  temp.partialeta2(i);
			end
			
			% plot the graph and calculat the effect size
			
			cur_x_vec = cur_data_struct.raster_site_info.event_aligned_bincenter_ts_list;
			cur_combined_factor_list = append(trialsubtype_list,'_', two_factor_list);
			cur_unique_combined_factors = unique(cur_combined_factor_list(cur_goodtrial_idx));
			factor_color = lines(length(cur_unique_combined_factors));
			legend_list = {};
			hold on
			for i_factor_instance = 1 : length(cur_unique_combined_factors)
				cur_factor_instance = cur_unique_combined_factors{i_factor_instance};
				legend_list(end+1) = {cur_unique_combined_factors{i_factor_instance}};
				cur_factor_instance_trial_idx =  find(strcmp(cur_combined_factor_list, cur_factor_instance));
				cur_trial_idx = intersect(cur_factor_instance_trial_idx, cur_goodtrial_idx);
				cur_data = mean(cur_data_struct.raster_data(cur_trial_idx, :), 1, 'omitnan') * (1000 / cur_data_struct.raster_site_info.bin_width_ms);
				cur_smooth_data = smoothdata(cur_data, 'gaussian', gaussian_filter_width);
				plot(cur_x_vec, cur_smooth_data, 'Color', factor_color(i_factor_instance, :), 'LineWidth', 1.5);
				%[N, edges, bin] = histcounts(cur_data_struct.raster_data(cur_trial_idx, :), size(cur_data_struct.raster_data,2));
			end
			y_limits = get(gca(), 'YLim');
			% show alinment as vertiacl line
			plot([0 0], y_limits, 'Color', [0 0 0]);
			
			% show the statistics analysis window
			%plot(window.range, [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
			patch([window.range(1), window.range(2), window.range(2), window.range(1)], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1);
			
			hold off
			if i_factor == 1
				leg = legend(legend_list, 'Interpreter', 'None','AutoUpdate','off','Location','eastoutside', 'FontSize', 9);
				leg.ItemTokenSize=[10,15];
			end
			title({[unique_factors{i_factor},' two-way anova of TrialType,DiffGo,Interaction']});
			subtitle({['p = [', num2str(p(1), '%.4f'),' ',num2str(p(2), '%.4f'),' ',num2str(p(3), '%.4f'), ...
				']'],[' partial eta_squared = [', num2str(eta_squared(1), '%.3f'), ' ',num2str(eta_squared(2), '%.3f'),' ',num2str(eta_squared(3), '%.3f'),']']}, 'Interpreter', 'None', 'FontSize',12);
			xlabel(t,'Time relative to alignment event [ms]');
			ylabel('Firing rate [Hz]');
			sgtitle({['Alignment: ', cur_alignment, ' Trialtype & DiffGo separated by LR' ]}, 'Interpreter', 'None');
			
			% 	cur_txt = ['t test p-value =' num2str(aggregate_struct.p)]
			% 	annotation('textbox',[.9 .5 .1 .2], ...
			%     'String',cur_txt,'EdgeColor','none');
			% 	cur_text.FontSize = 9;
			%
			unit_name_channel = unit_name{5};
			unit_name_cluster = unit_name{6};
			
		end
		write_out_figure(fh, fullfile(output_directory, [session_ID, '.', unit_name_channel, '.', unit_name_cluster, '.', cur_alignment, '.', 'Interaction_TrialType&DiffGo', '.pdf']));
		
	end
	
	
	
	% ANOVAN separated by DiffGo
	if (ANOVAN_by_factor_DiffGo)
		cur_alignment = alignment_event_list{i_alignment};
		cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
		two_factor_list = erase(two_factor_list, "Dyadic_Go: ");
		two_factor_list = erase(two_factor_list, "SoloA_Go: ");
		unique_factors = unique(two_factor_list(goodtrial_idx));
		fh = figure('Name', [cur_alignment, ': ', factor_name, ' & ', two_factor_name], 'Visible', figure_visibility_string, 'Position', [1 1 600 800]);
		t = tiledlayout(length(unique_factors),1,'TileSpacing','Compact','Padding','Compact');
		
		trial_sub_type_unique_idx = reference_alignment_data.raster_site_info.report_struct.data(:, reference_alignment_data.raster_site_info.report_struct.cn.A_TrialSubTypeENUM_idx);
		trialsubtype_list = reference_alignment_data.raster_site_info.report_struct.unique_lists.A_TrialSubTypeENUM(trial_sub_type_unique_idx)';
		combined_factor_list = append(factor_list,'_', B_factor_list);
		cur_combined_factor_list = combined_factor_list(goodtrial_idx);
		[cur_unique_combined_factors, ia, ic] = unique(cur_combined_factor_list);
		factor_color = lines(length(cur_unique_combined_factors));
		
		
		for i_factor = 1:length(unique_factors)
			nexttile
			cur_data_idx = find(strcmp(two_factor_list, unique_factors(i_factor)));
			cur_goodtrial_idx = intersect(cur_data_idx, goodtrial_idx);
			adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
			
			% 			exclude_trial_idx = find(ismember(two_factor_list, {'A=B, B faster', 'A=B, A faster'}));
			% 			cur_goodtrial_idx = setdiff(cur_goodtrial_idx, exclude_trial_idx);
			%	anova2 for trialtype & LR
			% 			firing_rate_Hz = sum(cur_data_struct.raster_data(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
			% 			[p, tbl, stats, terms] = anovan(firing_rate_Hz(cur_goodtrial_idx), {trialsubtype_list(cur_goodtrial_idx) factor_list(cur_goodtrial_idx)}, 'model', 'full' ,'varnames',{'TrialType', 'LR'}, 'display', 'off');
			%
			% 			stats test: ANOVAN based on A_LR and B_LR
			firing_rate_Hz = sum(cur_data_struct.raster_data(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
			[p, tbl, stats, terms] = anovan(firing_rate_Hz(cur_goodtrial_idx), {factor_list(cur_goodtrial_idx), B_factor_list(cur_goodtrial_idx)},'model',2,'varnames',{'A_LR','B_LR'},'display','off');
			
			cur_group_idx = [factor_idx(cur_goodtrial_idx) B_factor_idx(cur_goodtrial_idx)];
			[uGroup, aIx, bIx] = unique(cur_group_idx, 'rows');
			[sorted_bIx, sort_idx] = sort(bIx);
			
			if isnan(p) == 0
				temp = mes2way(firing_rate_Hz(cur_goodtrial_idx(sort_idx)), cur_group_idx(sort_idx, :), {'eta2', 'partialeta2'});
				eta_squared = [];
				for i = 1:length(p)
					eta_squared(end+1)= temp.partialeta2(i);
				end
			else
				eta_squared = [];
				for i = 1:length(p)
					eta_squared(end+1)= nan;
				end
			end
			% plot the graph and calculate the effect size
			
			cur_x_vec = cur_data_struct.raster_site_info.event_aligned_bincenter_ts_list;
			% 			cur_combined_factor_list = combined_factor_list(cur_goodtrial_idx);
			% 			[cur_unique_combined_factors, ia, ic] = unique(cur_combined_factor_list);
			% 			factor_color = lines(length(cur_unique_combined_factors));
			legend_list = {};
			hold on
			for i_factor_instance = 1 : length(cur_unique_combined_factors)
				cur_factor_instance = cur_unique_combined_factors{i_factor_instance};
				cur_factor_instance_trial_idx =  find(strcmp(combined_factor_list, cur_factor_instance));
				cur_trial_idx = intersect(cur_factor_instance_trial_idx, cur_goodtrial_idx);
				
				cur_data = mean(cur_data_struct.raster_data(cur_trial_idx, :), 1, 'omitnan') * (1000 / cur_data_struct.raster_site_info.bin_width_ms);
				if (length(cur_trial_idx) >= min_trials_per_condition_to_plot)
					cur_smooth_data = smoothdata(cur_data, 'gaussian', gaussian_filter_width);
				else
					% this will not show, but still fill the legend
					% correctly
					cur_smooth_data = cur_data * NaN;
				end
				plot(cur_x_vec, cur_smooth_data, 'Color', factor_color(i_factor_instance, :), 'LineWidth', 1.5);
				%[N, edges, bin] = histcounts(cur_data_struct.raster_data(cur_trial_idx, :), size(cur_data_struct.raster_data,2));
				legend_list(end+1) = {[cur_unique_combined_factors{i_factor_instance}, ' (N: ', num2str(length(cur_trial_idx), '%d'), ')']};
			end
			y_limits = get(gca(), 'YLim');
			% show alinment as vertiacl line
			plot([0 0], y_limits, 'Color', [0 0 0]);
			
			% show the statistics analysis window
			%plot(window.range, [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
			patch([window.range(1), window.range(2), window.range(2), window.range(1)], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1);
			
			hold off
			%if i_factor == 1
			leg = legend(legend_list, 'Interpreter', 'None','AutoUpdate','off','Location','eastoutside', 'FontSize', 10);
			leg.ItemTokenSize=[10,15];
			%end
			title({[unique_factors{i_factor},' A_LR, B_LR, Interaction']}, 'FontSize', 12,'Interpreter', 'None');
			subtitle({['p = [', num2str(p(1), '%.4f'),' ',num2str(p(2), '%.4f'),' ',num2str(p(3), '%.4f'), ...
				']'],[' patial eta_squared = [', num2str(eta_squared(1), '%.3f'), ' ',num2str(eta_squared(2), '%.3f'),' ',num2str(eta_squared(3), '%.3f'),']'], ['number of trials: ', num2str(length(cur_goodtrial_idx))]}, 'Interpreter', 'None', 'FontSize',11);
			xlabel(t,'Time relative to alignment event [ms]');
			ylabel('Firing rate [Hz]', 'FontSize', 12);
			sgtitle({['Alignment: ', cur_alignment, ' self & other actions analysis separated by DiffGo' ]}, 'Interpreter', 'None');
			
			% 	cur_txt = ['t test p-value =' num2str(aggregate_struct.p)]
			% 	annotation('textbox',[.9 .5 .1 .2], ...
			%     'String',cur_txt,'EdgeColor','none');
			% 	cur_text.FontSize = 9;
			%
			unit_name_channel = unit_name{5};
			unit_name_cluster = unit_name{6};
			write_out_figure(fh, fullfile(output_directory, [session_ID, '.', unit_name_channel, '.', unit_name_cluster, '.', cur_alignment, '.', 'anova2_A_LR&B_LR', '.pdf']));
			
		end
	end
	
	
	
	
	% 	rewrite factor two list
	if (ANOVAN_by_factor ==0) && (ANOVAN_by_factor_DiffGo == 0)
		cur_alignment = alignment_event_list{i_alignment};
		cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
		adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
		firing_rate_Hz = sum(cur_data_struct.raster_data(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
		[p, tbl, stats, terms] = anovan(firing_rate_Hz(goodtrial_idx), {factor_list(goodtrial_idx), two_factor_list(goodtrial_idx)},'model',2,'varnames',{'LR','DiffGo'},'display','off');
		cur_group_idx = [factor_idx(goodtrial_idx) two_factor_idx(goodtrial_idx)];
		[uGroup, aIx, bIx] = unique(cur_group_idx, 'rows');
		[sorted_bIx, sort_idx] = sort(bIx);
		
		if isnan(p) == 0
			temp = mes2way(firing_rate_Hz(goodtrial_idx(sort_idx)), cur_group_idx(sort_idx, :), {'eta2', 'partialeta2'});
			eta_squared = [];
			for i = 1:length(p)
				eta_squared(end+1)= temp.partialeta2(i);
			end
		else
			eta_squared = [];
			for i = 1:length(p)
				eta_squared(end+1)= nan;
			end
		end
		% 	multiple comparison in case anyone needs it
		% 	[results,~,~,gnames] = multcompare(stats,"Dimension",[1 2]);
		% 	tbl_interaction = array2table(results,"VariableNames", ...
		%     ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
		% 	tbl_interaction.("Group A")=gnames(tbl_interaction.("Group A"));
		% 	tbl_interaction.("Group B")=gnames(tbl_interaction.("Group B"));
		
		% plot the graph and calculat the effect size
		
		fh = figure('Name', [cur_alignment, ': ', factor_name, ' & ', two_factor_name], 'Visible', figure_visibility_string, 'Position', [1 1 600 400]);
		cur_x_vec = cur_data_struct.raster_site_info.event_aligned_bincenter_ts_list;
		unique_factors = unique(combined_factor_list(goodtrial_idx));
		short_unique_factors = erase(unique_factors, "SoloA_Go: ");
		factor_color = lines(length(unique_factors));
		legend_list = {};
		hold on
		for i_factor_instance = 1 : length(unique_factors)
			cur_factor_instance = unique_factors{i_factor_instance};
			cur_factor_instance_trial_idx =  find(strcmp(combined_factor_list, cur_factor_instance));
			cur_trial_idx = intersect(cur_factor_instance_trial_idx, goodtrial_idx);
			cur_data = mean(cur_data_struct.raster_data(cur_trial_idx, :), 1, 'omitnan') * (1000 / cur_data_struct.raster_site_info.bin_width_ms);
			if (length(cur_trial_idx) >= min_trials_per_condition_to_plot)
				cur_smooth_data = smoothdata(cur_data, 'gaussian', gaussian_filter_width);
			else
				% this will not show, but still fill the legend
				% correctly
				cur_smooth_data = cur_data * NaN;
			end
			legend_list(end+1) = {[short_unique_factors{i_factor_instance}, ' (N: ', num2str(length(cur_trial_idx), '%d'), ')']};
			plot(cur_x_vec, cur_smooth_data, 'Color', factor_color(i_factor_instance, :), 'LineWidth', 1.5);
			%[N, edges, bin] = histcounts(cur_data_struct.raster_data(cur_trial_idx, :), size(cur_data_struct.raster_data,2));
		end
		y_limits = get(gca(), 'YLim');
		% show alinment as vertiacl line
		plot([0 0], y_limits, 'Color', [0 0 0]);
		
		% show the statistics analysis window
		%plot(window.range, [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
		patch([window.range(1), window.range(2), window.range(2), window.range(1)], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1);
		
		hold off
		leg = legend(legend_list, 'Interpreter', 'None','Location','eastoutside');
		leg.ItemTokenSize=[10,15];
		title({['Alignment: ', cur_alignment, ' LR & DiffGo ', set.value ]}, 'Interpreter', 'None', 'FontSize', 11);
		subtitle({[' two-way anova p(LR,DiffGo,Interaction) = [', num2str(p(1), '%.4f'),' ',num2str(p(2), '%.4f'),' ',num2str(p(3), '%.4f'), ...
			']'],[' partial eta_squared = [', num2str(eta_squared(1), '%.3f'), ' ',num2str(eta_squared(2), '%.3f'),' ',num2str(eta_squared(3), '%.3f'),']']}, 'Interpreter', 'None');
		xlabel('Time relative to alignment event [ms]');
		ylabel('Firing rate [Hz]');
		
		unit_name_channel = unit_name{5};
		unit_name_cluster = unit_name{6};
		write_out_figure(fh, fullfile(output_directory, [session_ID, '.', unit_name_channel, '.', unit_name_cluster, '.',  set.value, '.', cur_alignment, '.', 'Interaction_LR&DiffGo', '.pdf']));
		
		fh_list(i_alignment) = fh;
		% 	close(fh);
		
	end
	%
	
end % alignment
% aggregation function: averaging



% for i_fh = 1 : length(fh_list)
% 	cur_fh = fh_list(i_fh);
% 	close(cur_fh);
% end
end

