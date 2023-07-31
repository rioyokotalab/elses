.PHONY: all eigenkernel wavekernel clean

all: eigenkernel wavekernel

eigenkernel:
ifeq ($(WITH_EIGENKERNEL), 1)
	$(MAKE) -C eigenkernel all
endif

wavekernel:
ifeq ($(WITH_WAVEKERNEL), 1)
	$(MAKE) -C wavekernel all
endif

clean:
ifeq ($(WITH_EIGENKERNEL), 1)
	$(MAKE) -C eigenkernel clean
endif
ifeq ($(WITH_WAVEKERNEL), 1)
	$(MAKE) -C wavekernel clean
endif
