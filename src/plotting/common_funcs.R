library(ggplot2)
library(grid)
library(ggthemes)
library(scales)

#----------------------------------------------------------------
# themes for papers
#----------------------------------------------------------------
theme0 <- function(base_size=10, base_family="Helvetica") {
  (theme_foundation(base_size=base_size, base_family=base_family)
   + theme(
			 plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0.5),
	     text = element_text(),
	     panel.background = element_rect(colour = NA),
	     plot.background = element_rect(colour = NA),
	     panel.border = element_rect(colour = NA),
	     axis.title = element_text(size = rel(1)),
			 axis.text.y = element_blank(),
			 axis.ticks.x = element_blank(),
			 axis.text.x = element_blank(),
			 axis.line.x = element_blank(),
	     axis.title.y = element_text(angle=90,vjust =2),
			 axis.title.x = element_text(vjust  = -0.2),
			 # axis.title.x = element_blank(),
	     axis.text = element_text(size = rel(1)),
	     axis.line = element_line(colour="#000000"),
	     axis.ticks = element_line(),
	     panel.grid.major = element_line(colour="#f0f0f0"),
	     panel.grid.minor = element_blank(),
	     legend.key = element_rect(colour = NA),
 	     legend.position = "none",
	     # legend.position = "top",
	     legend.direction = "horizontal",
	     legend.key.size= unit(0.8, "cm"),
	     legend.margin = unit(1, "cm"),
			 legend.title = element_blank(),
	     # legend.title = element_text(face="italic"),
	     plot.margin=unit(c(1,5,5,5),"mm"),
	     strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
	     # strip.text = element_text(face="bold")
     )
	 )
}

theme1 <- function(base_size=10, base_family="Helvetica") {
  (theme_foundation(base_size=base_size, base_family=base_family)
   + theme(
			 plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0.5),
	     text = element_text(),
	     panel.background = element_rect(colour = NA),
	     plot.background = element_rect(colour = NA),
	     panel.border = element_rect(colour = NA),
	     axis.title = element_text(size = rel(1)),
			 axis.ticks.x = element_blank(),
			 axis.text.x = element_blank(),
			 # axis.line.x = element_blank(),
	     axis.title.y = element_text(angle=90,vjust =2),
			 # axis.title.x = element_text(vjust  = -0.2),
			 axis.title.x = element_blank(),
	     axis.text = element_text(size = rel(1)),
	     axis.line = element_line(colour="#000000"),
	     axis.ticks = element_line(),
	     panel.grid.major = element_line(colour="#f0f0f0"),
	     panel.grid.minor = element_blank(),
	     legend.key = element_rect(colour = NA),
 	     legend.position = "none",
	     # legend.position = "bottom",
	     legend.direction = "horizontal",
	     legend.key.size= unit(0.5, "cm"),
	     legend.margin = unit(1, "cm"),
			 legend.title = element_blank(),
	     # legend.title = element_text(face="italic"),
	     plot.margin=unit(c(-5,5,5,5),"mm"),
	     strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
	     # strip.text = element_text(face="bold")
     )
	 )
}

theme2 <- function(base_size=23, base_family="Helvetica") {
  (theme_foundation(base_size=base_size, base_family=base_family)
   + theme(
       plot.title = element_blank(),
			 # plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0.5),
			 plot.background = element_rect(colour = NA),
			 plot.margin=unit(c(5,5,5,5),"mm"),
	     panel.background = element_rect(colour = NA),
	     panel.border = element_rect(colour = NA),
			 panel.grid.major = element_line(colour="#f0f0f0"),
			 panel.grid.minor = element_blank(),
	     # axis.title = element_text(size = rel(1)),
			 # axis.text.y = element_blank(),
			 # axis.ticks.y=element_blank(),
			 # axis.line.y=element_blank(),
	     axis.title.y = element_text(angle=90,vjust =2),
			 axis.title.x = element_text(vjust  = -0.2),
			 # axis.title.x = element_blank(),
	     axis.text = element_text(size = rel(1)),
	     axis.line = element_line(colour="#000000"),
	     axis.ticks = element_line(),
	     legend.key = element_rect(colour = NA),
	     legend.position = "top",
       # legend.position = "none",
	     legend.direction = "horizontal",
	     legend.key.size= unit(0.5, "cm"),
	     legend.margin = unit(1, "cm"),
			 # legend.title = element_blank(),
	     legend.title = element_text(),
	     strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
	     # strip.text = element_text(face="bold")
     )
	 )
}

