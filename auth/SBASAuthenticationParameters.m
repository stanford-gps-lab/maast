classdef SBASAuthenticationParameters
    % SBASAUTHENTICATIONPARAMETERS Class for passing SBAS Authentication
    % Scheme Parameters

    properties
        level_1_crypto_period_s = 60480006
        level_2_crypto_period_s = 6048006
        hash_path_length = 100801
        next_set_frequency = 12
    end

    methods

        function obj = SBASAuthenticationParameters(level_1_crypto_period_s, ...
                                                    level_2_crypto_period_s, ...
                                                    hash_path_length,  ...
                                                    next_set_frequency ...
                                                   )
            % SBASAUTHENTICATIONPARAMETERS Construct an instance of this class

            switch nargin
                case 0
                case 4
                    if ~isempty(level_1_crypto_period_s)
                        obj.level_1_crypto_period_s = level_1_crypto_period_s;
                    end

                    if ~isempty(level_2_crypto_period_s)
                        obj.level_2_crypto_period_s = level_2_crypto_period_s;
                    end

                    if ~isempty(hash_path_length)
                        obj.hash_path_length = hash_path_length;
                    end

                    if ~isempty(next_set_frequency)
                        obj.next_set_frequency = next_set_frequency;
                    end
                otherwise
                    error('SBASAuthenticationParameters:badConstructorArgs', 'Invalid number of constructor args.');
            end

        end

    end
end
