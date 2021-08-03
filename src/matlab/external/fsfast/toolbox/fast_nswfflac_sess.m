% fast_nswfflac_sess.m - spatial wiener filtering to recover and
% filter out the noise. This is very similar to
% fast_swfflac_sess.m, and, they should really be combined,
% but it was easier to do it this way.
%
%
% 


%
% fast_nswfflac_sess.m
%
% Original Author: Doug Greve
%
% Copyright © 2021 The General Hospital Corporation (Boston, MA) "MGH"
%
% Terms and conditions for use, reproduction, distribution and contribution
% are found in the 'FreeSurfer Software License Agreement' contained
% in the file 'LICENSE' found in the FreeSurfer distribution, and here:
%
% https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferSoftwareLicense
%
% Reporting: freesurfer@nmr.mgh.harvard.edu
%



tic;

% The following variables must be defined:
% flacfile = '~/links/sg1/xval/flac/sem_assoc.flac';
% sesspath = '~/links/sg1/xval/dng';
% outfspec  = 'fmcsm5-swf-bh';
% contrast
% nswfdim
% synthtarg = 0; % Synth target data with WGN
% okfile = '/tmp/ok.ok';
%
% These may or may not be defined
% rcslist = [49 34 14 24 50 14]; % 1-based
% targflacfile = '~/links/sg1/xval/flac/rest.flac';
% 

fprintf('contrast = %s\n',contrast);
fprintf('alpha = %g\n',alpha);
%fprintf('pthresh = %g (%g)\n',pthresh,10^(-pthresh));
fprintf('ytkreg = %g\n',ytikreg);
fprintf('sncor = %d\n',sncor);
fprintf('gscaleuse = %d\n',gscaleuse);
fprintf('contrast = %s\n',contrast);
fprintf('nswfdim = %d\n',nswfdim);
fprintf('synthtarg = %g\n',synthtarg);

% Delete the okfile, if it exists
tmp = sprintf('rm -f %s',okfile);
unix(tmp);

