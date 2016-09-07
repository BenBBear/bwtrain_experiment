function [ P ] = simple_bw_sampling( bitsetup, diff_W, Bmap, bit_total, bit_limit)
%SIMPLE_BW_SAMPLING Summary of this function goes here
%   Detailed explanation goes here
P = cell(size(diff_W));
C = 4;
for i = 1:size(bitsetup, 1)
    for j = 1:size(bitsetup, 2)
        B = bitsetup{i,j}(3,:) - bitsetup{i,j}(3,1) + 1;
        B_norm = 1 + B/C;
        B_diff = bit_total - bit_limit;
        row = exp(-B_norm * sign(B_diff));        
        P{i,j} = row/sum(row);
    end
end

end

