% Simulating the 1-D Diffusion equation (Fourier's equation) by the
...Finite Difference Method(a time march)
% Numerical scheme used is a first order upwind in time and a second order
...central difference in space (both Implicit and Explicit)
%%    
%%
%Specifying Parameters
nx=50;               %Number of steps in space(x)
nt=30;               %Number of time steps 
dt=.005;              %Width of each time step
dx=2/(nx-1);         %Width of space step
x=0:dx:2;            %Range of x (0,2) and specifying the grid points
u=zeros(nx,1);       %Preallocating u
un=zeros(nx,1);      %Preallocating un

dif=1;
vel=1;
kel=0;
rec=1;
eps=0.5;

alp = dif*dt/dx/dx;
bet = vel*dt/2/dx;
gam = kel*dt;

vis=0.01;            %Diffusion coefficient/viscosity
beta=vis*dt/(dx*dx); %Stability criterion (0<=beta<=0.5, for explicit)
UL=0.10;                %Left Dirichlet B.C
UR=0;                %Right Dirichlet B.C
UnL=0;               %Left Neumann B.C (du/dn=UnL) 
UnR=0;               %Right Neumann B.C (du/dn=UnR) 

%%
%Initial Conditions: A square wave
%  for i=1:nx
%      if ((0.75<=x(i))&&(x(i)<=1.25))
%          u(i)=2;
%      else
%          u(i)=1;
%      end
% end
u(10)=5;

%%
% %B.C vector
% bc=zeros(nx-2,1);
% %bc(1)=vis*dt*UL/dx^2; bc(nx-2)=vis*dt*UR/dx^2;  %Dirichlet B.Cs
% bc(1)=-UnL*vel*dt/dx; 
% bc(nx-2)=UnR*vel*dt/dx;  %Neumann B.Cs
% %Calculating the coefficient matrix for the implicit scheme
% E=sparse(2:nx-2,1:nx-3,1,nx-2,nx-2);
% A=E+E'-2*speye(nx-2);        %Dirichlet B.Cs
% A(1,1)=-1; A(nx-2,nx-2)=-1; %Neumann B.Cs
% D=speye(nx-2)-(vis*dt/dx^2)*A;

%%
%Calculating the velocity profile for each time step
i=2:nx-1;
for it=0:nt
    
    un=u;
    Ai=-eps*(alp+bet);
    Bi=1+eps*(2*alp+gam);
    Ci=-eps*(alp-bet);
    Di=zeros(nx,1);

    onesAi=ones(nx-1,1)*Ai;
    onesBi=ones(nx,1)*Bi;
    onesCi=ones(nx-1,1)*Ci;
    A=diag(onesBi)+diag(onesAi,-1)+diag(onesCi,+1);

    for i=2:nx-1
        Di(i,1)=(1-eps)*(alp+bet)*un(i-1,1)+(1-(1-eps)*(2*alp+gam))*un(i,1)+(1-eps)*(alp-bet)*un(i+1,1);
    end
    %% fixed B.C.
    A( 1, 1)=0;
    A( 1, 1+1)=0;
    A(nx, 1)=0;
    A(nx,nx-1)=0;


    %% Neumann reflecting B.C.   
    A( 1+1, 1+2)=A( 1+1, 1+2)+onesAi( 1+1,1);
    A(nx-1,nx-2)=A(nx-1,nx-2)+onesCi(nx-1,1);
    
    A(1,2)=0;
    A(2,1)=0;
    
    uL_flux=0;
    uR_flux=0;
    Di(1,1)=(+1-eps)*(alp+bet)*(un(1+1,1)-2*dx*uL_flux)...
        +(1-(1-eps)*(2*alp+gam))*un(1,1)...
           +(1-eps)*(alp+bet)*un(1+1,1);
   Di(nx,1)=(+1-eps)*(alp-bet)*(un(nx-1,1))...
        +(1-(1-eps)*(2*alp-gam))*un(nx,1)...
           +(1-eps)*(alp-bet)*un(nx,1)+2*dx*uR_flux;
    
    %A(nx,nx)=1;
    %A(nx,nx-1)=0;
    %A(nx-1,nx-2)=A(nx-1,nx-2)+onesCi(nx-1,1);
    %A(nx-1,nx)=0;
    %Di(nx-1,1)=Di(nx-1,1)-onesCi(nx-3,1)*2*dx*0;
    u=A\Di;
    sum(u)
    un=u;
    %bc=zeros(nx-2,1);
    %bc(1)=vis*dt*UL/dx^2; bc(nx-2)=vis*dt*UR/dx^2;  %Dirichlet B.Cs
    %bc(1)=.1;     bc(nx-2)=.1;  %Dirichlet B.Cs
    %UnL=-20;               %Left Neumann B.C (du/dn=UnL) 
    %UnR=+20;               %Right Neumann B.C (du/dn=UnR) 
    %bc(1)=-UnL*vis*dt/dx;    %Neumann B.Cs
    %bc(nx-2)=UnR*vis*dt/dx;  %Neumann B.Cs

    %UL=UL/(it+1);
    %u(10)=u(10)/(it+1);
    
    %un=u;
    h=plot(x,u);       %plotting the velocity profile
    axis([0 2 0 3])
    title({['1-D Diffusion with \nu =',num2str(vis),' and \beta = ',num2str(beta)];['time(\itt) = ',num2str(dt*it)]})
    xlabel('Spatial co-ordinate (x) \rightarrow')
    ylabel('Transport property profile (u) \rightarrow')
    drawnow; 
    refreshdata(h)
    %Uncomment as necessary
    %-------------------
    %Implicit solution
    
   % U=un;%U(1)=[];U(end)=[];
    %U=U+bc;
    %U=D\U;
    
    
    %u=[UL;U;UR];                      %Dirichlet
    %u=[U(1)-UnL*dx;U;U(end)+UnR*dx]; %Neumann
    %}
    %-------------------
    %Explicit method with F.D in time and C.D in space
    %{
    u(i)=un(i)+(vis*dt*(un(i+1)-2*un(i)+un(i-1))/(dx*dx));
    %}
end