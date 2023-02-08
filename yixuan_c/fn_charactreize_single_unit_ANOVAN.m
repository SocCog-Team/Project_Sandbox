function [] = fn_charactreize_single_unit_ANOVAN(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID)
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




for i_alignment = 1 : length(alignment_event_list)
	reference_alignment_data = unit_raster_by_alignment_event.(alignment_event_list{i_alignment});

	trials_in_set_idx = reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value);
	rewarded_trial_idx = reference_alignment_data.raster_site_info.TrialSets.ByOutcome.REWARD;
	
	DiffGo_factor_name = {'A_IFTrel_minus_Bgo_list','B_IFTrel_minus_Ago_list'};
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
	two_factor_name = 'TrialSubType_ByDiffGo_list';
	factor_idx = reference_alignment_data.raster_labels.(factor_name) + 1;
	two_factor_idx = reference_alignment_data.raster_labels.(two_factor_name) + 1;
	factor_uniqe_instances = [{'NONE'}; reference_alignment_data.unique_label_instances_struct.(factor_name)];
	two_factor_uniqe_instances = [{'NONE'};reference_alignment_data.unique_label_instances_struct.(two_factor_name)];
	factor_list = factor_uniqe_instances(factor_idx);
	two_factor_list = two_factor_uniqe_instances(two_factor_idx);
	combined_factor_list = append(factor_list, two_factor_list);
	
% 	[combined_unique_instances, instances_corresponding_idx,
% 	combined_factor_idx] = unique(combined_factor_list); it seems to be
% 	useless :-)
	
	
	existing_factor_idx = find(~strcmp(DiffGo_list, 'NONE'));
	long_DiffGo_idx =  find(~strcmp(DiffGo_list, 'ABgo'));
	goodtrial_idx = intersect(intersect(intersect(rewarded_trial_idx, existing_factor_idx),  trials_in_set_idx), long_DiffGo_idx);
	
% 	rewrite factor two list
	two_factor_list = two_factor_uniqe_instances(two_factor_idx(goodtrial_idx));


	cur_alignment = alignment_event_list{i_alignment};
	cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
	adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
	firing_rate_Hz = sum(cur_data_struct.raster_data(goodtrial_idx, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
	[p, tbl, stats, terms] = anovan(firing_rate_Hz, {factor_list(goodtrial_idx),two_factor_list},'model',2,'varnames',{'LR','DiffGo'},'display','off');
	eta_squared = [];
	for i = 1:3
		eta_squared(end+1)= cell2mat(tbl(1+i,5))/(cell2mat(tbl(1+i,5))+cell2mat(tbl(5,5)));
	end
% 	multiple comparison in case anyone needs it
% 	[results,~,~,gnames] = multcompare(stats,"Dimension",[1 2]);
% 	tbl_interaction = array2table(results,"VariableNames", ...
%     ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
% 	tbl_interaction.("Group A")=gnames(tbl_interaction.("Group A"));
% 	tbl_interaction.("Group B")=gnames(tbl_interaction.("Group B"));
	
	% plot the graph and calculat the effect size
	
	fh = figure('Name', [cur_alignment, ': ', factor_name, ' & ', two_factor_name], 'Visible', figure_visibility_string);
	cur_x_vec = cur_data_struct.raster_site_info.event_aligned_bincenter_ts_list;
	unique_factors = unique(combined_factor_list(goodtrial_idx));
	short_unique_factors{find(strcmp(unique_factors, 'AlSoloA_Go: A<B'))} = 'Al: A<B';
	short_unique_factors{find(strcmp(unique_factors, 'ArSoloA_Go: A<B'))} = 'Ar: A<B';
	short_unique_factors{find(strcmp(unique_factors, 'AlSoloA_Go: B<A'))} = 'Al: B<A';
	short_unique_factors{find(strcmp(unique_factors, 'ArSoloA_Go: B<A'))} = 'Ar: B<A';
	short_unique_factors = short_unique_factors';
	factor_color = lines(length(unique_factors));
	legend_list = {};
	hold on
	for i_factor_instance = 1 : length(unique_factors)
		cur_factor_instance = unique_factors{i_factor_instance};
		legend_list(end+1) = {short_unique_factors{i_factor_instance}};
		cur_factor_instance_trial_idx =  find(strcmp(combined_factor_list, cur_factor_instance));
		cur_trial_idx = intersect(cur_factor_instance_trial_idx, goodtrial_idx);
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
	leg = legend(legend_list, 'Interpreter', 'None');
	leg.ItemTokenSize=[10,15];
	title({['Alignment: ', cur_alignment, ' LR & DiffGo' ]}, 'Interpreter', 'None');
	subtitle({[' two-way anova p(LR,DiffGo,Interaction) = [', num2str(p(1), '%.4f'),' ',num2str(p(2), '%.4f'),' ',num2str(p(3), '%.4f'), ...
		']'],[' Corresponding eta_squared = [', num2str(eta_squared(1), '%.3f'), ' ',num2str(eta_squared(2), '%.3f'),' ',num2str(eta_squared(3), '%.3f'),']']}, 'Interpreter', 'None');
	xlabel('Time relative to alignment event [ms]');
	ylabel('Firing rate [Hz]');
% 	cur_txt = ['t test p-value =' num2str(aggregate_struct.p)]
% 	annotation('textbox',[.9 .5 .1 .2], ...
%     'String',cur_txt,'EdgeColor','none');
% 	cur_text.FontSize = 9;
% 	
	unit_name_channel = unit_name{5};
	unit_name_cluster = unit_name{6};
	write_out_figure(fh, fullfile(output_directory, [session_ID, '.', unit_name_channel, '.', unit_name_cluster, '.',  set.value, '.', cur_alignment, '.', 'Interaction_LR&DiffGo', '.pdf']));
	
	fh_list(i_alignment) = fh;
% 	close(fh);
	
end	
% aggregation function: averaging



for i_fh = 1 : length(fh_list)
	cur_fh = fh_list(i_fh);
	close(cur_fh);
end
end

