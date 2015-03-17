<?	
  require_once('magpierss/rss_fetch.inc');
?>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"
        "http://www.w3.org/TR/REC-html40/loose.dtd">
<HTML>
<HEAD>
  <LINK REL="STYLESHEET" HREF="sf.css" TYPE="text/css">
  <llink rel="stylesheet" type="text/css" href="http://static.sourceforge.net/css/sfx.php?secure=0&amp;20061201-1658" media="screen" title="SFx" />
  <lllink rel="stylesheet" type="text/css" href="http://static.sourceforge.net/css/cca.php?secure=0&amp;20061201-1658" media="screen" />
  <LINK REL="STYLESHEET" HREF="style.css" TYPE="text/css">
 
  <meta name="description" content="Geostatistical Matlab toolbox">
  <meta name="keywords" content="matlab, kriging, simulation, estimation, geostat, geostatistics, inverse problem, sgems, snesim, visim, multiple point">
	    <TITLE>mGstat :  A Geostatistical Matlab toolbox (Kriging, multiple point, simualation)</TITLE>
</HEAD>

<BODY>

<H1>mGstat :  A Geostatistical Matlab toolbox</H1>


<DIV CLASS="title">Download</DIV>
<P>


<?		
    $href="https://sourceforge.net/projects/mgstat/files/mGstat/";
//$href="http://sourceforge.net/project/showfiles.php?group_id=102150";
echo "<h3 class=\"downloadbar\"><a href=$href>Download the latest mGstat</a></h3></li>";
?>

</A>
You can also get the latest development release using <A HREF="http://en.wikipedia.org/wiki/Apache_Subversion">SVN</A>: 
<PRE>
svn checkout svn://svn.code.sf.net/p/mgstat/code/trunk/mGstat mGstat
</PRE>

<DIV CLASS="title">Documentation</DIV>
<P>
mGstat user guide : [<A HREF="mGstat.pdf">PDF</A>] [<A HREF="htmldoc/">HTML</A>]


<P>


<DIV CLASS="title">Introduction</DIV>
<P>
mGstat aims to be a geostatistical toolbox for Matlab.<P>
It provides <BR>
<H3> Native kriging kriging algorithms</H3> 
Simple kriging, ordinary kriging and Universial/Kriging with a trend are available. All methods support data observations in ND-space. Thus, for example Time-Space kriging can be used.<BR>
Synthetic semivariogram can be calculated using both GSLIB and GSTAT syntax. 
Experimental semivariograms can be calculated from data observations.
<BR>[<A HREF="htmldoc/ch02.html">.. more info in the manual</A>] 


<H3> An interface to GSTAT</H3>
mGstat provides an interface to GSTAT[<A HREF="http://www.gstat.org/">www</A>], which is a popular open source computer code for multivariate geostatistical modelling.<BR>The interface enable one to call gstat and have the output returned seamlessly into Matlab.
<BR>
The interface makes it straightforward to call GSTAT using Matlab as a scripting language.

<BR> [<A HREF="htmldoc/ch03.html">..more info in the manual</A>] 

<H3> An interface to VISIM</H3>
VISIM[<A HREF="http://www.imgp.gfy.ku.dk/visim.php">www</A>] is a GSLIB style program that can be used to solve <B>linear inverse problems</B>, using either <B>Sequential Gaussian Simulation</B> or <B>Direct Sequential Simulation</B> (with histogram reproduction) conditioned to <B>noisy</B> block data.<BR>
It can also function as a conventional point based simulation algorithm.<BR>
The mGstat interface enables one to read VISIM parameter files into a Matlab structure. Any VISIM option can be changed through this structure.<BR>
Using mGstat, VISIM can be used to perform <B>Conditional Simulation thorugh Error Simulation</B>.
<BR> 
[<A HREF="htmldoc/ch04.html">..more in the manual</A>] 

<H3> An interface to SGeMS</H3>
  SGeMS[<A HREF="http://sgems.sourceforge.net/">www</A>] (the Stanford Geostatistical Modeling Software) can be called interactively from within Matlab. SGeMS provides state of the art geostatistical simulation algorithms, such as multiple-point based SNESIM and FILTERSIM codes, as well as classical 2-point algorithms, such as sequential Gaussian simulation and direct sequential simulation.
<BR> 
[<A HREF="htmldoc/ch06.html">..more in the manual</A>] 

<!--
<H3> An interface to Colin Zelts 'nfd'</H3> 
'nfd' is part of the FAST (3-D First Arrival Seismic Tomography programs)[<A HREF="http://www.geophysics.rice.edu/department/faculty/zelt/fast.html">www</A>] software package tool. It provides travel time computation using an efficient eikonal solver. mGstat provides a Matlab interface, for straightforward use of 'nfd' from within Matlab.
<BR>
The eikonal solver can for example be used to compute <A HREF="htmldoc/fresnel.html">Fresnel</A> based sensitivity kernels associated with finit-frequency wave propagation.
<BR>[<A HREF="htmldoc/nfd.html">..more in the manual</A>] 

<P>
-->
<P>
<!-- -------------------------------------------------------------------------------------- -->

<HR>
<ADDRESS>
(C) 2004-2008 Thomas Mejer Hansen, [<A HREF="mailto:thomas.mejer.hansen@gmail.com">mail</A> - <A HREF="http://www.gfy.ku.dk/~tmh">www</A>]
</ADDRESS>
<p>
<CENTER>This site is hosted by<BR>
<A href="http://sourceforge.net/projects/mgstat/">
<IMG src="http://sourceforge.net/sflogo.php?group_id=102150&type=1" width="88" height="31" border="0" alt="SourceForge Logo"> </A> 
</CENTER>

<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
_uacct = "UA-401277-6";
urchinTracker();
</script>
</BODY>
</HTML>


