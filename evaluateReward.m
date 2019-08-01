function policy = evaluateReward(R, title_name, mdp_struct, dfa_struct, transition, stochastic, rejecting, rejecting_color)

% Value iteration
err = 1;
cnt = 0;

V = zeros(size(R, 1), 1);
V_prev = ones(size(V));

while err > 1e-5
    Q = R + mdp_struct.gamma * V(transition) * stochastic;
    V = log(sum(exp(Q), 2));
    policy = exp(Q - repmat(V, 1, mdp_struct.action_no));
    
    err = max(abs(V - V_prev));
    V_prev = V;
    cnt = cnt + 1;
    
%     disp(['[',num2str(cnt),'] err = ', num2str(err)])
end

% Evaluate the probability to satisfy the specification
perf = zeros(size(V));
perf_perv = ones(size(V));

for dfa_id = 1 : length(dfa_struct.K{1})
    dfa_state = dfa_struct.K{1}(dfa_id);
    perf((1:mdp_struct.state_no)+(dfa_state-1)*mdp_struct.state_no) = 1;
end

err = 1; cnt = 0;
while err > 1e-5
    perf = sum((policy * stochastic) .* perf(transition), 2);
    
    % Accepting state
    for dfa_id = 1 : length(dfa_struct.K{1})
        dfa_state = dfa_struct.K{1}(dfa_id);
        perf((1:mdp_struct.state_no)+(dfa_state-1)*mdp_struct.state_no) = 1;
    end
    
    % Rejecting state
    perf((1 : mdp_struct.state_no) + (rejecting - 1) * mdp_struct.state_no) = 0;
    for dfa_id = 1 : dfa_struct.state_no
        perf(rejecting_color + (dfa_id - 1) * mdp_struct.state_no) = 0;
    end
    
    err = max(abs(perf - perf_perv));
    perf_perv = perf;
    cnt = cnt + 1;
    
%     disp(['[', num2str(cnt),'] err = ', num2str(err)])
end

figure(1);
for fig_id = 0 : dfa_struct.state_no-1
    clf;
    heatmap(reshape(perf((1:mdp_struct.state_no)+mdp_struct.state_no*fig_id),...
                    mdp_struct.grid_dim, mdp_struct.grid_dim));
    caxis([0 1])
    title([title_name, ' ', num2str(fig_id+1)])
    saveas(gcf, [title_name, '_', num2str(fig_id+1)], 'png')
end



% tmp = squeeze(sum(repmat(policy * stochastic, 1, 1, size(F,2)) .* dQ, 2));
% dQ = dF + mdp_struct.gamma * ...
%     reshape(tmp(transition,:), state_no, mdp_struct.action_no, size(F,2)); 

end