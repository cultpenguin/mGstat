% kml_points : Creates a KML file defining a point/placemark
% 
% Call : 
% 
% kml_points(kml_file,lat,lon,name,descr,icon);
%
% icon : 'triangle','arrowdown','shot' or 'globe'
%
% Ex : 
%  kml_points('point.kml',[55],[12]);
%  kml_points('point.kml',[55],[12],'A Test','And a description');
%  kml_points('points.kml',[55 55.1],[12 12.1],'A Test','And a description','triangle');
%
function kml_points(kml_file,lat,lon,name,descr,icon);
ele=lat.*0;
if nargin<1
    kml_file='data.kml';
end
if nargin<4, name='NAME';end
if nargin<5, descr='DESCRIPTION';end
if nargin<6, icon='globe';end

fid = fopen(kml_file,'w');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid,'<kml xmlns="http://www.opengis.net/kml/2.2">\n');
if (length(lat)>1)
    fprintf(fid,'<Folder>');
    fprintf(fid,'      <name>%s</name>',name);
    fprintf(fid,'      <description>%s</description>',descr);
end    
fprintf(fid,'<Style id="triangle"><IconStyle><Icon><Scale>0.1</Scale><href>http://maps.google.com/mapfiles/kml/pal4/icon52.png</href></Icon></IconStyle></Style>');
fprintf(fid,'<Style id="shot"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pal4/icon51.png</href></Icon></IconStyle></Style>');
fprintf(fid,'<Style id="arrowdown"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pal4/icon28.png</href></Icon></IconStyle></Style>');
fprintf(fid,'<Style id="globe"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pal3/icon19.png</href></Icon></IconStyle></Style>');
for i=1:length(lat);
fprintf(fid,'  <Placemark>\n');
name=sprintf('%d',i);
fprintf(fid,'    <name>%s</name>\n',name);
fprintf(fid,'    <description>%s\n',descr);
fprintf(fid,'    </description>\n');
fprintf(fid,'    <styleUrl>#%s</styleUrl>\n',icon);
fprintf(fid,'    <Point>\n');
fprintf(fid,'      <coordinates>%16.6f,%16.6f,%g</coordinates>\n',lon(i),lat(i),ele(i));
fprintf(fid,'    </Point>\n');
fprintf(fid,'  </Placemark>\n');
end
if (length(lat)>1)
    fprintf(fid,'</Folder>\n');
end
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