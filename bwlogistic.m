function [W, Bmap, errList, bits] = bwlogistic(opt)
default_field(opt, 'learningRate', 0.02);
default_field(opt, 'batchsize', 20);
default_field(opt, 'iterations', 300);
default_field(opt, 'testCycle', 1000);
default_field(opt, 'iteration_console', true);
default_field(opt, 'l2reg', 0.01);
default_field(opt, 'initial_bitlength', 6);
default_field(opt, 'avg_bitlength_limit', 8);
default_field(opt, 'bit_offset', 2);
default_field(opt, 'sampling_function', @simple_bw_sampling);
X = opt.Xtrain;
Y = opt.Ytrain;
Xv = opt.Xval;
Yv = opt.Yval;


% Initialize some useful values
[total_sample_num, feature_dim] = size(X); % data: Nx(F-1)
feature_dim = feature_dim + 1;
bit_limit = opt.avg_bitlength_limit * feature_dim;
fprintf('Bit Limit for the system is %d, Parameter Num: %d\n', bit_limit, feature_dim);
W = rand(feature_dim, 1);  % Fx1
Bmap = repmat(opt.initial_bitlength, size(W));
W = cellfun(@(x) x(randi(2)), approx(W, Bmap, 0));
total_bitwidth = sum(sum(Bmap));
X = [X ones(total_sample_num, 1)]; % NxF
Xv =  [Xv ones(total_sample_num, 1)];
errList = [];
for iter=1:opt.iterations
    [indexes,len] = get_batch(total_sample_num, opt.batchsize,  iter);
    data = X(indexes,:);  % BxF
    label = Y(indexes);   % Bx1
    Z = data*W; %Bx1
    H = sigm(Z);  %Bx1
    %(1/B) * (1xB) * (BxF)
    grad = 1/len * (((H - label)'*data)' + opt.l2reg * W);  
    Wnew = W - opt.learningRate*grad;
    
    % save the sign of W, because sign bit doesn't affect approximation
    W_sign = sign(Wnew);
    W = abs(W);
    Wnew = abs(Wnew);
    
    % divide the W into integer part/floating part, only approximating the
    % floating part, but need to consider number carry
    [W_i_old, W_f_old] = num_parts(W);  
    [W_i_new, W_f_new] = num_parts(Wnew);            
    diff_W = Wnew-W;
    
    % get approximate version of floating part of W
    tmp_ = approx(W_f_new, Bmap, opt.bit_offset); 
    
    % sampling on {-2,-1,0,1,2} bit, base on approximation result and bit
    % width used.
    indexes = grid_sample(feval(opt.sampling_function, tmp_, diff_W, Bmap, total_bitwidth, bit_limit));
    
    % update W
    for i=1:size(indexes,1)
        for j=1:size(indexes,2)
            % row is a [1x2] array, for example approximate 0.62, row =
            % [0.65, 0.59], two approximation directions
            row = tmp_{i,j}(1:2,indexes(i,j));
            
            % if the W should go 0.60 -> 0.62, we should better take 0.65
            % instead of 0.59, which is the wrong gradient direction
            % this way we consider number carry. 
            sign_row_w = sign(W_i_new(i,j)+row-W_f_old(i,j)-W_i_old(i, j));
            direction = sign_row_w == sign(diff_W(i,j));
            
            % if both row[1],[2] has the correct direction,pick the closet
            % one
            if direction
                [~, tmpidx_] = min(abs(row-W_f_new(i,j)));
                v = row(tmpidx_);
            else 
                % else pick the right one
                v = row(direction == true);
                
                % this is the case that row[1] == row[2], pick either one.
                if isempty(v)               
                    v = row(1);
                end
            end               
            % update and add sign, keep the integer part. 
            W(i,j) = W_sign(i,j)*(v+W_i_new(i,j));
            
            % save the bit length of current value. 
            Bmap(i,j) = tmp_{i,j}(3,indexes(i,j));
        end
    end
    total_bitwidth = sum(sum(Bmap));
    
    if opt.iteration_console
        fprintf('Iteration %d,Size: %d, Error Rate: %.4f, Total Bitwidth: %d\n', iter,len,sum(abs((H>0.5)-label))/len, total_bitwidth);
    end
    if mod(iter, opt.testCycle) == 0
        Test = sigm(Xv*W)>0.5; 
        e =  sum(abs(Test-Yv))/length(Yv);
        errList(:, end+1) = [iter e total_bitwidth]; 
        fprintf('Validation => Error Rate: %.4f, Bit Use: %d\n', e, total_bitwidth);      
    end
end

[~, bit_int] = closest_powb(floor(max(max(abs(W)))), 2);
sign_bit = 1;
errList(3,:) = errList(3,:) + (bit_int+sign_bit)*feature_dim;
bits= [bit_int, ceil(total_bitwidth/feature_dim)];
end