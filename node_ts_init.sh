#! /bin/bash

projectsDirectory=~/Documents

# Collect project name, description and name

correctInputFlag=0
while [[ "$correctInputFlag" -eq 0 ]]; do
    read -p "Name of the project: " projectName
    if [[ -z "$projectName" ]]; then
        echo "No arguments, try again."
    else
        correctInputFlag=$(( correctInputFlag+1 ))
    fi
done

read -p "Feed me a short project description: " description
read -p "What's your email? (will be visible in README): " author_mail

# Create project directory if it does not already exist
if [[ -d "$projectsDirectory"/"$projectName" ]]; then
    echo "Project with such a name already exist. Terminating..."
    exit 1
else
    mkdir -p "$projectsDirectory"/"$projectName"
fi
printf '\e[1;32m%-6s\e[m' "Project directory successfully created."
printf "\n\n"

# Navigate to project directory
cd "$projectsDirectory"/"$projectName"/

# Create README.md out of template
curl https://raw.githubusercontent.com/michalakadam/NodeTSInitializr/master/templates/readme_template.md > readme_template.md

sed -e "s/PROJECT_NAME/$projectName/g" -e "s/DESCRIPTION/$description/g" -e "s/MAIL/$author_mail/g" readme_template.md > README.md
rm readme_template.md
printf "Adding README... DONE.\n"

# Initialize node with typescript support
npm init -y

npm install typescript --save-dev
npm install @types/node --save-dev

npx tsc --init --rootDir src --outDir lib --esModuleInterop --resolveJsonModule --lib es6,dom  --module commonjs

mkdir src

touch src/index.ts

printf "\n"
printf '\e[1;32m%-6s\e[m' "Node and TypeScript setup completed."
printf "\n\n"

# Live compile + run
npm install ts-node --save-dev
npm install nodemon --save-dev

sed 's#"test":.*#"start": "npm run build:live",\n    "build": "tsc -p .",\n    "build:live": "nodemon --watch \x27src/**/*.ts\x27 --exec \x27ts-node\x27 src/index.ts"#g' package.json > package.tmp
mv package.tmp package.json

printf '\e[1;32m%-6s\e[m' "Live compile + run set successfully."
printf "\n\n"

# Initialize empty git repository
git init

# Ignore files related to node and vsc
curl https://www.toptal.com/developers/gitignore/api/node,visualstudiocode > .gitignore
echo "lib/" >> .gitignore

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

printf "\n"
printf '\e[1;32m%-6s\e[m' "Git repo initialized."

code .
