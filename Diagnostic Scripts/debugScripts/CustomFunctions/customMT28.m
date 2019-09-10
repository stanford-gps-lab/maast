function [] = customMT28(obj)
mt28 = -1*ones(4); mt28 = {mt28};
obj.MT28 = repmat(mt28, [obj.NumSats, length(obj.t)]);
end