% Handle the row,col,slice list. 1-based
if(~exist('rcslist','var')) rcslist = []; end
if(~isempty(rcslist))
  rcslist = reshape(rcslist',[3 2])';
end

% Load the flac
flac = fast_ldflac(flacfile);
if(isempty(flac)) return; end

% Set the session and do a customize to get the run list
flac.sess = sesspath;
flac.nthrun  = 1;
flac = flac_customize(flac);
if(isempty(flac)) return; end
nruns = size(flac.runlist,1);

fprintf('Starting session %s (%6.1f)\n',flac.sess,toc);    
fprintf('flac = %s, nruns = %d (%g)\n',flac.name,nruns,toc);    
fprintf('outfspec = %s\n',outfspec);

contrastind = flac_conindex(contrast,flac);
if(isempty(contrastind))
  fprintf('ERROR: contrast %s not found in flac\n',contrast);
  return;
end

% Handle when the target flac is diff than source
if(~exist('targflacfile','var')) targflacfile = []; end
if(~isempty(targflacfile))
  targflac = fast_ldflac(targflacfile);
  if(isempty(targflac)) return; end
  targflac.sess = sesspath;
  targflac.nthrun  = 1;
  targflac = flac_customize(targflac);
  if(isempty(targflac)) return; end
  if(size(targflac.runlist,1) ~= nruns)
    fprintf('ERROR: target flac has diff no of runs\n');
    return;
  end
  fprintf('Target flac is %s\n',targflac.name);
else
  targflac = flac;
end

% Load the mask
mstem = sprintf('%s/%s/masks/%s',flac.sess,flac.fsd,flac.mask);
mask = MRIread(mstem);
if(isempty(mask)) return; end
indmask = find(mask.vol);
Nvmask = length(indmask);
indnotmask = find(~mask.vol);
nv = prod(mask.volsize);

% Go through each run
for jthrun = 1:nruns
  fprintf('\n\n');
  fprintf('Processing jth run %d (%6.1f)\n',jthrun,toc);
  jflac = targflac;
  jflac.nthrun = jthrun;
  jflac = flac_customize(jflac);
  if(isempty(jflac)) return; end
  jflac = flac_desmat(jflac);
  if(isempty(jflac)) return; end

  indtask = flac_taskregind(jflac);
  jX = jflac.X;

  % Go through each run but leave out the jth
  rjk = [];
  sjk = [];
  for kthrun = 1:nruns
    if(kthrun == jthrun) continue; end
    fprintf('  Processing kth run %d (%6.1f)\n',kthrun,toc);
    kflac = flac;
    kflac.nthrun = kthrun;
    kflac = flac_customize(kflac);
    if(isempty(kflac)) return; end

    % Load the residuals
    fprintf('      Loading residuals (%6.1f)\n',toc);
    rstem = sprintf('%s/%s/%s/%s/res',flac.sess,flac.fsd,flac.name,...
		    flac.runlist(kflac.nthrun,:));
    rrun = MRIread(rstem);
    if(isempty(rrun)) return; end
    rrun.vol = fast_vol2mat(rrun.vol);
    rrun.vol = rrun.vol(:,indmask);
    rjk = [rjk; rrun.vol];
    clear rrun;

    % Load the betas
    fprintf('      Loading betas (%6.1f)\n',toc);
    bstem = sprintf('%s/%s/%s/%s/beta',flac.sess,flac.fsd,flac.name,...
		    flac.runlist(kflac.nthrun,:));
    beta = MRIread(bstem);
    if(isempty(beta)) return; end
    beta.vol = fast_vol2mat(beta.vol);
    beta.vol = beta.vol(:,indmask);

    % Project into the contrast subspace
    C = flac.con(contrastind).C;
    srun = (jX*C'*C)*beta.vol;

    sjk = [sjk; srun];
    clear srun beta;
    
    confspec = sprintf('%s/%s/%s/%s/%s/fsig',kflac.sess,kflac.fsd,...
		       kflac.name,kflac.runlist(kflac.nthrun,:),...
		       kflac.con(contrastind).name);
    con = MRIread(confspec);
    if(isempty(con)) 
      if(~monly) quit; end
      return;
    end

  end

  % Make sure the dimensions are consistent
  ntpmin = min(size(sjk,1),size(rjk,1));
  sjk = sjk(1:ntpmin,:);
  rjk = rjk(1:ntpmin,:);

  % Compute the expected observable
  yjk = sjk + rjk;
  clear sjk;  
  nframesjk = size(yjk,1);
  
  fprintf('  Computing SVD of y for jth run %d (%6.1f)\n',jthrun,toc);  
  [Uy Sy0 Vy] = fast_svd(yjk);
  clear yjk;

  % Regularize y
  dSy = diag(Sy0);
  ind = find(dSy < ytikreg*dSy(1));
  nind = length(ind);
  fprintf('    Regularizing %d components of y out of %d\n',nind,nframesjk);
  dSy(ind) = ytikreg*dSy(1);
  Sy = diag(dSy);
  
  % Here is where it gets different from swf in that the SVD of the
  % residual/noise is computed instead of the signal
  fprintf('  Computing SVD of n for jth run %d (%6.1f)\n',jthrun,toc);  
  [Un Sn Vn] = fast_svd(rjk);
  clear rjk;
  
  % Only keep the top nswfdim components
  dSn = diag(Sn);
  ind = 1:nswfdim;
  cpvs = 100*sum(dSn(ind))/sum(dSn);
  fprintf('  CPVS = %6.2f for nswfdim = %d\n',cpvs,nswfdim);
  Un = Un(:,ind);
  Vn = Vn(:,ind);
  Sn = Sn(ind,ind);
  
  fprintf('  Loading target, jth run = %d (%6.1f)\n',jthrun,toc);
  fstem = sprintf('%s/%s/%s/%s',jflac.sess,jflac.fsd,...
		  jflac.runlist(jflac.nthrun,:),jflac.funcstem);
  fprintf('  fstem = %s\n',fstem);
  if(~synthtarg)
    y = MRIread(fstem);
    if(isempty(y)) return; end
  else
    fprintf('  Sythesizing target with WGN\n');
    y = MRIread(fstem,1);
    if(isempty(y)) return; end
    y.vol = randn(y.height,y.width,y.depth,y.nframes);
  end
  y.vol = fast_vol2mat(y.vol);
  Nv = size(y.vol,2);
  ysize = [y.height y.width y.depth];
  
  % Apply the spatial Wiener filter to get the noise estimate
  fprintf('  Applying spatial Wiener filter (%6.1f)\n',toc);  
  if(sncor == 0)
    nswf = ((y.vol(:,indmask)*Vy)*((inv(Sy.^2)*(Vy'*Vn)*(Sn.^2))))*Vn';
  else
    nswf = ((y.vol(:,indmask)*Vy)*inv(Sy)*Uy'*Un*Sn)*Vn'; % Assume sncor    
  end
  
  % Subtract the noise from the observable
  yswf = y.vol(:,indmask) - nswf;

  if(0)
    % This computes a global scaling factor base on the variance of the
    % best-fit signal. This will have no effect the final functional
    % analysis, but it will make the ranges of values before and after
    % SWF more similar which facilitates comparison.
    Ctask = eye(size(jX,2));
    Ctask = Ctask(indtask,:);
    [b0 rvar0 vdof0] = fast_glmfitw(nswf,jX);
    [F0 dof10 dof20] = fast_fratiow(b0,jX,rvar0,C);
    p0 = FTest(dof10, dof20, F0);
    ind0 = find(p0 < .01);
    if(isempty(ind0)) ind0 = [1:length(indmask)]; end
    s0 = jX(:,indtask)*b0(indtask,ind0);
    bswf = (inv(jX'*jX)*jX')*yswf(:,ind0);
    sswf = jX(:,indtask)*bswf(indtask,:);
    a0 = mean(std(s0),2);
    aswf = mean(std(sswf),2);
    gscale = a0/aswf;
    fprintf('  a0 = %g, aswf = %g, gscale = %g\n',a0,aswf,gscale);
    yswf = yswf*gscale;
  else
    gscale = 1;
  end
  
  % Set mean to be the same as the original
  ymn = mean(y.vol(:,indmask));  
  yswfmn = mean(yswf);
  yswf = yswf + repmat((ymn-yswfmn),[y.nframes 1]);

  % Prepare to save by demasking and reshaping
  yhat = y;
  yhat.vol = zeros(y.nframes,y.height*y.width*y.depth);
  yhat.vol(:,indnotmask) = y.vol(:,indnotmask);
  yhat.vol(:,indmask) = yswf;
  yhat.vol = fast_mat2vol(yhat.vol, [y.height y.width y.depth]);
  
  fprintf('  Saving (%6.1f)\n',toc);    
  yhatfspec = sprintf('%s/%s/%s/%s%s',jflac.sess,jflac.fsd,...
		      jflac.runlist(jflac.nthrun,:),outfspec,...
		      jflac.formatext);
  fprintf('  Saving to %s (%6.1f)\n',yhatfspec,toc);    
  MRIwrite(yhat,yhatfspec);
  
  logfile = sprintf('%s/%s/%s/%s.log',jflac.sess,jflac.fsd,...
		      jflac.runlist(jflac.nthrun,:),outfspec);
  fp = fopen(logfile,'w');
  fprintf(fp,'swfflac with -nswf\n');
  fprintf(fp,'contrast  = %s\n',contrast);
  fprintf(fp,'alpha     = %g\n',alpha);
  %fprintf(fp,'pthresh   = %g (%g)\n',pthresh,10^(-pthresh));
  fprintf(fp,'ytkreg    = %g\n',ytikreg);
  fprintf(fp,'sncor     = %d\n',sncor);
  fprintf(fp,'nswfdim = %d\n',nswfdim);
  fprintf(fp,'CPVS  %6.2f\n',cpvs);
  %fprintf(fp,'gscaleuse = %d\n',gscaleuse);
  fprintf(fp,'gscale    = %g\n',gscale);
  fprintf(fp,'synthtarg = %g\n',synthtarg);
  fclose(fp);

  % This computes how a given voxel (RCS) is projected to the rest
  % of the volume. This is a row from the spatial filter reshaped
  % into a volume. The row is extracted by applying the filter to
  % a vector of all 0s except 1 for the given voxel of interest.
  % There will be a separate plane for each voxel of interest.
  % The output will be stored as outfspec-wrcs-out. RCS is 1-based.
  % Also computes how all voxels project to the given voxel of
  % interest (ie, a column from the spatial filter). Saved to 
  % outfspec-wrcs-in
  if(~isempty(rcslist))
    fprintf('  Computing WRCS (%6.1f)\n',toc);        

    % Compute the volume index of each RCS
    indrcs = sub2ind(ysize,rcslist(:,1),rcslist(:,2),rcslist(:,3));

    % Create a volume of all 0s except for 1s at the voxels of
    % interest. Each frame is a different voxel.
    nrcs = size(rcslist,1);
    yrcs = zeros(nrcs,Nv);
    for ntmp = 1:nrcs
      yrcs(ntmp,indrcs(ntmp)) = 1;
    end

    % Now apply the filter to this volume to get the row of F (the
    % outward projection).
    yrcsswf = ((yrcs(:,indmask)*Vy)*((inv(Sy.^2)*(Vy'*Vn)*(Sn.^2))))*Vn';
    yrcsswf = yrcs(:,indmask) - yrcsswf;
    yrcsswf = gscale*yrcsswf;
  
    % Rescale so that the voxel of interest has a weight of 100, then
    % set the weight at the voxel of interest to 0, otherwise won't be
    % able to see the other weights.
    for ntmp = 1:nrcs
      ind1 = find(yrcs(ntmp,indmask));
      if(isempty(ind1))
	fprintf('ERROR: voxel %d %d %d is not in mask\n',rcslist(ntmp,:));
	return;
      end
      yrcsswf(ntmp,:) = yrcsswf(ntmp,:)/yrcsswf(ntmp,ind1);
      yrcsswf(ntmp,ind1) = 0;
    end
    yrcsswf = 100*yrcsswf;

    % Save the outward projection
    yhat = y;
    yhat.vol = zeros(nrcs,y.height*y.width*y.depth);
    yhat.vol(:,indmask) = yrcsswf;
    yhat.vol = fast_mat2vol(yhat.vol, [y.height y.width y.depth]);
    fprintf('  Saving outward WRCS (%6.1f)\n',toc);    
    yhatfspec = sprintf('%s/%s/%s/%s-wrcs-out%s',jflac.sess,jflac.fsd,...
			jflac.runlist(jflac.nthrun,:),outfspec,...
			jflac.formatext);
    fprintf('  Saving to %s (%6.1f)\n',yhatfspec,toc);    
    MRIwrite(yhat,yhatfspec);

    % Now do the inward projection (ie, the column of F)
    yrcsswf = ((yrcs(:,indmask)*Vy)*((inv(Sy.^2)*(Vy'*Vn)*(Sn.^2))))*Vn';
    yrcsswf = yrcs(:,indmask) - yrcsswf;
    yrcsswf = alpha*yrcsswf + (1-alpha)*yrcs(:,indmask);    
    yrcsswf = gscale*yrcsswf;
  
    % Rescale so that the voxel of interest has a weight of 100, then
    % set the weight at the voxel of interest to 0, otherwise won't be
    % able to see the other weights.
    for ntmp = 1:nrcs
      ind1 = find(yrcs(ntmp,indmask));
      yrcsswf(ntmp,:) = yrcsswf(ntmp,:)/yrcsswf(ntmp,ind1);
      yrcsswf(ntmp,ind1) = 0;
    end
    yrcsswf = 100*yrcsswf;
  
    % Save the inward projection
    yhat = y;
    yhat.vol = zeros(nrcs,y.height*y.width*y.depth);
    yhat.vol(:,indmask) = yrcsswf;
    yhat.vol = fast_mat2vol(yhat.vol, [y.height y.width y.depth]);
    fprintf('  Saving inward WRCS (%6.1f)\n',toc);    
    yhatfspec = sprintf('%s/%s/%s/%s-wrcs-in%s',jflac.sess,jflac.fsd,...
			jflac.runlist(jflac.nthrun,:),outfspec,...
			jflac.formatext);
    fprintf('  Saving to %s (%6.1f)\n',yhatfspec,toc);    
    MRIwrite(yhat,yhatfspec);
  
  end

  clear Vy Vn;
  clear y nswf yswf yhat;

end
fprintf('\n\n');
  
fmri_touch(okfile);
fprintf('fast_nswfflac_sess done for session %s (%6.1f)\n',flac.sess,toc);    










