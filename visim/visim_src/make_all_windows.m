% make_all_windows : Compiles VISIM for Windows using gfortran
%
% Gfortran for winXP can be downloaded from :
% http://www.equation.com/servlet/equation.cmd?call=fortran

delete('visim.inc');
d=dir('*.inc');

for i=1:length(d);
    [p,f]=fileparts(d(i).name);
    dos(sprintf('copy %s visim.inc',d(i).name));
    delete('*.o');
    dos('make');
    dos(sprintf('copy visim.exe %s.exe',f));
end
    
dos('copy visim_401_401_1_805_199.exe visim.exe');

delete('*.o')