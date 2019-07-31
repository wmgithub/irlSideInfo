% This file specifies an original MDP with state space, action space,
% transition function, labeling function.
mdp_state_no = grid_dim^2;

% For all indices: (x, y) -> x+(y-1)*grid_dim
% The origin is the upper left corner. x goes down, y goes right. 
% (x, y) \in [1, grid_dim] x [1, grid_dim]

% Two functions from index to (x,y)
itox = @(index) mod(index-1, grid_dim) + 1;
itoy = @(index) floor((index-1) / grid_dim) + 1;
xytoi = @(x, y) x + (y - 1) * grid_dim;

%% Atomic propositions and labeling functions
% labeling function is a vector
labeling = ones(mdp_state_no, 1) * num_AP;
for color_id = 1 : num_AP
    tmp = eval(AP_colors{color_id});
    for pos_id = 1 : length(tmp)
        labeling(tmp(pos_id)) = color_id;
    end
end

% % Test the labeling function
% figure(1);
% for index = 1 : length(labeling)
%     y = grid_dim - itox(index);
%     x = itoy(index) - 1;
%     patch(x+[0,0,1,1,0], y+[1,0,0,1,1], AP_to_color{labeling(index)});
%     hold on;
% end
% for index = 1 : mdp_state_no
%     x = itox(index);
%     y = itoy(index);
%     tmp = xytoi(x, y);
%     if tmp ~= index
%         disp(['index = ', num2str(index), ', tmp = ', num2str(tmp)])
%     end
% end
% % Testing passed!!!

%% Transition distribution: 
% Action = {'up', 'right', 'down', 'left'}
transition = zeros(mdp_state_no, action_no);
for index = 1 : mdp_state_no
    x = itox(index);
    y = itoy(index);
    % up
    transition(index, 1) = xytoi(max(1, x-1), y);
    % right
    transition(index, 2) = xytoi(x, min(grid_dim, y+1));
    % down
    transition(index, 3) = xytoi(min(grid_dim, x+1), y);
    % left
    transition(index, 4) = xytoi(x, max(1, y-1));
end

for yellow_id = 1 : length(yellow)
    transition(yellow(yellow_id), :) = yellow(yellow_id);
end

% % Test the transition function
% figure(2);
% for index = 1 : mdp_state_no
%     next = transition(index, 1);
%     y = grid_dim - itox(index);
%     x = itoy(index) - 1;
%     patch(x+[0,0,1,1,0], y+[1,0,0,1,1], AP_to_color{labeling(next)});
%     hold on;
% end
% % Testing passed!

% Each column corresponds to the prob of taking each action when the agent
% tries to take each action
stochastic = ones(action_no) * p_others;
for index = 1 : action_no
    stochastic(index, index) = p_center;
end
stochastic = stochastic';
% sum(stochastic, 1)

%% Output structure
mdp_struct = struct('transition', transition, ...
    'stochastic', stochastic, ...
    'labeling', labeling, ...
    'itox', itox, ...
    'itoy', itoy, ...
    'xytoi', xytoi, ...
    'AP_struct', AP_struct, ...
    'state_no', mdp_state_no, ...
    'action_no', action_no, ...
    'grid_dim', grid_dim, ...
    'gamma', gam);
