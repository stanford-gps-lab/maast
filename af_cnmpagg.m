function sig2_cnmp = af_wrscnmpagg(del_t,el)

%*************************************************************************
%*     Copyright c 2001 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
global CONST_F1 CONST_F2  

cnmp_coef = [-3.9586 11.5991 -10.5790 0.7142];    % aggressive cnmp

a1 = CONST_F1^2/(CONST_F1^2-CONST_F2^2);
a2 = CONST_F2^2/(CONST_F1^2-CONST_F2^2);

idxvis = find(~isnan(el));
sig2_cnmp = repmat(NaN,size(el));
sig2_cnmp(idxvis) = (a1^2+a2^2) * exp(polyval(cnmp_coef,el(idxvis))).^2;
