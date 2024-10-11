classdef DERMethods
    % Class DERMethods contains all methods pertaining to
    % Distinguished Encoding Rules (DER) and converting them to naked
    % formats without the DER headers.

    properties (Constant, Access = protected)
        DER_ECDSA256_PK_HEADER = uint8([48; 89; 48; 19; 6; 7; 42; 134; 72; 206; 61; 2; 1; 6; 8; 42; 134; 72; 206; ...
                                        61; 3; 1; 7; 3; 66; 0; 4])
        DER_ECDSA384_PK_HEADER = uint8([48; 118; 48; 16; 6; 7; 42; 134; 72; 206; 61; 2; 1; 6; 5; 43; 129; 4; 0; ...
                                        34; 3; 98; 0; 4])
        DER_ECDSA521_PK_HEADER = uint8([48; 129; 155; 48; 16; 6; 7; 42; 134; 72; 206; 61; 2; 1; 6; 5; 43; 129; ...
                                        4; 0; 35; 3; 129; 134; 0; 4])
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
                case "ECDSA384"
                    if ~all(der_key(1:24) == DERMethods.DER_ECDSA384_PK_HEADER)
                        error('DERMethods:DER2PK:BadHeader', 'Input header was not expected.');
                    end
                    public_key = der_key(25:end);
                case "ECDSA521"
                    if ~all(der_key(1:26) == DERMethods.DER_ECDSA521_PK_HEADER)
                        error('DERMethods:DER2PK:BadHeader', 'Input header was not expected.');
                    end
                    public_key = der_key(27:end);
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
                case "ECDSA384"
                    if length(public_key) ~= 96
                        error('DERMethods:PK2DER:BadPublicKey', 'Input public key invalid.');
                    end
                    der_key = [DERMethods.DER_ECDSA384_PK_HEADER; public_key];
                case "ECDSA521"
                    if length(public_key) ~= 132
                        error('DERMethods:PK2DER:BadPublicKey', 'Input public key invalid.');
                    end
                    der_key = [DERMethods.DER_ECDSA521_PK_HEADER; public_key];
                otherwise
                    error('DERMethods:PK2DER:BadKeyType', 'Key type %s not implemented.', key_type);
            end
        end

        function public_signature = DER2SIG(der_signature, key_type)
            % strips DER signature of all headers and outputs naked public
            % key signature [r; s]

            if der_signature(1) ~= uint8(48)
                error('DERMethods:DER2SIG:BadSignature', 'Input signature not valid.');
            end

            switch key_type
                case "ECDSA256"
                    key_length = 32;
                    der_signature = der_signature(3:end);
                case "ECDSA384"
                    key_length = 48;
                    der_signature = der_signature(3:end);
                case "ECDSA521"
                    if der_signature(2) ~= uint8(129)
                        error('DERMethods:DER2SIG:BadSignature', 'Input signature not valid.');
                    end
                    key_length = 65;
                    der_signature = der_signature(4:end);
                otherwise
                    error('DERMethods:DER2SIG:BadKeyType', 'Key type %s not implemented.', key_type);
            end

            public_signature = [];
            for i = 1:2
                if der_signature(1) ~= uint8(2)
                    error('DERMethods:DER2SIG:BadSignature', 'Input signature not valid.');
                end

                start_index = 3;
                end_index = 3 + der_signature(2) - 1;
                if end_index > length(der_signature)
                    error('DERMethods:DER2SIG:BadSignature', 'Input signature not valid.');
                end
                integer_data =  der_signature(start_index:end_index);

                integer = zeros(key_length, 1, 'uint8');
                if length(integer_data) > key_length
                    integer = integer_data(2:end);
                else
                    integer(end - length(integer_data) + 1:end) = integer_data;
                end
                public_signature = [public_signature; integer]; %#ok two loops ok
                der_signature = der_signature(end_index + 1:end);
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
                    key_length = 32;
                    length_bit = 2;
                    padding = 0;
                case "ECDSA384"
                    if length(signature) ~= 96
                        error('DERMethods:SIG2DER:BadPublicKey', 'Input public key invalid.');
                    end
                    der_signature = uint8([48; 0]);
                    key_length = 48;
                    length_bit = 2;
                    padding = 0;
                case "ECDSA521"
                    if length(signature) ~= 130
                        error('DERMethods:SIG2DER:BadPublicKey', 'Input public key invalid.');
                    end
                    der_signature = uint8([48; 129; 0]);
                    key_length = 65;
                    length_bit = 3;
                    padding = 1;
                otherwise
                    error('DERMethods:SIG2DER:BadKeyType', 'Key type %s not implemented.', key_type);
            end

            total_size = 0;
            for i = 1:2
                integer = signature(1:key_length);
                if integer(1) < 128
                    first_non_zero_index = find(integer > 0, 1);
                    byte_size = uint8(key_length + 1 - first_non_zero_index);
                    der_signature = [ ...
                                     der_signature; ...
                                     uint8(2); ...
                                     byte_size; ...
                                     integer(first_non_zero_index:end)]; %#ok two loops ok
                    total_size = total_size + byte_size;
                else
                    der_signature = [der_signature; uint8(2); uint8(key_length + 1); ...
                                     uint8(padding); integer]; %#ok two loops ok
                    total_size = total_size + uint8(key_length + 1);
                end
                signature = signature(key_length + 1:end);
            end
            der_signature(length_bit) = total_size + uint8(4);

        end

        function der_type = check_der_type(der_key)
            if all(der_key(1:27) == DERMethods.DER_ECDSA256_PK_HEADER)
                der_type = "SHA256withECDSA";
            elseif all(der_key(1:24) == DERMethods.DER_ECDSA384_PK_HEADER)
                der_type = "SHA384withECDSA";
            elseif all(der_key(1:26) == DERMethods.DER_ECDSA521_PK_HEADER)
                der_type = "SHA512withECDSA";
            else
                error('DERMETHODS:invalidDer', 'enter valid der');
            end
        end

    end

end
