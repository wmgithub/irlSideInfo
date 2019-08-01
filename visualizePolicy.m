function visualizePolicy(policy, mdp_struct, dfa_struct)

n_colors = 100;
color_index = gray(n_colors+1);
% fig_id = 0;
for fig_id = 0 : dfa_struct.state_no-1
    figure(1);
    clf;
    for state_id = (1 : 100)+fig_id*100
        mdp_id = mod(state_id - 1, mdp_struct.state_no) + 1;
%         dfa_id = floor((state_id - 1)/mdp_struct.state_no) + 1;
        
        y = mdp_struct.grid_dim - mdp_struct.itox(mdp_id);
        x = mdp_struct.itoy(mdp_id) - 1;
        % Up
        patch([0, 1, 0.5, 0]+x, [1, 1, 0.5, 1]+y, color_index(1 + round(n_colors * policy(state_id, 1)),:))
        hold on
        % Right
        patch([1, 1, 0.5, 1]+x, [1, 0, 0.5, 1]+y, color_index(1 + round(n_colors * policy(state_id, 2)),:))
        % Down
        patch([0, 1, 0.5, 0]+x, [0, 0, 0.5, 0]+y, color_index(1 + round(n_colors * policy(state_id, 3)),:))
        % Left
        patch([0, 0, 0.5, 0]+x, [1, 0, 0.5, 1]+y, color_index(1 + round(n_colors * policy(state_id, 4)),:))
    end
    title(['Policy for DFA state ', num2str(fig_id+1)])
    colormap(gcf, 'gray')
    colorbar
    saveas(gcf, ['Policy_for_dfa_state_', num2str(fig_id+1)], 'png')
end

end