
%%Linear system definition

A =  [1 2;-1 -3];


n=size(A,1);
B = eye(2);

C = eye(2);

m=size(B,2);
p=size(C,1);

N=2; 
mu0=[0;1];

x0a=-2;
x0b=1;
wa=-2;
wb=1;
va=-2;
vb=1;

Sigmax0=eye(n)*1/3*(x0a^2+x0b^2+x0a*x0b);
Sigmaw=eye(n)*1/3*(wa^2+wb^2+wa*wb);
Sigmav=eye(p)*1/3*(va^2+vb^2+va*vb);



%%Stacked operator definition. "_b" stands for bold notation in the paper 
A_b=kron(eye(N+1),A);
B_b=[kron(eye(N),B);zeros(n,m*N)];
C_b=[kron(eye(N+1),C)];
Z=zeros(n*(N+1),n*(N+1));
for(i=1:N+1)
        for(j=1:N+1)
                if(i==j+1)
                        Z([(i-1)*n+1:i*n],[(j-1)*n+1:j*n])=eye(n);
                end
        end
end


P11=round(inv(eye(n*(N+1))-Z*A_b),3);
P12=round(inv(eye(n*(N+1))-Z*A_b)*Z*B_b,3);


Sigmaw_b=blkdiag(Sigmax0,kron(eye(N),Sigmaw));
Sigmav_b=kron(eye(N+1),Sigmav);
mu_w=[mu0;zeros(N*n,1)];



%%Cost function parameters
M=1*eye(p);
R=1*eye(m);
M_b=kron(eye(N+1),M);
R_b=kron(eye(N),R);



%INFO STRUCTURE

syms a b;
assume(a,'real');
assume(b,'real');
K = [a 0 0 0 0 0;0 b 0 0 0 0;0 0 a 0 0 0;0 0 0 b 0 0]


%%%stacking the non-zero decision variables into a single vector
%vec_K=[a;b];

%OutputCost_create_cost;
%cost = vpa(cost,2);
%H = vpa(hessian(cost),2);

%%optimize directly
%sdpvar a b;
%cost = 4.0*a^4 + 8.0*a^3 + 28.0*a^2 + 18.0*a*b - 38.0*a + 6.0*b^4 - 42.0*b^3 + 149.0*b^2 - 216.0*b + 172.0;
%ops=sdpsettings('solver','mosek'); %also works with quadprog
%sol=optimize([], cost, ops) 




