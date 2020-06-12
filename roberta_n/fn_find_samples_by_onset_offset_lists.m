function [ samples_in_range_ldx ] = fn_find_samples_by_onset_offset_lists( data_list, onset_list, offset_list )
%FN_FIND_SAMPLES_BY_ONSET_OFFSET_LISTS Summary of this function goes here
%   Detailed explanation goes here
samples_in_range_ldx = zeros(size(data_list));

n_ranges = numel(onset_list);

for i_range = 1 : n_ranges
	tmp_idx = find((data_list >= onset_list(i_range)) & (data_list <= offset_list(i_range)));
	if ~isempty(tmp_idx)
		samples_in_range_ldx(tmp_idx) = 1;
	end
end
samples_in_range_ldx = logical(samples_in_range_ldx);
return
end

