OOCFLAGS += -v

all: game

game:
	rock $(OOCFLAGS)

clean:
	rock -x

.PHONY: all game clean