#----------------------------------------------------------------
# miscelaneaus functions
#----------------------------------------------------------------
plotCDFset <- function(df, info) {
	p <- ggplot( df, aes(x=data, linetype=Scenario) )
  p <- p + stat_ecdf( aes(y=..y..*100), size=0.5, pad=FALSE )
  p <- p + scale_linetype_manual( values=c('solid', 'dotted') )
	p <- p + labs( title=info$title, x=info$xlabel, y=info$ylabel )
  p + theme2()
}

meanStd <- function(x) {
   m <- mean(x)
   ymin <- m-sd(x)
   ymax <- m+sd(x)
   return(c(y=m,ymin=ymin,ymax=ymax))
}
plotDistribGroups <- function(ds, info, withBoxplot=FALSE, withDensity=TRUE) {
  if ( withDensity ) {
    p <- ggplot(data = ds, aes(x = group, y = data, fill = Scenario) )
    # p <- p + scale_fill_manual( values=c("#cccccc", "#ffffff") )
  } else {
    p <- ggplot(data = ds, aes(x = group, y = data) )
    # p <- p + scale_fill_manual( values=c("#ffffff") )
  }
  if (withBoxplot) {
    p <- p + stat_boxplot( geom ='errorbar', width=0.25, position=position_dodge(width=0.75) )
    p <- p + geom_boxplot( outlier.shape=NA, notch=TRUE, fill='grey')

    # NOTE plot with logarithmic scale
    p <- p + scale_y_log10(
      breaks = trans_breaks("log10", function(x) 10^x),
      labels = trans_format("log10", math_format(10^.x) ),
      limits = c(1, 10000)
    )
    p <- p + annotation_logticks(sides="l")

    # NOTE no modifications in scale
    # p <- p + ylim(0, info$ylim)
  } else {
    p <- p + geom_violin()
    p <- p + stat_summary(
      fun.data=meanStd, mult=1, geom="point", color="black", position=position_dodge(width=0.9)
    )
  }
  p <- p + labs(title=info$title, x=info$xlabel, y=info$ylabel)
  p + theme2()
}

plotColumns <- function(ds, info, withDensity=TRUE) {
  if ( withDensity ) {
    p <- ggplot(data = ds, aes(x = group, y = data, fill = Scenario) )
    p <- p + scale_fill_manual( values=c("#cccccc", "#ffffff") )
    p <- p + geom_text(
      aes(label=data, group=Scenario),
      position=position_dodge(width=1.1), vjust=-.3, size=5
    )
  } else {
    p <- ggplot(data = ds, aes(x = group, y = data) )
    p <- p + geom_text(
      aes(label=data),
      position=position_dodge(width=1.1), vjust=-.3, size=5
    )
  }

  # p <- p + geom_col(position="dodge2", colour="black", fill="white")
  p <- p + geom_col(position="dodge2", colour="black", fill="grey")

  p <- p + labs(title=info$title, x=info$xlabel, y=info$ylabel)
	p <- p + ylim(0, info$ylim)
  p + theme2()
}

plotDistribByProtocol <- function(ds, info) {
  p <- ggplot( ds, aes(x=data, linetype=protocol) )
  p <- p + stat_ecdf( aes(y=..y..*100), size=0.5, pad=FALSE )
  p <- p + scale_linetype_manual( values=c('solid', 'dotted') )
  p <- p + scale_x_continuous(breaks=seq(0, 20, 2))
	p <- p + labs( title=info$title, x=info$xlabel, y=info$ylabel )
  p + theme2()
}
