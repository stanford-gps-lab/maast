classdef RunAuthenticationDemos < matlab.unittest.TestCase
    % Runs the Authentication Demos

    methods (Test)

        function test_read_in_demo(~)
            demo_authentication_read_public;
        end

    end
end
