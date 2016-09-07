function [ indexes, len] = get_batch(total_num, batchsize, bid )

start_idx = max(mod((bid-1)*(batchsize)+1, total_num), 1);
end_idx = min(start_idx + batchsize - 1, total_num);
indexes = start_idx:end_idx;
len = end_idx - start_idx + 1;
end

