function [pvalue,pdf] = circular_stats(angles,values,n_shuffle)
% Computes pvalue for circular distribution
% Uses either mean vector length (MVL) as criterion for phase preference

% Default Parameters
if nargin < 3
    n_shuffle = 10000;
end

pvalue = NaN;
pdf = NaN(1,n_shuffle);

% Sanity Check
if (size(angles,1)*size(angles,2)) ~= length(angles)
    warning('Arguments must be one-dimensional vectors.');
    return;
elseif (size(values,1)*size(values,2)) ~= length(values)
    warning('Arguments must be one-dimensional vectors.');
    return;
elseif length(angles) ~= length(values)
    warning('Arguments must be the same length.');
    return;
end

% Making column vectors
angles = angles(:);
values = values(:);
% n_angles = length(angles);
n_values = length(values);


% Generating shuffles
shuffled_values = NaN(n_values,n_shuffle);
for i = 1:n_shuffle
    %temp = randperm(n_values)';
    shuffled_values(:,i) = values(randperm(n_values));
end

% Generating pdf
shuffled_mvl_x = mean(repmat(cos(angles),[1,n_shuffle]).*shuffled_values,1,'omitnan');
shuffled_mvl_y = mean(repmat(sin(angles),[1,n_shuffle]).*shuffled_values,1,'omitnan');
shuffled_mvl = sqrt(shuffled_mvl_x.^2+shuffled_mvl_y.^2);
pdf = sort(shuffled_mvl);

% Generating pvalue
mvl_x = mean(cos(angles).*values);
mvl_y = mean(sin(angles).*values);
this_mvl = sqrt(mvl_x.^2+mvl_y.^2);
index_test = (sort(shuffled_mvl)-this_mvl)>0;
pvalue = sum(index_test)/length(index_test);

end