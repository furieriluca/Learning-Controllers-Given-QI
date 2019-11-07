%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION :
%       Numerical example of Section III.B attached to the paper: 
%       
%       "First Order Methods For Globally Optimal Distributed Controllers Beyond Quadratic Invariance"
%        by Luca Furieri (furieril@control.ethz.ch) and Maryam Kamgarpour
%        (mkamgar@control.ee.ethz.ch)

% This file validates the result of "QI_descent.m" by solving the
% corresponding convex program in the Youla parameter.
%%%%%%%%%%%%%%%%%%



clear all;
clc;

create_system_2

Q=sdpvar(m*N,p*N,'full');
Q=Q.*struct;


%COST in Q
w_x_cost=M_b^0.5*(eye(size(P12,1))+P12*Q*C_b)*P11*Sigmaw_b^0.5;
w_u_cost=R_b^0.5*Q*C_b*P11*Sigmaw_b^0.5;
v_x_cost=M_b^0.5*P12*Q*Sigmav_b^0.5;
v_u_cost=R_b^0.5*Q*Sigmav_b^0.5;
x0_x_cost=M_b^0.5*(eye(size(P12,1))+P12*Q*C_b)*P11*mu_w;
x0_u_cost=R_b^0.5*Q*C_b*P11*mu_w;


cost=trace(w_x_cost'*w_x_cost)+trace(w_u_cost'*w_u_cost)+trace(v_x_cost'*v_x_cost)+trace(v_u_cost'*v_u_cost)+x0_x_cost'*x0_x_cost+x0_u_cost'*x0_u_cost;

ops=sdpsettings('solver','mosek'); %also works with quadprog
sol=optimize([], cost, ops) 

optimal_value=value(cost)

Q_opt=value(Q);
K_opt=Q_opt*inv(eye(size(C_b,1))+C_b*P12*Q_opt)
