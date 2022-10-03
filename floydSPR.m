function [ D,R ] = floydSPR( a )
%find the shortest path from all src to all dst
%a: graph matrix 
%D: distance matrix
%R: shortest path matrix
n = size(a,1);
D = a;
R = zeros(n,n);

for i=1:n
    for j=1:n
        if D(i,j)~=inf
            R(i,j)=j;
        end
    end
end

for k=1:n
    for i=1:n
        for j=1:n
            if D(i,k)+D(k,j)<D(i,j)
                D(i,j)=D(i,k)+D(k,j);
                R(i,j)=R(i,k);
            end
        end
    end
end

end

