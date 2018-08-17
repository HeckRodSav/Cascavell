recompile:
	cd ./cpp.version; \
	make clean;       \
	make;             \
	cd ../c.version;  \
	make clean;       \
	make;             \
	cd ..;

.PHONY: clean test full

full:
	make clean recompile test


test:
	cd ./cpp.version; \
	make test;        \
	cd ../c.version;  \
	make test;        \
	cd ..

clean:
	cd ./cpp.version; \
	make clean;       \
	cd ../c.version;  \
	make clean;       \
	cd ..;            \
	rm -f ./*.log;

	
clear:
	cd ./cpp.version; \
	make clear;       \
	cd ../c.version;  \
	make clear;       \
	cd ..;            \
	rm -f ./*.log;
