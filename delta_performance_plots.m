function delta_performance_plots(ref_outputs_filename, new_outputs_filename, outputs, percent, vhal, pa_mode)
%*************************************************************************
%*     Copyright c 2019 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%

%Created Todd Walter December 22, 2019 to include VAL, HAL and PA vs. NPA mode
global COL_USR_LL COL_IGP_LL 

global GRAPH_AVAIL_FIGNO GRAPH_VPL_FIGNO GRAPH_HPL_FIGNO
global GRAPH_UDREMAP_FIGNO GRAPH_GIVEMAP_FIGNO
global GRAPH_UDREHIST_FIGNO GRAPH_GIVEHIST_FIGNO GRAPH_COV_AVAIL_FIGNO

% Outputs
GUI_OUT_AVAIL = 1;
GUI_OUT_VHPL = 2;
GUI_OUT_UDREMAP = 3;
GUI_OUT_GIVEMAP = 4;
GUI_OUT_UDREHIST = 5;
GUI_OUT_GIVEHIST = 6;
GUI_OUT_COVAVAIL = 7;

init_graph;
init_col_labels;

eval(['load ' ref_outputs_filename]);

vpl_ref = vpl;
hpl_ref = hpl;

udrei_ref = udrei;
udre_hist_ref = udre_hist;

givei_ref = givei;
give_hist_ref = give_hist;

eval(['load ' new_outputs_filename]);

del_vpl = vpl - vpl_ref;
del_hpl = hpl - hpl_ref;

del_udrei = udrei_ref;
del_udre_hist = udre_hist - udre_hist_ref;

del_givei = givei - givei_ref;
del_give_hist = give_hist - give_hist_ref;

igp_mask = igpdata(:,COL_IGP_LL);

nt = size(del_vpl,2);

if outputs(GUI_OUT_AVAIL)
    h=figure(GRAPH_AVAIL_FIGNO);
    avail_contour(usrlatgrid, usrlongrid, del_vpl, del_hpl, inbnd, percent, vhal, pa_mode);
    set(h,'name','AVAILABLITY CONTOUR');
end

if outputs(GUI_OUT_VHPL)
    % sort v/hpl for each user and determine vpl at given percentage
    nusr = size(usrdata,1);
    sortvpl = zeros(size(del_vpl));
    sorthpl = zeros(size(del_hpl));
    percentidx = ceil(percent*nt);
    for i = 1:nusr
        sortvpl(i,:) = sort(del_vpl(i,:));
        sorthpl(i,:) = sort(del_hpl(i,:));
    end
    vpl = sortvpl(:,percentidx);
    hpl = sorthpl(:,percentidx);
    %VAL specific plot
    if(pa_mode)
        h=figure(GRAPH_VPL_FIGNO);
        vpl_contour(usrlatgrid,usrlongrid,vpl,percent);
        set(h,'name','VPL CONTOUR');
    end
    h=figure(GRAPH_HPL_FIGNO);
    hpl_contour(usrlatgrid,usrlongrid,hpl,percent);
    set(h,'name','HPL CONTOUR');
end

if outputs(GUI_OUT_GIVEMAP)
    % sort gives for each user and determine gives at given percentage
    if sum(sum(~isnan(del_givei)))
        nigp = size(del_givei,1);
        sortgive = zeros(size(del_givei));
        percentidx = ceil(percent*nt);
        for i = 1:nigp
            sortgive(i,:) = sort(del_givei(i,:));
        end
        give_i = sortgive(:,percentidx);
        h=figure(GRAPH_GIVEMAP_FIGNO);
        give_contour(igp_mask, inv_igp_mask, give_i,percent);
        set(h,'name','GIVE MAP');
%        text(longrid(1)+1,latgrid(1)+1,'o -  USER');
    else
        fprintf('No GIVEs were calculated\n');
    end
end

if outputs(GUI_OUT_UDREMAP)
    sat_llh = xyz2llh(sat_xyz);
    h=figure(GRAPH_UDREMAP_FIGNO);
    mapudre(del_udrei,sat_llh, wrsdata(:,COL_USR_LL));
    set(h,'name','UDRE MAP');
end

if outputs(GUI_OUT_UDREHIST)
	h=figure(GRAPH_UDREHIST_FIGNO);
    udre_histogram(del_udre_hist, udrei_hist);
    set(h,'name','UDRE HISTOGRAM');
end

if outputs(GUI_OUT_GIVEHIST)
    if sum(sum(~isnan(del_givei)))    
        h=figure(GRAPH_GIVEHIST_FIGNO);
        give_histogram(del_give_hist, givei_hist);
        set(h,'name','GIVE HISTOGRAM');
    else
        fprintf('No GIVEs were calculated\n');
    end        
end

if outputs(GUI_OUT_COVAVAIL)
    h = figure(GRAPH_COV_AVAIL_FIGNO);
    cov_avail(usrdata, vpl_ref, hpl_ref, vhal, pa_mode);
    set(h, 'name', 'COVERAGE VS AVAILABILITY');
    
    hold on
        cov_avail(usrdata, vpl, hpl, vhal, pa_mode);

end


