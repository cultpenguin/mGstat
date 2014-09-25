% print_mul : prints both EPS and PNG figures of current plot
%
% CALL :
%    print_mul(fname,trim,transp,res,do_watermark);
%    fname : filename
%            ['test'] (def)
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

function print_mul(fname,trim,transp,res,do_watermark);


if nargin<1, fname='test';end
if nargin<4, res=300;end
if nargin<2, trim=0;end
if nargin<3, 
    %transp=1;
    transp=0;
end
if nargin<5, do_watermark=0;end
save_fig=0;

fname=space2char(fname);
fname=space2char(fname,'_','\.');

if do_watermark==1
    watermark(fname);
end
fname=space2char(fname);

i=0;
i=i+1;P{i}.type='-dpng';P{i}.ext='.png';
%i=i+1;P{i}.type='-depsc';P{i}.ext='.eps';
i=i+1;P{i}.type='-dpdf';P{i}.ext='.pdf';

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


%% TRIM IMAGE USING MOGRIFY

if (trim==1)|(transp~=0)
    if isunix
        [a,mogrifybin]=unix('which mogrify');
        mogrifybin=mogrifybin(1:length(mogrifybin)-1);
    else
        mogrifybin='c:\cygwin\bin\mogrify.exe';
        %disp(sprintf('%s : trimming only supported on Unix',mfilename))
    end
    
    % TRANSPAREMCY
    if isstr(transp)
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
