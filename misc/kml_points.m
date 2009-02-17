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
    fprintf(fid,'<Folder>\n');
    try
        fprintf(fid,'      <name>%s</name>\n',name);
        fprintf(fid,'      <description>%s</description>\n',descr);
    end
end    
fprintf(fid,'<Style id="triangle"><IconStyle><Icon><Scale>0.1</Scale><href>http://maps.google.com/mapfiles/kml/pal4/icon52.png</href></Icon></IconStyle></Style>\n');
fprintf(fid,'<Style id="shot"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pal4/icon51.png</href></Icon></IconStyle></Style>\n');
fprintf(fid,'<Style id="arrowdown"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pal4/icon28.png</href></Icon></IconStyle></Style>\n');
fprintf(fid,'<Style id="globe"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pal3/icon19.png</href></Icon></IconStyle></Style>\n');
if isnumeric(icon)
    for i=1:length(icon)
    fprintf(fid,'<Style id="%d"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pal3/icon%d.png</href></Icon></IconStyle></Style>\n',icon(i),icon(i));
    end
end

try
    if (strcmp(icon(1:4),'http'))
        % WEB ADDRESS FOR ICCON
        fprintf(fid,'<Style id="web"><IconStyle><Icon><href>%s</href></Icon></IconStyle></Style>\n',icon);
        icon='web';
    end
end

for i=1:length(lat);
fprintf(fid,'  <Placemark>\n');
name_str='';
if iscell(name);
    try
        name_str=name{i};
    end
else
    try
       name_str=name;
    end
end

descr_str='';
if iscell(descr);
    try
        descr_str=descr{i};
    end
else
    try
       descr_str=descr;
    end
end

fprintf(fid,'    <name>%s</name>\n',name_str);
fprintf(fid,'    <description>%s\n',descr_str);
fprintf(fid,'    </description>\n');
if isnumeric(icon)
    try
        fprintf(fid,'    <styleUrl>#%d</styleUrl>\n',icon(i));
    catch
        fprintf(fid,'    <styleUrl>#%d</styleUrl>\n',icon);
    end
else
    fprintf(fid,'    <styleUrl>#%s</styleUrl>\n',icon);
end
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