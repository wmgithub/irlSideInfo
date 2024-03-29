% We use this file to generate a set of expert demonstrations for our
% experiment. 

% By construction, each feature is designed for transitioning from one dfa
% state to another dfa state. 

R = zeros(state_no, mdp_struct.action_no);
r_const = 8;

transition_list = transition(:)';
index_list = repmat((1:size(transition,1))',1,size(transition,2));
index_list = index_list(:)';

% -> s1
tmp = find(transition_list <= 100 & transition_list >= 1);
R(tmp) = r_const;

% -> s6
tmp = find(transition_list <= 600 & transition_list >= 501);
R(tmp) = -r_const;

% s5 -> s3
tmp = find(index_list >= 401 & index_list <= 500 & ...
        transition_list >= 201 & transition_list <= 300);
R(tmp) = r_const;

% s5 -> s4
tmp = find(index_list >= 401 & index_list <= 500 & ...
        transition_list >= 301 & transition_list <= 400);
R(tmp) = r_const;

% s5 -> s6
tmp = find(index_list >= 401 & index_list <= 500 & ...
        transition_list >= 501 & transition_list <= 600);
R(tmp) = -r_const;

% s3 -> s6
tmp = find(index_list >= 201 & index_list <= 300 & ...
        transition_list >= 501 & transition_list <= 600);
R(tmp) = -r_const;

% s3 -> s2
tmp = find(index_list >= 201 & index_list <= 300 & ...
        transition_list >= 101 & transition_list <= 200);
R(tmp) = r_const;

% s4 -> s2
tmp = find(index_list >= 301 & index_list <= 400 & ...
        transition_list >= 101 & transition_list <= 200);
R(tmp) = r_const;

% s4 -> s6
tmp = find(index_list >= 301 & index_list <= 400 & ...
        transition_list >= 501 & transition_list <= 600);
R(tmp) = -r_const;

% s2 -> s6
tmp = find(index_list >= 101 & index_list <= 200 & ...
        transition_list >= 501 & transition_list <= 600);
R(tmp) = -r_const;

% s2 -> s1
tmp = find(index_list >= 101 & index_list <= 200 & ...
        transition_list >= 1 & transition_list <= 100);
R(tmp) = r_const;

%% Evaluate and extract policy for the above reward function

policy = evaluateReward(R, 'Expert_task_performance_with_dfa_state', ...
    mdp_struct, dfa_struct, transition, stochastic, rejecting, rejecting_color);

%% Now, generating a set of expert demonstrations
demo_trajs = cell(num_of_demos, 1);
for traj_id = 1 : num_of_demos
    state_id = randi(100, 1) + (dfa_struct.S0 - 1) * mdp_struct.state_no;
    traj = zeros(num_of_steps, 2);
    rv = rand(1, num_of_steps); 
    
    for step_id = 1 : num_of_steps
        % This is the action the agent decides to take
        action = randsample(mdp_struct.action_no, 1, true, policy(state_id,:));
        traj(step_id, :) = [state_id, action];
        
        % This is the (stochastic) transition that the agent actually takes
        transition_id = randsample(mdp_struct.action_no, 1, true, stochastic(action,:));
        state_id = transition(state_id, transition_id);
    end
    
    demo_trajs{traj_id} = traj;
end
demo_trajs = cell2mat(demo_trajs);


