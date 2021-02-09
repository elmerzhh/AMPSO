function pos_new = disturbance_6(pos, swarm, sigma, choose)

    if strcmp(choose, 'r_dir')
        dr = normrnd(0,sigma,[1,swarm.setting.dim]);
        pos_new = pos + (swarm.setting.ub - swarm.setting.lb) * dr;
        
    elseif strcmp(choose, '1_dim')
        dim = randi(swarm.setting.dim);
        pos(dim) = pos(dim) + normrnd(0.0, sigma, [1,1]) * (swarm.setting.ub - swarm.setting.lb);
        pos_new = pos;
        
    elseif strcmp(choose, 'rand_dim')
        dim_num = randi(ceil(swarm.setting.dim / 5));
        for index = 1:dim_num
            dim = randi(swarm.setting.dim);
            pos(dim) = pos(dim) + normrnd(0.0, sigma, [1,1]) * (swarm.setting.ub - swarm.setting.lb);
        end
        pos_new = pos;
        
    else
        disp('input error')
    end
            