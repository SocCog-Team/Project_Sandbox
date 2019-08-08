function [ output_args ] = set_current_directory_tree_to_matlab_path( input_args )
%START_SESSIONBROWSER Summary of this function goes here
%   silly little wrapper to get the current path into the matlab path

start_dir = fileparts(mfilename('fullpath'));
cd(start_dir);

calling_dir = pwd;
path_string = path;


current_path_defined = strfind(path_string, [calling_dir, pathsep]);

% delete existing paths containing the calling directory
% this is a work around for matlab's inability to detect changed files on
% most network shares
if ~isempty(current_path_defined)
	% turn the path into cell array
	while length(path_string) > 0
		[cur_path_item, remain] = strtok(path_string, ';:');
		path_string = remain(2:end);
		if ~isempty(strfind(cur_path_item, calling_dir))
			rmpath(cur_path_item);
		end
	end
end
% now add them again
addpath(genpath(pwd()));

% start the session browser
%open('fnAnalyzePerformancePerTrialType_4paper2013.m');
%open('fnAnalyzePerformancePerTrialType_4paper2013_training.m');

return