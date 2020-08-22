NOAA Storm Database Analysis: Impact of Severe Weather on Population Health and Economy
=======================================================================================

Synopsis
--------

The purpose of this assignment is to analyze data collected from the
NOAA storm database and draw conclusions concerning its impact on the
population. The data documents a multitude of instances of severe
weather from 1950 to 2011 and records the time and place these events
occurred alongside their impact on population health and the economy.
Our analysis will attempt to diagnose the events that cause the most
negative impact on population health with respect to civilian injuries
and fatalities and on the economy with respect to property and crop
damage. This data may provide use in future planning for severe weather
in terms of resource allocation and general threat level.

Data Processing
---------------

#### Libraries

Our analysis begins by loading relevant libraries. `dplyr` is needed to
manipulate and condense the raw data. `ggplot2` is used to create
relevant figures to illustrate and answer the questions presented.
`gridExtra` allows us to include multiple plots in one figure.

    library(dplyr)

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    library(ggplot2)
    library(gridExtra)

    ## 
    ## Attaching package: 'gridExtra'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     combine

#### Reading Data

We start with a compressed comma-separated-value file that we read into
R using the `read.csv` command.

    stormdata <- read.csv("./repdata_data_StormData.csv.bz2")

#### Subsetting Data

We then subset the data into two separate data frames which will be used
for further analysis. Our aim is to answer the two questions:

1.  Across the United States, which types of events (as indicated in the
    EVTYPE variable) are most harmful with respect to population health?

2.  Across the United States, which types of events have the greatest
    economic consequences?

Our first data frame will address the the question concerning population
health. We will subset the data to focus on the “FATALITIES” and
“INJURIES” variables to find which severe weather event type most
negatively affects the population.

    health <- c("EVTYPE", "FATALITIES", "INJURIES")
    healthdata <- stormdata[health]

