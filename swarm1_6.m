function swarms_new = swarm1_6(swarms, N1)
    % swram:    setting(fhd, func, size, dim, lb, ub, v_max, 
    %                   w, c1, c2, sigma)
    %           particles(pos, vel, fit, best_pos, best_fit), 
    %           solution(best_pos, best_fit, best_index)
    
    global plot_interval;
    
    % reset search_swarm
    N = length(swarms);
    for index = 1:N
        swarm = swarms{index};
        swarm.setting.w = 1.0; 
        swarm.setting.c1 = 2.0; 
        swarm.setting.c2 = 2.0; 
        swarm.setting.sigma = 0.1;
    
        swarm.particles.pos = rand(swarm.setting.size, swarm.setting.dim) ...
            * (swarm.setting.ub - swarm.setting.lb) + swarm.setting.lb;
        swarm.particles.vel = (rand(swarm.setting.size, swarm.setting.dim) * 2 - 1) * swarm.setting.v_max;
        swarm.particles.fit = benchmark_2015(swarm.particles.pos, swarm.setting.func);
        swarm.particles.best_pos = swarm.particles.pos;
        swarm.particles.best_fit = swarm.particles.fit;
    
        [~, min_index] = min(swarm.particles.best_fit);
        swarm.solution.best_pos = swarm.particles.best_pos(min_index, :);
        swarm.solution.best_fit = swarm.particles.best_fit(min_index);
        swarm.solution.best_index = min_index;
        swarms{index} = swarm;
    end
    
    for iter = 1:N1
        % udate coefficients
        % Et = [0, 1]
        w_range = [0.6, 0.9]; 
        c1 = 1.49445;
        c2 = 1.49445;
        sigma_range = [0.1, 0.1];
        for index_out = 1:N 
            swarm = swarms{index_out};
            swarm = update_coe_6(swarm, w_range, sigma_range);
            swarm.setting.c1 = c1;
            swarm.setting.c2 = c2;
    
            % update position
            temp_vel = (swarm.setting.w * swarm.particles.vel) ...
                +(swarm.setting.c1*rand(swarm.setting.size,swarm.setting.dim).*(swarm.particles.best_pos-swarm.particles.pos)) ...
                +(swarm.setting.c2*rand(swarm.setting.size,swarm.setting.dim).*(ones(swarm.setting.size,1)*swarm.solution.best_pos-swarm.particles.pos));
            temp_vel = max(-swarm.setting.v_max, min(swarm.setting.v_max, temp_vel));
            swarm.particles.vel = temp_vel;
            temp_pos = swarm.particles.pos + swarm.particles.vel;
            temp_pos = max(swarm.setting.lb, min(swarm.setting.ub, temp_pos));
            swarm.particles.pos = temp_pos;
            swarm.particles.fit = benchmark_2015(swarm.particles.pos, swarm.setting.func);
            for index = 1:swarm.setting.size
                if swarm.particles.fit(index) < swarm.particles.best_fit(index)
                    swarm.particles.best_pos(index, :) = swarm.particles.pos(index, :);
                    swarm.particles.best_fit(index) = swarm.particles.fit(index);
                end
            end
    
            [~, min_index] = min(swarm.particles.best_fit);   % note: the best_fit is used here
            swarm.solution.best_pos = swarm.particles.best_pos(min_index, :);
            swarm.solution.best_fit = swarm.particles.best_fit(min_index);
            swarm.solution.best_index = min_index;
            swarms{index_out} = swarm;
        end
        
        if plot_interval
            if mod(iter, plot_interval) == 0
                best_fit = zeros(1, N);
                for index_out = 1:N
                    best_fit(index_out) = swarms{index_out}.solution.best_fit;
                end
                    
                disp(['step_search:', num2str(iter),  ' best fit: ', num2str(min(best_fit))]); 
            end
            if mod(iter, plot_interval) == 0
                plot_2d(swarms, 'search_swarm');
            end
        end
        
    end
    swarms_new = swarms;