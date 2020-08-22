library(dplyr)
library(ggplot2)
library(gridExtra)

stormdata <- read.csv("./repdata_data_StormData.csv.bz2")

health <- c("EVTYPE", "FATALITIES", "INJURIES")
healthdata <- stormdata[health]

damage <- c("EVTYPE", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP")
damagedata <- stormdata[damage]

fatalitydata <- aggregate(FATALITIES ~ EVTYPE, healthdata, sum)
fatalitytop10 <- top_n(fatalitydata, 10, FATALITIES)
fatalitysort <- fatalitytop10[order(fatalitytop10$FATALITIES, decreasing = T),]

injurydata <- aggregate(INJURIES ~ EVTYPE, healthdata, sum)
injurytop10 <- top_n(injurydata, 10, INJURIES)
injurysort <- injurytop10[order(injurytop10$INJURIES, decreasing = T),]

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

grid.arrange(fatalityplot, injuryplot, nrow = 1)

damagedata$PROPDMGEXP[damagedata$PROPDMGEXP == "0"] <- 0
damagedata$PROPDMGEXP[damagedata$PROPDMGEXP == "K"] <- 1000
damagedata$PROPDMGEXP[damagedata$PROPDMGEXP == "M"] <- 1000000
damagedata$PROPDMGEXP[damagedata$PROPDMGEXP == "B"] <- 1000000000

damagedata$PROPDMG <- damagedata$PROPDMG * as.numeric(damagedata$PROPDMGEXP)
damagedata$PROPDMG <- damagedata$PROPDMG / 1000000000

propdmgdata <- aggregate(PROPDMG ~ EVTYPE, damagedata, sum)
propdmgtop10 <- top_n(propdmgdata, 10, PROPDMG)
propdmgsort <- propdmgtop10[order(propdmgtop10$PROPDMG, decreasing = T),]

damagedata$CROPDMGEXP[damagedata$CROPDMGEXP == "0"] <- 0
damagedata$CROPDMGEXP[damagedata$CROPDMGEXP == "K"] <- 1000
damagedata$CROPDMGEXP[damagedata$CROPDMGEXP == "M"] <- 1000000
damagedata$CROPDMGEXP[damagedata$PROPDMGEXP == "B"] <- 1000000000

damagedata$CROPDMG <- damagedata$CROPDMG * as.numeric(damagedata$CROPDMGEXP)
damagedata$CROPDMG <- damagedata$CROPDMG / 1000000000

cropdmgdata <- aggregate(CROPDMG ~ EVTYPE, damagedata, sum)
cropdmgtop10 <- top_n(cropdmgdata, 10, CROPDMG)
cropdmgsort <- cropdmgtop10[order(cropdmgtop10$CROPDMG, decreasing = T),]

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

grid.arrange(propdmgplot, cropdmgplot, nrow = 1)