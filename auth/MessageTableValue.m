classdef MessageTableValue < handle
    % MESSAGETABLEVALUE contains the value for the key value pair in the
    % reciever message table
    properties (Access = public)
        message
        verified
    end

    methods

        function obj = MessageTableValue(message)
            % constructs an instance of the class w verified initialized to false
            obj.message = message;
            obj.verified = false;
        end

    end
end
