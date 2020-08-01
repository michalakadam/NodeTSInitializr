#! /bin/bash

npm init -y

npm install typescript --save-dev
npm install @types/node --save-dev

npx tsc --init --rootDir src --outDir lib --esModuleInterop --resolveJsonModule --lib es6,dom  --module commonjs

mkdir src

printf "\n"
printf '\e[1;32m%-6s\e[m' "Node and TypeScript setup completed."
printf "\n\n"

# Live compile + run
npm install ts-node --save-dev
npm install nodemon --save-dev

sed 's#"test":.*#"start": "npm run build:live",\n    "build": "tsc -p .",\n    "build:live": "nodemon --watch \x27src/**/*.ts\x27 --exec \x27ts-node\x27 src/index.ts"#g' package.json > package.tmp
mv package.tmp package.json

printf '\e[1;32m%-6s\e[m' "Live compile + run set successfully."
