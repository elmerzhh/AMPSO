function [swarm_new, step] = swarm2_6(swarm, original_pos, iter_exploit_min, iter_exploit_max)
    % swram:    setting(fhd, func, size, dim, lb, ub, v_max, 
    %                   v_min, w, c1, c2, sigma, diversity),   % diversity denote diversity_expected
    %           particles(pos, vel, fit, best_pos, best_fit), 
    %           solution(best_pos, best_fit, best_index)
    
    global plot_interval;
    global alpha3
    
    %% generation of exploit swarm
    sigma = 0.1;
    position = zeros(swarm.setting.size, swarm.setting.dim);
    position(1, :) = original_pos;
    for index = 2:swarm.setting.size
        position(index, :) = disturbance_6(original_pos, swarm, sigma, 'r_dir');
    end
    position = max(swarm.setting.lb, min(swarm.setting.ub, position));
    swarm.particles.pos = position;
    swarm.particles.vel = (rand(swarm.setting.size, swarm.setting.dim)...
        * 2 -1) * swarm.setting.v_max;
    swarm.particles.fit = benchmark_2015(swarm.particles.pos, swarm.setting.func);
    swarm.particles.best_pos = swarm.particles.pos;
    swarm.particles.best_fit = swarm.particles.fit;
    
    [~, min_index] = min(swarm.particles.best_fit);   % note: the best_fit is used here
    swarm.solution.best_pos = swarm.particles.best_pos(min_index, :);
    swarm.solution.best_fit = swarm.particles.best_fit(min_index);
    swarm.solution.best_index = min_index;
    
    %% iteration
    step = 1;
    record = zeros(1, 1000); record(1) = swarm.solution.best_fit;
    while true
        % update coefficients
        % Et = [0, 1]
        w_range = [0.5, 0.8]; 
        swarm.setting.c1 = 1.49445;
        swarm.setting.c2 = 1.49445;
        sigma_range = [0.1, 0.2];
        swarm = update_coe_6(swarm, w_range, sigma_range);
%         swarm.setting.sigma = sigma_range(2)-step*(sigma_range(2)-sigma_range(1)) / iter_exploit_max;
%         swarm.setting.sigma = max(sigma_range(1), swarm.setting.sigma);
%         
        % rebuilding of particle
        num_p1 = ceil(alpha3 * swarm.setting.size);  % the number of rebuilding particles
        num_p2 = swarm.setting.size - num_p1;
        [~, sort_index] = sort(swarm.particles.best_fit);
        worst_index = sort_index(num_p2+1:swarm.setting.size);
        position = zeros(num_p1, swarm.setting.dim);
        for index = 1:num_p1
            position(index, :) = disturbance_6(swarm.solution.best_pos, swarm, swarm.setting.sigma, '1_dim');
        end
        position = max(swarm.setting.lb, min(swarm.setting.ub, position));
        fitness = benchmark_2015(position, swarm.setting.func);
        swarm.particles.pos(worst_index, :) = position;
        swarm.particles.fit(worst_index) = fitness;
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
    
        % update swarm
        select_index = randperm(swarm.setting.size);
        select_index = select_index(1:num_p2);
        temp_vel = swarm.particles.vel(select_index, :);
        temp_pos = swarm.particles.pos(select_index, :);
        temp_best_pos = swarm.particles.best_pos(select_index, :);
    
        temp_vel = swarm.setting.w * temp_vel ...
            + swarm.setting.c1 * rand(num_p2, swarm.setting.dim) .* (temp_best_pos - temp_pos) ...
            + swarm.setting.c2 * rand(num_p2, swarm.setting.dim) .* (ones(num_p2, 1) * swarm.solution.best_pos - temp_pos);
        temp_vel = max(-swarm.setting.v_max, min(swarm.setting.v_max, temp_vel));
        temp_pos = temp_pos + temp_vel;
        temp_pos = max(swarm.setting.lb, min(swarm.setting.ub, temp_pos));
        temp_fit = benchmark_2015(temp_pos, swarm.setting.func);
    
        swarm.particles.vel(select_index, :) = temp_vel;
        swarm.particles.pos(select_index, :) = temp_pos;
        swarm.particles.fit(select_index) = temp_fit;
    
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
    
        step = step + 1;
        record(step) = swarm.solution.best_fit;
        
        terminal_flag = terminal_conditions(record, step, iter_exploit_min, iter_exploit_max);
        if terminal_flag
            break
        end
          
        if plot_interval
            if mod(step, plot_interval) == 0
                disp(['exploit:', num2str(step),  ' best fit: ', num2str(swarm.solution.best_fit)]); 
            end
            if mod(step, plot_interval) == 0
                plot_2d(swarm);
            end
        end 
        
    end
    swarm_new = swarm;
end
    
function flag = terminal_conditions(record, step, iter_exploit_min, iter_exploit_max)
    global beta1;

    flag = 0;
    if step > iter_exploit_max
        flag = 1;
    end
    if evolution_rate(record, step, iter_exploit_max) < beta1
        flag = 1;
    end
    if step < iter_exploit_min
        flag = 0;
    end
end


function Er = evolution_rate(record, t, N)
    if N > 1000
        K = 50;
    else
        K = 10;
    end

    if t > K
        Er = (record(t-K) - record(t)) /  (K * record(t-1));
    elseif t == 1
        Er = 1;
    else
        Er = (record(1) - record(t)) / (t * record(t-1));
    end
end