% The structure of the output of create_DRA:
% N_p:          |AP|
% state_no:     the number of states in Q
% trans:        state_no x 2^|AP| matrix
% pairs:        1
% K:            states to be visited for inf times
% L:            states to be visited for finite times
% S0:           initial state
% AP:           The set of atomic propositions

%% Another LTL specification
% ltlfilt -f '(G !r) & (F g1) & (F g2) & (!y U g1) & (!y U g2) & (F y)' --lbt
% /home/min/Softwares/ltl2dstar-0.5.4/src/ltl2dstar --ltl2nba=spin:/home/min/Softwares/ltl2ba-1.2/ltl2ba --output=automaton fo_min4.ltl fo_min4.out

%% Normal code

% % The code used to generate prefix-format input
% ltlfilt -f '(G !r) & (F g1) & (F g2) & (F y)' --lbt
% % Use ltl2dstar to generate a DRA
% /home/min/Softwares/ltl2dstar-0.5.4/src/ltl2dstar --ltl2nba=spin:/home/min/Softwares/ltl2ba-1.2/ltl2ba --output=automaton fo_min3.ltl fo_min3.out
R = create_DRA(['./' formula '.out'], N_p, 1);

% if exist(['./' formula '.ltl'], 'file')
%     if isunix
% %         dos(['./bin/ltl2dstar --ltl2nba=spin:./bin/ltl2ba --output=automaton ./' formula '.ltl ./' formula '.out']);
%         dos(['/home/min/Softwares/ltl2dstar-0.5.4/src/ltl2dstar --ltl2nba=spin:/home/min/Softwares/ltl2ba-1.2 --output=automaton ./' formula '.ltl ./' formula '.out']);
%     elseif ispc
%         dos(['./bin/ltl2dstar.exe --ltl2nba=spin:./bin/ltl2ba.exe --output=automaton ./' formula '.ltl ./' formula '.out']);
%     else
%         error('Unknown or unsupported operating system....');
%     end
%     
%     if exist(['./' formula '.out'], 'file')
%         R = create_DRA(['./' formula '.out'], N_p, 1);
%     else
%         error(['Cannot create DRA output with ltl2dstar, possible cause:', ...
%             'input file does not exist or ltl2dstar binary does not exist']);
%     end
% else
%     error('Input LTL formula not found');
% end

% We need to translate R.trans to dfa_struct.transition, which is a 
% state_no-by-|AP| matrix, instead of state_no-by-2^|AP|.

% We assume that the DFA encodes a reachability specification. Therefore, 
% target states should be K, unsafe states should be in L. 

% Each column represents "green2, green1, yellow, red, nothing"
dfa_trans = R.trans(:, [8, 4, 2, 1, size(R.trans, 2)]);
% AP_struct = struct( 'blue', 1, 'yellow', 2, 'red', 3, ...
%                     'green1', 4, 'green2', 5, 'white', 6);
dfa_APs = {'yellow', 'green2', 'green1', 'red'};

dfa_struct = R;
dfa_struct.trans = dfa_trans;
dfa_struct.AP_to_color = dfa_APs;

