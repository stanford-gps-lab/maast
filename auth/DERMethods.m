classdef DERMethods
    % Class DERMethods contains all methods pertaining to
    % Distinguished Encoding Rules (DER) and converting them to naked
    % formats without the DER headers.

    properties (Constant, Access = protected)
        DER_ECDSA256_PK_HEADER = uint8([48; 89; 48; 19; 6; 7; 42; 134; 72; 206; 61; 2; 1; 6; 8; 42; 134; 72; 206; ...
                                        61; 3; 1; 7; 3; 66; 0; 4])
    end

    methods (Static, Access = public)

        function public_key = DER2PK(der_key, key_type)
            % strips DER key of all headers and outputs naked public
            % key  [r; s]
            switch key_type
                case "ECDSA256"
                    if ~all(der_key(1:27) == DERMethods.DER_ECDSA256_PK_HEADER)
                        error('DERMethods:DER2PK:BadHeader', 'Input header was not expected.');
                    end
                    public_key = der_key(28:end);
                otherwise
                    error('DERMethods:DER2PK:BadKeyType', 'Key type %s not implemented.', key_type);
            end
        end

        function der_key = PK2DER(public_key, key_type)
            % assembles DER signature from naked public key
            switch key_type
                case "ECDSA256"
                    if length(public_key) ~= 64
                        error('DERMethods:PK2DER:BadPublicKey', 'Input public key invalid.');
                    end
                    der_key = [DERMethods.DER_ECDSA256_PK_HEADER; public_key];
                otherwise
                    error('DERMethods:PK2DER:BadKeyType', 'Key type %s not implemented.', key_type);
            end
        end

        function public_signature = DER2SIG(der_signature, key_type)
            % strips DER signature of all headers and outputs naked public
            % key signature [r; s]

            switch key_type
                case "ECDSA256"
                    if der_signature(1) ~= uint8(48)
                        error('DERMethods:DER2SIG:BadSignature', 'Input signature not valid.');
                    end

                    der_signature = der_signature(3:end);

                    public_signature = [];
                    for i = 1:2
                        if der_signature(1) ~= uint8(2)
                            error('DERMethods:DER2SIG:BadSignature', 'Input signature not valid.');
                        end

                        switch der_signature(2)
                            case uint8(32)
                                start_index = 3;
                                end_index = 34;
                            case uint8(33)
                                start_index = 4;
                                end_index = 35;
                            otherwise
                                error('DERMethods:DER2SIG:BadSignature', 'Input signature not valid.');
                        end
                        integer = der_signature(start_index:end_index);
                        public_signature = [public_signature; integer]; %#ok two loops ok
                        der_signature = der_signature(end_index + 1:end);
                    end

                otherwise
                    error('DERMethods:DER2SIG:BadKeyType', 'Key type %s not implemented.', key_type);
            end
        end

        function der_signature = SIG2DER(signature, key_type)
            % assembles DER signature from naked public key signature

            switch key_type
                case "ECDSA256"
                    if length(signature) ~= 64
                        error('DERMethods:SIG2DER:BadPublicKey', 'Input public key invalid.');
                    end
                    der_signature = uint8([48; 0]);
                    total_size = 0;
                    for i = 1:2
                        integer = signature(1:32);
                        if integer(1) < 128
                            der_signature = [der_signature; uint8(2); uint8(32); integer]; %#ok two loops ok
                            total_size = total_size + uint8(32);
                        else
                            der_signature = [der_signature; uint8(2); uint8(33); uint8(0); integer]; %#ok two loops ok
                            total_size = total_size + uint8(33);
                        end
                        signature = signature(33:end);
                    end
                    der_signature(2) = total_size + uint8(4);
                otherwise
                    error('DERMethods:SIG2DER:BadKeyType', 'Key type %s not implemented.', key_type);
            end
        end

    end
end
