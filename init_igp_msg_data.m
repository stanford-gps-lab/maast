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
mt26.Iv = NaN;
mt26.givei = MOPS_GIVEI_NM;
mt26.iodi = NaN;
mt26.time = NaN;
mt26.msg_idx = 1;
for idx = (max_bands*max_igps):-1:1
    igpdata.mt26(idx,3) = mt26;
    igpdata.mt26(idx,2) = mt26;
    igpdata.mt26(idx,1) = mt26;
end
%correction data
igpdata.iodi = NaN;
igpdata.v_delay  = NaN(max_bands, max_igps);
igpdata.givei    = repmat(MOPS_GIVEI_NM, size(igpdata.v_delay));
igpdata.eps_iono = NaN(max_bands, max_igps);
igpdata.igp_mat = [];
igpdata.inv_igp_mask = [];
igpdata.mt26_to_igpdata = [];