function [] = fn_characterize_individual_units_population(raster_dir_relative_to_alignment, initial_alignment_event, PETHdata_base_dir, proto_unit_list, n_units, alignment_event_list, output_directory, session_ID)
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

gaussian_filter_width = 50;



for i_alignment = 1 : length(alignment_event_list)
	
	Left_mean_firing_rate = [];
	Right_mean_firing_rate = [];
	sig_idx =[];
	insig_idx = [];
	eta_squared = [];
	i_coloumn = 0;
	for i_unit = 1 : n_units
		proto_unit_name = proto_unit_list(i_unit).name;
		unique_label_instances_name = regexprep(proto_unit_name, '.raster.mat', '.unique_label_instances.mat');
		load(fullfile(PETHdata_base_dir, initial_alignment_event, 'raster_format', unique_label_instances_name));
		cur_alignment_event = alignment_event_list{i_alignment};
		cur_unit_name = regexprep(proto_unit_name, initial_alignment_event, cur_alignment_event);
		cur_unit_dir = fullfile(PETHdata_base_dir, cur_alignment_event, raster_dir_relative_to_alignment);
		disp(['Loading unit: ', cur_unit_name]);
		% 		cur_unit_raster_data = load(fullfile(cur_unit_dir, cur_unit_name));
		unit_raster_by_alignment_event.(cur_alignment_event) = load(fullfile(cur_unit_dir, cur_unit_name));
		unit_raster_by_alignment_event.(cur_alignment_event).unique_label_instances_struct = unique_label_instances_struct;
		
		reference_alignment_data = unit_raster_by_alignment_event.(alignment_event_list{i_alignment});
		
		trials_in_set_idx = reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value);
		rewarded_trial_idx = reference_alignment_data.raster_site_info.TrialSets.ByOutcome.REWARD;
		% find valid trials in the set
		% which measure to explain with the analysis, here from decoding label
		% lists
		
		
		factor_name = 'A_LR_pos_list';
		factor_idx = reference_alignment_data.raster_labels.(factor_name) + 1;
		factor_uniqe_instances = [{'NONE'}; reference_alignment_data.unique_label_instances_struct.(factor_name)];
		factor_list = factor_uniqe_instances(factor_idx);
		two_factor_name = 'TrialSubType_ByDiffGo_list';
		two_factor_uniqe_instances = [{'NONE'};reference_alignment_data.unique_label_instances_struct.(two_factor_name)];
		two_factor_idx = reference_alignment_data.raster_labels.(two_factor_name) + 1;
		two_factor_list = two_factor_uniqe_instances(two_factor_idx);
		combined_factor_list = append(factor_list, two_factor_list);
		
		existing_factor_idx = find(~strcmp(factor_list, 'NONE'));
		goodtrial_idx = intersect(intersect(rewarded_trial_idx, existing_factor_idx),  trials_in_set_idx);
		
		
		cur_alignment = alignment_event_list{i_alignment};
		cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
		adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
		
