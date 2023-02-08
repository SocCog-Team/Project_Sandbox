function [] = fn_characterize_individual_units_YC(session_FQNion_ID)
%FN_CHARACTERIZE_INDIVIDUAL_UNITS_YC Summary of this function goes here
%   Detailed explanation goes here

timestamps.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);

% override_directive = 'local_code'; %this allows to override automatically using the network, requires host specific changes to GetDirectoriesByHostName
% SCPDirs = GetDirectoriesByHostName(override_directive);
% AddToMatlabPath( pwd, [], [] );



% definitons

loop_over_units = 1;


% input session directory
if ~exist('session_FQN', 'var') || isempty(session_FQN)
	% session with shuffled and blocked  partner,and SoloA
	session_FQN = fullfile('F:', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2021', '210219', '20210219T145809.A_Elmo.B_DL.SCP_01.sessiondir');
end

[session_dir, session_ID, session_ext] = fileparts(session_FQN);



% PETHdata path
PETHdata_base_dir = fullfile(session_FQN, 'TDT', 'PETHdata');
raster_dir_relative_to_alignment = fullfile('raster_format', 'ALL_LABELS');
output_directory = fullfile(session_FQN, 'TDT', 'PerUnitAnalysis', 'Dyadic');
% output_directory = fullfile(session_FQN, 'TDT', 'PerUnitAnalysis', 'testing');

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
initial_alignment_event = alignment_event_list{1};
n_alignment_events = length(alignment_event_list);


% autodetct all units
proto_unit_list = dir(fullfile(PETHdata_base_dir, initial_alignment_event, raster_dir_relative_to_alignment, [session_ID, '*', initial_alignment_event, '*', '.raster.mat']));
n_units = length(proto_unit_list);

% % 1. loop over units
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
			cur_unit_dir = fullfile(PETHdata_base_dir, cur_alignment_event, raster_dir_relative_to_alignment);
			disp(['Loading unit: ', cur_unit_name]);
			% 		cur_unit_raster_data = load(fullfile(cur_unit_dir, cur_unit_name));
			unit_raster_by_alignment_event.(cur_alignment_event) = load(fullfile(cur_unit_dir, cur_unit_name));
			unit_raster_by_alignment_event.(cur_alignment_event).unique_label_instances_struct = unique_label_instances_struct;
		end % i_alignment
		
		
% 		fn_charactreize_single_unit_ANOVAN(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID);
% 				fn_charactreize_single_unit_ANOVA(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID);
		%
		% 	Solo LR analysis: draw the graph of firing rate against tiem for each cluster
		
% 				fn_charactreize_single_unit(unit_raster_by_alignment_event, alignment_event_list,  unit_name, output_directory, session_ID);

% 		Diadic analysis 
		dyadic_fn_charactreize_single_unit(unit_raster_by_alignment_event, alignment_event_list, unit_name, output_directory, session_ID);
		
	end %i_unit
end

% 	draw the population plot of mean frequency of left against right: to
% 	run this comment the 60-88 line for easier computation

% fn_characterize_individual_units_population(raster_dir_relative_to_alignment, initial_alignment_event, PETHdata_base_dir, proto_unit_list, n_units, alignment_event_list, output_directory, session_ID);


% extract windows

% ANOVA!

% plot

%plot measure over all units



% clean up
timestamps.(mfilename).end = toc(timestamps.(mfilename).start);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end), ' seconds.']);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / 60), ' minutes. Done...']);


end

