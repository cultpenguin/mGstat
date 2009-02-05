% kml_line : Create a KML file definig a line
% 
% Call : 
% 
% kml_line(kml_file,lat,lon,name,descr,color,width);
%
% Ex : 
%  kml_line('line.kml',[55 55.1],[12 12.1]);
%  kml_line('line.kml',[55 55.1],[12 12.1],'A TEST','ffffff','4');
%
function kml_line(kml_file,lat,lon,name,descr,color,width);
ele=lat.*0+5;
if nargin<1
    kml_file='data.kml';
end
if nargin<4, name='NAME';end
if nargin<5, descr='DESCRIPTION';end

try 
    options.color=color;
catch
    options.color='ff000000';
end
try 
    options.width=width;
catch
    options.width=4;
end
options.extrude=1;
options.tessellate=1;

fid = fopen(kml_file,'w');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid,'<kml xmlns="http://www.opengis.net/kml/2.2">\n');

fprintf(fid,'  <Placemark>\n');
fprintf(fid,'    <Style id="LocalStyle">');
fprintf(fid,'      <LineStyle>');
fprintf(fid,'        <color>%s</color>',options.color);
fprintf(fid,'        <width>%d</width>',options.width);
fprintf(fid,'      </LineStyle>');
fprintf(fid,'      <PolyStyle>');
fprintf(fid,'        <color>7f00ff00</color>');
fprintf(fid,'      </PolyStyle>');
fprintf(fid,'    </Style>');
fprintf(fid,'    <name>%s</name>\n',name);
fprintf(fid,'    <description>%s\n',descr);
fprintf(fid,'    </description>\n');
fprintf(fid,'    <styleUrl>#LocalStyle</styleUrl>');
fprintf(fid,'        <LineString>\n');
fprintf(fid,'          <extrude>%d</extrude>\n',options.extrude);
fprintf(fid,'          <tessellate>%d</tessellate>\n',options.tessellate);
fprintf(fid,'          <altitudeMode>absolute</altitudeMode>\n');
fprintf(fid,'          <coordinates>\n');
for i=1:length(lat)
    fprintf(fid,'            %16.6f,%16.6f,%g\n',lon(i),lat(i),ele(i));
end
fprintf(fid,'          </coordinates>\n');
fprintf(fid,'        </LineString>\n');

fprintf(fid,'  </Placemark>\n');
fprintf(fid,'</kml>\n');
fclose(fid);


%<?xml version="1.0" encoding="UTF-8"?>
%<kml xmlns="http://www.opengis.net/kml/2.2">
%  <Placemark>
%    <name>Simple placemark</name>
%    <description>Attached to the ground. Intelligently places itself 
%       at the height of the underlying terrain.</description>
%    <Point>
%      <coordinates>-122.0822035425683,37.42228990140251,0</coordinates>
%    </Point>
%  </Placemark>
%</kml>