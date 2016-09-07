function [ vp ] = approx( v, start_bit_n, offset_bit_n)
% tic; origin = rand([1000,1000]); app = approx( origin, 5, 3); toc; % test command
if abs(v) >= 1
    error('cloest_powb_int only accepts parameter < 1');
end
if offset_bit_n > start_bit_n 
    error('offset_bit_n > start_bit_n !');
end
    [s1,s2] = size(v);
    vp = cell(s1,s2);
    
    function rt = approx_(data, direction)           
        rt = zeros(1, length(bit_trails));
        if data == 0  %% if data is equal = 0, then just return
            return
        end
        d_sign = sign(data);
        data = abs(data);
        if direction == -1
            data = 1-data;
        end
        for i=1:length(bit_trails)
            b = bit_trails(i);
            data_ = data;
            app = 0;
            for val=(1/2).^(1:b)
                if data_ > val
                    data_ = data_ - val;
                    app = app + val;
                end
            end
            if direction == -1
                app = 1-app;
            end
            rt(i) = d_sign*app;
        end                             
    end
    for i1=1:s1
        for i2=1:s2
            bit_trails = start_bit_n(i1, i2)-offset_bit_n:start_bit_n(i1, i2)+offset_bit_n;
            bit_trails = bit_trails(bit_trails > 1);
            vp{i1, i2} = [approx_(v(i1,i2), 1); approx_(v(i1,i2), -1); bit_trails];
        end
    end  
end

