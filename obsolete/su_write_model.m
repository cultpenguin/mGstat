% su_write_2d_model : Write model for SU modeling
function su_write_model(v,filename);
    if nargin==0
        help su_write_model
    end
    if nargin<2
        filename='velocity.out';
    end
           
    write_bin(filename,v(:));
    