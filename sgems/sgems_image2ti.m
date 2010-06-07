% sgems_image2ti : convert images to SGeMS training images
%                  images are converted both as continous 
%                  and categorical TIs.
% Example
%   % convert 'test.png' to the TI test.sgems:
%   sgems_image2ti('test.png');
%
%   % convert all PNGs to training images 
%   % replacing the PNG extension with an SGEMS extension
%   sgems_image2ti('*.png');
%
%   % Convert all PNGs, JPEGs, TIFFs in current directory:
%   sgems_image2ti;
%
%
function file_out=sgems_image2ti(filename_img,lims);

file_out=[];

if nargin==0
    sgems_image2ti('*.png');
    sgems_image2ti('*.jpg');    
    sgems_image2ti('*.tiff');
    return;
else
    d_img=dir(filename_img);
end

if length(d_img)==0
    disp(sprintf('%s : no matching files (''%s'') ',mfilename,filename_img))
    return
end

for i=1:length(d_img)
    [p,filename]=fileparts(d_img(1).name);
    IM=imread(d_img(i).name);
    
    IM=double(IM(:,:,1));
    [ny,nx]=size(IM);

    x=1:1:nx;
    y=1:1:ny;
    z=0;

    id=1;
    d=IM';d=d(:);
    data(:,id)=d;
    property{id}='CONTINIOUS';
    
    do_discrete=1;
    if do_discrete==1;
        
        d_sort=sort(d(:));
        % make discrete data
        if nargin==2
            % LIMS GIVEN AS INPUT
            for icat=1:(length(lims)-1);
                IM_CAT=zeros(size(IM));
                for k=1:icat
                    kk=find((IM>lims(k))&(IM<=lims(k+1)));
                    IM_CAT(kk)=k-1;
                end
            end
            
            id=id+1;
            d=IM_CAT';
            data(:,id)=d(:);
            property{id}=sprintf('DISCRETE_%d',icat');;
            
                
        else
            
            for icat=2:5;
                cont_method=2;
                if cont_method==1;
                    lims=linspace(0,255,icat+1);
                else
                    ilims=round(linspace(1,nx*ny,icat+1));
                    lims=d_sort(ilims);
                end
                
                IM_CAT{icat-1}=zeros(size(IM));
                for k=1:icat
                    kk=find((IM>=lims(k))&(IM<=lims(k+1)));
                    IM_CAT{icat-1}(kk)=k-1;
                end
                
                id=id+1;
                d=IM_CAT{icat-1}';
                data(:,id)=d(:);
                property{id}=sprintf('DISCRETE_%d',icat');;
                
            end
        end
    end
    file_out=[filename,'.sgems'];
    sgems_write_grid(x,y,z,data,file_out,'TI',property);


end