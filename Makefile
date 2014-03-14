all:
	mkdir -p gen_love/lib; mkdir -p gen_love/res
	cp -ru ./src/lib ./gen_love
	cp -ru ./res/ ./gen_love
	cd ./src; moonc -t ../gen_love . > /dev/null
	cd ./gen_love; ../thirdparty/love-release.sh -l -r build -n RÖPE -u Altom -v 0.9.0
	love gen_love/build/0.9.0/RÖPE.love
