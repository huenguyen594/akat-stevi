function A = Amatrix(depth, gamma)
% Create adjacency matrix for anisotropic diffusion
% Sintax:
%     A = Amatrix(depth, weight, gamma)
    
H = size(depth, 1);
npts = numel(depth);
x = 1:npts;
x = repmat(x, [5, 1]);
offset = repmat([-1; 1; -H; H; 0], [1, npts]);
y = x + offset;

isvalid = (y>0)&(y<npts+1);
isself = x==y;
isneigh = isvalid&~isself;
ishole = isself&(depth(x)==0);

W = -repmat(1./sum(isneigh), [5, 1]);
W(isself) = 1/gamma;
W(ishole) = 1;

A = sparse(x(isvalid), y(isvalid), W(isvalid));
end