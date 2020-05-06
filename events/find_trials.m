function [selected_trials,time,toi] = find_trials(Trials,codes,icol)
% [selected_trials,time] = find_trials(Trials,codes,icol)

% find codes that exist in separarate columns
if iscell(codes)
	toi = true(size(Trials.code,1),1);
	for i = 1:numel(codes)
		toi = toi & ismember(Trials.code(:,icol{i}),codes{i});
	end

	% output time as the last event (usually target presentation)
	icol = icol{end};

% find codes in a single column
else

	toi = ismember(Trials.code(:,icol),codes);
	toi = logical(sum(toi,2));

end

selected_trials.code = Trials.code(toi,:);
selected_trials.time = Trials.time(toi,:);

% return time stamps of requested codes in icol
time = selected_trials.time(:,icol);