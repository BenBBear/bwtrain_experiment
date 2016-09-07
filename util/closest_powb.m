function [value,bits] = closest_powb(v, base)
bits = round(logb(v, base));
value = base.^bits;

function y=logb(x,b)
if nargin < 2
    b = exp(1);
    return
    if ~isscalar(b) && ~ all(size(x)==size(b))
        error('LOGB: Base B must be a scalar, or must be the same size as X.');
    end
end
y = log(x)./log(b);
end
    
end

