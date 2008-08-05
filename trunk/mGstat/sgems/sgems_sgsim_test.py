import sgems

j=40; 
i=80;

sgems.execute('DeleteObjects SIM')
sgems.execute('DeleteObjects finished')
sgems.execute('NewCartesianGrid  SIM::100::100::1::1.0::1.0::1.0::0::0::0')

for maxcd in range(1,2,1):

  property_name='SIM'+str(maxcd)

  cmd='RunGeostatAlgorithm  sgsim::/GeostatParamUtils/XML::<parameters>  <algorithm name="sgsim" />     <Grid_Name  value="SIM"  />     <Property_Name  value="'+property_name+'" />     <Nb_Realizations  value="1" />     <Seed  value="14071789" />     <Kriging_Type  value="Simple Kriging (SK)"  />     <Trend  value="0 0 0 0 0 0 0 0 0 " />    <Local_Mean_Property  value=""  />     <Assign_Hard_Data  value="1"  />     <Hard_Data  grid=""   property=""  />     <Max_Conditioning_Data  value="'+str(maxcd)+'" />     <Search_Ellipsoid  value="80 80 80  0 0 0" />    <Use_Target_Histogram  value="0"  />     <nonParamCdf  ref_on_file ="0"  ref_on_grid ="1"  break_ties ="0" filename =""   grid =""  property ="">  <LTI_type  function ="Power"  extreme ="0"  omega ="3" />  <UTI_type  function ="Power"  extreme ="0"  omega ="0.333" />  </nonParamCdf>    <Variogram  nugget="0.001" structures_count="1"  >    <structure_1  contribution="0.999"  type="Gaussian"   >      <ranges max="'+str(j)+'"  medium="'+str(j/2)+'"  min="'+str(j/3)+'"   />      <angles x="'+str(i)+'"  y="0"  z="0"   />    </structure_1>  </Variogram>  </parameters>'   

  sgems.execute(cmd)
  sgems.execute('DisplayObject SIM::'+property_name+'__real0')

  sgems.execute('SaveGeostatGrid  SIM::'+property_name+'.out::gslib::0::'+property_name+'__real0');


sgems.execute('NewCartesianGrid  finished::1::1::1::1.0::1.0::1.0::0::0::0')
data=[]
data.append(1)
sgems.set_property('finished','dummy',data)
sgems.execute('SaveGeostatGrid  finished::c:/Users/tmh/PROGRAMMING/Austin/SGeMS/finished::gslib::0::dummy');
sgems.execute('SaveGeostatGrid  finished::finished::gslib::0::dummy');


