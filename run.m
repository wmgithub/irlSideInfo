cd '/home/min/PennAcademics/irl_inferred_logic/active_irl_experiment'
addpath(genpath('/home/min/Softwares/minFunc_2012'));
disp('Configuring')
config

disp('Constructing MDP...')
mdp
disp('Done!')

disp('Constructing DFA...')
dfa
disp('Done!')

disp('Constructing product automaton...')
product_automaton
disp('Done!')

disp('Generating expert demonstrations...')
generate_demos_4
disp('Done!')

disp('Doing inverse reinforcement learning...')
maxEntIRL
disp('Done!')