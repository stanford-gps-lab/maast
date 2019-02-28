function metric = obtain_ipp_spread ( a_spd, r_spd, dx, dy, sig2_ipp, GIVE_SIG2_DECORR )

% This function allows for the computation of metrics in addition to the
% use of radius and relative centroid.  Information regarding these metrics
% must be set in tm_metric_info.m.  All that must be returned is the index
% for the fourth metric.  If it isn't being used, simply return
% 1 (not zero, will cause an error).
%
% Note, arguments to the function may be modified, this function is called
% from correlate_dffps_vs_2_metrics_matt (though the 2 is obviously now
% outdated)
%
% M. DeLand 6/4/2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    OVERLAP = 2;
    ds2 = dx.^2 + dy.^2;
   
    % keep = find(ds2 > -1);    % Keeps all points
    
    keep = find(ds2 >= 0.125); % Don't look at points in the threat domain.  0.125 is approximate here
                               % it's the radius of the smallest circle containing the
                               % threat region.
    dy_k = dy(keep);
    dx_k = dx(keep);
    ds2_k = ds2(keep);
    spokes_k = zeros(361,1);
    sig2_ipp_k = sig2_ipp(keep);
   
    theta_k  = 180 * atan2( dy_k, dx_k ) / pi;
    %dtheta_k = 360 ./ ( a_spd + (ds2_k / (r_spd^2)) );
    dtheta_k = 360 ./ (a_spd);
    high   = floor( theta_k + dtheta_k ) + 181;         % 1 <= 'high' <= 721.
    low    = ceil( theta_k - dtheta_k ) + 181;          % -359 <= 'low' <= 361.
   
    for i = 1:length(dx_k)
        hi = high(i);
        lo = low(i);
        weight = 1 / max(sig2_ipp_k(i)/GIVE_SIG2_DECORR, 1);
        %weight = 1;
        if ( lo < 1 )
            spokes_k( (360 + lo):360 ) = weight + spokes_k( (360 + lo):360 );
            lo = 1;
        end
        if ( hi > 360 )
            spokes_k( 1:(hi - 360) ) = weight + spokes_k( 1:(hi - 360) );
            hi = 360;
        end
        if ( hi >= lo )
            spokes_k( lo:hi ) = weight + spokes_k( lo:hi );
        end
    end
    
    spokes_k(1) = spokes_k(1) + spokes_k(361);
    spokes_k = min(spokes_k, OVERLAP * ones(361,1));
    metric    = 1 - sum( spokes_k(1:360) ) / (OVERLAP * 360);
 