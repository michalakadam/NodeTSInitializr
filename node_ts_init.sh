#!/usr/bin/env bash

printEmptyLine () {
    for (( i=0; i<$1; i++ ))
	do  
   	    printf "\n"
	done
}

# Collect project name, description and name
correctInputFlag=0
while [[ "$correctInputFlag" -eq 0 ]]; do
    read -p "Name of the project: " projectName
    projectName=$(echo $projectName | sed -e 's/ /_/g')
    if [[ -z "$projectName" ]]; then
        echo "No arguments, try again."
    else
        correctInputFlag=$(( correctInputFlag+1 ))
    fi
done

read -p "Feed me a short project description: " description
read -p "What's your email? (will be visible in README and package.json): " author_mail

# Project needs to be initialized in parent directory.
# pwd points to node_modules when installing with npm.
projectdir=$(pwd)

# Create project directory if it does not already exist
if [[ -d "$projectdir"/"$projectName" ]]; then
    echo "Project with such a name already exist. Terminating..."
    exit 1
else
    mkdir -p "$projectdir"/"$projectName"
fi

printEmptyLine 1
printf '\e[1;32m%-6s\e[m' "Project directory successfully created at $projectdir"
printEmptyLine 2

# Navigate to project directory
cd "$projectdir"/"$projectName"/

# Create README.md out of template
curl https://raw.githubusercontent.com/michalakadam/Node_TS_Initializr/master/templates/readme_template.md > readme_template.md

sed -e "s/PROJECT_NAME/$projectName/g" -e "s/DESCRIPTION/$description/g" -e "s/MAIL/$author_mail/g" readme_template.md > README.md
rm readme_template.md

printEmptyLine 1
printf '\e[1;32m%-6s\e[m' "Adding README... DONE."
printEmptyLine 2

# Initialize node with typescript support
npm set init.name "$projectName"
npm set init.description "$description"
npm set init.author.email "$author_mail"
npm set init.type "module"
npm init -y

sed -i "s/#####//g" package.json
sed -i "s/index.js/src\/index.ts/g" package.json
sed -i 's#"main": "src/index.ts",#"main": "src/index.ts",\n  "type": "module",#' package.json
sed 's#"test":.*#"start": "npm run build:live",\n    "build": "tsc -p .",\n    "build:live": "nodemon --watch \x27src/**/*.ts\x27 --exec \x27ts-node\x27 src/index.ts",\n    "test": "jasmine-ts --config=jasmine.json"#g' package.json > package.tmp
mv package.tmp package.json

npm install --save-dev typescript
npm install --save-dev @types/node
npm install --save express
npm install --save-dev @types/express

npx tsc --init --rootDir src --outDir dist --target ES6 --lib ES6,DOM  --module ESNEXT --moduleResolution node --esModuleInterop --resolveJsonModule

mkdir src

touch src/index.ts

printEmptyLine 1
printf '\e[1;32m%-6s\e[m' "Node + Express and TypeScript setup completed."
printEmptyLine 2

# Live compile + run
npm install ts-node --save-dev
npm install nodemon --save-dev

printf '\e[1;32m%-6s\e[m' "Live compile + run set successfully."
printEmptyLine 2

# Jasmine setup
read -p "Do you want set up Jasmine?[Y/n] " jasmineAnswer
if [ "$jasmineAnswer" = "Y" ] || [ "$jasmineAnswer" = "y" ] || [ "$jasmineAnswer" = "" ]; then
  npm install --save-dev jasmine @types/jasmine
  npm install --save-dev jasmine-ts
  npm install --save-dev jasmine-spec-reporter
  mkdir spec
  curl https://raw.githubusercontent.com/michalakadam/Node_TS_Initializr/master/templates/jasmine_config_template.json > jasmine.json

  printEmptyLine 1
  printf '\e[1;32m%-6s\e[m' "Jasmine setup completed."
  printEmptyLine 2
fi

# Fix any vurnerabilities
npm audit fix

# Initialize empty git repository
git init

# Ignore files related to node and vsc
curl https://www.toptal.com/developers/gitignore/api/node,visualstudiocode > .gitignore
echo "dist/" >> .gitignore

# Enable user to add remote repository
read -p "Do you want to track remote repository?[Y/n] " repoAnswer
if [ "$repoAnswer" = "Y" ] || [ "$repoAnswer" = "y" ] || [ "$repoAnswer" = "" ]; then
    read -p "Feed me with link to the repository: (press q to quit) " repoLink
    #enable user to quit here
    if [ "$repoLink" = "q" ]; then
        echo "Quitting connection to remote repository"
    else
        git remote add origin $repoLink
    fi
fi

# Initial commit + switch to development branch
git add .
git commit -m "initial commit with project template generated"
git checkout -b development

printEmptyLine 1
printf '\e[1;32m%-6s\e[m' "Git repo initialized."

code .