Our second data frame will address the latter question. We will subset
the data to focus on the “PROPDMG” and “CROPDMG” variables (property and
crop damage respectively). It is important to note that “PROPDMGEXP” and
“CROPDMGEXP” variables contain the exponent for the numerical value
contained in the previous two variables stated and must be included as
well.

    damage <- c("EVTYPE", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP")
    damagedata <- stormdata[damage]

#### Sorting Data by Event Type

We next sort the data by event type for the four variables we discussed
above. We use the `aggregate` function from the `dplyr` package in order
to sum the values by event type (EVTYPE) in order to uncover which has
the most impact for each respective variable. The `top_n` function is
utilized to find the top 10 event types that have the biggest impact on
population health (fatalities and injuries) and the economy (property
and crop damage). The `order` function is used to reorder the top 10
instances that were extracted from the raw dataset for each variable.

This process was straightforward for “FATALITIES” and “INJURIES” as the
data only needed to be aggregated with respect to event type. We find
the Top 10 event types for each below:

    fatalitydata <- aggregate(FATALITIES ~ EVTYPE, healthdata, sum)
    fatalitytop10 <- top_n(fatalitydata, 10, FATALITIES)
    fatalitysort <- fatalitytop10[order(fatalitytop10$FATALITIES, decreasing = T),]

    injurydata <- aggregate(INJURIES ~ EVTYPE, healthdata, sum)
    injurytop10 <- top_n(injurydata, 10, INJURIES)
    injurysort <- injurytop10[order(injurytop10$INJURIES, decreasing = T),]

Before we make same transformation for “PROPDMG” and “CROPDMG”, we have
to consider that “PROPDMGEXP” and “CROPDMGEXP” contains vital
information surrounding the magnitude of the previous variable. `K`
denotes one thousand, `M` denotes one million, and `B` denotes one
billion. We replace these variables with their numerical counterparts to
allow for easier data manipulation.

    damagedata$PROPDMGEXP[damagedata$PROPDMGEXP == "0"] <- 0
    damagedata$PROPDMGEXP[damagedata$PROPDMGEXP == "K"] <- 1000
    damagedata$PROPDMGEXP[damagedata$PROPDMGEXP == "M"] <- 1000000
    damagedata$PROPDMGEXP[damagedata$PROPDMGEXP == "B"] <- 1000000000

    damagedata$CROPDMGEXP[damagedata$CROPDMGEXP == "0"] <- 0
    damagedata$CROPDMGEXP[damagedata$CROPDMGEXP == "K"] <- 1000
    damagedata$CROPDMGEXP[damagedata$CROPDMGEXP == "M"] <- 1000000
    damagedata$CROPDMGEXP[damagedata$PROPDMGEXP == "B"] <- 1000000000

We then multiply “PROPDMG” by “PROPDMGEXP” and “CROPDMG” by “CROPDMGEXP”
in order to obtain the true property and crop damage values for each.

    damagedata$PROPDMG <- damagedata$PROPDMG * as.numeric(damagedata$PROPDMGEXP)

    ## Warning: NAs introduced by coercion

    damagedata$CROPDMG <- damagedata$CROPDMG * as.numeric(damagedata$CROPDMGEXP)

    ## Warning: NAs introduced by coercion

The data is now suitable to aggregate. We apply the same transformation
as before by utiziling the `aggregate`,`top_n`, and `order` functions
for both “CROPDMG” and “PROPDMG”. We can see how large the values are by
using the `head` function.

    propdmgdata <- aggregate(PROPDMG ~ EVTYPE, damagedata, sum)
    propdmgtop10 <- top_n(propdmgdata, 10, PROPDMG)
    propdmgsort <- propdmgtop10[order(propdmgtop10$PROPDMG, decreasing = T),]
    head(propdmgsort)

    ##              EVTYPE      PROPDMG
    ## 2             FLOOD 144657709800
    ## 6 HURRICANE/TYPHOON  69305840000
    ## 8           TORNADO  56925660991
    ## 7       STORM SURGE  43323536000
    ## 1       FLASH FLOOD  16140812087
    ## 3              HAIL  15727366870

    cropdmgdata <- aggregate(CROPDMG ~ EVTYPE, damagedata, sum)
    cropdmgtop10 <- top_n(cropdmgdata, 10, CROPDMG)
    cropdmgsort <- cropdmgtop10[order(cropdmgtop10$CROPDMG, decreasing = T),]
    head(cropdmgsort)

    ##         EVTYPE     CROPDMG
    ## 1      DROUGHT 12472566000
    ## 4        FLOOD  5661968450
    ## 6         HAIL  3025537450
    ## 8    HURRICANE  2741910000
    ## 3  FLASH FLOOD  1421317100
    ## 2 EXTREME COLD  1292973000

Noticing that the damage values are into the billions, we apply one last
transformation to the data to make for easier-to-read plots in the
future.

    propdmgsort$PROPDMG <- propdmgsort$PROPDMG / 1000000000
    cropdmgsort$CROPDMG <- cropdmgsort$CROPDMG / 1000000000

Our aggregated top 10 event types for “FATALITIES”, “INJURIES”,
“PROPDMG”, and “CROPDMG” are now ready to be visually represented.

Results
-------

#### Plotting

We are now ready to plot the results using `ggplot`. We used `geom_col`
to represent the magnitude of each event type. Our first figure will
compare event types with respect to population health. Plots for
“FATALITIES” and “INJURIES” are constructed below:

    fatalityplot <- ggplot(fatalitysort, aes(EVTYPE, FATALITIES)) +
      geom_col(fill = "#CC6666") +
      ggtitle("Events Causing Highest Fatalities") +
      xlab("Event Type") +
      ylab("Fatalities") +
      theme(plot.title = element_text(hjust = 0.5)) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      scale_x_discrete(limits=fatalitysort$EVTYPE)

    injuryplot <- ggplot(injurysort, aes(EVTYPE, INJURIES)) +
      geom_col(fill = "#66CC99") +
      ggtitle("Events Causing Highest Injuries") +
      xlab("Event Type") +
      ylab("Injuries") +
      theme(plot.title = element_text(hjust = 0.5)) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      scale_x_discrete(limits=injurysort$EVTYPE)

We then repeat the same process with the respect to the economy by
plotting “PROPDMG” and “CROPDMG” below:

    propdmgplot <- ggplot(propdmgsort, aes(EVTYPE, PROPDMG)) +
      geom_col(fill = "#9999CC") +
      ggtitle("Events Causing Most Property Damage") +
      xlab("Event Type") +
      ylab("Property Damage in Billions of $") +
      theme(plot.title = element_text(hjust = 0.5)) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      scale_x_discrete(limits=propdmgsort$EVTYPE)

    cropdmgplot <- ggplot(cropdmgsort, aes(EVTYPE, CROPDMG)) +
      geom_col(fill = "#FF9666") +
      ggtitle("Events Causing Most Crop Damage") +
      xlab("Event Type") +
      ylab("Crop Damage in Billions of $") +
      theme(plot.title = element_text(hjust = 0.5)) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      scale_x_discrete(limits=cropdmgsort$EVTYPE)

#### Population Health

The figures can be constructed using the `grid.arrange` function in the
`gridExtra` library. This allows us to put two plots on the same figure
for easier comparison.

    grid.arrange(fatalityplot, injuryplot, nrow = 1)

![Figure 1: Severe weather’s impact on population
health.](NOAA_Storm_Database_Analysis_files/figure-markdown_strict/unnamed-chunk-13-1.png)

We can see that with respect to population health, tornadoes account for
the most fatalities and injuries and dwarf the competition. This puts a
heavy emphasis on tornadoes when considering population health.

#### Economy

    grid.arrange(propdmgplot, cropdmgplot, nrow = 1)

![Figure 2: Severe weather’s impact on the
economy.](NOAA_Storm_Database_Analysis_files/figure-markdown_strict/unnamed-chunk-14-1.png)

We can see that with respect to the economy that while droughts cause
the most crop damage, floods cause the most property damage, second most
crop damage, and most total damage. Hurricanes/typhoons also have the
second most impact in terms of total damage, making all three event
types very important to consider with respect to the economic
consequences of severe weather.

Conclusion
----------

After analyzing the data provided by the NOAA Storm Database, we can
conclude that tornadoes, floods, hurricanes/typhoons, and droughts are
all instances of severe weather that can pose a huge threat on the
population. Tornadoes have a tremendous impact on population health and
property damage. Floods and hurricanes/typhoons account for the largest
economic consequences, but droughts must also be taken into account when
considering their large impact on agriculture.
