function y = plot_2d(swarm, choose)

if nargin < 2
    choose = 'normal';
end

clf
if strcmp(choose, 'normal')
    t1 = swarm.particles.pos(:, 1);
    m1 = swarm.particles.pos(:, 2);

    plot(t1, m1, "r.")
    axis([swarm.setting.lb, swarm.setting.ub, swarm.setting.lb, swarm.setting.ub]);
    pause(0.1);
    
elseif strcmp(choose, 'search_swarm')
    N = length(swarm);
    color = ['r', 'g', 'b', 'c', 'm', 'y', 'k', 'w'];
    for index = 1:N
        t1 = swarm{index}.particles.pos(:, 1);
        m1 = swarm{index}.particles.pos(:, 2);
        plot(t1, m1, [color(index), '*'])
        hold on
    end
	axis([swarm{1}.setting.lb, swarm{1}.setting.ub, swarm{1}.setting.lb, swarm{1}.setting.ub]);
    pause(0.1);
    
else
    disp('input error')
end

