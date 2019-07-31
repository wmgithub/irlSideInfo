% MDP: mdp_struct
%   transition function     transition: S x A -> S
%   labeling function       labeling: S -> AP
% 
% DFA: dfa_struct
%   transition: |Q| x |AP|
%   K: the set of states to be visited infinitely often
%   L: the set of states to be visited for finitely many times
% 
% Reward features: 
%   S x Q -> Real number
% 
% Constructing a product automaton:
%   State space: S x Q, with label mdp_struct.labeling(s)

state_no = mdp_struct.state_no * dfa_struct.state_no;
testing = 0;

%% First, construct the transition function for the product automaton
% transition:   state_no-by-mdp_struct.action_no matrix
% transition = repmat(mdp_struct.transition, dfa_struct.state_no, 1) + ...
%     repmat(reshape( repmat((0:dfa_struct.state_no-1)*mdp_struct.state_no, ...
%                             mdp_struct.state_no, 1), ...
%                     dfa_struct.state_no*mdp_struct.state_no, 1), ...
%            1, mdp_struct.action_no);
transition = zeros( mdp_struct.state_no * dfa_struct.state_no, ...
                    mdp_struct.action_no);
       
% The mapping from mdp label to dfa transition index
% AP_struct = struct( 'blue', 1,    'yellow', 2,    'red', 3, ...
%                     'green1', 4,  'green2', 5,    'white', 6);
% dfa_APs = {'yellow', 'green2', 'green1', 'red'};]
label_to_trans = [5, 1, 4, 3, 2, 5];
% % dfa_APs = {'green2', 'green1', 'yellow', 'red'};
% % label_to_trans = [5, 3, 4, 2, 1, 5];

F_cell = cell(1, dfa_struct.state_no * dfa_struct.state_no);
for action_id = 1 : mdp_struct.action_no
    for state_id = 1 : size(transition, 1)
        [mdp_id, dfa_id] = ind2sub(...
            [mdp_struct.state_no, dfa_struct.state_no], state_id);
%         mdp_id = mod(state_id - 1, mdp_struct.state_no) + 1;
%         dfa_id = floor((state_id - 1)/mdp_struct.state_no) + 1;
        
        % The successor state in MDP
        mdp_id_next = mdp_struct.transition(mdp_id, action_id);
        % label of the successor state in AP
        label_id_next = mdp_struct.labeling(mdp_id_next);
        % The successor state in DFA
        dfa_id_next = dfa_struct.trans(dfa_id, label_to_trans(label_id_next));
        
        f_id = sub2ind([dfa_struct.state_no, dfa_struct.state_no], ...
                        dfa_id, dfa_id_next);
        if isempty(F_cell{f_id})
            F_cell{f_id} = zeros(state_no * mdp_struct.action_no, 1);
        end
        sa_id = sub2ind([state_no, mdp_struct.action_no], ...
                         state_id, action_id);
        F_cell{f_id}(sa_id, 1) = 1;
        
        % update both the dfa state and the mdp state
        transition(state_id, action_id) = ...
            sub2ind([mdp_struct.state_no, dfa_struct.state_no], ...
                     mdp_id_next, dfa_id_next);
        
%         transition(state_id, action_id) = ...
%             (dfa_id_next-1) * mdp_struct.state_no + mdp_id_next;
%         tmp = sub2ind(  [mdp_struct.state_no, dfa_struct.state_no], ...
%                         mdp_id_next, dfa_id_next);
%         if transition(state_id, action_id) ~= tmp
%             disp(num2str(tmp))
%             disp(num2str(transition(state_id, action_id)))
%             disp('-----')
%         end
    end
end

% Test the transition function
if testing
    colormap = hsv(dfa_struct.state_no);
    % fig_id = 0;
    for fig_id = 0 : dfa_struct.state_no-1
        figure(1);
        clf;
        for state_id = (1 : 100)+fig_id*100
            mdp_id = mod(state_id - 1, mdp_struct.state_no) + 1;
            dfa_id = floor((state_id - 1)/mdp_struct.state_no) + 1;
            
            y = mdp_struct.grid_dim - mdp_struct.itox(mdp_id);
            x = mdp_struct.itoy(mdp_id) - 1;
            % Up
            state_id_next = transition(state_id, 1);
            dfa_id_next = floor((state_id_next - 1)/mdp_struct.state_no) + 1;
            patch([0, 1, 0.5, 0]+x, [1, 1, 0.5, 1]+y, colormap(dfa_id_next,:))
            hold on
            % Right
            state_id_next = transition(state_id, 2);
            dfa_id_next = floor((state_id_next - 1)/mdp_struct.state_no) + 1;
            patch([1, 1, 0.5, 1]+x, [1, 0, 0.5, 1]+y, colormap(dfa_id_next,:))
            % Down
            state_id_next = transition(state_id, 3);
            dfa_id_next = floor((state_id_next - 1)/mdp_struct.state_no) + 1;
            patch([0, 1, 0.5, 0]+x, [0, 0, 0.5, 0]+y, colormap(dfa_id_next,:))
            % Left
            state_id_next = transition(state_id, 4);
            dfa_id_next = floor((state_id_next - 1)/mdp_struct.state_no) + 1;
            patch([0, 0, 0.5, 0]+x, [1, 0, 0.5, 1]+y, colormap(dfa_id_next,:))
        end
        title(['DFA state ', num2str(fig_id+1)])
        saveas(gcf, ['dfa_state_', num2str(fig_id+1)], 'png')
    end
end
