function pos = get_position(n_rows,n_columns,counter,margins)
% Gives precise axes positions in multiple subplots

if nargin<4
    w_margin_1 = .05; % left margin
    w_margin_2 = .05; % right margin
    w_eps = .01;      % horizontal spacing
    h_margin_1 = .05; % bottom margin
    h_margin_2 = .05; % top margin
    h_eps = .01;      % vertical spacing
    
    margins = [w_margin_1,w_margin_2,w_eps;
        h_margin_1,h_margin_2,h_eps];
end

w_margin_1 = margins(1,1); % left margin
w_margin_2 = margins(1,2); % right margin
w_eps = margins(1,3);      % horizontal spacing
h_margin_1 = margins(2,1); % bottom margin
h_margin_2 = margins(2,2); % top margin
h_eps = margins(2,3);

pos1 = w_margin_1 + (mod(counter-1,n_columns)/n_columns)*(1-(w_margin_1+w_margin_2));
pos2 = 1 - h_margin_2 - (ceil(counter/n_columns)/n_rows)*(1-(h_margin_1+h_margin_2));
pos3 = ((1-(w_margin_1+w_margin_2))/n_columns) - w_eps;
pos4 = ((1-(h_margin_1+h_margin_2))/n_rows) - h_eps;
pos=[pos1,pos2,pos3,pos4];

end