% 		for ANOVAN
		firing_rate_Hz = sum(cur_data_struct.raster_data(goodtrial_idx, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
		[p, tbl, stats, terms] = anovan(firing_rate_Hz, {factor_list(goodtrial_idx),two_factor_list(goodtrial_idx)},'model',2,'varnames',{'LR','DiffGo'}, 'display','off');
		cur_eta_squared = [];
		for i = 1:3
			cur_eta_squared(end+1)= cell2mat(tbl(1+i,5))/(cell2mat(tbl(1+i,5))+cell2mat(tbl(5,5)));
		end
		cur_eta_squared =cur_eta_squared';
		eta_squared(:, end+1)=cur_eta_squared;
		
% 		% 		for ANOVA
% 		firing_rate_Hz = sum(cur_data_struct.raster_data((goodtrial_idx), adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
% 		[p, tbl, stats] = anova1(firing_rate_Hz, factor_list(goodtrial_idx),'off');
% 		eta_squared(end+1) = cell2mat(tbl(2,2))/cell2mat(tbl(4,2));

		%%		for ttest
		% 		[ aggregate_struct, report_string ] = fn_statistic_test_and_report('Left', firing_rate_Hz(intersect(goodtrial_idx, Left_idx)), 'Right', firing_rate_Hz(intersect(goodtrial_idx, Right_idx)), 'ttest2', []);
		% 		Left_mean_firing_rate(end+1) = [aggregate_struct.Left_mean];
		% 		Right_mean_firing_rate(end+1) = [.Right_mean];
		% 		if aggregate_struct.p<0.05
		% 			sig_idx(end+1) = i_unit;
		% 		else
		% 			insig_idx(end+1)= i_unit;
		% 		end
		
		% 		for ANOVA and ANOVAN
		test = p<0.05;
		if test == 0
			i_coloumn = i_coloumn;
		else
			i_coloumn = i_coloumn +1;
		end
		for i_p = 1:length(p)
			if p(i_p)<0.05
				sig_idx(i_p,i_coloumn) = i_unit;
			else
				insig_idx(i_p, i_coloumn)= i_unit;
			end
		end
	end



% 	% 		plot the graph
	fh_population = figure('Name', [cur_alignment, ': ', 'A_LR_mean_firing_rates'], 'Visible', figure_visibility_string);
% 	hold on
% 	scatter(Left_mean_firing_rate(insig_idx), Right_mean_firing_rate(insig_idx),'filled','DisplayName', 'insignificant');
% 	scatter(Left_mean_firing_rate(sig_idx), Right_mean_firing_rate(sig_idx),'filled','DisplayName', 'significant');
% 	y_limits = get(gca(), 'YLim');
% 	plot(y_limits, y_limits, 'Color', [0 0 0], 'DisplayName', 'y=x' );
% 	legend('insignificant','significant','y=x','Location','northwest')
% 	drawnow
% 	hold off
% 	title({['Alignment: ', cur_alignment]}, 'Interpreter', 'None');
% 	subtitle({['Summary of mean firing rates: ', num2str(length(sig_idx)), ' significant points ', num2str(length(insig_idx)),' non-significant points']}, 'Interpreter', 'None');
% 	xlabel('Left mean firing rates [Hz]');
% 	ylabel('Right mean firing rates [Hz]');
% plot_list = {'LR', 'DiffGo', 'LR&DiffGo'};
% % for ANOVA
% 	for i_plot = 1:length(p)
% 		subplot(1,3,i_plot)
% 		cur_insig_idx = insig_idx(i_plot,:);
% 		cur_sig_idx = sig_idx(i_plot,:);
% 		hold on
% 		histogram(eta_squared(i_plot,nonzeros(cur_insig_idx)),'BinWidth', 0.05);
% 		histogram(eta_squared(i_plot, nonzeros(cur_sig_idx)),'BinWidth', 0.05);
% 		title({cell2mat(plot_list(i_plot))}, 'FontSize',10, 'Interpreter', 'None');
% 		xlabel('Effect Size (eta squared)');
% 		ylabel('Counts');
% 		sgtitle({['Alignment: ', cur_alignment, ' Two-way anova of LR%DiffGo']}, 'Interpreter', 'None');
% 		if i_plot == 1
% 			legend('insignificant','significant');
% 		end
% 			hold off
% 	end
% 	
% 	for summary table of anovan
	col = {'LR','DiffGo','LR&DiffGo','Counts','Percentage'};
	row = {'No significant','LR only','DiffGo only','LR&DiffGo only','LR and DiffGo','LR and LR&DiffGo','DiffGo and LR&DiffGo','All significant','Counts','Percentage'};
	sig_combo = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 1 1];
	combo_len = length(sig_combo);
	factor_percentage=[];
	for i_factor_proportion = 1: length(p)
		factor_percentage(end+1) = length(nonzeros(sig_idx(i_factor_proportion, :)))/n_units;
	end
	sig_label = (sig_idx)./(sig_idx);
	sig_label(isnan(sig_label)) = 0;
	sig_count_list=[];
	for i_combo_proportion = 1:length(sig_combo)
		cur_combo = sig_combo(i_combo_proportion, :)';
		cur_count = 0;
		for i = 1: length(sig_idx(1,:))
			if cur_combo == sig_label(:,i)
				cur_count = cur_count + 1;
			end
		end
		sig_count_list(end+1)=cur_count;
	end
	sig_combo(combo_len+2,:)=factor_percentage;
	sig_combo(combo_len+1,:)=factor_percentage*n_units;
	add_sig_combo = sig_combo';
	sig_count_list(end+1)= n_units;
	sig_count_list(end+1)= n_units;
	sig_count_list(1)= n_units - length(sig_idx(1,:));
	add_sig_combo(length(p)+1,:)=sig_count_list;
	add_sig_combo(length(p)+2,:)=sig_count_list/n_units;
	table_data = add_sig_combo';
	table_data(10,4)=NaN;
	table_data(9,5)=NaN;
	fh =figure;
	sig_table = uitable(fh, 'columnname',col, 'rowname', row, 'ColumnWidth',{'1x','1x','1x','2x','2x'},'data', table_data);
	sig_table.Position = [20 20 800 400];
	
% 	write_out_figure(fh_population, fullfile(output_directory, ['Summary', '.',  set.value, '.', cur_alignment, '.', '.pdf']));
	write_out_figure(fh, fullfile(output_directory,['Percentage of significant units', '.',  set.value, '.', cur_alignment, '.', '.pdf']));
end


% fh_list(i_alignment) = fh_population;
% 	close(fh);


% aggregation function: averaging



% for i_fh = 1 : length(fh_list)
% 	cur_fh = fh_list(i_fh);
% 	close(cur_fh);
% end
end

