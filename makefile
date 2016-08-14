flags    = -llua -Llua -Ilua

all: engine

clean:
	rm engine

engine: engine.c
	cc $< -o $@ $(flags)
