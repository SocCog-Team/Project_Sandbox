function [] = dyadic_fn_charactreize_single_unit(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID)
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
set.value ='Dyadic';
% time windows, range relative to alignment
window.range = [-500 500];

gaussian_filter_width = 150;
DiffGo_factor_name = {'A_IFTrel_minus_Bgo_list','B_IFTrel_minus_Ago_list'};


for i_align = 1 : length(alignment_event_list)
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
eta_squared = [];
for i = 1:length(p)
	eta_squared(end+1)= cell2mat(tbl(1+i,5))/(cell2mat(tbl(1+i,5))+cell2mat(tbl(5,5)));
end



% plot the graph and calculat the effect size

fh = figure('Name', [cur_alignment, ': ', factor_name], 'Visible', figure_visibility_string, 'Position',[1 1 600 800]);
cur_x_vec = cur_data_struct.raster_site_info.event_aligned_bincenter_ts_list;
unique_alignment_factors = unique(alignment_list);
unique_LR_factors = unique(LR_factor_list);
unique_DiffGo_factors = unique(DiffGo_factor_list);
factor_color = lines(length(unique_LR_factors));
legend_list = {};
t = tiledlayout(4,2,'TileSpacing','Compact','Padding','Compact');

for i_DiffGo_factor = 1:length(unique_DiffGo_factors)
	cur_DiffGo_instance = unique_DiffGo_factors{i_DiffGo_factor};
	DiffGo_idx = find(strcmp(DiffGo_factor_list, cur_DiffGo_instance));
	for i_align_factor = 1:length(unique_alignment_factors)
		cur_align_instance = unique_alignment_factors{i_align_factor};
		align_idx =  intersect(find(strcmp(alignment_list, cur_align_instance)), DiffGo_idx);
		nexttile
		for i_LR_factor = 1:length(unique_LR_factors)
			hold on
			cur_LR_instance = unique_LR_factors(i_LR_factor);
			legend_list(end+1) = {[cur_LR_instance]};
			cur_trial_idx = intersect(find(strcmp(LR_factor_list, cur_LR_instance)), align_idx);
			cur_data_Hz = mean(cur_data_struct.raster_data(cur_trial_idx, :), 1, 'omitnan') * (1000 / cur_data_struct.raster_site_info.bin_width_ms);
			cur_smooth_data_Hz = smoothdata(cur_data_Hz, 'gaussian', gaussian_filter_width);
			plot(cur_x_vec, cur_smooth_data_Hz, 'Color', factor_color(i_LR_factor, :), 'LineWidth',2.5);
			unit_name_channel = unit_name{5};
			unit_name_cluster = unit_name{6};
		end
		y_limits = get(gca(), 'YLim');
		% show alinment as vertiacl line
		plot([0 0], y_limits, 'Color', [0 0 0]);
		
		% show the statistics analysis window
		%plot(window.range, [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 2.0);
		patch([window.range(1), window.range(2), window.range(2), window.range(1)], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1);
		
		hold off
		if  (i_DiffGo_factor == 1) && (i_align_factor == 1)
		legend([legend_list{1},legend_list{2}],'AutoUpdate','off','Location','northwestoutside');
		
		end
		if i_align_factor == 1
			title({['Align: ', cur_align_instance]}, 'Interpreter', 'None', 'FontSize',11);
		else
			title({['Align: ', cur_align_instance, ' DiffGo: ',cur_DiffGo_instance]}, 'Interpreter', 'None', 'FontSize',11);
		end 
		
	end
% 	subtitle({['p = [', num2str(p(1), '%.3f'),' ',num2str(p(2), '%.3f'),' ',num2str(p(3), '%.3f'), ...
% 		']'],[' eta_squared = [', num2str(eta_squared(1), '%.3f'), ' ',num2str(eta_squared(2), '%.3f'),' ',num2str(eta_squared(3), '%.3f'),']']}, 'Interpreter', 'None');
	ylabel(t,'Firing rate [Hz]');
	xlabel(t,{['Time relative to alignment event [ms]'],...
		['p = [', num2str(p(1), '%.3f'),' ',num2str(p(2), '%.3f'),' ',num2str(p(3), '%.3f'),' ',num2str(p(4), '%.3f'),' ',num2str(p(5), '%.3f'),' ',num2str(p(6), '%.3f'),']'],...
		[' eta_squared = [', num2str(eta_squared(1), '%.3f'), ' ',num2str(eta_squared(2), '%.3f'),' ',num2str(eta_squared(3), '%.3f'),' ',num2str(eta_squared(4), '%.3f'),' ',num2str(eta_squared(5), '%.3f'),' ',num2str(eta_squared(6), '%.3f'),']']}, 'Interpreter', 'None');
	sgtitle({'Three-way ANOVA: alignment,LR,DiffGo,alignment&LR,alignment&DiffGo,LR&DiffGo'})
end

write_out_figure(fh, fullfile(output_directory, [session_ID, '.', unit_name_channel, '.', unit_name_cluster, '.',  set.value, '.alignment_LR_DiffGo', '.pdf']));













% for i_fh = 1 : length(fh_list)
% 	cur_fh = fh_list(i_fh);
% 	close(cur_fh);
% end
end

