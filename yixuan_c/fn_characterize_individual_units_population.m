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
% set.value = {'Dyadic','SoloA'};
% time windows, range relative to alignment
window.range = [-500 500];

gaussian_filter_width = 50;
dyadic_analysis = 0;

if (dyadic_analysis)
	DiffGo_factor_name = {'A_IFTrel_minus_Bgo_list','B_IFTrel_minus_Ago_list'};
	sig_idx =[];
	insig_idx = [];
	eta_squared = [];
	i_coloumn = 0;
	for i_unit = 1 : n_units
		proto_unit_name = proto_unit_list(i_unit).name;
		unique_label_instances_name = regexprep(proto_unit_name, '.raster.mat', '.unique_label_instances.mat');
		load(fullfile(PETHdata_base_dir, initial_alignment_event, 'raster_format', unique_label_instances_name));
		
		
		for i_align = 1 : length(alignment_event_list)
			cur_alignment_event = alignment_event_list{i_align};
			cur_unit_name = regexprep(proto_unit_name, initial_alignment_event, cur_alignment_event);
			cur_unit_dir = fullfile(PETHdata_base_dir, cur_alignment_event, raster_dir_relative_to_alignment);
			disp(['Loading unit: ', cur_unit_name]);
			% 		cur_unit_raster_data = load(fullfile(cur_unit_dir, cur_unit_name));
			unit_raster_by_alignment_event.(cur_alignment_event) = load(fullfile(cur_unit_dir, cur_unit_name));
			unit_raster_by_alignment_event.(cur_alignment_event).unique_label_instances_struct = unique_label_instances_struct;
			reference_alignment_data = unit_raster_by_alignment_event.(alignment_event_list{i_align});
			
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
			if i_align == 1
				self_DiffGo_factor_name = DiffGo_factor_name{1};
				self_DiffGo_trial_unique_instances = reference_alignment_data.unique_label_instances_struct.(self_DiffGo_factor_name);
				self_DiffGo_trial_unique_instances = ['NONE'; self_DiffGo_trial_unique_instances];
				self_DiffGo_idx = reference_alignment_data.raster_labels.(self_DiffGo_factor_name) + 1;
				self_DiffGo_list = self_DiffGo_trial_unique_instances(self_DiffGo_idx);
				self_existing_factor_idx = find(~strcmp(self_DiffGo_list, 'NONE'));
				% 		long_DiffGo_idx =  find(~strcmp(DiffGo_list, 'ABgo'));
				% 		self_goodtrial_idx = intersect(intersect(intersect(rewarded_trial_idx, existing_factor_idx),  trials_in_set_idx), long_DiffGo_idx);
				self_goodtrial_idx = intersect(intersect(rewarded_trial_idx, self_existing_factor_idx),  trials_in_set_idx);
				cur_alignment = alignment_event_list{i_align};
				cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
				adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
				self_firing_rate_Hz = sum(cur_data_struct.raster_data(self_goodtrial_idx, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
				self_motion_alignment = cell(length(self_firing_rate_Hz),1);
				self_motion_alignment(:)={'A_IFR'};
			else
				partner_DiffGo_factor_name = DiffGo_factor_name{2};
				partner_DiffGo_trial_unique_instances = reference_alignment_data.unique_label_instances_struct.(partner_DiffGo_factor_name);
				partner_DiffGo_trial_unique_instances = ['NONE'; partner_DiffGo_trial_unique_instances];
				partner_DiffGo_idx = reference_alignment_data.raster_labels.(partner_DiffGo_factor_name) + 1;
				partner_DiffGo_list = partner_DiffGo_trial_unique_instances(partner_DiffGo_idx);
				partner_existing_factor_idx = find(~strcmp(partner_DiffGo_list, 'NONE'));
				% 		long_DiffGo_idx =  find(~strcmp(DiffGo_list, 'ABgo'));
				% 		partner_goodtrial_idx = intersect(intersect(intersect(rewarded_trial_idx, existing_factor_idx),  trials_in_set_idx), long_DiffGo_idx);
				partner_goodtrial_idx = intersect(intersect(rewarded_trial_idx, partner_existing_factor_idx),  trials_in_set_idx);
				cur_alignment = alignment_event_list{i_align};
				cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
				adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
				partner_firing_rate_Hz = sum(cur_data_struct.raster_data(partner_goodtrial_idx, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
				partner_motion_alignment = cell(length(partner_firing_rate_Hz),1);
				partner_motion_alignment(:,1)={'B_IFR'};
			end
		end
		two_factor_name = 'TrialSubType_ByDiffGo_list';
		two_factor_uniqe_instances = [{'NONE'};reference_alignment_data.unique_label_instances_struct.(two_factor_name)];
		two_factor_idx = reference_alignment_data.raster_labels.(two_factor_name) + 1;
		two_factor_list = two_factor_uniqe_instances(two_factor_idx);
		
		
		% 	concat trials based on alignment, LR and DiffGo
		firing_rate_Hz = cat(1,self_firing_rate_Hz, partner_firing_rate_Hz);
		alignment_list = cat(1, self_motion_alignment, partner_motion_alignment);
		LR_factor_list = cat(1,factor_list(self_goodtrial_idx), factor_list(partner_goodtrial_idx));
		DiffGo_factor_list = cat(1, two_factor_list(self_goodtrial_idx), two_factor_list(partner_goodtrial_idx));
		
		
		[p, tbl, stats, terms] = anovan(firing_rate_Hz, {alignment_list, LR_factor_list, DiffGo_factor_list},'model',2,'varnames',{'alignment','LR','DiffGo'},'display','off');
		cur_eta_squared = [];
		for i = 1:length(p)
			cur_eta_squared(end+1)= cell2mat(tbl(1+i,5))/(cell2mat(tbl(1+i,5))+cell2mat(tbl(7,5)));
		end
		cur_eta_squared =cur_eta_squared';
		eta_squared(:, end+1)=cur_eta_squared;
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
	fh_population = figure('Name', [cur_alignment, ': ', 'A_LR_mean_firing_rates'], 'Visible', figure_visibility_string, 'Position',[1 1 800 600]);
	plot_list = {'alignment','LR', 'DiffGo', 'alignment&LR','alignment&DiffGo','LR&DiffGo'};
	% for histogram of dyadic trials
	
	for i_plot = 1:length(p)
		subplot(2,3,i_plot)
		cur_insig_idx = insig_idx(i_plot,:);
		cur_sig_idx = sig_idx(i_plot,:);
		hold on
		histogram(eta_squared(i_plot,nonzeros(cur_insig_idx)),'BinWidth', 0.05);
		histogram(eta_squared(i_plot, nonzeros(cur_sig_idx)),'BinWidth', 0.05);
		title({cell2mat(plot_list(i_plot))}, 'FontSize',10, 'Interpreter', 'None');
		xlabel('Eta squared');
		ylabel('Counts');
		sgtitle({[ ' Three-way anova of alignment&LR&DiffGo']}, 'Interpreter', 'None');
		if i_plot == 1
			legend('insignificant','significant');
		end
		hold off
	end
	
	write_out_figure(fh_population, fullfile(output_directory, ['Summary of three-way anova', '.',  set.value, '.', '.pdf']));
	
end



if dyadic_analysis ~= 1
	for i_alignment = 1 : length(alignment_event_list)
		
		Left_mean_firing_rate = [];
		Right_mean_firing_rate = [];
		sig_idx =[];
		insig_idx = [];
		eta_squared = [];
		
		
		% 		for i_factor = 1: 2 % 2 as length(factor_unique_instances)
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
			% 			Dyadic_idx = reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value{1});
			% 			SoloA_idx = reference_alignment_data.raster_site_info.TrialSets.(set.type).(set.value{2});
			% 			trials_in_set_idx = cat(1,  Dyadic_idx, SoloA_idx);
			rewarded_trial_idx = reference_alignment_data.raster_site_info.TrialSets.ByOutcome.REWARD;
			% 			DiffGo_factor_name = {'A_IFTrel_minus_Bgo_list','B_IFTrel_minus_Ago_list'};
			DiffGo_factor_name = {'A_IFTrel_minus_Bgo_list','A_IFTrel_minus_Bgo_list'};
			cur_DiffGo_factor_name = DiffGo_factor_name{i_alignment};
			DiffGo_trial_unique_instances = reference_alignment_data.unique_label_instances_struct.(cur_DiffGo_factor_name);
			DiffGo_trial_unique_instances = ['NONE'; DiffGo_trial_unique_instances];
			DiffGo_idx = reference_alignment_data.raster_labels.(cur_DiffGo_factor_name) + 1;
			DiffGo_list = DiffGo_trial_unique_instances(DiffGo_idx);
			
			% find valid trials in the set
			% which measure to explain with the analysis, here from decoding label
			% lists
			
			
			factor_name = 'A_LR_pos_list';
			B_factor_name = 'B_LR_pos_list';
			factor_idx = reference_alignment_data.raster_labels.(factor_name) + 1;
			factor_uniqe_instances = [{'NONE'}; reference_alignment_data.unique_label_instances_struct.(factor_name)];
			factor_list = factor_uniqe_instances(factor_idx);
			two_factor_name = 'TrialSubType_ByDiffGo_list';
			two_factor_uniqe_instances = [{'NONE'};reference_alignment_data.unique_label_instances_struct.(two_factor_name)];
			two_factor_idx = reference_alignment_data.raster_labels.(two_factor_name) + 1;
			two_factor_list = two_factor_uniqe_instances(two_factor_idx);
			two_factor_list = erase(two_factor_list, "Dyadic_Go: ");
			two_factor_list = erase(two_factor_list, "SoloA_Go: ");
			combined_factor_list = append(factor_list,'_', two_factor_list);
			B_factor_idx = reference_alignment_data.raster_labels.(B_factor_name) + 1;
			B_factor_uniqe_instances = [{'NONE'}; reference_alignment_data.unique_label_instances_struct.(B_factor_name)];
			B_factor_list = B_factor_uniqe_instances(B_factor_idx);
			
			trial_sub_type_unique_idx = reference_alignment_data.raster_site_info.report_struct.data(:, reference_alignment_data.raster_site_info.report_struct.cn.A_TrialSubTypeENUM_idx);
			trialsubtype_list = reference_alignment_data.raster_site_info.report_struct.unique_lists.A_TrialSubTypeENUM(trial_sub_type_unique_idx)';
			
			Left_idx = find(strcmp(factor_list, 'Al'));
			Right_idx = find(strcmp(factor_list, 'Ar'));
			existing_factor_idx = find(~strcmp(DiffGo_list, 'NONE'));
			long_DiffGo_idx =  find(~strcmp(DiffGo_list, 'ABgo'));
			A_faster_B_idx = find(strcmp(two_factor_list, 'A<B'));
			goodtrial_idx = intersect(intersect(intersect(rewarded_trial_idx, existing_factor_idx),  trials_in_set_idx), A_faster_B_idx);
			% 				unique_factor = unique(factor_list(goodtrial_idx));
			% 				cur_factor_idx = find(strcmp(factor_list, unique_factor(i_factor)));
			% 				goodtrial_idx = intersect(goodtrial_idx, cur_factor_idx);
			%
			
			
			cur_alignment = alignment_event_list{i_alignment};
			cur_data_struct = unit_raster_by_alignment_event.(cur_alignment);
			adjusted_window_range = window.range + cur_data_struct.raster_site_info.pre_event_dur_ms;
			
			% 		% 		for ANOVAN
			% 			firing_rate_Hz = sum(cur_data_struct.raster_data(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
			%
			% 			[p, tbl, stats, terms] = anovan(firing_rate_Hz(goodtrial_idx), {factor_list(goodtrial_idx),B_factor_list(goodtrial_idx)},'model',2,'varnames',{'A_LR','B_LR'}, 'display','off');
			% 			unique_two_factor = unique(two_factor_list);
			% 			for i_two_factor = 1: length(unique(two_factor_list))
			% 				cur_idx = find(strcmp(two_factor_list, unique_two_factor(i_two_factor)));
			% 				two_factor_idx(cur_idx) = i_two_factor;
			% 			end
			% 			cur_group_idx = [factor_idx(goodtrial_idx) B_factor_idx(goodtrial_idx)];
			% 			[uGroup, aIx, bIx] = unique(cur_group_idx, 'rows');
			% 			[sorted_bIx, sort_idx] = sort(bIx);
			%
			% 			if isnan(p) == 0
			% 				temp = mes2way(firing_rate_Hz(goodtrial_idx(sort_idx)), cur_group_idx(sort_idx, :), {'partialeta2'});
			% 				cur_eta_squared = [];
			% 				for i = 1:length(p)
			% 					cur_eta_squared(end+1)= temp.partialeta2(i);
			% 				end
			% 			else
			% 				cur_eta_squared = [];
			% 				for i = 1:length(p)
			% 					cur_eta_squared(end+1)= nan;
			% 				end
			% 			end
			%
			% 			cur_eta_squared =cur_eta_squared';
			% 			eta_squared(:, end+1)=cur_eta_squared;
			
			% 		for ANOVA
			% 		firing_rate_Hz = sum(cur_data_struct.raster_data((goodtrial_idx), adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
			% 		[p, tbl, stats] = anova1(firing_rate_Hz, factor_list(goodtrial_idx),'off');
			% 		eta_squared(end+1) = cell2mat(tbl(2,2))/cell2mat(tbl(4,2));
			%
			% 		%		for ttest
			firing_rate_Hz = sum(cur_data_struct.raster_data(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / (diff(window.range)/1000);
			[ aggregate_struct, report_string ] = fn_statistic_test_and_report('Left', firing_rate_Hz(intersect(goodtrial_idx, Left_idx)), 'Right', firing_rate_Hz(intersect(goodtrial_idx, Right_idx)), 'ttest2', []);
			Left_mean_firing_rate(end+1) = [aggregate_struct.Left_mean];
			Right_mean_firing_rate(end+1) = [aggregate_struct.Right_mean];
			if aggregate_struct.p<0.05
				sig_idx(end+1) = i_unit;
			else
				insig_idx(end+1)= i_unit;
			end
			%
			% 		for ANOVA and ANOVAN
			% 			test = p<0.05;
			% 			if test == 0
			% 				i_coloumn = i_coloumn;
			% 			else
			% 				i_coloumn = i_coloumn +1;
			% 			end
			% 			for i_p = 1:length(p)
			% 				if p(i_p)<0.05
			% 					sig_idx(i_p,i_coloumn) = i_unit;
			% 				else
			% 					if i_unit == 1
			% 						i_coloumn = 1;
			% 					end
			% 					insig_idx(i_p, i_coloumn)= i_unit;
			% 				end
			% 			end
		end
		fh_population = figure('Name', [cur_alignment, ': ', 'A_LR_mean_firing_rates'], 'Visible', figure_visibility_string, 'Position', [1 1 800 400]);
		
		% 		calculate if population hasLR bias
		population_mean = (Left_mean_firing_rate + Right_mean_firing_rate)/2;
		goodunit_idx = find(population_mean>1);
		sig_idx = intersect(sig_idx, goodunit_idx);
		insig_idx = intersect(insig_idx, goodunit_idx);
		[h_bias,p_bias,ci_bias,stats_bias] = ttest(Left_mean_firing_rate(sig_idx)-Right_mean_firing_rate(sig_idx));

		
		% 			Venn diagram of	pos and LR: those tuned to LR also significant in
		% 			pos analysis: pos_sig_idx need to be changed in line 115 and 117
% 		pos_LR = intersect(pos_sig_idx, sig_idx);
		
		% 	% 	% 		plot the scatter plot
		
		hold on
		scatter(Left_mean_firing_rate(insig_idx), Right_mean_firing_rate(insig_idx),'filled','DisplayName', 'insignificant');
		scatter(Left_mean_firing_rate(sig_idx), Right_mean_firing_rate(sig_idx),'filled','DisplayName', 'significant');
		y_limits = get(gca(), 'YLim');
		plot(y_limits, y_limits, 'Color', [0 0 0], 'DisplayName', 'y=x' );
		legend('insignificant','significant','y=x','Location','northwest')
		drawnow
		hold off
		title({['Alignment: ', cur_alignment]}, 'Interpreter', 'None');
		subtitle({['Summary of mean firing rates: ', num2str(length(sig_idx)), ' significant points ', num2str(length(insig_idx)),' non-significant points'],...
			['LR bias for significant units paired t-test p =', num2str(p_bias,'%.4f')]}, 'Interpreter', 'None');
		xlabel('Left mean firing rates [Hz]');
		ylabel('Right mean firing rates [Hz]');
		write_out_figure(fh_population, fullfile(output_directory, ['Summary of t-test on LR mean firing rate', '.',  set.value , '.', cur_alignment, '.', '.pdf']));

% 		plot_list = {'A_LR', 'B_LR', 'A_LR&B_LR'};
		% for ANOVA
		% 		t = tiledlayout(1,length(plot_list),'TileSpacing','Compact','Padding','Compact');
		% 		for i_plot = 1:length(p)
		% 			nexttile
		% 			cur_insig_idx = insig_idx(i_plot,:);
		% 			cur_sig_idx = sig_idx(i_plot,:);
		% 			hold on
		% 			% 			if i_plot == 1
		% 			% 				histogram(eta_squared(i_plot,nonzeros(cur_insig_idx)),'BinWidth', 0.02);
		% 			% 				histogram(eta_squared(i_plot, nonzeros(cur_sig_idx)),'BinWidth', 0.02);
		% 			% 			elseif i_plot == 2
		% 			% 				histogram(eta_squared(i_plot,nonzeros(cur_insig_idx)),'BinWidth', 0.01);
		% 			% 				histogram(eta_squared(i_plot, nonzeros(cur_sig_idx)),'BinWidth', 0.01);
		% 			% 			else
		% 			histogram(eta_squared(i_plot,nonzeros(cur_insig_idx)),'BinWidth', 0.03);
		% 			histogram(eta_squared(i_plot, nonzeros(cur_sig_idx)),'BinWidth', 0.03);
		% 			% 			end
		% 			title({cell2mat(plot_list(i_plot))}, 'FontSize',10, 'Interpreter', 'None');
		% 			xlabel('partial eta squared');
		% 			ylabel('Counts');
		% 			% 				sgtitle({['Alignment: ', cur_alignment, ' Two-way anova of TrialType%DiffGo in ', factor_uniqe_instances{1+i_factor}]}, 'Interpreter', 'None');
		% 			sgtitle({['Alignment: ', cur_alignment, ' Two-way anova of A_LR&B_LR in A<B']}, 'Interpreter', 'None');
		%
		% 			if i_plot == 1
		% 				legend('insignificant','significant','Location','westoutside');
		% 				legend('boxoff')
		% 			end
		% 			hold off
		% 		end
		%
		% 		% 	for summary table of anovan
		% 		%
		% 		col = ["A_LR","B_LR","A_LR&B_LR","Counts","Fraction"];
		% 		row = {'No significant','A_LR only','B_LR only','interaction only','A_LR and B_LR','A_LR and interaction','B_LR and interaction','All significant','Counts','Fraction'};
		% 		sig_combo = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 1 1];
		% 		combo_len = length(sig_combo);
		% 		factor_percentage=[];
		% 		for i_factor_proportion = 1: length(p)
		% 			factor_percentage(end+1) = length(nonzeros(sig_idx(i_factor_proportion, :)))*100/n_units;
		% 		end
		% 		sig_label = (sig_idx)./(sig_idx);
		% 		sig_label(isnan(sig_label)) = 0;
		% 		sig_count_list=[];
		% 		for i_combo_proportion = 1:length(sig_combo)
		% 			cur_combo = sig_combo(i_combo_proportion, :)';
		% 			cur_count = 0;
		% 			for i = 1: length(sig_idx(1,:))
		% 				if cur_combo == sig_label(:,i)
		% 					cur_count = cur_count + 1;
		% 				end
		% 			end
		% 			sig_count_list(end+1)=cur_count;
		% 		end
		% 		sig_combo(combo_len+2,:)=round(factor_percentage, 1);
		% 		sig_combo(combo_len+1,:)=factor_percentage*n_units/100;
		% 		add_sig_combo = sig_combo';
		% 		sig_count_list(end+1)= n_units;
		% 		sig_count_list(end+1)= n_units;
		% 		sig_count_list(1)= n_units - length(sig_idx(1,:));
		% 		add_sig_combo(length(p)+1,:)=sig_count_list;
		% 		add_sig_combo(length(p)+2,:)=round(sig_count_list*100/n_units, 1);
		% 		table_data = add_sig_combo';
		% 		table_data(10,4)=NaN;
		% 		table_data(9,5)=NaN;
		% 		sig_table = table(table_data(:,1),table_data(:,2),table_data(:,3),table_data(:,4),table_data(:,5), 'VariableNames',col, 'RowNames', row);
		% % 					writetable(sig_table,fullfile(output_directory,['Percentage of significant units', '.',  factor_uniqe_instances{1+i_factor}, '.', cur_alignment, '.', '.csv']),"WriteRowNames",true);
		% 		writetable(sig_table,fullfile(output_directory,['Percentage of significant units of self and others actions in A_faster_B', '.', cur_alignment, '.csv']),"WriteRowNames",true);
		%
		% 		% 			write_out_figure(fh_population, fullfile(output_directory, ['Summary of two way-ANOVA', '.',   factor_uniqe_instances{1+i_factor}, '.', cur_alignment, '.', '.pdf']));
		% 		write_out_figure(fh_population, fullfile(output_directory, ['Summary of two way-ANOVA of self and others actions ', '.',  'A_faster_B', '.', cur_alignment, '.', '.pdf']));
		
		% 		end %factor
	end
end


% fh_list(i_alignment) = fh_population;
% 	close(fh);


% aggregation function: averaging



% for i_fh = 1 : length(fh_list)
% 	cur_fh = fh_list(i_fh);
% 	close(cur_fh);
% end
end

