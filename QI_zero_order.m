%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Learning distributed controllers given QI.
%% Luca Furieri, Yang Zheng
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all;
clc;

QI_convexprogram;  %% solves the program with convex programming, so that we know the optimal cost and solution
optimal_cost = value(cost); %%%optimal cost

%ORACLE SETUP
create_system_2;  %%creates the dynamical system,
create_cost;    %%sets up the symbolic cost. Not used later
eval_cost = matlabFunction(cost,'Vars',{vec_K}); %%





parameters = 1*[5;-5;0]%[1.38+1;-1.6;1.40];%10*(rand(cardinality,1)-rand(cardinality,1)); 
parameters_initial = parameters; %%% chooses initial parameters
fprintf('Starting the learning...from a cost of %d\n',eval_cost(parameters_initial))






rounds_max = 10;  %%we take the average of steps needed to achieve accuracy eps over rounds_max runs

epsilons = round(logspace(log10(0.5),log10(2),10),1) %% creates a logarithmic space of precisions
for(i = 1:size(epsilons,2))
    epsilons(i) = 1/epsilons(i);
end


parameters_success = zeros(cardinality,rounds_max,size(epsilons,2));



countnans = 0;  %%counter for divergent runs
countoutside = 0; %% counter for runs where the iterates exit G0

for(precisions = 1:size(epsilons,2))
    
    eps = epsilons(precisions);  %chooses the precision
    fprintf('\n\n\n***NEW PRECISION*** :%d\n',eps)
    
    eta = 1*0.000050*eps^2; %115% %% stepsize (goes with eps^2)
    r = 0.050*sqrt(eps);   %% smoothing radius (goes with sqrt(eps) )
    T = 100/eta;  %%high number of maximum steps
    samples_number = 1;  %%mini-batch size
    
    %% eta2=4*0.000115, eta1.5= . , eta1=0.000115, eta0.5=0.000115/2
    
    
    
    window = 5000;  %% to monitor the progress in long runs, we will print the average of the real cost over the past "window" iterates
    running_window = 100;
    
    last_iterates_running = zeros(1,running_window);
    
    real_expected_cost = 0;
    mean = 0;
    variance = 0; %%%to be implented
    Taverage = 0;
    for(rounds = 1:rounds_max)
        fprintf('\n\nStarting round %d of precision %d\n',rounds,eps)
        while(i<=T)
            
            
            grad_estimate = zeros(cardinality,1);
            for(samples = 1:samples_number)
                sample_cost; %%we sample the noisy cost to get cost_sample and U
                expected_cost_evaluated = eval_cost(parameters);                             
                grad_estimate = grad_estimate+cost_sample*U;  %gradient estimate
                
                real_expected_cost  =  real_expected_cost + expected_cost_evaluated; %this keeps track of the real costs for monitoring purposes
            end
            grad_estimate = grad_estimate*cardinality/r^2/samples_number; %correctly scaled gradient estimate
            
            mean = mean + (expected_cost_evaluated-last_iterates_running(1))/running_window;  %%Keeps track of the last running_window steps and its mean value. To be used as a stopping criterion
            last_iterates_running = circshift(last_iterates_running,-1);
            last_iterates_running(end) = expected_cost_evaluated;
            
            
            
            
            parameters = parameters-eta*grad_estimate;  %%STEP
            
            if(isnan(parameters)~=[0;0;0])  %%if diverges... restart the round
                countnans = countnans+1;
                fprintf('!!!!NAN!!! reset the round\n')
                fprintf('RE-Starting round %d of precision %d\n',rounds,eps)
                i = 1;
                parameters = parameters_initial;
                real_expected_cost = 0;
                mean = 0;
                last_iterates_running = zeros(1,running_window);
            elseif((eval_cost(parameters)-optimal_cost)>10*(eval_cost(parameters_initial)-optimal_cost)) %%if it goes outside G0... restart the round
                countoutside = countoutside+1;
                fprintf('!!!!!!Went outside G0!!!!!!\n')
                fprintf('RE-Starting round %d of precision %d\n',rounds,eps)
                i = 1;
                parameters = parameters_initial;
                real_expected_cost = 0;
                mean = 0;
                last_iterates_running = zeros(1,running_window);
            end
            
            
            
            if(mod(i,window)==0) %%%print the progress every window-th step
                real_expected_cost =  real_expected_cost/window/samples_number;
                real_expected_cost
                real_expected_cost = 0;
            end
            
            if(mean-optimal_cost<eps && i> running_window) % if before time T we enter the precision requirement ON AVERAGE OVER A WINDOW... we end the run.
                fprintf('entered precision bound at step %d \n',i)
                Tmax = i;
                parameters_success(:,rounds,precisions) = parameters;
                break;
            end
            i = i+1;
        end
        i = 1;
        mean = 0;
        last_iterates_running = zeros(1,running_window);
        %variance = 0;
        Taverage = Taverage+Tmax;
        parameters = parameters_initial;
    end
    Taverages(precisions) = Taverage/rounds_max %% average steps needed over rounds_max runs
end

figure(1)
loglog(epsilons,Taverages,'-s')
grid on
%fprintf('DONE!\n')
%final_cost=eval_cost(parameters)
%initial_cost=eval_cost(parameters_initial)





