addpath ./util
addpath ./sampling
clear
close all
clc
load ionosphere    
Y=cellfun(@(x) x == 'g', Y);
options.learningRate = 0.01;
options.batchsize = 20;
options.iterations = 3000;
options.testCycle = 100;
options.iteration_console = false;
options.l2reg = 0.01;
options.Xtrain = X;
options.Xval = X;
options.Ytrain = Y;
options.Yval = Y;
disp('## Standard Logistic Regression');
[W, elist] = stlogistic(options);
figure
subplot(2,2,1) 
plot(elist(1,:), elist(2,:),'-.b*');
xlabel('Iteration');
ylabel('Error rate');
legend( 'Standard Training');


options.initial_bitlength = 6;
options.avg_bitlength_limit = 6;
options.bit_offset = 2;
options.sampling_function = @simple_bw_sampling;
fprintf('\n\n## Bitwidth Constrained Logistic Regression\n');
[WB, Bmap, eblist, bit_num] = bwlogistic(options);
subplot(2,2,2);
plot(elist(1,:), eblist(2,:),'-.r*');
xlabel('Iteration');
ylabel('Error rate');
legend( 'Bitwidth Training');
subplot(2,2,[3 4]);
plot(eblist(3,:),'-.r*');
title('Bitwidth Usage on Training');
xlabel('Iteration');
ylim([100 500]);
ylabel('Bit Used');

bit_int = bit_num(1);
bit_float = bit_num(2);
fprintf('Average %d bit per Weight Value, 1 sign bit, %d interger bit, %d float bit. \n',1+bit_int+bit_float,bit_int,bit_float);
subtitle('Logistic Regression on Matlab Builtin DataSet Ionosphere');