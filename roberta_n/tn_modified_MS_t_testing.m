function [ scores ] = tn_modified_MS_t_testing(data_by_trial_group_A, data_by_trial_group_B, data_column_labels)
%MS_T_TESTING Cluster-based corrected permutation t-test 
%   takes 2 vectors of values as a first variable
%   data_column_labels - for getting the vector of frequencies (time-points)
%   PPC_methods - lol, it seems like i am not even using it here

num_perm = 1000;
cr_value = 1.96; %ttest critical value for 0.05 p, sm: why use t instead of the calculated alpha, to preserve the sign?
% cr_value = 2.576;
% sing_lev = 0.05;	% this for the actual permutation test significance
sing_lev = 0.005;	% this for the actual permutation test significance

clear scores

test_type = 'ttest2';% ttest, ttest2

% data_by_trial_group_A = (data(:, 1));
% data_by_trial_group_B = (data(:, 2));

% Calculating p-values of the real data for defining clusters
for fr=1:size(data_column_labels, 2),
	% get the nan_idx
	finite_A_idx = find(~isnan(data_by_trial_group_A(:, fr)));
	finite_B_idx = find(~isnan(data_by_trial_group_B(:, fr)));
	finite_AB_idx = intersect(finite_A_idx, finite_B_idx);
	
	switch test_type
		case 'ttest'
			[h, p, ci, stats] = ttest(data_by_trial_group_A(finite_AB_idx, fr), data_by_trial_group_B(finite_AB_idx, fr)); % h=1 - reject the null hypothesis sm: this is a paired t-test
		case 'ttest2'
			[h, p, ci, stats] = ttest2(data_by_trial_group_A(finite_AB_idx, fr), data_by_trial_group_B(finite_AB_idx, fr)); % h=1 - reject the null hypothesis sm: this is a non-paired t-test		
	end
	scores.data(fr).n = length(finite_AB_idx);
	scores.data(fr).p_val = p;
	scores.data(fr).tstat = stats.tstat;
	% 	if isnan(stats.tstat)
	% 		disp('Doh...');
	% 	end
end    
%plot(data_column_labels.LFP.frequencies, [scores.data.tstat]); 
%hline([1.96, -1.96]) 

% Identifying both positive and negative clusters
% Single values are kept as a cluster as well! (you can always exclude them
% later manually)
pos_tmp_ind = find([scores.data.tstat] > cr_value);
pos_difvec = diff(pos_tmp_ind);
pos_clusters = MS_find_clusters(pos_tmp_ind, pos_difvec);
    
neg_tmp_ind = find([scores.data.tstat] < -cr_value);
neg_difvec = diff(neg_tmp_ind);
neg_clusters = MS_find_clusters(neg_tmp_ind, neg_difvec); 

scores.clusters = [pos_clusters neg_clusters];

% Quit if there are no clusters in the real data
if isempty(scores.clusters),
    scores = [];
	disp([mfilename, ': No clusters found, returning...']);
    return
end

% Calculating summed absolute t-test value for the real data within clusters
for clus = 1:numel(scores.clusters),
    if numel(scores.clusters{1, clus}) == 1,
        scores.clus_ttest(1, clus) = {abs(scores.data(1, scores.clusters{1, clus}).tstat)};
    else
        scores.clus_ttest(1, clus) = {sum(abs([scores.data(1, scores.clusters{1, clus}(1, 1):scores.clusters{1, clus}(1, 2)).tstat]))};
    end
end

