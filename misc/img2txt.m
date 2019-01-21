% img2txt: convert 2D image to GSLIB type ASCII files
%
% Call
%   img2txt;
%   img2txt(filenames);
%   img2txt(filenames,nx,ny);
%
%   filenames srting, def='*.jpg';
%   nx: max size in x-dim
%   ny: max size in y-dim
%
%   Calling 
%    >> img2txt;
%   is similar to callingh 
%    >> img2txt('*.jpg',1e+9,1e+9)
%
%
function fout=img2txt(filenames,nx,ny);

if nargin==1, filenames='*.jpg';end
if isempty(filenames),filenames='*.jpg';end
if nargin<2, nx=1e+9;end
if nargin<3, ny=1e+9;end
   
F=dir(filenames);
nF=length(F);

io=0;
for i=1:length(F);
    
    fname=F(i).name;
    [fp,fn,fe]=fileparts(fname);

    try
        disp(sprintf('%s: Trying to read %s',mfilename,fname))
        I=imread(fname);
        [ny_org,nx_org,ncol]=size(I);
        
        nx=min([nx nx_org]);
        ny=min([ny ny_org]);
        
        % determined color
        sI=(I(:,:,1)~=I(:,:,2))&(I(:,:,1)~=I(:,:,3))&(I(:,:,2)~=I(:,:,3));
        is_color=sum(sI(:));
        
        subplot(ceil(nF/3),4,i);imshow(I);
        drawnow;
        
        col_id={'r','g','b'};
        
        if is_color
            for i=1:ncol,
                fo=sprintf('%s_%d_%d_%s.dat',fn,nx,ny,col_id{i});
                disp(sprintf('Writing %s',fo))
                write_eas_matrix(fo, I(1:ny,1:nx,i));
                io=io+1;fout{io}=fo;
                %write_eas_matrix(fo, I(:,:,1));
            end
        end
        BW=rgb2gray(I);
        fo=sprintf('%s_%d_%d_bw.dat',fn,nx,ny);
        disp(sprintf('Writing %s',fo))
        write_eas_matrix(fo, BW(1:ny,1:nx));
        io=io+1;fout{io}=fo;
    catch
        disp(sprintf('%s: Failed to read %s',mfilename,fname))        
    end
end





;