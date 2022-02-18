COMPONENT=KeepYourDistanceAppC
#BUILD_EXTRA_DEPS = RadioCountMsg.py RadioCountMsg.class
#CLEAN_EXTRA = RadioCountMsg.py RadioCountMsg.class RadioCountMsg.java

#RadioCountMsg.py: KeepYourDistance.h
#	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=RadioCountMsg KeepYourDistance.h radio_count_msg -o $@

#RadioCountMsg.class: RadioCountMsg.java
#	javac RadioCountMsg.java

#RadioCountMsg.java: KeepYourDistance.h
#	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=RadioCountMsg KeepYourDistance.h radio_count_msg -o $@

CFLAGS += -I$(TOSDIR)/lib/printf
include $(MAKERULES)

