% print_mul : prints both EPS, PNG, and PDF figures of current plot
%
% CALL :
%    print_mul(fname,types,trim,transp,res,do_watermark);
%    fname : filename
%            ['test'] (def)
%    types : type of output files
%            [0] no hardcopy
%            [1] png
%            [2] pdf
%            [3] eps
%            [4] png,pdf
%            [5] png,pdf,eps
%            [6] png transparent with export_fig (+1,+2)
%    trim  : trim PNG image (remove borders - requires mogrify)
%            [0]: no trimminf (def)
%            [1]: trimming
%    trans : transparency of PNG image(requires mogrify)
%            [0]: no transparency (def)
%            [1]: white as transparent
%            ['red']: red as transparent
%    res : resolution
%            [300] (def)
%    do_watermark : add fname as watermark to figure in lower right corner
%            [0] no watermark(def)
%            [1] watermark(def)
%
% Ex :
%   print_mul('test') % prints test.eps, test.png, and test.pdf
%   print_mul('test',1,1) % prints test.eps, test.png, and test.pdf
%                         % test.png will be trimmed and white set as
%                         % transparent color
%
%   print_mul('test',0,'black',600,1) % prints test.eps, test.png, and test.pdf
%                         % test.png will NOT be trimmed and BLACK set as
%                         % transparent color. resolution is set to 600dpi
%                         % and a watermark is added
%
%% /TMH 2005-2012
%

function print_mul(fname,types,trim,transp,res,do_watermark);


if nargin<1, fname='test';end
if nargin<2, types=1;end
if types==0; return;end
if nargin<5, res=300;end
if nargin<3, trim=0;end
if trim>1
    res=trim;
    trim=0;
end
if nargin<4, 
    %transp=1;
    transp=0;
end
if nargin<6, do_watermark=0;end


save_fig=0;

fname=space2char(fname);
fname=space2char(fname,'_','\.');

if do_watermark==1
    watermark(fname);
end
fname=space2char(fname);

i=0;
if ((types==1)||(types==4)||(types==5)||(types==6))
    i=i+1;P{i}.type='-dpng';P{i}.ext='.png';
end
if ((types==2)||(types==4)||(types==6))
    i=i+1;P{i}.type='-dpdf';P{i}.ext='.pdf';
end
if ((types==3)||(types==5))
    i=i+1;P{i}.type='-depsc';P{i}.ext='.eps';
end

for i=1:length(P)
    res_string=sprintf('-r%d',res);
    file_out=[fname,P{i}.ext];
    %file_out=[fname,'];
    try
        print(gcf, P{i}.type,res_string,[file_out])
    catch
        disp(sprintf('%s : failed to print %s as %s',mfilename,fname,P{i}.ext))
    end
end

%% SAVE FIG FILE
if (save_fig==1)
    saveas(gcf,[fname,'.fig'],'fig');
end


%% EXPORT FIG
if types==6,
    if exist('export_fig','file')
        scale=res/180;
        export_fig(sprintf('%s_transp.png',fname),'-transparent',sprintf('-m%3.1f',scale))
        %export_fig(sprintf('%s_transp.png',fname),'-transparent','-m8')
    else
        disp(sprintf('%s: export_fig is not available -- skipping',mfilename))
    end
end


%% TRIM IMAGE USING MOGRIFY

if (trim==1)||(transp~=0)
    if isunix
        [a,mogrifybin]=unix('which mogrify');
        mogrifybin=mogrifybin(1:length(mogrifybin)-1);
    else
        mogrifybin='c:\cygwin\bin\mogrify.exe';
        %disp(sprintf('%s : trimming only supported on Unix',mfilename))
    end
    
    % TRANSPAREMCY
    if ischar(transp)
        transp_cmd=['-transparent ',transp];
    else
        if transp==1
            transp_cmd=['-transparent white'];
        else
            transp_cmd='';
        end
    end
    
    if trim==1;
        trim_cmd='-trim';
    else
        trim_cmd='';
    end
    
    % MOGRIFY PNG FILE
    if exist(mogrifybin,'file')
        cmd=sprintf('%s %s %s %s.png',mogrifybin,trim_cmd,transp_cmd,fname);
        [status,result]=system(cmd);
        if status~=0; disp(sprintf('%s : %s',mfilename,result));end
    else
        % disp(sprintf('%s : MOGRIFY binary not found',mfilename))
    end
end
