% visim_tomograhy
function visim_tomography(V,m0,S,R,t,dt);

[q,parname]=fileparts(V.parfile);

m_current=m0;
it=0;

for it=1:9

  
  % Calculate Rays/Fresnel zones using reference velocity field.
  %visim_tomo_setup(S,R,t,dt)
  [fvolgeom,fvolsum]=visim_tomo_setup(m_ref,x,y,z,S,R,t,dt,name)
  V.fvolgeom.fname=fvolgeom;
  V.fvolsum.fname=fvolsum;
  
  % Write VISIM parameter file
  % run VISIM on current parameter file
  V.parfile=sprintf('%s_it%d.par',parname,it);
  disp(V.parfile)
  %write_visim(V)
  %visim(V);
  
  
  
  %% RECOMPUTE RAY GEMOETRY
  % A) Compute E-TYPE and recalculate ray geometry
  % B) Get the maximum likelihood realization and compute ra
  m_current=V.etype.mean;
  
end