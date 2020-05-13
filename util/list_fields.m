function L = list_fields(S,Sname)
% take in a structure variable and list out all
% fields and corresponding values
% Input: 
% - Sname: name of the information group
% - S: 	   structure containing information regarding Sname
% 
% Outputs:
% L: list of field names of S to feed into nwb

Fields = fieldnames(S);

L = '';
for i = 1:numel(Fields)
	L = [L ',''' Fields{i} ''',' Sname '.' Fields{i}];
end

L(1) = [];

