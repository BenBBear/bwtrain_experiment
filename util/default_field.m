function [ opt ] = default_field( opt, field, value )
%DEFAULT_FIELD Summary of this function goes here
%   Detailed explanation goes here
if ~isfield(opt, field)
   opt = setfield(opt, field, value);
end
end

