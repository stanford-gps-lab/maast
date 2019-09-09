function [] = calculateSig2(obj)
% This function calculates the line of sight variance to all satellites
% that are monitored according to the WAAS MOPS.

obj.Sig2 = obj.Sig2FLT(obj.SatellitesMonitoredMask) + ...
    obj.Sig2UIVE(obj.SatellitesMonitoredMask).*maast.tools.obliquity2(obj.ElevationAngles(obj.SatellitesMonitoredMask)) + ...
    obj.Sig2Tropo(obj.SatellitesMonitoredMask) + obj.Sig2CNMP(obj.SatellitesMonitoredMask);
end