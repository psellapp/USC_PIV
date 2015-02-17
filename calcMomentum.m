function [momentum] = calcMomentum(uprof,y_val,Umean)
%
% Calculate momentum defect
% created: Prabu, 2/16/2015
%
% uprof - vector of u-vel profile
% y_val - vector of y locations
% Umean - mean U

momentum = 0;
n_y = length(y_val);
dy = y_val(2) - y_val(1);

for i = 1:n_y
    uU = Umean - uprof(i);
    uU = uU/Umean;
    momentum = momentum + ((uU - uU^2)*dy);
end

end