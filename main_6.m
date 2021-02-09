
clc, clear, close all
rng('shuffle');
global plot_interval;
global vel_percent;
global Ner;
global alpha1;
global alpha2;
global alpha3;
global beta1;

SIZE = 20;
DIM = 10;

Ner = 5; % the number of particles in every sub-swarm of exploration swarm
plot_interval = 0;
vel_percent = [0.01, 0.01, 0.01];
alpha1 = 0.02; % control N1      
alpha2 = 0.2; % control N2
alpha3 = 0.25; % control Ns
beta1 = 0.001;

FUNC_LIST = 15;
RUN_TIMES = 30;
record = zeros(FUNC_LIST, RUN_TIMES);
% parpool('local')
for func_num = 1:FUNC_LIST
    for run = 1:RUN_TIMES
        disp(['Func: ', num2str(func_num), '  Run: ', num2str(run)]);
        record(func_num, run) = main(func_num, SIZE, DIM);
    end
end
% save([num2str(DIM), 'D_', num2str(SIZE), 'SIZE_AMPSO_2015.mat'], 'record');


function best_fit = main(FUNC, SIZE, DIM)
    global alpha1;
    global alpha2;
    
    LB = -100;
    UB = 100;
    fes_max = DIM * 10000;
    Ntotal = ceil(fes_max / SIZE);
    
    swarm = init_6(FUNC, SIZE, DIM, LB, UB);
    search_swarms = swarm{1}; exploit_swarm = swarm{2}; convergence_swarm = swarm{3};
    
    Ni = 0; epoch = 0; 
    % search coefficient
    N1 = alpha1 * Ntotal;   N2 = alpha2 * Ntotal;
    swarm2_fit = Inf;   swarm2_pos = zeros(1, DIM);
    while Ni < ceil(Ntotal / 3)
        search_swarms = swarm1_6(search_swarms, N1);
        Ni = Ni + N1 + 1;
        swarm1_fit = Inf;   swarm1_pos = zeros(1, DIM);
        for index = 1:length(search_swarms)
            if search_swarms{index}.solution.best_fit < swarm1_fit
                swarm1_fit = search_swarms{index}.solution.best_fit;
                swarm1_pos = search_swarms{index}.solution.best_pos;
            end
        end

        [exploit_swarm, step_exploit] = swarm2_6(exploit_swarm, swarm1_pos, N1, N2);
        Ni = Ni + step_exploit + 1;
        if exploit_swarm.solution.best_fit < swarm2_fit
            swarm2_fit = exploit_swarm.solution.best_fit;
            swarm2_pos = exploit_swarm.solution.best_pos;
        end

        epoch = epoch + 1;
        % disp(['epoch:', num2str(epoch)]);
    end
    
    remain_Ni = Ntotal - Ni;
    convergence_swarm = swarm3_6(convergence_swarm, swarm2_pos, remain_Ni);
    % disp(['the best fit: ', num2str(convergence_swarm.solution.best_fit)]);
    % convergence_swarm.solution.best_pos
    best_fit = convergence_swarm.solution.best_fit;
    % best_pos = convergence_swarm.solution.best_pos;
end