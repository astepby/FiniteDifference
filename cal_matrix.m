sprintf('cal_matrix')          
flag_conv = 0;		           % convergence of the Poisson loop
k_iter= 0;
A=zeros(n_max,n_max);
P=zeros(n_max,1);

% % %     alpha(1) = b(1);
    for i=2:n_max-1
% % %         beta(i)=a(i)/alpha(i-1);
% % %         alpha(i)=b(i)-beta(i)*c(i-1);
        A(i,i)=b(i);
        A(i,i-1)=a(i);
        A(i,i+1)=c(i);
        P(i)=exp(fi(i))+exp(-fi(i));
    end
    
    A(1,1)=1;
    A(n_max,n_max)=1;
    F=A*fi'-f;
    J=A-diag(P);
    Y=J\F;
    
% Solution of Lv = f %    

    v(1) = f(1);
    for i = 2:n_max
        v(i) = f(i) - beta(i)*v(i-1);
    end
     
% Solution of U*fi = v %    

    temp = v(n_max)/alpha(n_max);
    delta(n_max) = temp - fi(n_max);
    fi(n_max)=temp;
    for i = (n_max-1):-1:1       %delta%
        temp = (v(i)-c(i)*fi(i+1))/alpha(i);
        delta(i) = temp - fi(i);
        fi(i) = temp;
    end
    
    delta_max = 0;
    
    for i = 1: n_max
        xx = abs(delta(i));
        if(xx > delta_max)
            delta_max=xx;
        end
        %sprintf('delta_max = %d',delta_max)      %'k_iter = %d',k_iter,'
        
    end

     %delta_max=max(abs(delta));
     
     
     if(delta_max < delta_acc)
        flag_conv = 1;
    else
        for i = 2: n_max-1
            b(i) = -(2/dx2 + exp(fi(i)) + exp(-fi(i)));
            f(i) = exp(fi(i)) - exp(-fi(i)) - dop(i) - fi(i)*(exp(fi(i)) + exp(-fi(i)));
        end
    end
