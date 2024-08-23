function igpdata = init_igp_msg_data()

global MOPS_GIVEI_NM

%decoded iono data
max_bands = 10;
max_igps = 201;
%MT18
mt18.mask = cast(zeros(1,max_igps), 'uint8');
mt18.num_bands = 0;
mt18.igps = [];
mt18.iodi = NaN;
mt18.time = NaN;
mt18.msg_idx = 1;
for bdx = max_bands:-1:1
    igpdata.mt18(bdx,3) = mt18;
    igpdata.mt18(bdx,2) = mt18;
    igpdata.mt18(bdx,1) = mt18;
end
%MT26
mt26.Iv = NaN(1, max_igps);
mt26.givei = repmat(MOPS_GIVEI_NM, 1, max_igps);
mt26.iodi = NaN(1, max_igps);
mt26.time = NaN(1, max_igps);
mt26.msg_idx = ones(1, max_igps);
for bdx = max_bands:-1:1
    igpdata.mt26(bdx,3) = mt26;
    igpdata.mt26(bdx,2) = mt26;
    igpdata.mt26(bdx,1) = mt26;
end
%correction data
igpdata.v_delay  = NaN(max_bands, max_igps);
igpdata.givei    = repmat(MOPS_GIVEI_NM, size(igpdata.v_delay));
igpdata.eps_iono = NaN(max_bands, max_igps);