% sgems_variogram_xml : convert variogram STRING into SGEMS XML
%
% Call : 
%    XML=sgems_variogram_xml(Va);
%
% Example : 
%    S=sgems_get_par('sgsim');
%    var_xml=sgems_variogram_xml('0.1 Nug(0) + 0.4 Exp(10) + 0.5 Sph(40,30,0.2)');
%    S.XML.parameters.Variogram = var_xml;
%    S = sgems_grid(S);
%    images(S.x,S.y,S.D(:,:,1)');
%
% The STRING format for a variogram model is the same as used in GSTAT :
% http://www.gstat.org/gstat.pdf


function XML=sgems_variogram_xml(Va)
if isstr(Va)
    Va=deformat_variogram(Va);
end

XML.nugget=0;
XML.structures_count=0;
Nnugget=0;
istruc=0;
for i=1:length(Va)
    if Va(i).itype==0
        XML.nugget=Va(i).par1;
        Nnugget=1;
    else
        istruc=istruc+1;
        % Stricture name
        STRUC=sprintf('structure_%d',istruc);
        XML.(STRUC).contribution = Va(i).par1;
        % variogram type
        if Va(i).itype==1; XML.(STRUC).type = 'Exponential';
        elseif Va(i).itype==2; XML.(STRUC).type = 'Spherical'; 
        elseif Va(i).itype==3; XML.(STRUC).type = 'Gaussian'; 
        else XML.(STRUC).type = 'UnsupportedBySgems'; end
        % Range + rotation
        if length(Va(i).par2)==1
            % ISOTROP 
            ranges=[1 1 1].*Va(i).par2;
            angles=[0 0 0];
        elseif (length(Va(i).par2)==3);
            % 2D anisotrop
            ranges=[1 Va(i).par2(3) 0].*Va(i).par2(1);
            angles=[Va(i).par2(2) 0 0];
        elseif (length(Va(i).par2)==6);
            % 3D anisotropy
            ranges=[1 Va(i).par2(5)  Va(i).par2(6)].* Va(i).par2(1);
            angles=Va(1).par2(2:4)
        end
        XML.(STRUC).ranges.max=ranges(1);
        XML.(STRUC).ranges.medium=ranges(2);
        XML.(STRUC).ranges.min=ranges(3);
        XML.(STRUC).angles.x=angles(1);
        XML.(STRUC).angles.y=angles(2);
        XML.(STRUC).angles.z=angles(3);
        
    end
end
XML.structures_count=length(Va)-Nnugget;

