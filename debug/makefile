flags = -llua -Lfull_lua/src -Ifull_lua/src

all: engine

clean:
	rm engine

engine: engine.c
	cc $< -o $@ -g -rdynamic $(flags)
