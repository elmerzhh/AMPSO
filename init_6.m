function swarm = init_6(FUNC, SIZE, DIM, LB, UB)
    % vel_percent = [0.01, 0.01, 0.01] 
    % swarm structures: setting, solution, particles, 
    
    global vel_percent;
    global Ner;
    
    swarm = cell(1,3);
    N = ceil(SIZE / Ner);
    swarm{1} = cell(1,N);
    for index = 1:N 
        swarm{1}{index}.setting =  struct('func', FUNC, 'size', Ner, 'dim', DIM, ...
            'lb', LB, 'ub', UB, 'v_max', (UB-LB)*vel_percent(1), ...
            'w', 2.0, 'c1', 1.49445, 'c2', 1.49445, 'sigma', 0.0);
    end
    swarm{2}.setting = struct('func', FUNC, 'size', SIZE, 'dim', DIM,...
        'lb', LB, 'ub', UB, 'v_max', (UB-LB)*vel_percent(2), ...
        'w', 2.0, 'c1', 1.49445, 'c2', 1.49445, 'sigma', 0.0);
    swarm{3}.setting = struct('func', FUNC, 'size', SIZE, 'dim', DIM,...
        'lb', LB, 'ub', UB, 'v_max', (UB-LB)*vel_percent(3), ...
        'w', 2.0, 'c1', 1.49445, 'c2', 1.49445, 'sigma', 0.0);
    
    
    for index = 1:N 
        swarm{1}{index}.particles.pos = rand(swarm{1}{index}.setting.size, swarm{1}{index}.setting.dim) ...
            * (swarm{1}{index}.setting.ub - swarm{1}{index}.setting.lb) + swarm{1}{index}.setting.lb;
        swarm{1}{index}.particles.vel = (rand(swarm{1}{index}.setting.size, swarm{1}{index}.setting.dim)...
            * 2 - 1) * swarm{1}{index}.setting.v_max;
        swarm{1}{index}.particles.fit = benchmark_2015(swarm{1}{index}.particles.pos, swarm{1}{index}.setting.func);
        swarm{1}{index}.particles.best_pos = swarm{1}{index}.particles.pos;
        swarm{1}{index}.particles.best_fit = swarm{1}{index}.particles.fit;
    
        [~, min_index] = min(swarm{1}{index}.particles.best_fit);
        swarm{1}{index}.solution.best_pos = swarm{1}{index}.particles.best_pos(min_index, :);
        swarm{1}{index}.solution.best_fit = swarm{1}{index}.particles.best_fit(min_index);
        swarm{1}{index}.solution.best_index = min_index;
    end
    
    
    for index = 2:3            
        swarm{index}.particles.pos = rand(swarm{index}.setting.size, swarm{index}.setting.dim) ...
            * (swarm{index}.setting.ub - swarm{index}.setting.lb) + swarm{index}.setting.lb;
        swarm{index}.particles.vel = (rand(swarm{index}.setting.size, swarm{index}.setting.dim)...
            * 2 - 1) * swarm{index}.setting.v_max;
        swarm{index}.particles.fit = benchmark_2015(swarm{index}.particles.pos, swarm{index}.setting.func);
        swarm{index}.particles.best_pos = swarm{index}.particles.pos;
        swarm{index}.particles.best_fit = swarm{index}.particles.fit;
        
        [~, min_index] = min(swarm{index}.particles.best_fit);
        swarm{index}.solution.best_pos = swarm{index}.particles.best_pos(min_index, :);
        swarm{index}.solution.best_fit = swarm{index}.particles.best_fit(min_index);
        swarm{index}.solution.best_index = min_index;
    end
    