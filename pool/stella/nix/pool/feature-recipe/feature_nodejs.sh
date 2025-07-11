if [ ! "$_NODEJS_INCLUDED_" = "1" ]; then
_NODEJS_INCLUDED_=1



feature_nodejs() {
	FEAT_NAME="nodejs"
	FEAT_LIST_SCHEMA="22_17_0@x64:binary 22_12_0@x64:binary 10_15_3@x64:binary 9_7_0@x64:binary 9_7_0@x86:binary 8_9_4@x64:binary 8_9_4@x86:binary 7_9_0@x64:binary 7_9_0@x86:binary 6_10_2@x64:binary 6_10_2@x86:binary 4_4_5@x64:binary 4_4_5@x86:binary 0_12_14@x64:binary 0_12_14@x86:binary 0_10_45@x64:binary 0_10_45@x86:binary"
	FEAT_DEFAULT_ARCH="x64"
	FEAT_DEFAULT_FLAVOUR="binary"
}



feature_nodejs_22_17_0() {
	FEAT_VERSION="22_17_0"

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x64="https://nodejs.org/dist/v22.17.0/node-v22.17.0-darwin-x64.tar.gz"
		FEAT_BINARY_URL_FILENAME_x64="node-v22.17.0-darwin-x64.tar.gz"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x64="https://nodejs.org/dist/v22.17.0/node-v22.17.0-linux-x64.tar.xz"
		FEAT_BINARY_URL_FILENAME_x64="node-v22.17.0-linux-x64.tar.xz"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
	fi


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}



feature_nodejs_22_12_0() {
	FEAT_VERSION=22_12_0

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x64="https://nodejs.org/dist/v22.12.0/node-v22.12.0-darwin-x64.tar.gz"
		FEAT_BINARY_URL_FILENAME_x64="node-v22.12.0-darwin-x64.tar.gz"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x64="https://nodejs.org/dist/v22.12.0/node-v22.12.0-linux-x64.tar.xz"
		FEAT_BINARY_URL_FILENAME_x64="node-v22.12.0-linux-x64.tar.xz"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
	fi


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}

feature_nodejs_10_15_3() {
	FEAT_VERSION=10_15_3

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x64="https://nodejs.org/dist/v10.15.3/node-v10.15.3-darwin-x64.tar.gz"
		FEAT_BINARY_URL_FILENAME_x64="node-v10.15.3-darwin-x64.tar.gz"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x64="https://nodejs.org/dist/v10.15.3/node-v10.15.3-linux-x64.tar.xz"
		FEAT_BINARY_URL_FILENAME_x64="node-v10.15.3-linux-x64.tar.xz"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
	fi


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}

feature_nodejs_9_7_0() {
	FEAT_VERSION=9_7_0

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x86=
		FEAT_BINARY_URL_FILENAME_x86=
		FEAT_BINARY_URL_PROTOCOL_x86=

		FEAT_BINARY_URL_x64="https://nodejs.org/dist/v9.7.0/node-v9.7.0-darwin-x64.tar.gz"
		FEAT_BINARY_URL_FILENAME_x64="node-v9.7.0-darwin-x64.tar.gz"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x86="https://nodejs.org/dist/v9.7.0/node-v9.7.0-linux-x86.tar.gz"
		FEAT_BINARY_URL_FILENAME_x86="node-v9.7.0-linux-x86.tar.gz"
		FEAT_BINARY_URL_PROTOCOL_x86="HTTP_ZIP"

		FEAT_BINARY_URL_x64="https://nodejs.org/dist/v9.7.0/node-v9.7.0-linux-x64.tar.gz"
		FEAT_BINARY_URL_FILENAME_x64="node-v9.7.0-linux-x64.tar.gz"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}

feature_nodejs_8_9_4() {
	FEAT_VERSION=8_9_4

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x86=
		FEAT_BINARY_URL_FILENAME_x86=
		FEAT_BINARY_URL_PROTOCOL_x86=

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v8.9.4/node-v8.9.4-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v8.9.4-darwin-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v8.9.4-linux-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v8.9.4-linux-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}

feature_nodejs_7_9_0() {
	FEAT_VERSION=7_9_0

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x86=
		FEAT_BINARY_URL_FILENAME_x86=
		FEAT_BINARY_URL_PROTOCOL_x86=

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v7.9.0/node-v7.9.0-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v7.9.0-darwin-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v7.9.0/node-v7.9.0-linux-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v7.9.0-linux-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v7.9.0/node-v7.9.0-linux-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v7.9.0-linux-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}


feature_nodejs_6_10_2() {
	FEAT_VERSION=6_10_2

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x86=
		FEAT_BINARY_URL_FILENAME_x86=
		FEAT_BINARY_URL_PROTOCOL_x86=

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v6.10.2/node-v6.10.2-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v6.10.2-darwin-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v6.10.2/node-v6.10.2-linux-x86.tar.xz
		FEAT_BINARY_URL_FILENAME_x86=node-v6.10.2-linux-x86.tar.xz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v6.10.2/node-v6.10.2-linux-x64.tar.xz
		FEAT_BINARY_URL_FILENAME_x64=node-v6.10.2-linux-x64.tar.xz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}

feature_nodejs_4_4_5() {
	FEAT_VERSION=4_4_5

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x86=
		FEAT_BINARY_URL_FILENAME_x86=
		FEAT_BINARY_URL_PROTOCOL_x86=

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v4.4.5/node-v4.4.5-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v4.4.5-darwin-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v4.4.5/node-v4.4.5-linux-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v4.4.5-linux-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v4.4.5/node-v4.4.5-linux-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v4.4.5-linux-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}

feature_nodejs_0_12_14() {
	FEAT_VERSION=0_12_14

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v0.12.14/node-v0.12.14-darwin-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v0.12.14-darwin-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v0.12.14/node-v0.12.14-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v0.12.14-darwin-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v0.12.14/node-v0.12.14-linux-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v0.12.14-linux-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v0.12.14/node-v0.12.14-linux-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v0.12.14-linux-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}

feature_nodejs_0_10_45() {
	FEAT_VERSION=0_10_45

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v0.10.45/node-v0.10.45-darwin-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v0.10.45-darwin-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v0.10.45/node-v0.10.45-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v0.10.45-darwin-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v0.10.45/node-v0.10.45-linux-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v0.10.45-linux-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v0.10.45/node-v0.10.45-linux-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v0.10.45-linux-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/node"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}


feature_nodejs_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"

}


fi
