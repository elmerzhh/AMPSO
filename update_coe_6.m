function swarm_new = update_coe_6(swarm, w_range, sigma_range)
    
    Et = diversity(swarm);
    
    % update coefficient
    a = 1.0;
    swarm.setting.w = transform_coe_update(w_range, a, Et);
    swarm.setting.sigma = (sigma_range(2)-sigma_range(1)) * Et + sigma_range(1);
    swarm_new = swarm;
end
    
function coe = transform_coe_update(x_range, a, Et)
    b = 1 / x_range(1) - a;
    c = log((1.0/x_range(2) - a) / b);
    coe = 1 / (a + b * exp(c * Et));
%     disp(['b', num2str(b), 'c', num2str(c)])
end  
    
function diversity = diversity(swarm)
    N = swarm.setting.size;
    E_pos = 0;
    for index_1 = 1:swarm.setting.dim
        p = zeros(1, N);
        pos_tri = linspace(swarm.setting.lb, swarm.setting.ub, N);
        for index_2 = 1:swarm.setting.size
            handle = find(swarm.particles.pos(index_2, index_1) <= pos_tri, 1);
            p(handle) = p(handle) + 1;
        end
        p = p / swarm.setting.size;
        p(p==0) = [];
        entropy_temp = 0;
        for index_3 = 1:length(p)
            entropy_temp = entropy_temp - p(index_3) * log(p(index_3));
        end
        entropy_temp = entropy_temp / log(N);
        E_pos = entropy_temp / swarm.setting.dim;
    end

    fitness = swarm.particles.fit;
    fit_tri = linspace(min(fitness), max(fitness), N);
    p = zeros(1, N);
    for index = 1:swarm.setting.size
        handle = find(fitness(index) <= fit_tri, 1);
        p(handle) = p(handle) + 1;
    end
    p = p / sum(p);
    p(p==0) = [];
    E_fit = 0;
    for index = 1:length(p)
        E_fit = E_fit - p(index) * log(p(index));
    end
    E_fit = E_fit / log(N);

    diversity = (E_pos + E_fit) / 2;
end