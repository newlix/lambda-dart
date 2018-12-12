.PHONY: gentest test
gentest:
	gentest
test:
	cd testapp; flutter drive --target=lib/drive.dart