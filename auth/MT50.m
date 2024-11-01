classdef (Abstract) MT50 < handle
    % MT50 Class related to storage, encoding, and decoding MT50 messages.

    properties (Access = public, Abstract = true)
        hash_point
    end

    methods (Abstract)

        message_bits = encode(obj)

    end

    methods (Abstract = true, Static = true)

        mt50 = decode(message)

    end
end
