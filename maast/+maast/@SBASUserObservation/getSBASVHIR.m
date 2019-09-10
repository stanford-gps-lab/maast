function [vir, hir] = getSBASVHIR(obj)
% obj.getVHIR calculates the Vertical and Horizontal Integrity Risk for
% specified alert levels

% Preallocate
[numUsers, timeLength] = size(obj);
vir = NaN(numUsers, timeLength);
hir = vir;

% Loop through objects
for j = 1:numUsers
    for i = 1:timeLength
        if (sum(obj(j,i).SatellitesMonitoredMask) > 3) && (max(obj(j,i).SatellitePRN) >= maast.constants.WAASMOPSConstants.MinGEOPRN)
            % Calculate VPL
            % Get geometry matrix in the local enu frame
            G = [obj(j,i).LOSenu(obj(j,i).SatellitesMonitoredMask, :), ones(sum(obj(j,i).SatellitesMonitoredMask),1)];
            W = diag(ones(sum(obj(j,i).SatellitesMonitoredMask),1)./obj(j,i).Sig2(obj(j,i).SatellitesMonitoredMask));
            Cov = inv(G'*W*G);
            vir(j,i) = normpdf(maast.constants.WAASMOPSConstants.VALLPV200, 0, sqrt(Cov(3,3)));
            % Calculate HPL
            hir(j,i) = normpdf(maast.constants.WAASMOPSConstants.HALLPV200, 0,...
                sqrt(0.5*(Cov(1,1) + Cov(2,2)) +...
                sqrt(0.25*(Cov(1,1) - Cov(2,2))^2 +...
                Cov(1,2)*Cov(2,1))));
        else
            % V/HPL not available
            vir(j,i) = NaN;
            hir(j,i) = NaN;
        end
    end
end