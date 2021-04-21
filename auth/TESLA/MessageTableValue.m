classdef MessageTableValue < handle
    properties
        message
        verified
    end

    methods

        function obj = MessageTableValue(message)
            obj.message = message;
            obj.verified = false;
        end

    end
end