% Finally I can permute the data!
scores.perm_ttest = zeros(num_perm, numel(scores.clusters));
data_full = vertcat(data_by_trial_group_A, data_by_trial_group_B);
for prm = 1 : num_perm,
    perm_ind = randperm(numel(data_full(:,1)));
	% for easier reading create these once
	
	num_A_trials = size(data_by_trial_group_A, 1);
	num_B_trials = size(data_by_trial_group_B, 1);
	
	pseudo_A_data = data_full(perm_ind(1:num_A_trials), :);
	pseudo_B_data = data_full(perm_ind(num_A_trials + 1 : numel(data_full(:, 1))), :);
		
	
	for clus = 1:numel(scores.clusters),

		if numel(scores.clusters{1, clus}) == 1,		
			finite_A_idx = find(~isnan(data_by_trial_group_A(:, scores.clusters{clus})));
			finite_B_idx = find(~isnan(data_by_trial_group_B(:, scores.clusters{clus})));
			finite_AB_idx = intersect(finite_A_idx, finite_B_idx);
				
			switch test_type
				case 'ttest'
					[h, p, ci, stats] = ttest(pseudo_A_data(finite_AB_idx, scores.clusters{clus}), ...
						pseudo_B_data(finite_AB_idx, scores.clusters{clus}));				
				case 'ttest2'
					[h, p, ci, stats] = ttest2(pseudo_A_data(finite_AB_idx, scores.clusters{clus}), ...
						pseudo_B_data(finite_AB_idx, scores.clusters{clus}));
			end			
			
% 			[h, p, ci, stats] = ttest(data_full(perm_ind(1:numel(data_full(:, 1)) / 2), scores.clusters{clus}), ...
% 				data_full(perm_ind(numel(data_full(:, 1)) / 2 + 1:numel(data_full(:, 1))), scores.clusters{clus}));
			scores.perm_ttest(prm, clus) = abs(stats.tstat);
		else
			tsum = 0;
			%pseudo_A_data = data_full(perm_ind(1:numel(data_full(:, 1)) / 2), :);
			%pseudo_B_data = data_full(perm_ind(numel(data_full(:, 1)) / 2 + 1 : numel(data_full(:, 1))), :);
			
			for frv = scores.clusters{clus}(1,1) : scores.clusters{clus}(1,2),
% 				if (frv == 318)
% 					disp('Doh,...');
% 				end
				
				% deal with NaNs, due to permutation these will not be
				% happening in the ame trials for AA and AB
				finite_A_idx = find(~isnan(pseudo_A_data(:, frv)));
				finite_B_idx = find(~isnan(pseudo_B_data(:, frv)));
				finite_AB_idx = intersect(finite_A_idx, finite_B_idx);
				
				% 				if length(finite_AB_idx) < 2
				% 					disp(['FRV: ', num2str(frv), ' too few non-NaN trials?']);
				% 				end
				switch test_type
					case 'ttest'
						[h, p, ci, stats] = ttest(pseudo_A_data(finite_AB_idx, frv), ...
					pseudo_B_data(finite_AB_idx, frv));
					case 'ttest2'
						[h, p, ci, stats] = ttest2(pseudo_A_data(finite_AB_idx, frv), ...
					pseudo_B_data(finite_AB_idx, frv));
				end
				
				
				% 				[h, p, ci, stats] = ttest(pseudo_A_data(perm_ind(1:numel(data_full(:, 1)) / 2), frv), ...
% 					data_full(perm_ind(numel(data_full(:, 1)) / 2 + 1 : numel(data_full(:, 1))), frv));
                %tsum = tsum + abs(stats.tstat);
				if isfinite(stats.tstat)
					% NaN are "infectious" that is adding a NaN to a normal
					% sum results in NaN (sameme for Inf so avoid NaNs
					tsum = nansum([tsum abs(stats.tstat)]);
				else
% 					disp('Encountered non-finite tstat output from ttest, not accumulating.');
				end
				%tsum = nansum([tsum abs(stats.tstat)]);
            end
            scores.perm_ttest(prm, clus) = abs(tsum);
        end
    end
end
scores.perm_dist = max(scores.perm_ttest, [], 2);
%hist(max(scores.perm_ttest, [], 2));

% Assign significance
for cl = 1:numel(scores.clus_ttest)
    tmpnum = sum(scores.clus_ttest{cl} > scores.perm_dist);
    pval = 1 - tmpnum/num_perm;
    scores.out.pval(cl) = {pval};
    scores.out.h(cl) = {pval < sing_lev};
end


end