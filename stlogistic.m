function [W, errList] = stlogistic(opt)
default_field(opt, 'learningRate', 0.02);
default_field(opt, 'batchsize', 20);
default_field(opt, 'iterations', 300);
default_field(opt, 'testCycle', 1000);
default_field(opt, 'iteration_console', true);
default_field(opt, 'l2reg', 0.01);
X = opt.Xtrain;
Y = opt.Ytrain;
Xv = opt.Xval;
Yv = opt.Yval;

% Initialize some useful values
[total_sample_num, feature_dim] = size(X); % data: Nx(F-1)
feature_dim = feature_dim + 1;
W = rand(feature_dim, 1);  % Fx1
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
    % need regulization. 
    grad = 1/len * (((H - label)'*data)' + opt.l2reg * W);  %% full batch, need to modify it. and plus a regulerization here.  
    W = W - opt.learningRate*grad;
    if opt.iteration_console
        fprintf('Iteration %d,Size: %d, Error Rate: %.4f\n', iter,len,sum(abs((H>0.5)-label))/len);
    end
    if mod(iter, opt.testCycle) == 0
        Test = sigm(Xv*W)>0.5; 
        e =  sum(abs(Test-Yv))/length(Yv);
        errList(:, end+1) = [iter e];
        fprintf('Test => Error Rate: %.4f\n', e);      
    end
end
end