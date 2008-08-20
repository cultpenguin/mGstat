% sgems_test : testing various SGeMS algorithms available form mGstat 
%
% Call : 
%   S=sgems_test('sgsim');
%   S=sgems_test('lusim');
%
function S=sgems_test(alg,dim);
 
if nargin==0;
    alg='sgsim';
end

if nargin<2
    dim.nx=50;
    dim.ny=50;
    dim.nz=1;
end


mgstat_verbose(sprintf('%s : Testing SGeMS algorithm ''%s''',mfilename,alg),10)


S=sgems_get_par(alg);

S.dim=dim;

S=sgems_grid(S);


figure(1);
for i=1:min([S.XML.parameters.Nb_Realizations.value 12])
    subplot(4,3,i);
    pcolor(S.x,S.y,S.D(:,:,1,i)');shading interp;
    axis image
end
suptitle(alg);

return
