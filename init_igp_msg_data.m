function igpdata = init_igp_msg_data()

%decoded iono data
max_bands = 10;
max_igps = 201;
%MT18
igpdata.mt18_mask = cast(zeros(max_bands,max_igps), 'uint8');
igpdata.mt18_num_bands = zeros(max_bands,1);
igpdata.mt18_igps = [];
igpdata.mt18_iodi = NaN(max_bands,1);
igpdata.mt18_time = NaN(max_bands,1);
%MT26
igpdata.mt26_Iv = NaN(max_bands, max_igps);
igpdata.mt26_givei = NaN(max_bands, max_igps);
igpdata.mt26_iodi = NaN(max_bands, max_igps);
igpdata.mt26_time = NaN(max_bands, max_igps);

%correction data
igpdata.givei    = NaN(max_bands, max_igps);
igpdata.eps_iono = NaN(max_bands, max_igps);