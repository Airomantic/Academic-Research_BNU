function [mu,sigma,idx,r]=EM(x,k)
% Expectation Maximization 
% This function is written based on the EM algorithm in Bishop's Book to
% solve Gaussian Mixture Models.
% x : input data, n x d , n: number of samples and d: number of features 
% k : number of clusters
%
% mu: centers for clusters
% sigma: Covariance
% idx: cluster labels
% r: posterior probabilities
% Copyright 2009, Ali Bahramisharif  http://www.cs.ru.nl/~ali/
% This code is free to change, use and re-distribute.


%start of the code.
%initialization with Kmeans
[idx,mu] = kmeans(x,k);

[n,nf]=size(x);
r=rand(n,k);
r=r./repmat(sum(r,2),[1 k]);

p=zeros(k,1);
sigma=rand(k,nf,nf);
count=0;
% to prevent running the algorithm forever
while count<1e4
    count=count+1;
    mup=mu;

    % Maximization
    N=sum(r(:,:),1);
    for i=1:k
        mu(i,:)=sum(repmat(r(:,i),1,nf).*x)/N(i);
        x2=x-repmat(mu(i,:),n,1);
        sigma(i,:,:) = 1e-9*eye(nf)+(repmat(r(:,i),1,nf).*x2)'*x2/N(i);
        p(i)=N(i)/n;
    end
    
    %condition of convergence
    if sum((mup-mu).^2)<1e-15
        dis=zeros(n,k);
        for i=1:k
            dis(:,i)=sum(abs(x-repmat(mu(i,:),n,1)),2);
        end
        for i=1:n
            [ig idx(i)]=min(dis(i,:));
        end
        return
    end

    % Expectation
    for j=1:k
        r(:,j)=p(j)*normal(x,mu(j,:),sigma(j,:,:));
    end
    r=r./repmat(sum(r,2),[1 k]);

end

%algorithm is not converged
disp(sprintf('maximum number of iterations is reached'))
dis=zeros(n,k);
for i=1:k
    dis(:,i)=sum(abs(x-repmat(mu(i,:),n,1)),2);
end
for i=1:n
    [ig idx(i)]=min(dis(i,:));
end

return



function val=normal(x,mu,sigma)
% x    : n x d; n data points and d features
% mu   : 1 x d; for each cluster
% sigma: 1 x d x d ; for each cluster

[n,nf] = size(x);
sigma=squeeze(sigma);
x = x - repmat(mu,n,1);
val = exp(-0.5*sum((x*inv(sigma)).*x, 2)) / sqrt((2*pi)^nf*abs((1e-10)+det(sigma)));
return

