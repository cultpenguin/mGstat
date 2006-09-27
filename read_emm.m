% read_emm : read emm output file from em1dinv
%
% CALL : 
%   [emm]=read_emm(filename);
%
function [emm,line]=read_emm(filename)
    
    if nargin==0
        help read_emm
        return
    end
    
    fid=fopen(filename,'r');

    iline=0;
    for i=1:43,
        iline=iline+1;
        line{iline}=fgetl(fid);
    end
    
    emm.version=line{2};
    emm.date=line{6};
    emm.runtimee=str2num(line{8});
    emm.ni=str2num(line{10});
    emm.nds=str2num(line{12});    
    emm.nd=str2num(line{14});
    emm.dcp_file=line{16};
    emm.mod_file=line{18};
    emm.nm=str2num(line{20});
    emm.nm_par=str2num(line{22});    
    emm.nm_layers=str2num(line{24});    
    emm.logspace=sscanf(line{26},'%d');    


    %    Model parameters
    iline=iline+1;  line{iline}=fgetl(fid);
    d=sscanf(line{iline},'%d');    
    emm.MPar.nm=d(1);
    emm.MPar.ni=d(2);    
    for i=1:emm.MPar.nm
        l=fgetl(fid);
        d=sscanf(l,'%f');    
        emm.MPar.data(i,:)=d(:)';
    end

    
    %    Forward
    fgetl(fid);
    iline=iline+1;  line{iline}=fgetl(fid);
    d=sscanf(line{iline},'%d');    
    emm.Forward.nm=d(1);
    emm.Forward.ni=d(2);    
    for i=1:emm.Forward.nm
        l=fgetl(fid);
        d=sscanf(l,'%f');    
        emm.Forward.data(i,:)=d(:)';
    end

    %    G
    fgetl(fid);
    iline=iline+1;  line{iline}=fgetl(fid);
    d=sscanf(line{iline},'%d');    
    emm.G.nm=d(1);
    emm.G.ni=d(2);    
    for i=1:emm.G.nm
        l=fgetl(fid);
        d=sscanf(l,'%f');    
        emm.G.data(i,:)=d(:)';
    end
    

    %    Mres
    fgetl(fid);
    iline=iline+1;  line{iline}=fgetl(fid);
    d=sscanf(line{iline},'%d');    
    emm.Mres.nm=d(1);
    emm.Mres.ni=d(2);    
    for i=1:emm.Mres.nm
        l=fgetl(fid);
        d=sscanf(l,'%f');    
        emm.Mres.data(i,:)=d(:)';
    end
    

    
    %    MCovC
    fgetl(fid);
    iline=iline+1;  line{iline}=fgetl(fid);
    d=sscanf(line{iline},'%d');    
    emm.MCovC.nm=d(1);
    emm.MCovC.ni=d(2);    
    for i=1:emm.MCovC.nm
        l=fgetl(fid);
        d=sscanf(l,'%f');    
        emm.MCovC.data(i,:)=d(:)';
    end

        
    %    MCovCn
    fgetl(fid);
    iline=iline+1;  line{iline}=fgetl(fid);
    d=sscanf(line{iline},'%d');    
    emm.MCovCn.nm=d(1);
    emm.MCovCn.ni=d(2);    
    for i=1:emm.MCovCn.nm
        l=fgetl(fid);
        d=sscanf(l,'%f');    
        emm.MCovCn.data(i,:)=d(:)';
    end


    
    
    %    MCovUC
    fgetl(fid);
    iline=iline+1;  line{iline}=fgetl(fid);
    d=sscanf(line{iline},'%d');    
    emm.MCovUC.nm=d(1);
    emm.MCovUC.ni=d(2);    
    for i=1:emm.MCovUC.nm
        l=fgetl(fid);
        d=sscanf(l,'%f');    
        emm.MCovUC.data(i,:)=d(:)';
    end



     
    %    AnaC
    fgetl(fid);
    iline=iline+1;  line{iline}=fgetl(fid);
    d=sscanf(line{iline},'%d');    
    emm.AnaC.nm=d(1);
    emm.AnaC.ni=d(2);    
    for i=1:emm.AnaC.nm
        l=fgetl(fid);
        d=sscanf(l,'%f');    
        emm.AnaC.data(i,:)=d(:)';
    end
     
    %    AnaUC
    fgetl(fid);
    iline=iline+1;  line{iline}=fgetl(fid);
    d=sscanf(line{iline},'%d');    
    emm.AnaUC.nm=d(1);
    emm.AnaUC.ni=d(2);    
    for i=1:emm.AnaUC.nm
        l=fgetl(fid);
        d=sscanf(l,'%f');    
        emm.AnaUC.data(i,:)=d(:)';
    end

    


