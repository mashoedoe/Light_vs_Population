<h1>Manipulating a choropleth color palette to help understand how satelite imagery of 
night light represents the distribution of people and inequality.</h1>


Maps of light distribution at night such as those produced by the 
[VIIRS polar orbiting mission](http://earthobservatory.nasa.gov/Features/NightLights/ "Night Lights") 
can help us understand human activity better. One example is population density. 
Light distribution can be a proxy for population distribution. 

According to http://journals.sfu.ca/apan/index.php/apan/article/download/7/pdf_7 the full 
resolution VIIRS imagery has the advantage of not suffering from pixel saturation in urban 
areas which was a limitation of earlier DMSP imagery and remains a valid point when comparing 
current imagery to images produced before VIIRS was available. 
The map tiles used for this Shiny App is not full resolution imagery but a set of map tiles 
provided by 
[GIBS](https://earthdata.nasa.gov/about/science-system-description/eosdis-components/global-imagery-browse-services-gibs)
and operated by [EOSDIS](https://earthdata.nasa.gov).
So in our example, light saturation is a limitation in images collected over urban areas. 

This Shiny App aims to produce an overlay map that matches the night light images of 
these map tiles using population density. We can replicate the effect of light saturation 
by assigning the same color (white) to a proportion of the most densely populated areas. 
Deciding what threshold to use for this assignment is the challenge. This Shiny App 
provides a slider and dropdown selection input for you to experiment with data from
South Africa. You can adjust the inputs to see which threshold most accurately achieves
a choropleth map that matches the underlying satelite image map tiles in urban areas 
(areas that are visible as white on the satelite map tiles).

From experimenting with the slider myself, it appears that coding the 30% most densely 
populated wards in South Africa (those with over 1473 people per km<sup>2</sup>) as the 
colour 'white' we are able to make a choropleth map that recreates the light from urban areas 
captured by the satelite image map tiles. Once you have matched the appearance of urban areas 
(choropleth versus satelite map tiles) it is then noticable how some areas of South Africa 
lack light on the satelite images where considerable population density is present according 
to the the colors of the choropleth map. This highlights the economic inequality in South Africa 
visually. 



The population totals used for each ward is from [StatsSA](http://www.statssa.gov.za/?page_id=3839) 
while boundary data for the 4277 ward shapes is from the 
[Muncipal Demarcation Board](http://www.demarcation.org.za/index.php/downloads/boundary-data/boundary-data-main-files/wards).