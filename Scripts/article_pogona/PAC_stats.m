function [pvalue,pdf,this_mvl] = PAC_stats(Yphase,Yvalue,n_shuffle,n_bins)
% Antoine Bergel - March 24 - antoine.bergel[at]espci.fr
% Computes pvalue for circular distribution
% Uses mean vector length (MVL) as criterion for phase preference
% Yphase must be in radians
% Output 1 pvalue : statistical test output
% Output 2 pdf : distribution of mvl for shuffled data
% Output 3 this_mvl : MVL for unshuffled data


% Default Parameters
if nargin < 4
    n_bins = 72;
end
if nargin < 3
    n_shuffle = 1000;
end

pvalue = NaN;
pdf = NaN(1,n_shuffle);

% Sanity Check
if size(Yphase,1)*size(Yphase,2) ~= length(Yphase)
    warning('Phase vector must be a column or row vector.');
    return;
elseif size(Yvalue,1)*size(Yvalue,2) ~= length(Yvalue)
    warning('Value vector must be a column or row vector.');
    return;
elseif length(Yphase) ~= length(Yvalue)
    warning('Phase and Value vectors must be the same size.');
    return;
end

% Formatting data
Yphase = Yphase(:);
Yvalue = Yvalue(:);
Yphase = mod(Yphase,2*pi);
n_values = length(Yvalue);

% Generating shuffles
shuffled_values = NaN(n_values,n_shuffle);
index_rand = randi(n_values,[n_shuffle,1]);
for i = 1:n_shuffle
    shuffled_values(:,i) = [Yvalue(1:index_rand(i)-1);flip(Yvalue(index_rand(i):end))];
end

% Generating bin_edges and bin_centers
bin_edges = 0:(2*pi)/n_bins:(2*pi);
bin_centers = bin_edges(1:end-1)+(pi/n_bins);

all_Yvalues = [Yvalue,shuffled_values];
bin_counts = zeros(length(bin_edges)-1,n_shuffle+1);
for i = 1:size(bin_counts,1)
    index_keep = (Yphase>=bin_edges(i)).*(Yphase<bin_edges(i+1));
    bin_counts(i,:) = mean(all_Yvalues(index_keep==1,:),'omitnan');
end

% Generating mvl
all_bin_centers = repmat(bin_centers',[1,n_shuffle+1]);
mvl_x = mean(cos(all_bin_centers).*bin_counts,'omitnan');
mvl_y = mean(sin(all_bin_centers).*bin_counts,'omitnan');
all_mvl = sqrt(mvl_x.^2+mvl_y.^2);
this_mvl = all_mvl(1);
shuffled_mvl = all_mvl(2:end);

% Generating pvalue
pdf = sort(shuffled_mvl);
index_test = (sort(shuffled_mvl)-this_mvl)>0;
pvalue = sum(index_test)/length(index_test);

end