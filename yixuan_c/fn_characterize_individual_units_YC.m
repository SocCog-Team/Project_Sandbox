function [] = fn_characterize_individual_units_YC(session_FQNion_ID)
%FN_CHARACTERIZE_INDIVIDUAL_UNITS_YC Summary of this function goes here
%   Detailed explanation goes here


% A_TargetOnsetTime_ms


timestamps.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);

% override_directive = 'local_code'; %this allows to override automatically using the network, requires host specific changes to GetDirectoriesByHostName
% SCPDirs = GetDirectoriesByHostName(override_directive);
% AddToMatlabPath( pwd, [], [] );


% AddToMatlabPath( fullfile('C:', 'SCP_CODE', 'measures-of-effect-size-toolbox'), [], [] );


% definitons

loop_over_units = 0;
array = 0;


% input session directory
if ~exist('session_FQN', 'var') || isempty(session_FQN)
	% session with shuffled and blocked  partner,and SoloA
	session_FQN = fullfile('F:', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2021', '210219', '20210219T145809.A_Elmo.B_DL.SCP_01.sessiondir');
end

[session_dir, session_ID, session_ext] = fileparts(session_FQN);



% PETHdata path
PETHdata_base_dir = fullfile(session_FQN, 'TDT', 'PETHdata');
raster_dir_relative_to_alignment = fullfile('raster_format', 'ALL_LABELS');
% output_directory = fullfile(session_FQN, 'TDT', 'PerUnitAnalysis','SoloA_Dyadic_comparison','Dyadic_TrialSubtype&LR_separated_by_DiffGo');
output_directory = fullfile(session_FQN, 'TDT', 'PerUnitAnalysis', 'LR_analysis');
output_directory = fullfile(session_FQN, 'TDT', 'PerUnitAnalysis', 'Dyadic2');

if ~isempty(output_directory)
	mkdir(output_directory);
end

PETHdata_dir_struct = dir(PETHdata_base_dir);
existing_alignment_event_list = {};
for i_dir = 1 : length(PETHdata_dir_struct)
	if (PETHdata_dir_struct(i_dir).isdir)
		switch PETHdata_dir_struct(i_dir).name
			case {'.', '..'}
				continue
			otherwise
				existing_alignment_event_list(end+1) = {PETHdata_dir_struct(i_dir).name};
		end
	end
end

% list of alignments
alignment_event_list = {'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms'};
% baseline_alignment = { 'A_TargetOnsetTime_ms'};
baseline_alignment = {'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms'};
initial_alignment_event = alignment_event_list{1};
n_alignment_events = length(alignment_event_list);


% autodetct all units
proto_unit_list = dir(fullfile(PETHdata_base_dir, initial_alignment_event, raster_dir_relative_to_alignment, [session_ID, '*', initial_alignment_event, '*', '.raster.mat']));
n_units = length(proto_unit_list);

% % 1. loop over units
population_sum = [];
population_label = {};
baseline_sum = [];
unit_label = {};
if (loop_over_units)
	for i_unit = 1 : n_units
		proto_unit_name = proto_unit_list(i_unit).name;
		unit_name = regexp(proto_unit_name, '\.', 'split'); % 	get channel and cluster names
		
		unique_label_instances_name = regexprep(proto_unit_name, '.raster.mat', '.unique_label_instances.mat');
		% load unique_label_instances_struct
		load(fullfile(PETHdata_base_dir, initial_alignment_event, 'raster_format', unique_label_instances_name));
		
		
		% 2. loop over alignment events
		for i_alignment = 1 : length(alignment_event_list)
			cur_alignment_event = alignment_event_list{i_alignment};
			cur_unit_name = regexprep(proto_unit_name, initial_alignment_event, cur_alignment_event);
			cur_unit_baseline_name = regexprep(proto_unit_name, initial_alignment_event, baseline_alignment);
			cur_unit_dir = fullfile(PETHdata_base_dir, cur_alignment_event, raster_dir_relative_to_alignment);
			disp(['Loading unit: ', cur_unit_name]);
			% 		cur_unit_raster_data = load(fullfile(cur_unit_dir, cur_unit_name));
			unit_raster_by_alignment_event.(cur_alignment_event) = load(fullfile(cur_unit_dir, cur_unit_name));
			unit_raster_by_alignment_event.(cur_alignment_event).unique_label_instances_struct = unique_label_instances_struct;
		end % i_alignment
% 		cur_unit_baseline_dir =  fullfile(PETHdata_base_dir, baseline_alignment{1}, raster_dir_relative_to_alignment);
% 		unit_raster_by_alignment_event.(baseline_alignment{1}) = load(fullfile(cur_unit_baseline_dir, cur_unit_baseline_name));
		
		
% 						fn_charactreize_single_unit_ANOVAN(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID);
		% 						fn_charactreize_single_unit_ANOVA(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID);
		%
		% 	Solo LR analysis: draw the graph of firing rate against tiem for each cluster
		
		[adjusted_window_range, unit_label, population_label, baseline_sum, population_sum, cur_x_vec, unique_factors] = fn_charactreize_single_unit(unit_label, population_label, baseline_sum, baseline_alignment, unit_raster_by_alignment_event, alignment_event_list,  unit_name, output_directory, session_ID, population_sum);
		
		% 		Diadic analysis
		% 				dyadic_fn_charactreize_single_unit(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID);
		
	end %i_unit
	population_label = population_label';
	unit_label = unit_label';
	% eliminate the units with low firing rate
	population_mean = sum(population_sum(:, adjusted_window_range(1):adjusted_window_range(2)), 2) / 1001;
	goodunit_idx = find(population_mean>1);
	population_label = population_label(goodunit_idx);
	baseline_sum = baseline_sum(goodunit_idx);
	population_sum = population_sum(goodunit_idx,:);
	unit_label = unit_label(goodunit_idx);
	
	for i_unit_label = 1: length(unit_label)
		cur_label = unit_label{i_unit_label};
		cur_channel = str2num(cur_label(end-2:end));
		if cur_channel < 33
			unit_label{i_unit_label} = 'array 1';
		elseif (32<cur_channel) && (cur_channel<65)
			unit_label{i_unit_label} = 'array 2';
		elseif (64<cur_channel) && (cur_channel<97)
			unit_label{i_unit_label} = 'array 3';
		elseif (96<cur_channel) && (cur_channel<129)
			unit_label{i_unit_label} = 'array 4';
		elseif (128<cur_channel) && (cur_channel<161)
			unit_label{i_unit_label} = 'array 5';
		end
	end
	unique_population_label = unique(population_label);
	unique_unit_label = unique(unit_label);
	pattern_list = {'Increased_activity','Decreased_activity'};
	pattern_label = (sum(population_sum(:, adjusted_window_range(1):adjusted_window_range(2)), 2))/1001 - baseline_sum;
	pattern_label(find(pattern_label > 0)) = 1;
	pattern_label(find(pattern_label < 0)) = 2;
	unique_pattern_label = unique(pattern_label);
	
	
	
	% 		plot the graph
	if (array)
		gaussian_filter_width = 150;
		window.range = [-500 500];
		array_list = {'array 1', 'array 2', 'array 3', 'array 4', 'array 5', 'total'};
		for i_alignment = 1: length(alignment_event_list)
			cur_alignment = alignment_event_list{i_alignment};
			cur_unique_population_label = unique_population_label((i_alignment*2-1): 2*i_alignment);
			for i_pattern = 1:length(pattern_list)
				cur_pattern = unique_pattern_label(i_pattern);
				cur_pattern_idx = find(pattern_label == cur_pattern);
				% plot the graph for particular pattern & alignment
				fh = figure('Name', [cur_alignment, '_Array_analysis', cur_pattern]);
				t = tiledlayout(2, 3,'TileSpacing','Compact','Padding','Compact');
				for i_population_plot=1: length(array_list)
					cur_array = array_list{i_population_plot};
					cur_array_idx = find(strcmp(unit_label, cur_array));
					
					nexttile
					factor_color = lines(length(unique_factors));
					if i_population_plot <6
						hold on
						data_ttest =[];
						for i_factor_instance = 1 : length(unique_factors)
							cur_factor_instance = cur_unique_population_label{i_factor_instance};
							cur_factor_idx = find(strcmp(population_label, cur_factor_instance));
							cur_goodtrial_idx = intersect(intersect(cur_array_idx, cur_pattern_idx), cur_factor_idx);
							cur_data = population_sum(cur_goodtrial_idx, :);
							cur_baseline = mean(baseline_sum(cur_array_idx, :));
							data_ttest(end+1) = length(cur_goodtrial_idx);
							normalised_data = (cur_data - cur_baseline)/std(baseline_sum(cur_array_idx));
							cur_data_Hz = mean(normalised_data, 1, 'omitnan');
							
							std_cur_data = std(normalised_data, 1);
							
							CI_alpha = 0.05;
							CI_hw = calc_cihw(std_cur_data, size(cur_data, 1), CI_alpha);
							
							smooth_upper = smoothdata((CI_hw + cur_data_Hz), 'gaussian', gaussian_filter_width);
% 							smooth_upper = CI_hw + cur_data_Hz;
							smooth_lower = smoothdata((cur_data_Hz - CI_hw), 'gaussian', gaussian_filter_width);
% 							smooth_lower = cur_data_Hz - CI_hw;
							cur_smooth_data_Hz = smoothdata(cur_data_Hz, 'gaussian', gaussian_filter_width);
							inBetween = [smooth_upper, fliplr(smooth_lower)];
							cur_x_vec_flip = [cur_x_vec, fliplr(cur_x_vec)];
							fill(cur_x_vec_flip, inBetween, factor_color(i_factor_instance, :),'FaceAlpha',0.3);
							plot(cur_x_vec, cur_smooth_data_Hz, 'Color', factor_color(i_factor_instance, :), 'LineWidth',2.5);
						end
						y_limits = get(gca(), 'YLim');
						% show alinment as vertiacl line
						plot([0 0], y_limits, 'Color', [0 0 0]);
						patch([window.range(1), window.range(2), window.range(2), window.range(1)], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1);
						hold off
						title({[array_list{i_population_plot}, ' N = [', num2str(data_ttest(1)), ' ',num2str(data_ttest(2)), ']']}, 'Interpreter', 'None');
% 						ylabel('Normalised firing rate ');
					else
						hold on
						factor_color = lines(length(unique_factors));
						legend_list = {};
						data_ttest = [];
						for i_factor_instance = 1 : length(unique_factors)
							cur_factor_instance = cur_unique_population_label{i_factor_instance};
							legend_list(end+1) = {unique_factors{i_factor_instance}};
							cur_factor_idx = find(strcmp(population_label, cur_factor_instance));
							cur_goodtrial_idx = intersect(cur_factor_idx, cur_pattern_idx);
							cur_data = population_sum(cur_goodtrial_idx, :);
							cur_baseline = mean(baseline_sum(:));
							normalised_data = (cur_data - cur_baseline)/std(baseline_sum(:));
							cur_data_Hz = mean(normalised_data, 1, 'omitnan');
							data_ttest(end+1) = length(cur_goodtrial_idx);
							
							std_cur_data = std(normalised_data, 1);
							
							CI_alpha = 0.05;
							CI_hw = calc_cihw(std_cur_data, size(cur_data, 1), CI_alpha);
							
							smooth_upper = smoothdata((CI_hw + cur_data_Hz), 'gaussian', gaussian_filter_width);
% 							smooth_upper = CI_hw + cur_data_Hz;
							smooth_lower = smoothdata((cur_data_Hz - CI_hw), 'gaussian', gaussian_filter_width);
% 							smooth_lower = cur_data_Hz - CI_hw;
							cur_smooth_data_Hz = smoothdata(cur_data_Hz, 'gaussian', gaussian_filter_width);
							inBetween = [smooth_upper, fliplr(smooth_lower)];
							cur_x_vec_flip = [cur_x_vec, fliplr(cur_x_vec)];
							fill(cur_x_vec_flip, inBetween, factor_color(i_factor_instance, :),'FaceAlpha',0.3);
							if i_factor_instance == 1							
								p1 = plot(cur_x_vec, cur_smooth_data_Hz, 'Color', factor_color(i_factor_instance, :), 'LineWidth',2.5);
							else
								p2 = plot(cur_x_vec, cur_smooth_data_Hz, 'Color', factor_color(i_factor_instance, :), 'LineWidth',2.5);
							end
						end
						legend([p1 p2] ,legend_list, 'AutoUpdate', 'off', 'Location','eastoutside');
						y_limits = get(gca(), 'YLim');
						% show alinment as vertiacl line
						plot([0 0], y_limits, 'Color', [0 0 0]);
						patch([window.range(1), window.range(2), window.range(2), window.range(1)], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1);
						hold off
						
						title({[array_list{i_population_plot}, ' N = [', num2str(data_ttest(1)), ' ',num2str(data_ttest(2)), ']']}, 'Interpreter', 'None');
						xlabel(t, 'Time relative to alignment event [ms]');
						ylabel(t, 'Normalised firing rate (t-score)');
					end
					sgtitle({['Alignment: ', cur_alignment, ' Pattern: ', pattern_list{i_pattern}]}, 'Interpreter', 'None');
				end
				write_out_figure(fh, fullfile(output_directory, ['Array analysis of LR firing rate_SoloA_', cur_alignment,'.', pattern_list{i_pattern},  '.pdf']));

			end
		end
	end
end

% 	draw the population plot of mean frequency of left against right: to
% 	run this comment the 60-88 line for easier computation

fn_characterize_individual_units_population_dyadic(raster_dir_relative_to_alignment, initial_alignment_event, PETHdata_base_dir, proto_unit_list, n_units, alignment_event_list, output_directory, session_ID);


fn_characterize_individual_units_population(raster_dir_relative_to_alignment, initial_alignment_event, PETHdata_base_dir, proto_unit_list, n_units, alignment_event_list, output_directory, session_ID);




% extract windows

% ANOVA!

% plot

%plot measure over all units



% clean up
timestamps.(mfilename).end = toc(timestamps.(mfilename).start);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end), ' seconds.']);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / 60), ' minutes. Done...']);


end

