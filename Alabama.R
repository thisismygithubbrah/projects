# Alabama shapefile source
# https://dataverse.harvard.edu/dataset.xhtml?persistentId=hdl:1902.1/16796#

library(sf)
library(ggplot2)
al <- st_read('AL_Shapefile/al_final.shp')

m <- ggplot() +
  theme_minimal() + 
  theme(text = 
          element_text(family    = 'Arial'))

# Discrete Version
ggal <- m + geom_sf(data = al, 
            aes(fill = cut_interval(P_08, n = 5)), 
            color = 'white', lwd = .02) +
  # scale_fill_brewer("% Voted Dem 2012", palette = 'RdBu')
  scale_fill_manual(values = c(scales::muted('red'), 'red', 'purple', 'blue', scales::muted('blue'))) +
  guides(fill = guide_legend(title = "% Vote Obama '08")) +
  theme(legend.position = 'bottom', legend.title = element_text(size = 10))

library(extrafont)
loadfonts() # loads 'Arial' font
pdf('alabama_discrete.pdf')
system.time(print(ggal)) # 14 seconds on 2015 MBP
dev.off()

# svg('plot.svg')
# ggal
# dev.off()
# Gradient Version
ggal_gradient <- m + geom_sf(data = al, 
            aes(fill = P_08), 
            color = 'white', lwd = .02) + 
  scale_fill_gradient(low = scales::muted('red'), high = 'blue') +
  guides(fill = guide_colorbar(title = "% Vote Obama '08", barheight = unit(6, 'cm'))) +
  theme(axis.text.x = element_text(size = 7))

pdf('alabama_gradient.pdf')
system.time(print(ggal_gradient)) # 14 seconds on MBP
dev.off()

# Note: Do not use Quartz if you are on macOS, this default graphics device takes 120s+
# Likely speed boost if you use sp rather than newer sf package. 
  # Do this for larger, more fine-grained shapefiles like Wisconsin

# Benchmarking:
# > # Discrete Version
#   > system.time(print(m + geom_sf(data = al, 
#                                   +             aes(fill = cut_interval(P_08, n = 5)), 
#                                   +             color = 'white', lwd = .02) +
#                         +   # scale_fill_brewer("% Voted Dem 2012", palette = 'RdBu')
#                         +   scale_fill_manual(values = c(scales::muted('red'), 'red', 'purple', 'blue', scales::muted('blue'))) +
#                         +   guides(fill = guide_legend(title = "% Vote Obama '08")) +
#                         +   theme(legend.position = 'bottom', legend.title = element_text(size = 10))))
# user  system elapsed 
# 24.808   4.255  28.800 
    # 24 seconds to render!! bc known issue w graphics device. versus only .03 seconds to create!
# what is the critical difference between when Quartz opens a new window on its own versus uses
# the static 'plots' window inside RStudio?


# Notes:
# You can add a drop shadow by using a base of grey polygons shifted slightly southeast,
# like in http://unconj.ca/blog/choropleth-maps-with-r-and-ggplot2.html, where the author uses
# sp but you can do this gy just adding to the geometry directly according to sf docs

# dropshadow <- al; dropshadow$geometry <- dropshadow$geometry + c(.005, -.002)
# m + geom_sf(data = dropshadow %>% mutate(geometry = geometry + c(.005, -.002)),
#             color = "grey50", size = 0.2, fill = "grey50")

# known issue w RStudio graphics device slowing everything down: 
# https://community.rstudio.com/t/ggplot2-geom-sf-performance/3251
# change plotting device to X11 to rectify
# use 'system.time(print(sf-object))' and similar statements to benchmark

# More overlay options from Claudia Engel:
# https://cengel.github.io/rspatial/4_Mapping.nb.html

# How to log-transform a choropleth:
# https://www.r-graph-gallery.com/327-chloropleth-map-from-geojson-with-ggplot2/