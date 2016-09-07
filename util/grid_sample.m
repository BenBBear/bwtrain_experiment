function [ indexes ] = grid_sample( P )
indexes = zeros(size(P));
for i = 1:size(P,1)
    for j = 1:size(P,2)
        indexes(i,j) = discretesample(P{i,j}, 1);
    end
end
end

