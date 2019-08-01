%% Initialization
% The dimension of F: (state_no*mdp_struct.action_no)-by-feature_no
% F: 2400 x 16
% dF: 600 x 4 x 16
F = cell2mat(F_cell);
dF = reshape(F, state_no, mdp_struct.action_no, size(F,2));

% theta is the reward parameter vector
% theta: 16 x 1
theta = rand(size(F, 2), 1);

%% Maximum entropy IRL

obj_func = @(theta) irlObjFunc(theta, demo_trajs, F, dF, state_no, mdp_struct, transition, stochastic);

order = 1;
% type == 1: finite differencing
% type == 2: central differencing
% type == 3: complex differentials
type = 2;
derivativeCheck(@irlObjFunc, theta, order, type, ...
    demo_trajs, F, dF, state_no, mdp_struct, transition, stochastic);

%% 

maxFunEvals = 1000;
options = [];
options.display = 'none';
options.maxFunEvals = maxFunEvals;

options.LS_init = 1;
options.Method = 'lbfgs';
options.numDiff = 0;
options.MaxIter = 2000;
options.progTol = 1e-6;
options.optTol = 1e-6;

disp('--- Before optimization ---')
[obj_val, ignore] = obj_func(theta);
disp(['obj_val = ', num2str(obj_val)])

[theta, obj_val, exit_flag, output] = minFunc(obj_func, theta, options);
disp('--- After optimization --- (note that obj is to be minimized)')
disp(['obj_val = ', num2str(obj_val)])

%% Evaluate and extract policy for the above reward function
R = reshape(F * theta, state_no, action_no);
policy = evaluateReward(R, 'Learning_task_performance_with_dfa_state', ...
    mdp_struct, dfa_struct, transition, stochastic, rejecting, rejecting_color);

%% Visualize the learned policy
visualizePolicy(policy, mdp_struct, dfa_struct)
