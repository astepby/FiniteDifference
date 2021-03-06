%clear screen
clc
format long
 
%constants
eps0 = 8.85418782e-12;	
q = 1.60217646e-19;
 
%setup coefficients
den0=1e9;
phi0=0;
kbT=0.0259;
 
%precomputed values
%lambda_D = sqrt(eps0*kbT/(den0*q));	%for kbT  in eV
%dx = lambda_D;				%cell spacing
dx=1e-7;
Cn = -q/eps0*dx*dx;
Cp = +q/eps0*dx*dx;

%setup matrixes
nn=501;			%number of nodes
A=zeros(nn,nn);
fixed_node = zeros(nn,1);
b0=zeros(nn,1);
 
%left boundary
A(1,1)=1;
b0(1)=-.5;
fixed_node(1)=1;
 
%right boundary
A(nn,nn)=1;
b0(nn)=+.5;
fixed_node(nn)=1;
 
%internal nodes
for n=2:nn-1
	%FD stencil
	A(n,n-1)=1;
	A(n,n)=-2;
	A(n,n+1)=1;
 
	fixed_node(n)=false;
	b0(n)=Cn*den0 + Cp*den0;
    
end
 
%initial values
bx = zeros(nn,1);
P = zeros(nn,1);
J = zeros(nn,nn);
x = zeros(nn,1);
y = zeros(nn,1);
 
%--- Newton Solver ----
for it=1:1000
 
	%1) compute bx
	for n=1:nn
		if (fixed_node(n))
			bx(n)=0;
		else
			bx(n) = -Cn*den0*exp(+(x(n)-phi0)/kbT)...
                    -Cp*den0*exp(-(x(n)-phi0)/kbT);
		end
	end
 
	%2) b=b0+bx
	b = b0 + bx;
 
	%3) F=Ax-b
	F = A*x-b;
 
	%4) compute P=dbx(i)/dx(j), used in computing J
	for n=1:nn
		if (fixed_node(n))
			P(n)=0;
		else
			P(n) = -Cn*den0*exp(+(x(n)-phi0)/kbT)/kbT...
                   -Cp*den0*exp(-(x(n)-phi0)/kbT)/kbT;
		end
	end
 
	%5) J=df(i)/dx(j), J=A-diag(dbx(i)/dx(j))
	J = A - diag(P);
 
	%6) Solve Jy=F
	y = J\F;
 
	%7) update x
	x = x - 2*y;
 
	%8) compute norm;
	l2 = norm(y);
	if (l2<1e-6)
		disp(sprintf("Cnonverged in %d iterations with norm %g\n",it,l2));	
		break;
	end
end
disp(sprintf("The end of it"));	
 
%disp(x');
xline=linspace(0,1,nn)*dx*nn;
figure(1)
plot(xline,x);
hold on
%figure(2)
N=Cn*den0*exp((x-phi0)/kbT)/kbT;
P=Cp*den0*exp((x+phi0)/kbT)/kbT;
N(1)=0;
N(end)=0;
P(1)=0;
P(end)=0;
plot(xline,N*1)
plot(xline,P*1)
%plot(linspace(0,1,nn)*dx,Cn*den0*exp((x-phi0)/kbT)/kbT)
%plot(linspace(0,1,nn)*dx,Cp*den0*exp((x+phi0)/kbT)/kbT)

hold off