function [obj_val, d_obj] = irlObjFunc(theta, demo_trajs, F, dF, state_no, mdp_struct, transition, stochastic)

% R: the reward matrix, state_no-by-mdp_struct.action_no
% R: 600 x 4
R = reshape(F * theta, state_no, mdp_struct.action_no);

% policy: state_no-by-mdp_struct.action_no matrix
% Q: 600 x 4
% V: 600 x 1
% policy: 600 x 4
Q = zeros(state_no, mdp_struct.action_no);
V = log(sum(exp(Q), 2));
V_prev = V-1;
policy = exp(Q - repmat(V, 1, mdp_struct.action_no));

% dQ: state_no-by-mdp_struct.action_no-by-size(F,2)
% dQ: 600 x 4 x 16
% dV: 600 x 16
% z_theta: 600 x 4 x 16
dQ = ones(size(Q,1), size(Q,2), size(F,2));
dV = ones(size(V,1), size(F,2));
z_theta = repmat(policy, 1, 1, size(F,2)) .* dQ;

% dpi: state_no-by-mdp_struct.action_no-by-size(F,2)
% dpi: 600 x 4 x 16
dpi = z_theta - ...
    repmat(policy, 1, 1, size(F,2)) .* ...
    repmat(sum(z_theta, 2), 1, mdp_struct.action_no, 1);


% disp('Initializing')
err = 1;
cnt = 0;
while err > 1e-5
    Q = R + mdp_struct.gamma * V(transition) * stochastic;
    V = log(sum(exp(Q), 2));
    policy = exp(Q - repmat(V, 1, mdp_struct.action_no));
    
    err = max(abs(V - V_prev));
    V_prev = V;
    cnt = cnt + 1;
    
%     disp(['[',num2str(cnt),'] err = ', num2str(err)])
end

% Compute the gradient of Q w.r.t. theta
err = 1;
cnt = 0;
dQ_prev = dQ-1;
while err > 1e-5
tmp = squeeze(sum(repmat(policy * stochastic, 1, 1, size(F,2)) .* dQ, 2));
dQ = dF + mdp_struct.gamma * ...
    reshape(tmp(transition,:), state_no, mdp_struct.action_no, size(F,2)); 

err = max(abs(dQ(:) - dQ_prev(:)));
dQ_prev = dQ;
cnt = cnt + 1;

% disp(['[',num2str(cnt),'] err = ', num2str(err)])
end

z_theta = repmat(policy, 1, 1, size(F,2)) .* dQ;
dpi = z_theta - ...
    repmat(policy, 1, 1, size(F,2)) .* ...
    repmat(sum(z_theta, 2), 1, mdp_struct.action_no, 1);

%% Objective function and gradient
% First, get index of the transitions in demonstrations in Q
Q_index = sub2ind(size(Q), demo_trajs(:,1), demo_trajs(:,2));
% Then get index of the transitions in demonstrations in dQ
index = repmat(1:size(F,2), length(demo_trajs(:,1)), 1);
dQ_index = sub2ind(size(dQ),    repmat(demo_trajs(:,1), size(F,2), 1), ...
                                repmat(demo_trajs(:,2), size(F,2), 1), ...
                                index(:));
tmp1 = sum(reshape(dQ(dQ_index), size(demo_trajs, 1), size(F, 2)), 1);                            
tmp2 = sum(squeeze(sum(z_theta(demo_trajs(:,1), :, :), 2)), 1);

% Original objective is to maximize likelihood 
obj_val = sum(log(policy(Q_index))) / size(demo_trajs, 1);
d_obj = tmp1 - tmp2;
d_obj = d_obj' / size(demo_trajs, 1);

% Since we will minimize the negative likelihood objective (which is positive), we get negative of obj_val
obj_val = -obj_val;
d_obj = -d_obj;
                            
% obj_val = sum(Q(Q_index)) / size(demo_trajs, 1);
% d_obj = sum(reshape(dQ(dQ_index), size(demo_trajs, 1), size(F,2)), 1) / size(demo_trajs, 1);

end