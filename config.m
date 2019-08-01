% This file contains all the hyper-parameters.

clear
clc

% First set random seed
random_seed = 1;
rng(random_seed);

%% For MDP: mdp.m

% Dimension of the grid world: grid_dim-by-grid_dim
grid_dim = 10;
% Number of available actions
action_no = 4;

% Stochastic transition 
% p_center: Prob to transit in the given direction
% p_others: Prob to transit to other directions
p_center = 1;
p_others = (1-p_center) / (action_no-1);

% Discount factor
gam = 0.9;

% Labels
blue = [2];
yellow = [grid_dim+1];
red = [[grid_dim+4, 2*grid_dim+9], 3*grid_dim+[6:9], [4*grid_dim+9, ...
    5*grid_dim+[4:5], 5*grid_dim+8, 6*grid_dim+1, 6*grid_dim+3,...
    8*grid_dim+5]];
green1 = [5*grid_dim];
green2 = [8*grid_dim+8];
AP_struct = struct( 'blue', 1, 'yellow', 2, 'red', 3, ...
                    'green1', 4, 'green2', 5, 'white', 6);
AP_to_color = {'b', 'y', 'r', 'g', 'g', 'w'};

AP_colors = fieldnames(AP_struct);
num_AP = length(AP_colors);

%% For DFA: dfa.m
formula = 'fo_min4';
N_p = 4;

% Note that we need to transform the alphabet from 2^|AP| to |AP|. 
% dfa_trans and dfa_APs should be re-defined in dfa.m. 

%% For product automaton: product_automaton.m
% label_to_trans should be re-defined in product_automaton.m. 

% Rejecting state in DFA is state 1
rejecting = 6;
% Rejecting color
rejecting_color = red;

num_of_demos = 20;
num_of_steps = 40;
