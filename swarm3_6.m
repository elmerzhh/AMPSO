function swarm_new = swarm3_6(swarm, original_pos, remain_Ni)

    % swram:    setting(fhd, func, size, dim, lb, ub, v_max, 
    %                   v_min, w, c1, c2, sigma, diversity),   % diversity denote diversity_expected
    %           particles(pos, vel, fit, best_pos, best_fit), 
    %           solution(best_pos, best_fit, best_index)
    
    global plot_interval;
    global beta1;
    
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
    % disp(['best generated fit:  ', num2str(swarm.solution.best_fit)])
    
    %% iteration
    step = 1; t0 = 0; t1 = 0; not_upgrade = 0;
    record = zeros(1, ceil(remain_Ni+1));
    record(1) = swarm.solution.best_fit;
    while step < remain_Ni
        % update coefficient
        % Et = [0, 1]
        w_range = [0.5, 0.8]; 
        swarm.setting.c1 = 1.49445;
        swarm.setting.c2 = 1.49445;
        sigma_range = [0.1, 0.2];
        swarm = update_coe_6(swarm, w_range, sigma_range);
%         swarm.setting.sigma = sigma_range(2)-step*(sigma_range(2)-sigma_range(1)) / ceil(remain_Ni+1);
% %         
%         pc = 0.1 / (1 + exp(0.05*(50 - not_upgrade)));
        pc = 1.0 / (1 + exp(25 - not_upgrade));

        if rand < pc
            t0 = t0 + 1;  
            not_upgrade = 0;
            % rebuild swarm
            position = zeros(swarm.setting.size, swarm.setting.dim);
            for index = 1:swarm.setting.size
                position(index, :) = disturbance_6(swarm.solution.best_pos, swarm, swarm.setting.sigma, '1_dim');
            end
            position = max(swarm.setting.lb, min(swarm.setting.ub, position));
            swarm.particles.pos = position;
            swarm.particles.fit = benchmark_2015(position, swarm.setting.func);
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
        
        else
            t1 = t1 + 1;
            % delta = normrnd(0,0.1^3,[swarm.setting.size,swarm.setting.dim]);

            temp_vel = (swarm.setting.w * swarm.particles.vel) ...
                +(swarm.setting.c1*rand(swarm.setting.size,swarm.setting.dim).*(swarm.particles.best_pos-swarm.particles.pos)) ...
                +(swarm.setting.c2*rand(swarm.setting.size,swarm.setting.dim).*(ones(swarm.setting.size,1)*swarm.solution.best_pos-swarm.particles.pos));

%             for index = 1:swarm.setting.size
%                 flag = 1;
%                 for index_j = 1:swarm.setting.dim
%                     if temp_vel(index, index_j)~=0
%                         flag = 0;
%                     end
%                 end
%                 if flag==1
%                     temp_vel(index, :) = mean(temp_vel);
%                 end
%             end

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
    
            [~, min_index] = min(swarm.particles.best_fit);
            swarm.solution.best_pos = swarm.particles.best_pos(min_index, :);
            swarm.solution.best_fit = swarm.particles.best_fit(min_index);
            swarm.solution.best_index = min_index;
        end
    
    
        step = step + 1;
        record(step) = swarm.solution.best_fit;

        Er = evolution_rate(record, step, remain_Ni);
        if Er < beta1
            not_upgrade = not_upgrade + 1;
        else
            not_upgrade = 0;
        end
        
        if plot_interval
            if mod(step, plot_interval) == 0
                disp(['t0: ', num2str(t0), '    t1: ', num2str(t1)]);
                disp(['convergence:', num2str(step),  ' best fit: ', num2str(swarm.solution.best_fit)]); 
            end
            if mod(step, plot_interval) == 0
                plot_2d(swarm);
            end
        end      
    swarm_new = swarm;
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